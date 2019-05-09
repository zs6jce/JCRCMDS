       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRDUPKEYR - Duplicate Keyed Logicals List - print
       //  List files with same leading keys and select/omit statements
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define Constants
       /define BitMask
       /define f_OvrPrtf
       /define f_DltOvr
       /define f_Quscrtus
       /define Qdbrtvfd
       /define Qdbldbr
       /define f_DisplayLastSplf
       /define f_SndCompMsg
       /define f_GetDayName
       /define f_BuildString
       /define Qlgsort
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRDUPKEYP printer oflind(IsOverFlow) usropn;
 
       dcl-s WorkFileQual char(20);
       dcl-s DbrCnt uns(5);
       dcl-s yy like(filescopearry.numofkeys);
       dcl-s zz uns(10);
       dcl-s ActualPF char(20);
 
       dcl-s IsSendMessage ind;
       dcl-s IsAllEQual ind;
       dcl-s IsAllSelect ind;
       dcl-s IsPrintOnce ind;
 
       // setup sort pointer
       dcl-s SortOverlay char(200) based(sortptr);
       dcl-s SortPtr pointer inz(%addr(ds1));
 
       dcl-ds SelectOmitDS inz qualified;
        Type char(7);
        Field char(10);
        Comp char(2);
        Value char(31);
       end-ds;
 
       dcl-ds DS0 qualified template;
        NumbKeys uns(3);
        FormatCnt uns(3);
        File char(10);
        Lib char(10);
        UniqueFlg char(1);
        KeysArry char(13) dim(30);
        PrtKeys char(104) pos(24);
        SelOmtArry char(50) dim(30);
       end-ds;
 
       dcl-ds DS1 likeds(DS0) dim(2000);
       dcl-ds DS2 likeds(DS0) dim(2000);
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_Mbr char(10);
        p_FileQual char(20);
        p_Output char(8);
       end-pi;
       //---------------------------------------------------------
 
       scDow = f_GetDayName();
       f_OvrPrtf('JCRDUPKEYP': '*JOB': %subst(p_FileQual:1:10));
       open JCRDUPKEYP;
 
       //---------------------------------------------------------
       // If file is logical, based-on-physical name is extracted
       // processing continues.
       //---------------------------------------------------------
       AllocatedSize = f_GetAllocatedSize(p_FileQual: '*FIRST');
       Fild0100ptr = %alloc(AllocatedSize);
       callp QDBRTVFD(
             Fild0100ds:
             AllocatedSize:
             ReturnFileQual:
             'FILD0100':
             p_FileQual:
             '*FIRST':
             '0':
             '*FILETYPE':
             '*EXT':
             ApiErrDS);
 
       fscopePtr = Fild0100ptr + Fild0100ds.OffsFileScope;
 1b    if %bitand(bit2: Fild0100ds.TypeBits) = bit2;
          ReturnFileQual =
          FileScopeArry.BasedOnPf + FileScopeArry.BasedOnPfLib;
 1e    endif;
 
       ActualPF = ReturnFileQual;
 
       scObjHead =
       f_BuildString('&  &   &': %subst(ReturnFileQual: 1: 10):
       %subst(ReturnFileQual: 11: 10): Fild0100ds.FileText);
 
       write PrtHead;
       IsOverFlow = *off;
 
       write prtdivider;
 
       // retrieve data base relation names
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
 
       callp QDBLDBR(
             UserSpaceName:
             'DBRL0100':
             ReturnFileQual:
             '*ALL':
             '*ALL':
             ApiErrDS);
 
       // Process list entries in user space
       QdbldbrPtr = ApiHeadPtr + ApiHead.OffSetToList;
 
 1b    for ForCount = 1 to ApiHead.ListEntryCount;
 2b       if not(QdbldbrDS.DependentFile = '*NONE');
             exsr srLoadRecord;
             QdbldbrPtr += ApiHead.ListEntrySize;
 2e       endif;
 1e    endfor;
 
       QdbldbrDS.DependentFile = ActualPF;
       exsr srLoadRecord;
 
       //---------------------------------------------------------
       // start with smallest number of keys and spin through entire list
       // looking for files with keys in same positions and same select omits
       //
       //  Sort driver arry ascending by number of keys,
       //  and the compare arry descending by number of keys.
       //---------------------------------------------------------
       ds2(*) = ds1(*);
 
       qlgsortDS.RecordLength = %len(ds1(1));
       qlgsortDS.RecordCount = DbrCnt;
       qlgsortDS.NumOfKeys = 1;
       qlgsortDS = %trimr(qlgsortDS) + f_AddSortKey(1:1:9:1);  // ascend
       qlgsortDS.BlockLength = %len(%trimr(qlgsortDS));
 
       callp QLGSORT(
             qlgsortDS:
             SortOverlay:
             SortOverlay:
             qlgsortDS.RecordLength * qlgsortDS.RecordCount:
             qlgsortDS.RecordLength * qlgsortDS.RecordCount:
             ApiErrDS);
 
       SortPtr = %addr(DS2);
       qlgSortDS = %subst(qlgSortDS: 1: 80);
       qlgsortDS = %trimr(qlgsortDS) + f_AddSortKey(1:1:9:2); // descend
       callp QLGSORT(
             qlgsortDS:
             SortOverlay:
             SortOverlay:
             qlgsortDS.RecordLength * qlgsortDS.RecordCount:
             qlgsortDS.RecordLength * qlgsortDS.RecordCount:
             ApiErrDS);
 
       //---------------------------------------------------------
       //---------------------------------------------------------
 1b    for aa = 1 to DbrCnt;
 2b       if ds1(aa).File > *blanks;
             IsPrintOnce = *on;
 
 3b          for cc = 1 to DbrCnt;
 4b             if ds2(cc).File > *blanks
                   and ds2(cc).File <> ds1(aa).File
                   and ds2(cc).FormatCnt = ds1(aa).FormatCnt;
 
                   IsAllSelect = *on;
 5b                for bb = 1 to %elem(ds1.SelOmtArry);
 6b                   if ds2(cc).SelOmtArry(bb) <> ds1(aa).SelOmtArry(bb);
                         IsAllSelect = *off;
 5v                      leave;
 6e                   endif;
 5e                endfor;
 
 5b                if IsAllSelect;
                      IsAllEQual = (ds1(aa).NumbKeys > 0);
 6b                   for bb = 1 to ds1(aa).NumbKeys;
 7b                      if ds2(cc).KeysArry(bb) <> ds1(aa).KeysArry(bb);
                            IsAllEQual = *off;
 6v                         leave;
 7e                      endif;
 6e                   endfor;
 
 6b                   if IsAllEQual = *on;
                         IsSendMessage = *on;
 7b                      if IsPrintOnce;
                            PrtFile = ds1(aa).File;
                            PrtLib = ds1(aa).Lib;
                            PrtKeys = ds1(aa).PrtKeys;
                            write PrtLine;
                            IsPrintOnce = *off;
 7e                      endif;
                         PrtFile = ds2(cc).File;
                         PrtLib = ds2(cc).Lib;
                         PrtKeys = ds2(cc).PrtKeys;
                         write PrtLine;
 
                         // remove found file from driver array
 7b                      for bb = 1 to DbrCnt;
 8b                         if  ds2(cc).File = ds1(bb).File;
                               ds1(bb) = *blanks;
 8e                         endif;
 7e                      endfor;
                         ds2(cc) = *blanks;
 
 6e                   endif;
 5e                endif;
 4e             endif;
 3e          endfor;
 
 3b          if not IsPrintOnce;
                write prtdivider;
 3e          endif;
 2e       endif;
 1e    endfor;
 
 1b    if not IsSendMessage;
          PrtFile = *all'*';
          PrtLib = *all'*';
          PrtKeys = %trimr(%subst(p_FileQual:1:10)) +
          ' has no duplicate access paths.';
          f_sndCompMsg(PrtKeys);
          write PrtLine;
 1e    endif;
 
       dealloc(n) Fild0100ptr;
       close JCRDUPKEYP;
       f_DltOvr('JCRDUPKEYP');
       f_DisplayLastSplf('JCRDUPKEYR': p_Output);
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       begsr srLoadRecord;
       WorkFileQual = QdbldbrDS.DependentFile;
       AllocatedSize = f_GetAllocatedSize(WorkFileQual: '*FIRST');
 1b    if ApiErrDS.BytesReturned = 0;
          DbrCnt += 1;
          ds1(DbrCnt).File = %subst(WorkFileQual: 1: 10);
          ds1(DbrCnt).Lib = %subst(WorkFileQual: 11: 10);
 
          Fild0100ptr = %realloc(Fild0100ptr: AllocatedSize);
          callp QDBRTVFD(
                Fild0100ds:
                AllocatedSize:
                ReturnFileQual:
                'FILD0100':
                WorkFileQual:
                '*FIRST':
                '0':
                '*FILETYPE':
                '*EXT':
                ApiErrDS);
 
          // Check for unique keys required
 2b       if Fild0100ds.AccessType = 'KU';
             ds1(DbrCnt).uniqueflg = 'U';
 2x       else;
             ds1(DbrCnt).uniqueflg = ' ';
 2e       endif;
 
          // get number of record formats
          ds1(DbrCnt).FormatCnt = Fild0100ds.NumRcdFmts;
 
          // set offsets
          fscopePtr = Fild0100ptr + Fild0100ds.OffsFileScope;
          cc = FileScopeArry.OffsKeySpecs + 1;
 
          // if 1st bit of KeySequenBits = 1, key is descend sequence
          ds1(DbrCnt).KeysArry(*) = *blanks;
          ds1(DbrCnt).SelOmtArry(*) = *blanks;
          ds1(DbrCnt).NumbKeys = FileScopeArry.NumOfKeys;
          KeySpecsPtr = Fild0100ptr + FileScopeArry.OffsKeySpecs;
 
 2b       for yy = 1 to FileScopeArry.NumOfKeys;
             ds1(DbrCnt).KeysArry(yy) = %trimr(KeySpecsDS.KeyFieldName);
 
             // check for descending keys
 3b          if %bitand(bit0: KeySpecsDS.KeySequenBits) = bit0;
                %subst(ds1(DbrCnt).KeysArry(yy): 11: 3) = '(D)';
 3e          endif;
             KeySpecsPtr += 32;
 2e       endfor;
 
          // extract select/omit fields
          aa = 0;
 2b       if FileScopeArry.NumSelectOmit > 0;
             SelectOmitSpecPtr = Fild0100ptr + FileScopeArry.OffsSelectOmit;
 3b          for ForCount2 = 1 to (FileScopeArry.NumSelectOmit - 1);
 4b             if SelectOmitSpec.StatementRule = 'S';
                   SelectOmitDS.Type = '*SELECT';
 4x             elseif SelectOmitSpec.StatementRule = 'O';
                   SelectOmitDS.Type = '*OMIT';
 4x             elseif SelectOmitSpec.StatementRule = 'A';
                   SelectOmitDS.Type = '*AND';
 4e             endif;
 
                SelectOmitDS.Field = SelectOmitSpec.FieldName;
                SelectOmitDS.Comp = SelectOmitSpec.CompRelation;
                SelectOmitParmPtr = Fild0100ptr + SelectOmitSpec.OffsToParms;
                // extract select/omit values
 4b             for zz = 1 to SelectOmitSpec.NumberOfParms;
                   SelectOmitDS.Value = %subst(
                   SelectOmitParm.ParmValue:
                   1:
                   SelectOmitParm.ParmLength-20);
                   aa += 1;
                   ds1(DbrCnt).SelOmtArry(aa) = SelectOmitDS;
                   SelectOmitParmPtr = Fild0100ptr + SelectOmitParm.OffsToNext;
 4e             endfor;
                SelectOmitSpecPtr += 32;
 3e          endfor;
 2e       endif;
 1e    endif;
       endsr;
