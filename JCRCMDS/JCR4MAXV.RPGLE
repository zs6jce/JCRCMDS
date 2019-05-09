       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCR4MAXV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define f_GetQual
       /define f_SndEscapeMsg
       /define f_RunCmd
       /define f_IsValidSrcType
       /COPY JCRCMDS,JCRCMDSCPY
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_SrcMbr char(10);
        p_SrcFilQual char(20);
        p_Style char(12);
       end-pi;
       //---------------------------------------------------------
 
 1b    if not f_IsValidSrcType(p_SrcFilQual: p_SrcMbr:'RPGLE':'SQLRPGLE');
          f_SndEscapeMsg('Member ' + %trimr(p_SrcMbr) +
          ' is not type RPGLE or SQLRPGLE.');
 1e    endif;
 
       // see if source mbr can be allocated, if not send err msg
       f_RunCmd('ALCOBJ OBJ((' + f_GetQual(p_SrcFilQual) +
       ' *FILE *EXCLRD ' + %trimr(p_SrcMbr) + ')) WAIT(1)');
 
 1b    if ApiErrDS.BytesReturned > 0;
          f_SndEscapeMsg('Cannot allocate member ' +
          %trimr(p_SrcMbr) + ' in source file ' +
          f_GetQual(p_SrcFilQual));
 1e    endif;
 
       f_RunCmd('DLCOBJ OBJ((' + f_GetQual(p_SrcFilQual) +
       ' *FILE *EXCLRD ' + %trimr(p_SrcMbr) + '))');
       *inlr = *on;
       return;
