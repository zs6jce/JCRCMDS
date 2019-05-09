       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRDTAARAR - Dtaara values and rollover distance list - print
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define Atof
       /define Constants
       /define Qeccvtec
       /define Quslobj
       /define f_BuildString
       /define f_DecodeApiTimeStamp
       /define f_GetApiISO
       /define f_GetQual
       /define f_Quscrtus
       /define f_RtvMsgAPI
       /define f_SndStatMsg
       /define f_OvrPrtf
       /define f_Dltovr
       /define f_DisplayLastSplf
       /define f_GetDayName
       /define Qecedt
       /define QecedtAlpha
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRDTAARAP printer oflind(IsOverFlow) usropn;
 
       dcl-s CvtVar like(editmask);
       dcl-s xSrcvar like(editmask);
       dcl-s xString like(editmask);
       dcl-s EditMask char(256);
       dcl-s p_ObjTyp char(10) inz('*DTAARA');
       dcl-s MaxValuea varchar(35);
       dcl-s CurValf float(8);
       dcl-s MaxValuef float(8);
       dcl-s ToRollf float(8);
       dcl-s EditMaskLen int(10);
       dcl-s NumXXX int(10);
       dcl-s TempPos int(10);
       dcl-s ToRolli int(20);
       dcl-s vRecvrLen int(10);
       dcl-s IsFound ind;
 
       // Retrieve Data Area
       dcl-pr Qwcrdtaa extpgm('QWCRDTAA');
        *n like(QwcrdtaaDS);  // Receiver
        *n int(10) const;  // Length of Receiver
        *n char(20) const;  // Dtaara and Lib
        *n int(10) const;  // Starting Position
        *n int(10) const;  // Length of Receiver
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds QwcrdtaaDS qualified;
        BytesProvided int(10) inz;
        BytesReturned int(10) inz;
        TypeOfValue char(10);
        DtaaraLib char(10);
        LenReturned int(10) inz;
        NumDecimal int(10) inz;
        Value char(2000);
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_DtaaraQual char(20);
        p_Output char(8);
       end-pi;
       //---------------------------------------------------------
 
       scDow = f_GetDayName();
       headlib = %subst(p_DtaaraQual: 11: 10);
       headdta = %subst(p_DtaaraQual: 1: 10);
 
       f_SndStatMsg(f_BuildString('List dtaaras from & - in progress':
       f_GetQual(p_DtaaraQual)));
 
       f_OvrPrtf('JCRDTAARAP': '*JOB': HeadLib);
       open JCRDTAARAP;
       write prthead;
       IsOverFlow = *off;
 
       // load object names into user space
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
       callp QUSLOBJ(
             UserSpaceName:
             'OBJL0600':
             p_DtaaraQual:
             p_ObjTyp:
             ApiErrDS);
 
 1b    if ApiErrDS.BytesReturned > 0;
          // load print file field, print error message
          vMessage = ApiErrDS.ErrMsgId + ': ' +
          f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal);
 
          exsr srWriteAsterisk;
          write PrtMessage;
          exsr srSendCompletMsg;
 1e    endif;
 
       // if no matching objects found, print error message
 1b    if ApiHead.ListEntryCount = 0;
          exsr srWriteAsterisk;
          vmessage = 'No matching dtaara names found.';
          write PrtMessage;
          exsr srSendCompletMsg;
 1e    endif;
 
       // Process objects in user space by moving pointer
       QuslobjPtr = ApiHeadPtr + ApiHead.OffSetToList;
 
 1b    for ForCount = 1 to ApiHead.ListEntryCount;
          IsFound = *on;
 
          // extract object create date, last used date, number times used
          ApiStampDS = f_DecodeApiTimeStamp(QuslobjDS.CreateStamp);
          CreateDate =
          f_GetApiISO(ApiStampDS.Century + ApiStampDS.YY + ApiStampDS.MMDD);
 
 2b       if QuslobjDS.NumDaysUsed > 9999;
             DaysUsed = 9999;
 2x       else;
             DaysUsed = QuslobjDS.NumDaysUsed;
 2e       endif;
 
 2b       if QuslobjDS.NumDaysUsed > 0;
             ApiStampDS = f_DecodeApiTimeStamp(QuslobjDS.LastUseStamp);
             LastUsed =
             f_GetApiISO(ApiStampDS.Century+ApiStampDS.YY+ApiStampDS.MMDD);
 2x       else;
             LastUsed = *blanks;
 2e       endif;
 
          callp QWCRDTAA(
                QwcrdtaaDS:
                %len(QwcrdtaaDS):
                QuslobjDS.ObjNam + QuslobjDS.ObjLib:
                -1:
                20:
                ApiErrDS);
 
 2b       if QwcrdtaaDS.TypeOfValue = '*DEC';
             xSrcvar = %trimr(QwcrdtaaDS.Value);
             // Convert to String
             xString = *blanks;
             EditMask = *blanks;
             EditMaskLen = 0;
 
             callp QECCVTEC(
                   EditMask:
                   EditMaskLen:
                   vRecvrLen:
                   ' ':
                   'J':
                   ' ':
                   QwcrdtaaDS.LenReturned:
                   QwcrdtaaDS.NumDecimal:
                   ApiErrDS);
 
             cvtvar = *allx'FF';
             callp QECEDT(
                   cvtvar:
                   vRecvrLen:
                   xSrcvar:
                   '*PACKED':
                   QwcrdtaaDS.LenReturned:
                   EditMask:
                   EditMaskLen:
                   ' ':
                   ApiErrDS);
 
             temppos = %checkr(x'FF': cvtvar);
 3b          if temppos = *zeros;
                temppos = vRecvrLen;
 3e          endif;
             xString = %subst(cvtvar: 1: temppos);
 
             evalr curvala = %trimr(xString);
 3b          if curvala = *blanks;
                evalr curvala = '0';
 3e          endif;
 
             // remove/compress commas from J code edit,
             // before converting to float.
             xstring = %scanrpl(',':'': xstring);
             CurValf = atof(%trimr(xString));
 
             // build character string to match largest size of dtaara
             NumXXX = (QwcrdtaaDS.LenReturned - QwcrdtaaDS.NumDecimal);
             %len(MaxValueA) = 0;
 3b          for ForCount2 = 1 to NumXXX;
                MaxValueA = MaxValueA + '9';
 3e          endfor;
 
 3b          if QwcrdtaaDS.NumDecimal > 0;
                MaxValueA = MaxValueA + '.';
 3e          endif;
 
 3b          for ForCount2 = 1 to QwcrdtaaDS.NumDecimal;
                MaxValueA = MaxValueA + '9';
 3e          endfor;
 
             // make it float value
             MaxValuef = atof(%trimr(maxvaluea));
 
             // calc difference and load to alpha
             ToRollF = MaxValuef - CurValf;
             NumXXX = (QwcrdtaaDS.LenReturned - QwcrdtaaDS.NumDecimal);
             eval(h) ToRolli = ToRollf;
             evalr torolla = %editc(torolli:'J');
             PrtLength = QwcrdtaaDS.LenReturned;
             PrtNumDec = QwcrdtaaDS.NumDecimal;
 
             // print line of report
             ObjNam = QuslobjDS.ObjNam;
             ObjText = QuslobjDS.ObjText;
             PrtValType = QwcrdtaaDS.TypeOfValue;
 
             write PrtDetail;
 3b          if IsOverFlow;
 4b             if ForCount <> ApiHead.ListEntryCount; // no last blank page
                   write PrtHead;
 4e             endif;
                IsOverFlow = *off;
 3e          endif;
 2e       endif;
 
          QuslobjPtr += ApiHead.ListEntrySize;
 1e    endfor;
 
       // if no matching objects found, print message and exit
 1b    if not IsFound;
          exsr srWriteAsterisk;
          vmessage = 'No matching dtaara names found.';
          write PrtMessage;
 1x    else;
          // end of report
          vmessage = ' ** End Of Report';
          write PrtMessage;
 1e    endif;
       exsr srSendCompletMsg;
 
       //---------------------------------------------------------
       begsr srSendCompletMsg;
       close JCRDTAARAP;
       f_Dltovr('JCRDTAARAP');
       f_DisplayLastSplf('JCRDTAARAR': p_Output);
       *inlr = *on;
       return;
       endsr;
 
       //---------------------------------------------------------
       begsr srWriteAsterisk;
       QuslobjPtr = ApiHeadPtr;
       ObjNam = *all'*';
       CreateDate = *all'*';
       LastUsed = *all'*';
       DaysUsed = 0;
       ObjText = *all'*';
       write PrtDetail;
       endsr;
