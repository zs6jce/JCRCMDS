       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRNETFMV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define f_Qusrobjd
       /define f_RtvMsgAPI
       /define f_CheckMbr
       /define f_SndEscapeMsg
       // *ENTRY
       /define p_JCRNETFMR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s NumofMbrs int(5) based(p_MbrListPtr);
       dcl-s NumOfUsrs int(5) based(p_UsrListPtr);
 
       //---------------------------------------------------------
       // overlay entry parms with other definitions
       p_UsrListPtr = %addr(p_UsrList);
       p_MbrListPtr = %addr(p_MbrList);
 
       //----------------------------------------
       QusrObjDS = f_QUSROBJD(p_FileQual: '*FILE');
 1b    if ApiErrDS.BytesReturned > 0;
          f_SndEscapeMsg(ApiErrDS.ErrMsgId + ': ' +
          %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal)));
 1e    endif;
 
       //----------------------------------------
 1b    if not(%subst(QusrObjDS.ExtendedAttr: 1: 2) = 'PF'
          or %subst(QusrObjDS.ExtendedAttr: 1: 4) = 'SAVF');
 
          ApiErrDS.ErrMsgId = 'CPF8057';
          ApiErrDS.MsgReplaceVal = p_FileQual;
          f_SndEscapeMsg(ApiErrDS.ErrMsgId + ': ' +
          %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal)));
 1e    endif;
 
       //----------------------------------------
 1b    if NumOfUsrs = 0;
          f_SndEscapeMsg('Must select at least one TOUSRID.');
 1e    endif;
 
       //----------------------------------------
 1b    if NumofMbrs = 0;
          f_SndEscapeMsg('Must select at least one MBR NAME.');
 1e    endif;
 
       //----------------------------------------
       f_CheckMbr(p_FileQual: '*FIRST');
       *inlr = *on;
       return;
