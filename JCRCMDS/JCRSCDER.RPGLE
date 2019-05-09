       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRSCDER - Search/Copy Job Schedule Entries
       //  call qwclscde API to load list of job schedule entries
       //    allow search through the list and then provide a copy options
 
       // Note: the qwclscde api returns all job schedule entries
       // but can require multiple calls with a continuation handle. (strange api)
       // said all that to say my normal method of searching through the user space
       //  will not work in this circumstance. I have to call the API multiple
       //   times and filter the entries as records are written to the subfile.
 
       // added user profile and show if user profile *NOT FOUND or *DISABLED
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCRSCDED workstn sfile(sbfdta1: rrn1) infds(infds) indds(ind);
 
       /define FunctionKeys
       /define Ind
       /define Infds
       /define ApiErrDS
       /define Constants
       /define Dspatr
       /define Sds
       /define f_BuildString
       /define f_GetQual
       /define f_Quscrtus
       /define f_SndSflMsg
       /define f_RunCmd
       /define f_RmvSflMsg
       /define f_GetDayName
       /define ListAuthorizedUsers
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s ContinuationHandle char(16);
       dcl-s p_Entry char(10) inz('*ALL');
       dcl-s rrn1 uns(5);
       dcl-s IsOk1 ind;
       dcl-s IsOk2 ind;
       dcl-s IsOk3 ind;
       dcl-s IsOk4 ind;
       dcl-s IsSelected ind;
       dcl-s lenscan uns(3);
       dcl-s string1 char(1024);
       dcl-s cvtdate char(16);
       dcl-s yymmdd  char(16);
 
       // command field has a length parameter. I do not not want to search
       //  past the end of the field, so substring commandstring into this field
       dcl-s upcase varchar(512);
 
       dcl-pr QWCLSCDE extpgm('QWCLSCDE'); // list job schedule entries
        *n char(20); // user space
        *n char(8) const; // api format
        *n char(10); // entry
        *n char(16); // continuation handle
        *n like(apierrds);
       end-pr;
 
       dcl-pr Qwccvtdt extpgm('QWCCVTDT'); // api date converter
        *n char(10) const; // from format
        *n char(8); // api date stamp
        *n char(10) const; // to format
        *n char(16); // to date
        *n like(apierrds);
       end-pr;
 
       dcl-ds qwclscdeDS qualified based(qwclscdeptr);
        InformationStatus char(1);
        Job               char(10)  pos(2);
        EntryNumber       char(10)  pos(12);
        ScheduledDate     char(10)  pos(22);
        ScheduledDays     char(10)  dim(7) pos(32);
        ScheduledTime     char(6)   pos(102);
        Frequency         char(10)  pos(108);
        RelativeDayOfTheMonth   char(10) dim(5) pos(118);
        RecoveryAction          char(10)  pos(168);
        NextSubmissionDate      char(10)  pos(178);
        Status                  char(10)  pos(188);
        Jobq                    char(10)  pos(198);
        JobqLib                 char(10)  pos(208);
        UserProfileOfEntryAdder char(10)  pos(218);
        LastSubmissionDate      char(10)  pos(228);
        LastSubmissionTime      char(6)   pos(238);
        Text                    char(50)  pos(244);
        Reserved1               char(23)  pos(294);
        JobqStatus              char(10)  pos(317);
        DatesOmitted            char(10) dim(20) pos(327);
        Jobd                    char(10)  pos(527);
        JobdLib                 char(10) pos(537);
        UserProfileForSubmittedJob char(10) pos(547);
        Msgq                       char(10) pos(557);
        MsgqLib                    char(10) pos(567);
        SaveEntry                  char(10) pos(577);
        LastSubmissionJob          char(10) pos(587);
        LastSubmissionUser         char(10) pos(597);
        LastSubmissionJobNumber    char(6)  pos(607);
        LastAttemptedSubmissionDate char(10) pos(613);
        LastAttemptedSubmissionTime char(6)  pos(623);
        StatusLastAttemptedSubmission char(10)  pos(629);
        Reserved2                     char(2)   pos(639);
        LengthOfCommand               int(10)   pos(641);
        Command                       char(512) pos(645);
       end-ds;
 
       //----*ENTRY---------------------------
       dcl-pi *n;
        p_jobname char(10);
        p_cmd char(20);
       end-pi;
 
       // prep parm for space instead of * wildcards
 1b    if p_jobname > *blanks and p_jobname <> '*ALL';
          p_jobname = %xlate('*':' ':p_jobname);
 1e    endif;
       scJob = p_jobname;
       scCmd = ' ' + p_cmd;
 
       scDow = f_GetDayname();
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
       exsr srRefreshScreen;
       sflrcdnbr = 1;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
 1b    dou 1 = 2;
          Ind.sfldspctl = *on;
          Ind.sfldsp = (rrn1 > 0);
          write msgctl;
          write sfooter1;
          exfmt sbfctl1;
 
 2b       if InfdsFkey = f03 or InfdsFkey = f12;
             *inlr = *on;
             return;
 2e       endif;
 
          f_RmvSflMsg(ProgId);
 
          // refresh
          SflRcdNbr = InfdsSflRcdNbr;
 2b       if InfdsFkey = f05;
             scJob = *blanks;
             scstat = *blanks;
             scCmd = *blanks;
             scUser = *blanks;
             exsr srRefreshScreen;
 
 2x       elseif InfdsFkey = f06;
             f_RunCmd('DSPJOBLOG');
 
 2x       elseif ind.IsChange;
             exsr srRefreshScreen;
 
 2x       elseif  Ind.sfldsp;
 
             // process user requests
             readc sbfdta1;
 
 3b          dow not %eof;
 4b             if sbfOption > ' ';
 
 5b                if sbfOption = 'C';  // copy entry
                      string1=
                      f_BuildString(' +
                      ?ADDJOBSCDE +
                      JOB(&) +
                      FRQ(&) +
                      SCDDATE(&) +
                      SCDDAY(&) +
                      SCDTIME(&) +
                      RCYACN(&) +
                      JOBD(&) +
                      JOBQ(&) +
                      USER(&) +
                      MSGQ(&) +
                      TEXT(&)':
                      sbjob:
                      sFRQ:
                      sSCDDATE:
                      sSCDDAY:
                      sSCDTIME:
                      sRCYACN:
                      sJOBD:
                      sJOBQ:
                      sBUSER:
                      sMSGQ:
                      sTEXT);
 
                      //-----------------------------------------------------
                      // command and omit dates are too long for build string
                      //  if happens again, change build string
                      //-----------------------------------------------------
                      string1 =
                      %trimr(string1) + ' CMD(' + %trimr(scmd) +
                      ') OMITDATE('+ %trim(SOMITDATE) + ')';
                      f_RunCmd(string1);
 6b                   if ApiErrDS.BytesReturned > 0;
                         f_SndSflMsg(progid:
                         'Job Schedule Entry not copied - check joblog');
 6e                   endif;
 
 5x                elseif sbfOption = '5';
                      f_RunCmd('WRKJOBSCDE JOB('+ sbjob + ')');
 5e                endif;
 
                   // update subfile to reflect change
                   aoptions1 = %bitor(Green:UL);
                   clear sbfOption;
 
                   update sbfdta1;
 
                   SflRcdNbr = rrn1;
 4e             endif;
 
                readc sbfdta1;
 3e          enddo;
 2e       endif;
 1e    enddo;
 
       //---------------------------------------------------------
       begsr srRefreshScreen;
       Ind.sfldsp = *off;
       Ind.sfldspctl = *off;
       write sbfctl1;
       rrn1 = 0;
       sflrcdnbr = 1;
       ContinuationHandle = *blanks;
 
       // subroutine allows for partial continuation
       exsr srListEntries;
 1b    if  ApiHead.InformationStatus = 'P';
          ContinuationHandle = ApiHead.ContinuationHandle;
          exsr srListEntries;
 1e    endif;
       endsr;
 
       //-----------------------
       // if first character is blank, then filter is a wild card
       // if first character <> blank, then trailing is wild card
       // scJob is position to.
       // scstat is only show these.
       // sctest is only show these.
       //-----------------------
       begsr srApplyFilters;
 
       IsSelected = *off;
 
       IsOk1 = *off;
 1b    if scJob = '*ALL';  // *entry special value
          IsOk1 = *on;
 
 1x    elseif scJob > *blanks;
 2b       if %subst(scJob:1:1)>*blanks;
             lenscan = %len(%trimr(scJob));
 3b          if %subst(qwclscdeDS.Job:1:lenscan) >= scJob;
                IsOk1 = *on;
 3e          endif;
 2x       else;
 3b          if %scan(%trim(scJob): qwclscdeDS.Job: 1) > 0;
                IsOk1 = *on;
 3e          endif;
 2e       endif;
 1x    else;
          IsOk1 = *on;
 1e    endif;
 
       //--------------------------------------------------
       IsOk2 = *off;
 1b    if scStat > *blanks;
 2b       if scStat = qwclscdeDS.Status;
             IsOk2 = *on;
 2e       endif;
 1x    else;
          IsOk2 = *on;
 1e    endif;
 
       //--------------------------------------------------
       IsOk3 = *off;
 1b    if scUSer > *blanks;
          exsr srGetUserProfile;
 
 2b       if scUser = sbUser;
             IsOk3 = *on;
 2e       endif;
 1x    else;
          IsOk3 = *on;
 1e    endif;
 
       //--------------------------------------------------
       IsOk4 = *off;
 1b    if scCmd > *blanks;
          upcase =
          %subst(qwclscdeDS.Command:1:qwclscdeDS.LengthOfCommand);
          upcase = %xlate(lo:up:upcase);
 
 2b       if %subst(scCmd:1:1)>*blanks;
             lenscan = %len(%trimr(scCmd));
 3b          if %len(upcase) >= lenscan;
 4b             if %subst(upcase:1:lenscan) = scCmd;
                   IsOk4 = *on;
 4e             endif;
 3e          endif;
 2x       else;
 3b          if %scan(%trim(scCmd): upcase: 1) > 0;
                IsOk4 = *on;
 3e          endif;
 2e       endif;
 1x    else;
          IsOk4 = *on;
 1e    endif;
 
 1b    if IsOk1 and IsOk2 and IsOk3 and IsOk4;
          IsSelected = *on;
 1e    endif;
       endsr;
 
       //-----------------------------------------
       //-----------------------------------------
       begsr srListEntries;
       callp QWCLSCDE(
             UserSpaceName:
             'SCDL0200':
             p_Entry:
             ContinuationHandle:
             ApiErrDS);
 
       // Process data from user space by moving qwclscdePtr pointer.
       qwclscdePtr = ApiHeadPtr + ApiHead.OffSetToList;
 1b    for ForCount = 1 to ApiHead.ListEntryCount;
 
 2b       if scJob > *blanks
             or scstat > *blanks
             or scUser > *blanks
             or scCmd > *blanks;
             exsr srApplyFilters;
 2e       endif;
 2b       if IsSelected;
 
 3b          if qwclscdeDS.InformationStatus = 'L';
                SBCMD = 'The Entry is Locked';
 3x          elseif qwclscdeDS.InformationStatus = 'A';
                SBCMD = 'You Have Insufficient Authority';
 3x          else;
                SBCMD =
                %subst(qwclscdeDS.Command:1:qwclscdeDS.LengthOfCommand);
 3e          endif;
 
             //--------------------------------------------------
             // load hidden fields for copy or change selections
             //--------------------------------------------------
             SENTRYNBR = qwclscdeDS.EntryNumber;
             SCMD = %subst(qwclscdeDS.Command:1:qwclscdeDS.LengthOfCommand);
             SFRQ = qwclscdeDS.Frequency;
 
 3b          if %subst(qwclscdeDS.ScheduledDate:1:1) = '*';
                SSCDDATE = qwclscdeDS.ScheduledDate;
 3x          else;
                yymmdd = qwclscdeDS.ScheduledDate + '000001000';
                callp QWCCVTDT(
                      '*YMD    ':
                      yymmdd    :
                      '*JOB    ':
                      cvtdate:
                      ApiErrDS);
                SSCDDATE = %subst(cvtdate:2:6);
 3e          endif;
 
             SSCDDAY =
             %trimr(qwclscdeDS.ScheduledDays(1))+ ' '  +
             %trimr(qwclscdeDS.ScheduledDays(2))+ ' '  +
             %trimr(qwclscdeDS.ScheduledDays(3))+ ' '  +
             %trimr(qwclscdeDS.ScheduledDays(4))+ ' '  +
             %trimr(qwclscdeDS.ScheduledDays(5))+ ' '  +
             %trimr(qwclscdeDS.ScheduledDays(6))+ ' '  +
             qwclscdeDS.ScheduledDays(7);
 
             // if %subst(qwclscdeDS.ScheduledTime:1:1) = '*';
             SSCDTIME = qwclscdeDS.ScheduledTime;
             // else;
             //    SSCDTIME = qs + %trimr(qwclscdeDS.ScheduledTime) + qs;
             // endif;
 
 3b          if %subst(qwclscdeDS.DatesOmitted(01):1:1) = x'00';
                SOMITDATE = '*NONE';
 3x          else;
                SOMITDATE =
                %trimr(qwclscdeDS.DatesOmitted(01))+ ' '  +
                %trimr(qwclscdeDS.DatesOmitted(02))+ ' '  +
                %trimr(qwclscdeDS.DatesOmitted(03))+ ' '  +
                %trimr(qwclscdeDS.DatesOmitted(04))+ ' '  +
                %trimr(qwclscdeDS.DatesOmitted(05))+ ' '  +
                %trimr(qwclscdeDS.DatesOmitted(06))+ ' '  +
                %trimr(qwclscdeDS.DatesOmitted(07))+ ' '  +
                %trimr(qwclscdeDS.DatesOmitted(08))+ ' '  +
                %trimr(qwclscdeDS.DatesOmitted(09))+ ' '  +
                %trimr(qwclscdeDS.DatesOmitted(10))+ ' '  +
                %trimr(qwclscdeDS.DatesOmitted(11))+ ' '  +
                %trimr(qwclscdeDS.DatesOmitted(12))+ ' '  +
                %trimr(qwclscdeDS.DatesOmitted(13))+ ' '  +
                %trimr(qwclscdeDS.DatesOmitted(14))+ ' '  +
                %trimr(qwclscdeDS.DatesOmitted(15))+ ' '  +
                %trimr(qwclscdeDS.DatesOmitted(16))+ ' '  +
                %trimr(qwclscdeDS.DatesOmitted(17))+ ' '  +
                %trimr(qwclscdeDS.DatesOmitted(18))+ ' '  +
                %trimr(qwclscdeDS.DatesOmitted(19))+ ' '  +
                qwclscdeDS.DatesOmitted(20);
 3e          endif;
 
             SRCYACN = qwclscdeDS.RecoveryAction;
 
 3b          if qwclscdeDS.JobdLib = *blanks;
                SJOBD = qwclscdeDS.Jobd;
 3x          else;
                SJOBD = f_GetQual(qwclscdeDS.Jobd +
                        qwclscdeDS.JobdLib);
 3e          endif;
 
 3b          if qwclscdeDS.JobqLib = *blanks;
                SJOBQ = qwclscdeDS.Jobq;
 3x          else;
                SJOBQ = f_GetQual(qwclscdeDS.Jobq +
                        qwclscdeDS.JobqLib);
 3e          endif;
 
             exsr srGetUserProfile;
 
 3b          if qwclscdeDS.MsgqLib = *blanks;
                SMSGQ = qwclscdeDS.Msgq;
 3x          else;
                SMSGQ = f_GetQual(qwclscdeDS.Msgq +
                        qwclscdeDS.MsgqLib);
 3e          endif;
 
             STEXT = qs + %trimr(qwclscdeDS.Text) + qs;
             SBJOB = qwclscdeDS.Job;
             SBSTAT = qwclscdeDS.Status;
             SBFREQ = qwclscdeDS.Frequency;
             SBSTIME =
             %subst(qwclscdeDS.ScheduledTime:1:2) + ':' +
             %subst(qwclscdeDS.ScheduledTime:3:2) + ':' +
             %subst(qwclscdeDS.ScheduledTime:5:2);
 
             //---------------------------------------------------------
             // the scheduled date display is interesting.
             //  the IBM command shows either the schedule date (if <> *NONE)
             //   or the first entry in the DAYS arraye, unless two
             //   or more days are scheduled, then it shows 'USER DEF'
             // I do not necessarily want to replicate that,
             //  but I want to show maximum amount of command string so I will
             //---------------------------------------------------------
 3b          if qwclscdeDS.ScheduledDate <> '*NONE ';
                SBSDATE =
                %subst(qwclscdeDS.ScheduledDate:4:2) + '/' +
                %subst(qwclscdeDS.ScheduledDate:6:2) + '/' +
                %subst(qwclscdeDS.ScheduledDate:2:2);
 3x          else;
 4b             if qwclscdeDS.ScheduledDays(2) > *blanks;
                   SBSDATE = 'USER DEF';
 4x             else;
                   SBSDATE = qwclscdeDS.ScheduledDays(1);
 4e             endif;
 3e          endif;
 
             rrn1 += 1;
             write sbfdta1;
 2e       endif;
 
          qwclscdePtr += ApiHead.ListEntrySize;
 1e    endfor;
       endsr;
 
 
       //----------------------------------------------
       // retrieve status from the user profile.
       begsr srGetUserProfile;
       callp QSYRUSRI(
             Usri0300DS:
             %len(Usri0300DS):
             'USRI0100':
             qwclscdeDS.UserProfileForSubmittedJob:
             ApiErrDS);
 
 1b    if ApiErrDS.BytesReturned > 0 and
          ApiErrDS.ErrMsgId = 'CPF9801';
          SBUSER = '*NOT FOUND';
 1x    elseif usri0300DS.status = '*DISABLED';
          SBUSER = '*DISABLED ';
 1x    else;
          SBUSER = qwclscdeDS.UserProfileForSubmittedJob;
 1e    endif;
       endsr;
