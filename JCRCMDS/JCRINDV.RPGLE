       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRINDV - Validity checking program for lib/file/member
       //--------------------------------------------------------
       /define ControlStatements
       /define f_CheckMbr
       // *ENTRY
       /define p_JCRINDR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s ForCount uns(3);
       dcl-s OffsetToNext int(5) based(displaceptr);
       dcl-s NumOfLists int(5) based(parmptr);
 
       // overlay source file/lib/mbr names
       dcl-ds MbrList based(MbrListPtr) qualified;
        SrcMbr char(10) pos(3);
        SrcFilQual char(20);
       end-ds;
 
       //---------------------------------------------------------
       // Use pointer to overlay input parm with data structure.
       // Spin down number of offsets to list entries.
       // MbrListPtr (start of list + OffsetToNext) moves DS through the list.
       //---------------------------------------------------------
       ParmPtr = %addr(p_SrcMbrs);
       DisplacePtr = ParmPtr;
 
 1b    for ForCount = 1 to NumOfLists;
          DisplacePtr += 2;
          MbrListPtr = ParmPtr + OffsetToNext;
          f_CheckMbr(MbrList.SrcFilQual: MbrList.SrcMbr);
 1e    endfor;
 
       *inlr = *on;
       return;
