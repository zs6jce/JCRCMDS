       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRVALLIBV - Validity checking program for library name
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckObj
       /COPY JCRCMDS,JCRCMDSCPY
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_ObjQual char(20);
       end-pi;
       //---------------------------------------------------------
 
 1b    if not(%subst(p_ObjQual: 11: 1) = '*');
          f_CheckObj(%subst(p_ObjQual:11:10)+'QSYS':'*LIB');
 1e    endif;
 
       *inlr = *on;
       return;
