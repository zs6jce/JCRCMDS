       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRPROTOV - Validity checking program
       //   note do not allow replacement of existing member
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckMbr
       /define f_CheckObj
       /define f_IsSameMbr
       /define f_SndEscapeMsg
       /define f_SrcFileAddPfm
       /define f_IsValidMbr
       /define f_GetQual
       // *ENTRY
       /define p_JCRPROTOR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s InLib char(10);
 
       //---------------------------------------------------------
       f_CheckMbr(p_InFileQual: p_InMbr);
       f_CheckObj(p_OutFileQual: '*FILE');
 
 1b    if f_IsSameMbr(p_InFileQual: p_InMbr: p_OutFileQual: p_OutMbr);
          f_SndEscapeMsg('Input file.lib.mbr cannot +
          be same as New file.lib.mbr name.');
 1e    endif;
 
 1b    if f_IsValidMbr(p_OutFileQual: p_OutMbr);
          f_SndEscapeMsg('Cannot replace existing member ' +
          %trimr(p_OutMbr) + ' in source file ' +
          f_GetQual(p_OutFileQual));
 1e    endif;
 
       f_SrcFileAddPfm(p_OutFileQual: p_OutMbr: ' ': ' ':
       p_InFileQual: p_InMbr);
 
       *inlr = *on;
       return;
