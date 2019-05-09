       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRIFSSAVR - Copy savf to to IFS (with optional zip)
       //  Build copy to stream file command to download savf to IFS directory.
       //---------------------------------------------------------
       /define ControlStatements
       /define Constants
       /define f_RunCmd
       /define f_BuildString
       /define f_SndCompMsg
       /define f_ZipIFS
       // *ENTRY
       /define p_JCRIFSSAVR
       /COPY JCRCMDS,JCRCMDSCPY
       dcl-s filetype char(10) inz('savf');
 
       //---------------------------------------------------------
       p_Savf = %xlate(up: lo: p_Savf);
       p_Lib = %xlate(up: lo: p_Lib);
       p_IfsDir = %xlate(up: lo: p_IfsDir);
 
       f_RunCmd(f_BuildString(
       'CPYTOSTMF FROMMBR(&Q/qsys.lib/&.lib/&.file&Q) TOSTMF(&Q&&&Q) +
       STMFOPT(*REPLACE) CVTDTA(*NONE) STMFCODPAG(*STMF) +
       ENDLINFMT(*FIXED)': p_Lib: p_Savf:p_IfsDir: %trimr(p_Savf)+'.savf'));
 
       //---------------------------------------------------------
       // grant authority to IFS file
       f_RunCmd(f_BuildString(
       'CHGAUT OBJ(&Q&&.&&Q) USER(*PUBLIC) DTAAUT(*RWX)':
       p_IfsDir: p_Savf: filetype));
 
       //---------------------------------------------------------
 1b    if p_CreateZip = '*YES';
         f_ZipIFS(p_Savf: filetype: p_IfsDir);
 1e    endif;
 
       f_SndCompMsg(
       f_BuildString('Savf & copy to IFS directory & - completed':
       %xlate(lo: up: p_Savf): p_IfsDir));
 
       *inlr = *on;
       return;
