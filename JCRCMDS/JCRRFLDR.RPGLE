       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRRFLDR - Fields in RPG source
       //  call program to load field names and attributes into imported array
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCRRFLDD workstn sfile(sbfdta1: rrn) infds(infds) indds(ind)
       usropn;
       dcl-f JCRRFLDP printer oflind(IsOverFlow) usropn;
       dcl-f JCRRFLDF usage(*output) extfile(extOfile) extmbr(ExtOmbr)
       usropn;
 
       /define Constants
       /define Infds
       /define Ind
       /define Sds
       /define FieldsArry
       /define FieldsAttrDS
       /define FunctionKeys
       /define f_Qusrmbrd
       /define f_BuildString
       /define f_DisplayLastSplf
       /define f_qmhrcvpm
       /define f_GetQual
       /define f_GetDataTypeKeyWords
       /define f_GetDayName
       /define f_RmvSflMsg
       /define f_SndCompMsg
       /define f_SndSflMsg
       /define f_OvrPrtf
       /define f_Dltovr
       /define p_JCRGETFLDR
       // *ENTRY
       /define p_JCRRFLDR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s vsetll char(15);
       dcl-s NumberOfRecs uns(5);
       dcl-s PepCnt packed(3);
       dcl-s extOmbr char(10);
       dcl-s unsignedlength uns(10);
 
       //---------------------------------------------------------
       QusrmbrdDS = f_Qusrmbrd(p_SrcFilQual: p_SrcMbr: 'MBRD0100');
       %subst(p_SrcFilQual: 11: 10) = QusrmbrdDS.Lib;
 
       scObjHead =
       f_BuildString('&  &  &  &':
       p_SrcMbr: QusrmbrdDS.File: QusrmbrdDS.Lib: QusrmbrdDS.Text);
 
       //---------------------------------------------------------
       // depending on output selection
       //---------------------------------------------------------
 1b    if p_Output = '*';
          open JCRRFLDD;
 
 1x    elseif p_Output = '*PRINT';
          f_OvrPrtf('JCRRFLDP': '*JOB': p_SrcMbr);
          open JCRRFLDP;
          write PrtHead;
          IsOverFlow = *off;
 
 1x    elseif p_Output = '*OUTFILE';
          extOmbr = %subst(p_OutMbrOpt: 3: 10);
          extOfile = f_GetQual(p_OutFileQual);
          open JCRRFLDF;
          jPgm = p_SrcMbr;
          jSrcFil = QusrmbrdDS.File;
          jSrcLib = QusrmbrdDS.Lib;
 1e    endif;
       //---------------------------------------------------------
 
       // Load JCRCMDSSRV clipboard array with field names and attributes
       callp p_JCRGETFLDR(
             p_SrcFilQual:
             p_SrcMbr:
             DiagSeverity:
             PepCnt);
 
       //---------------------------------------------------------
       f_RmvSflMsg(ProgId);
       scDow = f_GetDayName();
 
 1b    if p_Output = '*';
          // if compile error, show severity as not all fields may have been defined
 2b       if DiagSeverity > '20';
             f_SndSflMsg(ProgId: 'Diagnostic severity ' + DiagSeverity +
             '. Not all fields may be defined. See listing.');
 2e       endif;
 1e    endif;
 
       jDiagSev = DiagSeverity; // show in outfile
 
       //---------------------------------------------------------
       // Pull all entries from imported array to screen fields
       //---------------------------------------------------------
 1b    for NumberOfRecs = 1 to FieldsArryCnt;
          FieldsAttrDS = FieldsArry(NumberOfRecs).Attr;
 2b       if not(FieldsAttrDS.Text = '*NOT REFERENCED');
             jFldNam = FieldsArry(NumberOfRecs).Name;
             jFldTxt = FieldsAttrDS.Text;
             jFldSrc = FieldsAttrDS.FromFile;
 
 3b          if jFldTxt = 'CONST';
                jDtaTyp = 'const';
                jFldTxt = *blanks;
 3x          else;
                unsignedlength = %int(FieldsAttrDS.Length);
                jDtaTyp = %scanrpl(';':' ':
                f_GetDataTypeKeyWords(
                FieldsAttrDS.DataType:
                unsignedlength:
                FieldsAttrDS.DecimalPos));
 3e          endif;
 
             //----------------------------
 3b          if p_Output = '*';
                rrn += 1;
                write sbfdta1;
 
 3x          elseif p_Output = '*PRINT';
                write PrtDetail;
 4b             if IsOverFlow;
                   write PrtHead;
                   IsOverFlow = *off;
 4e             endif;
 
 3x          elseif p_Output = '*OUTFILE';
                write JCRRFLDFR;
 3e          endif;
             //----------------------------
 
 2e       endif;
 1e    endfor;
 
       //----------------------------
       // send printed completion message
 1b    if p_Output = '*PRINT';
          close JCRRFLDP;
          f_Dltovr('JCRRFLDP');
          f_DisplayLastSplf(ProgId: '*PRINT');
          *inlr = *on;
          return;
 
 1x    elseif p_Output = '*OUTFILE';
          close JCRRFLDF;
          f_SndCompMsg('File ' +%trimr(extOfile) + ' member ' +
          %trimr(ExtOmbr) + ' generated by JCRRFLD.');
          *inlr = *on;
          return;
 1e    endif;
 
       //---------------------------------------------------------
       // display subfile to user
       //---------------------------------------------------------
       NumberOfRecs = rrn;
       SflRcdNbr = 1;
       Ind.sfldsp = (rrn > 0);
 1b    if (not Ind.sfldsp);
          f_SndSflMsg(ProgId: 'No Fields defined in program');
 1e    endif;
 
       Ind.sfldspctl = *on;
 1b    dou 1 = 2;
          write msgctl;
          write sfooter1;
          exfmt sbfctl1;
 
 2b       if (not Ind.sfldsp)
             or InfdsFkey = f03 or InfdsFkey = f12;
             f_SndCompMsg(f_BuildString('JCRRFLD for & in & - completed.':
             p_SrcMbr: f_GetQual(p_SrcFilQual)));
             *inlr = *on;
             return;
 2e       endif;
 
          f_RmvSflMsg(ProgId);
 
          // print subfile
 2b       if InfdsFkey = f06;
             f_OvrPrtf('JCRRFLDP': '*JOB': p_SrcMbr);
             open JCRRFLDP;
             write PrtHead;
             IsOverFlow = *off;
 
 3b          for rrn = 1 to NumberOfRecs;
                chain rrn sbfdta1;
                write PrtDetail;
 4b             if IsOverFlow;
                   write PrtHead;
                   IsOverFlow = *off;
 4e             endif;
 3e          endfor;
 
             close JCRRFLDP;
             f_Dltovr('JCRRFLDP');
 
             // send printed completion message to message subfile
             f_DisplayLastSplf(ProgId: '*PRINT');
             f_SndSflMsg(ProgId: f_qmhrcvpm(3));
 2x       else;
             //---------------------------------------------------------
             // position subfile
             //---------------------------------------------------------
             aa = %checkr(' ': scPosition);
 3b          if aa = 0;
                SflRcdNbr = 1;
 1i             iter;
 3e          endif;
 
 3b          for rrn = 1 to NumberOfRecs;
                chain rrn sbfdta1;
                vsetll = %subst(jFldNam: 1: aa);
 4b             if scPosition <= vsetll
                   or NumberOfRecs = rrn;
                   SflRcdNbr = rrn;
 3v                leave;
 4e             endif;
 3e          endfor;
 2e       endif;
 1e    enddo;
