       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRNETFFV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckMbr
       /define f_CheckObj
       /define f_SndEscapeMsg
       // *ENTRY
       /define p_JCRNETFFR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s xx uns(3);
 
 1b    if not(p_Lib = '*LIBL');
          f_CheckObj(p_Lib + '*LIBL': '*LIB');
 1e    endif;
 
 1b    if p_UsrList.Count = 0;
          f_SndEscapeMsg('Must select at least one TOUSRID.');
 1e    endif;
 
 1b    if p_FileList.Count = 0;
          f_SndEscapeMsg('Must select at least one FILE NAME.');
 1x    else;
 
 2b       for xx = 1 to p_FileList.Count;
 3b          if %scan('*':p_FileList.Arry(xx)) = 0; // skip generics
                f_CheckMbr(p_FileList.Arry(xx) + p_Lib: '*FIRST');
 3e          endif;
 2e       endfor;
 1e    endif;
 
       *inlr = *on;
       return;
