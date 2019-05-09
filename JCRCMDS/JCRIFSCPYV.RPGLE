       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRIFSCPYV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckDir
       // *ENTRY
       /define p_JCRIFSCPYR
       /COPY JCRCMDS,JCRCMDSCPY
 
       f_CheckDir(p_IfsDir);
       *inlr = *on;
       return;
