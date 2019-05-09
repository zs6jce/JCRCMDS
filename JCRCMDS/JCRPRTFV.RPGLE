       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRPRTFV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckObj
       /define f_IsValidSrcType
       /define f_IsSameMbr
       /define f_SrcFileAddPfm
       /define f_SndEscapeMsg
       // *ENTRY
       /define p_JCRPRTFR
       /COPY JCRCMDS,JCRCMDSCPY
 
       //---------------------------------------------------------
 1b    if not f_IsValidSrcType(p_RpgFileQual: p_RpgMbr:'RPGLE':'SQLRPGLE');
          f_SndEscapeMsg('Member ' + %trimr(p_RpgMbr) +
          ' is not type RPGLE or SQLRPGLE.');
 1e    endif;
 
       f_CheckObj(p_DDsFileQual: '*FILE');
 
 1b    if f_IsSameMbr(p_RpgFileQual: p_RpgMbr: p_DDsFileQual: p_DDsMbr);
          f_SndEscapeMsg('RPGLE file/lib/mbr cannot +
          be same as DDS file/lib/mbr name.');
 1e    endif;
 
       f_SrcFileAddPfm(p_DDsFileQual: p_DDsMbr: 'PRTF':
       'PRTF for ' + p_RpgMbr);
 
       *inlr = *on;
       return;
