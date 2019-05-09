       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRDQER - Data queue entries display
       //  call QmhrdQm API for no-touch display of dataq entries as messages.
       //---------------------------------------------------------
       // Note storage model was changed to teraspace to accommodate large
       //  number of entries data queues.
 
       // Additional changes to pull page-at-a-time from allocated memory, page down,
       //  and position to list entry number to allow for over 9999 entries in queue.
       //    use list entry number positioning instead of screen number based positioning.
       //     Add a show last entry button.
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCRDQED workstn sfile(sbfdta1: rrn) infds(infds) indds(ind);
 
       /define ApiErrDS
       /define Constants
       /define Cvthc
       /define Infds
       /define FunctionKeys
       /define Ind
       /define Qmhqrdqd
       /define f_BuildString
       /define f_GetDayName
       /define f_DecodeApiTimeStamp
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s TempqDS char(116);
       dcl-s ColumnShift int(10);
       dcl-s ForCount int(10);
       dcl-s ofs int(10);
       dcl-s qTrimLen int(10);
       dcl-s v0200len int(10);
       dcl-s xx int(10);
       dcl-s BytesAvail int(10);
       dcl-s ff uns(5);
       dcl-s Shift uns(5) inz(58);
       dcl-s IsHexMode ind;
       dcl-c cSflPag const(7);
       dcl-c Hex40 const(x'40');
       dcl-s PageSize uns(3) inz(14);
       dcl-s StartPtr pointer inz(*null);
       dcl-s EntryCount uns(3);
 
       dcl-c cRuler1 const('....+....1....+....2....+....3....+....4....+....5-
       ....+....6....+....7....+....8....+....9....+....0....+....1....+....2.-
       ...+....3....+....4....+....5....+....6....+....7....+....8....+....9..-
       ..+....0....+....1....+....2');
 
       dcl-c cRuler2 const('. . . . + . . . . 1 . . . . + . . . . 2 . . . . + -
       . . . . 3 . . . . + . . . . 4 . . . . + . . . . 5 . . . . + . . . . 6 .-
        . . . + . . . . 7 . . . . + . . . . 8 . . . . + . . . . 9 . . . . + . -
       . . . 0 . . . . + . . . . 1 . . . . + . . . . 2 . . . . + . . . . 3 . .-
        . . + . . . . 4 . . . . + . . . . 5 . . . . + . . . . 6 . . . . + . . -
       . . 7 . . . . + . . . . 8 . . . . + . . . . 9 . . . . + . . . . 0 ');
 
       //---------------------------------------------------------
       // Retrieve Data Queue Message
       dcl-pr QmhrdQm extpgm('QMHRDQM');
        *n like(QmhrdQmDS) options(*varsize);  // receiver
        *n int(10) const;  // receiver length
        *n char(8) const;  // api format
        *n char(20);  // dtaq and lib
        *n like(RDQS0200DS) options(*varsize) const; // key information
        *n int(10) const;  // key info length
        *n char(8) const;  // information
        *n like(ApiErrDS) options(*varsize);
       end-pr;
 
       dcl-ds QmhrdQmDS qualified based(QMHRDQMPtr);
        BytesReturned int(10) pos(1);
        BytesAvail int(10) pos(5);
        MsgRtnCount int(10) pos(9);
        MsgAvlCount int(10) pos(13);
        KeyLenRtn int(10) pos(17);
        KeyLenAvl int(10) pos(21);
        MsgTxtRtn int(10) pos(25);
        MsgTxtAvl int(10) pos(29);
        EntryLenRtn int(10) pos(33);
        EntryLenAvl int(10) pos(37);
        OffsetToEntry int(10) pos(41);
        DtaqLib char(10) pos(45);
       end-ds;
 
       // Move pointer through message entries
       dcl-ds ListEntryDS qualified based(ListEntryPtr);
        NextEntry int(10);
        Datetime char(8);  // TOD format
        MessageData char(1000);  // variable text
       end-ds;
 
       // Message selection - RDQS0100 nonkeyed queues  RDQS0200 Keyed data queues
       dcl-ds rdqs0100DS qualified;
        Selection char(1) pos(1) inz('A');   // all
        MsgByteRtv int(10) pos(5) inz;  // message bytes to rtv
       end-ds;
 
       dcl-ds rdqs0200DS qualified;
        Selection char(1) inz('K') pos(1);  // Keyed
        KeyOrder char(2) inz('GE') pos(2);
        MsgByteRtv int(10) inz pos(5);  // message bytes to rtv
        KeyByteRtv int(10) inz pos(9);  // keys bytes to rtv
        KeyLen int(10) inz pos(13);  // key length
        Key char(256) pos(17);  // key value
       end-ds;
 
       // Divide entry up into subfile fields
       dcl-ds ViewqDS inz;
        Viewq1;
        Viewq2;
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_DtaqNameQual char(20);
        p_DtaqObjType char(10);
       end-pi;
       //---------------------------------------------------------
 
       vSflMode = *on;
       ind.sfldrop = vSflMode;
       vpos = 1;
       QMHRDQMptr = %alloc(1);
       scDow = f_GetDayName();
 
       // retrieve data queue description
       callp QMHQRDQD(
             QmhqrdqdDS:
             %size(QmhqrdqdDS):
             'RDQD0100':
             p_DtaqNameQual);
 
       exsr srRefresh;
 
       // Display subfile.  Calc number of screens in subfile.
       vSrecNum = 1;
       ColumnShift = 0;
       sEntryLen = QmhqrdqdDS.MsgLength;
       vQTotCnt = QmhrdQmDS.MsgAvlCount;
       scObjHead =
       f_BuildString('&  &  &':
       %subst(p_DtaqNameQual: 1: 10): QmhrdQmDS.DtaqLib: QmhqrdqdDS.Text);
 
 1b    dou 1 = 2;
          xx = ofs + 1;
 2b       dow xx > 100;
             xx -= 100;
 2e       enddo;
 2b       if IsHexMode;
             scRuler = %subst(cRuler2: (xx*2) - 1);
 2x       else;
             scRuler = %subst(cRuler1: xx);
 2e       endif;
 
 2b       if ofs = 0;
             %subst(scRuler: 1: 1) = '*';
 2e       endif;
 
          ind.sfldsp = (rrn > 0);
          ind.sfldspctl = *on;
          ind.IsactivateF14 = (QmhqrdqdDS.Sequence = 'K');
 
          write sheader;
          exfmt sbfctl1;
          ind.sfldrop = vSflMode;
 
          // exit / cancel
 2b       if InfdsFkey = f03 or InfdsFkey = f12;
             dealloc(n) QMHRDQMptr;
             *inlr = *on;
             return;
 
 2x       elseif ind.IsChange;
 3b          if vEntNum = 0;
                vEntNum = 1;
 3x          elseif vEntNum > QmhrdQmDS.MsgRtnCount;
                vEntNum = QmhrdQmDS.MsgRtnCount;
 3e          endif;
             exsr srLoadOnePage;
 1i          iter;
 
 2x       elseif InfdsFkey  = fPageup;
 3b          if vEntNum - PageSize < 0;
                vEntNum = 1;
 3x          else;
                vEntNum -= PageSize;
 3e          endif;
             exsr srLoadOnePage;
 1i          iter;
 
 2x       elseif InfdsFkey = fPageDown;
 3b          if vEntNum + PageSize <= QmhrdQmDS.MsgRtnCount;
                vEntNum += PageSize;
 3e          endif;
             exsr srLoadOnePage;
 1i          iter;
 
             // show last message
 2x       elseif InfdsFkey = f06;
             vEntNum = QmhrdQmDS.MsgRtnCount;
             exsr srLoadOnePage;
 
             // refresh
 2x       elseif InfdsFkey = f05;
             exsr srRefresh;
 
             // change display mode
 2x       elseif InfdsFkey = f10;
 3b          if IsHexMode;
                IsHexMode = *off;
                Shift = 58;
 3x          else;
                IsHexMode = *on;
                Shift = 25;
 3e          endif;
 
             exsr srUpdSfl;
 
             // fold/unfold
 2x       elseif InfdsFkey = f11;
 3b          if vSflMode = *on;
                vSflMode = *off;
 3x          else;
                vSflMode = *on;
 3e          endif;
             ind.sfldrop = vSflMode;
 
 2x       elseif InfdsFkey = f14;
             ind.IsKeysMode = (not ind.IsKeysMode);
             exsr srUpdSfl;
 
             // shift column position to left
 2x       elseif InfdsFkey = f19;
             ColumnShift -= Shift;
 3b          if ColumnShift < 0;
                ColumnShift = 1;
 3e          endif;
             vdspPos = ColumnShift;
 
             // shift column position to right
 2x       elseif InfdsFkey = f20;
             ColumnShift += Shift;
 3b          if ColumnShift >= QmhqrdqdDS.MsgLength;
                ColumnShift = QmhqrdqdDS.MsgLength - 1;
 3e          endif;
             vdspPos = ColumnShift;
 2e       endif;
 
          //---------------------------------------------------------
          // Determine column offset user wants to display.
          //---------------------------------------------------------
 2b       if vdspPos > 0;
             ofs = vdspPos - 1;
 3b          if ofs < 0;
                ofs = 0;
 3e          endif;
 3b          if ofs >= QmhqrdqdDS.MsgLength;
                ofs = QmhqrdqdDS.MsgLength - 1;
 3e          endif;
             exsr srUpdSfl;
             vpos = ofs + 1;
             vdspPos = 0;
 2e       endif;
 
          // vEntNum = 0;
 1e    enddo;
 
       //---------------------------------------------------------
       // Different type dataqs require different parm list to API.
       // An anomaly is that usual method of retrieving 8 bytes to get
       // bytes available does not work.
       //---------------------------------------------------------
       begsr srRefresh;
 1b    if QmhqrdqdDS.Sequence = 'K';
          sAccessTyp = '*KEYED (' + %char(QmhqrdqdDS.KeyLength) + ')';
          rdqs0200DS.MsgByteRtv = QmhqrdqdDS.MsgLength;
          rdqs0200DS.KeyByteRtv = QmhqrdqdDS.KeyLength;
          rdqs0200DS.KeyLen = QmhqrdqdDS.KeyLength;
          v0200Len = QmhqrdqdDS.KeyLength + 16;
 
          QMHRDQMptr = %realloc(QMHRDQMptr: %len(QmhrdQmDS));
          callp QMHRDQM(
                QmhrdQmDS:
                %len(QmhrdQmDS):
                'RDQM0200':
                p_DtaqNameQual:
                rdqs0200DS:
                v0200Len:
                'RDQS0200':
                ApiErrDS);
          BytesAvail = QmhrdQmDS.BytesAvail;
 
          // Use pointer based allocated memory as API can return more entries
          // than allowed by normal RPG field lengths or *sgnlvl storage
          QMHRDQMptr = %realloc(QMHRDQMptr: BytesAvail);
 
          callp QMHRDQM(
                QmhrdQmDS:
                BytesAvail:
                'RDQM0200':
                p_DtaqNameQual:
                rdqs0200DS:
                v0200Len:
                'RDQS0200':
                ApiErrDS);
 1x    else;
          sAccessTyp = '*NON-KEYED';
          rdqs0100DS.MsgByteRtv = QmhqrdqdDS.MsgLength;
 
          QMHRDQMptr = %realloc(QMHRDQMptr: %len(QmhrdQmDS));
 
          callp QMHRDQM(
                QmhrdQmDS:
                %len(QmhrdQmDS):
                'RDQM0100':
                p_DtaqNameQual:
                rdqs0100DS:
                %size(rdqs0100DS):
                'RDQS0100':
                ApiErrDS);
          BytesAvail = QmhrdQmDS.BytesAvail;
 
          QMHRDQMptr = %realloc(QMHRDQMptr: BytesAvail);
          callp QMHRDQM(
                QmhrdQmDS:
                BytesAvail:
                'RDQM0100':
                p_DtaqNameQual:
                rdqs0100DS:
                %size(rdqs0100DS):
                'RDQS0100':
                ApiErrDS);
 1e    endif;
 
       vEntNum = 1;
       exsr srLoadOnePage;
       endsr;
 
 
       //------------------------------------------------------------------
       // Spin through allocated memory to load one page from selected list entry number
       //------------------------------------------------------------------
       begsr srLoadOnePage;
       rrn = 0;
       ind.sfldsp = *off;
       ind.sfldspctl = *off;
       write sbfctl1;
 
       //------------------------------------------------------------------
       // I need to get the list entry pointer to where the first subfile record
       // will be loaded from.  Only way I know is (since offset to next
       // entry could be variable) is to spin through X number of entries
       // so pointer is in right place to load next page of subfile.
       //------------------------------------------------------------------
 1b    if QmhrdQmDS.MsgRtnCount > 0;
          ListEntryPtr = QMHRDQMptr + QmhrdQmDS.OffsetToEntry;
          ind.sflend = *off;
 
 2b       for ForCount = 1 to (vEntNum-1);
 3b          if ForCount > QmhrdQmDS.MsgRtnCount;
 2v             leave;
 3e          endif;
             ListEntryPtr = QMHRDQMptr + ListEntryDS.NextEntry;
 2e       endfor;
 
          // save starting pointer position
          StartPtr =  ListEntryPtr;
          EntryCount = 0;
 
 2b       for ForCount = vEntNum to vEntNum+(PageSize-1);
 3b          if ForCount > QmhrdQmDS.MsgRtnCount;
             ind.sflend = *on;
 2v             leave;
 3e          endif;
 
             // save entry count
             EntryCount += 1;
 
             // Decode Date-Time_Stamp into MM/DD/YY and HH:MM:SS
             ApiStampDS = f_DecodeApiTimeStamp(ListEntryDS.Datetime);
 
             Qudate =
             f_BuildString('&/&/&':
             %subst(ApiStampDS.MMDD: 1: 2):
             %subst(ApiStampDS.MMDD: 3: 2):
             ApiStampDS.YY);
 
             Qutime =
             f_BuildString('&:&:&':
             %subst(ApiStampDS.HHMMSS: 1: 2):
             %subst(ApiStampDS.HHMMSS: 3: 2):
             %subst(ApiStampDS.HHMMSS: 5: 2));
 
             exsr srTempqDS;
             exsr srDataToDsp;
             rrn += 1;
             write sbfdta1;
 3b          if rrn = 9999;
 2v             leave;
 3e          endif;
 
             ListEntryPtr = QMHRDQMptr + ListEntryDS.NextEntry;
 2e       endfor;
 1e    endif;
       endsr;
 
 
       //---------------------------------------------------------
       // Update Subfile.
       //---------------------------------------------------------
       begsr srUpdSfl;
       ListEntryPtr = StartPtr;
 1b    for xx = 1 to EntryCount;
          chain xx sbfdta1;
          exsr srTempqDS;
          exsr srDataToDsp;
          update sbfdta1;
          ListEntryPtr = QMHRDQMptr + ListEntryDS.NextEntry;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // Fill TempqDS from allocated memory.
       // If Keyed data queue, then there is unexplained 5 bytes at beginning of each key.
       // Size of msg entry could be larger than msg variable.
       //  qTrimLen makes sure this does not blow up!
       //---------------------------------------------------------
       begsr srTempqDS;
       qTrimLen = QmhqrdqdDS.MsgLength - ofs;
 
 1b    if QmhqrdqdDS.Sequence = 'K';
 2b       if (QmhqrdqdDS.KeyLength + 5) + QmhqrdqdDS.MsgLength
             > %size(ListEntryDS.MessageData);
             qTrimLen =
             %size(ListEntryDS.MessageData) - (QmhqrdqdDS.KeyLength + 5);
 2e       endif;
 
 2b       if qTrimLen > %len(ViewqDS);
             qTrimLen = %len(ViewqDS);
 2e       endif;
 
          // Entry/Key display mode.
 2b       if ind.IsKeysMode;
             TempqDS =
             %subst(ListEntryDS.MessageData: ofs + 5: QmhqrdqdDS.KeyLength);
 2x       else;
             TempqDS =
             %subst(ListEntryDS.MessageData:
             QmhqrdqdDS.KeyLength + ofs + 5: qTrimLen);
 2e       endif;
 
 1x    else;
 2b       if QmhqrdqdDS.MsgLength > %size(ListEntryDS.MessageData);
             qTrimLen = %size(ListEntryDS.MessageData);
 2e       endif;
 
 2b       if qTrimLen > %len(ViewqDS);
             qTrimLen = %len(ViewqDS);
 2e       endif;
 
          // When actual message received is shorter than maximum entry possible
 2b       if ofs + 1 <= %size(ListEntryDS.MessageData);
             TempqDS = %subst(ListEntryDS.MessageData: ofs + 1);
 2x       else;
             TempqDS = *blanks;
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Move data to display fields.
       //---------------------------------------------------------
       begsr srDataToDsp;
 1b    if IsHexMode;
          ViewqDS = '';
          callp cvthc(%addr(ViewqDS):
                %addr(TempqDS):
                qTrimLen * 2);
 1x    else;
          ViewqDS = %subst(TempqDS: 1);
 
          // Drop anything below Hex 40 before sending to screen.
          ff = qTrimLen;
 2b       for aa = 1 to ff;
 3b          if %subst(ViewqDS: aa: 1) < Hex40;
                %subst(ViewqDS: aa: 1) = ' ';
 3e          endif;
 2e       endfor;
 
 2b       if qTrimLen + 1 < %len(ViewqDS);
             %subst(ViewqDS: qTrimLen + 1) = *all' ';
 2e       endif;
 1e    endif;
       endsr;
