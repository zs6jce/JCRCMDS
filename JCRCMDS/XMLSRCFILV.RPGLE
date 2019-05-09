       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // XMLSRCFILV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckMbr
       /define f_CheckObj
       // *ENTRY
       /define p_XMLSRCFILR
       /COPY JCRCMDS,JCRCMDSCPY
 
       f_CheckMbr(p_InFileQual: '*FIRST');
       f_CheckObj(p_OutFileQual: '*FILE');
       *inlr = *on;
       return;
