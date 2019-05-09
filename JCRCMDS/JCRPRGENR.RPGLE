       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRPRGENR - generate callp prototypes
       //  Call programs to read compile listings and generate prototype.
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define Constants
       /define f_GetQual
       /define f_Qusrmbrd
       /define f_SndCompMsg
       /define f_SndEscapeMsg
       /define FieldsArry
       /define FieldsAttrDS
       /define f_IsIgnoreLine
       /define f_IsCompileTimeArray
       /define f_GetProcedureEntryPoint
       /define f_GetParmFieldsArryIndex
       /define f_GetDataTypeKeyWords
       /define SourceOutDS
       /define p_JCRGETCLPR
       /define p_JCRGETFLDR
       // *ENTRY
       /define p_JCRPRGENR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRGETFLDF disk(132) extfile('QTEMP/JCRGETFLDF') usropn;
       dcl-ds InputDS len(132) qualified inz;
        CompileArray char(3) pos(3);
        SpecType char(1) pos(8);
        Src94 char(94) pos(9);
        SourceListing char(27) pos(27);
        EndOfSource char(25) pos(20);
       end-ds;
 
       dcl-f PROTOSRC disk(112) usage(*output) extfile(extOFile)
       extmbr(p_InsertInMbr) usropn;
 
       //---------------------------------------------------------
       dcl-s string varchar(94);
       dcl-s ProcedureEntryPoint char(6);
       dcl-s PepCnt packed(3);
       dcl-s DoParmCnt packed(3);
 
       //---------------------------------------------------------
       extOFile = f_GetQual(p_InsertFileQual);
       open PROTOSRC;
 
 1b    if p_Pgmatr = 'RPGLE'
          or p_Pgmatr = 'SQLRPGLE';
          exsr srRPG;
 
 1x    elseif p_Pgmatr = 'CLLE'
          or p_Pgmatr = 'CLP';
          exsr srCL;
 1e    endif;
 
       close PROTOSRC;
 
       f_SndCompMsg('JCRPRGEN Protoype for ' +
       %trimr(p_SrcMbr) + ' in member ' +
       %trimr(p_InsertInMbr) + ' - completed.');
 
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       // if no parms, do a single line pr
       // dcl-pr p_TEST extpgm('TEST') end-pr;
       //---------------------------------------------------------
       begsr srWriteDclPR;
       QusrmbrdDS = f_Qusrmbrd(p_SrcFil + p_SrcLib: p_SrcMbr: 'MBRD0100');
 
       OutDS.SrcCod = ' //-----' + %trim(QusrmbrdDS.Text) + ' ------';
       OutDS.SrcSeq += 10;
       write PROTOSRC OutDS;
 
       OutDS.SrcCod = ' dcl-pr  p_' + %trimr(p_SrcMbr) +
       '  extpgm(' + qs +
       %trimr(p_SrcMbr) + qs + ')';
 
 1b    if PepCnt = 0;
          OutDS.SrcCod = %trimr(OutDS.SrcCod) + ' end-pr;';
 1x    else;
          OutDS.SrcCod = %trimr(OutDS.SrcCod) + ';';
 1e    endif;
 
       OutDS.SrcSeq += 10;
       write PROTOSRC OutDS;
       endsr;
 
       //---------------------------------------------------------
       begsr srWriteEndPR;
       OutDS.SrcCod = ' end-pr;';
       OutDS.SrcSeq += 10;
       write PROTOSRC OutDS;
       endsr;
 
       //---------------------------------------------------------
       // Get field attributes from JCRGETFLDR
       // Extract parm field names and get attributes from loaded arrays.
       // Generate Rpgle prototype source code in outfile.
       //---------------------------------------------------------
       begsr srRPG;
 
       // load global clipboard with field attributes from JCRGETFLDR
       callp p_JCRGETFLDR(
             p_SrcFil + p_SrcLib:
             p_SrcMbr:
             DiagSeverity:
             PepCnt);
 
 1b    if DiagSeverity > '20';
          *inlr = *on;
          f_SndEscapeMsg('*ERROR*  Diagnostic severity ' +
          DiagSeverity + '. Please check listing for errors.');
 1e    endif;
 
       exsr srWriteDclPR;
 
 1b    if PepCnt > 0;
          DoParmCnt = 0;
          //---------------
          open JCRGETFLDF;
          ProcedureEntryPoint = *blanks;
 2b       dou InputDS.SourceListing = 'S o u r c e   L i s t i n g';
             read JCRGETFLDF InputDS;
 2e       enddo;
 
          read JCRGETFLDF InputDS;
 2b       dow not %eof;
 
             // do not process compile time arrays
 3b          if f_IsCompileTimeArray(InputDS.CompileArray)
                or InputDS.EndOfSource = 'E N D   O F   S O U R C E';
 2v             leave;
 3e          endif;
 
             InputDS = %xlate(lo: up: InputDS);
             string = %trimr(InputDS.Src94);
 
 3b          if not f_IsIgnoreLine(string);
 
                // execute function that looks for PI or *entry;
 4b             if ProcedureEntryPoint = *blanks;
                   ProcedureEntryPoint =
                   f_GetProcedureEntryPoint(InputDS.SpecType: string);
 
 5b                if ProcedureEntryPoint = 'NO-PEP';
 2v                   leave;
 5e                endif;
 4x             else;
 
                   //-------------------------------------------------------------
                   // I let the rpggetfldr program count the number of parms
                   // then read until I load that many field names.
                   //-------------------------------------------------------------
                   aa = f_GetParmFieldsArryIndex(InputDS.SpecType: string);
 
 5b                if aa > 0;
                      FieldsAttrDS = FieldsArry(aa).Attr;
                      exsr srWriteDclParm;
                      DoParmCnt += 1;
 6b                   If DoParmCnt = PepCnt;
 2v                      leave;
 6e                   endif;
 5e                endif;
 
 4e             endif;
 3e          endif;
             read JCRGETFLDF InputDS;
 2e       enddo;
 
          close JCRGETFLDF;
          exsr srWriteEndPR;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srWriteDclParm;
       OutDS.SrcCod = '  *n ' +
       f_GetDataTypeKeyWords(
       FieldsAttrDS.DataType:
       FieldsAttrDS.Length:
       FieldsAttrDS.DecimalPos);
 
      //-------------------------------------
      // if dim found, get rid of ; add dim statement;
 1b    if %subst(FieldsAttrDS.Text:1:4) = 'DIM(';
          bb = %len(%trimr(OutDS.SrcCod));
 2b       if bb > 1;
             %subst(OutDS.SrcCod:bb) = *blanks;
             OutDS.SrcCod = %trimr(OutDS.SrcCod) + ' ' +
             %xlate(up:lo: %trimr(FieldsAttrDS.Text)) + ';';
 2e       endif;
 1e    endif;
      //-------------------------------------
 
       OutDS.SrcCod  = %trimr( OutDS.SrcCod ) +
       '  // ' + %xlate(up: lo: FieldsArry(aa).Name);
 
       OutDS.SrcSeq += 10;
       write PROTOSRC OutDS;
       endsr;
 
       //---------------------------------------------------------
       // Generate callp prototype from CL.
       //---------------------------------------------------------
       begsr srCL;
 
       // return CL entry parms and field attributes
       callp p_JCRGETCLPR(
             p_SrcFil + p_SrcLib:
             p_SrcMbr:
             DiagSeverity);
 
 1b    if DiagSeverity > '20';
          *inlr = *on;
          f_SndEscapeMsg('*ERROR*  Diagnostic severity ' +
          DiagSeverity + '. Please check listing for errors.');
 1e    endif;
 
       PepCnt = FieldsArryCnt;
       exsr srWriteDclPR;
 1b    if PepCnt >  0;
 
          //---------------------------------------------------------
          // Unload imported array mapping differences
          //  between CL definitions and RPG data types
          //  before executing subroutine to write lines.
          //---------------------------------------------------------
 2b       for aa = 1 to FieldsArryCnt;
             FieldsAttrDS = FieldsArry(aa).Attr;
 
 3b          if FieldsAttrDS.DataType = 'C';
                FieldsAttrDS.DataType = 'A';
 3x          elseif FieldsAttrDS.DataType = 'D';
                FieldsAttrDS.DataType = 'P';
 3x          elseif FieldsAttrDS.DataType = 'L';
                FieldsAttrDS.DataType = 'N';
 3e          endif;
 
             exsr srWriteDclParm;
 2e       endfor;
 
          exsr srWriteEndPR;
 1e    endif;
       endsr;
