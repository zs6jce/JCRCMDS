       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRLOGR - Retrieve previously executed commands
       //  loop through Qmhrtvrq API call to get all previous executed commands
       //   load and display subfile of distinct commands.
       //    prompt selection and execution of commands
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCRLOGD workstn sfile(sbfdta1: rrn) infds(infds) indds(ind);
 
       /define ApiErrDS
       /define Constants
       /define Infds
       /define Dspatr
       /define FunctionKeys
       /define Ind
       /define Qcmdchk
       /define Quscmdln
       /define Sds
       /define f_RtvMsgApi
       /define f_RmvSflMsg
       /define f_SndCompMsg
       /define f_SndSflMsg
       /define f_RunCmd
       /define f_GetDayName
       /COPY JCRCMDS,JCRCMDSCPY
 
       // Retrieve Message
       dcl-pr Qmhrtvrq extpgm('QMHRTVRQ');
        *n like(rtvq0100DS);  // message information
        *n int(10) const;  // message length
        *n char(8) const;  // format name
        *n char(10) const;  // message type
        *n char(4);  // message key
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds rtvq0100DS qualified;
        BytesReturned int(10) pos(1);
        BytesAvail int(10) pos(5);
        MsgKey char(4) pos(9);
        MsgLenReturn int(10) pos(33);
        MsgLenAvail int(10) pos(37);
        MsgText char(500) pos(41);
        MsgText2 char(2) overlay(MsgText:1);
        MsgText6 char(6) overlay(Msgtext:1);
       end-ds;
 
       dcl-s MsgKey char(4);
       dcl-s MsgType char(10);
       dcl-s CmdList char(500) dim(500);
       dcl-s CmdCount uns(5);
 
       //---------------------------------------------------------
       scDow = f_GetDayName();
       exsr srRefreshScreen;
 
 1b    dou 1 = 2;
          write msgctl;
          write sbfctl1;
          exfmt sfooter1;
 2b       if (not Ind.sfldsp)
             or InfdsFkey = f03 or InfdsFkey = f12;
             f_SndCompMsg('JCRLOG - completed');
             *inlr = *on;
             return;
 
 2x       elseif InfdsFkey = f05;
             exsr srRefreshScreen;
 
 2x       elseif InfdsFkey = f21;  //command line
             callp(e) QUSCMDLN();
 
 2x       else;
             f_RmvSflMsg(ProgId);
 
             readc sbfdta1;
 3b          dow not %eof;
                aCmdMsg = Green;
 
 4x             if sbfOption = '2';
                   f_RunCmd('?' + FullCmd);
 
 4b             elseif sbfOption > ' ';
                   f_RunCmd(%trimr(FullCmd));
 4e             endif;
 
 4b             if ApiErrDS.BytesReturned > 0;  //error occurred
                   aCmdMsg = %bitor(White: RI);
                   f_SndSflMsg(ProgId:
                   ApiErrDS.ErrMsgId + ': ' +
                   f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal));
 4x             else;
                   f_SndSflMsg(ProgId:
                   %trimr(
                   %subst(
                   FullCmd: 1: 60)) + ' - completed');
 4e             endif;
 
                // Update subfile to reflect selected change
                sbfOption = *blanks;
                s1recnum = rrn;
                update sbfdta1;
                readc sbfdta1;
 3e          enddo;
 2e       endif;
 1e    enddo;
 
       //---------------------------------------------------------
       begsr srRefreshScreen;
       Ind.sfldsp = *off;
       Ind.sfldspctl = *off;
       aCmdMsg = Green;
       rrn = 0;
       write sbfctl1;
       CmdCount = 0;
       MsgKey = *blanks;
       MsgType = '*LAST';
 
 1b    dou rtvq0100DS.BytesAvail = 0;
          callp Qmhrtvrq(
                rtvq0100DS:
                %len(rtvq0100DS):
                'RTVQ0100':
                MsgType:
                MsgKey:
                ApiErrDS);
 
 2b       if rtvq0100DS.BytesAvail > 0;
             MsgType = '*PRV';
             MsgKey = rtvq0100DS.MsgKey;
 3b          if not(rtvq0100DS.MsgText2 = '/*'
                or rtvq0100DS.MsgText6 = 'jcrlog'
                or rtvq0100DS.MsgText6 = 'JCRLOG'
                or rtvq0100DS.MsgText6 = 'ENDRQS');
                FullCmd =
                %subst(rtvq0100DS.MsgText: 1: rtvq0100DS.MsgLenReturn);
 
 4b             If %subst(FullCmd:1:1) = '?';
                   FullCmd = %subst(FullCmd:3);
 4e             endif;
 
                //---------------------
 4b             if %subst(FullCmd:1:1) = '?';
                   FullCmd = %subst(FullCmd:3:%len(FullCmd)-2);
 4e             endif;
                //---------------------
 
                // show distinct commands
 4b             if CmdCount = 0
                   or %lookup(FullCmd: CmdList: 1: CmdCount) = 0;
                   CmdCount += 1;
                   CmdList(CmdCount) = FullCmd;
                   callp(e) QCMDCHK(FullCmd: %len(%trimr(FullCmd)));
 5b                if not %error;
                      cmdmsg73 = FullCmd;
                      rrn += 1;
                      write sbfdta1;
 5e                endif;
 4e             endif;
 3e          endif;
 2e       endif;
 1e    enddo;
 
       f_RmvSflMsg(ProgId);
       s1recnum = 1;
       Ind.sfldsp = (rrn > 0);
       Ind.sfldspctl = *on;
       endsr;
