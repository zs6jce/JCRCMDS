       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRANZDR - DSPF screen layout with field names print
       // Pointers to pointers to pointer arrays. The Retrieve Display
       // File Info API (QDFRTVFD) is a complicated piece of work. (97 page API documentation)
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define Constants
       /define BitMask
       /define Cvthc
       /define f_OvrPrtf
       /define f_BuildString
       /define f_DisplayLastSplf
       /define f_DltOvr
       /define f_Qusrobjd
       /define Atof
       /define f_GetDayName
       /define f_SndEscapeMsg
       /define f_RtvMsgAPI
       /define Qecedt
       /define QecedtAlpha
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRANZDP printer oflind(IsOverFlow) usropn;
 
       dcl-s dd uns(5);
       dcl-s zz uns(5);
       dcl-s rr uns(3);
       dcl-s FillChar char(3000);
       dcl-s FieldNam char(10);
       dcl-s row uns(3);
       dcl-s PrintRow uns(3);
       dcl-s col uns(3);
       dcl-s MaxCol uns(3);
       dcl-s NumberDec uns(3);
       dcl-s NameSpace uns(3);
       dcl-s pConst char(132);
       dcl-s ReceiverVar char(256);
       dcl-s ReceiverVarLen int(10);
       dcl-s EditMask char(256);
       dcl-s Alpha63 char(63);
       dcl-s CharParm char(256);
       dcl-s EditMaskLen int(10);
       dcl-s ZeroSuppress char(1);
       dcl-s ProgramLen int(10);
       dcl-s FldNameRowArry char(132) dim(6);
       dcl-s IsEdit ind;
 
       // Retrieve Display File Description
       dcl-pr QDFRTVFD extpgm('QDFRTVFD');
        *n char(8) options(*varsize); // Receiver
        *n int(10) const; // Receiver Length
        *n char(8) const; // Api Format
        *n char(20) const; // Qualified File Name
        *n like(apierrds);
       end-pr;
 
       // Convert Double Float to Packed Decimal
       dcl-pr QXXDTOP extproc(*dclcase);
        *n pointer value;
        *n int(10) value;  // digits
        *n int(10) value;  // decimals
        *n float(8) value; // double
       end-pr;
 
       // Base File
       dcl-ds QDFFBASEds based(qdffbaseptr) qualified;
        OffsetToQDFFINFO int(5) pos(9);
        NumRecFmts int(5) pos(11);
        NumScreenSizes int(5) pos(14);
       end-ds;
 
       // Screen Size Table
       dcl-ds QDFFSCRAds based(qdffscraptr) qualified;
        ScreenID char(1) pos(1);
       end-ds;
 
       // Display Device Dependent
       dcl-ds QDFFINFOds based(qdffinfoptr) qualified;
        LengthFileHeader int(10) pos(1);
        OffsetToQDFWFLEI int(10) pos(5);
       end-ds;
 
       // Displacement to Record Format Table
       dcl-ds QDFARFTEds based(qdfarfteptr) qualified;
        RcdFmtName char(10) pos(1);
        OffsetToQDFFRINF int(10) pos(13);
       end-ds;
 
       // Record Header
       dcl-ds QDFFRINFds based(qdffrinfptr) qualified;
        LengthRecordHeader int(10) pos(1);
        OffsetToQDFFFITB int(10) pos(5);
        NumFields int(5) pos(17);
        OffsetToQDFFRDPD int(5) pos(29);
       end-ds;
 
       // Fields Indexing Table
       dcl-ds QDFFFITBds based(qdfffitbptr) qualified;
        OffsetToQDFFFINF int(10) pos(1);
        DisplayLength int(5) pos(7);
       end-ds;
 
       // Field Header
       dcl-ds QDFFFINFds based(qdfffinfptr) qualified;
        FieldAttribute char(1) pos(3);
        DateTimeBits char(1) pos(4);
        SystemUserBits char(1) pos(5);
       end-ds;
 
       // Named Field Header
       dcl-ds QDFFFNAMds based(qdfffnamptr) qualified;
        ProgramLen int(5) pos(5);
        NumberDec char(1) pos(7);
        DataType char(1) pos(8);
        NamedOffsetToQDFFFDPD int(5) pos(11);
       end-ds;
 
       // Constant Header
       dcl-ds QDFFFCONds based(qdfffconptr) qualified;
        ConstantOffsetToQDFFFDPD int(5) pos(3);
       end-ds;
 
       // Record Level Device Dependent
       dcl-ds QDFFRDPDds based(qdffrdpdptr) qualified;
        OffsetToQDFFRCTB int(10) pos(1);
       end-ds;
 
       // Row Column Table
       dcl-ds QDFFRCTBds based(qdffrctbptr) qualified;
        QDFFRCTEds char(2) pos(7) dim(1000);
       end-ds;
 
       // Where Used File
       dcl-ds QDFWFLEIds based(qdfwfleiptr) qualified;
        OffsetToQDFWRCDI int(5) pos(1);
        OffsetToQDFFNTBL int(10) pos(9);
       end-ds;
 
       // Where Used Record
       dcl-ds QDFWRCDIds based(qdfwrcdiptr) qualified;
        OffsetToQDFWFLDI int(5) pos(1);
        RecordLengthWhereUsed int(10) pos(5);
       end-ds;
 
       // Where Used Field
       dcl-ds QDFWFLDIds based(qdfwfldiptr) qualified;
        FieldLengthWhereUsed int(5) pos(1);
        FieldNameIndex int(10) pos(7);
        FieldLength int(5) pos(11);
       end-ds;
 
       // Field Name Table
       dcl-ds QDFFNTBLds based(qdffntblptr) qualified;
        NumberOfEntries int(10) pos(1);
        FieldNameArry char(10) pos(5) dim(1000);
       end-ds;
 
       // Device Field Dependent
       dcl-ds QDFFFDPDds based(qdfffdpdptr) qualified;
        OffsetToQDFFCOSA int(5) pos(5);
       end-ds;
 
       // Constant Keywords
       dcl-ds QDFFCOSAds based(qdffcosaptr) qualified;
        NumberEntries int(5) pos(1);
       end-ds;
 
       // Keyword Entries
       dcl-ds QDFFCCOAds based(qdffccoaptr) qualified;
        Category char(1) pos(1);
        OffsetToCategory int(5) pos(2);
       end-ds;
 
       // Keyword 24 structure
       dcl-ds QDFKEDTRds based(qdfkedtrptr) qualified;
        NumberOfKeys int(5) pos(1);
       end-ds;
 
       // Keyword Parameters
       dcl-ds QDFKEDTPds based(qdfkedtpptr) qualified;
        KeyWord char(1) pos(1);
        ZeroSuppress char(1) pos(2);
        LenEditMask int(5) pos(3);
        EditMask char(256) pos(6);
       end-ds;
 
       // Keyword 23 structure
       dcl-ds QDFKDFTds based(qdfkdftptr) qualified;
        NumberOfKeys int(5) pos(1);
       end-ds;
 
       // Keword Parameters
       dcl-ds QDFKDFPMds based(qdfkdfpmptr) qualified;
        LengthOfData int(5) pos(5);
        MscgonData char(4000) pos(7);
       end-ds;
 
       dcl-ds GetAllocSizeDS qualified;
        SizeReturned int(10) pos(5);
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_FileQual char(20);
        p_ObjTyp char(10);
        p_Output char(8);
       end-pi;
       //---------------------------------------------------------
 
       // Print headings.  Load print position 'rulers'
       f_OvrPrtf('JCRANZDP': '*JOB': %subst(p_FileQual: 1: 10));
       open JCRANZDP;
       scDow = f_GetDayName();
 
       QusrObjDS = f_QUSROBJD(p_FileQual: '*FILE');
       %subst(p_FileQual: 11: 10) = QusrObjDS.ReturnLib;
 
       scObjHead =
       f_BuildString('&         File: &   &   &':
       'JCRANZDR': QusrObjDS.ObjNam: QusrObjDS.ReturnLib: QusrObjDS.Text);
 
       write PrtHead;
       IsOverFlow = *off;
 
       // load output positions ruler
 1b    for dd = 1 to 13;
          %subst(LayOut:dd*10:1) = %subst(%editc(dd: '3'): 5: 1);
 1e    endfor;
       write PrtLine;
 
       %subst(LayOut:1:132) = *all'1234567890';
       write PrtLine;
 
       //---------------------------------------------------------
       // Receiver variable returned by this API can be larger than max rpg field size.
       // 'Allocate memory size and point to it' then call again so all data will fit.
       callp QDFRTVFD(
             GetAllocSizeDS:
             %len(GetAllocSizeDS):
             'DSPF0100':
             p_FileQual:
             ApiErrds);
 
 1b    if ApiErrDS.BytesReturned > 0;  //error occurred
          f_SndEscapeMsg(ApiErrDS.ErrMsgId + ': ' +
          %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal)));
 1e    endif;
 
       QDFFBASEptr = %alloc(GetAllocSizeDS.SizeReturned);
       callp QDFRTVFD(
             QDFFBASEds:
             GetAllocSizeDS.SizeReturned:
             'DSPF0100':
             p_FileQual:
             ApiErrds);
 
       // set pointer to Screen Size IDs
       QDFFSCRAptr = QDFFBASEptr + 19;
 1b    if QDFFSCRAds.ScreenID = x'03';
          MaxCol = 80;
 1x    else;
          MaxCol = 132;
 1e    endif;
 
       // set pointer to File Header Section QDFFINFOds
       QDFFINFOptr =
       %addr(QDFFBASEds) + QDFFBASEds.OffsetToQDFFINFO;
 
       // Where Used File Information pointer
       QDFWFLEIptr = QDFFINFOptr + QDFFINFOds.OffsetToQDFWFLEI;
 
       // Field Name table pointer
       QDFFNTBLptr = QDFWFLEIptr + QDFWFLEIds.OffsetToQDFFNTBL;
 
       // Where Used Record information starting pointer
       QDFWRCDIptr = QDFWFLEIptr + QDFWFLEIds.OffsetToQDFWRCDI;
 
       //---------------------------------------------------------
       // Spin through record formats, ignoring any internally generated formats
       //  set pointer to record format section QDFARFTEds
       //---------------------------------------------------------
       QDFARFTEptr = QDFFINFOptr + QDFFINFOds.LengthFileHeader;
 1b    for bb = 1 to QDFFBASEds.NumRecFmts;
 2b       if %subst(QDFARFTEds.RcdFmtName:1 :1) <> '*';
 3b          if bb > 1;  // Next record format
                exsr srPrintLine;
 3e          endif;
 
             LayOut = *blanks;
             %subst(LayOut:1:80) = *all'-';
             %subst(LayOut:1:13) =
             '-R-' + %xlate(' ':'-':QDFARFTEds.RcdFmtName);
             write PrtLine;
             LayOut = *blanks;
 
             //---------------------------------------------------------
             // Get Fields for Record Format
             //  The trick is to keep track of all different pointers while spinning through
             //  multiple arrays.
             // set pointer to record header section QDFFRINF to get number of fields
             //---------------------------------------------------------
             QDFFRINFptr = QDFFINFOptr + QDFARFTEds.OffsetToQDFFRINF;
 
             // set pointer to Field Indexing Table
             QDFFFITBptr = QDFFRINFptr + QDFFRINFds.OffsetToQDFFFITB;
 
             // set pointer to Field Header QDFFFINF
             // set pointer to named field and constant headers
             QDFFFINFptr = QDFFRINFptr + QDFFFITBds.OffsetToQDFFFINF;
             QDFFFNAMptr = QDFFFINFptr + 6;
             QDFFFCONptr = QDFFFINFptr + 6;
 
             // set pointer to Record Level Device Dependent Section QDFFRDPD
             QDFFRDPDptr = QDFFRINFptr + QDFFRINFds.OffsetToQDFFRDPD;
 
             // set pointer to Row Column Table QDFFRCTB
             QDFFRCTBptr = QDFFRINFptr + QDFFRDPDds.OffsetToQDFFRCTB;
 
             // set offset to Where Used Field Information
             QDFWFLDIptr = QDFWRCDIptr + QDFWRCDIds.OffsetToQDFWFLDI;
 
 3b          for cc = 1 to QDFFRINFds.NumFields;
                FieldNam = *blanks;
 4b             if QDFFFINFds.FieldAttribute = x'06' // hidden
                   or QDFFFINFds.FieldAttribute = x'07';  // program communication
 4x             else;
                   row = f_CvtHexToInt(%subst(QDFFRCTBds.QDFFRCTEds(cc):1:1));
                   col = f_CvtHexToInt(%subst(QDFFRCTBds.QDFFRCTEds(cc):2:1));
                   col += 1;
                   // goofy API
 5b                if col > MaxCol;
                      col -= MaxCol;
                      row += 1;
 5e                endif;
 
                   //---------------------------------------------------------
                   // If Row number changes, print current buffers and start
                   // loading buffers for next row
                   //---------------------------------------------------------
 5b                if cc = 1;
                      PrintRow = row;
 5e                endif;
 5b                if PrintRow <> row;
                      exsr srPrintLine;
                      PrintRow = row;
 5e                endif;
 
                   //---------------------------------------------------------
                   // CONSTANTS
 5b                if QDFFFINFds.FieldAttribute = x'01';
                      FieldNam = *blanks;
 6b                   if %bitand(bit0: QDFFFINFds.DateTimeBits) = bit0
                         or %bitand(bit1: QDFFFINFds.DateTimeBits) = bit1;
                         FieldNam = 'DATE';
                         pConst = 'DD/DD/DD';
 
 6x                   elseif %bitand(bit2: QDFFFINFds.DateTimeBits) = bit2;
                         FieldNam = 'TIME';
                         pConst = 'TT:TT:TT';
 
 6x                   elseif %bitand(bit4: QDFFFINFds.SystemUserBits) = bit4;
                         FieldNam = 'USER';
                         pConst = 'UUUUUUUUUU';
 
 6x                   elseif %bitand(bit5: QDFFFINFds.SystemUserBits) = bit5;
                         FieldNam = 'SYSNAME';
                         pConst = 'SSSSSSSS';
 
 6x                   else;
                         QDFFFDPDptr =
                         QDFFFINFptr + QDFFFCONds.ConstantOffsetToQDFFFDPD;
                         exsr srCategoryKeys;
 6e                   endif;
 
 6b                   if col < 133;
                         %subst(Layout:Col) = pConst;
 7b                      if FieldNam > *blanks;
                            exsr srStagger;
 7e                      endif;
 6e                   endif;
 5x                else;
 
                      //---------------------------------------------------------
                      // FIELDS
                      ProgramLen = QDFFFNAMds.ProgramLen;
                      NumberDec = f_CvtHexToInt(QDFFFNAMds.NumberDec);
 
 6b                   if QDFWFLDIds.FieldNameIndex > 0;
                         FieldNam =
                         QDFFNTBLds.FieldNameArry(QDFWFLDIds.FieldNameIndex);
                         QDFFFDPDptr =
                         QDFFFINFptr + QDFFFNAMds.NamedOffsetToQDFFFDPD;
 
                         //---------------------------------------------------------
                         // if field has edit code or edit word then it will have keywords
                         // Float numbers will only work for 14 or less length numeric, so
                         // if field is longer than 14, give it Z edit code
                         //---------------------------------------------------------
 7b                      if QDFFFNAMds.DataType = x'00'
                            or QDFFFNAMds.DataType = x'01';  // Alpha
                            FillChar = *all'X';
 7x                      else;
                            FillChar = *all'9';
 8b                         if QDFFFDPDds.OffsetToQDFFCOSA > 0
                               and ProgramLen < 15;
                               IsEdit = *off;
                               exsr srCategoryKeys;
 9b                            if IsEdit;
                                  FillChar = ReceiverVar;
 9e                            endif;
 8e                         endif;
 7e                      endif;
 
 7b                      if col < 133;
                            %subst(Layout:Col) =
                            %subst(FillChar:1:QDFFFITBds.DisplayLength);
 8b                         if FieldNam > *blanks;
                               exsr srStagger;
 8e                         endif;
 7e                      endif;
 6e                   endif;
 5e                endif;
 4e             endif;
 
 4b             if cc < QDFFRINFds.NumFields;
                   QDFWFLDIptr += QDFWFLDIds.FieldLengthWhereUsed;
                   QDFFFITBptr += %len(QDFFFITBds);  // next Field Index Table
                   QDFFFINFptr = QDFFRINFptr + QDFFFITBds.OffsetToQDFFFINF;
                   QDFFFNAMptr = QDFFFINFptr + 6;
                   QDFFFCONptr = QDFFFINFptr + 6;
 4e             endif;
 3e          endfor;
 
             // set offset to next Where Used Record Information
             QDFWRCDIptr += QDFWRCDIds.RecordLengthWhereUsed;
 2e       endif;
          QDFARFTEptr += %len(QDFARFTEds);
 1e    endfor;
       exsr srPrintLine;
 
       %subst(LayOut:1:132) = *all'-';
       write PrtLine;
 
       dealloc(n) QDFFBASEptr;
       close JCRANZDP;
       f_DltOvr('JCRANZDP');
       f_DisplayLastSplf('JCRANZDR': p_Output);
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       // Print display line and field names
       begsr srPrintLine;
 
       write PrtLine;
 
 1b    for rr = 1 to 6;
 2b       if FldNameRowArry(rr) > *blanks;
             LayOut = FldNameRowArry(rr);
             write PrtLine;
 2e       endif;
 1e    endfor;
 
       Layout = *blanks;
       FldNameRowArry(*) = *blanks;
       endsr;
 
       //---------------------------------------------------------
       // Stagger field names if short length fields
       // 9   99  666
       // Fieldname1
       //     Fieldname2
       //         Fieldname3
       //---------------------------------------------------------
       begsr srStagger;
       NameSpace = col; // no contiguous names Field1Field2
 1b    if col = 1;
          NameSpace = 2;
 1e    endif;
 1b    for rr = 1 to 6;
 2b       if %subst(FldNameRowArry(rr): NameSpace - 1: 1) = *blanks;
             %subst(FldNameRowArry(rr): col) = FieldNam;
 1v          leave;
 2e       endif;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       begsr srCategoryKeys;
 1b    if QDFFFDPDds.OffsetToQDFFCOSA > 0; // has keywords
          // Get Keyword Category Displacement String (QDFFCOSA)
          QDFFCOSAptr = QDFFFINFptr + QDFFFDPDds.OffsetToQDFFCOSA;
          QDFFCCOAptr = QDFFCOSAptr + 2;
 2b       for zz = 1 to QDFFCOSAds.NumberEntries;
 
             // Get editing for field
 3b          if QDFFCCOAds.Category = x'24';
                IsEdit = *on;
                QDFKEDTRptr =
                QDFFFINFptr + QDFFCCOAds.OffsetToCategory;
                QDFKEDTPptr = QDFKEDTRptr + 2;
                ZeroSuppress = QDFKEDTPds.ZeroSuppress;
                EditMaskLen = QDFKEDTPds.LenEditMask;
                EditMask = %subst(QDFKEDTPds.EditMask:1:EditMaskLen);
 
                //---------------------------------------------------------
                // Get field description into decimal value to apply  editing mask.
                // Way cool 'virtual decimal' number created by
                // Alpha to Float C++ function combined with Float to Packed C++ function.
                //---------------------------------------------------------
                ReceiverVar = *blanks;
                ReceiverVarLen = %len(ReceiverVar);
 
                Alpha63 = *blanks;
 4b             for aa = 1 to (ProgramLen - NumberDec);
                   %subst(Alpha63: aa: 1) = '9';
 4e             endfor;
 
 4b             if NumberDec > 0;
                   %subst(Alpha63: aa: 1) = '.';
 5b                for dd = 1 to NumberDec;
                      aa += 1;
                      %subst(Alpha63: aa: 1) = '9';
 5e                endfor;
 4e             endif;
 
                qxxdtop(%addr(CharParm):
                ProgramLen:
                NumberDec:
                -atof(Alpha63));
 
                callp QECEDT(
                      ReceiverVar:
                      ReceiverVarLen:
                      CharParm:
                      '*PACKED':
                      ProgramLen:
                      EditMask:
                      EditMaskLen:
                      ZeroSuppress:
                      ApiErrDS);
 2v             leave;
 
                //---------------------------------------------------------
                // If constant has attributes (RI, PC , colors or stuff),
                // then spin through Keyword Category Displacement String
                // until category 23 is found.
                //---------------------------------------------------------
 3x          elseif QDFFCCOAds.Category = x'23'; // constant
                QDFKDFTptr =
                QDFFFINFptr + QDFFCCOAds.OffsetToCategory;
                QDFKDFPMptr = QDFKDFTptr + 2;
 4b             for zz = 1 to QDFKDFTds.NumberOfKeys;
                   pConst =
                   %subst(QDFKDFPMds.MscgonData:1:
                   QDFKDFPMds.LengthOfData);
                   QDFKDFPMptr += QDFKDFPMds.LengthOfData;
 4e             endfor;
 2v             leave;
 3e          endif;
             QDFFCCOAptr += %len(QDFFCCOAds);
 2e       endfor;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Convert hex to character, then character to integer.
       //---------------------------------------------------------
       dcl-proc f_CvtHexToInt;
        dcl-pi *n uns(3);
         p_Character char(1) const;
        end-pi;
 
        dcl-s HexVal char(1);
        dcl-s Alpha2 char(2);
        dcl-s Integer uns(3);
 
       // Convert Character to Hex
        dcl-pr cvtch extproc(*dclcase);
         *n pointer value; // receiver pointer
         *n pointer value; // source pointer
         *n int(10) value; // receiver length
        end-pr;
 
        HexVal = p_Character;
 1b     if HexVal = x'FF';  // no location
           return 0;
 1e     endif;
 
        cvthc(%addr(Alpha2): %addr(HexVal): 2);
        cvtch(%addr(Integer): %addr(Alpha2): %size(Integer) * 2);
        return Integer;
       end-proc;
