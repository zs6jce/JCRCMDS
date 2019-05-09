       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCR4PROTOR - Convert *entry/call parms to FIXED FORMAT prototypes
       // Get field attributes from JCRGETFLDR
       // OriginRPG input file is read to control writing of non-call/non-parm statements to outfile
       // Seek1RPG input file find *ENTRY and call Opcodes.
       // Seek2RPG input file find defined parm Lists.
       // RPGSRC will be generated code.
       // This program converts CALLs having variable names as the
       // program name. // Prototype name is 'v_' + field name.
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define FieldsArry
       /define Constants
       /define FieldsAttrDS
       /define SrcDS
       /define f_GetQual
       /define f_Qusrobjd
       /define f_SndCompMsg
       /define f_SndEscapeMsg
       /define p_JCRGETFLDR
       // *ENTRY
       /define p_JCRPROTOR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f ORIGINRPG disk(112) extfile(extifile) extmbr(p_inmbr) usropn;
       dcl-f SEEK1RPG disk(112) extfile(extifile) extmbr(p_inmbr) usropn;
       dcl-f SEEK2RPG disk(112) extfile(extifile) extmbr(p_inmbr) usropn;
       dcl-f RPGSRC disk(112) usage(*output) extfile(extofile) extmbr(p_outmbr)
       usropn;
 
       //---------------------------------------------------------
       dcl-s SrcOut like(src112);
       dcl-s AlreadyProto char(15) dim(1000);
       dcl-s PiSrcArry char(100) dim(512);
       dcl-s CalledPgmName char(10);
       dcl-s CallExtender char(10);
       dcl-s CallpArry char(100) dim(512);
       dcl-s CallpPostArry char(100) dim(512);
       dcl-s CallpPreArry char(100) dim(512);
       dcl-s PListName char(14);
       dcl-s SrcCspec char(100);
       dcl-s hyphens char(50) inz(*all'-');
       dcl-s SrcSeq zoned(6: 2);
       dcl-s Crrn1 uns(10);
       dcl-s Crrn2 uns(10);
       dcl-s pi uns(5);
       dcl-s rr uns(5);
       dcl-s v1 uns(5);
       dcl-s v2 uns(5);
       dcl-s v3 uns(5);
       dcl-s IsArray ind;
       dcl-s IsCompileTime ind;
       dcl-s IsDefinePList ind;
       dcl-s IsComment ind;
       dcl-s IsFirstTime ind;
       dcl-s pepcnt packed(3);
 
       //--*INPUT SPECS-------------------------------------------
     IOriginRPG ns
     I                             a   13   15  CompileArry
     I                             a   13  112  Src112
     I                             a   19   19  Asterisk
     ISeek1RPG  ns
     I                             a   13   15  CompileArry1
     I                             a   13  112  Seek1Src
     ISeek2RPG  ns
     I                             a   13   15  CompileArry2
     I                             a   13  112  Seek2Src
     I                             a   24   37  Seek2F1
     I                             a   48   61  Seek2F2
     I                             a   62   75  Seek2RF
       //---------------------------------------------------------
 
       extIfile = f_GetQual(p_InFileQual);
       extOfile = f_GetQual(p_OutFileQual);
 
       // Load JCRCMDSSRV clipboard array with field names and attributes
       callp p_JCRGETFLDR(
             p_InFileQual:
             p_InMbr:
             DiagSeverity:
             PepCnt);
 
 1b    if DiagSeverity > '20';
          f_SndEscapeMsg('*ERROR*  Diagnostic severity ' +
          DiagSeverity + '. Please check listing for errors.');
 1e    endif;
       open OriginRPG;
       open Seek1RPG;
       open Seek2RPG;
       open RPGSRC;
 
       read OriginRPG;
 1b    dow not %eof;
          Crrn1 += 1;
 
 2b       if CompileArry = '** '
             or CompileArry = '**C'
             or CompileArry = '**c';
             IsArray = *on;
 2e       endif;
          SrcDS.Src63 = %xlate(lo: up: Src112);
 
 2b       if IsArray
             or Asterisk = '/'
             or Asterisk = '+'
             or SrcDS.SpecType = 'D'
             or SrcDS.SpecType = 'F'
             or SrcDS.SpecType = 'P'
             or SrcDS.SpecType = 'O'
             or (SrcDS.SpecType = 'C'
             and Asterisk <> '*'
             and SrcDS.Opcode <> 'PARM  ');
             IsComment = *off;
 2e       endif;
 
 2b       if IsArray = *off
             and (not(Asterisk = '/'
             or Asterisk = '+'
             or Asterisk = '*'));
 
 3b          if SrcDS.SpecType = 'C'
                and (SrcDS.Factor1 = '*ENTRY  '
                or SrcDS.Opcode = 'PLIST'
                or (%subst(SrcDS.Opcode: 1: 4) = 'CALL'
                and %subst(SrcDS.Opcode: 1: 5) <> 'CALLP'
                and %subst(SrcDS.Opcode: 1: 5) <> 'CALLB'));
                IsComment = *on;
 3e          endif;
 
 3b          if (SrcDS.SpecType = 'C')
                or (SrcDS.SpecType = 'I');
 4b             if not IsFirstTime;
                   exsr srGenAllProtoTypes;
                   IsFirstTime = *on;
                   SrcDS.Src63 = %xlate(lo: up: Src112);
 4e             endif;
 3e          endif;
 
 3b          if SrcDS.SpecType = 'C'
                and %subst(SrcDS.Opcode: 1: 4) = 'CALL'
                and %subst(SrcDS.Opcode: 1: 5) <> 'CALLP'
                and %subst(SrcDS.Opcode: 1: 5) <> 'CALLB';
                exsr srGenCallpSrc;
 3e          endif;
 2e       endif;
 
          SrcSeq += .01;
          SrcOut = Src112;
 2b       if IsComment;
             %subst(SrcOut: 6: 2) = ' *';
 2e       endif;
          except OutSrc;
 
          read OriginRPG;
 1e    enddo;
       close OriginRPG;
       close Seek1RPG;
       close RPGSRC;
       f_SndCompMsg('Prototype mbr ' + %trimr(p_OutMbr) + ' generated.');
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       //  I need three steps here.
       //  Before CALLP, If parm has factor2 value,load values
       //  generate CALLP and parm value statements
       //  After CALLP, If parms had factor1, load parm values to those
       //  Spin through CALLP and load arrays, after
       //  CALLP is processed, write out 3 arrays.
       //---------------------------------------------------------
       begsr srGenCallpSrc;
       CallpPreArry(*) = *blanks;
       CallpArry(*) = *blanks;
       CallpPostArry(*) = *blanks;
       v1 = 0;
       v2 = 0;
       v3 = 0;
 
       // extract program name
       CalledPgmName = *blanks;
       aa = %scan(qs: SrcDS.Factor2: 2);
 1b    if aa = 0;  //variable program name
          CalledPgmName = 'v_' + SrcDS.Factor2;
 1x    else;
          CalledPgmName = %xlate(up: lo: %subst(SrcDS.Factor2: 2: aa - 2));
 1e    endif;
 
       // extract CALL SrcDS.Opcode extender
       CallExtender = *blanks;
       aa = %scan('(': SrcDS.Opcode: 5);
 1b    if aa > 0;
          CallExtender = %subst(SrcDS.Opcode: aa);
 1e    endif;
 
       v1 = 1;
       CallpPreArry(v1) = '      *';
       v2 = 1;
       CallpArry(v2) = '     C';
       %subst(CallpArry(v2): 26) = 'callp' + %xlate(up: lo: CallExtender);
       %subst(CallpArry(v2): 36) =
       'p_' + %trimr(%xlate(lo: up: CalledPgmName)) + '(';
 
       IsDefinePList = (SrcDS.ResultField > *blanks);
 1b    if IsDefinePList;
          PListName = SrcDS.ResultField;
 1e    endif;
 
       //---------------------------------------------------------
       // if result field plist is used,
       // then read through and find where plist is defined
       // before starting prototype generation.
       //---------------------------------------------------------
 1b    if IsDefinePList;
          setll 1 Seek2RPG;
 1x    else;
          chain Crrn1 Seek2RPG;
 1e    endif;
 
       read Seek2RPG;
 1b    dow not %eof;
          SrcDS.Src63 = %xlate(lo: up: Seek2Src);
 2b       if not(SrcDS.Asterisk = '/'
             or SrcDS.Asterisk = '+'
             or SrcDS.Asterisk = '*');
 
 3b          if CompileArry2 = '** '
                or CompileArry2 = '**C'
                or CompileArry2 = '**c';
                IsCompileTime = *on;
 1v             leave;
 3e          endif;
 
 3b          if not IsDefinePList;
 4b             If (SrcDS.SpecType = 'C'
                   and SrcDS.Opcode <> 'PARM  ')
                   or SrcDS.SpecType = 'P'
                   or SrcDS.SpecType = 'O';
 1v                leave;
 4e             endif;
 
 4b             if SrcDS.Opcode = 'PARM';
 5b                if Seek2F2 > *blanks;
                      v1 += 1;
                      CallpPreArry(v1) = '     C';
                      %subst(CallpPreArry(v1): 26) = 'eval';
                      %subst(CallpPreArry(v1): 36) =
                      %trimr(seek2RF) + '=' + seek2F2;
 5e                endif;
 
                   v2 += 1;
                   CallpArry(v2) = '     C';
                   %subst(CallpArry(v2): 36) = %trimr(seek2RF) + ':';
 
 5b                if Seek2F1 > *blanks;
                      v3 += 1;
                      CallpPostArry(v3) = '     C';
                      %subst(CallpPostArry(v3): 26) = 'eval';
                      %subst(CallpPostArry(v3): 36) =
                      %trimr(seek2F1) + '=' + seek2RF;
 5e                endif;
 4e             endif;
 3x          else;
 4b             if SrcDS.Factor1 = PListName
                   and SrcDS.Opcode = 'PLIST';
                   IsDefinePList = *off;
 4e             endif;
 3e          endif;
 2e       endif;
          read Seek2RPG;
 1e    enddo;
       v3 += 1;
       CallpPostArry(v3) = '      *';
 
       //---------------------------------------------------------
       //  go back and put closing ) on last parm
       //  If no parms where found on this call, put closing ) on callp statement
       //---------------------------------------------------------
       aa = %scan(':': CallpArry(v2));
 1b    if aa > 1;
          %subst(CallpArry(v2): aa: 1) = ')';
 1x    else;
          CallpArry(v2) = %trimr(CallpArry(v2)) + ' )';
 1e    endif;
 
       //---------------------------------------------------------
       // now unload arrays into source
       //---------------------------------------------------------
       IsDefinePList = *off;
 1b    for aa = 1 to v1;
          SrcCspec = CallpPreArry(aa);
          SrcSeq += .01;
          except CSPEC;
 1e    endfor;
 
 1b    for aa = 1 to v2;
          SrcCspec = CallpArry(aa);
          SrcSeq += .01;
          except CSPEC;
 1e    endfor;
 1b    for aa = 1 to v3;
          SrcCspec = CallpPostArry(aa);
          SrcSeq += .01;
          except CSPEC;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srGenAllProtoTypes;
       crrn2 = 0;
       setll 1 Seek1RPG;
       read Seek1RPG;
 1b    dow not %eof;
          crrn2 += 1;
 2b       if CompileArry1 = '** '
             or CompileArry1 = '**C'
             or CompileArry = '**c';
 LV          leavesr;
 2e       endif;
          SrcDS.Src63 = %xlate(lo: up: Seek1Src);
 
 2b       if not(SrcDS.Asterisk = '/'
             or SrcDS.Asterisk = '+'
             or SrcDS.Asterisk = '*');
 
             //---------------------------------------------------------
             // Generate Main PI procedure interface and PR
             // Prototype for *entry parms
             //---------------------------------------------------------
 3b          if SrcDS.SpecType = 'C';
 4b             if SrcDS.Factor1 = '*ENTRY  ';
                   pi = 0;
                   SrcCspec = '      //-*ENTRY-----------------------------';
                   SrcSeq += .01;
                   except CSPEC;
                   pi += 1;
                   PISrcArry(pi) =
                   '      // -----------------------------------';
                   SrcCspec = '     D                 PR';
                   %subst(SrcCspec: 8: 15) = 'p_' + %xlate(up: lo: p_InMbr);
                   %subst(SrcCspec: 44) = 'extpgm(' + qs +
                   %trimr(p_InMbr) + qs + ')';
                   %subst(SrcCspec: 81) = '           ';
                   SrcSeq += .01;
                   except CSPEC;
                   pi += 1;
                   PISrcArry(pi) = '     D                 PI';
                   %subst(PISrcArry(pi): 8: 15) =
                   'p_' + %xlate(up: lo: p_InMbr);
 
                   exsr srWriteProtoypeSpecs;
                   exsr srWriteProcedureInterfaceSpecs;
 
                   //---------------------------------------------------------
 4x             elseif SrcDS.Opcode = 'CALL    '
                   or %subst(SrcDS.Opcode: 1: 5) = 'CALL(';
 
                   //if already prototyped, do not repeat
                   aa = 0;
 5b                if rr > 0;
                      aa = %lookup(SrcDS.Factor2: AlreadyProto: 1: rr);
 6b                   if aa = 0;
                         rr += 1;
                         AlreadyProto(rr) = SrcDS.Factor2;
 6e                   endif;
 5x                else;
                      rr = 1;
                      AlreadyProto(1) = SrcDS.Factor2;
 5e                endif;
 
 5b                if aa = 0;
                      IsDefinePList = (SrcDS.ResultField > *blanks);
 6b                   If IsDefinePList;
                         PListName = SrcDS.ResultField;
 6e                   endif;
                      exsr srWriteProgramPrototypeSpecs;
                      IsDefinePList = *off;
 5e                endif;
 4e             endif;
 3e          endif;
 2e       endif;
          read Seek1RPG;
 1e    enddo;
       endsr;
 
       //---------------------------------------------------------
       // Generate prototype specs for called programs
       //---------------------------------------------------------
       begsr srWriteProgramPrototypeSpecs;
       pi = 0;
 
       //little work here to extract program name
       CalledPgmName = *blanks;
       aa = %scan(qs: SrcDS.Factor2: 2);
 1b    if aa = 0;  //variable program name
          CalledPgmName = 'v_' + SrcDS.Factor2;
          SrcCspec =
          '      //---variable name--------------------------------------';
 1x    else;
          CalledPgmName = %xlate(up: lo: %subst(SrcDS.Factor2: 2: aa - 2));
          QusrObjDS = f_QUSROBJD(%xlate(lo: up:CalledPgmName) +
                      '*LIBL':'*PGM');
 2b       if ApiErrDS.BytesReturned = 0;
             QusrObjDS.Text = %trimr(QusrObjDS.Text) + hyphens;
 2x       else;
             QusrObjDS.Text = *all'-';
 2e       endif;
          SrcCspec = '      //---' + QusrObjDS.Text + '-';
 1e    endif;
 
       SrcSeq += .01;
       except CSPEC;
 
       SrcCspec = '     D                 PR';
       %subst(SrcCspec: 8: 15) = 'p_' + %xlate(up: lo: CalledPgmName);
       %subst(SrcCspec: 44) = 'extpgm(' + %trimr(SrcDS.Factor2) + ')';
       %subst(SrcCspec: 81) = '           ';
       SrcSeq += .01;
       except CSPEC;
       exsr srWriteProtoypeSpecs;
       endsr;
 
       //---------------------------------------------------------
       // if result field plist is used,
       // then read through finding plist definition before starting prototype generation.
       //---------------------------------------------------------
       begsr srWriteProtoypeSpecs;
 1b    If IsDefinePList;
          setll 1 Seek2RPG;
 1x    else;
          chain Crrn2 Seek2RPG;
 1e    endif;
 
       read Seek2RPG;
 1b    dow not %eof;
          SrcDS.Src63 = %xlate(lo: up: Seek2Src);
 2b       if not(SrcDS.Asterisk = '/'
             or SrcDS.Asterisk = '+'
             or SrcDS.Asterisk = '*');
 
 3b          if CompileArry2 = '** '
                or CompileArry2 = '**C'
                or CompileArry2 = '**c';
                IsCompileTime = *on;
 1v             leave;
 3e          endif;
 
 3b          If not IsDefinePList;
 4b             If (SrcDS.SpecType = 'C'
                   and SrcDS.Opcode <> 'PARM  ')
                   or SrcDS.SpecType = 'P'
                   or SrcDS.SpecType = 'O';
 1v                leave;
 4e             endif;
 
 4b             if SrcDS.Opcode = 'PARM';
                   // if result is indexed,
                   // remove index before lookup
                   aa = %scan('(': SrcDS.ResultField);
 5b                if aa > 0;
                      SrcDS.ResultField =
                      %subst(SrcDS.ResultField: 1: aa - 1);
 5e                endif;
 
                   // get field attributes
                   aa = %lookup(SrcDS.ResultField: FieldsArry(*).Name: 1:
                   FieldsArryCnt);
 5b                if aa = 0;
                      f_SndEscapeMsg('*ERROR*  Field definition for ' +
                      %trimr(SrcDS.ResultField) + ' not found.');
 5e                endif;
 
                   FieldsAttrDS = FieldsArry(aa).Attr;
                   SrcCspec = '     D';
                   %subst(SrcCspec: 30) = %editc(FieldsAttrDS.Length:'4');
                   %subst(SrcCspec: 40) = %xlate(up: lo: FieldsAttrDS.DataType);
                   %subst(SrcCspec: 41) = FieldsAttrDS.DecimalPos;
                   %subst(SrcCspec: 81) = Seek2RF;
                   SrcSeq += .01;
                   except CSPEC;
                   %subst(SrcCspec: 8: 14) = Seek2RF;
                   %subst(SrcCspec: 81) = *blanks;
                   pi += 1;
                   PISrcArry(pi) = SrcCspec;
 4e             endif;
 3x          else;
 4b             if SrcDS.Factor1 = PListName
                   and SrcDS.Opcode = 'PLIST';
                   IsDefinePList = *off;
 4e             endif;
 3e          endif;
 2e       endif;
          read Seek2RPG;
 1e    enddo;
       endsr;
 
       //---------------------------------------------------------
       begsr srWriteProcedureInterfaceSpecs;
 1b    for aa = 1 to pi;
          SrcCspec = PISrcArry(aa);
          SrcSeq += .01;
          except CSPEC;
 1e    endfor;
       SrcCspec = '      // -----------------------------------';
       SrcSeq += .01;
       except CSPEC;
       endsr;
 
     ORPGSRC    e            OutSrc
     O                       SrcSeq               6
     O                                           12 '000000'
     O                       SrcOut             112
     ORPGSRC    e            CSPEC
     O                       SrcSeq               6
     O                                           12 '000000'
     O                       SrcCspec           112
