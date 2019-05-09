       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRNOTPOPV - Validity checking program for lib/file/member
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckMbr
       /COPY JCRCMDS,JCRCMDSCPY
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_FileQual char(20);
        p_Mbr char(10);
       end-pi;
       //---------------------------------------------------------
 
       f_CheckMbr(p_FileQual: p_Mbr);
       *inlr = *on;
       return;
