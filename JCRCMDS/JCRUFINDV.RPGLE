       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRUFINDV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define f_CheckObj
       /define f_Quscrtus
       /define Quslobj
       /define f_RtvMsgAPI
       /define f_SndEscapeMsg
       /define f_GetQual
       /define f_BuildString
       /define f_OutFileCrtDupObj
       // *ENTRY
       /define p_JCRUFINDR
       /COPY JCRCMDS,JCRCMDSCPY
 
       //---------------------------------------------------------
       f_CheckObj(%subst(p_ScanSpaces: 11: 10) + 'QSYS':'*LIB');
 
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
       callp QUSLOBJ(
             UserSpaceName:
             'OBJL0100':
             p_ScanSpaces:
             '*USRSPC':
             ApiErrDS);
 
 1b    if ApiErrDS.BytesReturned > 0;
          f_SndEscapeMsg(ApiErrDS.ErrMsgId + ': ' +
          %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal)));
 1e    endif;
 
       QuslobjPtr = ApiHeadPtr + ApiHead.OffSetToList;
 
 1b    if ApiHead.ListEntryCount = 0;
          f_SndEscapeMsg(
          f_BuildString('User space & was not found.':
          f_GetQual(p_ScanSpaces)));
 1e    endif;
 
 1b    if p_ScanString1 = *blanks;
          f_SndEscapeMsg('Scan String 1 must have a value.');
 1e    endif;
 
 1b    if p_Relations > *blanks
          and p_ScanString2 = *blanks;
          f_SndEscapeMsg('Scan String 2 must have a value.');
 1e    endif;
 
 1b    if p_Relations = *blanks
          and p_ScanString2 > *blanks;
          f_SndEscapeMsg('Relationship must have a value.');
 1e    endif;
 
 1b    if p_Output = '*OUTFILE';
          f_OutFileCrtDupObj(p_OutFileQual: p_OutMbrOpt: 'JCRUFINDF');
 1e    endif;
 
       *inlr = *on;
       return;
