       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRLSRCV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckObj
       /define f_OutFileCrtDupObj
       // *ENTRY
       /define p_JCRLSRCR
       /COPY JCRCMDS,JCRCMDSCPY
 
       //---------------------------------------------------------
 1b    if not(%subst(p_PgmQual: 11: 10) = '*LIBL');
          f_CheckObj(%subst(p_PgmQual: 11: 10) + 'QSYS': '*LIB');
 1e    endif;
 
 1b    if p_Output = '*OUTFILE';
          f_OutFileCrtDupObj(p_OutFileQual: p_OutMbrOpt: 'JCRLSRCF');
 1e    endif;
 
       *inlr = *on;
       return;
