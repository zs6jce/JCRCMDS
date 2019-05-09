       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRDDLV - Validity checking program for lib/file/member
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define f_Qusrobjd
       /define f_RtvMsgAPI
       /define f_SndEscapeMsg
       /define f_SrcFileAddPfm
       /define f_CheckObj
       // *ENTRY
       /define p_JCRDDLR
       /COPY JCRCMDS,JCRCMDSCPY
 
       //---------------------------------------------------------
       QusrObjDS = f_QUSROBJD(p_InFileQual: '*FILE');
 1b    if ApiErrDS.BytesReturned > 0;
          f_SndEscapeMsg(ApiErrDS.ErrMsgId + ': ' +
          %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal)));
 1e    endif;
 
       f_CheckObj(p_OutFileQual: '*FILE');
 
       f_SrcFileAddPfm(p_OutFileQual: p_OutMbr: 'DDL': QusrObjDS.Text);
 
       *inlr = *on;
       return;
