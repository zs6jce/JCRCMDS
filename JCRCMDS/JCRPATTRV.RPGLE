       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRPATTRV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckMbr
       /define f_CheckObj
       // *ENTRY
       /define p_JCRPATTRR
       /COPY JCRCMDS,JCRCMDSCPY
 
       //---------------------------------------------------------
       f_CheckMbr(p_SrcFilQual: p_SrcMbr);
 
       //---------------------------------------------------------
 1b    if p_CrtToLib = '*SRCLIB';
          p_CrtToLib = %subst(p_SrcFilQual: 11: 10);
 1e    endif;
       f_CheckObj(p_CrtToLib + '*LIBL': '*LIB');
 
       //---------------------------------------------------------
 1b    if %subst(p_LikePrtf: 1: 10) = '*SRCMBR';
          %subst(p_LikePrtf: 1: 10) = p_SrcMbr;
 1e    endif;
 
 1b    if %subst(p_LikePrtf: 11: 10) = '*SRCLIB';
          %subst(p_LikePrtf: 11: 10) = %subst(p_SrcFilQual: 11: 10);
 1e    endif;
 
       f_CheckObj(p_LikePrtf: '*FILE');
       *inlr = *on;
       return;
