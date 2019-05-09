       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRHFDR - Rpg H,F,D to free
 
       //  Source lines with (columns 6 and 7 = blanks and columns 8 to 80 > *blanks)
       //  are free format. Any columns 6 and 7 > *blanks are fixed column.
 
       //  The program will deal with sets, find the starting rrn and ending
       //  rrn of a structure, pass that to a function to find the set of each entity
       //  inside that structure, then process the inner and outer sets.
       //
       //   CLASS, DATFMT, PROCPTR, TIMFMT,  and VARYING are converted to datatype extensions.
       //   varying keyword is replaced with varchar datatype.
       //   *next is removed if the overlay keyword is the data structure name.
       //   ds len is not allowed with extname.  Will require change to extname object.
       //   *delete is added to the usage keyword if record is deleted in main or proc.
       //   + or - lengths are now part of the data type extension, packed(1: +2).
       //   uds requires DTAARA{{(name)} {*AUTO}.  Fixed column allowed IN and OUT
       //    with uds. Need to change *auto to *userctl if using these opcodes
       //   data area names are quoted and upper cased.
       //   data area *var modifier is removed.
       //   continuation lines (+ and -) are reformatted as keywords are expanded/removed.
       //   H specs with embedded compiler directives will not be converted.
       //   Program described with EADD on output will need to be E only after conversion
       //
       //   Review embedded compiler directives in the source
       //   and remove any OS directives. aftermath will only run on v7 or better.
       //   Conversion is not directive aware.
       //
       //   If any constants, inz or *java objects longer that 2048,
       //   scan replace 2048 with proper size, then change last field in
       //    fspecds in jcrcmdscpy before recompiling jcrgetfilr and this program.
       //
       //   This program is an exception to the general rule that functions should be
       //   self-contained entities.  Here procedures are used like subroutines.
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       //------------------------------------------------
       // rpgle source member input file
       //------------------------------------------------
       dcl-f InputSrc disk(112) extfile(extIfile) extmbr(p_InMbr) usropn
       infds(Infds) block(*no);  // block no so rrn will work
 
       dcl-ds InputDS len(112) qualified;
        CompileArry char(3) pos(13);
        SrcSeq zoned(6: 2) pos(1);
        SrcDat zoned(6: 0) pos(7);
        Src112 char(100) pos(13);
        Src74 char(74) pos(19);
        SrcComment char(20) pos(93);
        Src94 char(94) pos(19);
        SpecType char(1) pos(18);
        FileName char(10) pos(19);
        FieldName char(14) pos(19);
        Asterisk char(1) pos(19);
        Designation char(1) pos(30);  // full, primary, second, etc..
        RecordAddressType char(1) pos(46);
        dReservedWord char(8) pos(38); // *PROC, *ROUTINE, *FILE etc...
        dSdsExternal char(1) pos(34);  // E for External
        dSdsType char(1) pos(35);  // Sds or Uds
        dType char(3) pos(36);  // s ds c pi pr
        dFromLen char(7) pos(38);
        dLen char(7) pos(45);
        dDataType char(1) pos(52);
        dDecimals char(2) pos(53);
        dKeyWords char(37) pos(56);
       end-ds;
 
       //------------------------------------------------
       // new source member written out with free H,F and D specs
       //------------------------------------------------
       dcl-f NewSrc disk(112) usage(*output: *update) extfile(extOfile)
       extmbr(p_OutMbr) usropn;
 
       dcl-ds OutDS len(112) inz qualified;
        SrcSeq zoned(6: 2) pos(1);
        SrcDat zoned(6: 0) pos(7);
        SrcOut char(100) pos(13);
       end-ds;
 
       /define Infds
       /define f_IsIgnoreLine
       /define Constants
       /define f_GetQual
       /define f_SndCompMsg
       /define f_IsCompileTimeArray
       /define f_GetDataTypeKeyWords
       /define f_GetInternalProcNames
       /define f_ReturnZeroIfBetweenQuotes
       /define f_ReturnZeroIfAfterComments
       /define f_EllipsisLoc
       /define FspecDS
       /define p_JCRGETFILR
       // *ENTRY
       /define p_JCRHFDR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s UpSpec char(1);
       dcl-s IsH ind;
       dcl-s IsF ind;
       dcl-s IsD ind;
       dcl-s IsP ind;
       dcl-s IsCopyEndIf ind;
       dcl-s BigFirst uns(5);
       dcl-s BigLast uns(5);
       dcl-s LastGoodRrn uns(5);
       dcl-s IsFirstCompileTimeArray ind;
       dcl-s FileName char(10);
       dcl-s CSorDS char(3);
       dcl-s string varchar(94);
       dcl-s s7 char(7);
       dcl-s IsCompileArray ind;
       dcl-s IsFirstFile ind inz(*on);
       dcl-s JustWroteOne ind;
       dcl-s dFromLen like(InputDS.dFromLen);
       dcl-s dLen like(InputDS.dLen);
       dcl-s dDataType like(InputDS.dDataType);
       dcl-s dDecimals like(InputDS.dDecimals);
       dcl-s dReservedWord like(InputDS.dReservedWord);
       dcl-s dSdsType like(InputDS.dSdsType);
       dcl-s dSdsExternal like(InputDS.dSdsExternal);
       dcl-s dxname varchar(74);
       dcl-s dComment char(20);
       dcl-s StructureType like(InputDS.dType);
       dcl-s dFromLenUns uns(10);
       dcl-s dLenUns uns(10);
       dcl-s ApostropheCnt uns(5);
       dcl-s DimSize packed(9);
       dcl-s pEntityLast uns(5);  // needed global definition for sameline end-
       dcl-s IsStructureName ind;
       dcl-s ds_Name varchar(74);
       dcl-s IsExclude ind;
       dcl-s IsLikeDS ind;  // no end-ds
       dcl-s DefineDangler varchar(37);
       dcl-s CurrPrName char(74);
       dcl-s kw uns(5);  // keyword start
       dcl-s kwstring varchar(2048);
       dcl-s dddkey char(2048);
       dcl-s dddpos uns(5);
       dcl-s dddcnt uns(5);
       dcl-s EntityKeyword varchar(2048) dim(100);
       dcl-s KeyCnt uns(3);
       dcl-s EndDash varchar(6);
       dcl-s Block varchar(74);
       dcl-s BlockLen uns(5);
       dcl-s BaseLen uns(3) inz(74);
 
       //---------------------------------------------
       // Prototypes to exclude
       //  with V7 do not need prototypes for internal procedures
       //----------------------------------------------
       dcl-ds ExcludePR qualified;
        Cnt uns(5);
        Arry char(74) dim(500);
       end-ds;
 
       //---------------------------------------------
       // Keep up with the number values of any constants
       // that could be used on a dim statement. Use that value to calculate
       // the free field lengths.
       //----------------------------------------------
       dcl-ds Constant dim(1000) qualified;
        Name char(74);
        Value packed(9);
       end-ds;
       dcl-s ConstantCnt uns(5);
 
       //---------------------------------------------------------
       extIfile = f_GetQual(p_InFileQual);
       extOfile = f_GetQual(p_OutFileQual);
       IsFirstCompileTimeArray = *off;
 
       ExcludePR = f_GetInternalProcNames(p_InMbr: p_InFileQual);
 
       open NewSrc;
       open InputSrc;
       exsr srReadInput;
       close InputSrc;
       close NewSrc;
 
       f_SndCompMsg('Free H,F,D mbr ' +%trimr(p_OutMbr)+ ' generated.');
       *inlr = *on;
       return;
 
       //---------------------------------------------
       //---------------------------------------------
       begsr srReadInput;
       read InputSrc InputDS;
 1b    dow not %eof;
 
 2b       if f_IsCompileTimeArray(InputDS.CompileArry);
             IsCompileArray = *on;
 
             //---------------------------------------------------------------
             // if the procedure ends at a compile time array
             // write the end-proc and reset the rrn to get the compile time array
             //---------------------------------------------------------------
 3b          if not IsFirstCompileTimeArray;
                IsFirstCompileTimeArray = *on;
 4b             if IsP;
                   f_PspecWrite(BigFirst:LastGoodRrn);
                   IsP = *off;
                   setgt LastGoodRrn InputSrc;
                   read InputSrc InputDS;
                   IsCompileArray = f_IsCompileTimeArray(InputDS.CompileArry);
 4e             endif;
 3e          endif;
 2e       endif;
 
 2b       if IsCompileArray;
             f_WriteAsIs();
 2x       else;
 
             JustWroteOne = *off;
             string = %trimr(InputDS.Src74);
 3b          if not f_IsIgnoreLine(string);
 
                // save for procedures ending just before ** arrays
                LastGoodRrn = InfdsDbRrn;
                exsr srCheckEndOfStructure;
 
 4b             if not JustWroteOne;
                   exsr srStartOfStructure;
 4e             endif;
 3e          endif;
 
 3b          if not(IsH or IsF or IsD or IsP or JustWroteOne);
                f_WriteAsIs();
 3e          endif;
 
 2e       endif;
          read InputSrc InputDS;
 1e    enddo;
 
       //----------------------------------------------------------
       // deal with copy books when the last line is /endif or
       //  no other executable lines to provide event trigger for write.
       //----------------------------------------------------------
 1b    if IsH or IsD or IsP or IsF;
          LastGoodRrn = InfdsDbRrn;
          IsCopyEndif = *off;
 
 2b       if %xlate(lo:up: InputDS.FieldName) = '/ENDIF';
             IsCopyEndif = *on;
             LastGoodRrn = InfdsDbRrn - 1;
 2e       endif;
 
 2b       if IsH;
             f_HspecWrite(BigFirst:LastGoodRrn);
 2x       elseif IsF;
             f_FspecWrite(FileName);
 2x       elseif IsD;
             f_DspecWrite(BigFirst:LastGoodRrn);
 2x       elseif IsP;
             f_PspecWrite(BigFirst:LastGoodRrn);
 2e       endif;
 
          // now write last /endif
 2b       if IsCopyEndif;
             setgt LastGoodRrn InputSrc;
             read InputSrc InputDS;
             f_WriteAsIs();
 2e       endif;
 1e    endif;
       endsr;
 
       //-----------------------------------------------------
       // Get if at end of structure
       //  Structure constructions rely on DS or S or C Values to
       //   to determine where structures start and stop.
       //    Deal with continuation lines for ... long variable names
       //  the first... can always be first rrn, but never that last of a group
       //   and the check end of group ignores... lines
       //-----------------------------------------------------
       begsr srCheckEndOfStructure;
       UpSpec = %xlate(lo: up: InputDS.SpecType);
 
 1b    if UpSpec = 'D';
          CSorDs = %xlate(lo: up: InputDS.dType);
 1e    endif;
 
       //---------------------------------------------
       // cannot be after quote or in a quoted continuation string
       //  d....    inz('+
       //                ... ')
 
       // also ... inside a structure are ignored
       //  a  ds
       //  subf1...
 
       // which massively complicates things as
       //  a  ds
       //   b...
       //     s      1a
       //  Skip ahead two records to see if at the end
       //  of the DS structure or if b is a subfield of a.
       //---------------------------------------------
 1b    if IsD;
 
 2b       if f_IsInEllipsis(InputDS.Src74);
 3b          dou not f_IsIgnoreLine(string);
                read InputSrc InputDS;
 4b             if %eof;
 3v                leave;
 4e             endif;
                string = %trimr(InputDS.Src74);
 3e          enddo;
 2e       endif;
 
          UpSpec = %xlate(lo: up: InputDS.SpecType);
          CSorDs = %xlate(lo: up: InputDS.dType);
 
 2b       if (UpSpec = 'D'
             and
             (CSorDS = 'C  ' or
             CSorDS = 'S  ' or
             CSorDS = 'PR ' or
             CSorDS = 'PI ' or
             CSorDS = 'DS '))
             or
             UpSpec <> 'D';
 
             f_DspecWrite(BigFirst:BigLast);
             JustWroteOne = *on;
 
             setgt BigLast InputSrc;
             IsD = *off;
             BigFirst = 0;
             BigLast = 0;
 2e       endif;
 
          //----------------------------------------------
 1x    elseif IsF;
 
 2b       if (UpSpec ='F'
             and InputDS.FileName > *blanks)
             OR
             UpSpec <> 'F';
 
             f_FspecWrite(FileName);
             JustWroteOne = *on;
 
             setgt BigLast InputSrc;
             IsF = *off;
             BigFirst = 0;
             BigLast = 0;
 2e       endif;
 
          //----------------------------------------------
 1x    elseif IsH;
 2b       if UpSpec <> 'H';
             f_HspecWrite(BigFirst:BigLast);
             JustWroteOne = *on;
 
             setgt BigLast InputSrc;
             IsH = *off;
             BigFirst = 0;
             BigLast = 0;
 2e       endif;
 
          //----------------------------------------------
 1x    elseif IsP;
 
          f_PspecWrite(BigFirst:BigLast);
          JustWroteOne = *on;
 
          setgt BigLast InputSrc;
          IsP = *off;
          BigFirst = 0;
          BigLast = 0;
 
 1e    endif;
       endsr;
 
       //-----------------------------------------------------
       // Get start of structure
       //-----------------------------------------------------
       begsr srStartOfStructure;
 
 1b    if UpSpec = 'D';
          IsD = *on;
          BigLast = InfdsDbRrn;
 
 2b       if BigFirst = 0;
             BigFirst = InfdsDbRrn;
 
 3b          if f_IsInEllipsis(InputDS.Src74);
 4b             dou not f_IsIgnoreLine(string);
                   read InputSrc InputDS;
 5b                if %eof;
 4v                   leave;
 5e                endif;
                   string = %trimr(InputDS.Src74);
                   BigLast = InfdsDbRrn;
 4e             enddo;
 3e          endif;
 
 2e       endif;
 
          //----------------------------------------------
 1x    elseif UpSpec = 'F';
          BigLast = InfdsDbRrn;
 
          IsF = *on;
 2b       if BigFirst = 0;
             BigFirst = InfdsDbRrn;
             FileName = InputDS.FileName;
 2e       endif;
 
          //----------------------------------------------
 1x    elseif UpSpec = 'H';
          IsH = *on;
          BigLast = InfdsDbRrn;
 2b       if BigFirst = 0;
             BigFirst = InfdsDbRrn;
 2e       endif;
 
          //----------------------------------------------
 1x    elseif UpSpec = 'P';
          IsP = *on;
          BigLast = InfdsDbRrn;
 
 2b       if BigFirst = 0;
             BigFirst = InfdsDbRrn;
 
 3b          if f_IsInEllipsis(InputDS.Src74);
 4b             dou not f_IsIgnoreLine(string);
                   read InputSrc InputDS;
 5b                if %eof;
 4v                   leave;
 5e                endif;
                   string = %trimr(InputDS.Src74);
                   BigLast = InfdsDbRrn;
 4e             enddo;
 3e          endif;
 2e       endif;
 1e    endif;
       endsr;
 
       //------------------------------
       //------------------------------
       // Now that keywords are parsed, fit best into 74 characters
       //  Tempting to put a 2d cutting stock solution here
       //  to get best fits, but that is something for another day.
       //  For now, if next keyword will not fit in current line,
       //  start a new line.
       //-------------------------------
       dcl-proc f_OutputBestFit;
        dcl-pi *n;
         base varchar(148);
         comment char(20);
        end-pi;
 
        dcl-s BlocksWrittenCnt uns(5);
        dcl-s KeyLen uns(5);
        dcl-s InLineLen uns(5);
        dcl-s SpaceLen uns(5);
        dcl-s EndColonLen uns(5);
        dcl-s cmnt varchar(24);
 
        BlockLen = 0;
        BlocksWrittenCnt = 0;
        KeyLen = 0;
        SpaceLen = 1;
        EndColonLen = 1;
        InLineLen = %len(EndDash);
 
       //----------------------------------------------------------
 1b     if not f_IsFit(0:%len(Base));
           OutDS.SrcOut = s7 + %subst(base:1:BaseLen);
           f_WriteFreeSpec();
           base = %subst(base:BaseLen+1);
 1e     endif;
 
 1b     if comment > *blanks;
           cmnt = ' // ' + %trim(comment);
 1e     endif;
 
       //----------------------------------------------------------
       // prime the pump to fall into fitter loop
 1b     if KeyCnt = 0;
           KeyCnt = 1;
           %len(EntityKeyword(1)) = 0;
 1e     endif;
 
        block = base + ' ';
 
       //---------------------------------------------------------------
 1b     for kw = 1 to KeyCnt;
           BlockLen = %len(block);
           KeyLen = %len(EntityKeyword(kw));
 
          //----------------------------------------------
          // keyword will not fit, write out what is built so far
          //----------------------------------------------
 2b        if not f_isFit(BlockLen: KeyLen + SpaceLen);
 
             // next block will fit in 74
 3b           if f_isFit(0: KeyLen + SpaceLen);
                 OutDS.SrcOut = s7 + block + cmnt;
                 BlocksWrittenCnt += 1;
                 f_WriteFreeSpec();
                 %len(block) = 0;
                 %len(cmnt) = 0;
 3x           else;
                 EntityKeyword(kw) =
                 f_ParseLongKeyword(EntityKeyword(kw));
 3e           endif;
 2e        endif;
 
          //----------------------------------------------
           block += EntityKeyword(kw) + ' ';
 1e     endfor;
 
       //-----------------------------------------------------
       // last one
        BlockLen = %len(block);
        %len(EndDash) = 0;      // in line end
 1b     if IsStructureName = *on;
           endDash = f_BuildEndDash();
 1e     endif;
 
 1b     If %len(EndDash) > 0;
           SpaceLen = 2;
 1x     else;
           SpaceLen = 1;
 1e     endif;
 
 1b     if not f_isFit(BlockLen: %len(endDash)+SpaceLen);
           OutDS.SrcOut = s7 + block + cmnt;
           f_WriteFreeSpec();
           OutDS.SrcOut = s7 + enddash +';';
           f_WriteFreeSpec();
 1x     else;
 
 2b        if %len(enddash) = 0;
              OutDS.SrcOut = s7 + %trimr(block) + ';' + cmnt;
 2x        else;
              OutDS.SrcOut = s7 + %trimr(block) + ' ' +
              enddash + ';' + cmnt;
 2e        endif;
           f_WriteFreeSpec();
 1e     endif;
 
 1b     if IsStructureName = *off;
           endDash = f_BuildEndDash();
 2b        if %len(EndDash) > 0;
              OutDS.SrcOut = s7+ enddash + ';';
              f_WriteFreeSpec();
 2e        endif;
 1e     endif;
 
        return;
       end-proc;
 
       //---------------------------
       //----------------------------------------------
       // now start complex task of reparsing
       // continuation lines and breaking keywords on :
 
       // rule 1:  quoted strings have to break inside the quotes
       //   inz(+
       //    'A');  is not valid.
 
       //   inz('+
       //  A'); is valid.
 
       //  Get keyword and the first quote+ on same line.
       //----------------------------------------------
       dcl-proc f_ParseLongKeyword;
        dcl-pi *n  varchar(2048);
         string varchar(2048);
        end-pi;
        dcl-s fq uns(5);
        dcl-s fStart uns(5);
        dcl-s fEnd uns(5);
        dcl-s fLen uns(5);
        dcl-s sLen uns(5);
        dcl-s HowMuchLeft uns(5);
        dcl-s NextStart uns(5);
        dcl-s RemainingSpaces uns(5);
 
        BlockLen = %len(block);
        RemainingSpaces = 0;
        fStart = 1;
 
        fq = %scan(qs:string);
 1b     if fq > 0;
 2b        if f_isFit(BlockLen: fq + 2);
             // load block with entity leaving room for - continuation
              RemainingSpaces = %len(block:*MAX) - BlockLen - 2;
              fEnd = RemainingSpaces;
              fLen = (fEnd -fStart);
 
              block = block + %subst(string:fStart:Flen) + '-';
              OutDS.SrcOut = s7 + block;
              f_WriteFreeSpec();
              %len(block) = 0;
 2e        endif;
 1e     endif;
 
       //------------------------------------------------------
       // 'Consume' all of the keyword, except
       // return whatever will occupy the last line = block
       // so our outer loop in bestfit will continue parsing any
       // remaining keywords
       //------------------------------------------------------
        slen = %len(string);
 
 1b     dou 1 = 2;
           NextStart = (fStart + Flen);
           HowMuchLeft = slen - NextStart;
 
          //---------------
 2b        if HowMuchLeft < BaseLen;
              %len(block)=0;
              string = %subst(string:NextStart);
              return string;
 2e        endif;
          //---------------
 
           flen = BaseLen - 3;
           block = %subst(string:NextStart:Flen) + '-';
           OutDS.SrcOut = s7 + block;
           f_WriteFreeSpec();
           fStart = NextStart;
 
 1e     enddo;
 
       end-proc;
 
       //---------------------------
       //---------------------------
       dcl-proc f_IsFit;
        dcl-pi *n ind;
         CurrLen uns(5) const;
         AddLen uns(5) const;
        end-pi;
 
        return ((Currlen + addlen) <= Baselen);
       end-proc;
 
       //---------------------------
       //---------------------------
       dcl-proc f_BuildEndDash;
        dcl-pi *n varchar(6);
        end-pi;
 
        dcl-s string varchar(6);
        %len(string) = 0;
 
 1b     if BigLast = pEntityLast and
           (StructureType = 'PR '
           or StructureType = 'PI '
           or (StructureType = 'DS ' and IsLikeDS = *off));
           string = 'end-' + %trimr(%xlate(up: lo: StructureType));
 1e     endif;
 
        return string;
       end-proc;
 
       //----------------------------------------------------
       // global function to write as-is lines
       //----------------------------------------------------
       dcl-proc f_WriteAsIs;
        dcl-pi *n end-pi;
 1b     if %xlate(lo: up: InputDS.FieldName) = '/FREE'
           or %xlate(lo: up: InputDS.FieldName) = '/END-FREE';
 1x     else;
 
 2b        monitor;
              OutDS.SrcDat = InputDS.SrcDat;
 2x        on-error;
              OutDS.SrcDat = 0;
 2e        endmon;
 
           OutDS.SrcSeq += .01;
           OutDS.SrcOut = InputDS.Src112;
           write NewSrc OutDS;
 1e     endif;
       end-proc;
 
       //----------------------------------------------------
       // the *delete usage keyword on dcl-f has proven to be a major pain.
       // why IBM did not leave it *update is beyond me.
       //   Call jcrgetfilr to return file list with assocaited delete flag
       //----------------------------------------------------
       dcl-proc f_FspecWrite;
        dcl-pi *n;
         pName char(10);
        end-pi;
 
        dcl-s ff uns(5);
        dcl-s IsDelete ind;
        dcl-s fcomment char(20);
        dcl-s fNameCvt varchar(148);
        dcl-s UsageKeyWord char(32);
        dcl-s DeviceKeyWord char(14);
        dcl-s KeyedKeyword char(20);
       //--------------------------------
 
        pName = %xlate(lo: up: pName);
 
       //--------------------------------
       // program to load F and dcl-f into element per file
       //--------------------------------
 1b     if IsFirstFile;
           callp p_JCRGETFILR(
                 p_InMbr:
                 p_InFileQual:
                 FileCount:
                 OnePerRcdFmt:
                 FspecArry:
                 CommentArry:
                 PrNameArry:
                 DeleteArry);
           IsFirstFile = *off;
 1e     endif;
 
       //--------------------------
       // find this file name in returned file array
       //--------------------------
 1b     for ff = 1 to FileCount;
           FspecDS = %xlate(lo: up: FspecArry(ff));
           Fcomment = CommentArry(ff);
 
 2b        if FspecDS.Name = pName
              and PrNameArry(ff) = CurrPrName;
 
             //---------------------------------------------------------
             //---------------------------------------------------------
             // no free format for primary, secondary, table
 3b           if (FspecDS.Designation = ' '
                 or FspecDS.Designation = 'F')
                 and (
                 FspecDS.RecordAddressType = ' '
                 or  FspecDS.RecordAddressType = 'A'
                 or  FspecDS.RecordAddressType = 'K');
 
                 IsDelete = (DeleteArry(ff) = 'Y');  // from jcrfilgetr
 
                 exsr srFspecFree;
 3x           else;
                 fNameCvt = fSpecDS.FixedFormat;
                 f_ReParseKeywords('F':'0':fNameCvt:fComment:fSpecDS.KeyWords);
 3e           endif;
 
             //--------------------------
 1v           leave;
 2e        endif;
 1e     endfor;
        return;
 
       //--------------------------
       // finally! start building new F specs
       // The FSPEC array returned from JCRGETFILR has
       //  one element per file.
       // 1-74 are the fixed column F spec from the program source
       // the remain string elements is all the keywords compressed
 
       // ***load commentarry into a field when file is found
       // ***then leave room on first line for //commentfield
       // reference RPG FREE manual.pdf on desk top
       //--------------------------
        begsr srFspecFree;
 
       // DEVICE{(record-length)}
        DeviceKeyword = f_GetDevice(
                        FspecDS.Device:
                        FspecDS.RecordLength);
 
       // USAGE(*UPDATE: *DELETE: *OUTPUT)
        UsageKeyWord = f_GetUsage(
                       FspecDS.FileType:
                       FspecDS.Designation:
                       FSpecDS.FileAddition:
                       FspecDS.Device:
                       IsDelete);
 
       // KEYED{(*CHAR: key-length)}
        KeyedKeyword = f_GetKeyed(
                       FspecDS.LengthOfKeyedField:
                       FspecDS.RecordAddressType:
                       UsageKeyWord);
 
        fNameCvt = 'dcl-f ' +  %trimr(FspecDS.Name);
 
 1b     if DeviceKeyword > *blanks;
           fNameCvt += ' ' + %trimr(DeviceKeyword);
 1e     endif;
 
 1b     if KeyedKeyword > *blanks;
           fNameCvt += ' ' + %trimr(KeyedKeyword);
 1e     endif;
 
 1b     if  UsageKeyWord > *blanks;
           fNameCvt += ' ' + %trimr(UsageKeyWord);
 1e     endif;
 
        f_ReParseKeywords('F':'1':fNameCvt: fComment: fSpecDS.KeyWords);
        endsr;
       end-proc;
 
       //------------------------------
       // do not lower case between apostrophes
       //-------------------------------
       dcl-proc f_MakeLowerCase;
        dcl-pi *n varchar(2048);
         string varchar(2048);
        end-pi;
 
        dcl-s aa uns(5);
 
        ApostropheCnt = 0;
 1b     for aa = 1 to %len(string);
 
 2b        if %subst(string:aa:1) = qs;
              ApostropheCnt += 1;
 2e        endif;
 
 2b        if %rem(ApostropheCnt: 2) = 0;
              %subst(string:aa:1) = %xlate(up: lo: %subst(string:aa:1));
 2e        endif;
 1e     endfor;
        return string;
       end-proc;
 
       //------------------------------
       // reference RPG FREE manual.pdf specifications section 5-39
       //------------------------------
       dcl-proc f_GetUsage;
        dcl-pi *n char(32);
         FileType char(1);
         Designation char(1);
         FileAddition char(1);
         Device char(7);
         IsDelete ind;
        end-pi;
 
        dcl-s string char(32);
 
        string = *blanks;
 
       //-------------------------------
 1b     if FileType = 'I'
           and Designation = 'F'
           and  FileAddition = ' ';
 
 2b        if not(Device = 'DISK'
              or Device = 'SEQ'
              or Device = 'SPECIAL');
              string = 'usage(*input)';
 2e        endif;
 
          //-------------------------------
 1x     elseif FileType = 'I'
           and Designation = 'F'
           and  FileAddition = 'A';
           string = 'usage(*input: *output)';
 
          //-------------------------------
 1x     elseif FileType = 'U'
           and Designation = 'F'
           and  FileAddition = ' ';
 2b        if IsDelete;
              string = 'usage(*update: *delete)';
 2x        else;
              string = 'usage(*update)';
 2e        endif;
 
          //-------------------------------
 1x     elseif FileType = 'U'
           and Designation = 'F'
           and  FileAddition = 'A';
 2b        if IsDelete;
              string = 'usage(*update: *delete: *output)';
 2x        else;
              string = 'usage(*update: *output)';
 2e        endif;
 
          //-------------------------------
 1x     elseif FileType = 'O'
           and Designation = ' ';
 2b        if not(Device = 'PRINTER');
              string = 'usage(*output)';
 2e        endif;
 
 1e     endif;
        return string;
       end-proc;
 
       //------------------------------
       //------------------------------
       dcl-proc f_GetDevice;
        dcl-pi *n char(14);
         Device char(7) const;
         RecordLength char(5);
        end-pi;
 
        dcl-s string char(14);
        dcl-s LoDev like(Device);
 
        string = *blanks;
        LoDev = %xlate(up: lo: Device);
 
 1b     if LoDev = 'disk  ';
 2b        if RecordLength <> *blanks;
              string = 'disk(' + %trim(RecordLength) +')';
 2e        endif;
 1x     else;
 
 2b        if RecordLength <> *blanks;
              string = %trimr(LoDev) + '('+ %trim(RecordLength) +')';
 2x        else;
              string = LoDev;
 2e        endif;
 1e     endif;
        return string;
       end-proc;
 
       //------------------------------
       //------------------------------
       dcl-proc f_GetKeyed;
        dcl-pi *n char(20);
         LengthOfKeyedField char(5);
         RecordAddressType char(1);
         Usage char(32);
        end-pi;
 
        dcl-s string char(20);
        string = *blanks;
 1b     if Usage = 'usage(*output)';
           return string;
 1e     endif;
 
 1b     if RecordAddressType = 'K';
           string = 'keyed';
 1x     elseif RecordAddressType = 'A';
           string = 'keyed(*char: ' +
           %trim(LengthOfKeyedField) + ')';
 1e     endif;
 
        return string;
       end-proc;
 
       //------------------------------
       // String everything together but break nothing across the end of a line
       // treat keywords as a entity - name(  )
       //-------------------------------
       dcl-proc f_ReParseKeywords;
        dcl-pi *n;
         SpecType char(1) const;
         IsFreeFspec ind const;
         base varchar(148);
         comment char(20);
         KeyWords char(2048);
        end-pi;
 
        dcl-s aa uns(5);
        dcl-s bb uns(5);
        dcl-s kwlen uns(5);
        dcl-s ParenthCnt uns(3);
        KeyCnt = 0;
 
 1b     if keywords > *blanks;
           kwstring = %trim(KeyWords);
           kwstring = f_MakeLowerCase(kwstring);
           kwlen = %len(kwstring);
           kw = 0;  // keyword start
 
          //------------------------------
          // rule:  a single keyword entity is either a standalone keyword
          // or a keyword( ).  get each keyword entity into a varlen string
          // to know how long it is when time comes to write
          // out specs. Ignore everything between quotes
          //------------------------------
 2b        for kw = 1 to kwlen;
             // start of a new entity
 3b           if %subst(kwstring: kw: 1) > ' '
                 and %subst(kwstring: kw: 1)<> '('
                 and %subst(kwstring: kw: 1)<> ')';
 
                // trick here:  is the next position, following spaces, a character
                // for start of next keyword, or is the next character a '(' ?
 
                 aa = kw;
 4b              dou %subst(kwstring: aa: 1) = ' '
                    or %subst(kwstring: aa: 1) = '('
                    or aa > kwlen;
 
                   // last entity in list
 5b                 if aa = kwlen;
                       KeyCnt += 1;
                       EntityKeyword(KeyCnt) =
                       %subst(kwstring: kw);
                       kw = kwlen; // exit big loop
 4v                    leave; // exit inner loop
 5e                 endif;
 
                    aa += 1;
 
                   // keyword   keyword
 5b                 if %subst(kwstring: aa: 1) = ' ';
 6b                    dou %subst(kwstring: aa: 1) <> ' ';
                          aa += 1;
 6e                    enddo;
 6b                    if %subst(kwstring: aa: 1) <> '(';
                          KeyCnt += 1;
                          EntityKeyword(KeyCnt) =
                          %subst(kwstring: kw: (aa-kw)-1);
                          kw = aa-1; // reset to start next keyword
 4v                       leave; // exit inner loop
 6x                    else;
                          exsr srFindOuterParenth;
 4v                       leave; // exit inner loop
 6e                    endif;
 
 5x                 elseif %subst(kwstring: aa: 1) = '(';
                       exsr srFindOuterParenth;
 4v                    leave; // exit inner loop
 
                      //-----------------------------------------------
 5e                 endif;
 4e              enddo;
 3e           endif;
 2e        endfor;
 1e     endif;
 
 1b     if SpecType <> 'X';  // skip write 1st pass reparse D specs
 2b        if IsFreeFspec;
              f_OutputBestFit(base:comment);
 
             //--------------------------------------------
             // for fixedformat (Input Primary, Secondary, etc.
             // write out the fixed portion with the first of any
             // keywords, then write out a F spec per remaining keywords
             //--------------------------------------------
 2x        else;
              OutDS.SrcOut = '     F' + base;
 3b           if KeyCnt > 0;
                 %subst(OutDS.SrcOut:44) = EntityKeyword(1);
 3e           endif;
 3b           If comment > *blanks;
                 %subst(OutDS.SrcOut:82) = comment;
 3e           endif;
              f_WriteFreeSpec();
 
 3b           for kw = 2 to KeyCnt;
                 OutDS.SrcOut = '     F';
                 %subst(OutDS.SrcOut:44) = EntityKeyword(kw);
                 f_WriteFreeSpec();
 3e           endfor;
 
 2e        endif;
 1e     endif;
        return;
 
       //--------------------------------------------
       // a(b) or b ( c )  c('((())))))))') or inz(%addr(e))
       // increment and decrement a count
       // of (=1 (=2 )=2 )=1 until find a )=count of 0
       // ignoring anything inside quotes
       //--------------------------------------------
        begsr srFindOuterParenth;
        ApostropheCnt = 0;
        ParenthCnt = 0;
 
 1b     for bb = aa to kwlen;
 2b        if %subst(kwstring: bb: 1) = qs;
              ApostropheCnt += 1;
 2e        endif;
 
 2b        if %rem(ApostropheCnt: 2) = 0;
 3b           if %subst(kwstring: bb: 1) = '(';
                 ParenthCnt += 1;
 3x           elseif %subst(kwstring: bb: 1) = ')';
                 ParenthCnt -= 1;
 
 4b              if ParenthCnt = 0;  // found last outer )
                    KeyCnt += 1;
                    EntityKeyword(KeyCnt) =
                    %subst(kwstring: kw: (bb-kw)+1);
                    kw = bb; // reset to start next keyword
 LV                 leavesr;
 4e              endif;
 
 3e           endif;
 2e        endif;
 1e     endfor;
        endsr;
       end-proc;
 
       //---------------------------
       //---------------------------
       dcl-proc f_WriteFreeSpec;
        dcl-pi *n end-pi;
        OutDS.SrcDat = 0;
        OutDS.SrcSeq += .01;
        write NewSrc OutDS;
       end-proc;
 
       //----------------------------------------------------
       // Passed in was the rrn range of the entire d spec structure.
       //
       //  Break the structure down and process the discrete components.
       //   ds, pi, pr will have a structure header (what type of structure and keywords)
       //      then
       //    retrieve discrete structure components (fields ) one at a time
       //
       //     so   D prname    PR  n  // Header 1
       //          d   name1  3a      // discrete component 1
       //          d   name2...       // start of discrete component 2
       //          d          3a
       //          d          varying // end of discrete component 2
       //       ---------
       //     s and c structures will only have a header
       //          d   name3    s   3u    inz(19)   // Header 1
       //------------------------------------------------------------------
       dcl-proc f_DspecWrite;
        dcl-pi *n;
         pFirst uns(5) const;
         pLast uns(5) const;
        end-pi;
 
        dcl-s FirstE uns(5);
        dcl-s LastE uns(5);
        dcl-s rrne uns(5);
        dcl-s string varchar(94);
        dcl-s dots uns(3);
        dcl-s IsE ind;
        dcl-s IsEntityName ind;
 
        Dots = 0;
        StructureType = *blanks;
        %len(dxname) = 0;
 
       //------------------------------------------------------
       // as in the main code to get the rrn limits of the entire structure,
       // now parse out the limits of each entity in that structure.
       // pFirst and pLast define the range of the entire protype
       // eStart is the beginning of the namespace for this entity
 
       // Build the name of the entity,
       //  then populate the structure with each of it's individual entities,
       //   then extract each entity and the associated keywords.
       //------------------------------------------------------
 
        IsEntityName = *on;
        IsStructureName = *on;
 1b     for rrne = pFirst to pLast;
           chain rrne InputSrc InputDS;
           string = %trimr(InputDS.Src74);
 2b        if not f_IsIgnoreLine(string);
 
             //-----------------------------------------------------
             // Get if at end of structure
             //  Structure constructions rely on DS or S or C Values to
             //   to determine where structures start and stop.
             //    Deal with continuation lines for ... long variable names
             //  the first... can always be first rrn, but never that last of a group
             //   and the check end of group ignores... lines
             //-----------------------------------------------------
              UpSpec = %xlate(lo: up: InputDS.SpecType);
 3b           if UpSpec = 'D';
                 CSorDs = %xlate(lo: up: InputDS.dType);
 3e           endif;
 
 3b           if IsE and
                 (CSorDS = 'C  ' or
                 CSorDS = 'S  ' or
                 CSorDS = 'PR ' or
                 CSorDS = 'PI ' or
                 CSorDS = 'DS ' or
                 Inputds.FieldName > *blanks or
                 Inputds.Dlen > *blanks or
                 InputDS.dDataType > *blanks or
                 f_IsInEllipsis(InputDS.Src74));
 
                 f_dCommonFields(FirstE:LastE);
 4b              if IsExclude;
                    return;
 4e              endif;
 
                //reset file position as may have been moved
                 chain rrne InputSrc InputDS;
                 UpSpec = %xlate(lo: up: InputDS.SpecType);
                 CSorDs = %xlate(lo: up: InputDS.dType);
                 FirstE = 0;
                 LastE = 0;
                 IsE = *off;
                 IsStructureName = *off;
 3e           endif;
 
             //-----------------------------------------------------
             // Get start of structure
             //-----------------------------------------------------
 3b           if UpSpec = 'D';
                 IsE = *on;
                 LastE = rrne;
 
 4b              if FirstE = 0;
 
                   //----------------------------------------
                   // Deal with ... to extract field name
                    Dots = f_EllipsisLoc(InputDS.Src74);
 5b                 if Dots = 0;
                       dxname = %trim(%subst(InputDS.Src74:1:15));
 5x                 else;
                       dxname = %trim(%subst(InputDS.Src74:1:Dots-1));
 5e                 endif;
                   //----------------------------------------
 
 5b                 if f_IsInEllipsis(InputDS.Src74);
 6b                    dou not f_IsIgnoreLine(string);
                          rrne += 1;
                          read InputSrc InputDS;
 7b                       if %eof;
 6v                          leave;
 7e                       endif;
                          string = %trimr(InputDS.Src74);
                          LastE = rrne;
 6e                    enddo;
 5e                 endif;
 
 5b                 if IsEntityName;
                       StructureType = %xlate(lo: up: InputDS.dType);
 5e                 endif;
 
                    FirstE = rrne;
 4e              endif;
 
                 IsEntityName = *off;
 3e           endif;
 
 2x        else;
              OutDS.SrcOut = InputDS.Src112;
 3b           monitor;
                 OutDS.SrcDat = InputDS.SrcDat;
 3x           on-error;
                 OutDS.SrcDat = 0;
 3e           endmon;
              OutDS.SrcSeq += .01;
              write NewSrc OutDS;
 2e        endif;
 1e     endfor;
 
       // get last one
        f_dCommonFields(FirstE:LastE);
        return;
 
       end-proc;
 
       //----------------------------
       // some fairly ugly stuff here.  First load the keywords
       // for the entity into an array and scan for
       // varying and like(+ -) and alter the data type and the
       // keywords to allow for varchar and like(field: -9)
       // *auto and quotes around non-var data structure and extnames
       //----------------------------
       dcl-proc f_dCommonFields;
        dcl-pi *n;
         pEntityStart uns(5);
         MakeGlobalLast uns(5);
        end-pi;
 
        dcl-s aa uns(5);
        dcl-s xa uns(5);
        dcl-s start uns(5);
        dcl-s end uns(5);
        dcl-s namespace varchar(148);
        dcl-s charSize char(9);
        dcl-s SizeName char(74);
        dcl-s dnobase varchar(148);
        dcl-s rebuild char(2048);
        dcl-s IsFoundDtaaraKeyword ind;
        dcl-s IsFoundExtNameKeyword ind;
       //-----------------------------------------
 
        pEntityLast = MakeGlobalLast;
        ApostropheCnt = 0;
        %len(DefineDangler) = 0;
        dddkey = *blanks;
        dddpos = 1;
        dddcnt = 0;
 
 1b     if IsStructureName;
           IsLikeDS = *off;
 1e     endif;
 
        DimSize = 0;
 1b     for rrn = pEntityStart to pEntityLast;
           chain rrn InputSrc InputDS;
 
 2b        if rrn = pEntityStart;
              dFromLen = InputDS.dFromLen;
              dLen = InputDS.dLen;
              dDataType = %xlate(lo: up: InputDS.dDataType);
              dDecimals = InputDS.dDecimals;
              dSdsType = %xlate(lo:up:InputDS.dSdsType);
              dSdsExternal = %xlate(lo:up:InputDS.dSdsExternal);
              dReservedWord = InputDS.dReservedWord;
              dComment = *blanks;
 
 3b           if StructureType = 'PR ';
                //---------------------------------------------------------
                // Use a one character field for a place
                // holder if my prototype has a like define.  Do not
                // want to move that field name into the comments.
                // otherwise move any field names in the prototype to
                // the comments as the field name are replaced with *n.
                //---------------------------------------------------------
 4b              if %len(dxname) > 1 and InputDS.dType = *blanks;
                    dComment = dxname+'  '+%triml(inputds.SrcComment);
 4x              else;
 5b                 if inputds.SrcComment > *blanks;
                       dComment = %triml(inputds.SrcComment);
 5e                 endif;
 4e              endif;
 
 3x           else;
 4b              if inputds.SrcComment > *blanks;
                    dComment = %triml(inputds.SrcComment);
 4e              endif;
 3e           endif;
 2e        endif;
 
          //-----------------------------------------
          // was doing great until strings inside quotes with + and - spacing.
          // Several keywords get extended to include quotes or the varying keyword
          // is replaced by varchar, it became impossible to retain original spacing
          // in the d specs.
          // now get the ('  ') into one string so work can begin
          // on parsing it out as a standalone process.
          // Get all the other keywords into a single string to process
          // continuation lines as a object instead across spread across different records
          //-----------------------------------------
           string = %trimr(InputDS.Src74);
 2b        if not f_IsIgnoreLine(string)
                  and InputDS.dKeyWords > *blanks;
              %subst(dddKey:dddpos:37) = InputDS.dKeyWords;
              dddpos += 37;
              dddcnt += 1;
 2e        endif;
 1e     endfor;
 
        dddkey = f_RemoveContinuationSpacing(dddcnt: dddkey);
 
       //------------------------------------------------------
       // let the reparser do the heavy lifting of breaking keywords
       // into string elements, now
       // process all the things that change lengths and keyword formats
       //------------------------------------------------------
        f_ReParseKeywords('X':'1': dnobase: dcomment: dddKey);
 
       //--------------------------------------
       // special little section here to generate missing *auto and dtaara keywords
        IsFoundDtaaraKeyword = *off; // for uds to (*auto) conversions
 1b     if dSdsType = 'U';
 2b        if KeyCnt = 0;
              KeyCnt = 1;
              EntityKeyword(1) = 'dtaara';
 
 2x        else;
 3b           for aa = 1 to KeyCnt;
 4b              if %len(EntityKeyword(aa)) >= 6  and
                    %subst(EntityKeyword(aa):1:6) = 'dtaara';
                    IsFoundDtaaraKeyword = *on; // for uds to (*auto) conversions
 4e              endif;
 3e           endfor;
 
 3b           if not IsFoundDtaaraKeyword;
                 KeyCnt += 1;
                 EntityKeyword(KeyCnt) = 'dtaara';
 3e           endif;
 2e        endif;
 1e     endif;
 
       //---------------------------------------------------------
       // generate ext keyword if extname keyword not found.
       //  extra effort as the ext keyword has to appear before any
       //  other keyword else will not compile
       // smurf
       //---------------------------------------------------------
        IsFoundExtNameKeyword = *off;
 1b     if dSdsExternal = 'E';
 2b        for aa = 1 to KeyCnt;
 3b           if %len(EntityKeyword(aa)) >= 7  and
                 %subst(EntityKeyword(aa):1:7) = 'extname';
                 IsFoundExtNameKeyword = *on;
 2v              leave;
 3e           endif;
 2e        endfor;
 
 2b        if not IsFoundExtNameKeyword;
 3b           if KeyCnt = 0;
                 KeyCnt = 1;
                 EntityKeyword(1) = 'ext';
 
 3x           else;
                // roll all keywords forward 1 position, then insert ext in first element
 4b              for aa = KeyCnt downto 1;
                    EntityKeyword(aa+1) = EntityKeyword(aa);
 4e              endfor;
                 EntityKeyword(1) = 'ext';
                 KeyCnt += 1;
 
 3e           endif;
 2e        endif;
 1e     endif;
 
       //---------------------------------------------------------
 
       //--------------------------------------
 1b     for aa = 1 to KeyCnt;
           rebuild=EntityKeyword(aa);
 2b        if rebuild = 'varying';
              dDataType = 'V';
              %len(EntityKeyword(aa))=0;
 
 2x        elseif %subst(rebuild:1:7) = 'procptr';
              DefineDangler='(*proc)';
              %len(EntityKeyword(aa))=0;
 
 2x        elseif %subst(rebuild:1:6) = 'dtaara';
              IsFoundDtaaraKeyword = *on;
              EntityKeyword(aa) =
              f_ExtendDtaara(EntityKeyword(aa): dSdsType);
 
 2x        elseif %subst(rebuild:1:6) = 'datfmt';
              exsr srLoadSuffix;
              %len(EntityKeyword(aa))=0;
 
 2x        elseif %subst(rebuild:1:6) = 'timfmt';
              exsr srLoadSuffix;
              %len(EntityKeyword(aa))=0;
 
 2x        elseif dFromLen > *blanks and
              %subst(rebuild:1:4) = 'dim(';
              exsr srLoadDimSize;
 
 2x        elseif %subst(rebuild:1:6) = 'const(';
              exsr srLoadConstant;
 
 2x        elseif (%subst(rebuild:1:5) = 'like '
              or %subst(rebuild:1:5) = 'like(' )
              and
              (%scan('+': dLen) > 0 or %scan('-': dLen) > 0);
              EntityKeyword(aa) =
              f_ExtendLikeLength(EntityKeyword(aa): dLen);
              dlen = 'LIKEXXX';
 
 2x        elseif %subst(rebuild:1:8) = 'packeven';
 2x        elseif %subst(rebuild:1:8) = 'fromfile';
             // do something here if a problem
 
 2x        elseif %subst(rebuild:1:5) = 'class';
             // D MyString S O CLASS(*JAVA: java.lang.String )
             // DCL-S MyString OBJECT(*JAVA:  java.lang.String );
             //
             // remove class keyword but let go as an entity for now.
             // it could require reparsing the string depending
             // on continuation lines.
              EntityKeyword(aa) = %subst(EntityKeyword(aa):6);
             // DefineDangler=%subst(EntityKeyword(aa):7);
 
 2x        elseif IsStructureName;
 3b           if %subst(rebuild:1:6) = 'likeds'
                 or %subst(rebuild:1:7) = 'likerec';
                 IsLikeDS = *on;
 
 3x           elseif StructureType = 'DS '
                 and %subst(rebuild:1:7) = 'extname';
                 EntityKeyword(aa) = f_DsExtName(EntityKeyword(aa));
 3e           endif;
 2e        endif;
 1e     endfor;
 
        KeyCnt = f_CompressBlankElements(KeyCnt);
 
       //------------------------------------------------------
       //------------------------------------------------------
        IsExclude = *off;
 
 1b     if  StructureType = 'S  ' or StructureType = 'C  ';
           namespace = f_NameSpaceStandAlone();
 
 1x     elseif StructureType = 'DS ';
           namespace = f_NameSpaceDataStructure();
 
 1x     elseif StructureType = 'PR ';
          // internal procedures do not need prototypes
 2b        if ExcludePr.Cnt > 0 and
              %lookup(dxname: ExcludePr.Arry: 1:
              ExcludePr.Cnt) > 0;
              IsExclude = *on;
              return;
 2e        endif;
           namespace = f_NameSpaceProtoType();
 
 1x     elseif StructureType = 'PI ';
           namespace = f_NameSpaceProcedureInterface();
 1e     endif;
 
       // do some final DS work to get positional notation keywords
 1b     if StructureType = 'DS ';
 2b        if IsStructureName;
              ds_Name = %xlate(lo: up: dxname);
 2e        endif;
 
 2b        for aa = 1 to KeyCnt;
              EntityKeyword(aa) =
              f_PosNotation(ds_Name:EntityKeyword(aa));
 2e        endfor;
 1e     endif;
 
        f_OutputBestFit(namespace:dcomment);
        return;
 
       //-------------------------------
        begsr srLoadSuffix;
       // find ( and )
        start = %scan('(':rebuild: 6);
        end = %scan(')':rebuild: start);
 1b     if start > 0 and end > 0;
           DefineDangler=
           %subst(rebuild: start: (end-start)+1);
 1e     endif;
        endsr;
 
       //-------------------------------
        begsr srLoadDimSize;
        DimSize = 1; // just in case
 
        start = %scan('(':rebuild: 4);
        end = %scan(')':rebuild: start);
 1b     if start > 0 and end > start;
 
           SizeName =
           %trim(%subst(rebuild: start+1: (end-start)-1));
 
 2b        if %check('0123456789': %trim(SizeName)) = 0;
              evalr charSize = '000000000' + %trim(SizeName);
              dimsize = %dec(charSize:9:0);
 2x        else;
              SizeName = %xlate(lo:up:SizeName);
 3b           if ConstantCnt > 0;
                 xa = %lookup(SizeName: Constant(*).Name: 1: ConstantCnt);
 4b              if xa > 0;
 5b                 if Constant(xa).Value > 0;
                       dimsize = Constant(xa).Value;
 5e                 endif;
 4e              endif;
 3e           endif;
 2e        endif;
 1e     endif;
        endsr;
 
       //-------------------------------
       // Only care about the value for numeric constants that may be a DIM(xx) later
       //-------------------------------
        begsr srLoadConstant;
 
        start = %scan('(':rebuild: 3);
        end = %scan(')':rebuild: start);
 1b     if start > 0 and end > start;
 
           SizeName =
           %trim(%subst(rebuild: start+1: (end-start)-1));
 
 2b        if %check('0123456789': %trim(SizeName)) = 0;
              evalr charSize = '000000000' + %trim(SizeName);
 
              ConstantCnt += 1;
              Constant(ConstantCnt).Name = %xlate(lo:up:dxname);
              Constant(ConstantCnt).Value = %dec(charSize:9:0);
 2e        endif;
 1e     endif;
        endsr;
 
       end-proc;
 
       //------------------------------------------------------
       // in several instances, the keyword was removed
       //  as in datfmt and timfmt keywords.
       //  here compress out the 0 length keywords and reduce keycnt
       //-----------------------------------------------------
       dcl-proc f_CompressBlankElements;
        dcl-pi *n uns(3);
         pCnt uns(3);
        end-pi;
 
        dcl-s aa uns(3);
        dcl-s bb uns(3);
 
 1b     for aa = 1 to pCnt;
 2b        if %len(EntityKeyword(aa)) = 0;
 
 3b           for bb = aa to (Pcnt-1);
                 EntityKeyword(bb) = EntityKeyword(bb+1);
 3e           endfor;
 
              pCnt -= 1;
              aa -= 1;
 2e        endif;
 1e     endfor;
 
        return pCnt;
       end-proc;
 
       //-------------------------------
       // Fixed column allows EXTNAME(File:RcdFmt:*Output) with no quotes.
       // free requires either a constant value defined before the extname or
       // that file and rcdfmt be upper cased and wrapped in quotes.
       // This is complicated as the constant could already
       // have quotes around either, both, or none of the values
       //-------------------------------
       dcl-proc f_DsExtName;
        dcl-pi *n varchar(2048);
         string varchar(2048);
        end-pi;
 
        dcl-s BigEnd uns(5);
        dcl-s curStart uns(5);
        dcl-s curEnd uns(5);
        dcl-s xx uns(3);
        dcl-s Build varchar(2048);
 
        dcl-ds *n;
         exFirst varchar(23);
         exSecond varchar(23);
         exThird varchar(23);
         exParms varchar(23) dim(3) pos(1);
        end-ds;
 
        CurStart = %scan('(':string: 3);
        BigEnd = %scan(')':string: CurStart);
 1b     if CurStart > 0 and BigEnd > CurStart;
           CurEnd = CurStart; // prime for the loop
 
 2b        for xx = 1 to 3;
              %len(exParms(xx)) = 0;
 
 3b           if CurEnd <> BigEnd;
                 CurStart = CurEnd;
                 CurEnd = f_exCurEnd(CurStart: BigEnd: string);
                 exParms(xx) = f_exTearDown(Curstart: CurEnd: string);
 3e           endif;
 2e        endfor;
 
          //---------------------------------------
          // now put back together
          //---------------------------------------
           Build = 'extname(' + exFirst;
 2b        if %len(exSecond) > 0;
              Build = Build + ':' + exSecond;
 3b           if %len(exThird) > 0;
                 Build = Build + ':' + exThird;
 3e           endif;
 2e        endif;
           Build += ')';
           return build;
 1x     else;
           return string;
 1e     endif;
       end-proc;
 
       //---------------------------------------
       // get current end of parameter
       //---------------------------------------
       dcl-proc f_exCurEnd;
        dcl-pi *n uns(5);
         Start uns(5);
         BigEnd uns(5);
         string varchar(2048);
        end-pi;
        dcl-s cc uns(5);
        cc = %scan(':':string: start+1);
 1b     if cc = 0 or cc>BigEnd;
           return BigEnd;
 1x     else;
           return cc;
 1e     endif;
       end-proc;
 
       //---------------------------------------
       // return extname parm value, quoted with no spaces
       //---------------------------------------
       dcl-proc f_exTearDown;
        dcl-pi *n varchar(23);
         start uns(5);
         curend uns(5);
         string varchar(2048);
        end-pi;
        dcl-s Polished varchar(23);
 
        Polished = %subst(string: start+1: (CurEnd-start)-1);
        Polished = %trim(%scanrpl(qs:'': Polished));
        Polished = %xlate(lo:up: Polished);
 
 1b     if polished = '*LDA' or
           (%subst(Polished:1:1) = '*' and %subst(Polished:1:2) <> '*L');
           Polished = %xlate(up:lo: Polished);
 1x     else;
           Polished = qs + Polished + qs;
 1e     endif;
 
        return Polished;
       end-proc;
 
       //----------------------------------------------
       // **** if second half of namespace is populated, write two lines ****
       // if will not fit in 74 (name too long) then load two halves
       //----------------------------------------------
       dcl-proc f_NameSpaceStandAlone;
        dcl-pi *n varchar(148) end-pi;
        dcl-s dstring varchar(148);
        dcl-s longss char(148);
 
 1b     if Dlen = 'LIKEXXX';
           dstring = 'dcl-s ' + dxname;
 
 1x     elseif StructureType = 'S '
           and dLen = ' '
           and  dDataType = ' ';
           dlen = *blanks;
           dstring = 'dcl-s ' + dxname;
 1x     else;
 
 2b        monitor;
              dLenUns = %uns(dLen);
 2x        on-error;
              dLenUns = 0;
 2e        endmon;
 
 2b        if StructureType = 'S ';
 3b           if dDataType = ' ' and dLenUns > 0;
 4b              if dDecimals > *blanks;
                    dDataType = 'P';
 4x              else;
                    dDataType = 'A';
 4e              endif;
 3e           endif;
 
             //------------------------------------
              dstring = 'dcl-s ' + dxname + ' ' +
              %trimr(%scanrpl(';':' ':
              f_GetDataTypeKeyWords(
              dDataType:
              dLenUns:
              dDecimals:DefineDangler)));
 
             //--------------------------------------------
 3b           if %len(dstring) > 74; // too long;
                 longss = 'dcl-s ' + dxname;
 
                 %subst(longss:75) =
                 %trimr(%scanrpl(';':' ':
                 f_GetDataTypeKeyWords(
                 dDataType:
                 dLenUns:
                 dDecimals:DefineDangler)));
                 dstring = %trimr(longss);
 3e           endif;
             //--------------------------------------------
 
 2x        elseif StructureType = 'C';
              dstring = 'dcl-c ' + dxname;
 2e        endif;
 1e     endif;
 
        return dstring;
       end-proc;
 
       //----------------------------------------------
       // **** if second half of namespace is populated, write two lines ****
       // if will not fit in 74 (name too long) then load two halves
       //  one section is for IsStructureName.   then not IsStructureName
       //  for all the subfields in that structure;
       //----------------------------------------------
       dcl-proc f_NameSpaceProtoType;
        dcl-pi *n varchar(148) end-pi;
        dcl-s dstring varchar(148);
        dcl-s longss char(148);
 
 1b     if Dlen = 'LIKEXXX';
 2b        if IsStructureName;
              dstring = 'dcl-pr ' + dxname;
 2x        else;
              dstring = ' *n';
 2e        endif;
 
 1x     elseif dLen = ' '
           and  dDataType = ' ';
           dlen = *blanks;
 2b        if IsStructureName;
              dstring = 'dcl-pr ' + dxname;
 2x        else;
              dstring = ' *n';
 2e        endif;
 1x     else;
 
 2b        monitor;
              dLenUns = %uns(dLen);
 2x        on-error;
              dLenUns = 0;
 2e        endmon;
 
 2b        if dDataType = ' ' and dLenUns > 0;
 3b           if dDecimals > *blanks;
                 dDataType = 'P';
 3x           else;
                 dDataType = 'A';
 3e           endif;
 2e        endif;
 
          //------------------------------------
 2b        if IsStructureName;
              dstring = 'dcl-pr ' + dxname + ' ' +
              %trimr(%scanrpl(';':' ':
              f_GetDataTypeKeyWords(
              dDataType:
              dLenUns:
              dDecimals:DefineDangler)));
 2x        else;
              dstring = ' *n ' +
              %trimr(%scanrpl(';':' ':
              f_GetDataTypeKeyWords(
              dDataType:
              dLenUns:
              dDecimals:DefineDangler)));
 2e        endif;
 
          //--------------------------------------------
 2b        if %len(dstring) > 74; // too long;
 3b           if IsStructureName;
                 longss = 'dcl-pr ' + dxname;
 3x           else;
                 longss = ' *n ';
 3e           endif;
 
              %subst(longss:75) =
              %trimr(%scanrpl(';':' ':
              f_GetDataTypeKeyWords(
              dDataType:
              dLenUns:
              dDecimals:DefineDangler)));
 
              dstring = %trimr(longss);
 2e        endif;
          //--------------------------------------------
 1e     endif;
 
        return dstring;
       end-proc;
 
       //----------------------------------------------
       // sds converts to psds and predefined subfields look like this
       //  DCL-DS pgm_stat PSDS;
       //  status *STATUS;
       //  routine *ROUTINE;
       //  END-DS;
       //----------------------------------------------
       dcl-proc f_NameSpaceDataStructure;
        dcl-pi *n varchar(148) end-pi;
        dcl-s dstring varchar(148);
        dcl-s longss char(148);
        dcl-s dummyup varchar(37);
        dcl-s len1 uns(3);
        dcl-s len2 uns(3);
        dcl-s len3 uns(3);
 
 1b     if %len(dxname) = 0;
           dxname = '*n';
 1e     endif;
 
 1b     if Dlen = 'LIKEXXX';
 2b        if IsStructureName;
              dstring = 'dcl-ds ' + dxname;
 2x        else;
              dstring = ' ' + dxname;
 2e        endif;
 
 1x     elseif %subst(dReservedWord:1:1) = '*';
           dstring = ' ' + dxname + ' ' + %trim(dReservedWord);
 
 1x     elseif dLen = ' '
           and  dDataType = ' ';
           dlen = *blanks;
 2b        if IsStructureName;
              dstring = 'dcl-ds ' + dxname;
 2x        else;
              dstring = ' ' + dxname;
 2e        endif;
 1x     else;
 
 2b        monitor;
              dLenUns = %uns(dLen);
 2x        on-error;
              dLenUns = 0;
 2e        endmon;
 
 2b        monitor;
              dFromLenUns = %uns(dFromLen);
 2x        on-error;
              dFromLenUns = 0;
 2e        endmon;
 
          //------------------------------------------------------------------
          // Convert from/to notation to datatype() and
          // pos() notation.   Already have code to convert overlay(:)
          // to pos so dummy up a overlay(data structure name:from)
          // keyword and let the f_PosNotation function do the dirty work.
          //------------------------------------------------------------------
 2b        if dFromLenUns > 0;
 3b           if not(dDataType = 'G' or dDataType = 'O');
 
                 dLenUns = (dLenUns - dFromLenUns) + 1;
 
 4b              if dDataType = ' ';
 5b                 if dDecimals > *blanks;
                       dDataType = 'S';
 5x                 else;
                       dDataType = 'A';
 5e                 endif;
 
 4x              elseif dDataType = 'B';
                    dDataType = 'I';
 5b                 if dLenUns = 2;
                       dLenUns = 5;
 5x                 elseif dLenUns = 4;
                       dLenUns = 10;
 5e                 endif;
 
 4x              elseif dDataType = 'I' or dDataType = 'U';
 5b                 if dLenUns = 1;
                       dLenUns = 3;
 5x                 elseif dLenUns = 2;
                       dLenUns = 5;
 5x                 elseif dLenUns = 4;
                       dLenUns = 10;
 5e                 endif;
 
 4x              elseif dDataType = 'P';
                    dLenUns = (2 * dLenUns) - 1;
 4e              endif;
 
 4b              if DimSize > 0;
                    dLenUns /= DimSize;
 4e              endif;
 
                 dummyup =
                 'OVERLAY('+ds_name+':'+ %trimr(%char(dFromLenUns)) + ')';
 
 4b              if KeyCnt > 0;
                    len1 = %len(EntityKeyword(KeyCnt));
                    len2 = %len(dummyup);
                    len3 = %len(EntityKeyword(1));
 4e              endif;
 
                // see if pos will fit on same line
 4b              if KeyCnt > 0
                    and ((len1 + len2 + 1) <= len3);
                    EntityKeyword(KeyCnt) =
                    %trimr(EntityKeyword(KeyCnt)) +' '+ dummyup;
 4x              else;
                    KeyCnt += 1;
                    EntityKeyword(KeyCnt) = dummyup;
 4e              endif;
 
 3e           endif;
 2e        endif;
 
          //------------------------------------------------------------------
 2b        if dDataType = ' ' and dLenUns > 0;
 3b           if dDecimals > *blanks;
                 dDataType = 'S';
 3x           else;
                 dDataType = 'A';
 3e           endif;
 2e        endif;
 
          //------------------------------------
          // data structures data types are len() so pass arbitrary
          //  & character so function will return len() instead of char()
 2b        if IsStructureName;
              dDataType = '&';
              dstring = 'dcl-ds ' + dxname + ' ' +
              %trimr(%scanrpl(';':' ':
              f_GetDataTypeKeyWords(
              dDataType:
              dLenUns:
              dDecimals:DefineDangler)));
 2x        else;
              dstring = ' ' + dxname + ' ' +
              %trimr(%scanrpl(';':' ':
              f_GetDataTypeKeyWords(
              dDataType:
              dLenUns:
              dDecimals:DefineDangler)));
 2e        endif;
 
          //--------------------------------------------
 2b        if %len(dstring) > 74; // too long;
 3b           if IsStructureName;
                 longss = 'dcl-ds ' + dxname;
                 dDataType = '&';
 3x           else;
                 longss = ' ' + dxname;
 3e           endif;
 
              %subst(longss:75) =
              %trimr(%scanrpl(';':' ':
              f_GetDataTypeKeyWords(
              dDataType:
              dLenUns:
              dDecimals:DefineDangler)));
              dstring = %trimr(longss);
 2e        endif;
 1e     endif;
 
 1b     if IsStructureName
           and (dSdsType = 's' or dSdsType = 'S');
 2b        if (dSdsExternal = 'e' or dSdsExternal='E');
              dstring += ' ext PSDS';
 2x        else;
              dstring += ' PSDS';
 2e        endif;
 1e     endif;
 
        return dstring;
       end-proc;
 
       //----------------------------------------------
       //----------------------------------------------
       dcl-proc f_NameSpaceProcedureInterface;
        dcl-pi *n varchar(148) end-pi;
        dcl-s dstring varchar(148);
        dcl-s longss char(148);
 
 1b     if %len(dxname) = 0;
           dxname = '*n';
 1e     endif;
 
 1b     if Dlen = 'LIKEXXX';
 2b        if IsStructureName;
              dstring = 'dcl-pi ' + dxname;
 2x        else;
              dstring = ' ' + dxname;
 2e        endif;
 
 1x     elseif dLen = ' '
           and  dDataType = ' ';
           dlen = *blanks;
 2b        if IsStructureName;
              dstring = 'dcl-pi ' + dxname;
 2x        else;
              dstring = ' ' + dxname;
 2e        endif;
 1x     else;
 
 2b        monitor;
              dLenUns = %uns(dLen);
 2x        on-error;
              dLenUns = 0;
 2e        endmon;
 
 2b        if dDataType = ' ' and dLenUns > 0;
 3b           if dDecimals > *blanks;
                 dDataType = 'P';
 3x           else;
                 dDataType = 'A';
 3e           endif;
 2e        endif;
 
          //------------------------------------
 2b        if IsStructureName;
              dstring = 'dcl-pi ' + dxname + ' ' +
              %trimr(%scanrpl(';':' ':
              f_GetDataTypeKeyWords(
              dDataType:
              dLenUns:
              dDecimals:DefineDangler)));
 2x        else;
              dstring = ' ' + dxname + ' ' +
              %trimr(%scanrpl(';':' ':
              f_GetDataTypeKeyWords(
              dDataType:
              dLenUns:
              dDecimals:DefineDangler)));
 2e        endif;
 
          //--------------------------------------------
 2b        if %len(dstring) > 74; // too long;
 3b           if IsStructureName;
                 longss = 'dcl-pi ' + dxname;
 3x           else;
                 longss = ' ' + dxname;
 3e           endif;
 
              %subst(longss:75) =
              %trimr(%scanrpl(';':' ':
              f_GetDataTypeKeyWords(
              dDataType:
              dLenUns:
              dDecimals:DefineDangler)));
              dstring = %trimr(longss);
 2e        endif;
          //--------------------------------------------
 1e     endif;
 
        return dstring;
       end-proc;
 
       //----------------------------------------------------
       // Reformat continuation lines as keywords were expanded
       // or contracted.  This function removes the + and minus - sign continuation
       // while adjusting the string so the desired spacing is retained.
 
       // 'extproc(*java                        : aclass               '
       // '              : 'getSmack')
 
       //    converts to
       // 'extproc(*java:aclass:'getSmak')
       //
       // When time comes to write this back out, may
       // have to split on a : or reassign + -  continuation spacing.
       //----------------------------------------------------
       dcl-proc f_RemoveContinuationSpacing;
        dcl-pi *n char(2048);
         LoopCnt uns(5);
         pstring char(2048);
        end-pi;
 
        dcl-s block char(37) based(bptr);
        dcl-s aa uns(5);
        dcl-s slampos uns(5);
        dcl-s NewString varchar(2048);
 
 1b     if LoopCnt = 0;
           return pstring;
 1e     endif;
 
        %len(NewString) = 0;
        bptr = %addr(pstring);
        newstring = %trim(block);
 
 1b     for aa = 2 to LoopCnt;
           bptr += 37;
           slampos = %len(newstring);
 
 2b        if %subst(newstring:slampos:1) = '+';
              %len(newstring) -= 1;  // drop +
              newstring += %trim(block);
 
 2x        elseif %subst(newstring:slampos:1) = '-';
              %len(newstring) -= 1;  // drop -
              newstring += %trimr(block);
 
 2x        else;
              newstring = newstring + ' ' + %trimr(block);
 2e        endif;
 1e     endfor;
 
        return newstring;
       end-proc;
 
       //--------------------------------------------------
       // if the overlay name is the same as the ds name,
       // get positional notation.
       // EntityKeyword(XX) = overlay(GetAllocSizeDS:5)
       // would change to pos(5)
       // if not same name, then leave overlay notation
       // Watch out for between quotes and ignore those
       //--------------------------------------------------
       dcl-proc f_PosNotation;
        dcl-pi *n varchar(2048);
         pDsName varchar(74);
         pString varchar(2048);
        end-pi;
 
        dcl-s loc uns(3);
        dcl-s xx uns(3);
        dcl-s string varchar(94);
        dcl-s comparestring varchar(74);
        dcl-s OvrEnd uns(3);
        dcl-s ColonPos uns(3);
        dcl-s NextKeyWord uns(3);
        dcl-s EndCap varchar (10);
 
        string = %trimr(%xlate(lo: up: pString));
        Loc = %scan('OVERLAY(':string);
 1b     if loc > 0;
           Loc = f_ReturnZeroIfBetweenQuotes(Loc:string);
 2b        if loc > 0;
 
             // extract the overlay name (name:2)
             //  watch out for (name), change these to POS(1)
              xx = %scan(':': string: loc+8);
 3b           if xx = 0;
                 xx = %scan(')': string: loc+8);
 3e           endif;
 3b           if xx = 0;
                 return pstring;
 3x           else;
                 comparestring =
                 %trim(%subst(string: loc+8: xx-(loc+8)));
 4b              if comparestring = pDsName;
                    exsr srgetpositionalnotation;
 4e              endif;
 3e           endif;
 
             //------------------------------------------
 2e        endif;
 1e     endif;
        pstring = %trim(pstring);
        return pstring;
 
       // inz overlay(GetAllocSizeDS:5) aaa = inz pos(5) aaa
       // remove overlay, remove name, remove :
       // loc and OvrEnd is my range
 
        begsr srgetpositionalnotation;
        OvrEnd = %scan(')': pString: loc+8);
        ColonPos = %scan(':': Pstring: loc+8);
 1b     if ColonPos > OvrEnd;
           ColonPos = 0;
 1e     endif;
 1b     if ColonPos = 0;
           EndCap = '1)';
 1x     else;
           EndCap = %subst(pstring: ColonPos+1: (OvrEnd-Colonpos));
 1e     endif;
 
 1b     if %scan('*NEXT': %xlate(lo:up:EndCap)) > 0;
           %len(pstring) = 0;
           return pstring;
 1e     endif;
 
        %subst(pstring: Loc: (OvrEnd-Loc)+1) = 'pos('+EndCap;
 
       // now go back and compress out any spaces between the end cap
       // and the next keyword
        xx = %scan(')': pString: loc);
        NextKeyWord = %check(' ':pstring:xx+1);
 1b     if NextKeyWord > 0;
           %subst(pstring: xx + 2) =
           %subst(pstring: NextKeyWord);
 1e     endif;
        endsr;
       end-proc;
 
       //----------------------------------------------------
       // Output from +len or -len is second parm of like keyword
       // and cannot have spaces between the + and number
       // '+   1' is not valid.  +1 is valid.
       //----------------------------------------------------
       dcl-proc f_ExtendLikeLength;
        dcl-pi *n varchar(2048);
         string varchar(2048);
         len char(7);
        end-pi;
 
        dcl-s cpar uns(5); // close parenth
        dcl-s compressedlen varchar(7);
 
        compressedlen = %scanrpl(' ':'': len);
 
        cpar = %scan(')':string:5);
        %subst(string:cpar) = ':';
        string = string + compressedlen + ')';
        return string;
       end-proc;
 
       //----------------------------------------------------
       // Dtaara(*VAR : runtimeDA)  - dtaara(runtimeDA)
       // Dtaara(runtimeDA)         - dtaara('RUNTIMEDA')
       // uds dtaara(TESTX73)       - dtaara(*auto: 'TESTX73')
       // uds dtaara(*lda)          - dtaara(*auto: *LDA);
       // uds                       - dtaara(*auto)
       // uds dtaara                - dtaara(*auto)
       // Dtaara                    - dtaara
       //----------------------------------------------------
       dcl-proc f_ExtendDtaara;
        dcl-pi *n varchar(2048);
         string varchar(2048);
         uds char(1);
        end-pi;
 
 1b     if uds = 'U';
          //--------------------------------
 2b        if string = 'dtaara';
              string = string + '(*auto)';
              return string;
 
             //--------------------------------
 2x        elseif %scan('dtaara':string) = 0;
              string = 'dtaara(*auto) ' + string;
              return string;
 
             //--------------------------------
 2x        elseif %scan('*lda':string) > 0
              and %scan('*auto':string) = 0;
              string = %scanrpl('*lda':'*auto: *lda':string);
              return string;
 
             //--------------------------------
 2x        elseif %scan('*var':string) > 0;
              string = %scanrpl('*var':'*auto':string);  // replace *var
              return string;
 
             //--------------------------------
 2x        elseif %scan('*auto':string) = 0;
              string = %scanrpl('(':'(*auto: ':string);  // add *auto
 2e        endif;
 1e     endif;
 
       //--------------------------------
 1b     if %scan('*var':string) > 0;
           string = %scanrpl('*var':'': string);  // get rid of *var
           string = %scanrpl(':':'': string);     // get rid of :
           string = %scanrpl(' ':'': string);     // remove : space
           return string;
 1e     endif;
 
       //--------------------------------
 1b     if string <> 'dtaara';
           string = %scanrpl('extname(':'dtaara(':f_DsExtName(string));
 1e     endif;
        return string;
       end-proc;
 
       //----------------------------------------------------
       // Write DCL-PROC END-PROC statements
       //----------------------------------------------------
       dcl-proc f_PspecWrite;
        dcl-pi *n;
         pFirst uns(5);
         pLast uns(5);
        end-pi;
 
        dcl-s keywords char(2048);
        dcl-s rrn uns(5);
        dcl-s pcomment char(20);
        dcl-s string varchar(94);
        dcl-s pstring varchar(148);
        dcl-s dots uns(3);
        dcl-s prNameSpace varchar(74);
 
        Dots = 0;
        StructureType = *blanks;
        %len(prNameSpace) = 0;
 
       //------------------------------------------------------
       // get the P NAME or NAME...
       //  If ... start getting attributes at the next record.
       //------------------------------------------------------
       // build keyword string.
 1b     for rrn = pFirst to pLast;
           chain rrn InputSrc InputDS;
 
           string = %trimr(InputDS.Src74);
 2b        if not f_IsIgnoreLine(string);
 
 3b           if rrn = pFirst;
                 Dots = f_EllipsisLoc(InputDS.Src74);
 
                // Deal with ... to extract field name
 4b              if Dots = 0;
                    prNameSpace = %trim(%subst(InputDS.Src74:1:15));
                    exsr srpCommonFields;
 4x              else;
                    prNameSpace = %trim(%subst(InputDS.Src74:1:Dots-1));
 4e              endif;
 
                 CurrPrName = %xlate(lo: up: prNameSpace);       // for file arry match
 
 3x           elseif (rrn = pFirst + 1) and Dots > 0;
                 exsr srpCommonFields;
 
 3x           else;
                 KeyWords = %trimr(Keywords) + ' '
                 + %triml(InputDS.dKeyWords);
 3e           endif;
 2e        endif;
 1e     endfor;
 
       //------------------------------------------------------------------
 1b     if StructureType = 'B';
           pstring = 'dcl-proc ' + prNameSpace;
 1x     elseif structureType = 'E';
           pstring = 'end-proc';
 1e     endif;
 
        f_ReParseKeywords('P':'1': pstring: pcomment: KeyWords);
        return;
 
       //----------------------------
        begsr srpCommonFields;
        StructureType = %xlate(lo: up: InputDS.dType);
        KeyWords = ' ' + %triml(InputDS.dKeyWords);
        pComment = inputds.SrcComment;
        endsr;
       end-proc;
 
       //----------------------------------------------------
       // get all H specs into a string, then call reparse to compress
       // to full line use.
       // unless hspec has compiler directive, then just write back out as-is
       //  ....5...10...15...20.
       //  /IF DEFINED(*V6R1M0)
       //  /ELSE
       //  /ENDIF
       //----------------------------------------------------
       dcl-proc f_HspecWrite;
        dcl-pi *n;
         pFirst uns(5);
         pLast uns(5);
        end-pi;
 
        dcl-s keywords char(2048);
        dcl-s rrn uns(5);
        dcl-s ctlopt varchar(148) inz('ctl-opt');
        dcl-s hcomment char(20);
        dcl-s string varchar(94);
 
       // check for embedded compiler directives
 1b     for rrn = pFirst to pLast;
           chain rrn InputSrc InputDS;
 2b        if f_CompilerDirective(InputDS.Src74);
 3b           for rrn = pFirst to pLast;
                 chain rrn InputSrc InputDS;
                 f_WriteAsIs();
 3e           endfor;
              return;
 2e        endif;
 1e     endfor;
 
       // build keyword string.
 1b     for rrn = pFirst to pLast;
           chain rrn InputSrc InputDS;
           string = %trimr(InputDS.Src74);
 2b        if not f_IsIgnoreLine(string);
              KeyWords = %trimr(keywords) + ' ' + %triml(InputDS.Src74);
 3b           if hcomment = *blanks;
                 hcomment = inputds.SrcComment;
 3e           endif;
 2e        endif;
 1e     endfor;
 
        f_ReParseKeywords('H':'1': CtlOpt: Hcomment: KeyWords);
        return;
       end-proc;
 
       //------------------------------------------------------------------
       // return *on if ... is not between ( ) like inz('...')
       //------------------------------------------------------------------
       dcl-proc f_IsInEllipsis  export;
        dcl-pi *n ind;
         string char(74);
        end-pi;
 
       // ignore ... in the keywords section
 1b     if %len(%trimr(string)) > 35 and
           %subst(string:1:35) = *blanks;
           return *off;
 1e     endif;
 
 1b     If %scan('...':string) > 0
           and (%scan('(':string) = 0
           or %scan('...':string) < %scan('(':string));
           return *on;
 1x     else;
           return *off;
 1e     endif;
       end-proc;
 
       //----------------------------------------------------
       // see if compiler directives are contained in entity
       //  ....5...10...15...20.
       //  /IF DEFINED(*V6R1M0)
       //  /ELSE
       //  /ENDIF
       //----------------------------------------------------
       dcl-proc f_CompilerDirective;
        dcl-pi *n ind;
         pstring char(74);
        end-pi;
        dcl-s string char(74);
        string =%triml(%xlate(lo: up: pstring));
 1b     if %subst(string:1:1) = '/'
           and %check(up: %subst(string:2:1)) =0;
           return *on;
 1x     else;
           return *off;
 1e     endif;
       end-proc;
