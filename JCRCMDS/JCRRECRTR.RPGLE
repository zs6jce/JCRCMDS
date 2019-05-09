       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRRECRTR - Recreate *CMD using existing values
       //  Execute function to return command creation string
       //   Prompt CRTCMD command using QCAPCMD command processor API.
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define f_CrtCmdString
       /define f_RtvMsgAPI
       /define f_SndCompMsg
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s string char(500);
       dcl-s CompMsg char(73);
       dcl-s ChangedSrc char(500);
       dcl-s ChangedLen int(10);
       dcl-s Replacement char(112);
       dcl-s ReplaceLib char(10);
       dcl-s xx uns(3);
       dcl-s yy uns(3);
 
       //Process Commands
       dcl-pr QCAPCMD extpgm('QCAPCMD');
        *n char(500);  // source command
        *n int(10) const;  // length of source
        *n like(cpop0100DS);  // options block
        *n int(10) const;  // options block len
        *n char(8) const;  // options format
        *n char(500);  // changed command
        *n int(10) const;  // length available
        *n int(10);  // length of changed
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds cpop0100DS qualified;
        *n int(10) pos(1) inz(0); // command running
        *n char(1) pos(5) inz('0'); // DBCS handling
        *n char(1) pos(6) inz('2'); // prompt if ?
        *n char(1) pos(7) inz('0'); // use system syntax
        *n char(4) pos(8) inz(x'00000000'); // message key
        *n int(10) pos(12) inz(0); // xcsid
        *n char(5) pos(16) inz(x'0000000000'); // reserved
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_CmdQual char(20);
        p_ObjType char(10);
       end-pi;
       //---------------------------------------------------------
 
       // Extract command definitions
       string = f_CrtCmdString(p_CmdQual);
 
       // execute command processing API
       callp QCAPCMD(
             string:
             %len(string):
             cpop0100DS:
             %len(cpop0100ds):
             'CPOP0100':
             ChangedSrc:
             %size(ChangedSrc):
             ChangedLen:
             ApiErrDS);
 
 1b    if ApiErrDS.BytesReturned > 0;
 2b       if  ApiErrDS.ErrMsgId = 'CPF6801';  //f3 or f12 pressed
             Replacement = %subst(ApierrDS.MsgReplaceVal:1:3);
 2x       else;
             // extract actual library name
             xx = %scan('CMD(': string);
             yy = %scan('/':string: xx + 4);
             ReplaceLib = %subst(string: xx + 4: (yy-(xx + 4)));
             Replacement = %subst(p_CmdQual:1:10) + ReplaceLib;
 2e       endif;
 
          CompMsg = ApiErrDS.ErrMsgId + ': ' +
          f_RtvMsgApi(ApiErrDS.ErrMsgId: Replacement);
 1x    else;
          CompMsg = 'JCRRECRT for command ' +
          %trimr(%subst(p_CmdQual:1:10)) + ' - completed';
 1e    endif;
 
       f_SndCompMsg(CompMsg);
       *inlr = *on;
       return;
