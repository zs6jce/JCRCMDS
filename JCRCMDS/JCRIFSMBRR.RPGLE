       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRIFSMBRR - Copy source member to IFS (with option to zip)
       // Build copy to stream file command to download members to my IFS directory.
       //
       // Set up a PDM option to be CALL JCRIFSMBRR PARM(&N &F &L &S '/my_directory/')
       // then to execute, place that PDM option beside any member.
       // Replace '/my_directory/ with actual IFS drive folder.
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       // apparently the only sure way to know the file ccsid is to open it
       //  then check the ccsid of the File Information Data Structure
       dcl-f MBRSRC disk(112) extfile(extifile) extmbr(p_SrcMbr) usropn
       infds(infds);
 
 
       /define f_GetQual
       /define ApiErrDS
       /define Constants
       /define Infds
       /define f_BuildString
       /define f_RunCmd
       /define f_SndCompMsg
       /define f_ZipIFS
       /define f_SndEscapeMsg
       // *ENTRY
       /define p_JCRIFSMBRR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s dbfccsid char(12);
 
       //---------------------------------------------------------
       // if Coded character set identifier = 65535  (returned as -1 in infds)
       //  (note this is hex format and will not copy)
       //    change ccsid to 37. (other coutries may need to change this)
       //---------------------------------------------------------
       dbfccsid = *blanks;
       extIfile = f_GetQual(p_SrcFile + p_SrcLib);
       open MBRSRC;
 1b    if InfdsCcsid = -1;   // 65535 go figure
          dbfccsid = 'DBFCCSID(37)';
 1e    endif;
       close MBRSRC;
 
       //---------------------------------------------------------
       p_SrcMbr = %xlate(up: lo: p_SrcMbr);
       p_SrcFile = %xlate(up: lo: p_SrcFile);
       p_SrcLib = %xlate(up: lo: p_SrcLib);
       p_SrcAttr = %xlate(up: lo: p_SrcAttr);
       p_IfsDir = %xlate(up: lo: p_IfsDir);
       ApiErrDS.ErrMsgId = *blanks;
 
       //---------------------------------------------------------
       // copy to stream file command
       f_RunCmd(f_BuildString(
       'CPYTOSTMF FROMMBR(&Q/qsys.lib/&.lib/&.file/&.mbr&Q) +
       TOSTMF(&Q&&.&&Q) STMFOPT(*REPLACE) & STMFCODPAG(*PCASCII)':
       p_SrcLib: p_SrcFile: p_SrcMbr: p_IfsDir: p_SrcMbr: p_SrcAttr:
       dbfccsid));
 
 1b    if ApiErrDS.ErrMsgId > *blanks;  //error occurred
          f_SndEscapeMsg(ApiErrDS.ErrMsgId + ': Object Not Copied');
 1e    endif;
 
       // grant authority to IFS file
       f_RunCmd(f_BuildString(
       'CHGAUT OBJ(&Q&&.&&Q) USER(*PUBLIC) DTAAUT(*RWX)':
       p_IfsDir: p_SrcMbr: p_SrcAttr));
 
       //-------------------------------------------------
 1b    if p_CreateZip = '*YES';
          f_ZipIFS(p_SrcMbr: p_SrcAttr: p_IfsDir);
 1e    endif;
 
       f_SndCompMsg(
       f_BuildString('Member &.& copy to IFS directory & - completed':
       %xlate(lo: up: p_SrcMbr): p_SrcAttr: p_IfsDir));
 
       *inlr = *on;
       return;
