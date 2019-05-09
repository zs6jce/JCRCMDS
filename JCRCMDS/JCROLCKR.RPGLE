       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCROLCKR - Object lock list-sndbrkmsg or endjob(*immed)
       // Modify BreakMsgText to change default break message text.
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCROLCKD workstn sfile(sbfdta1: rrn) infds(infds) indds(ind);
 
       /define ApiErrDS
       /define Constants
       /define Infds
       /define FunctionKeys
       /define Ind
       /define Sds
       /define f_BuildString
       /define f_RunOptionJob
       /define f_GetQual
       /define f_GetDayName
       /define f_Quscrtus
       /define f_Qusrobjd
       /define f_RmvSflMsg
       /define f_SndSflMsg
       /define f_RunCmd
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s SflRcdNbrSav like(sflrcdnbr);
       dcl-s BreakMsgQueue char(20) dim(50);
       dcl-s BreakMsgText char(70);
       dcl-s JobNamePrev char(10);
       dcl-s JobNumbPrev char(6);
       dcl-s JobUserPrev char(10);
       dcl-s MbrName char(10);
       dcl-s IsToggleLock ind;
       dcl-s IsRefresh ind inz(*off);
 
       // List Object Locks
       dcl-pr Qwclobjl extpgm('QWCLOBJL');
        *n char(20);  // user space
        *n char(8) const;  // api format
        *n char(20);  // object and lib
        *n char(10);  // object type
        *n char(10);  // mbr
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds QwclobjlDS qualified based(QwclobjlPtr);
        JobName char(10) pos(1);
        JobUser char(10) pos(11);
        JobNumb char(6) pos(21);
        LockState char(10) pos(27);
        LockStatus int(10) pos(37);
        LockType int(10) pos(41);
        MbrName char(10) pos(45);
        Share char(1) pos(55);
        LockScope char(1) pos(56);
        ThreadID char(8) pos(57);
       end-ds;
 
       // Send Break Message
       dcl-pr Qmhsndbm extpgm('QMHSNDBM');
        *n char(70);  // text
        *n int(10) const;  // length
        *n char(10) const;  // type
        *n char(20) dim(50);  // msgq array
        *n int(10) const;  // msg length
        *n char(20) const;  // msg reply queue
        *n like(ApiErrDS);
       end-pr;
 
       // toggle between lock information and user profile text
       dcl-ds LockInfoDS qualified;
        scLock char(10) pos(1);
        scStatus char(6) pos(12);
        scType char(19) pos(19);
        scMbr char(10) pos(39);
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_ObjQual char(20);
        p_ObjTyp char(10);
       end-pi;
 
       scDow = f_GetDayName();
 
       //---------------------------------------------------------
       QusrObjDS = f_QUSROBJD(p_ObjQual: p_ObjTyp);
       %subst(p_ObjQual: 11: 10) = QusrObjDS.ReturnLib;
 
 1b    if %subst(QusrObjDS.ExtendedAttr: 1: 2) = 'PF'
          or %subst(QusrObjDS.ExtendedAttr: 1: 2) = 'LF';
          MbrName = '*ALL';
 1x    else;
          MbrName = '*NONE';
 1e    endif;
 
       scObjHead =
       f_BuildString('&  &  &  &': %subst(p_ObjQual: 1: 10):
       QusrObjDS.ReturnLib: p_ObjTyp: QusrObjDS.Text);
 
       IsToggleLock = *on;
 
       BreakMsgText =
       f_BuildString('Lock status: &. Please SIGNOFF now.':
       p_ObjQual);
 
       // Create user space and get pointer to header
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
       exsr srRefreshScreen;
 
       //---------------------------------------------------------
 1b    dou 1 = 2;
          write msgctl;
          write sfooter1;
          exfmt sbfctl1;
          f_RmvSflMsg(ProgId);
          SflRcdNbr = InfdsSflRcdNbr;
 
 2b       if InfdsFkey = f03 or InfdsFkey = f12;
             *inlr = *on;
             return;
 
             // refresh
 2x       elseif InfdsFkey = f05 or InfdsFkey = f08;
             IsRefresh = *on;
             SflRcdNbrSav = SflRcdNbr;
             Ind.sfldsp = *off;
             Ind.sfldspctl = *off;
             write sbfctl1;
             rrn = 0;
 
 3b          if InfdsFkey = f08;
                IsToggleLock = (not IsToggleLock);
 3e          endif;
             exsr srRefreshScreen;
 
             // override default break message
 2x       elseif InfdsFkey = f10;
             wbBrkMsg = BreakMsgText;
             exfmt WindowB;
 3b          if not(InfdsFkey = f12);
                BreakMsgText = wbBrkMsg;
 3e          endif;
 
 2x       elseif Ind.sfldsp;
 
             //-------------------------------------------
             readc sbfdta1;
 3b          dow not %eof;
 4b             if sbfOption > 0;
 
                   // Load and send break message
 5b                if sbfOption = 1;
                      BreakMsgQueue(1) = scJobName + '*LIBL';
                      f_SndSflMsg(ProgId: 'Break message sent');
 
                      callp QMHSNDBM(
                            BreakMsgText:
                            %size(BreakMsgText):
                            '*INFO':
                            BreakMsgQueue:
                            1:
                            'QSYSOPR   *LIBL':
                            ApiErrDS);
 
 5x                elseif sbfOption = 11;
                      f_RunCmd(f_buildstring(
                      'DSPUSRPRF USRPRF(&)':
                      scJobUser));
 
 5x                else;
                      f_RunOptionJob(
                      sbfoption:
                      scJobName:
                      scJobUser:
                      scJobNumb:
                      ProgId);
 5e                endif;
 
                   // update subfile to reflect selected change
                   sbfOption = 0;
                   update sbfdta1;
                   SflRcdNbr = rrn;
 4e             endif;
 
                readc sbfdta1;
 3e          enddo;
 2e       endif;
 1e    enddo;
 
       //---------------------------------------------------------
       // load object lock jobs into user space
       //---------------------------------------------------------
       begsr srRefreshScreen;
 1b    if IsToggleLock;
          scToggHead = 'Lock';
          %subst(scToggHead:12) = 'Status Type';
          %subst(scToggHead:39) = 'Member';
 1x    else;
          scToggHead = 'Text';
 1e    endif;
 
       JobNamePrev = *blanks;
       JobUserPrev = *blanks;
       JobNumbPrev = *blanks;
 
       callp QWCLOBJL(
             UserSpaceName:
             'OBJL0100':
             p_ObjQual:
             p_ObjTyp:
             MbrName:
             ApiErrDS);
 
       // Process list entries in user space
       QwclobjlPtr = ApiHeadPtr + ApiHead.OffSetToList;
 
 1b    for ForCount = 1 to ApiHead.ListEntryCount;
          // Some jobs can have multiple different type locks on same object.
          // For this screen, only want to see one of them.
 2b       if not(JobNamePrev = QwclobjlDS.JobName
             and JobUserPrev = QwclobjlDS.JobUser
             and JobNumbPrev = QwclobjlDS.JobNumb);
 
             JobNamePrev = QwclobjlDS.JobName;
             JobUserPrev = QwclobjlDS.JobUser;
             JobNumbPrev = QwclobjlDS.JobNumb;
 
             // load presentation layer
 3b          if QwclobjlDS.LockStatus = 1;
                LockInfoDS.scStatus = '*ACTIV';
 3x          elseif QwclobjlDS.LockStatus = 2;
                LockInfoDS.scStatus = '*WAIT';
 3x          elseif QwclobjlDS.LockStatus = 3;
                LockInfoDS.scStatus = '*ASYNC';
 3x          else;
                LockInfoDS.scStatus = '*ERROR';
 3e          endif;
 
 3b          if QwclobjlDS.LockType = 1;
                LockInfoDS.scType = 'Lock on Object';
 3x          elseif QwclobjlDS.LockType = 2;
                LockInfoDS.scType = 'Lock on Member';
 3x          elseif QwclobjlDS.LockType = 3;
                LockInfoDS.scType = 'Lock on Access Path';
 3x          elseif QwclobjlDS.LockType = 4;
                LockInfoDS.scType = 'Lock on Data';
 3e          endif;
 
             scJobName = QwclobjlDS.JobName;
             scJobUser = QwclobjlDS.JobUser;
             scJobNumb = QwclobjlDS.JobNumb;
             LockInfoDS.scLock = QwclobjlDS.LockState;
             LockInfoDS.scMbr = QwclobjlDS.MbrName;
             scds = LockInfods;
 
 3b          if not IsToggleLock;
                QusrObjDS =
                f_QUSROBJD(QwclobjlDS.JobUser + 'QSYS': '*USRPRF');
 4b             if ApiErrDS.BytesReturned = 0;
                   scDs = QusrObjDS.Text;
 4x             else;
                   scDs = 'Not authorized';
 4e             endif;
 3e          endif;
 
             rrn += 1;
             write sbfdta1;
 2e       endif;
          QwclobjlPtr += ApiHead.ListEntrySize;
 1e    endfor;
 
       //----------------------------------------
       SflRcdNbr = 1;
       Ind.sfldsp = (rrn > 0);
 
 1b    if (not Ind.sfldsp);
          f_SndSflMsg(ProgId: 'No Object Locks were found');
 1e    endif;
 
       Ind.sfldspctl = *on;
 
 1b    if IsRefresh and Ind.sfldsp;
 2b       if SflRcdNbrSav > rrn;
             SflRcdNbr = rrn;
 2x       else;
 3b          if SflRcdNbrSav = 0;
                SflRcdNbr = 1;
 3x          else;
                SflRcdNbr = SflRcdNbrSav;
 3e          endif;
 2e       endif;
          IsRefresh = *off;
 1e    endif;
       endsr;
