       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRSMLTR - Scan mult source file/mbrs - scanner
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f MBRSRC disk(112) extfile(extifile) extmbr(rtvmbr) usropn
       infds(infds);
       dcl-ds InputDS;
        SrcSeq zoned(6:2) pos(1);
        SrcChgdat zoned(6) pos(7);
        SrcComment char(1) pos(19);
        SrcCommentFree char(2) pos(19);
        SrcDta char(100) pos(13);
       end-ds;
 
       dcl-f JCRSMLTF usage(*output) extfile(extofile) extmbr(extombr) usropn;
       dcl-f JCRSMLTP printer oflind(IsOverFlow) indds(ind) usropn;
       dcl-f JCRSMLTCHF keyed;
 
       /define ApiErrDS
       /define Constants
       /define Ind
       /define Infds
       /define Quslmbr
       /define f_BlankCommentsCL
       /define f_GetQual
       /define f_GetDayName
       /define f_Quscrtus
       /define f_OvrPrtf
       /define f_Dltovr
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s extOmbr char(10);
       dcl-s NumOfFiles uns(3);
       dcl-s NumOfScanValues uns(3);
       dcl-s ScanLen uns(3);
       dcl-s ToPosSave uns(3);
       dcl-s ToPos uns(3);
       dcl-s FromPos uns(3);
       dcl-s ScanRRN uns(10) dim(16000);
       dcl-s SaveRRN uns(10);
       dcl-s CurrentRRN uns(10);
       dcl-s OffsetToNext int(5) based(displaceptr);
       dcl-s RtvMbr char(10);
       dcl-s SrcCase like(srcdta);
       dcl-s SrcListPtr pointer inz(*null);
       dcl-s IsAllFound ind;
       dcl-s IsNoneFound ind;
       dcl-s IsSomeFound ind;
       dcl-s IsFoundArry ind dim(10);
       dcl-s yy uns(5);
       dcl-s ScanVals varchar(25) dim(10) based(parsevaluesptr);
       dcl-s PredefinedKey like(ChoiceKey);
 
       // Get number of source files and source file/lib/mbr names
       dcl-ds InnerList based(InnerListPtr);
        SrcFil char(10) pos(3);
        SrcLib char(10) pos(13);
        SrcMbr char(10) pos(23);
        SrcMbrTyp char(10) pos(33);
       end-ds;
 
       dcl-ds LdaDS DTAARA(*usrctl: *LDA) qualified;
        SrcFiles char(398);
        ScanStrings char(272);
        Case char(4);
        IfContains char(7);
        Listlvl char(6);
        ScanComment char(5);
        From uns(3);
        To uns(3);
        Output char(8);
        OutqQual char(20);
        OutFileQual char(20);
        OutMbrOpt char(22);
       end-ds;
 
       dcl-ds OutFileData;
        ScanStr1;
        ScanStr2;
        ScanStr3;
        ScanStr4;
        ScanStr5;
        ScanStr6;
        ScanStr7;
        ScanStr8;
        ScanStr9;
        ScanStr10;
        ScanStrOutFile like(scanstr1) dim(10) pos(1);
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       // LDA is used for long parms
 
       in LdaDS;
       SrcListPtr = %addr(LdaDS.SrcFiles);
       ParseValuesPtr = %addr(LdaDS.ScanStrings) + 2;
       NumOfFiles = f_ParmListCount(LdaDS.SrcFiles);
       NumOfScanValues = f_ParmListCount(LdaDS.ScanStrings);
       scDow = f_GetDayName();
 
       // if not case senstitive, covert all to upper case
 1b    if LdaDS.Case = '*NO';
 2b       for cc = 1 to NumOfScanValues;
             ScanVals(cc) = %xlate(lo: up: ScanVals(cc));
 2e       endfor;
 1e    endif;
 
       Ind.ShowSrcData =
       (LdaDS.IfContains = '*ANY'
       or LdaDS.IfContains = '*ALL');
 
       FromPos = LdaDS.From;
       ToPos = LdaDS.To;
 1b    if ToPos > %len(SrcCase);
          ToPos = %len(SrcCase);
 1e    endif;
 
       ToPosSave = ToPos;
       ScanLen = (ToPos - FromPos) + 1;
 
       //---------------------------------------------------------
 1b    if LdaDS.OutPut = '*';
          LdaDS.OutPut = '*PRINT';
 1e    endif;
 
       //---------------------------------------------------------
       // Print files/Lib/mbr names at top of report.
       // Spin down number of offsets to List entries.
       // Inner List pointer (start of List + OffsetToNext
       // pointer) moves DS through List
       // OR
       //  if file is one of the predefined source lists in JCRSMLTCHF
       //  then list the choice selections in that file.
       //  Predefined source lists must start with * .
       //---------------------------------------------------------
 1b    if LdaDS.OutPut = '*PRINT';
          f_OvrPrtf('JCRSMLTP': LdaDS.OutqQual: ScanVals(1));
          open JCRSMLTP;
          write PrtHead1;
          isOverFlow = *off;
 
          pListLvl = LdaDS.ListLvl;
          pScanCmnt = LdaDS.ScanComment;
 
          DisplacePtr = SrcListPtr;
 2b       for ForCount2 = 1 to NumOfFiles;
             DisplacePtr += 2;
             InnerListPtr = SrcListPtr + OffsetToNext;
 
 3b          if not(%subst(SrcFil:1 :1) = '*');
                hSrcLib = SrcLib;
                hSrcFil = SrcFil;
                hSrcMbr = SrcMbr;
                hSrcMbrTyp = SrcMbrTyp;
                write PrtHead2;
 3x          else;
                PredefinedKey = %subst(SrcFil: 1: 10);
                setll PreDefinedKey JCRSMLTCHR;
                reade PredefinedKey JCRSMLTCHR;
 4b             dow not %eof;
                   hSrcLib = ChoiceLib;
                   hSrcFil = ChoiceFil;
                   hSrcMbr = ChoiceMbr;
                   hSrcMbrTyp = ChoiceTyp;
                   write PrtHead2;
 5b                if IsOverFlow;
                      write PrtHead1;
                      IsOverFlow = *off;
 5e                endif;
                   Ind.HeadingSwitch = *on;
                   reade PredefinedKey JCRSMLTCHR;
 4e             enddo;
 3e          endif;
 
             Ind.HeadingSwitch = *on;
 2e       endfor;
 
          write PrtSpaceA1;
 
          //---------------------------------------------------------
          // Print strings in heading of report.
          // Load verbiage for set definition parameter.
          //---------------------------------------------------------
          settype = LdaDS.IfContains;
 
 2b       if LdaDS.IfContains = '*ALL';
             setverbage = 'Member contains ALL search strings';
 2x       elseif LdaDS.IfContains = '*ANY';
             setverbage = 'Member contains ANY of the search strings';
 2x       elseif LdaDS.IfContains = '*NONE';
             setverbage = 'Member contains NONE of the search strings';
 2x       elseif LdaDS.IfContains = '*NOTALL';
             setverbage = 'Member contains some but not all strings';
 2e       endif;
 
          Ind.HeadingSwitch = *off;
 2b       for aa = 1 to NumOfScanValues;
             scnstr = ScanVals(aa);
             write PrtHead3;
             Ind.HeadingSwitch = *on;
 2e       endfor;
 
          write PrtSpaceA1;
          write PrtHead4;
 
          //---------------------------------------------------------
          // open outfile and load scan value file fields
          //---------------------------------------------------------
 1x    else;
          extOmbr = %subst(LdaDS.OutMbrOpt: 3: 10);
          extOfile = f_GetQual(LdaDS.OutFileQual);
          open JCRSMLTF;
          rdate = %date();
          rtime = %time();
          SCANSET = LdaDS.IfContains;
          ScanStrOutFile(*) = *blanks;
 2b       for aa = 1 to NumOfScanValues;
             ScanStrOutFile(aa) = ScanVals(aa);
 2e       endfor;
 1e    endif;
 
       // Create user space/retrieve pointer to user space
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
 
       // load user space with mbr name list
       DisplacePtr = SrcListPtr;
 1b    for ForCount2 = 1 to NumOfFiles;
          DisplacePtr += 2;
          InnerListPtr = SrcListPtr + OffsetToNext;
          extIfile = f_GetQual(SrcFil + SrcLib);
 
 2b       if not(%subst(SrcFil:1 :1) = '*');
             exsr srGetMbrList;
 2x       else;
             PredefinedKey = %subst(SrcFil: 1: 10);
             setll PreDefinedKey JCRSMLTCHR;
             reade PredefinedKey JCRSMLTCHR;
 3b          dow not %eof;
                SrcLib = ChoiceLib;
                SrcFil = ChoiceFil;
                SrcMbr = ChoiceMbr;
                SrcMbrTyp = ChoiceTyp;
                extIfile = f_GetQual(SrcFil + SrcLib);
                exsr srGetMbrList;
                reade PredefinedKey JCRSMLTCHR;
 3e          enddo;
 2e       endif;
 1e    endfor;
 
 1b    if LdaDS.OutPut = '*PRINT';
          write prtendor; // end of report
          close JCRSMLTP;
          f_Dltovr('JCRSMLTP');
 1x    else;
          close JCRSMLTF;
 1e    endif;
       *inlr = *on;
       return;
 
       //-----------------------------------------------------
       //-----------------------------------------------------
       begsr srGetMbrList;
 
       callp QUSLMBR(
             UserSpaceName:
             'MBRL0200':
             SrcFil + SrcLib:
             SrcMbr:
             '0':
             ApiErrDS);
 
 1b    if ApiErrDS.BytesReturned = 0;  //no errors on return
          // Process members in user space,
          // override input file to each member
          QuslmbrPtr = ApiHeadPtr + ApiHead.OffSetToList;
 
 2b       for ForCount = 1 to ApiHead.ListEntryCount;
             RtvMbr = QuslmbrDS.MbrName;
 
             // member type selection
 3b          if SrcMbrTyp = '*ALL'
                or SrcMbrTyp = QuslmbrDS.MbrType;
                SrcTxt = QuslmbrDS.Text;
                Mbrtype = QuslmbrDS.MbrType;
                open MBRSRC;
                exsr srReadMbr;
                close MBRSRC;
 
                // Exclusive options, *NONE and *NOTALL
                // can only be processed after entire member is read.
 4b             if (LdaDS.IfContains = '*NONE' and IsNoneFound)
                   or (LdaDS.IfContains = '*NOTALL' and IsSomeFound);
                   exsr srPrintLine;
 4e             endif;
 
 3e          endif;
             QuslmbrPtr += ApiHead.ListEntrySize;
 2e       endfor;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // read through member scanning for each find string.
       // For inclusive sets (*ALL *ANY), keep track of
       // RRNs that are used later for printing.
       //---------------------------------------------------------
       begsr srReadMbr;
       IsFoundArry(*) = *off;
       IsAllFound = *off;
       IsSomeFound = *off;
       IsNoneFound = *on;
       CurrentRRN = 0;
       cc = 0;
 
       read MBRSRC InputDS;
 1b    dow not %eof;
          CurrentRRN += 1;
 
          // If LdaDS.ScanComment = *NO , do not consider comment lines.
 2b       if LdaDS.ScanComment = '*YES'
             OR
             (LdaDS.ScanComment = '*NO'
             and not
             (SrcComment = '*'
             or SrcCommentFree = '//'))
             OR
             (LdaDS.ScanComment = '*ONLY'
             and
             (SrcComment = '*'
             or SrcCommentFree = '//'));
 
 3b          if InfdsRecLen = 92
                or ((QuslmbrDS.MbrType = 'RPGLE'
                or QuslmbrDS.MbrType = 'SQLRPGLE')
                and LdaDS.ScanComment = '*NO');
 
                %subst(SrcDta:81) = *blanks;  // blank out inline comments
 3e          endif;
 
 3b          if LdaDS.Case = '*NO';
                SrcCase = %xlate(lo: up: Srcdta);
 3x          else;
                SrcCase = SrcDta;
 3e          endif;
 
             // If scan comment = *NO, then blank out comments
 3b          if LdaDS.ScanComment = '*NO';
 4b             if QuslmbrDS.MbrType = 'RPGLE'
                   or QuslmbrDS.MbrType = 'SQLRPGLE';
                   aa = %scan('//': SrcCase);
 5b                if aa > 0;
                      %subst(SrcCase:aa) = *blanks;
 5e                endif;
 
 4x             elseif QuslmbrDS.MbrType = 'CLP'
                   or  QuslmbrDS.MbrType = 'CLLE'
                   or  QuslmbrDS.MbrType = 'CMD'
                   or  QuslmbrDS.MbrType = 'CLP38';
 
                   //  blank out all comments before scanning
                   SrcCase = f_BlankCommentsCL(SrcCase);
 4e             endif;
 3e          endif;
 
             //---------------------------------------------------------
 3b          for aa = 1 to NumOfScanValues;  // number of strings
                bb = 0;
                bb = %scan(ScanVals(aa):
                %subst(SrcCase: FromPos: ScanLen)
                :1);
 
 4b             if bb > 0;
                   //---------------------------------------------------------
                   // If set = *ANY.  Meaning include if source
                   // contains any strings defined.
                   // If level is set to *FIRST,
                   //  print and leave when 1st one is found.
                   //---------------------------------------------------------
 5b                if LdaDS.IfContains = '*ANY';
 6b                   if cc = 0;
                         cc = 1;
 6e                   endif;
                      exsr srPrintLine;
 
 6b                   if LdaDS.ListLvl = '*FIRST';
 LV                      leavesr;
 6x                   else;
 3v                      leave;
 6e                   endif;
 
                      //---------------------------------------------------------
                      // If set is defined as *ALL.
                      // Exsr subroutine to see if all strings are present
                      // until all strings are determined to be in Mbr.
                      //---------------------------------------------------------
 5x                elseif LdaDS.IfContains = '*ALL';
 
                      //---------------------------------------------------------
                      // If set is defined as *ALL.  Meaning include if source contains
                      // ALL strings defined.
                      // Spin through member to see if all strings are present.
                      // If user has selected to view only *FIRST occurrence of each string,
                      // then only load RRN of each first occurrence into array.
 
                      // If user has selected *ALL occurrences of string, then must
                      // load all rrns, until known all strings are present,
                      // then just read and print reset.
                      //---------------------------------------------------------
 6b                   if not IsAllFound;
 7b                      if cc = 0;
                            ScanRRN(1) = CurrentRRN;
                            cc = 1;
 7x                      else;
 8b                         if not(LdaDS.ListLvl = '*FIRST'
                               and IsFoundArry(aa) = *on);
 9b                            if not(ScanRRN(cc) = CurrentRRN);   //no duplicates
                                  cc += 1;
                                  ScanRRN(cc) = CurrentRRN;
 9e                            endif;
 8e                         endif;
 7e                      endif;
                         IsFoundArry(aa) = *on;
 
                         //---------------------------------------------------------
                         // Determine if all strings have been found.
                         // If all have been found, save current RRN, spin back through RRN array
                         // and output all previously found records.
                         // Reset file to current record and continue.
                         //---------------------------------------------------------
                         IsAllFound = *on;
 7b                      for yy = 1 to NumOfScanValues;
 8b                         if IsFoundArry(yy) = *off;
                               IsAllFound = *off;
 7v                            leave;
 8e                         endif;
 7e                      endfor;
 
 7b                      if IsAllFound;
                            SaveRRN = CurrentRRN;
 8b                         for yy = 1 to cc;
                               CurrentRRN = ScanRRN(yy);
                               chain CurrentRRN MBRSRC InputDS;
                               exsr srPrintLine;
 8e                         endfor;
 
                            CurrentRRN = SaveRRN;
                            chain CurrentRRN MBRSRC InputDS;
 7e                      endif;
 
                         //---------------------------------------------------------
 7b                      if IsAllFound
                            and LdaDS.ListLvl = '*FIRST';
 LV                         leavesr;
 7e                      endif;
 6x                   else;
                         exsr srPrintLine;
 3v                      leave;
 6e                   endif;
 
                      //---------------------------------------------------------
                      // If set is defined as *NOTALL
                      // When first scan is found, set flag to off
                      // and exit subroutine.
                      //---------------------------------------------------------
 5x                elseif LdaDS.IfContains = '*NONE';
                      IsNoneFound = *off;
 LV                   leavesr;
 
                      //---------------------------------------------------------
                      // If set is defined as *SOME,
                      // As each string is found, set indicator off and exit subroutine.
                      //---------------------------------------------------------
 5x                elseif LdaDS.IfContains = '*NOTALL';
                      IsFoundArry(aa) = *on;
 
                      //---------------------------------------------------------
                      // Determine if all string have been found,
                      // set IsSomeFound = *off and exit read process.
                      //---------------------------------------------------------
                      IsSomeFound = *on;
                      IsAllFound = *on;
 6b                   for yy = 1 to NumOfScanValues;
 7b                      if IsFoundArry(yy) = *off;
                            IsAllFound = *off;
 7e                      endif;
 6e                   endfor;
 
 6b                   if IsAllFound;
                         IsSomeFound = *off;
 LV                      leavesr;
 6e                   endif;
 5e                endif;
 4e             endif;
 3e          endfor;
 2e       endif;
          read MBRSRC InputDS;
 1e    enddo;
       endsr;
 
       //---------------------------------------------------------
       // Print detail line
       //---------------------------------------------------------
       begsr srPrintLine;
 1b    monitor;
          SrcSeq = SrcSeq;
 1x    on-error;
          SrcSeq = 0;
 1e    endmon;
 
 1b    monitor;
          SrcChgdat = SrcChgdat;
 1x    on-error;
          SrcChgdat = 0;
 1e    endmon;
 
       Ind.IsChangedDate = (SrcChgdat > 0);
 
 1b    if LdaDS.OutPut = '*PRINT';
          SrcDta80 = SrcDta;
          SrcTxt41 = SrcTxt;
          write PrtDetail;
 1x    else;
 2b       if Ind.ShowSrcData = *off;
             SrcSeq = 0;
             SrcChgdat = 0;
             clear SrcDta;
 2e       endif;
          write JCRSMLTFR;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // return number of elements passed in parameter list
       //---------------------------------------------------------
       dcl-proc f_ParmListCount;
        dcl-pi *n uns(5);
         p_ListParm char(2);
        end-pi;
 
        dcl-ds ExtractDS qualified;
         Bin uns(5);
        end-ds;
 
        ExtractDS = p_ListParm;
        return ExtractDS.bin;
       end-proc;
