       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRIFSSAVV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define f_Qusrobjd
       /define f_CheckDir
       /define f_RtvMsgAPI
       /define f_SndEscapeMsg
       /define f_BuildString
       // *ENTRY
       /define p_JCRIFSSAVR
       /COPY JCRCMDS,JCRCMDSCPY
 
       //---------------------------------------------------------
       QusrObjDS = f_QUSROBJD(p_Savf + p_Lib: '*FILE');
 1b    if ApiErrDS.BytesReturned > 0;
          f_SndEscapeMsg(ApiErrDS.ErrMsgId + ': ' +
          %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal)));
 1e    endif;
 
 1b    if not(QusrObjDS.ExtendedAttr = 'SAVF');
          f_SndEscapeMsg(f_BuildString('Object & in & is not a *SAVF.':
          p_savf: p_lib));
 1e    endif;
 
       f_CheckDir(p_IfsDir);
       *inlr = *on;
       return;
