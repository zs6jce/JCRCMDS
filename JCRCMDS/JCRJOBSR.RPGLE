       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRJOBSR - Work with selected jobs
       //
       //  add filter for Current User filter
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCRJOBSD workstn sfile(sbfdta1: rrn) infds(infds) indds(ind);
 
       /define ApiErrDS
       /define Constants
       /define Infds
       /define FunctionKeys
       /define Ind
       /define Sds
       /define f_RunOptionJob
       /define f_Quscrtus
       /define f_RmvSflMsg
       /define f_SndSflMsg
       /define f_GetDayName
       /define Qlgsort
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s FunctionType char(1);
       dcl-s Status char(10);
       dcl-s aJobq char(10);
       dcl-s aJobqLib char(10);
       dcl-s aSubSystem char(10);
       dcl-s aJobqStat like(sthreadsta);
       dcl-s LenofDataBuff int(10);
       dcl-s NumberOfKeys int(10) inz(7);
       dcl-s rrnsave like(rrn);
       dcl-s Filter char(10);
       dcl-s FilterLen uns(3);
       dcl-s IsGeneric ind;
       dcl-s IsSelected ind;
       dcl-s QuickSort char(200) based(qusljobptr);
       dcl-s SwapName char(10);
       dcl-s savrcdnbr like(sflrcdnbr);
 
       // Retrieve Jobq Info
       dcl-pr Qsprjobq extpgm('QSPRJOBQ');
        *n char(145);  // Receiver
        *n int(10) const;  // Receiver Length
        *n char(8) const;  // Api Format
        *n char(20) const;  // Qualified JobQ Name
        *n like(ApiErrDS);
       end-pr;
 
       // List Jobs
       dcl-pr Qusljob extpgm('QUSLJOB');
        *n char(20);  // user space
        *n char(8) const;  // api format
        *n char(26);  // qualified job name
        *n char(10);  // status
        *n like(ApiErrDS);
        *n char(1) const;  // type jobs
        *n int(10);  // number of keys
        *n char(16);  // integer key array
       end-pr;
 
       // retrieve job list entries
       dcl-ds QusljobDS qualified based(QusljobPtr);
        JobName char(10) pos(1);
        UserName char(10) pos(11);
        JobNumber char(6) pos(21);
        IntJobID char(16) pos(27);
        JobStatus char(8) pos(43);
        JobType char(1) pos(53);
        KeyReturnCtn int(10) pos(61);
        CurrUser char(10) pos(101);
       end-ds;
 
       // load request key values
       dcl-ds KeyValues qualified;
        *n int(10) inz(0101); // active job status
        *n int(10) inz(0305); // active job status
        *n int(10) inz(0601); // function name
        *n int(10) inz(0602); // function type
        *n int(10) inz(1004); // job queue
        *n int(10) inz(1802); // runpty
        *n int(10) inz(1903); // status on queue
       end-ds;
 
       dcl-ds RunDS qualified;
        RunPriority int(10);  // 1802
       end-ds;
 
       dcl-ds keyds qualified based(uKeyPtr);
        LengthReturn int(10) pos(1);
        KeyField int(10) pos(5);
        LengthOfData int(10) pos(13);
        Data char(20) pos(17);
       end-ds;
 
       dcl-ds QSPRJOBQDS len(145) qualified;
        SubSys char(10) pos(63);
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        pJobNameQual char(26);
        pJobStatus char(7);
        pThreadStat char(4);
        pCurrUser char(10);
        pSelectJobq char(10);
       end-pi;
       //---------------------------------------------------------
 
       Status = pJobStatus;
       IsGeneric = *off;
       Toggle1 = 'User';
       scDow = f_GetDayName();
 
       // Extract jobq scan value and length of scan value
 1b    if not(pSelectJobq = '*ALL');
 2b       if not(%subst(pSelectJobq: 10: 1) = ' '
             or %subst(pSelectJobq: 10: 1) = '*');
             Filter = pSelectJobq;
             FilterLen = 10;
 2x       else;
             aa = %scan('*': pSelectJobq: 1);
 3b          if aa > 0;
                IsGeneric = *on;
 3x          else;
                aa = %scan(' ': pSelectJobq: 1);
 3e          endif;
             Filter = %subst(pSelectJobq: 1: aa - 1);
             FilterLen = aa-1;
 2e       endif;
 1e    endif;
 
       //---------------------------------------------------------
       // load user space with job information
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
 
       exsr srRefresh;
 
 1b    dou 1 = 2;
          write msgctl;
          write sfooter1;
          exfmt sbfctl1;
          f_RmvSflMsg(ProgId);
          savrcdnbr = InfdsSflRcdNbr;
 
 2b       if InfdsFkey = f03 or InfdsFkey = f12;
             *inlr = *on;
             return;
 
             // sort by job name or user name
 2x       elseif InfdsFkey = f09 or InfdsFkey = f10;
             Ind.sfldsp = *off;
             Ind.sfldspctl = *off;
             write sbfctl1;
             rrn = 0;
 
             qlgSortDS = %subst(qlgSortDS: 1: 80);  //drop off keys
             QusljobPtr = ApiHeadPtr + ApiHead.OffSetToList;
             qlgsortDS.RecordLength = ApiHead.ListEntrySize;
             qlgsortDS.RecordCount = ApiHead.ListEntryCount;
             qlgsortDS.NumOfKeys = 1;
 
 3b          if InfdsFkey = f09;
                qlgsortDS = %trimr(qlgsortDS) + f_AddSortKey(1: 10);
 3x          else;
 4b             if Toggle1 = 'Current';  // current user
                   qlgsortDS = %trimr(qlgsortDS) + f_AddSortKey(101: 10);
 4x             else;
                   qlgsortDS = %trimr(qlgsortDS) + f_AddSortKey(11: 10);
 4e             endif;
 3e          endif;
 
             qlgsortDS.BlockLength = %len(%trimr(qlgsortDS));
             LenofDataBuff = ApiHead.ListEntryCount *ApiHead.ListEntrySize;
             callp QLGSORT(
                   qlgsortDS:
                   QuickSort:
                   QuickSort:
                   LenofDataBuff:
                   LenofDataBuff:
                   ApiErrDS);
 
             exsr srLoadFromUserSpace;
             Ind.sfldsp = (rrn > 0);
             Ind.sfldspctl = *on;
             SflRcdNbr = 1;
 
 2x       elseif InfdsFkey = f05;
             exsr srRefresh;
 
 2x       elseif InfdsFkey = f08;
 3b          if Toggle1 = 'User ';  // swap column headings
                Toggle1 = 'Current';
 3x          else;
                Toggle1 = 'User ';
 3e          endif;
 
 3b          for rrn = 1 to rrnsave;
                chain rrn sbfdta1;
                SwapName = sUserName;
                sUserName = sCurrUser;
                sCurrUser = SwapName;
                update sbfdta1 %fields(sCurrUser: sUserName);
 3e          endfor;
             sflrcdnbr = savrcdnbr;
 
             //---------------------------------------------------------
             // process selected subfile records
             //---------------------------------------------------------
 2x       elseif Ind.sfldsp;
             readc sbfdta1;
 3b          if %eof;
                *inlr = *on;
                return;
 3e          endif;
 
 3b          dow not %eof;
 4b             if sbfOption > 0;
 5b                if Toggle1 = 'Current';  // current user
                      SwapName = sCurrUser;
 5x                else;
                      SwapName = sUserName;
 5e                endif;
 
                   f_RunOptionJob(
                   sbfOption:
                   sJobName:
                   SwapName:
                   sJobNum:
                   ProgId);
 
                   SflRcdNbr = rrn;  //stay on current screen
                   sbfOption = 0;
                   update sbfdta1;
 4e             endif;
 
                readc sbfdta1;
 3e          enddo;
 
 2e       endif;
 1e    enddo;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srRefresh;
       Ind.sfldsp = *off;
       Ind.sfldspctl = *off;
       write sbfctl1;
       rrn = 0;
 
       callp QUSLJOB(
             UserSpaceName:
             'JOBL0200':
             pJobNameQual:
             Status:
             ApiErrDS:
             '*':
             NumberOfKeys:
             KeyValues);
 
       exsr srLoadFromUserSpace;
 
       Ind.sfldsp = (rrn > 0);
 1b    if (not Ind.sfldsp);
          f_SndSflMsg(ProgId: 'No Jobs were found');
 1e    endif;
 
       Ind.sfldspctl = *on;
       SflRcdNbr = 1;
       endsr;
 
       //---------------------------------------------------------
       // Process list entries in user space
       //---------------------------------------------------------
       begsr srLoadFromUserSpace;
       QusljobPtr = ApiHeadPtr + ApiHead.OffSetToList;
 
 1b    for ForCount = 1 to ApiHead.ListEntryCount;
          IsSelected = *on;
 2b       if not(QusljobDS.JobStatus = '*ACTIVE' or
             QusljobDS.JobStatus = '*JOBQ');
             sFuncName = *blanks;
             sRunPty = *blanks;
             QusljobDS.JobType = *blanks;
             sThreadSta = *blanks;
             sJobType = *blanks;
 2x       else;
             //---------------------------------------------------------
             // Unload key values
             //---------------------------------------------------------
             ukeyPtr = QusljobPtr + 64;
 3b          for aa = 1 to QusljobDS.KeyReturnCtn;
 
 4b             if keyds.KeyField = 0101;
                   sThreadSta = keyds.Data;
 4x             elseif keyds.KeyField = 0305;
                   sCurrUser = keyds.Data;
 5b                if not( pCurrUser = '*ALL ' or
                      pCurrUSer = sCurrUser);
                      IsSelected = *off;
 3v                   leave;
 5e                endif;
 4x             elseif keyds.KeyField = 0601;
                   sFuncName = keyds.Data;
 4x             elseif keyds.KeyField = 0602;
                   FunctionType = keyds.Data;
 4x             elseif keyds.KeyField = 1802;
                   RunDS = keyds.data;
 4e             endif;
 
 4b             if QusljobDS.JobStatus = '*JOBQ';
 5b                if keyds.KeyField = 1004;
                      aJobq = %subst(keyds.Data: 1: 10);
 
                      // validate jobq selection;
 6b                   if pSelectJobq = '*ALL'
                         or
                         (IsGeneric
                         and %subst(aJobq: 1: FilterLen) =
                         %subst(Filter: 1: FilterLen))
                         or
                         (not IsGeneric and aJobq = Filter);
 
 6x                   else;
                         IsSelected = *off;
 3v                      leave;
 6e                   endif;
                      aJobqLib = %subst(keyds.Data: 11: 10);
 
                      // get jobq attached subsystem name
                      callp QSPRJOBQ(
                            QSPRJOBQDS:
                            145:
                            'JOBQ0100':
                            aJobq + aJobqLib:
                            ApiErrDS);
                      aSubSystem = QSPRJOBQDS.SubSys;
 
 5x                elseif keyds.KeyField = 1903;
                      aJobqStat = keyds.Data;
 5e                endif;
 4e             endif;
                ukeyPtr += keyds.LengthReturn;
 3e          endfor;
 
 3b          if FunctionType = 'D';
                sFuncName = 'DLYW-' + sFuncName;
 3e          endif;
             sRunPty = %char(RunDS.RunPriority);
 
 3b          if QusljobDS.JobType = ' ';
                sJobType = 'Invalid';
 3x          elseif QusljobDS.JobType = 'A';
                sJobType = 'Auto Start';
 3x          elseif QusljobDS.JobType = 'B';
                sJobType = 'Batch';
 3x          elseif QusljobDS.JobType = 'I';
                sJobType = 'Interactive';
 3x          elseif QusljobDS.JobType = 'M';
                sJobType = 'Sbs Monitor';
 3x          elseif QusljobDS.JobType = 'R';
                sJobType = 'Spooled Rdr';
 3x          elseif QusljobDS.JobType = 'S';
                sJobType = 'System Job';
 3x          elseif QusljobDS.JobType = 'W';
                sJobType = 'Spooled Wtr';
 3x          elseif QusljobDS.JobType = 'X';
                sJobType = 'SCPF Job';
 3x          else;
                sJobType = *blanks;
 3e          endif;
 2e       endif;
 
 2b       if IsSelected;
 3b          if QusljobDS.JobStatus = '*JOBQ';
                sJobType = aJobq;
                sFuncName = aJobqLib;
                sRunPty = aSubSystem;
                sThreadSta = aJobqStat;
 3e          endif;
 
             sJobName = QusljobDS.JobName;
             sUserName = QusljobDS.UserName;
 3b          if Toggle1 = 'Current';  // current user
                SwapName = sUserName;
                sUserName = sCurrUser;
                sCurrUser = SwapName;
 3e          endif;
 
             sJobNum = QusljobDS.JobNumber;
             sJobStatus = QusljobDS.JobStatus;
 3b          if (pThreadStat = '*ALL' or pThreadStat = sThreadSta);
                rrn += 1;
                write sbfdta1;
 3e          endif;
 2e       endif;
          QusljobPtr += ApiHead.ListEntrySize;
 1e    endfor;
 
       rrnsave = rrn;
       endsr;
