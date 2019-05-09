       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRRFLDV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckMbr
       /define f_OutFileCrtDupObj
       // *ENTRY
       /define p_JCRRFLDR
       /COPY JCRCMDS,JCRCMDSCPY
 
       //---------------------------------------------------------
       f_CheckMbr(p_SrcFilQual: p_SrcMbr);
 
 1b    if p_Output = '*OUTFILE';
          f_OutFileCrtDupObj(p_OutFileQual: p_OutMbrOpt: 'JCRRFLDF');
 1e    endif;
 
       *inlr = *on;
       return;
