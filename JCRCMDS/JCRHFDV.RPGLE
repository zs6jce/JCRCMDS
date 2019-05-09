       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRHFDV - Validity checking program for lib/file/member
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckObj
       /define f_IsValidSrcType
       /define f_IsSameMbr
       /define f_SrcFileAddPfm
       /define f_SndEscapeMsg
       // *ENTRY
       /define p_JCRHFDR
       /COPY JCRCMDS,JCRCMDSCPY
 
       //---------------------------------------------------------
 1b    if not f_IsValidSrcType(p_InFileQual: p_InMbr: 'RPGLE': 'SQLRPGLE');
          f_SndEscapeMsg('Member ' + %trimr(p_InMbr) +
          ' is not type RPGLE or SQLRPGLE.');
 1e    endif;
 
       f_CheckObj(p_OutFileQual: '*FILE');
 
 1b    if f_IsSameMbr(p_InFileQual: p_InMbr: p_OutFileQual: p_OutMbr);
          f_SndEscapeMsg('Input file/lib/mbr cannot +
          be same as New file/lib/mbr name.');
 1e    endif;
 
       f_SrcFileAddPfm(p_OutFileQual: p_OutMbr: ' ': ' ':
       p_InFileQual: p_InMbr);
 
       *inlr = *on;
       return;
