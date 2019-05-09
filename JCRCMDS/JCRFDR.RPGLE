       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRFDR - File descriptions driver
       // This program also provides the presentation layer for JCRLKEY and JCRDBR.
       //  F2 lower cases everything on the screen, easy to copy keys and
       //  record formats from this screen.
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCRFDD workstn sfile(sbfdta1: rrn) infds(infds)
       sfile(windta3: rrn3) indds(ind);
       dcl-f JCRFDP printer oflind(IsOverFlow) usropn;
 
       /define ApiErrDS
       /define Constants
       /define BitMask
       /define DspAtr
       /define Infds
       /define FunctionKeys
       /define f_GetApiISO
       /define f_GetApiHMS
       /define f_Qusrmbrd
       /define f_Qusrobjd
       /define f_qmhrcvpm
       /define f_RmvSflMsg
       /define f_SndSflMsg
       /define f_SndCompMsg
       /define f_BuildString
       /define Ind
       /define Sds
       /define f_Quscrtus
       /define f_GetQual
       /define f_GetDayName
       /define f_RunOptionFile
       /define Qdbldbr
       /define Qdbrtvfd
       /define Qlgsort
       /define f_GetFileUtil
       /define f_RtvMsgAPI
       /define f_OvrPrtf
       /define f_DltOvr
       /define f_DisplayLastSplf
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s rrn3 like(rrn);
       dcl-s WorkFileQual char(20);
       dcl-s PfFile char(10);
       dcl-s PfLib char(10);
       dcl-s KeyList char(99);
       dcl-s ForCount1 like(ApiHead.listentrycount);
       dcl-s ForCount3 like(filescopearry.numselectomit);
       dcl-s ForCount4 like(selectomitspec.numberofparms);
       dcl-s ForCount5 like(fild0100ds.numofbasedpf);
       dcl-s ForCount6 like(joinspecds.numjflds);
       dcl-s ForCount7 like(pfattrds.numoftriggers);
       dcl-s IsLF ind;
       dcl-s IsDbrView ind;
       dcl-s IsMbrView ind;
       dcl-s kwork varchar(16);
       dcl-s IsIncludeSO ind;
       dcl-s IsThisKeyOK ind;
       dcl-s IsValidKeys ind;
       dcl-s IsFdScreen ind;
       dcl-s IsOption3 ind inz(*off);
       dcl-s KeySortArry char(14) dim(9) ascend;
       dcl-s QuickSort char(200) based(qdbldbrptr);
       dcl-s FileOption packed(1) inz;
       dcl-s savrcdnbr like(sflrcdnbr);
       dcl-s dbUtility char(8);
       dcl-s subtext like(sbfrow);
       dcl-s savFileName char(10);
       dcl-s savLibName char(10);
       dcl-s PrtRrn like(rrn);
       dcl-s IsExitPgm ind;
       dcl-s IsLowerCase ind;
 
       // receive keys selected in JCRLKEY utility
       dcl-ds LeadingKeysDS qualified;
        KeyFields char(10) dim(9);
        KeyPosition zoned(1) dim(9);
        SelectOmit ind;
        IsFoundKey ind;
       end-ds;
 
       dcl-ds SbfRowDS qualified;
        soCon char(4) pos(33) inz('s/o:');
        soType char(7) pos(38);
        soFld char(10) pos(46);
        soComp char(2) pos(57);
        soValu char(32) pos(60);
       end-ds;
 
       // member display-------------------------------
       dcl-pr p_JCRFDMBRR extpgm('JCRFDMBRR');
        *n char(20);
        *n char(10) const;
       end-pr;
 
       // object locks---------------------------------
       dcl-pr p_JCROLCKR extpgm('JCROLCKR');
        *n char(20);
        *n char(10) const;
       end-pr;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_Mbr char(10);
        p_FileQual char(20);
        p_ObjTyp char(10);
        p_CallingCmd char(10);
        p_InitialView char(4);
        p_LeadingKeys char(101);
        p_MbrType char(10);
       end-pi;
       //---------------------------------------------------------
 
       f_RmvSflMsg(ProgId);
       LeadingKeysDS = p_LeadingKeys;
       DbUtility = '2=' + f_GetFileUtil();
       sbfSelAtr = %bitor(ND: PR);
       aKeySelec = Blue;
       IsLowerCase = *off;
 
       scDow = f_GetDayName();
 
       scKeySelec =
       'F6=Print   +
       F7=Data Base Relations   +
       F8=Object Locks  +
       F13=Fields  +
       F14=MbrList  +
       F15=' + %trimr(f_GetFileUtil())+'  F12=Cancel';
 
       scProgid = p_CallingCmd;
 
       //---------------------------------------------------------
       // Setup looping subroutine so user can refresh screen
 1b    dou IsExitPgm;
          exsr srRefreshScreen;
 1e    enddo;
       //---------------------------------------------------------
 
       dealloc(n) Fild0100ptr;
 
 1b    if not(p_CallingCmd = 'JCRLKEY');
          f_SndCompMsg(%trimr(p_CallingCmd) + ' for ' +
          f_GetQual(sFileName + sLibName) + ' - completed');
 1e    endif;
 
       *inlr = *on;
       p_LeadingKeys = LeadingKeysDS;
       return;
 
       //---------------------------------------------------------
       begsr srRefreshScreen;
 1b    if p_CallingCmd = 'JCRLKEY';
          IsIncludeSO = LeadingKeysDS.SelectOmit;
          IsFdScreen = *off;
          exsr srDataBaseRelations;
 
 1x    elseif p_InitialView = '*DBR';
          IsFdScreen = *off;
          IsIncludeSO = *on;
          IsDbrView = *on;
          exsr srDataBaseRelations;
 
 1x    elseif p_InitialView = '*MBR';
          callp p_JCRFDMBRR(p_FileQual: p_MbrType);
          *inlr = *on;
          return;
 1x    else;
          IsFdScreen = *on;
          exsr srGetFileInformation;
 1e    endif;
 
       p_InitialView = *blanks;
 
       //---------------------------------------------------------
       // Show user screen
       SflRcdNbr = 2;
 
 1b    dou 1 = 2;
          Ind.sfldsp = (rrn > 0);
          Ind.sfldspctl = *on;
          PrtRrn = Rrn;
 2b       if p_CallingCmd = 'JCRLKEY';
 3b          if rrn = 1;
                LeadingKeysDS.IsFoundKey = *off;
                IsExitPgm = *on;
 LV             leavesr;
 3x          else;
                LeadingKeysDS.IsFoundkey = *on;
 3e          endif;
 2e       endif;
 
 2b       if rrn = 1;
             SflRcdNbr = 1;
 2e       endif;
 
          //-----------------------------------------------
          write msgctl;
          write sbfctl1;
          exfmt sfooter1;
 2b       if InfdsFkey = f03;
             IsExitPgm = *on;
 LV          leavesr;
 2e       endif;
 
          f_RmvSflMsg(ProgId);
          savrcdnbr = InfdsSflRcdNbr;
 
          //---------------------------------------------------------
 2b       if InfdsFkey = f02;
             IsLowerCase = not(IsLowerCase);
 LV          leavesr;
 
 2x       elseif InfdsFkey = f05;
 LV          leavesr;
 
 2x       elseif InfdsFkey = f08;
             callp p_JCROLCKR(p_FileQual: '*FILE');
             //f_SndSflMsg(ProgId: 'Member List for ' +
             //%trimr(f_GetQual(p_FileQual)) + ' - completed');
 1i          iter;
 
 2x       elseif InfdsFkey = f12;
 3b          if (IsDbrView or IsMbrView)
                and p_CallingCmd = 'JCRFD';
                IsDbrView = *off;
                IsMbrView = *off;
                IsFdScreen = *on;
                %subst(scKeySelec: 15: 19) = 'Data Base Relations';
                exsr srGetFileInformation;
 1i             iter;
 
 3x          elseif IsMbrView and p_CallingCmd = 'JCRDBR';
                IsDbrView = *on;
                IsMbrView = *off;
                exsr srDataBaseRelations;
 1i             iter;
 
 3x          else;
                IsExitPgm = *on;
 LV             leavesr;
 3e          endif;
 2e       endif;
 
          IsDbrView = *off;
          IsMbrView = *off;
 
          //---------------------------------------------------------
 2b       if InfdsFkey = f06;
             exsr srPrint;
 
             //---------------------------------------------------------
             // toggle view to include or exclude select/omit
 2x       elseif InfdsFkey = f07;
             IsDbrView = *on;
             IsIncludeSO = not(IsIncludeSO);
             exsr srDataBaseRelations;
 
             //---------------------------------------------------------
 2x       elseif InfdsFkey = f13
             or InfdsFKey = f15;
 3b          if InfdsFKey = f13;
                FileOption = 1;  // Field descriptions
 3x          elseif InfdsFKey = f15;
                FileOption = 2;  // Data base utility
 3e          endif;
             f_RunOptionFile(FileOption:
             sFileName: sLibname: '*FIRST': '*FIRST': ProgId);
 
             //---------------------------------------------------------
 2x       elseif InfdsFkey = f14;
             callp p_JCRFDMBRR(p_FileQual: '*ALL');
             f_SndSflMsg(ProgId: 'Member List for ' +
             %trimr(f_GetQual(p_FileQual)) + ' - completed');
 
             IsFdScreen = *on;
             exsr srGetFileInformation;
 2e       endif;
 
          //---------------------------------------------------------
          // values from changed record are sent to a function to process selections
          //---------------------------------------------------------
          readc sbfdta1;
 2b       dow not %eof;
 3b          if sbfSelect > 0;
 
 4b             if sbfSelect = 3;
                   IsOption3 = *on;
                   savFileName = sFileName;
                   savLibName = sLibName;
                   p_FileQual = sbfFileHid + sbfLibHid;
                   exsr srGetFileInformation;
                   sFileName = savFileName;
                   sLibName = savLibName;
 
                   // as a precaution, limit options to those visible on screen
 4x             elseif (sbfSelect = 1 or sbfSelect = 2 or sbfSelect = 7);
                   f_RunOptionFile(
                   sbfSelect:
                   sbfFileHid:
                   sbfLibHid:
                   '*FIRST':
                   '*FIRST':
                   ProgId);
 4e             endif;
 
                IsOption3 = *off;
                SflRcdNbr = rrn;  //STAY ON SCREEN
                sbfSelect = 0;
                sbfSelAtr = UL;
                update sbfdta1;
                sbfSelAtr = %bitor(ND: PR);
 3e          endif;
             readc sbfdta1;
 2e       enddo;
 1e    enddo;
       endsr;
 
       //---------------------------------------------------------
       // load bottom of screen with key field names
       //---------------------------------------------------------
       begsr srLeadingKeysFooter;
       IsDbrView = *on;
       KeySortArry(*) = *blanks;
 
       // build string to show on screen
 1b    for ForCount = 1 to 9;
 2b       if LeadingKeysDS.KeyFields(ForCount) > *blanks;
             cc += 1;
 3b          if LeadingKeysDS.KeyPosition(ForCount) = 0;
                KeySortArry(cc) = 'X)' +
                LeadingKeysDS.KeyFields(ForCount);
 3x          else;
                KeySortArry(cc) =
                %char(LeadingKeysDS.KeyPosition(ForCount)) + ')' +
                LeadingKeysDS.KeyFields(ForCount);
 3e          endif;
 2e       endif;
 1e    endfor;
 
 1b    if cc > 1;
          sorta %subarr(KeySortArry: 1 :cc);
 1e    endif;
 
       scKeySelec = *blanks;
 1b    for ForCount = 1 to cc;
          scKeySelec = %trimr(scKeySelec) + ' ' +
          %trimr(KeySortArry(ForCount));
 1e    endfor;
       aKeySelec = White;
       endsr;
 
       //---------------------------------------------------------
       // if user selects option 3 from the data base relationship screen,
       //  load the record formats into a window
       //   otherwise load the file information subfile.
       //---------------------------------------------------------
       begsr srGetFileInformation;
 
 1b    if IsOption3;
          Ind.sfldsp3 = *off;
          Ind.sfldspctl3 = *off;
          rrn3 = 0;
          write winctl3;
 1x    else;
          sbfRow = *blanks;
          scHeadOpt = *blanks;
          Ind.sfldsp = *off;
          Ind.sfldspctl = *off;
          rrn = 0;
          write sbfctl1;
 1e    endif;
 
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
 
       sFileName = %subst(ReturnFileQual: 1: 10);
       sLibName = %subst(ReturnFileQual: 11: 10);
       PfFile = sFileName;
       PfLib = sLibName;
       IsLF = (%bitand(bit2: Fild0100ds.TypeBits) = bit2);
       PfAttrPtr = Fild0100ptr + Fild0100ds.OffsPFAttr;
       fscopePtr = Fild0100ptr + Fild0100ds.OffsFileScope;
 
       // get based on PF
 1b    if IsLF;
          PfFile = FileScopeArry.BasedOnPf;
          PfLib = FileScopeArry.BasedOnPfLib;
 1e    endif;
 
       scObjHead =
       f_BuildString('&  &  &':
       sFileName: sLibName: Fild0100ds.FileText);
 
 1b    if IsOption3;
          exsr srRow7andRow8;
          Ind.sfldsp3 = (rrn3 > 0);
          Ind.sfldspctl3 = *on;
          write winctl3;
          exfmt winfoot3;
 
 1x    elseif IsFdScreen;
          scTitle = 'File Description';
 
          //-ROW 1---------------------------------------------------
          // List keys and select/omits
 2b       if %bitand(bit6: Fild0100ds.TypeBits) = bit6;  // keyed access path
             sbfrow = *blanks;
             %subst(sbfrow:1:70) = *all'_';
 
             sbfRowAtr = Blue;
             %subst(sbfrow:1:4)= 'Keys';
 
 3b          if FileScopeArry.NumSelectOmit > 0;
                %subst(sbfrow:32:12) = ' Select/Omit';
 3e          endif;
 
 3b          if FILD0100ds.AccessType = 'KU';
                %subst(sbfrow:46) = 'Unique Keys: *YES';
 3e          endif;
             rrn += 1;
             write sbfDta1;
             sbfSelAtr = %bitor(ND: PR);
 
             exsr srKeys;
             exsr srLineRow;
 2e       endif;
 
          //--ROW 2--------------------------------------------------
          sbfRowAtr = White;
          %subst(sbfRow:1) = 'Type';
          %subst(sbfRow:8) = 'Created';
          %subst(sbfRow:20) = 'Last change';
          %subst(sbfRow:42) = 'Last Used';
          %subst(sbfRow:54) = 'Count';
          %subst(sbfRow:61) = 'RecLen';
 2b       if not(IsLF) and PfAttrDS.NumOfTriggers > 0;
             %subst(sbfRow:68) = 'Triggers';
 2e       endif;
          rrn += 1;
          write sbfDta1;
 
          sbfrow = *blanks;
          sbfRowAtr = Green;
 2b       if IsLF;
             sbfRow = 'LF';
 2x       else;
             sbfRow = 'PF';
 2e       endif;
 
          QusrObjDS = f_QUSROBJD(ReturnFileQual: '*FILE': 'OBJD0400');
          %subst(sbfrow:7) = f_GetApiISO(QusrobjDS.CreateDateTime);
          %subst(sbfrow:19) = f_GetApiISO(QusrobjDS.ChangeDateTime);
          %subst(sbfrow:30) = f_GetApiHMS(QusrobjDS.ChangeDateTime);
          %subst(sbfrow:42) = f_GetApiISO(QusrobjDS.LastUsedDate);
 2b       if QusrobjDS.NumDaysUsed > 9999;
             %subst(sbfrow:56) = '9999';
 2x       else;
             %subst(sbfrow:56) = %char(QusrobjDS.NumDaysUsed);
 2e       endif;
 
          %subst(sbfrow:64) = %char(Fild0100ds.FileRecLen);
 
 2b       if (not IsLF) and PfAttrDS.NumOfTriggers > 0;
             %subst(sbfrow:72) = %char(PfAttrDS.NumOfTriggers);
 2e       endif;
 
          rrn += 1;
          write sbfDta1;
 
          //--ROW 4--------------------------------------------------
          sbfRow = *blanks;
          rrn += 1;
          write sbfDta1;
 
          sbfRowAtr = White;
          sbfRow = *blanks;
          %subst(sbfRow:1) = 'Last Save';
          %subst(sbfRow:13) = 'Last Restore';
 
          %subst(sbfRow:27) = 'Member';
 2b       if Fild0100ds.NumMbrs >= 1;
 3b          if Fild0100ds.NumMbrs > 1;
                %subst(sbfRow:27) = 'First Member';
                %subst(sbfRow:68) = 'Members';
 3e          endif;
             %subst(sbfRow:45:7) = 'Records';
             %subst(sbfRow:59:7) = 'Deleted';
 2e       endif;
          rrn += 1;
          write sbfDta1;
 
          //--ROW 5--------------------------------------------------
          sbfRowAtr = Green;
          sbfRow = *blanks;
          %subst(sbfrow:1) = f_GetApiISO(QusrobjDS.SaveDateTime);
          %subst(sbfrow:13) = f_GetApiISO(QusrobjDS.RestoreDateTime);
 
 2b       if Fild0100ds.NumMbrs = 0;
             %subst(sbfrow:27) = 'File contains no members';
 2x       else;
             QusrmbrdDS = f_Qusrmbrd(ReturnFileQual: '*FIRST': 'MBRD0200');
             %subst(sbfrow:27) = QusrmbrdDS.Mbr;
 3b          if QusrmbrdDS.CurrNumberRecs > 9999999999;
                %subst(sbfrow:38) = '9,999,999,999';
 3x          else;
                %subst(sbfrow:38) = %editc(QusrmbrdDS.CurrNumberRecs: '1');
 3e          endif;
 
 3b          if QusrmbrdDS.DeletedRecs > 9999999999;
                %subst(sbfrow:52) = '9,999,999,999';
 3x          else;
                %subst(sbfrow:52) = %editc(QusrmbrdDS.DeletedRecs: '1');
 3e          endif;
 3b          if Fild0100ds.NumMbrs > 1;
 4b             if Fild0100ds.NumMbrs <= 9999999;
                   evalr %subst(sbfrow:66:7) = '       ' +
                   %char(Fild0100ds.NumMbrs);
 4e             endif;
 3e          endif;
 2e       endif;
 
          rrn += 1;
          write sbfDta1;
 
          //--ROW 6--------------------------------------------------
          exsr srLineRow;
 
          exsr srRow7andRow8;
 
          //--ROW 10-------------------------------------------------
          // Spin through JoinSpecDSs linked list to get JFLDs (join spec array)
 2b       if %bitand(bit2: Fild0100ds.TypeBits) = bit2;
 
 3b          if Fild0100ds.NumOfBasedPf > 1;
                LfSpecificptr = Fild0100ptr + Fild0100ds.OffsLfAttr;
 
 4b             if %bitand(bit2: LfSpecific.AttrBits) = bit2;  // JOIN
                   sbfRow = 'Join Fields';
                   sbfRowAtr = White;
                   rrn += 1;
                   write sbfDta1;
                   sbfRowAtr = Green;
                   JoinSpecPtr = Fild0100ptr + LfSpecific.JoinOffset;
 5b                dou JoinSpecDS.NextLink = 0;
                      JoinSpecArryPtr = Fild0100ptr + JoinSpecDS.OffsToJSA;
 6b                   for ForCount6 = 1 to JoinSpecDS.NumJFlds;
                         sbfrow = *blanks;
 7b                      if JoinSpecArryDS.FromNumber > 0;
                            sbfrow = %char(JoinSpecArryDS.FromNumber);
 7e                      endif;
 
                         %subst(sbfrow:5) = JoinSpecArryDS.FromField;
 7b                      if JoinSpecArryDS.ToNumber > 0;
                            %subst(sbfrow:17) = %char(JoinSpecArryDS.ToNumber);
 7e                      endif;
 
                         %subst(sbfrow:25) = JoinSpecArryDS.ToField;
                         rrn += 1;
                         write sbfDta1;
                         JoinSpecArryPtr += 48;
 6e                   endfor;
 
 6b                   if not(JoinSpecDS.NextLink = 0);
                         JoinSpecPtr = Fild0100ptr + JoinSpecDS.NextLink;
 6e                   endif;
 5e                enddo;
 4e             endif;
 3e          endif;
 2e       endif;
 
          exsr srLineRow;
 
          //---------------------------------------------------------
          // TRIGGERS
          //---------------------------------------------------------
 2b       if (not IsLF) and PfAttrDS.NumOfTriggers > 0;
             sbfRowAtr = White;
             TriggerPtr = Fild0100ptr + PfAttrDS.OffsTriggers;
             sbfSelAtr = %bitor(ND: PR);
             sbfrow = 'Program';
             %subst(sbfrow:12) = 'Library';
             %subst(sbfrow:24) = 'Event';
             %subst(sbfrow:34) = 'Time';
             rrn += 1;
             write sbfDta1;
             sbfRowAtr = Green;
 
 3b          for ForCount7 = 1 to PfAttrDS.NumOfTriggers;
                sbfrow = TriggerDS.TPrgNam;
                %subst(sbfrow:12) = TriggerDS.TPrgLib;
 4b             if TriggerDS.TEvent = '1';
                   %subst(sbfrow:24) = 'INSERT';
 4x             elseif TriggerDS.TEvent = '2';
                   %subst(sbfrow:24) = 'DELETE';
 4x             elseif TriggerDS.TEvent = '3';
                   %subst(sbfrow:24) = 'UPDATE';
 4e             endif;
 
 4b             if TriggerDS.TTime = '1';
                   %subst(sbfrow:34) = 'AFTER';
 4x             else;
                   %subst(sbfrow:34) = 'BEFORE';
 4e             endif;
                rrn += 1;
                write sbfdta1;
                TriggerPtr += 48;
 3e          endfor;
 2e       endif;
 1e    endif;
       endsr;
 
       //--ROW 7--------------------------------------------------
       // Record Formats:
       // Either load rows 7 & 8 with record format information for File
       // description screen, or load window for option 3 on data base relations screen.
       //---------------------------------------------------------
       begsr srRow7andRow8;
 1b    if IsOption3;
          sbfRowAtr3 = White;
 1x    else;
          sbfRowAtr = White;
 1e    endif;
 
 1b    if Fild0100ds.NumOfBasedPf = 1;
          SubText = 'RcdFmt';
 1x    else;
          SubText = 'RcdFmts';
 1e    endif;
 
 1b    if IsLF;
          %subst(SubText:13) = 'Over Physical File';
 1e    endif;
 
 1b    if IsOption3;
          sbfRow3 = SubText;
          rrn3 += 1;
          write winDta3;
 1x    else;
          sbfRow = SubText;
          rrn += 1;
          write sbfDta1;
 1e    endif;
 
       //--ROW 8--------------------------------------------------
 1b    if IsOption3;
          sbfRowAtr3 = Green;
 1x    else;
          sbfRowAtr = Green;
 1e    endif;
 
 1b    for ForCount5 = 1 to Fild0100ds.NumOfBasedPf;
 
          SubText= FileScopeArry.RcdFmt;
 2b       if IsLowerCase;
             SubText = %xlate(up: lo: SubText);
 2e       endif;
 
 2b       if IsLF;
             %subst(SubText:13) = FileScopeArry.BasedOnPf;
             %subst(SubText:24) = FileScopeArry.BasedOnPfLib;
 
             // to get PF object description text
             QusrObjDS = f_QUSROBJD(FileScopeArry.BasedOnPf +
                         FileScopeArry.BasedOnPfLib: '*FILE');
             %subst(SubText:35) = QusrObjDS.Text;
 2e       endif;
 
          fscopePtr += 160;
 
 2b       if IsOption3;
             sbfRow3 = SubText;
             rrn3 += 1;
             write winDta3;
 2x       else;
             sbfRow = SubText;
             rrn += 1;
             write sbfDta1;
 2e       endif;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       begsr srDataBaseRelations;
       IsFdScreen = *off;
       sbfSelAtr = %bitor(ND: PR);
       exsr srGetFileInformation;
 
 1b    If IsIncludeSO;
          scTitle = 'INCLUDE Select/Omit Logicals';
          %subst(scKeySelec: 15: 19) = 'Exclude Select/Omit';
 1x    else;
          scTitle = 'EXCLUDE Select/Omit Logicals';
          %subst(scKeySelec: 15: 19) = 'Include Select/Omit';
 1e    endif;
 
 1b    if p_CallingCmd = 'JCRLKEY';
          exsr srLeadingKeysFooter;
 1e    endif;
 
       sbfRowAtr = White;
       sbfRow = 'File';
       %subst(sbfRow:12) = 'Library';
       %subst(sbfRow:21) = 'Fmts U Keys';
       rrn += 1;
       write sbfdta1;
       sbfRowAtr = Green;
       sbfRow = *blanks;
 
       // retrieve data base relation names
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
 
       callp QDBLDBR(
             UserSpaceName:
             'DBRL0100':
             PfFile + PfLib:
             '*ALL':
             '*ALL':
             ApiErrDS);
       QdbldbrPtr = ApiHeadPtr + ApiHead.OffSetToList;
 
       // sort by file name
       qlgsortDS.RecordLength = ApiHead.ListEntrySize;
       qlgsortDS.RecordCount = ApiHead.ListEntryCount;
       qlgsortDS.NumOfKeys = 1;
       qlgsortDS = %trimr(qlgsortDS) + f_AddSortKey(21: 20);
       qlgsortDS.BlockLength = %len(%trimr(qlgsortDS));
 
       callp QLGSORT(
             qlgsortDS:
             QuickSort:
             QuickSort:
             ApiHead.ListEntryCount * ApiHead.ListEntrySize:
             ApiHead.ListEntryCount * ApiHead.ListEntrySize:
             ApiErrDS);
 
       // Process list entries in user space
 1b    for ForCount1 = 0 to ApiHead.ListEntryCount;
          sbfSelAtr = UL;
 
          // put PF first in output
 2b       if ForCount1 > 0;
             WorkFileQual = %subst(QuickSort: 21: 20);
 2x       else;
             WorkFileQual = PfFile + PfLib;
 2e       endif;
 
 2b       if not(WorkFileQual = *blanks or WorkFileQual = '*NONE');
             PfFile = %subst(WorkFileQual: 1: 10);
             PfLib = %subst(WorkFileQual: 11: 10);
 
             AllocatedSize = f_GetAllocatedSize(WorkFileQual:'*FIRST');
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
 
 3b          if ApiErrDS.BytesReturned > 0;
                sbfSelAtr = %bitor(ND: PR);
                KeyList = '**' +
                f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal);
 
                %subst(sbfrow:1) = PfFile;
                %subst(sbfrow:12) = PfLib;
                rrn += 1;
                write sbfdta1;
 3x          else;
                // set offsets
                fscopePtr = Fild0100ptr + Fild0100ds.OffsFileScope;
 4b             if (not IsIncludeSO)
                   and FileScopeArry.NumSelectOmit > 0
                   // or Fild0100ds.AccessType='AR'
                   or Fild0100ds.AccessType='EV';
 
 5b                if ForCount1 > 0;
                      QdbldbrPtr += ApiHead.ListEntrySize;
 5e                endif;
 
 1i                iter;
 4e             endif;
 
                //---------------------------------------------------------
                exsr srKeys;
 3e          endif;
 2e       endif;
 2b       if ForCount1 > 0;
             QdbldbrPtr += ApiHead.ListEntrySize;
 2e       endif;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // If this utility is called from JCRLKEY
       // (find desired access path). then there are
       // two arrays to process.
       // LeadingKeysDS.KeyFields will contain key name(s)
       // LeadingKeysDS.KeyPosition will contain required position in key list.
       // if LeadingKeysDS.KeyPosition(cc) = 0, then field in any position.
       //---------------------------------------------------------
       begsr srKeys;
 1b    if p_CallingCmd = 'JCRLKEY';
          bb = FileScopeArry.OffsKeySpecs;
          IsValidKeys = *on;
 2b       for cc = 1 to %elem(LeadingKeysDS.KeyFields);
 3b          if LeadingKeysDS.KeyFields(cc) = *blanks;
 2v             leave;
 3e          endif;
 
             FileScopeArry.OffsKeySpecs = bb;
             IsThisKeyOK = *off;
             KeySpecsPtr = Fild0100ptr + FileScopeArry.OffsKeySpecs;
 3b          for ForCount2 = 1 to FileScopeArry.NumOfKeys;
 4b             if LeadingKeysDS.KeyFields(cc) = KeySpecsDS.KeyFieldName
                   and (LeadingKeysDS.KeyPosition(cc) = 0
                   or LeadingKeysDS.KeyPosition(cc) = ForCount2);
                   IsThisKeyOK = *on;
 3v                leave;
 4e             endif;
                KeySpecsPtr += 32;
 3e          endfor;
 
 3b          if not IsThisKeyOK;
                IsValidKeys = *off;
 2v             leave;
 3e          endif;
 2e       endfor;
 
 2b       if not IsValidKeys;
 LV          leavesr;
 2e       endif;
          FileScopeArry.OffsKeySpecs = bb;
 1e    endif;
 
       //---------------------------------------------------------
       sbfRowAtr = Green;
       sbfRow = *blanks;
       KeyList = *blanks;
       sbfFileHid = PfFile;
       sbfLibHid = PfLib;
 
 1b    if IsDbrView;
          scHeadOpt = '1=Field Descriptions  ' +
          %trimr(DbUtility) + '  3=Record Formats';
          %subst(sbfrow:1) = PfFile;
          %subst(sbfrow:12) = PfLib;
          %subst(sbfrow:23) = %char(Fild0100ds.NumRcdFmts);
 2b       if FILD0100ds.AccessType = 'KU';
             %subst(sbfrow:25) = 'U';
 2e       endif;
 1e    endif;
 
       // Some join lfs do not return an offset to
       // to file scope array.  IBM has been notified.
 1b    if Fild0100ds.OffsFileScope > 0
          and %bitand(bit6: Fild0100ds.TypeBits) = bit6;  // keyed access path
 
          KeySpecsPtr = Fild0100ptr + FileScopeArry.OffsKeySpecs;
 2b       for ForCount3 = 1 to FileScopeArry.NumOfKeys;
 
             // make (key1: key2) for pasting into rpg program
 3b          If IsLowerCase;
 
                // open parenthesis
 4b             if FileScopeArry.NumOfKeys > 1
                   and ForCount3 = 1;
                   kwork='('+
                   %trimr(%xlate(up:lo:KeySpecsDS.KeyFieldName)) +':';
 
                   // close parenthesis
 4x             elseif FileScopeArry.NumOfKeys > 1 and
                   ForCount3 = FileScopeArry.NumOfKeys;
                   kwork = %trimr(%xlate(up:lo:KeySpecsDS.KeyFieldName)) +')';
 
                   // full colon between fields
 4x             elseif FileScopeArry.NumOfKeys > 1;
                   kwork = %trimr(%xlate(up:lo:KeySpecsDS.KeyFieldName)) +':';
 
                   // single key with no ():
 4x             else;
                   kwork = %trimr(%xlate(up:lo:KeySpecsDS.KeyFieldName));
 4e             endif;
 
 3x          else;
                kwork = %trimr(KeySpecsDS.KeyFieldName);
 
             // check for descending keys
 3b          if %bitand(bit0: KeySpecsDS.KeySequenBits) = bit0;
                kwork = kwork + '(D)';
 3e          endif;
 3e          endif;
 
             //---------------------------------------------------------
             // If keys will not fit on one line, drop down to second line.
             // On the file description display the keys start at the beginning of the
             // subfile record.
             //---------------------------------------------------------
 3b          if (IsDbrView
                and %len(%trimr(KeyList)) + (%len(kwork) + 1) > %size(KeyList))
                or ((not isDbrView)
                and %len(%trimr(sbfRow)) + (%len(kwork) + 1) > %size(sbfRow));
 
 4b             if IsDbrView;
                   %subst(sbfrow:26) = KeyList;
 4e             endif;
 
                rrn += 1;
                write sbfDta1;
                sbfRow = *blanks;
                KeyList = *blanks;
                sbfSelAtr = %bitor(ND: PR);
 3e          endif;
 
 3b          if IsDbrView;
                KeyList = %trimr(KeyList) + ' ' + kwork;
 3x          else;
                sbfRow = %trimr(sbfRow) + ' ' + kwork;
 3e          endif;
             KeySpecsPtr += 32;
 2e       endfor;
 2b       if IsDbrView;
             %subst(sbfrow:26) = KeyList;
 2e       endif;
 1e    endif;
 
       rrn += 1;
       write sbfDta1;
       sbfSelAtr = %bitor(ND: PR);
 
       //---------------------------------------------------------
       // extract select/omit fields
 1b    if Fild0100ds.OffsFileScope > 0
          and FileScopeArry.NumSelectOmit > 0;
          %subst(sbfRow:25:11) = 'Select/Omit';
          SbfRowDS.soCon = 's/o:';
          SelectOmitSpecPtr = Fild0100ptr + FileScopeArry.OffsSelectOmit;
 
 2b       for ForCount3 = 1 to FileScopeArry.NumSelectOmit;
 3b          if SelectOmitSpec.StatementRule = 'S';
                SbfRowDS.soType = '*SELECT';
 3x          elseif SelectOmitSpec.StatementRule = 'O';
                SbfRowDS.soType = '*OMIT';
 3x          elseif SelectOmitSpec.StatementRule = 'A';
                SbfRowDS.soType = '*AND';
 3e          endif;
             SbfRowDS.soFld = SelectOmitSpec.FieldName;  //field name
             SbfRowDS.soComp = SelectOmitSpec.CompRelation;  //EQ,NE,GT,LT,ETC
             SelectOmitParmPtr = Fild0100ptr + SelectOmitSpec.OffsToParms;
 
             //---------------------------------------------------------
             // extract select/omit values
 3b          for ForCount4 = 1 to SelectOmitSpec.NumberOfParms;
                SbfRowDS.soValu = %subst(
                SelectOmitParm.ParmValue:
                1:
                SelectOmitParm.ParmLength-20);
                sbfRow = SbfRowDS;
                rrn += 1;
                write sbfDta1;
                SbfRowDS.soCon = *blanks;
                SelectOmitParmPtr = Fild0100ptr + SelectOmitParm.OffsToNext;
 3e          endfor;
             SelectOmitSpecPtr += 32;
 2e       endfor;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       begsr srLineRow;
       sbfRowAtr = Blue;
       sbfrow = *blanks;
       %subst(sbfrow:1:70) = *all'_';
       rrn += 1;
       write sbfDta1;
       endsr;
 
       //---------------------------------------------------------
       begsr srPrint;
       f_OvrPrtf('JCRFDP': '*JOB' : 'JCRFDP');
       open JCRFDP;
 
       write PrtHead;
       IsOverFlow = *off;
 
 1b    for ForCount = 1 to PrtRrn;
          chain ForCount sbfdta1;
 2b       if IsOverFlow;
             write PrtHead;
             IsOverFlow = *off;
 2e       endif;
          write PrtLine;
 1e    endfor;
 
       close JCRFDP;
       f_DltOvr('JCRFDP');
 
       // generate completion message then send to message subfile
       f_DisplayLastSplf(ProgId: '*PRINT');
       f_SndSflMsg(ProgId: f_qmhrcvpm(3));
       endsr;
