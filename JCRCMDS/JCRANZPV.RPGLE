       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRANZPV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define f_IsValidSrcType
       /define f_SndEscapeMsg
       /COPY JCRCMDS,JCRCMDSCPY
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_SrcMbr char(10);
        p_SrcFilQual char(20);
        p_ShowNames char(4);
        p_Output char(8);
       end-pi;
       //---------------------------------------------------------
 
 1b    if not f_IsValidSrcType(p_SrcFilQual: p_SrcMbr: 'PRTF');
          f_SndEscapeMsg('Member ' + %trimr(p_SrcMbr) +
          ' is not type PRTF.');
 1e    endif;
       *inlr = *on;
       return;
