       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRANZPR - PRTF Field Layout Print
       //  read dds extended source code listing.
       //   extract source information from spooled file.
       //    load output arrays with positional field data and field names.
       //
       // Shares common print file with jcranzdr.
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define Constants
       /define f_RtvMsgApi
       /define FieldsAttrDS
       /define Qeccvtec
       /define Qecedt
       /define f_GetDayName
       /define f_BuildString
       /define f_BuildEditWord
       /define f_OvrPrtf
       /define f_DltOvr
       /define f_DisplayLastSplf
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f DDSLIST disk(132) extfile('QTEMP/DDSLIST');
       dcl-ds inputDS len(132);
        aAsterisk char(1) pos(2);
        aSeqno char(6) pos(2);
        aNameType char(1) pos(26);
        sRcdFmtName char(12) pos(26);
        aFldName char(10) pos(28);
        aFldLen char(3) pos(41);
        aFldType char(1) pos(44);
        aDecimalPos char(2) pos(45);
        aLineNumb char(3) pos(48);
        aStartPos char(3) pos(51);
        aConstant char(36) pos(54);
        aMinusSgn char(1) pos(89);
        aEndOfSrc char(8) pos(30);
        aHeading char(8) pos(42);
        aExpanded char(8) pos(43);
        aCompNumb char(1) pos(95);
       end-ds;
 
       dcl-f JCRANZDP printer oflind(IsOverFlow) usropn;
 
       //---------------------------------------------------------
       dcl-s AllNines char(30) inz(*all'9');
       dcl-s AllZeros char(30) inz(*all'0');
       dcl-s MsgconArry char(1) dim(288) based(blocptr);
       dcl-s BlocDta char(288);
       dcl-s Ctl_BlkTyp char(19) inz('Record Format Block');
       dcl-s DecimalPart char(9);
       dcl-s EditMask char(256);
       dcl-s FieldName char(10);
       dcl-s FirstField char(3) inz('YES');
       dcl-s FirstRecFm char(23) inz('YES');
       dcl-s FlushBuffr char(3) inz('NO');
       dcl-s StaggerNam char(198) dim(15);
       dcl-s StaggerDepth uns(3);  // prevent name overlap
       dcl-s IPPfield char(12);
       dcl-s LoadNamFlg char(14) inz('Load Name Flag');
       dcl-s O_EditCode char(1);
       dcl-s PrvLineNum char(3);
       dcl-s ReceiverVar char(256);
       dcl-s WholePart char(21);
       dcl-s MapStartPos char(3);
       dcl-s EditMaskLen int(10);
       dcl-s ReceiverVarLen int(10);
       dcl-s WholeLength int(5);
       dcl-s xb int(5);
       dcl-s xd int(5);
       dcl-s EndPosX int(5);
       dcl-s xf int(5);
       dcl-s xg int(10);
       dcl-s xh int(5);
       dcl-s DecimalPos packed(1);
       dcl-s v30_9Dec packed(30: 9);
       dcl-s aFldLenNUM zoned(3) based(aptr);
       dcl-s ForCount uns(5);
       dcl-s aPtr pointer inz(%addr(afldlen));
       dcl-s BlocPtr pointer inz(%addr(blocdta));
       dcl-s IsExpanded ind;
       dcl-s IsFloatDollar ind;
       dcl-s savspace char(288);
 
       dcl-ds v30_9DS qualified;
        v30_9Zoned zoned(30: 9) inz(0);
       end-ds;
 
       dcl-ds EditedDS qualified;
        EditedArry char(1) dim(40) inz;
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_Mbr char(10);
        p_File char(10);
        p_Lib char(10);
        p_Text char(50);
        p_ShowNames char(4);
        p_Output char(8);
       end-pi;
       //---------------------------------------------------------
 
       f_OvrPrtf('JCRANZDP': '*JOB': p_Mbr);
       open JCRANZDP;
 
       // Print headings.  Load print position 'rulers'
       scDow = f_GetDayName();
 
       scObjHead =
       f_BuildString('&         Mbr: &   &   &   &':
       'JCRANZPR': p_Mbr: p_File: p_Lib: p_Text);
 
       write PrtHead;
       IsOverFlow = *off;
 
       // load output positions ruler
 1b    for xb = 1 to 19;
          %subst(LayOut:xb*10:1) = %subst(%editc(xb: '3'): 5: 1);
 1e    endfor;
       write PrtLine;
 
       LayOut = *all'1234567890';
       write PrtLine;
       LayOut = *all'-';
       write PrtLine;
 
       //---------------------------------------------------------
       read ddslist inputDS;
 1b    dow not %eof;
 2b       if aExpanded = 'Expanded';
             IsExpanded = *on;
 2e       endif;
 
 2b       if IsExpanded
             and aHeading <> 'Data Des'
             and aSeqno > '     0'
             and aSeqno < '999900'
             and aSeqno <> 'SEQNBR'
             and aAsterisk <> '*';
 
             //---------------------------------------------------------
             // 'R' or aCompNumb determine either new record format or new
             // field has started.
             // 'R'  print of previous block and start of new block
             //---------------------------------------------------------
 3b          if aNameType = 'R';
                Ctl_BlkTyp = ('Record Format Block');
                FirstField = 'YES';
 
 4b             if FirstRecFm = 'Not first record format';
                   FlushBuffr = 'YES';
 5b                if FieldName > *blanks or BlocDta > *blanks;
                      exsr srChkPrevBlk;  //Flush existing buffer
 5e                endif;
                   FlushBuffr = 'NO';
 4e             endif;
 
                //---------------------------------------------------------
                // print this record format name
                //---------------------------------------------------------
                LayOut = *blanks;
 4b             if p_ShowNames = '*YES';
                   LayOut = *all'_';
                   %subst(LayOut:2:12) = %xlate(' ':'_':sRcdFmtName);
 4e             endif;
                write PrtLine;
                LayOut = *blanks;
                FirstRecFm = 'Not first record format';
 
                //---------------------------------------------------------
                // Printable field or constant is detected if there
                // is value in aCompNumb.  It 1) signals all records have
                // been read for previous field and must be processed.
                // 2) load field data for current field.
                //---------------------------------------------------------
 3x          elseif aCompNumb > *blanks;
 4b             if FirstField = 'NO';
                   exsr srChkPrevBlk;
 4e             endif;
 
                FirstField = 'NO';
                Ctl_BlkTyp = 'Field Data Block'; //reset
                exsr srLoadFieldData;
 4b             if aMinusSgn = '-';
                   %subst(aConstant: 36: 1) = ' ';  //remove continuation sign
 4e             endif;
                BlocDta = aConstant;
 3x          else;
                //---------------------------------------------------------
                // load constant data between fields.
                // Multiple records can be applicable to one field.
                //---------------------------------------------------------
 4b             if Ctl_BlkTyp = 'Field Data Block';
 5b                if aMinusSgn = '-';
                      %subst(aConstant: 36: 1) = ' ';
 5e                endif;
 
 5b                if FieldName > *blanks
                      or BlocDta = 'PAGNBR'
                      or BlocDta = 'DATE'
                      or BlocDta = 'DATE(*SYS)'
                      or BlocDta = 'DATE(*JOB)'
                      or BlocDta = 'DATE(*YY)'
                      or BlocDta = 'DATE(*Y)'
                      or BlocDta = 'DATE(*SYS)'
                      or BlocDta = 'TIME';
                      BlocDta = %trimr(BlocDta) + ' ' + aConstant;
 5x                else;
                      BlocDta = %trimr(BlocDta) + aConstant;
 5e                endif;
 4e             endif;
 3e          endif;
 2e       endif;
          read ddslist inputDS;
 
          //---------------------------------------------------------
          // 'E N D' signifies end of listing.  Print last line
          //---------------------------------------------------------
 2b       if aEndOfSrc = 'E N D   ';
             FlushBuffr = 'YES';
             exsr srChkPrevBlk;
 1v          leave;
 2e       endif;
 1e    enddo;
 
       close JCRANZDP;
       f_DltOvr('JCRANZDP');
       f_DisplayLastSplf('JCRANZPR': p_Output);
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       // Determine if LINE SPACING event is about to occur.
       // If No SpaceB or SkipB, then load
       // field into current field line. If there is
       // Space/Skip before, print current
       // line, reset all values.  Start with this field on new line.
       //---------------------------------------------------------
       begsr srChkPrevBlk;
 1b    if %scan('SPACEB(': BlocDta) > 0
          or %scan('SKIPB(': BlocDta)  > 0;
          write PrtLine;  //print data for previous line
 
 2b       if p_ShowNames = '*YES';
 3b          for cc = 1 to StaggerDepth;
                LayOut = StaggerNam(cc);
                write PrtLine;
 3e          endfor;
 2e       endif;
 
          Layout = *blanks;
          StaggerDepth = 0;
          StaggerNam(*) = *blanks;
          EndPosX = 0;
 1e    endif;
 
       // Determine what type of field.
       IPPfield = *blanks;
       O_EditCode = *blanks;
       xb = 0;
 
       // check for reserved word
 1b    if FieldName = *blanks;
          f_DDsReservedWords(
          BlocDta:
          FieldName:
          FieldsAttrDS.Length:
          FieldsAttrDS.DecimalPos:
          FieldsAttrDS.DataType);
 1e    endif;
 
 1b    if FieldName = *blanks;
          IPPfield = 'Constant';
          xb = %scan(qs: BlocDta);
          xb += 1;
 1x    elseif FieldsAttrDS.DataType = 'A';
          IPPfield = 'Alpha Field';
 1x    else;
 
          //---------------------------------------------------------
          // Extract either starting position to edit word/edit code.
          // Handle date,time,stamp type data be building an
          // edit word based on type field and type formatting.
 
          // Then watch out for 'DATFMT(*ISO) SPACEA(2)  '
          // and be careful to not overlay the
          // spacing keyword when building the edit word.
          //---------------------------------------------------------
 2b       if FieldsAttrDS.DataType = 'L'
             or FieldsAttrDS.DataType = 'T'
             or FieldsAttrDS.DataType = 'Z';
 
             savspace = *blanks;
             xb = %scan('SPACEA(': BlocDta);
 3b          if xb = 0;
                xb = %scan('SKIPB(': BlocDta);
 3e          endif;
 3b          if xb = 0;
                xb = %scan('SPACEB(': BlocDta);
 3e          endif;
 3b          if xb = 0;
                xb = %scan('SKIPA(': BlocDta);
 3e          endif;
 3b          if xb > 0;
                savspace = %subst(BlocDta:xb);
                %subst(BlocDta:xb) = *blanks;
 3e          endif;
 
             blocdta = 'EDTWRD(' +
             (f_BuildEditWord(%subst(blocdta:1:28):
             FieldsAttrDS.DataType)) +')';
 
 3b          if savspace > *blanks;
                blocdta = %trimr(blocdta) + ' ' + %triml(savspace);
 3e          endif;
 2e       endif;
 
          xb = %scan('EDTWRD(': BlocDta);
 2b       if xb > 0;
             IPPfield = 'Num EditWord';
             xb = 9;
 2x       else;
             //---------------------------------------------------------
             // extract edit code. Check for floating dollar sign
             //---------------------------------------------------------
             O_EditCode = *blanks;
             IsFloatDollar = *off;
 
             xb = %scan('EDTCDE(': BlocDta);
 3b          if xb > 0;
                O_EditCode = %subst(BlocDta: xb + 7: 1);
 
                xb = %scan('$': BlocDta: xb + 8);
 4b             if xb > 0;
                   IsFloatDollar = *on;
 4e             endif;
 3e          endif;
             IPPfield = 'Num EditCode';
 2e       endif;
 1e    endif;
 
       //---------------------------------------------------------
       // load data into print array
       exsr srFieldLoad;
 
       //---------------------------------------------------------
       // If there is space after, print, then reset all values
       // Or if current Line number does not equal previous line number.
       //---------------------------------------------------------
 1b    if FlushBuffr = 'YES'
          or FlushBuffr = 'NO'
          AND
          (PrvLineNum <> aLineNumb
          or %scan('SPACEA(': BlocDta) > 0
          or %scan('SKIPA(': BlocDta) > 0);
          write PrtLine;
 2b       if p_ShowNames = '*YES';
 3b          for cc = 1 to StaggerDepth;
                LayOut = StaggerNam(cc);
                write PrtLine;
 3e          endfor;
 2e       endif;
 
          Layout = *blanks;
          StaggerDepth = 0;
          StaggerNam(*) = *blanks;
          EndPosX = 0;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // load field name data
       begsr srLoadFieldData;
       clear FieldsAttrDS;
       FieldName = *blanks;
       DecimalPos = 0;
 
 1b    if aFldName > *blanks;
          FieldName = aFldName;
          FieldsAttrDS.Length = aFldLenNum;
          FieldsAttrDS.DecimalPos = aDecimalPos;
          FieldsAttrDS.DataType = aFldType;
 2b       if FieldsAttrDS.DecimalPos = *blanks;
             DecimalPos = 0;
 2x       else;
             DecimalPos = FieldsAttrDS.DecimalPosN;
 2e       endif;
 1e    endif;
       MapStartPos = aStartPos;
       PrvLineNum = aLineNumb;
       endsr;
 
       //---------------------------------------------------------
       // load data into print array
       begsr srFieldLoad;
 1b    if MapStartPos = *blanks;
          EndPosX = 0;
 1x    else;
          EndPosX = %uns(MapStartPos);
 1e    endif;
       EndPosX -= 1;
 1b    if EndPosX < 199;
 2b       if IPPfield = 'Constant';
             exsr srDoConstLeft;
 2x       elseif IPPfield = 'Alpha Field';
             exsr srDoAlphaLeft;
 2x       elseif IPPfield = 'Num EditWord';
             exsr srDoConstLeft;
 2x       elseif IPPfield = 'Num EditCode';
             exsr srDoEditCodeLeft;
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // EditedDS field is end result of API edit mask apply.
       //  Blanks and zeros are  filtered out.   Also, filter
       //  decimal point '.' from zero decimal numbers.
       //---------------------------------------------------------
       begsr srDoEditCodeLeft;
 
       //---------------------------------------------------------
       // Fill whole number part of number.
       // Number of decimals is subtracted from field length to get number
       // of digits in whole number.  Zeros and nines are loaded into field.
       // End result for 9,2 field is 000000000000009999999
       // Y editcodes are always 99/99/99
       //---------------------------------------------------------
 1b    if O_EditCode = 'Y';
          EditedDS = ' 99/99/99';
 2b       if FieldsAttrDS.Length = 8;
             EditedDS = ' 99/99/9999';
 2e       endif;
 1x    else;
          WholeLength = FieldsAttrDS.Length - DecimalPos;
          WholePart =
          %subst(AllZeros: 1: (%size(WholePart) - WholeLength)) +
          %subst(AllNines: 1: WholeLength);
 
          //---------------------------------------------------------
          // Number of decimal places loads up left side
          // of field with 9's and fill out remainder with zeros.
          // End result for 9,2 field is 990000000
          //---------------------------------------------------------
 2b       if DecimalPos = 0;
             DecimalPart = *all'0';
 2x       else;
             DecimalPart = %subst(AllNines: 1: DecimalPos) +
             %subst(AllZeros: DecimalPos + 1:
             %size(DecimalPart) - DecimalPos);
 2e       endif;
 
          //---------------------------------------------------------
          // Make negative numeric so edit code application
          // can generate max size.
          //---------------------------------------------------------
          v30_9DS = WholePart + DecimalPart;
          v30_9Dec = -(v30_9DS.V30_9Zoned);  //make packed negative
 
 2b       if O_EditCode = ' ';  //Use 'Z' so mapper will work
             O_EditCode = 'Z';
 2e       endif;
 
          // Create edit mask required to apply edit code
          callp QECCVTEC(
                ReceiverVar:
                EditMaskLen:
                ReceiverVarLen:
                ' ':
                O_EditCode:
                ' ':
                30:
                9:
                ApiErrDS);
          EditMask = ReceiverVar;
 
          //---------------------------------------------------------
          // Apply edit mask generated by edit code
          // If using leading 0 suppress in front of
          // constant, then must make field length parm 1
          // bigger than actual value of field.
          //---------------------------------------------------------
          ReceiverVar = *blanks;
          callp QECEDT(
                ReceiverVar:
                ReceiverVarLen:
                v30_9Dec:
                '*PACKED':
                30:
                EditMask:
                EditMaskLen:
                ' ':
                ApiErrDS);
 
          //---------------------------------------------------------
          // If API cannot apply user defined edit codes, it returns blank.
          //  Load length of field so it will show on report.
          //---------------------------------------------------------
 2b       if ReceiverVar = *blanks;
             ReceiverVar = %subst(AllNines: 2: FieldsAttrDS.Length);
 2e       endif;
          EditedDS = ReceiverVar;  //load edited field
 
          // Load if field has floating $ sign
 2b       if IsFloatDollar;
             xb = %scan('9': EditedDS: 1);
 3b          if xb > 1;
                xb -= 1;
                %subst(EditedDS: xb: 1) = '$';
 3e          endif;
 2e       endif;
 1e    endif;
       LoadNamFlg = 'Start FldNam';
 
 1b    for xg = 1 to 40;
 2b       if (EditedDS.EditedArry(xg) > ' '
             and EditedDS.EditedArry(xg) <> '0');
 
 3b          if (DecimalPos = 0
                and EditedDS.EditedArry(xg) = '.');
 3x          else;
                EndPosX += 1;
 4b             if EndPosX > 198;
                   EndPosX = 198;
 4e             endif;
 
 4b             if LoadNamFlg = 'Start FldNam';
                   exsr srLoadFieldName;
 4e             endif;
 4b             if EndPosX > 0 and EndPosX < 199;
                   %subst(Layout: EndPosx:1) = EditedDS.EditedArry(xg);
 4e             endif;
 3e          endif;
 2e       endif;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // Process numeric fields with edit words or constants.
       // The only difference is edit words replace ' '  with '9'.
       //---------------------------------------------------------
       begsr srDoConstLeft;
       LoadNamFlg = 'Start FldNam';
 
       //---------------------------------------------------------
       // Add support for MSGCON keyword. BLOCDTA could contain
       // MSGCON(len msgid msgf). If it does, call function to
       // extract message from msgf and load into MsgconArry.
       //---------------------------------------------------------
 1b    if %subst(BlocDta: 1: 6) = 'MSGCON';
          BlocDta = f_MSGCON(BlocDta);
          xb = 1;
 1e    endif;
 1b    for xg = xb to 198;
 2b       if MsgconArry(xg) = qs;  //end of edit word
 1v          leave;
 2e       endif;
 
          EndPosX += 1;
 2b       if EndPosX > 198;
             EndPosX = 198;
 2e       endif;
 
 2b       if LoadNamFlg = 'Start FldNam';
             exsr srLoadFieldName;
 2e       endif;
 
 2b       if MsgconArry(xg) = ' '
             and IPPfield = 'Num EditWord';
 3b          if FieldsAttrDS.DataType = 'L';
                %subst(Layout: EndPosx:1) = 'D';
 3x          elseif FieldsAttrDS.DataType = 'Z';
                %subst(Layout: EndPosx:1) = 'Z';
 3x          elseif FieldsAttrDS.DataType = 'T';
                %subst(Layout: EndPosx:1) = 'T';
 3x          else;
                %subst(Layout: EndPosx:1) = '9';  //load edited field
 3e          endif;
 2x       else;
             %subst(Layout: EndPosx:1) = MsgconArry(xg);
 2e       endif;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // Process alpha fields with no end positions or + positioning
       begsr srDoAlphaLeft;
       xh = EndPosX - 1;
 1b    if xh <= 0;
          xh = 1;
 1e    endif;
 
       xf = EndPosX + 1;
       exsr srStagger;
 
       // Load 'X's to positionally represent alpha field
 1b    for ForCount = 1 to FieldsAttrDS.Length;
          EndPosX += 1;
 2b       if EndPosX < 1 or EndPosX > 198;
 1v          leave;
 2e       endif;
          %subst(Layout: EndPosx:1) = 'X';
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // Load field names under data representations
       begsr srLoadFieldName;
       xh = EndPosX - 1;
 1b    if xh <= 0;
          xh = 1;
 1e    endif;
       xf = EndPosX;
       exsr srStagger;
       LoadNamFlg = *blanks;
       endsr;
 
       //---------------------------------------------------------
       // Formatted2 & Formatted3 business is to stagger field
       // field names if short length fields.
       // 9   99
       // Fieldname 1
       // Fieldname 2
       // Be careful of fields names that extend past 132.
       // example:  Field a123456789 is in position 131, there is not
       // enough room to load entire field name.
       //---------------------------------------------------------
       begsr srStagger;
       xd = %len(%trimr(FieldName));
 1b    if xf <= 0;
          xf = 1;
 1e    endif;
 
 1b    if 198 - (xf - 1) < xd;
          xd = 198 - (xf - 1);
 1e    endif;
 
 1b    for cc = 1 to 10;
 2b       if %subst(StaggerNam(cc): xh: xd + 1) = *blanks;
 3b          if xf <= 198;
                %subst(StaggerNam(cc): xf: xd) = FieldName;
 3e          endif;
 3b          if cc > StaggerDepth;
                StaggerDepth = cc;
 3e          endif;
 1v          leave;
 2e       endif;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // Changes parms to match attribute of DDS reserved field names
       //---------------------------------------------------------
       dcl-proc f_DDsReservedWords;
        dcl-pi *n;
         BlocDta char(288);
         FieldName char(10);
         MapFldLength uns(10);
         MapDecPos char(2);
         MapDtaTyp char(1);
        end-pi;
 
        dcl-s QuotePos1 uns(5);
        dcl-s QuotePos2 uns(5);
        dcl-s xg int(10);
 
       //---------------------------------------------------------
       // Reserved words (PAGE DATE PAGNBR) are more difficult to extract.
 
       // Real problem is when words are part of constant.
       // ('Work DATE')
       // Check if either reserved word is in first position or not between two '  '.
       //---------------------------------------------------------
 1b     if %subst(BlocDta: 1: 7) = 'PAGNBR';
           FieldName = 'PAGNBR';
           MapFldLength = 4;
           MapDecPos = '00';
           MapDtaTyp = 'S';
           exsr srMoveEditWord;
 1x     elseif %subst(BlocDta: 1: 5) = 'USER';
           FieldName = 'USER';
           MapFldLength = 10;
           MapDecPos = '00';
           MapDtaTyp = 'S';
 1x     elseif %subst(BlocDta: 1: 8) = 'SYSNAME';
           FieldName = 'SYSNAME';
           MapFldLength = 8;
           MapDecPos = '00';
           MapDtaTyp = 'S';
 1x     elseif %subst(BlocDta: 1: 5) = 'DATE'
           or %subst(BlocDta: 1: 10) = 'DATE(*SYS)'
           or %subst(BlocDta: 1: 10) = 'DATE(*JOB)'
           or %subst(BlocDta: 1: 8) = 'DATE(*Y)';
           FieldName = 'DATE';
           MapFldLength = 6;
           MapDecPos = '00';
           MapDtaTyp = 'P';
           exsr srMoveEditWord;
 1x     elseif %subst(BlocDta: 1: 9) = 'DATE(*YY)';
           FieldName = 'DATE';
           MapFldLength = 8;
           MapDecPos = '00';
           MapDtaTyp = 'P';
           exsr srMoveEditWord;
 1x     elseif %subst(BlocDta: 1: 5) = 'TIME';
           FieldName = 'TIME';
           MapFldLength = 6;
           MapDecPos = '00';
           MapDtaTyp = 'P';
           exsr srMoveEditWord;
 1x     else;
          //---------------------------------------------------------
          // Find position of Quotes (if any)
           QuotePos2 = 0;
           QuotePos1 = %scan(qs: BlocDta);
 2b        if QuotePos1 > 0;
              QuotePos2 = %scan(qs: BlocDta: QuotePos1 + 1);
 2e        endif;
 
           xg = %scan(' PAGNBR ': BlocDta);
 2b        if xg > 0;
 3b           if (QuotePos1 = 0
                 and QuotePos2 = 0)
                 OR
                 (xg < QuotePos1
                 or xg > QuotePos2);
                 FieldName = 'PAGNBR';
                 MapFldLength = 4;
                 MapDecPos = '00';
                 MapDtaTyp = 'S';
 3e           endif;
 2e        endif;
 
           xg = %scan(' TIME ': BlocDta);
 2b        if xg > 0;
 3b           if (QuotePos1 = 0
                 and QuotePos2 = 0)
                 OR
                 (xg < QuotePos1
                 or xg > QuotePos2);
                 FieldName = 'TIME';
                 MapFldLength = 6;
                 MapDecPos = '00';
                 MapDtaTyp = 'P';
 3e           endif;
 2e        endif;
 
           xg = %scan(' DATE ': BlocDta);
 2b        if xg > 0;
 3b           if (QuotePos1 = 0
                 and QuotePos2 = 0)
                 OR
                 (xg < QuotePos1
                 or xg > QuotePos2);
                 FieldName = 'DATE';
                 MapFldLength = 6;
                 MapDecPos = '00';
                 MapDtaTyp = 'P';
 3e           endif;
 2e        endif;
 1e     endif;
        return;
 
       //---------------------------------------------------------
        begsr srMoveEditWord;
        xg = %scan(' ': BlocDta: 5);
 1b     if xg > 0;
           BlocDta = %subst(BlocDta: xg + 1);
 1e     endif;
        endsr;
 
       end-proc;
 
       //---------------------------------------------------------
       // Returns text from dds MSGCON keyword
       dcl-proc f_MsgCon;
        dcl-pi *n char(288);
         p_BlockOfData char(288);
        end-pi;
 
       // variables for processing MSGCON keywords
        dcl-s mWork like(p_blockofdata);
        dcl-s xx int(10);  // numeric work field
        dcl-s yy int(10);  // numeric work field
        dcl-s Msgid char(7);
        dcl-s MsgFile char(10);
        dcl-s MsgLib char(10);
        dcl-s replacement char(112);
 
        dcl-ds MsgLengthDS qualified;
         MsgLength zoned(7) inz(0);
        end-ds;
 
       //---------------------------------------------------------
       // p_BlockOfData could contain MSGCON(len msgid msgf)
       // Assume all msgcon data will be on one line.
 
       // get Length.  skip MSGCON( section and compress out spaces
       // placed after ( and before number starts.
       // Extract value and right justify it into MsgLengthDS.
       //---------------------------------------------------------
        mWork = %triml(%subst(p_BlockOfData: 8));  //left justify
        xx = %scan(' ': mWork: 1);  //find 1st blank
        %subst(MsgLengthDS: 7-(xx - 2): xx - 1) =
        %subst(mWork: 1: xx - 1);
 1b     if MsgLengthDS = *blanks;
           MsgLengthDS.MsgLength = 0;
 1e     endif;
 
 1b     if MsgLengthDS.MsgLength > 130;  //force validity
           MsgLengthDS.MsgLength = 130;
 1e     endif;
 
       //---------------------------------------------------------
       // get MSGID. Use where LEN ends as starting place to extract MSGID.
       // This will fairly easy as ID is 7 long.
       //---------------------------------------------------------
        mWork = %triml(%subst(mWork: xx));
        Msgid = %subst(mWork: 1: 7);
 
       //---------------------------------------------------------
       // get MSGF.  Msgf could be qualified LIB/MSGF or not.
       // Start where MSGID ends and compress over to MSGF value.
       //
       // Determine where string ends.  It could be either
       // MSGF) and it would end at ) or
       // MSGF  ) and it would end at first ' '.
       // yy (end string) is set to where MSGF actually ends.
       //---------------------------------------------------------
        mWork = %triml(%subst(mWork: 8));  //start at msgf
 
        yy = %scan(')': mWork);  //find  closing )
        xx = %scan(' ': (%subst(mWork: 1: yy)));  //find  last ' '
 1b     if xx <> 0;  //did not find one
 2b        if xx < yy;  //find lowest
              yy = xx;
 2e        endif;
 1e     endif;
        yy -= 1;  //last pos of string
 
       //---------------------------------------------------------
       // Is string qualified (lib/File) name or just msgf name.
       //---------------------------------------------------------
        xx = %scan('/': mWork);  //qualified?
 1b     if xx = 0;  //is not qualified
           MsgFile = %subst(mWork: 1: yy);
           MsgLib = '*LIBL';
 1x     else;
          // if it is qualified, extract qualified (lib/file) names.
           MsgFile = %subst(mWork: xx + 1: yy - xx);
           MsgLib = %subst(mWork: 1: xx - 1);
 1e     endif;
        return
        %trimr(f_RtvMsgApi(Msgid: Replacement: MsgFile + MsgLib)) + qs;
 
       end-proc;
