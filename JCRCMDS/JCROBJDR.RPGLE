       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCROBJDR - Expanded work with object descriptions
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCROBJDD workstn sfile(sbfdta1: rrn) infds(infds) indds(ind);
 
       /define ApiErrDS
       /define f_DecodeApiTimeStamp
       /define Constants
       /define Infds
       /define Dspatr
       /define FunctionKeys
       /define Ind
       /define Qlgsort
       /define Quslobj
       /define Sds
       /define f_BuildString
       /define f_GetQual
       /define f_Quscrtus
       /define f_RmvSflMsg
       /define f_SndCompMsg
       /define f_SndSflMsg
       /define f_SndStatMsg
       /define f_GetFileUtil
       /define f_GetDayName
       /define f_SndEscapeMsg
       /define f_RtvMsgAPI
       /define f_RunCmd
       /define f_RunOptionFile
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s SaveOriginal like(QwcrtvcaDS);
       dcl-s KeyFld char(10) inz('OBJSIZE');
       dcl-s SequenceText char(10) inz('Descend');
       dcl-s SortArry like(ScreenFieldDS) dim(9999);
       dcl-s LengthOfBuffer int(10);
       dcl-s LoadedElements int(10);
       dcl-s SequenceValue int(10) inz(2);
       dcl-s DeleteCount uns(5);
       dcl-s NumberOfRecs uns(5);
       dcl-s RRNsave like(rrn);
       dcl-s IsFirstTime ind;
 
       // Retrieve Current Attributes
       dcl-pr Qwcrtvca extpgm('QWCRTVCA');
        *n char(150);  // receiver
        *n int(10) const;  // receiver length
        *n char(8) const;  // api format
        *n int(10) const;  // number of keys
        *n char(12);  // keys list
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds QwcrtvcaDS len(150) qualified;
        AttrReturnCnt int(10) inz;
       end-ds;
 
       // ds to extract retrieved attributes from API call
       dcl-ds rtvc0100DS qualified based(rtvc0100Ptr);
        Length int(10);
        Key int(10);
        DataType char(1);
        Reserved char(3);
        LenOfData int(10);
        Data char(30);
       end-ds;
 
       dcl-ds Alpha2NumDS qualified;
        Numeric int(10) inz;
       end-ds;
 
       // Change Job
       dcl-pr Qwtchgjb extpgm('QWTCHGJB');
        *n char(26) const;  // job name *=current
        *n char(16) const;  // internal identifier
        *n char(8) const;  // api format
        *n char(150);  // receiver
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds BinaryKeysArry qualified;
        Purge1604 int(10) inz(1604);
        Runpty1802 int(10) inz(1802);
        TimeSlice2002 int(10) inz(2002);
       end-ds;
 
       // ScreenFieldDS -  load screen fields into sort array
       dcl-ds ScreenFieldDS inz;
        ObjLib;
        ObjName;
        ObjType;
        ObjAttr;
        ObjText;
        ObjSize;
        CreateDate;
        LastUsed;
        DaysUsed;
        hidRIsfl;
        hidNDsfl;
        HidSortcrt;  // C YY MM DD for sort
        HidSortlst;  // C YY MM DD for sort
        CreatedBy;
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_ObjQual char(20);
        p_ObjTyp char(10);
        p_Objatr char(10);
        p_CrtUsr char(10);
        p_AllowOption char(4);
       end-pi;
       //---------------------------------------------------------
 
       IsFirstTime = *on;
       f_SndStatMsg(f_BuildString('Retrieving & type & - in progress':
       f_GetQual(p_ObjQual): p_ObjTyp));
       aNotUsed = ND;
       scDow = f_GetDayName();
 
       exsr srDiscreteBumpJobPriority;
       DbUtility = '6=' + f_GetFileUtil();
 
 1b    if p_AllowOption = '*NO';
          aOptionSfl = %bitor(ND: PR);
          aOptions = ND;
 1x    else;
          aOptionSfl = %bitor(Green: UL);
          aOptions = Blue;
 1e    endif;
 
       // Create user space/retrieve pointer to user space
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
       exsr srRefreshScreen;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
 1b    dou 1 = 2;
          Ind.sfldsp = (rrn > 0);
          Ind.sfldspctl = *on;
 
 2b       if (not Ind.sfldsp);
             f_RmvSflMsg(ProgId);
             f_SndSflMsg(ProgId:
             'No objects matching selection were found');
 2e       endif;
 
          write msgctl;
          write sfooter1;
          exfmt sbfctl1;
 2b       if InfdsFkey = f03 or InfdsFkey = f12;
             f_SndCompMsg(f_BuildString('JCROBJD for & type & - completed':
             f_GetQual(p_ObjQual): p_ObjTyp));
             *inlr = *on;
             return;
 2e       endif;
 
          f_RmvSflMsg(ProgId);
 
          // refresh
 2b       if InfdsFkey = f05;
             exsr srRefreshScreen;
 1i          iter;
 2e       endif;
 
          // user selected new library or object
 2b       if not(HeaderObj = %subst(p_ObjQual: 1: 10) and
             HeaderLib = %subst(p_ObjQual: 11: 10));
             %subst(p_ObjQual: 1: 10) = HeaderObj;
             %subst(p_ObjQual: 11: 10) = HeaderLib;
             exsr srRefreshScreen;
 1i          iter;
 2e       endif;
 
 2b       if InfdsSflRcdNbr > 0;
             SflRcdNbr = InfdsSflRcdNbr;
 2x       else;
             SflRcdNbr = 1;
 2e       endif;
 
          // re-sort subfile
 2b       if InfdsFkey = f13
             or InfdsFkey = f14;
 3b          if InfdsFkey = f13;
                SequenceText = 'Ascend';
                SequenceValue = 1;
 3e          endif;
 3b          if InfdsFkey = f14;
                SequenceText = 'Descend';
                SequenceValue = 2;
 3e          endif;
 
             KeyFld = curfld;
             exsr srSortAndReload;
             SflRcdNbr = 1;
 1i          iter;
 2e       endif;
 
          //-----------------------------------------------
          DeleteCount = 0;
          readc sbfdta1;
 2b       dow not %eof;
 
             f_RunOptionObject(
             sbfOption:
             ObjName:
             ObjLib:
             ObjType:
             ProgId);
 
             // Update subfile to reflect changes
 3b          if sbfOption = 4;
 4b             if ApiErrDS.BytesReturned > 0;  //error occurred
                   f_RmvSflMsg(ProgId);
                   f_SndSflMsg(ProgId:
                   ApiErrDS.ErrMsgId + ': ' +
                   f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal));
 4x             else;
                   DeleteCount += 1;
 4e             endif;
 
 3x          else;
                sbfOption = 0;
                aRIsfl = hidRIsfl;
                aNDsfl = hidNDsfl;
                SflRcdNbr = rrn;
                update sbfdta1;
 3e          endif;
 
             readc sbfdta1;
 2e       enddo;
 
 2b       if DeleteCount > 0;
             exsr srSortAndReload;
             DeleteCount = 0;
 2e       endif;
 1e    enddo;
 
       //---------------------------------------------------------
       // load object name list
       //---------------------------------------------------------
       begsr srRefreshScreen;
       Ind.sfldsp = *off;
       Ind.sfldspctl = *off;
       aRIsfl = Green;
       aNDsfl = Green;
       aNotUsed = ND;
       write sbfctl1;
       rrn = 0;
 
       HeaderObj = %subst(p_ObjQual: 1: 10);
       HeaderLib = %subst(p_ObjQual: 11: 10);
 
       callp QUSLOBJ(
             UserSpaceName:
             'OBJL0700':
             p_ObjQual:
             p_ObjTyp:
             ApiErrDS);
 
 1b    if ApiErrDS.BytesReturned > 0;
          f_SndEscapeMsg(ApiErrDS.ErrMsgId + ': ' +
          %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal)));
 1e    endif;
 
       // change job back to original run priority
 1b    if IsFirstTime;
          IsFirstTime = *off;
          callp QWTCHGJB(
                '*':
                ' ':
                'JOBC0100':
                SaveOriginal:
                ApiErrDS);
 1e    endif;
 
       // Process data from user space by moving QuslobjPtr pointer
       LoadedElements = 0;
       QuslobjPtr = ApiHeadPtr + ApiHead.OffSetToList;
 
 1b    for ForCount = 1 to ApiHead.ListEntryCount;
          // only load objects that match attributes
 2b       if p_CrtUsr = '*ALL'
             or p_CrtUsr = QuslobjDS.CreatedByUser;
             CreatedBy = QuslobjDS.CreatedByUser;
 
 3b          if QuslobjDS.ExtendedAttr = p_Objatr
                or p_Objatr = '*ALL';
                aRIsfl = Green;
                aNDsfl = Green;
                ObjName = QuslobjDS.ObjNam;
                ObjLib = QuslobjDS.ObjLib;
                ObjType = QuslobjDS.ObjTyp;
                ObjAttr = QuslobjDS.ExtendedAttr;
 
 4b             if %subst(HeaderLib: 1: 1) = '*';
                   ObjText = QuslobjDS.ObjLib  + ' ' + QuslobjDS.ObjText;
 4x             else;
                   ObjText = QuslobjDS.ObjText;
 4e             endif;
 
                ApiStampDS = f_DecodeApiTimeStamp(QuslobjDS.CreateStamp);
                HidSortcrt = ApiStampDS.Century +
                ApiStampDS.YY + ApiStampDS.MMDD;
                CreateDate = %dec(ApiStampDS.MMDD + ApiStampDS.YY: 6: 0);
 
 4b             if QuslobjDS.NumDaysUsed > 9999;
                   DaysUsed = 9999;
 4x             else;
                   DaysUsed = QuslobjDS.NumDaysUsed;
 4e             endif;
 
 4b             if QuslobjDS.NumDaysUsed > 0;
                   ApiStampDS = f_DecodeApiTimeStamp(QuslobjDS.LastUseStamp);
                   HidSortlst = ApiStampDS.Century +
                   ApiStampDS.YY + ApiStampDS.MMDD;
                   LastUsed = %dec(ApiStampDS.MMDD + ApiStampDS.YY: 6: 0);
 4x             else;
                   aRIsfl = %bitor(Green: RI);
                   aNotUsed = %bitor(Green: RI);
                   aNDsfl = ND;
                   LastUsed = 0;
                   HidSortlst = *blanks;
 4e             endif;
 
                ObjSize =
                (QuslobjDS.ObjSize * QuslobjDS.MultiplySize)/1024;
 4b             if ObjAttr = 'DDMF';
                   aRIsfl = Green;
 4e             endif;
 
                hidRIsfl = aRIsfl;
                hidNDsfl = aNDsfl;
                rrn += 1;
                LoadedElements += 1;
                SortArry(LoadedElements) = ScreenFieldDS;
 
 4b             if LoadedElements = 9999;
 1v                leave;
 4e             endif;
 3e          endif;
 2e       endif;
 
          QuslobjPtr += ApiHead.ListEntrySize;
 1e    endfor;
       RRNsave = rrn;
 
       // Allow user to make selection from subfile
       exsr srLoadFromSorter;
 1b    if SflRcdNbr <= 0;
          SflRcdNbr = 1;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Read subfile and load records into sorting array
       //---------------------------------------------------------
       begsr srSortAndReload;
       NumberOfRecs = RRNsave;
 
 1b    if DeleteCount > 0;
          RRNsave -= DeleteCount;
 2b       if SflRcdNbr > RRNsave;
             SflRcdNbr = RRNsave;
 2e       endif;
 1e    endif;
 
       LoadedElements = 0;
 1b    for rrn = 1 to NumberOfRecs;
          chain rrn sbfdta1;
 2b       if not(sbfOption = 4);  //DELETE OPTION
             LoadedElements += 1;
             SortArry(LoadedElements) = ScreenFieldDS;
 2e       endif;
 1e    endfor;
       exsr srLoadFromSorter;
       rrn = RRNsave;
       endsr;
 
       //---------------------------------------------------------
       // Sort array and load back into subfile
       //---------------------------------------------------------
       begsr srLoadFromSorter;
       Ind.sfldsp = *off;
       Ind.sfldspctl = *off;
       aRIsfl = Green;
       aNDsfl = Green;
       write sbfctl1;
       rrn = 0;
 
       qlgSortDS = %subst(qlgSortDS: 1: 80);  //drop off keys
       qlgsortDS.RecordLength = %size(SortArry);
       qlgsortDS.RecordCount = LoadedElements;
 
 1b    if KeyFld = 'OBJSIZE';
          qlgsortDS.NumOfKeys = 2;
          qlgsortDS = %trimr(qlgsortDS) +
          f_AddSortKey(71: 9: 2: SequenceValue) +
          f_AddSortKey(11: 10);
          f_SndSflMsg(ProgId: 'Sort ' + %trimr(SequenceText) +
          ' by Size');
 
 1x    elseif KeyFld = 'OBJLIB';
          qlgsortDS.NumOfKeys = 2;
          qlgsortDS = %trimr(qlgsortDS) +
          f_AddSortKey(1: 10: 6: SequenceValue) +
          f_AddSortKey(11: 10);
          f_SndSflMsg(ProgId: 'Sort ' + %trimr(SequenceText) +
          ' by Library Name');
 
 1x    elseif KeyFld = 'OBJNAME';
          qlgsortDS.NumOfKeys = 1;
          qlgsortDS = %trimr(qlgsortDS) +
          f_AddSortKey(11: 10: 6: SequenceValue);
          f_SndSflMsg(ProgId: 'Sort ' + %trimr(SequenceText) +
          ' by Object Name');
 
 1x    elseif KeyFld = 'OBJTYPE';
          qlgsortDS.NumOfKeys = 2;
          qlgsortDS = %trimr(qlgsortDS) +
          f_AddSortKey(21: 10: 6: SequenceValue) +
          f_AddSortKey(11: 10);
          f_SndSflMsg(ProgId: 'Sort ' + %trimr(SequenceText) +
          ' by Object Type');
 
 1x    elseif KeyFld = 'OBJATTR';
          qlgsortDS.NumOfKeys = 2;
          qlgsortDS = %trimr(qlgsortDS) +
          f_AddSortKey(31: 10: 6: SequenceValue) +
          f_AddSortKey(11: 10);
          f_SndSflMsg(ProgId: 'Sort ' + %trimr(SequenceText) +
          ' by Attribute');
 
 1x    elseif KeyFld = 'OBJTEXT';
          qlgsortDS.NumOfKeys = 1;
          qlgsortDS = %trimr(qlgsortDS) +
          f_AddSortKey(41: 30: 6: SequenceValue);
          f_SndSflMsg(ProgId: 'Sort ' + %trimr(SequenceText) +
          ' by Text');
 
 1x    elseif KeyFld = 'CREATEDATE';
          qlgsortDS.NumOfKeys = 2;
          qlgsortDS = %trimr(qlgsortDS) +
          f_AddSortKey(98: 7: 6: SequenceValue) +
          f_AddSortKey(1: 10);
          f_SndSflMsg(ProgId: 'Sort ' + %trimr(SequenceText) +
          ' by Created Date');
 
 1x    elseif KeyFld = 'LASTUSED';
          qlgsortDS.NumOfKeys = 2;
          qlgsortDS = %trimr(qlgsortDS) +
          f_AddSortKey(105: 7: 6: SequenceValue) +
          f_AddSortKey(11: 10);
          f_SndSflMsg(ProgId: 'Sort ' + %trimr(SequenceText) +
          ' by Last Used Date');
 
 1x    elseif KeyFld = 'DAYSUSED';
          qlgsortDS.NumOfKeys = 2;
          qlgsortDS = %trimr(qlgsortDS) +
          f_AddSortKey(92: 4: 2: SequenceValue) +
          f_AddSortKey(11: 10);
          f_SndSflMsg(ProgId: 'Sort ' + %trimr(SequenceText) +
          ' by Number of Times Used');
 
 1x    elseif KeyFld = 'CREATEDBY';
          qlgsortDS.NumOfKeys = 2;
          qlgsortDS = %trimr(qlgsortDS) +
          f_AddSortKey(112: 10: 6: SequenceValue) +
          f_AddSortKey(11: 10);
          f_SndSflMsg(ProgId: 'Sort ' + %trimr(SequenceText) +
          ' by Created by User');
 1e    endif;
 
       qlgsortDS.BlockLength = %len(%trimr(qlgsortDS));
       LengthOfBuffer = LoadedElements * %size(SortArry);
       callp QLGSORT(
             qlgsortDS:
             SortArry:
             SortArry:
             LengthOfBuffer:
             LengthOfBuffer:
             ApiErrDS);
 
 1b    if LoadedElements >= 9999;
          f_RmvSflMsg(ProgId);
          f_SndSflMsg(ProgId:'9999+ objects returned. Narrow the search.');
          LoadedElements = 9999;
 1e    endif;
 
 1b    for aa = 1 to LoadedElements;
          ScreenFieldDS = SortArry(aa);
          aRIsfl = hidRIsfl;
          aNDsfl = hidNDsfl;
          sbfOption = 0;
          rrn += 1;
          write sbfdta1;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srDiscreteBumpJobPriority;
       // retrieve job values
       callp QWCRTVCA(
             QwcrtvcaDS:
             %len(QwcrtvcaDS):
             'RTVC0100':
             3:
             BinaryKeysArry:
             ApiErrDS);
 
       //---------------------------------------------------------
       // Save original values then modify variable with new values
       //  for passing to change job API.
       //  Lower Runpty by 1.
       //  Set purge to *NO.
       //  Add 500 to timeslice.
       //---------------------------------------------------------
       SaveOriginal = QwcrtvcaDS;
       rtvc0100Ptr = %addr(QwcrtvcaDS) + 4;
 
 1b    for ForCount2 = 1 to QwcrtvcaDS.AttrReturnCnt;
 2b       if rtvc0100DS.Key = BinaryKeysArry.Purge1604;
 3b          if %subst(rtvc0100DS.Data: 1: rtvc0100DS.LenOfData) = '*YES';
                %subst(rtvc0100DS.Data: 1: rtvc0100DS.LenOfData) = '*NO';
 3e          endif;
 2x       elseif rtvc0100DS.Key = BinaryKeysArry.Runpty1802;
             Alpha2NumDS = rtvc0100DS.Data;
 3b          if Alpha2NumDS.Numeric > 1;
                Alpha2NumDS.Numeric -= 1;
                %subst(rtvc0100DS.Data: 1: 4) = Alpha2NumDS;
 3e          endif;
 
 2x       elseif rtvc0100DS.Key = BinaryKeysArry.TimeSlice2002;
             Alpha2NumDS = rtvc0100DS.Data;
             Alpha2NumDS.Numeric += 500;
             %subst(rtvc0100DS.Data: 1: 4) = Alpha2NumDS;
 2e       endif;
          rtvc0100Ptr += rtvc0100DS.Length;
 1e    endfor;
 
       // change job to new run values
       callp QWTCHGJB(
             '*':
             ' ':
             'JOBC0100':
             QwcrtvcaDS:
             ApiErrDS);
       endsr;
 
       //---------------------------------------------------------
       // Execute selected command
       //---------------------------------------------------------
       dcl-proc f_RunOptionObject;
        dcl-pi *n;
         p_Option packed(1);
         p_ObjName char(10);
         p_ObjLib char(10);
         p_ObjType char(10);
         p_ProgId char(10);
        end-pi;
 
        dcl-s ObjLibAndName char(21);
        dcl-s msg char(75);
 
        dcl-pr Qlidlto extpgm('QLIDLTO');  // delete object
         *n char(20) const;  // name and lib
         *n char(10) const;  // type
         *n char(10) const;  // auxillary stg
         *n char(1) const;  // remove message
         *n like(ApiErrDS);
        end-pr;
 
        ObjLibAndName = f_GetQual(p_ObjName + p_ObjLib);
 
 1b     if p_Option = 1;
           f_RunCmd(f_BuildString('WRKOBJ OBJ(&) OBJTYPE(&)':
           ObjLibAndName: p_ObjType));
           msg = 'Work Object ' + %trimr(p_ObjName) + ' - completed';
 
 1x     elseif p_Option = 5;
           f_RunCmd(f_BuildString('DSPOBJD OBJ(&) OBJTYPE(&)':
           ObjLibAndName: p_ObjType));
           msg = 'Display Object Description ' +
           %trimr(p_ObjName) + ' - completed';
 
 1x     elseif p_Option = 3;
           f_RunCmd(f_BuildString('WRKOBJLCK OBJ(&) OBJTYPE(&)':
           ObjLibAndName: p_ObjType));
           msg = 'Work Object Lock ' + %trimr(p_ObjName) + ' - completed';
 
          // delete object APi
 1x     elseif p_Option = 4;
           callp Qlidlto(
                 p_ObjName + p_ObjLib:
                 p_ObjType:
                 '*':
                 '0':
                 ApiErrDS);
           msg = 'Delete Object ' + %trimr(p_ObjName) + ' - completed';
 
 1x     elseif p_Option = 7;
           f_RunCmd('CLRPFM ' + ObjLibAndName);
           msg = 'Clear Physical File Member ' +
           %trimr(p_ObjName) + ' - completed';
 
 1x     elseif p_Option = 6;
           f_RunOptionFile(2: p_ObjName: p_ObjLib:
           '*FIRST': '*FIRST': p_ProgId);
 
 1x     elseif p_Option = 8;
           f_RunCmd(f_BuildString('WRKOBJ OBJ(*ALLUSR/&) OBJTYPE(&)':
           p_ObjName: p_ObjType));
           msg = 'Wrkobj *allusr/ ' +
           %trimr(p_ObjName) + ' - completed';
 
 1x     elseif p_Option = 9;
           f_RunCmd('WRKMBRPDM ' + ObjLibAndName);
           msg = 'Work with members ' + %trimr(p_ObjName) + ' - completed';
 1x     else;
           msg = 'Option ' + %char(p_Option) + ' is not available';
 1e     endif;
 
        f_SndSflMsg(p_ProgId: msg);
        return;
       end-proc;
