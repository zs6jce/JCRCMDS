       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRRFILV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define f_IsValidSrcType
       /define f_SndEscapeMsg
       // *ENTRY
       /define p_JCRRFILR
       /COPY JCRCMDS,JCRCMDSCPY
 
       //-----------------------------------------------------
 1b    if not f_IsValidSrcType(p_SrcFilQual: p_SrcMbr: 'RPGLE':'SQLRPGLE');
          f_SndEscapeMsg('Member ' + %trimr(p_SrcMbr) +
          ' is not type RPGLE or SQLRPGLE.');
 1e    endif;
 
       *inlr = *on;
       return;
