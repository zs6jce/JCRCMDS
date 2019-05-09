       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRBNDV - Validity checking program with create outfile
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckObj
       /define f_OutFileCrtDupObj
       // *ENTRY
       /define p_JCRBNDR
       /COPY JCRCMDS,JCRCMDSCPY
 
       //---------------------------------------------------------
       f_CheckObj(p_ObjQual: p_ObjTyp);
 
 1b    if p_Output = '*OUTFILE';
          f_OutFileCrtDupObj(p_OutFileQual: p_OutMbrOpt: 'JCRBNDF');
 1e    endif;
 
       *inlr = *on;
       return;
