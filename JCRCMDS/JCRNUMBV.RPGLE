       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRNUMBV - Validity checking program with allocate object
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckMbr
       /define ApiErrDS
       /define f_GetQual
       /define f_SndEscapeMsg
       /define f_RunCmd
       /COPY JCRCMDS,JCRCMDSCPY
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_Mbr char(10);
        p_FileQual char(20);
       end-pi;
       //---------------------------------------------------------
 
       //---------------------------------------------------------
       f_CheckMbr(p_FileQual: p_Mbr);
 
       // see if source mbr can be allocated, if not send err msg
       f_RunCmd('ALCOBJ OBJ((' + f_GetQual(p_FileQual) +
       ' *FILE *EXCLRD ' + %trimr(p_Mbr) + ')) WAIT(1)');
 
 1b    if ApiErrDS.BytesReturned > 0;
          f_SndEscapeMsg('Cannot allocate member ' +
          %trimr(p_Mbr) + ' in source file ' +
          f_GetQual(p_FileQual));
 1e    endif;
 
       f_RunCmd('DLCOBJ OBJ((' + f_GetQual(p_FileQual) +
       ' *FILE *EXCLRD ' + %trimr(p_Mbr) + '))');
 
       *inlr = *on;
       return;
