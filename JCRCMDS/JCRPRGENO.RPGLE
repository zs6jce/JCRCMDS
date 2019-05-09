       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRPRGENO - prompt override program
       //  return command prompt override string for program source lib/file/mbr
       //---------------------------------------------------------
       /define ControlStatements
       /define f_PromptOverrideGetSource
       /COPY JCRCMDS,JCRCMDSCPY
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_CmdQual char(20);
        filler1 char(10);
        filler2 char(20);
        p_PgmQual char(20);
        p_RtnString char(5700);
       end-pi;
       //---------------------------------------------------------
 
       p_RtnString = f_PromptOverrideGetSource(p_PgmQual);
       *inlr = *on;
       return;
