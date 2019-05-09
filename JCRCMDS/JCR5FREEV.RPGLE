       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCR5FREEV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckObj
       /define f_IsSameMbr
       /define f_IsValidSrcType
       /define f_SndEscapeMsg
       /define f_SrcFileAddPfm
       // *ENTRY
       /define p_JCR5FREER
       /COPY JCRCMDS,JCRCMDSCPY
       dcl-s InLib char(10);
 
       //---------------------------------------------------------
 1b    if not f_IsValidSrcType(p_InFileQual: p_InMbr:'RPGLE':'SQLRPGLE');
          f_SndEscapeMsg('Member ' + %trimr(p_InMbr) +
          ' is not type RPGLE or SQLRPGLE.');
 1e    endif;
 
       f_CheckObj(p_OutFileQual: '*FILE');
 
 1b    if f_IsSameMbr(p_InFileQual: p_InMbr: p_OutFileQual: p_OutMbr);
          f_SndEscapeMsg('RPG4 file/lib/mbr cannot +
          be same as Free file/lib/mbr name.');
 1e    endif;
 
       f_SrcFileAddPfm(p_OutFileQual: p_OutMbr: ' ': ' ':
       p_InFileQual: p_InMbr);
 
       *inlr = *on;
       return;
