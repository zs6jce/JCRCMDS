       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRIFSMBRV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckMbr
       /define f_CheckDir
       // *ENTRY
       /define p_JCRIFSMBRR
       /COPY JCRCMDS,JCRCMDSCPY
 
       f_CheckMbr(p_SrcFile + p_SrcLib: p_SrcMbr);
       f_CheckDir(p_IfsDir);
 
       *inlr = *on;
       return;
