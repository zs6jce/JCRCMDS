       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRUSPACEV - Validity checking program
       // note: Retrieving pointers to system domain objects is not allowed at seclvl 40
       //  ie. Cannot search system domain user spaces
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckObj
       /define Qusptrus
       /define ApiErrDS
       /define f_RtvMsgAPI
       /define f_SndEscapeMsg
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s uSpacePtr pointer inz(*null);
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_uSpaceQual char(20);
       end-pi;
       //---------------------------------------------------------
 
       f_CheckObj(p_uSpaceQual: '*USRSPC');
 
       // check for system domain errors CPF3C48
       callp QUSPTRUS(p_uSpaceQual: uSpacePtr: ApiErrDS);
 
 1b    if ApiErrDS.BytesReturned > 0;
          f_SndEscapeMsg(ApiErrDS.ErrMsgId + ': ' +
          %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal)));
 1e    endif;
 
       *inlr = *on;
       return;
