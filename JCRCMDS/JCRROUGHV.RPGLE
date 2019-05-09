       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRROUGHV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckObj
       /define f_IsValidMbr
       /define f_SrcFileAddPfm
       /COPY JCRCMDS,JCRCMDSCPY
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_DdsMbr char(10);
        p_DdsFileQual char(20);
        p_CpySplfPFQual char(20);
       end-pi;
       //---------------------------------------------------------
 
       f_CheckObj(p_CpySplfPFQual: '*FILE');
       f_CheckObj(p_DdsFileQual: '*FILE');
 
 1b    if not f_IsValidMbr(p_DdsFileQual: p_DdsMbr);
          f_SrcFileAddPfm(p_DdsFileQual: p_DdsMbr: 'PRTF': 'jcrrough');
 1e    endif;
 
       *inlr = *on;
       return;
