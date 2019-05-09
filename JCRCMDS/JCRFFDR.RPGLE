       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRFFDR - File Field Descriptions - print/display
       //  call API to retrieve file field descriptions.
       //   load entries to array and QLGSORT them into sequence.
       //    Output information to selected media type.
 
       // V7 added show if field CCSID is different than default ccsid of job.
       //  you will across some IBM files with CCSID of 65535 and have to use
       //     cast(Field as varchar(Length) CCSID 37)  to sql
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCRFFDP printer oflind(IsOverFlow) usropn indds(indp);
       dcl-f JCRFFDD workstn sfile(sbfdta1: rrn1) infds(infds)
       sfile(windta3: rrn3) indds(ind) sfile(windta4: rrn4) usropn;
 
       dcl-f JCRFFDF usage(*output) extfile(extofile) extmbr(extombr) usropn;
       dcl-f RPGSRC disk(112) usage(*output) extfile(extofile) extmbr(extombr)
       usropn;
 
       /define ApiErrDS
       /define Constants
       /define Dspatr
       /define Infds
       /define Sds
       /define FunctionKeys
       /define Ind
       /define f_BuildString
       /define Qdbrtvfd
       /define Qlgsort
       /define Quslfld
       /define BitMask
       /define f_DisplayLastSplf
       /define f_GetQual
       /define f_OvrPrtf
       /define f_Dltovr
       /define f_GetDayName
       /define f_Quscrtus
       /define f_SndCompMsg
       /define f_GetFileUtil
       /define f_RunOptionFile
       /define f_GetDataTypeKeyWords
       /define f_CamelCase
       /define SourceOutDS
       /define f_RmvSflMsg
       /define f_SndSflMsg
       // *ENTRY
       /define p_JCRFFDR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s QualActual char(21);
       dcl-s FileActual char(10);
       dcl-s LibActual char(10);
       dcl-s KeyFldsArry char(10) dim(50);
       dcl-s KeySeqArry char(1) dim(50);
       dcl-s SwapName char(10);
       dcl-s SortByFld char(10);
       dcl-s SearchKey char(3);
       dcl-s extOMbr char(10);
       dcl-s SortOverlay char(200) based(sortptr);
       dcl-s KeyCount like(filescopearry.numofkeys);
       dcl-s SoCount like(filescopearry.numselectomit);
       dcl-s ParmCount like(selectomitspec.numberofparms);
       dcl-s RcdFmtCount like(fild0100ds.numrcdfmts);
       dcl-s LengthOfBuffer int(10);
       dcl-s NextFrom uns(5) inz(1);
       dcl-s rrn1 like(rrn);
       dcl-s rrn3 like(rrn);
       dcl-s rrn4 like(rrn);
       dcl-s IsToggleAlias ind;
       dcl-s IsToggleKeys ind;
       dcl-s IsSearch ind;
       dcl-s IsFiltered ind;
       dcl-s IsFirstTime ind;
       dcl-s fscopePtrSave pointer;
       dcl-s PrtRrn like(rrn) inz(0);
       dcl-s unsignedlength uns(10);
       dcl-s DecimalPos char(2);
 
       dcl-ds indp qualified;  // print file indicator
        IsUnPacked ind pos(09) inz;
       end-ds;
 
       dcl-ds QusrjobiDS qualified;
        JobDefaultCCSID int(10) pos(373);
       end-ds;
 
       dcl-pr qusrjobi extpgm('QUSRJOBI'); // retrieve job info
        *n like(QusrjobiDS);
        *n int(10) const;
        *n char(8) const;
        *n char(26) const;
        *n char(16) const;
        *n like(apierrds);
       end-pr;
 
       dcl-ds ScreenFieldDS extname('JCRFFDF') inz end-ds;
 
       //-----List fields not populated
       dcl-pr  p_JCRNOTPOPR  extpgm('JCRNOTPOPR');
        *n char(20) const;
        *n char(10) const;
        *n char(8)  const;
       end-pr;
 
       //---------------------------------------------------------
       // get default job ccsid
       callp QUSRJOBI(
             QusrjobiDS:
             %size(QusrjobiDS):
             'JOBI0400':
             '*       ':
             '                ':
             ApiErrDs);
       scjobccsid = %char(QusrjobiDS.JobDefaultCCSID);
 
       //---------------------------------------------------------
       f_RmvSflMsg(ProgId);
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
       f11Show = 'Keys';
       ccsidhead = *blanks;
 
       // Open appropriate output file depend on type
 1b    if p_Output = '*';  //DISPLAY
          open JCRFFDD;
          scDow = f_GetDayName();
          DbUtility = 'F15=' + f_GetFileUtil();
 
 1x    elseif p_Output = '*PRINT';
          f_OvrPrtf('JCRFFDP': '*JOB': %subst(p_FileQual: 1: 10));
          open JCRFFDP;
          scDow = f_GetDayName();
          indp.IsUnPacked = (p_UnPack = '*YES');
 
 1x    elseif p_Output = '*OUTFILE';
          extOmbr = %subst(p_OutMbrOpt: 3: 10);
          extOfile = f_GetQual(p_OutFileQual);
          open JCRFFDF;
 
 1x    elseif p_Output = '*SRC';
          extOmbr = %subst(p_OutMbrOpt: 3: 10);
          extOfile = f_GetQual(p_OutFileQual);
          open RPGSRC;
 1e    endif;
       FldOrAlias = 'Field';
       IsFirstTime = *on;
 
       //---------------------------------------------------------
       // Load file Header information / get offset to key array
       // API can return data longer than will fit in RPG variable
       //---------------------------------------------------------
       AllocatedSize = f_GetAllocatedSize(p_FileQual: p_RcdFmt);
       Fild0100ptr = %alloc(AllocatedSize);
       callp QDBRTVFD(
             Fild0100ds:
             AllocatedSize:
             ReturnFileQual:
             'FILD0100':
             p_FileQual:
             p_RcdFmt:
             '0':
             '*FILETYPE':
             '*EXT':
             ApiErrDS);
 
       FileActual = %subst(p_FileQual: 1: 10);
       LibActual = %subst(ReturnFileQual: 11: 10);
 
       scObjHead =
       f_BuildString('&  &  &':
       FileActual: LibActual: Fild0100ds.FileText);
 
       RecordLen = Fild0100ds.FileRecLen;
       FieldCount = Fild0100ds.NumOfFlds;
 
       // extract bit info for file type
 1b    if %bitand(bit2: Fild0100ds.TypeBits) = bit2;
          FileType4 = '*LF';
 1x    else;
          FileType4 = '*PF';
 1e    endif;
 
       QualActual = f_GetQual(FileActual + LibActual);
 
       exsr srLoadRcdFmtInfo;
 
       //---------------------------------------------------------
 1b    if p_Output = '*';
          exsr srProcessSubfile;
          f_SndCompMsg('JCRFFD for ' +
          %trimr(QualActual) + ' - completed');
 
 1x    elseif p_Output = '*PRINT';
          f_Dltovr('JCRFFDP');
          close JCRFFDP;
          f_DisplayLastSplf('JCRFFDR': p_Output);
 
 1x    elseif p_Output = '*OUTFILE';
          close JCRFFDF;
          f_SndCompMsg('Outfile ' + %trimr(extOfile) +
          ' generated by JCRFFD.');
 1e    endif;
 
       dealloc(n) Fild0100ptr;
       *inlr = *on;
       return;
       write assume;
 
       //---------------------------------------------------------
       begsr srProcessSubfile;
 1b    if Fild0100ds.NumRcdFmts  > 1;
          MultiFmts = 'Press F4 to select format';
          aF4key = Blue;
 1x    else;
          MultiFmts = *blanks;
          aF4key = ND;
 1e    endif;
 
 1b    if p_UnPack = '*NO';
          MSGUNPACK = *blanks;
 1x    else;
          MSGUNPACK = '*UNPACKED';
          RecordLen = sbToPos;
 1e    endif;
       FldOrAlias = 'Field';
 
 1b    if FileScopeArry.NumSelectOmit > 0;
          aF7key = Blue;
 1x    else;
          aF7key = ND;
 1e    endif;
 
       //---------------------------------------------------------
 1b    dou 1=2;
          Ind.sfldsp = rrn1 > 0;
          Ind.sfldspctl = *on;
          write msgctl;
          write sfooter1;
          exfmt sbfctl1;
          IsSearch = *off;
          f_RmvSflMsg(ProgId);
 
 2b       if InfdsFkey = f03 or InfdsFkey = f12;
 LV          leavesr;
 
 2x       elseif InfdsFkey = f04
             and Fild0100ds.NumRcdFmts > 1;
             exsr srPromptRcdFmt;
 
 2x       elseif InfdsFkey = F06;
             exsr srPrintScreen;
             f_SndSflMsg(ProgId: '** Print Completed **');
 
 2x       elseif InfdsFkey = F07
             and FileScopeArry.NumSelectOmit > 0;
             exsr srSelectOmit;
 
 2x       elseif InfdsFkey = f08;
             IsToggleAlias = *on;
 3b          if FldOrAlias = 'Field';
                FldOrAlias = 'ALIAS';
 3x          else;
                FldOrAlias = 'Field';
 3e          endif;
 
 3b          for rrn1 = 1 to ApiHead.ListEntryCount;
                chain rrn1 sbfdta1;
 4b             if FldAlias > *blanks;
                   SwapName = sbField;
                   sbField = FldAlias;
                   FldAlias = SwapName;
 4e             endif;
                update sbfdta1 %fields(FldAlias: sbField);
 3e          endfor;
 
 2x       elseif InfdsFkey = f09;
             f_SndSflMsg(ProgId: 'Sort by Field Name');
             f11Show = 'Keys';
             SortByFld = 'SBFIELD';
             exsr srResequence;
 
 2x       elseif InfdsFkey = f10;
             f_SndSflMsg(ProgId: 'Sort by Position');
             f11Show = 'Keys';
             SortByFld = 'SBFROMPOS';
             exsr srResequence;
 
 2x       elseif InfdsFkey = f11;
 3b          if f11Show = 'Keys';
                f11Show = 'Fields';
                SortByFld = 'SBKEY';
                SearchKey = 'Key';
                IsSearch = *on;
                exsr srResequence;
                SearchKey = *blanks;
 3x          else;
                f11Show = 'Keys';
                SortByFld = 'SBFROMPOS';
                exsr srResequence;
 3e          endif;
 
 2x       elseif InfdsFkey = f15;
             f_RunOptionFile(2: FileActual: LibActual:
             '*FIRST': '*FIRST': ProgId);
 
 2x       elseif InfdsFkey = f16;
             callp p_JCRNOTPOPR(FileActual+ LibActual:'*FIRST':'*');
 
 2x       elseif SearchTxt > *blanks
             or SearchFld > *blanks
             or SearchLen > 0;
             IsSearch = *on;
             SortByFld = *blanks;
             exsr srResequence;
 2x       else;
             SortByFld = *blanks;
             exsr srResequence;
 2e       endif;
 1e    enddo;
       endsr;
 
       //---------------------------------------------------------
       begsr srReadUserSpace;
       aF8Key = ND;
       FromFile = FileActual;
       FileLib = LibActual;
 
       QuslfldPtr = ApiHeadPtr + ApiHead.OffSetToList;
       SortPtr = QuslfldPtr;
 
 1b    for ForCount = 1 to ApiHead.ListEntryCount;
          sbField = QuslfldDS.FieldName;
          FldText50 = QuslfldDS.FieldText;
          FldAlias = QuslfldDS.AliasName;
 2b       if QuslfldDS.AliasName > *blanks;
             aF8Key = Blue;
 2e       endif;
 
 2b       if FldText50 = *blanks
             and FldAlias > *blanks; // show alias if no text
             FldText50 = FldAlias;
 2e       endif;
 
          // Determine if field Key field and A or Descending
          aa = %lookup(sbField: KeyFldsArry: 1: KeyCount);
 2b       if aa > 0;
 3b          if aa<=9;
                sbKey = KeySeqArry(aa) + '0'+ %char(aa);
 3x          else;
                sbKey = KeySeqArry(aa) + %char(aa);
 3e          endif;
 2x       else;
             sbKey = *blanks;
 2e       endif;
 
          //---------------------------------------------------------
          // Calculate ending position of each field.
          //---------------------------------------------------------
 2b       if QuslfldDS.Digits > 0; // numeric
             unsignedlength = QuslfldDS.Digits;
             DecimalPos = %triml(%editc(QuslfldDS.DecimalPos:'3'));
 2x       else;
             unsignedlength = QuslfldDS.FieldLengthA;
             DecimalPos = *blanks;
 2e       endif;
 
          sbDataType = %scanrpl(';':' ':
          f_GetDataTypeKeyWords(
          QuslfldDS.FieldType:
          unsignedlength:
          DecimalPos));
 
          sbLength = unsignedlength;  // for length searches
 
 2b       if p_UnPack = '*NO';
             sbFromPos = QuslfldDS.InputPosition;
             sbToPos = QuslfldDS.OutputPosition + QuslfldDS.FieldLengthA - 1;
 2x       else;
             // calculate from and to positions if *un-packed
             sbFromPos = NextFrom;
             NextFrom = sbFromPos + sbLength;
             sbToPos = NextFrom - 1;
 2e       endif;
 
          SBCCSID = *blanks;
 2b       if QuslfldDS.FieldCCSID > 0;
 3b          if QuslfldDS.FieldCCSID <> QusrjobiDS.JobDefaultCCSID;
                ccsidhead = 'CCSID Field <> Job';
                SBCCSID = %char(QuslfldDS.FieldCCSID);
 3e          endif;
 2e       endif;
 
          // write to output type
          //-----------------------------------------------------------------
          //  use a particulary sleazy,obscure overlay of an unused
          //   portion of the user space entry to store my screen fields,
          //    after the sort I can just pull the fields back out without re-processing.
          //-----------------------------------------------------------------
 2b       if p_Output = '*';
             %subst(QuslfldDS:101: %len(ScreenFieldDS)) = ScreenFieldDS;
             sbTxt = f_CamelCase(FldText50);
             rrn1 += 1;
             PrtRrn += 1;
             write sbfdta1;
 
 2x       elseif p_Output = '*PRINT';
             FldText45 = FldText50;
             write PrtDetail;
 3b          if IsOverFlow;
 
 4b             if ForCount <> ApiHead.ListEntryCount; // avoid last blank page
                   write PrtPageBrk;
 4e             endif;
 
                IsOverFlow = *off;
 3e          endif;
 
 2x       elseif p_Output = '*OUTFILE';
             write JCRFFDFR;
 
 2x       elseif p_Output = '*SRC';
             OutDS.SrcCod = ' clear ' + %trimr(sbField) + ';';
             OutDS.SrcSeq += 1;
             write RPGSRC OutDS;
 2e       endif;
 
          QuslfldPtr += ApiHead.ListEntrySize;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // get pointer to file scope array for record format
       //---------------------------------------------------------
       begsr srLoadRcdFmtInfo;
       fscopePtr = Fild0100ptr + Fild0100ds.OffsFileScope;
 1b    for RcdFmtCount = 1 to Fild0100ds.NumRcdFmts;
 2b       if p_RcdFmt = '*FIRST'
             or p_RcdFmt = FileScopeArry.RcdFmt;
 1v          leave;
 2e       endif;
          fscopePtr += 160;  //next record format
 1e    endfor;
 
       // load field definitions for record format
       callp QUSLFLD(
             UserSpaceName:
             'FLDL0100':
             p_FileQual:
             FileScopeArry.RcdFmt:
             '0':
             ApiErrDS);
 
       // Load Key Fields array for checking against
       scRcdFmt = FileScopeArry.RcdFmt;
       KeyList = '*NONE';
 
 1b    if %bitand(bit6: Fild0100ds.TypeBits) = bit6;  // keyed access path
          KeyList = *blanks;
          KeySpecsPtr = Fild0100ptr + FileScopeArry.OffsKeySpecs;
 
 2b       for KeyCount = 1 to FileScopeArry.NumOfKeys;
             KeyList = %trimr(KeyList) + '  ' + KeySpecsDS.KeyFieldName;
             KeyFldsArry(KeyCount) = KeySpecsDS.KeyFieldName;
 
             // check for descending keys
 3b          if %bitand(bit0: KeySpecsDS.KeySequenBits) = bit0;
                KeyList = %trimr(KeyList) + '(D)';
                KeySeqArry(KeyCount) = 'D';
 3x          else;
                KeySeqArry(KeyCount) = 'A';
 3e          endif;
 
             KeySpecsPtr += 32;
 2e       endfor;
          KeyList = %triml(KeyList);
 1e    endif;
       NumbOfKeys = FileScopeArry.NumOfKeys;
 
 1b    if p_Output = '*PRINT';
          write PrtHead1;
          IsOverFlow = *off;
 
          write PrtKeys;
          write PrtHead2;
 2b       if FileScopeArry.NumSelectOmit > 0;
             printso = 'S/O:';
             exsr srSelectOmit;
 2e       endif;
          write PrtHead3;
 1e    endif;
 
       exsr srReadUserSpace;
       endsr;
 
       //---------------------------------------------------------
       begsr srPromptRcdFmt;
 1b    if IsFirstTime;
          IsFirstTime = *off;
          Ind.sfldsp3 = *off;
          Ind.sfldspctl3 = *off;
          write winctl3;
          rrn3 = 0;
          select3 = *blanks;
 
          // load record formats
          fscopePtrSave = fscopePtr;
          fscopePtr = Fild0100ptr + Fild0100ds.OffsFileScope;
 2b       for RcdFmtCount = 1 to Fild0100ds.NumRcdFmts;
             SbfRcdFmt = FileScopeArry.RcdFmt;
             rrn3 += 1;
             write windta3;
             fscopePtr += 160;  //next record format
 2e       endfor;
          fscopePtr = fscopePtrSave;
 1e    endif;
 
       Ind.sfldsp3 = (rrn3 > 0);
       Ind.sfldspctl3 = *on;
       write winctl3;
       exfmt winfoot3;
 
       readc windta3;
 1b    if (not %eof) and select3 > *blanks;
          p_RcdFmt = SbfRcdFmt;
          select3 = *blanks;
          update windta3;
          exsr srLoadRcdFmtInfo;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       begsr srSelectOmit;
 1b    if p_Output = '*' and InfdsFkey <> F06;
          Ind.sfldsp4 = *off;
          Ind.sfldspctl4 = *off;
          write winctl4;
          rrn4 = 0;
 1e    endif;
 
       SelectOmitSpecPtr = Fild0100ptr + FileScopeArry.OffsSelectOmit;
 1b    for SoCount = 1 to (FileScopeArry.NumSelectOmit - 1);
 2b       if SelectOmitSpec.StatementRule = 'S';
             soType = '*SELECT';
 2x       elseif SelectOmitSpec.StatementRule = 'O';
             soType = '*OMIT';
 2x       elseif SelectOmitSpec.StatementRule = 'A';
             soType = '*AND';
 2e       endif;
 
          sofld = SelectOmitSpec.FieldName;  //field name
          socomp = SelectOmitSpec.CompRelation;  //EQ,NE,GT,LT,ETC
          SelectOmitParmPtr = Fild0100ptr + SelectOmitSpec.OffsToParms;
 
          // extract select/omit values
 2b       for ParmCount = 1 to SelectOmitSpec.NumberOfParms;
             sovalu = %subst(SelectOmitParm.ParmValue: 1:
             SelectOmitParm.ParmLength-20);
 
 3b          if p_Output = '*' and InfdsFkey <> F06;
                rrn4 += 1;
                write windta4;
 3x          else;
                write PrtSelOmt;
                printso = *blanks;
 3e          endif;
             SelectOmitParmPtr = Fild0100ptr + SelectOmitParm.OffsToNext;
 2e       endfor;
          SelectOmitSpecPtr += 32;
 1e    endfor;
 
 1b    if p_Output = '*' and InfdsFkey <> F06;
          Ind.sfldsp4 = (rrn4 > 0);
          Ind.sfldspctl4 = *on;
          write winctl4;
          exfmt winfoot4;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       begsr srPrintScreen;
       f_OvrPrtf('JCRFFDP': '*JOB': %subst(p_FileQual: 1: 10));
       open JCRFFDP;
       write PrtHead1;
       write PrtKeys;
       write PrtHead2;
 1b    if FileScopeArry.NumSelectOmit > 0;
          printso = 'S/O:';
          exsr srSelectOmit;
 1e    endif;
       write PrtHead3;
 
 1b    for bb = 1 to PrtRrn;
          chain bb sbfdta1;
          FldText45 = FldText50;
          write PrtDetail;
 2b       if IsOverFlow;
 
 3b          if bb <> PrtRrn; // avoid last blank page
                write PrtPageBrk;
 3e          endif;
 
             IsOverFlow = *off;
 2e       endif;
 1e    endfor;
 
       close JCRFFDP;
       f_Dltovr('JCRFFDP');
       endsr;
 
       //---------------------------------------------------------
       // Sort user space then reload subfile
       //---------------------------------------------------------
       begsr srResequence;
       rrn1 = 0;
       PrtRrn = 0;
       ind = *off;
       write sbfctl1;
 
 1b    if IsSearch;
 2b       if SearchFld > *blanks;
             SortByFld = 'SBFIELD';
 2x       elseif SearchTxt > *blanks;
             SortByFld = 'SBTEXT';
 2x       elseif SearchKey > *blanks;
             SortByFld = 'SBKEY';
 2e       endif;
 1e    endif;
 
       qlgSortDS = %subst(qlgSortDS: 1: 80);  //drop off keys
       qlgsortDS.RecordLength = ApiHead.ListEntrySize;
       qlgsortDS.RecordCount = ApiHead.ListEntryCount;
 
       // note sort key positions are where I overlaid user space entry
       // with my screen fields.
 
 1b    if SortByFld = 'SBFIELD';
          qlgsortDS.NumOfKeys = 1;
          qlgsortDS = %trimr(qlgsortDS) + f_AddSortKey(154: 10);
 
 1x    elseif SortByFld = 'SBFROMPOS';
          qlgsortDS.NumOfKeys = 1;
          qlgsortDS = %trimr(qlgsortDS) + f_AddSortKey(180: 5: 2: 1);
 
 1x    elseif SortByFld = 'SBTEXT';
          qlgsortDS.NumOfKeys = 1;
          qlgsortDS = %trimr(qlgsortDS) + f_AddSortKey(101: 50);
 
 1x    elseif SortByFld = 'SBKEY';
          qlgsortDS.NumOfKeys = 1;
          qlgsortDS = %trimr(qlgsortDS) + f_AddSortKey(151: 3: 6: 1);
 1e    endif;
 
       qlgsortDS.BlockLength = %len(%trimr(qlgsortDS));
       LengthOfBuffer =
       ApiHead.ListEntryCount * ApiHead.ListEntrySize;
       callp QLGSORT(
             qlgsortDS:
             SortOverlay:
             SortOverlay:
             LengthOfBuffer:
             LengthOfBuffer:
             ApiErrDS);
 
       QuslfldPtr = SortPtr;
 1b    for ForCount = 1 to ApiHead.ListEntryCount;
          ScreenFieldDS = %subst(Quslfldds:101);
          IsFiltered = *on;
 
 2b       if IsSearch;
 3b          if SearchFld > *blanks;
                IsFiltered = %scan(%trimr(SearchFld): sbField) > 0;
 
 3x          elseif SearchKey > *blanks;
                IsFiltered = (Sbkey > *blanks);
 
 3x          elseif SearchLen > 0;
                IsFiltered = (sbLength = SearchLen);
 
 3x          elseif SearchTxt > *blanks;
                IsFiltered = %scan(%trimr(SearchTxt):
                %xlate(lo: up: FldText50)) > 0;
 3e          endif;
 2e       endif;
 
 2b       if IsFiltered;
             sbTxt = f_CamelCase(FldText50);
             rrn1 += 1;
             PrtRrn += 1;
             write sbfdta1;
 2e       endif;
 
          QuslfldPtr += ApiHead.ListEntrySize;
 1e    endfor;
       endsr;
