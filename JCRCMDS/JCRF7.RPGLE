       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRF7 - seu exit program - split/combine lines.
       // To activate for your seu sessions.
       //  1. strpdm and edit source member.
       //   2. Press F13 to Change Session Defaults.
       //    3. Page down then change
       //     User exit program  JCRF7______  *REGFAC, *NONE, Name
       //         Library. . .   mylib___    Name
       //              (mylib=your jcrcmds library name)
       //---------------------------------------------------------
       // Program Summary:
       // If cursor is on line with data past cursor position,
       //    press F7 to split line into two lines.
 
       // If cursor is on line with no data past cursor position,
       //    press F7 to combine current and next line.
 
       //  Combining lines will not delete second line.
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos)
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-ds HeadDS based(pHeadPtr) qualified;
        RecLen int(10) pos(1);
        CursorPos int(10) pos(9);
        F7Key char(1) pos(61);
       end-ds;
 
       dcl-s SrcLines char(282) based(pSrcLinesPtr);
       dcl-s line1 char(120);
       dcl-s line2 char(120);
       dcl-s xx uns(3);
 
       dcl-ds ReturnDS based(pReturnPtr) qualified;
        Code char(1) pos(1);
        Rec int(10) pos(5);
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        pHeadPtr pointer;
        pReturnPtr pointer;
        pSrcLinesPtr pointer;
       end-pi;
       //---------------------------------------------------------
 
 1b    if HeadDS.F7Key = '7' and HeadDS.CursorPos > 0;
          line1 = %subst(SrcLines:21: HeadDS.RecLen);
          line2 = %subst(SrcLines: HeadDS.RecLen+41: HeadDS.RecLen);
 
 2b       if %subst(line1: HeadDS.CursorPos) > *blanks;
             exsr srSplitLine;
 2x       else;
             exsr srMergeLine;
 2e       endif;
 
          %subst(SrcLines: 21) = line1;
          %subst(SrcLines: HeadDS.RecLen+41: HeadDS.RecLen) = line2;
          ReturnDS.Code = *off;
 1e    endif;
 
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       // SPLIT LINE
       // if position 6 is equal blanks, assume in /free zone and align
       // split line up with 1st character after 6.
       // if position 6 > *blanks, drop straight down to next line.
       //---------------------------------------------------------
       begsr srSplitLine;
 
 1b    if %subst(line1: 6: 1) = *blanks;  //assume free
          //find 1st character on top statement to
          //line up split code
          xx = %check(' ': line1: 7);
 2b       if xx = 0;
             xx = 8;
 2e       endif;
 1x    else;  //not free
          xx = HeadDS.CursorPos;
 1e    endif;
 
       line2 = *blanks;
       %subst(line2: xx) = %subst(line1: HeadDS.CursorPos);
 1b    if HeadDS.CursorPos = 1;
          line1 = *blanks;
 1x    else;
          line1 = %subst(line1: 1: HeadDS.CursorPos - 1);
 1e    endif;
       ReturnDS.Rec = 2;
       endsr;
 
       //---------------------------------------------------------
       // Merge line at cursor
       //---------------------------------------------------------
       begsr srMergeLine;
 
       %subst(line1: HeadDS.CursorPos) = %triml(line2);
 1b    if HeadDS.CursorPos = 1;
          line2 = *blanks;
 1x    else;
          line2 = %subst(line2: %len(line2) - (HeadDS.CursorPos - 2));
 1e    endif;
 
       ReturnDS.Rec = 1;
 1b    if line2 > *blanks;
          ReturnDS.Rec = 2;
 1e    endif;
       endsr;
