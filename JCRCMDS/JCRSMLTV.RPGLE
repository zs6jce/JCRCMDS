       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRSMLTV - Validity checking program for list elements
       //  If the file name starts with *, then read and check the
       //  pre-defined file groups and short cuts in JCRSMLTCHF.
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckMbr
       /define f_CheckObj
       /define f_SndEscapeMsg
       /define f_OutFileCrtDupObj
       // *ENTRY
       /define p_JCRSMLTRS
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRSMLTCHF keyed usropn;
 
       dcl-s OffsetToNext int(5) based(DisplacePtr);
       dcl-s NumOfLists int(5) based(p_SrcFilesPtr);
       dcl-s ForCount uns(3);
       dcl-s PredefinedKey like(ChoiceKey);
 
       // Get number of source files and source file/lib/Mbr names
       dcl-ds InnerList based(InnerListPtr) qualified;
        SrcFil char(10) pos(3);
        SrcLib char(10) pos(13);
       end-ds;
 
       //---------------------------------------------------------
       // Use pointers to overlay input parms with DS values.
       //  Spin down number of offsets to list entries.
       //   Inner list pointer (start of list + OffsetToNext)
       //     moves DS through list.
       //---------------------------------------------------------
       p_SrcFilesPtr = %addr(p_SrcFiles);
       DisplacePtr = p_SrcFilesPtr;
 
 1b    if NumOfLists = 0;
          f_SndEscapeMsg('*Must select at least one SOURCE FILE.');
 1e    endif;
 
 1b    for ForCount = 1 to NumOfLists;
          DisplacePtr += 2;
          InnerListPtr = p_SrcFilesPtr + OffsetToNext;
 2b       if not(%subst(InnerList.SrcFil: 1: 1) = '*');
             f_CheckMbr(InnerList.SrcFil + InnerList.SrcLib:'*FIRST');
 2x       else;
             exsr srCheckPreDefinedFiles;
 2e       endif;
 1e    endfor;
 
       // Check OUTFILE parameter
 1b    if p_Output = '*OUTFILE';
          f_OutFileCrtDupObj(p_OutFileQual: p_OutMbrOpt: 'JCRSMLTF');
 
 1x    elseif p_Output = '*PRINT';
 2b       if not(%subst(p_OutqQual:1:1) = '*');
 3b          if %subst(p_OutqQual:11) = *blanks;
                %subst(p_OutqQual:11) = '*LIBL';
 3e          endif;
             f_CheckObj(p_OutqQual: '*OUTQ');
 2e       endif;
 1e    endif;
 
       *inlr = *on;
       return;
 
       //------------------------------------------
       begsr srCheckPreDefinedFiles;
       open JCRSMLTCHF;
 
       PredefinedKey = %subst(InnerList.SrcFil: 1: 10);
       setll PreDefinedKey JCRSMLTCHR;
 1b    if not %equal;
          f_SndEscapeMsg('Predefined key ' +
          %trimr(PreDefinedKey) + ' not in file JCRSMLTCHF.');
 1x    else;
 
          reade PredefinedKey JCRSMLTCHR;
 2b       dow not %eof;
             f_CheckObj(ChoiceFil + ChoiceLib:'*FILE');
             reade PredefinedKey JCRSMLTCHR;
 2e       enddo;
 1e    endif;
 
       close JCRSMLTCHF;
       endsr;
