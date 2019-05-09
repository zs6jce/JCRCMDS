       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRFFDV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckMbr
       /define f_CheckObj
       /define f_GetFileLevelID
       /define f_OutFileCrtDupObj
       // *ENTRY
       /define p_JCRFFDR
       /COPY JCRCMDS,JCRCMDSCPY
       dcl-s levelid char(13);
 
       //---------------------------------------------------------
 1b    if not(%subst(p_FileQual: 11: 10) = '*LIBL');
          f_CheckObj(%subst(p_FileQual: 11: 10) + 'QSYS': '*LIB');
 1e    endif;
 
       // if invalid record format, function throws an exception message
       LevelID = f_GetFileLevelID(p_FileQual: p_RcdFmt);
 
 1b    if p_Output = '*SRC';
          f_CheckMbr(p_OutFileQual: %subst(p_OutMbrOpt: 3: 10));
 
 1x    elseif p_Output = '*OUTFILE';
          f_OutFileCrtDupObj(p_OutFileQual: p_OutMbrOpt: 'JCRFFDF');
 1e    endif;
 
       *inlr = *on;
       return;
