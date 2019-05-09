       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRLSRCR - List Pgm/Mod/Srvpgm Source information
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define FunctionKeys
       /define Qbnlpgmi
       /define Qbnrmodi
       /define Qclrpgmi
       /define Qbnlspgm
       /define Quslobj
       /define f_Qusrobjd
       /define f_GetDayName
       /define f_BuildString
       /define f_GetQual
       /define f_Quscrtus
       /define f_RtvMsgAPI
       /define f_SndCompMsg
       /define f_SndStatMsg
       /define f_GetApiISO
       /define f_OvrPrtf
       /define f_Dltovr
       /define f_DisplayLastSplf
       // *ENTRY
       /define p_JCRLSRCR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRLSRCP printer oflind(IsOverFlow) usropn;
       dcl-f JCRLSRCF usage(*output) extfile(extOfile) extmbr(ExtOmbr) usropn;
 
       dcl-s extOmbr char(10);
       dcl-s IsPrintEndOfReport ind;
       dcl-s aster char(10) inz(*all'*');
 
       //---------------------------------------------------------
       headpgm = %subst(p_PgmQual: 1: 10);
       headLib = %subst(p_PgmQual: 11: 10);
 
       f_SndStatMsg(f_BuildString('List source for & - in progress':
       f_GetQual(p_PgmQual)));
       scDow = f_GetDayName();
 
       //---------------------------------------------------------
       // depending on output selection
       //---------------------------------------------------------
 1b    if p_Output = '*OUTFILE';
          extOmbr = %subst(p_OutMbrOpt: 3: 10);
          extOfile = f_GetQual(p_OutFileQual);
          open JCRLSRCF;
 1x    else;
          f_OvrPrtf('JCRLSRCP': '*JOB': HeadPgm);
          open JCRLSRCP;
          write PrtHead;
          IsOverFlow = *off;
 1e    endif;
 
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
       ApiHeadPtr2 = f_Quscrtus(UserSpaceName2);
 
       // Load program object names into user space
       callp QUSLOBJ(
             UserSpaceName:
             'OBJL0100':
             p_PgmQual:
             '*ALL':
             ApiErrDS);
 
       // load print file field, print error message
 1b    if ApiErrDS.BytesReturned > 0;
          vMessage = ApiErrDS.ErrMsgId + ': ' +
          f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal);
 
 2b       if p_Output = '*OUTFILE';
             close JCRLSRCF;
             f_SndCompMsg(vMessage);
             *inlr = *on;
             return;
 2x       else;
             exsr srWriteAsterisk;
             exsr srSendCompletMsg;
 2e       endif;
 1e    endif;
 
       // if no matching objects found, print error message
 1b    if ApiHead.ListEntryCount = 0;
          vmessage = 'No matching program objects found.';
 2b       if p_Output = '*OUTFILE';
             f_SndCompMsg(vMessage);
             *inlr = *on;
             return;
 2x       else;
             exsr srWriteAsterisk;
             exsr srSendCompletMsg;
 2e       endif;
 1e    endif;
 
       //---------------------------------------------------------
       // spin through and retrieve all program object names
       //---------------------------------------------------------
       QuslobjPtr = ApiHeadPtr + ApiHead.OffSetToList;
 
 1b    for ForCount = 1 to ApiHead.ListEntryCount;
 2b       if QuslobjDS.ObjTyp = '*PGM'
             or QuslobjDS.ObjTyp = '*MODULE'
             or QuslobjDS.ObjTyp = '*SRVPGM';
             exsr srBuildPrint;
 2e       endif;
 
          QuslobjPtr += ApiHead.ListEntrySize;
 1e    endfor;
 
       //---------------------------------------------------------
       // if no matching objects found, print message and exit
 1b    if p_Output = '*PRINT' or p_Output = '*';
 2b       if not IsPrintEndOfReport;
             vmessage = 'No matching program objects found.';
             exsr srWriteAsterisk;
 2x       else;
             // end of report
             vmessage = ' ** End Of Report';
             write PrtMessage;
 2e       endif;
 1e    endif;
       exsr srSendCompletMsg;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srBuildPrint;
 
       IsPrintEndOfReport = *on;
       QusrObjDS =
       f_QUSROBJD(QuslobjDS.ObjNam + QuslobjDS.ObjLib:
       QuslobjDS.ObjTyp:
       'OBJD0400');
 
       lCreateDt = f_GetApiISO(QusrobjDS.CreateDateTime);
 1b    if QusrobjDS.NumDaysUsed > 9999;
          lDaysUsed = 9999;
 1x    else;
          lDaysUsed = QusrobjDS.NumDaysUsed;
 1e    endif;
 
 1b    if QusrobjDS.NumDaysUsed > 0;
          lLastUsed = f_GetApiISO(QusrobjDS.LastUsedDate + '      ');
 1x    else;
          lLastUsed = *blanks;
 1e    endif;
 
       //-----------------------------
 1b    if QuslobjDS.ObjTyp = '*SRVPGM';
          callp QBNLSPGM(
                UserSpaceName2:
                'SPGL0100':
                QuslobjDS.ObjNam + QuslobjDS.ObjLib:
                ApiErrDS);
 
 2b       if ApiErrDS.BytesReturned > 0;  //Source not available
             f_FmtPrint(aster: aster: aster);
             exsr srPrintLine;
 2x       else;
             SrvPgmPtr = ApiHeadPtr2 + ApiHead2.OffSetToList;
 
 3b          for ForCount2 = 1 to ApiHead2.ListEntryCount;
                f_FmtPrint(SrvPgmDs.SrcFil:
                SrvPgmDs.SrcLib: SrvPgmDs.SrcMbr);
                lSrcAttr = SrvPgmDs.SrcAttrb;
                exsr srPrintLine;
 
                SrvPgmPtr += ApiHead2.ListEntrySize;
 3e          endfor;
 2e       endif;
 
          //-----------------------------
 1x    elseif QuslobjDS.ObjTyp = '*MODULE';
          callp QBNRMODI(
                QbnrmodiDS:
                %len(QbnrmodiDS):
                'MODI0100':
                QuslobjDS.ObjNam + QuslobjDS.ObjLib:
                ApiErrDS);
 
          f_FmtPrint(QbnrmodiDS.SrcFil:
          QbnrmodiDS.SrcLib: QbnrmodiDS.SrcMbr);
          exsr srPrintLine;
 1x    else;
 
          //-----------------------------
          // check ILE / non-ILE
          callp QCLRPGMI(
                QclrpgmiDS:
                %len(QclrpgmiDS):
                'PGMI0100':
                QuslobjDS.ObjNam + QuslobjDS.ObjLib:
                ApiErrDS);
 
          // OPM------------------
 2b       if QclrpgmiDS.PgmType = ' ';
             f_FmtPrint(QclrpgmiDS.SrcFil:
             QclrpgmiDS.SrcLib: QclrpgmiDS.SrcMbr);
             lSrcAttr = QclrpgmiDS.SrcAttrb;
             exsr srPrintLine;
 
             // ILE---------------
 2x       elseif QclrpgmiDS.PgmType = 'B';
             callp QBNLPGMI(
                   UserSpaceName2:
                   'PGML0100':
                   QuslobjDS.ObjNam + QuslobjDS.ObjLib:
                   ApiErrDS);
 
 3b          if ApiErrDS.BytesReturned > 0;  //Source not available
                f_FmtPrint(aster: aster: aster);
                exsr srPrintLine;
 3x          else;
                QbnlpgmiPtr = ApiHeadPtr2 + ApiHead2.OffSetToList;
 4b             for ForCount2 = 1 to ApiHead2.ListEntryCount;
 
                   f_FmtPrint(QbnlpgmiDS.SrcFil:
                   QbnlpgmiDS.SrcLib: QbnlpgmiDS.SrcMbr);
                   lSrcAttr = QbnlpgmiDS.SrcAttrb;
                   exsr srPrintLine;
 
                   QbnlpgmiPtr += ApiHead2.ListEntrySize;
 4e             endfor;
 3e          endif;
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srPrintLine;
       lPgm = QuslobjDS.ObjNam;
       lSrcAttr = QusrObjDS.ExtendedAttr;
       lObjText = QusrObjDS.Text;
 
 1b    if p_Output = '*OUTFILE';
          write JCRLSRCFR;
 1x    else;
          write PrtDetail;
 2b       if IsOverFlow;
             write PrtHead;
             IsOverFlow = *off;
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srWriteAsterisk;
       lPgm = aster;
       lSrcLib = aster;
       lSrcFil = aster;
       lSrcMbr = aster;
       lSrcAttr = aster;
       lCreateDt = *blanks;
       lDaysUsed = 0;
       lLastUsed = *blanks;
       lObjText = aster;
       write PrtDetail;
       write PrtMessage;
       endsr;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srSendCompletMsg;
 1b    if p_Output = '*OUTFILE';
          close JCRLSRCF;
          f_SndCompMsg('File ' +%trimr(extOfile)+ ' generated by JCRLSRC');
 1x    else;
          close JCRLSRCP;
          f_Dltovr('JCRLSRCP');
          f_DisplayLastSplf('JCRLSRCR': p_Output);
 1e    endif;
       *inlr = *on;
       return;
       endsr;
 
       //----------------------------------------------------------------
       // global function to tidy up mainline code for loading print fields
       //----------------------------------------------------------------
       dcl-proc f_FmtPrint;
        dcl-pi *n;
         pFile char(10);
         pLib char(10);
         pMbr char(10);
        end-pi;
 
 1b     if ApiErrDS.BytesReturned > 0;  //Source not available
           lSrcFil = aster;
           lSrcLib = aster;
           lSrcMbr = aster;
 1x     else;
           lSrcFil = pFile;
           lSrcLib = pLib;
           lSrcMbr = pMbr;
 1e     endif;
 
        return;
       end-proc;
