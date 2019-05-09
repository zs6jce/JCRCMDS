       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRUSPACER - User space data display
       //  27x132 display size is required to use this utility.
       //   Search is case sensitive.
       // If large user space size, search function could take a few moments
       // as each BYTE in the user space must be scanned.
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCRUSPACED workstn sfile(sbfdta1: rrn) infds(infds)
       sfile(sbfdta2: rrn2) indds(ind);
 
       /define ApiErrDS
       /define Constants
       /define Cvthc
       /define Infds
       /define Dspatr
       /define Sds
       /define FunctionKeys
       /define Ind
       /define Qusptrus
       /define Qusrusat
       /define f_GetDayName
       /define f_RmvSflMsg
       /define f_SndSflMsg
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s ByteFromSpace char(1) based(Ptr1);
       dcl-s ByteToSubfile char(1) based(Ptr2);
       dcl-s SpaceString char(40) based(SearchPtr);
       dcl-s DeepInSpace int(10) inz(1);
       dcl-s LastFoundCnt int(10);
       dcl-s SaveDeep int(10) inz(1);
       dcl-s RcdsToWrite uns(3) inz(1);
       dcl-s rrnsav like(rrn);
       dcl-s rrn2 like(rrn);
       dcl-s SflPag uns(3) inz(21);
       dcl-s WriteCount uns(3) inz(1);
       dcl-s SavePtr1 pointer inz(*null);
       dcl-s uSpacePtr pointer inz(*null);
       dcl-s IsFound ind;
       dcl-s IsLastScan ind;
 
       dcl-ds HexVal qualified;
        TopRowHex char(1);
        BotRowHex char(1);
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_uSpaceQual char(20);
       end-pi;
       //---------------------------------------------------------
 
       f_RmvSflMsg(ProgId);
       scDow = f_GetDayName();
 
       // Get pointer to user space
       callp QUSPTRUS(p_uSpaceQual: uSpacePtr: ApiErrDS);
       Ptr1 = uSpacePtr;
 
       // Get user space size so do not move pointer past that point
       callp QUSRUSAT(
             QusrusatDS:
             %size(QusrusatDS):
             'SPCA0100':
             p_uSpaceQual:
             ApiErrDS);
 
       scSpace = %subst(p_uSpaceQual: 1: 10);
       scLib = QusrusatDS.SpaceLibrary;
       scSize = QusrusatDS.SpaceSize;
       SflRcdNbr = 1;
       exsr srLoadSubfilePage;
 
       //---------------------------------------------------------
 1b    dou 1 = 2;
          Ind.sfldsp = (rrn > 0);
          Ind.sfldspctl = *on;
          write msgctl;
          write sfooter1;
          exfmt sbfctl1;
          f_RmvSflMsg(ProgId);
 
 2b       if InfdsFkey = f03 or InfdsFkey = f12;
             *inlr = *on;
             return;
 
             //---------------------------------------------------------
             // fPageUp and fPageDown are controlled by offset of 1st subfile record.
             // To fPageDown add SflPag*100 to offset & start loading.
             // To fPageUp sub SflPag*100 from offset & continue.
             //---------------------------------------------------------
 2x       elseif InfdsFkey = fPageDown;
             chain 1 sbfdta1;
             DeepInSpace = sbfOffset + (SflPag/RcdsToWrite*100);
             Ptr1 = uSpacePtr + (DeepInSpace - 1);
             exsr srLoadSubfilePage;
 
 2x       elseif InfdsFkey = fPageUp;
             chain 1 sbfdta1;
             DeepInSpace = sbfOffset - (SflPag/RcdsToWrite * 100);
 3b          if DeepInSpace < 1;
                DeepInSpace = 1;
 3e          endif;
             Ptr1 = uSpacePtr + (DeepInSpace - 1);
             exsr srLoadSubfilePage;
 
             //---------------------------------------------------------
             // Show subfile of individual characters at cursor location
             //---------------------------------------------------------
 2x       elseif InfdsFkey = f04;
             Ind.sfldsp2 = *off;
             Ind.sfldspctl2 = *off;
             rrn2 = 0;
             write sbfctl2;
             write sfooter2;
             rrnsav = rrn;  //save 1st subfile rrn
 
             CsrRRN = (CsrRRN - 1) / RcdsToWrite;
             CsrRRN = (CsrRRN * RcdsToWrite) + 1;
             chain csrRrn sbfdta1;
 3b          if %found;
                SflRcdNbr = rrn;
                sbfOffset2 = sbfOffset;
 4b             for aa = 1 to 100;
                   sbfRecChar = %subst(sbfRecData: aa: 1);
                   rrn2 += 1;
                   write sbfdta2;
                   sbfOffset2 += 1;
 4e             endfor;
 3e          endif;
             Ind.sfldsp2 = (rrn2 > 0);
             Ind.sfldspctl2 = *on;
             exfmt sbfctl2;
             rrn = rrnsav;  //restore subfile rrn
 
             //---------------------------------------------------------
 2x       elseif InfdsFkey = f08;
             DeepInSpace = sbfOffset + 100 - (SflPag/RcdsToWrite * 100);
 3b          if DeepInSpace < 1;
                DeepInSpace = 1;
 3e          endif;
             Ptr1 = uSpacePtr + (DeepInSpace - 1);
 3b          if RcdsToWrite = 1;
                RcdsToWrite = 3;
 3x          else;
                RcdsToWrite = 1;
 3e          endif;
             exsr srLoadSubfilePage;
 
             //---------------------------------------------------------
             // F16 = continue search from last instances was found
             //---------------------------------------------------------
 2x       elseif InfdsFkey = F16;
 3b          if scsearch > *blanks;
                DeepInSpace = LastFoundCnt + 1;
                SearchPtr = uSpacePtr + LastFoundCnt;
                exsr srFindSearchString;
 4b             if IsFound;
                   exsr srLoadSubfilePage;
 4x             else;
                   f_SndSflMsg(ProgId:
                   'Search string not found again in user space');
 4e             endif;
 3e          endif;
 2x       else;
             //---------------------------------------------------------
             // If ENTER was pressed
             //---------------------------------------------------------
 3b          if scPosTo > 0;
 4b             if scPosTo > scsize;  // avoid Ptr error!
                   f_SndSflMsg(ProgId:
                   'Position To is past end of space size');
 4x             else;
                   //---------------------------------------------------------
                   // Load a full subfile record starting at that position
                   //---------------------------------------------------------
                   DeepInSpace = scPosTo;
                   Ptr1 = uSpacePtr + (DeepInSpace - 1);
                   exsr srLoadSubfilePage;
 4e             endif;
 3x          else;
                //---------------------------------------------------------
                // Enter starts search from beginning of userspace, F16 continues search
                //---------------------------------------------------------
 4b             if scsearch > *blanks;
                   DeepInSpace = 1;
                   SearchPtr = uSpacePtr;
                   exsr srFindSearchString;
 5b                if IsFound;
                      exsr srLoadSubfilePage;
 5x                else;
                      f_SndSflMsg(ProgId:
                      'Search string not found in user space');
 5e                endif;
 4e             endif;
 3e          endif;
 2e       endif;
 1e    enddo;
 
       //---------------------------------------------------------
       // Load user space data to subfile records
       //---------------------------------------------------------
       begsr srLoadSubfilePage;
       WriteCount = 1;
       Ind.sfldsp = *off;
       Ind.sfldspctl = *off;
       rrn = 0;
       write sbfctl1;
 
 1b    dow (WriteCount <= SflPag)
          and DeepInSpace <= QusrusatDS.SpaceSize;
          SavePtr1 = Ptr1;
          SaveDeep = DeepInSpace;
 
 2b       for bb = 1 to RcdsToWrite;
             DeepInSpace = SaveDeep;
             Ptr2 = %addr(sbfRecData);
             clear sbfRecData;
 
 3b          for aa = 1 to 100;
 4b             if bb = 1;
                   ByteToSubfile = ByteFromSpace;
 4x             elseif bb = 2;
                   callp cvthc(%addr(HexVal):Ptr1:2);
                   ByteToSubfile = Hexval.TopRowHex;
 4x             else;
                   callp cvthc(%addr(HexVal):Ptr1:2);
                   ByteToSubfile = Hexval.BotRowHex;
 4e             endif;
 
 4b             if ByteToSubfile < x'40'
                   And ByteToSubfile > x'00';  //not displayable
                   ByteToSubfile = x'1F';
 4e             endif;
 4b             if ByteToSubfile = x'00';  //not displayable
                   ByteToSubfile = x'41';
 4e             endif;
 
                Ptr1 += 1;  //next space pointer
                Ptr2 += 1;  //next subfile data pointer
                DeepInSpace += 1;  //do not go too far
 4b             if DeepInSpace > QusrusatDS.SpaceSize;
                   DeepInSpace = sbfOffset + 200;
 3v                Leave;
 4e             endif;
 3e          endfor;
 
 3b          if not(bb = RcdsToWrite);
                Ptr1 = SavePtr1;
 3e          endif;
 
 3b          if not(bb = 1);
                aOffset = ND;
                aRecData = Green;
 3x          else;
                aOffset = Green;
                aRecData = White;
 3e          endif;
 
             // Load counter down side of subfile
             sbfOffset = DeepInSpace - 100;
             rrn += 1;
             write sbfdta1;
             WriteCount += 1;
 2e       endfor;
 1e    enddo;
 
       // position to subfile record
 1b    if rrn > 2;
          SflRcdNbr = rrn - 1;
 1x    else;
          SflRcdNbr = 1;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Use pointers to run down user space searching,
       // If match was found, set to full subfile record.
       //---------------------------------------------------------
       begsr srFindSearchString;
       IsFound = *off;
       IsLastScan = *off;
       LastFoundCnt = 0;
 1b    dow DeepInSpace < scsize;  //avoid Ptr error!
          aa = %scan(%trimr(scSearch): SpaceString: 1);
 2b       if aa > 0;
             IsFound = *on;
             DeepInSpace = DeepInSpace + aa - 1;
             LastFoundCnt = DeepInSpace;
             //---------------------------------------------------------
             Ptr1 = uSpacePtr + (DeepInSpace - 1);
 1v          leave;
 2e       endif;
 
 2b       if IsLastScan;
 1v          leave;
 2e       endif;
 
          SearchPtr = SearchPtr + %size(SpaceString) + 1
          - %len(%trimr(scSearch));
          DeepInSpace = DeepInSpace + %size(SpaceString) + 1
          - %len(%trimr(scSearch));
 
 2b       if DeepInSpace + %size(SpaceString) > Scsize;
             DeepInSpace = Scsize - %size(SpaceString) + 1;
             SearchPtr = uSpacePtr + DeepInSpace - 1;
             IsLastScan = *on;
 2e       endif;
 1e    enddo;
       endsr;
