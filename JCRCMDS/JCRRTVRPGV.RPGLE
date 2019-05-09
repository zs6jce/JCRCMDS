       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRRTVRPGV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define f_CheckObj
       /define f_SrcFileAddPfm
       /define f_RtvMsgAPI
       /define f_SndEscapeMsg
       /define f_Qusrobjd
       /COPY JCRCMDS,JCRCMDSCPY
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_ObjQual char(20);
        p_SrcMbr char(10);
        p_SrcQual char(20);
       end-pi;
       //---------------------------------------------------------
 
       f_CheckObj(p_ObjQual: '*PGM');
       f_CheckObj(p_SrcQual: '*FILE');
 
       QusrObjDS = f_QUSROBJD(p_ObjQual: '*PGM');
 1b    if not(QusrObjDS.ExtendedAttr = 'RPGLE' or
          QusrObjDS.ExtendedAttr = 'SQLRPGLE');
          f_SndEscapeMsg('Program type ' + %trimr(QusrObjDS.ExtendedAttr) +
          ' is not type RPGLE or SQLRPGLE.');
 1e    endif;
 
       //---------------------------------------------------------
       f_SrcFileAddPfm(p_SrcQual: p_SrcMbr: 'RPGLE':
       'Source recovered by JCRRTVRPG - ' +%trimr(%subst(p_ObjQual:1:10)));
 
 1b    if ApiErrDS.BytesReturned > 0;
          ApiErrDS.MsgReplaceVal = p_SrcMbr + p_SrcQual;
          f_SndEscapeMsg(ApiErrDS.ErrMsgId + ': ' +
          %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal)));
 1e    endif;
 
       *inlr = *on;
       return;
