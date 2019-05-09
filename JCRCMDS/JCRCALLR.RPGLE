       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRCALLR - Generate CMD to provide parms to called program
       //  Generate/execute command that will prompt for parms in RPG or CL program
       //   Get program attributes from prompt override program.
       //    A command is created with called program as Command Processing Pgm
       //     Helpful Hint:  Execute jcrcallx after this command has run.
       //  V7 drive off first dcl-pi to get procedure interface command definition
       //---------------------------------------------------------
       /define ControlStatements
       /define FieldsArry
       /define FieldsAttrDS
       /define ApiErrDS
       /define Constants
       /define f_GetQual
       /define f_BuildString
       /define f_SndCompMsg
       /define f_SndEscapeMsg
       /define f_RunCmd
       /define f_IsIgnoreLine
       /define f_IsCompileTimeArray
       /define p_JCRGETFLDR
       /define p_JCRGETCLPR
       /define f_GetProcedureEntryPoint
       /define f_GetParmFieldsArryIndex
       /define SourceOutDS
       // *ENTRY
       /define p_JCRCALLR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRGETFLDF disk(132) extfile('QTEMP/JCRGETFLDF') usropn;
       dcl-ds SplfDs len(132) qualified inz;
        CompileArray char(3) pos(3);
        SpecType char(1) pos(8);
        Src94 char(94) pos(9);
        SourceListing char(27) pos(27);
        EndOfSource char(25) pos(20);
       end-ds;
 
       dcl-f CMDSRC disk(112) usage(*output) extfile('QTEMP/CMDSRC')
       extmbr('JCRCALLX') usropn;
 
       //---------------------------------------------------------
       dcl-s string varchar(94);
       dcl-s p_DiagSeverity char(2) inz('00');
       dcl-s p_Lib char(10);
       dcl-s p_CPPname char(10);
       dcl-s WorkField char(11);
       dcl-s linecount packed(6:2);
       dcl-s WorkType char(5);
       dcl-s ProcedureEntryPoint char(6);
       dcl-s IsAllDone ind;
       dcl-s PepCnt packed(3);
       dcl-s DoParmCnt packed(3);
       dcl-s ParmName char(10);
 
       //---------------------------------------------------------
       exsr srWriteCmdPromptLine;
 
 1b    if p_Pgmatr = 'RPGLE'
          or p_Pgmatr = 'SQLRPGLE';
          exsr srRPG;
 
 1x    elseif p_Pgmatr = 'CLLE'
          or p_Pgmatr = 'CLP';
          exsr srCL;
 1e    endif;
 
       exsr srExecutePrompt;
 
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       begsr srRPG;
 
       // load global clipboard with field attributes from JCRGETFLDR
       callp p_JCRGETFLDR(
             p_SrcFil + p_SrcLib:
             p_SrcMbr:
             DiagSeverity:
             PepCnt);
 
 1b    if DiagSeverity > '19';
          *inlr = *on;
          f_SndEscapeMsg('*ERROR*  Diagnostic severity ' +
          DiagSeverity + '. Please check listing for errors.');
 1e    endif;
 
 1b    If PepCnt > 0;
          DoParmCnt = 0;
          //---------------
          open JCRGETFLDF;
          ProcedureEntryPoint = *blanks;
 2b       dou SplfDs.SourceListing = 'S o u r c e   L i s t i n g';
             read JCRGETFLDF SplfDs;
 2e       enddo;
 
          read JCRGETFLDF SplfDs;
 2b       dow not %eof;
 
             // no process compile time arrays
 3b          if f_IsCompileTimeArray(SplfDs.CompileArray)
                or SplfDS.EndOfSource = 'E N D   O F   S O U R C E';
 2v             leave;
 3e          endif;
 
             SplfDs = %xlate(lo: up: SplfDs);
             string = %trimr(SplfDs.Src94);
 
 3b          if not f_IsIgnoreLine(string);
 
                // execute function that looks for PI or *entry;
 4b             if ProcedureEntryPoint = *blanks;
                   ProcedureEntryPoint =
                   f_GetProcedureEntryPoint(SplfDs.SpecType: string);
 
 5b                if ProcedureEntryPoint = 'NO-PEP';
 2v                   leave;
 5e                endif;
 4x             else;
 
                   //-------------------------------------------------------------
                   // The ability to mix new free format and old fixed columns
                   //  makes it difficult to tell where the entry parms end.
                   // I let the rpggetfldr program count the number of parms
                   //  then read until I load that many field names.
                   //-------------------------------------------------------------
                   bb = f_GetParmFieldsArryIndex(SplfDs.SpecType: string);
 
 5b                if bb > 0;
                      exsr srWriteParmKwdSource;
                      DoParmCnt += 1;
 6b                   If DoParmCnt = PepCnt;
 2v                      leave;
 6e                   endif;
 5e                endif;
 
 4e             endif;
 3e          endif;
             read JCRGETFLDF SplfDs;
 2e       enddo;
 
          close JCRGETFLDF;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // write out command source
       begsr srWriteParmKwdSource;
 
       ParmName = FieldsArry(bb).Name;
       FieldsAttrDS = FieldsArry(bb).Attr;
 
       OutDS.SrcCod = 'PARM KWD(' +
       %subst(ParmName: 1: 10) + ') TYPE(';
 1b    if FieldsAttrDS.DecimalPos > '  ';
          OutDS.SrcCod = %trimr(OutDS.SrcCod) + '*DEC) LEN(';
 1x    else;
          OutDS.SrcCod = %trimr(OutDS.SrcCod) + '*CHAR) LEN(';
 1e    endif;
 
       OutDS.SrcCod = %trimr(OutDS.SrcCod) +
       %char(FieldsAttrDS.Length) + ' ' + FieldsAttrDS.DecimalPos + ') + ';
       linecount += 10;
       OutDS.SrcSeq = linecount;
       write CMDSRC OutDS;
 
       // Generate PROMPT text
       OutDS.SrcCod = 'PROMPT(' + qs + ParmName + '  ' +
       %char(FieldsAttrDS.Length);
 
 1b    if FieldsAttrDS.DecimalPos > ' ';
          OutDS.SrcCod = %trimr(OutDS.SrcCod) + ',' +FieldsAttrDS.DecimalPos;
 1e    endif;
       OutDS.SrcCod = %trimr(OutDS.SrcCod) + qs + ')';
       linecount += 10;
       OutDS.SrcSeq = linecount;
       write CMDSRC OutDS;
       endsr;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       // For CL program types, call program to return parm fields
       begsr srCL;
       callp p_JCRGETCLPR(
             p_SrcFil + p_SrcLib:
             p_SrcMbr:
             DiagSeverity);
 
 1b    if p_DiagSeverity > '20';
          *inlr = *on;
          f_SndEscapeMsg('*ERROR*  Diagnostic severity ' +
          p_DiagSeverity + '. Please check listing for errors.');
 1e    endif;
 
 1b    for aa = 1 to FieldsArryCnt;
          linecount += 10;
          OutDS.SrcSeq = linecount;
          FieldsAttrDS = FieldsArry(aa).Attr;
 2b       if FieldsAttrDS.DataType = 'D';
             WorkType = '*DEC';
 2x       elseif FieldsAttrDS.DataType = 'C';
             WorkType = '*CHAR';
 2x       elseif FieldsAttrDS.DataType = 'L';
             WorkType = '*LGL';
 2x       elseif FieldsAttrDS.DataType = 'I';
             WorkType = '*INT4';
 2x       elseif FieldsAttrDS.DataType = 'U';
             WorkType = '*UINT4';
 2e       endif;
 
          WorkField = %subst(FieldsArry(aa).Name: 2: 10);
 
          OutDS.SrcCod =
          f_BuildString('PARM KWD(&) TYPE(&) LEN(& &) PROMPT(&Q&&Q)':
          WorkField: WorkType: %char(FieldsAttrDS.Length):
          FieldsAttrDS.DecimalPos: WorkField);
          write CMDSRC OutDS;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srWriteCmdPromptLine;
       p_CPPname = %subst(p_PgmQual: 1: 10);
       p_Lib = %subst(p_PgmQual: 11: 10);
 
       // create source file for temp command member
       f_RunCmd('DLTF FILE(QTEMP/CMDSRC)');
       f_RunCmd('CRTSRCPF FILE(QTEMP/CMDSRC) MBR(JCRCALLX) RCDLEN(112)');
       open CMDSRC;
 
       OutDS.SrcCod =
       f_BuildString('CMD PROMPT(&QEntry Parms - &&Q)':p_CPPname);
 
       linecount += 10;
       OutDS.SrcSeq = linecount;
       write CMDSRC OutDS;
       endsr;
 
       //---------------------------------------------------------
       // create command object and execute
       //---------------------------------------------------------
       begsr srExecutePrompt;
       close CMDSRC;
 
       f_RunCmd('DLTCMD CMD(QTEMP/JCRCALLX)');
 
       f_RunCmd('CRTCMD CMD(QTEMP/JCRCALLX) ' +
       'PGM(' + f_GetQual(p_CPPname + p_Lib) +
       ') SRCFILE(QTEMP/CMDSRC) SRCMBR(JCRCALLX)');
 
 1b    if ApiErrDS.BytesReturned > 0;
          f_SndEscapeMsg('CrtCmd Failed.  Check source JCRCALLX +
          in QTEMP/CMDSRC.');
 1e    endif;
 
       f_RunCmd('?QTEMP/JCRCALLX');
 
       f_SndCompMsg('JCRCALL parm processing for ' +
       f_GetQual(p_CPPname + p_Lib) + ' - completed');
       endsr;
