       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRVALOBJV - Validity checking program for lib/obj/type
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckObj
       /COPY JCRCMDS,JCRCMDSCPY
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_ObjQual char(20);
        p_ObjTyp char(10);
       end-pi;
       //---------------------------------------------------------
 
       f_CheckObj(p_ObjQual: p_ObjTyp);
       *inlr = *on;
       return;
