       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRANZOR - O spec layout with field names print
       //  call program to load field names & attributes into IMPORTED array
       //   read rpgle source code specs
       //    load output arrays with positional field data and field names
       // Shares common print file with jcranzdr and jcranzpr
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define FieldsArry
       /define Constants
       /define FieldsAttrDS
       /define Qeccvtec
       /define f_Qusrmbrd
       /define f_BuildString
       /define Qecedt
       /define SrcDS
       /define f_BuildEditWord
       /define f_GetQual
       /define f_SndEscapeMsg
       /define f_GetDayName
       /define f_OvrPrtf
       /define f_Dltovr
       /define f_DisplayLastSplf
       /define f_IsCompileTimeArray
       /define p_JCRGETFLDR
       // *ENTRY
       /define p_JCRANZOR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f RPGSRC disk(112) extfile(extifile) extmbr(p_srcmbr) usropn;
       dcl-f JCRANZDP printer oflind(IsOverFlow) usropn;
 
       dcl-s IsFoundOspec ind;
       dcl-s AllNines char(30) inz(*all'9');
       dcl-s AllZeros char(30) inz(*all'0');
       dcl-s DecimalPart char(9);
       dcl-s EditMask char(256);
       dcl-s FirstTime char(2) inz('XX');
       dcl-s FloatDollar char(3) inz('''$''');
       dcl-s StaggerNam char(198) dim(15);
       dcl-s IPPfield char(12);
       dcl-s LoadNamFlg char(14) inz('Load Name Flag');
       dcl-s LookupName char(15);
       dcl-s ReceiverVar char(256);
       dcl-s WholePart char(21);
       dcl-s EditMaskLen int(10);
       dcl-s ReceiverVarLen int(10);
       dcl-s xa int(5);
       dcl-s xe int(5);
       dcl-s xm int(5);
       dcl-s DecimalPos packed(1);
       dcl-s v30_9Dec packed(30: 9);
       dcl-s oEndPosN zoned(5) based(oendptr);
       dcl-s ForCount uns(5);
       dcl-s StaggerDepth uns(3);  // prevent name overlap
       dcl-s IntegerLength uns(5);
       dcl-s LastEndPos uns(5);
       dcl-s xb uns(5);
       dcl-s xd uns(3);  // )
       dcl-s xf uns(3);  // )
       dcl-s xg uns(3);  // (
       dcl-s xh uns(3);  // (
       dcl-s xi uns(5);
       dcl-s EndPosX uns(5);
       dcl-s xk uns(5);
       dcl-s xo uns(5);
       dcl-s oEndPtr pointer inz(%addr(srcds.oendpos));
       dcl-s IsContinuation ind inz(*off);
       dcl-s BuildContin varchar(200);
       dcl-s PlusSignVal char(5);
       dcl-s DimSizeVal char(5);
       dcl-s PepCnt packed(3);
 
       dcl-ds v30_9DS qualified;
        v30_9Zoned zoned(30: 9) inz(0);
       end-ds;
 
       dcl-ds EditedDS qualified;
        EditedArry char(1) dim(40) inz;
       end-ds;
 
       //---------------------------------------------------------
       // Load JCRCMDSSRV clipboard array with field names and attributes
       callp p_JCRGETFLDR(
             p_SrcFilQual:
             p_SrcMbr:
             DiagSeverity:
             PepCnt);
 
 1b    if DiagSeverity > '20';
          f_SndEscapeMsg('*ERROR*  Diagnostic severity ' +
          DiagSeverity + '. Please check listing for errors.');
 1e    endif;
 
       QusrmbrdDS = f_Qusrmbrd(p_SrcFilQual: p_SrcMbr: 'MBRD0100');
       %subst(p_SrcFilQual: 11: 10) = QusrmbrdDS.Lib;
 
       extIfile = f_GetQual(p_SrcFilQual);
       open RPGSRC;
 
       f_OvrPrtf('JCRANZDP': '*JOB': p_SrcMbr);
       open JCRANZDP;
       scDow = f_GetDayName();
 
       scObjHead =
       f_BuildString('&         Mbr: &   &   &   &':
       'JCRANZOR': QusrmbrdDS.Mbr: QusrmbrdDS.File:
       QusrmbrdDS.Lib: QusrmbrdDS.Text);
 
       write PrtHead;
       IsOverFlow = *off;
 
       // load ruler to show output positions
 1b    for xa = 1 to 19;
          %subst(LayOut:xa * 10:1) = %subst(%editc(xa: '3'): 5: 1);
 1e    endfor;
 
       write PrtLine;
       LayOut = *all'1234567890';
       write PrtLine;
       LayOut = *all'-';
       write PrtLine;
 
       //---------------------------------------------------------
       IsFoundOspec = *off;
       read RPGSRC SrcDS;
 1b    dow not %eof;
 
 2b       if f_IsCompileTimeArray(SrcDS.CompileArray)
             or SrcDS.SpecType = 'P'
             or SrcDS.SpecType = 'p';
 1v          leave;
 2e       endif;
 
          SrcDS.oAndOr = %xlate(lo: up: SrcDS.oAndOr);
 
 2b       if (SrcDS.SpecType = 'O'
             or SrcDS.SpecType = 'o')
             and
             (not(SrcDS.Asterisk = '*' or SrcDS.Asterisk = '/'))
             and
             (not(SrcDS.oAndOr = 'OR' or SrcDS.oAndOr = 'AND'));
             IsFoundOspec = *on;
 
             //---------------------------------------------------------
             // First, print field data for previous line.
             // Spaces are loaded with '_' then is loaded into printing array.
             //---------------------------------------------------------
 3b          if SrcDS.oLineType > *blanks;
 4b             if FirstTime = 'NO';
                   write prtLine;
 
 5b                if p_ShowNames = '*YES';
 6b                   for cc = 1 to StaggerDepth;
                         LayOut = StaggerNam(cc);
                         write PrtLine;
 6e                   endfor;
 5e                endif;
 
                   Layout = *blanks;
                   StaggerDepth = 0;
                   StaggerNam(*) = *blanks;
                   EndPosX = 0;
                   LastEndPos = 0;
 4e             endif;
                FirstTime = 'NO';
 
                //---------------------------------------------------------
                // Take Record Format line and replace
                // the spaces with underscores for printing asthetics
                //---------------------------------------------------------
                LayOut = *blanks;
 4b             if p_ShowNames = '*YES';
                   LayOut = *all'_';
                   %subst(Layout:2:74) = %xlate(' ':'_':SrcDS.Src80);
 4e             endif;
 
                write PrtLine;
                LayOut = *blanks;
 3x          else;
                IPPfield = *blanks;
                exsr srGetFieldAttr;
                exsr srFieldLoad;
 3e          endif;
 2e       endif;
 
          read RPGSRC SrcDS;
 1e    enddo;
 
       // all processed
 1b    if (not IsFoundOspec);
          LayOut = 'No Output Specifications found in source ********';
          StaggerDepth = 0;
 1e    endif;
       write prtLine;
 
 1b    if p_ShowNames = '*YES';
 2b       for cc = 1 to StaggerDepth;
             LayOut = StaggerNam(cc);
             write PrtLine;
 2e       endfor;
 1e    endif;
 
       close RPGSRC;
       close JCRANZDP;
       f_Dltovr('JCRANZDP');
       f_DisplayLastSplf('JCRANZOR': p_Output);
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       // Load data into print array
       begsr srFieldLoad;
 1b    if SrcDS.oEndPos = *blank;
          EndPosX = LastEndPos;
 2b       if EndPosX < 199;
 3b          if IPPfield = 'Constant';
                exsr srDoConstLeft;
 3x          elseif IPPfield = 'Alpha Field';
                exsr srDoAlphaLeft;
 3x          elseif IPPfield = 'Num EditWord';
                exsr srDoConstLeft;
 3x          elseif IPPfield = 'Num EditCode';
                exsr srDoEditCodeLeft;
 3e          endif;
 2e       endif;
 1x    else;
          //---------------------------------------------------------
          // end position = + and some value  load from left to right
          // check for - in EndPosition
          //---------------------------------------------------------
          xb = 0;
          xe = %scan('+': SrcDS.oEndPos: 1);
 2b       if xe = 0;
             xb = %scan('-': SrcDS.oEndPos: 1);
 2e       endif;
 
 2b       if xe  > 0       //plus
             or xb  > 0;  //minus
             PlusSignVal = *blanks;
 3b          if xe  > 0;  //plus
                %subst(PlusSignVal: xe + 1) = %subst(SrcDS.oEndPos: xe + 1); //drop plus sign
 3x          else;
                %subst(PlusSignVal: xb + 1) =
                %subst(SrcDS.oEndPos: xb + 1);  //drop minus sign
 3e          endif;
 
 3b          if PlusSignVal = *blanks;
                EndPosX = 0;
 3x          else;
                EndPosX = %uns(PlusSignVal);
 3e          endif;
 
 3b          if xe > 0;  //plus
                EndPosX += LastEndPos;
 3x          else;
                EndPosX = LastEndPos - EndPosX;
 3e          endif;
 
 3b          if EndPosX < 199;
 4b             if IPPfield = 'Constant';
                   exsr srDoConstLeft;
 4x             elseif IPPfield = 'Alpha Field';
                   exsr srDoAlphaLeft;
 4x             elseif IPPfield = 'Num EditWord';
                   exsr srDoConstLeft;
 4x             elseif IPPfield = 'Num EditCode';
                   exsr srDoEditCodeLeft;
 4e             endif;
 3e          endif;
 2x       else;
             //---------------------------------------------------------
             // end position is given, load from right to left
             //---------------------------------------------------------
 3b          if SrcDS.oEndPos = *blanks;
                EndPosX = 0;
 3x          else;
                EndPosX = oEndPosN;
 3e          endif;
 3b          if EndPosX < 199;
 4b             if IPPfield = 'Constant';
                   exsr srDoConstRight;
 4x             elseif IPPfield = 'Alpha Field';
                   exsr srAlphaRight;
 4x             elseif IPPfield = 'Num EditWord';
                   exsr srDoConstRight;
 4x             elseif IPPfield = 'Num EditCode';
                   exsr srDoEditCodeRight;
 4e             endif;
 3e          endif;
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // load edit coded field with no EndPos or + EndPos.
       // The EditedDS field is end result of an API edit mask apply.
       //  Blanks and zeros are filtered out.
       //   Filter decimal point '.' from zero decimal numbers.
       //---------------------------------------------------------
       begsr srDoEditCodeLeft;
       exsr srGetEditCode;
       LoadNamFlg = 'Start FldNam';
 1b    for xm = 1 to 40;
 2b       if (EditedDS.EditedArry(xm) > ' '
             and EditedDS.EditedArry(xm) <> '0');
 
 3b          if (DecimalPos = 0
                and EditedDS.EditedArry(xm) = '.');
 3x          else;
                EndPosX += 1;
 4b             if LoadNamFlg = 'Start FldNam';
                   exsr srLoadFieldName;
 4e             endif;
                %subst(Layout: EndPosx:1) = EditedDS.EditedArry(xm);
 3e          endif;
 2e       endif;
 2b       if EndPosX = 198;
 1v          leave;
 2e       endif;
 1e    endfor;
       LastEndPos = EndPosX;  //reset last end pos
       endsr;
 
       //---------------------------------------------------------
       // load edit coded field with end positions.
       //  Start at end position and work backwards.
       //---------------------------------------------------------
       begsr srDoEditCodeRight;
       exsr srGetEditCode;
       LastEndPos = EndPosX;
       EndPosX += 1;
 1b    for xa = 40 downto 1;
 2b       if (EditedDS.EditedArry(xa) > ' '
             and EditedDS.EditedArry(xa) <> '0');
 
 3b          if (DecimalPos = 0
                and EditedDS.EditedArry(xa) = '.');
 3x          else;
                EndPosX -= 1;
                %subst(Layout: EndPosx:1) = EditedDS.EditedArry(xa);
 3e          endif;
 2e       endif;
 1e    endfor;
 
       // set variables to load field name into print arrays
       xi = EndPosX - 1;
 1b    if xi <= 0;
          xi = 1;
 1e    endif;
       xk = EndPosX;
       exsr srStagger;
       endsr;
 
       //---------------------------------------------------------
       // Process numeric fields having edit words or constants.
       // The only difference is edit words replace ' '  with '9'.
       //---------------------------------------------------------
       begsr srDoConstLeft;
       LoadNamFlg = 'Start FldNam';
 
 1b    for xm = 2 to 28;
 2b       if %subst(SrcDS.oConstant: xm: 1) = qs;
 1v          leave;
 2e       endif;
          EndPosX += 1;
 
 2b       if LoadNamFlg = 'Start FldNam';
             exsr srLoadFieldName;
 2e       endif;
 
 2b       if %subst(SrcDS.oConstant: xm: 1) = ' '
             and IPPfield = 'Num EditWord';
 
 3b          if FieldsAttrDS.DataType = 'D';
                %subst(Layout: EndPosx:1) = 'D';
 3x          elseif FieldsAttrDS.DataType = 'Z';
                %subst(Layout: EndPosx:1) = 'Z';
 3x          elseif FieldsAttrDS.DataType = 'T';
                %subst(Layout: EndPosx:1) = 'T';
 3x          else;
 4b             if EndPosX <= 198;
                   %subst(Layout: EndPosx:1) = '9';  //load edited field
 4e             endif;
 3e          endif;
 2x       else;
 3b          if EndPosX <= 198;
                %subst(Layout: EndPosx:1) = %subst(SrcDS.oConstant: xm: 1);
 3e          endif;
 2e       endif;
 2b       if EndPosX >= 198;
 1v          leave;
 2e       endif;
 1e    endfor;
       LastEndPos = EndPosX;
       endsr;
 
       //---------------------------------------------------------
       // Constants or Edit worded fields.
       // Start at end position and work backwards.
       // RPG output constant uses two single quotes to print single quote
       // Replace two single quotes with single quote before calculating length of constant.
       //---------------------------------------------------------
       begsr srDoConstRight;
       LastEndPos = EndPosX;
 
       IsContinuation = *off;
       xe = %scan(qs + qs: SrcDS.oConstant: 2);
 1b    dow xe > 0;
          SrcDS.oConstant = %replace(qs: SrcDS.oConstant: xe: 2);
          xe = %scan(qs + qs: SrcDS.oConstant: xe + 1);
 1e    enddo;
 
       //-----------------------------------------------------------------
       // Load all continued lines into a long string then load that
       // string into the output array.  For every line ending
       // in a + sign, need to remove all spaces but one and remove the + sign.
       //-----------------------------------------------------------------
       aa = %checkr(' ': SrcDS.oConstant);
 1b    if %subst(SrcDS.oConstant:aa:1) = '+';
          %len(BuildContin) = 0;
          BuildContin = %trim(%subst(SrcDS.oConstant:2:aa-2)) + ' ';
 
 2b       dou IsContinuation = *off;
             read RPGSRC SrcDS;
             aa = %checkr(' ': SrcDS.oConstant);
 3b          if %subst(SrcDS.oConstant:aa:1) = '+';
                BuildContin = BuildContin +
                %trim(%subst(SrcDS.oConstant:1:aa-1)) + ' ';
                IsContinuation = *on;
 3x          else;
                BuildContin = BuildContin +
                %trim(%subst(SrcDS.oConstant:1:aa-1));
                IsContinuation = *off;
 
                bb = %len(BuildContin);
 4b             for EndPosX = LastEndpos by 1
                   downto (LastEndPos - (%len(BuildContin)-1));
                   %subst(Layout: EndPosx:1) = %subst(BuildContin: bb: 1);
                   bb -= 1;
 4e             endfor;
 3e          endif;
 2e       enddo;
 1x    else;
 
          //-----------------------------------------------------------------
          xe = %checkr(' ': SrcDS.oConstant);
          EndPosX += 1;
 
 2b       for xa = (xe - 1) downto 2;
             EndPosX -= 1;
 3b          if %subst(SrcDS.oConstant: xa: 1) = ' '
                and IPPfield = 'Num EditWord';
 4b             if FieldsAttrDS.DataType = 'D';
                   %subst(Layout: EndPosx:1) = 'D';
 4x             elseif FieldsAttrDS.DataType = 'Z';
                   %subst(Layout: EndPosx:1) = 'Z';
 4x             elseif FieldsAttrDS.DataType = 'T';
                   %subst(Layout: EndPosx:1) = 'T';
 4x             else;
                   %subst(Layout: EndPosx:1) = '9';  //load edited field
 4e             endif;
 3x          else;
 
                %subst(Layout: EndPosx:1) = %subst(SrcDS.oConstant: xa: 1);
 3e          endif;
 2e       endfor;
 1e    endif;
 
       // set variable to load field name
 1b    if SrcDS.oEname > *blanks;
          xi = EndPosX - 1;
 2b       if xi <= 0;
             xi = 1;
 2e       endif;
          xk = EndPosX;
          exsr srStagger;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // load edit coded field with end positions
       //---------------------------------------------------------
       begsr srAlphaRight;
       LastEndPos = EndPosX;
       EndPosX += 1;
 1b    for ForCount = 1 to FieldsAttrDS.Length;
          EndPosX -= 1;
          %subst(Layout: EndPosx:1) = 'X';  //load edited field
 1e    endfor;
       // set variables to load field name
       xi = EndPosX - 1;
 1b    if xi <= 0;
          xi = 1;
 1e    endif;
       xk = EndPosX;
       exsr srStagger;
       endsr;
 
       //---------------------------------------------------------
       // Process alpha fields with no end positions or + positioning.  load from front
       //---------------------------------------------------------
       begsr srDoAlphaLeft;
       xk = EndPosX + 1;
       xi = xk - 1;
 1b    if xi <= 0;
          xi = 1;
 1e    endif;
       exsr srStagger;
 
       // Load 'X's to positionally represent alpha field
 1b    for ForCount = 1 to FieldsAttrDS.Length;
          EndPosX += 1;
 2b       if EndPosX <= 198;
             %subst(Layout: EndPosx:1) = 'X';
 2x       else;
 1v          leave;
 2e       endif;
 1e    endfor;
       LastEndPos = EndPosX;
       endsr;
 
       //---------------------------------------------------------
       // Set values to load field name for this time variable
       //---------------------------------------------------------
       begsr srLoadFieldName;
       xi = EndPosX - 1;
 1b    if xi <= 0;
          xi = 1;
 1e    endif;
       xk = EndPosX;
       exsr srStagger;
       LoadNamFlg = *blanks;
       endsr;
 
       //---------------------------------------------------------
       // Formatted2 & Formatted3 business is to stagger field names if short length fields.
       // 9 99 9
       // Fieldname 1
       //   Fieldname 2
       //      Fieldname 3
       // Be careful of fields names that extend past 198.
       // example:  Field a123456789 is in position 197.  There is not
       // enough room to load entire field name.
       //---------------------------------------------------------
       begsr srStagger;
       xo = %len(%trimr(SrcDS.oEname));
 1b    if 198 - (xk - 1) < xo;
          xo = 198 - (xk - 1);
 1e    endif;
 
 1b    for cc = 1 to 10;
 2b       if %subst(StaggerNam(cc): xi: xo + 1) = *blanks;
 3b          if xk <= 198;
                %subst(StaggerNam(cc): xk: xo) = SrcDS.oEname;
 3e          endif;
 3b          if cc > StaggerDepth;
                StaggerDepth = cc;
 3e          endif;
 1v          leave;
 2e       endif;
 1e    endfor;
 
       endsr;
 
       //---------------------------------------------------------
       // Get field attributes. If field name, then look up array to get attributes.
       //---------------------------------------------------------
       begsr srGetFieldAttr;
 1b    if SrcDS.oConstant > *blanks
          and SrcDS.oEname = *blanks;
          IPPfield = 'Constant';
 1x    else;
          SrcDS.oEname = %xlate(lo: up: SrcDS.oEname);
 
          //---------------------------------------------------------
          // There could be an indexed array name as an output field.
          // Lookup with array name to get attributes.
          //---------------------------------------------------------
          LookupName = SrcDS.oEname;
          xa = %scan('(': LookupName: 1);
 2b       if xa <> 0;
             LookupName = %subst(LookupName: 1: xa - 1);
 2e       endif;
 
          xa = %lookup(LookupName: FieldsArry(*).Name: 1: FieldsArryCnt);
 2b       if xa > 0;
             FieldsAttrDS = FieldsArry(xa).Attr;
 3b          if FieldsAttrDS.DecimalPos = *blanks;
                DecimalPos = 0;
 3x          else;
                DecimalPos = FieldsAttrDS.DecimalPosN;
 3e          endif;
 
             //---------------------------------------------------------
             // Back to array fun!  It could be that an
             // that an un-indexed array name was coded on output.
             // The JCRGETFLDR program loads array definitions
             // in two parts.  Multiply element length by num elements.
             //---------------------------------------------------------
             xg = %scan('DIM(': FieldsAttrDS.Text: 1);
 3b          if xg <> 0
                and LookupName = SrcDS.oEname   //not indexed
                and %subst(LookupName:1:3) <> 'TAB';
                xf = %scan(')': FieldsAttrDS.Text: xg);
 
 4b             if xf <> 0;  //end of )
                   xd = (xf - 1) - 4;
                   xh = (6 - xd);
                   DimSizeVal = *blanks;
                   %subst(DimSizeVal: xh: xd) =
                   %subst(FieldsAttrDS.Text: 5: xd);
 5b                if DimSizeVal = *blanks;
                      DimSizeVal = '00000';
 5e                endif;
                   // make numeric
                   FieldsAttrDS.Length =
                   FieldsAttrDS.Length * %uns(DimSizeVal);
 4e             endif;
 3e          endif;
 
             //---------------------------------------------------------
 3b          if FieldsAttrDS.DataType = 'A';
                IPPfield = 'Alpha Field';
 
                //---------------------------------------------------------
                // New to O specs is ability to format date, time and
                // and timestamp fields.
                // Dummy up field length,
                // build an edit word based on type field
                // and type formatting.
                //---------------------------------------------------------
 3x          elseif FieldsAttrDS.DataType = 'D'
                or FieldsAttrDS.DataType = 'T'
                or FieldsAttrDS.DataType = 'Z';
                IPPfield = 'Num EditWord';
                SrcDS.oConstant =
                f_BuildEditWord(SrcDS.oConstant: FieldsAttrDS.DataType);
 
 3x          else;
 4b             if SrcDS.oConstant > *blanks
                   and SrcDS.oEditCode = ' ';
                   IPPfield = 'Num EditWord';
 4x             else;
                   IPPfield = 'Num EditCode';
 4e             endif;
 3e          endif;
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Fill whole number part of number
       // Number of decimals is subtracted from field length to get number
       // of digits in whole number.  Zeros and nines are loaded.
       // End result for 9,2 field is 000000000000009999999
       // Y editcodes are always 99/99/99
       //---------------------------------------------------------
       begsr srGetEditCode;
 1b    if SrcDS.oEditCode = 'Y'
          or SrcDS.oEditCode = 'y';
 
          EditedDS = ' 99/99/99';
 2b       if FieldsAttrDS.Length = 8;
             EditedDS = ' 99/99/9999';
 2e       endif;
 1x    else;
          IntegerLength = FieldsAttrDS.Length - DecimalPos;
          WholePart =
          %subst(AllZeros: 1: (%size(WholePart) - IntegerLength)) +
          %subst(AllNines: 1: IntegerLength);
 
          //---------------------------------------------------------
          // Number of decimal places loads up left side
          // of field with 9's and fill out remainder with zeros.
          // End result for 9,2 field is 990000000
          //---------------------------------------------------------
 2b       if DecimalPos = 0;
             DecimalPart = *all'0';
 2x       else;
             DecimalPart =
             %subst(AllNines: 1: DecimalPos) +
             %subst(AllZeros: DecimalPos + 1:
             %size(DecimalPart) - DecimalPos);
 2e       endif;
 
          //---------------------------------------------------------
          // Make negative numeric so edit code application can generate max size.
          //---------------------------------------------------------
          v30_9DS = WholePart + DecimalPart;
          v30_9Dec = -(v30_9DS.v30_9Zoned);  //make negative packed
 2b       if SrcDS.oEditCode = ' ';  //Use 'Z' so mapper will work
             SrcDS.oEditCode = 'Z';
 2x       else;
             SrcDS.oEditCode = %xlate(lo: up: SrcDS.oEditCode);
 2e       endif;
 
          // Create edit mask required to apply edit code
          callp QECCVTEC(
                ReceiverVar:
                EditMaskLen:
                ReceiverVarLen:
                ' ':
                SrcDS.oEditCode:
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
          // Load length of field so it will show on report.
          //---------------------------------------------------------
 2b       if ReceiverVar = *blanks;  //could not apply
             ReceiverVar = %subst(AllNines: 2: FieldsAttrDS.Length);
 2e       endif;
          EditedDS = ReceiverVar;
 
          // Load if field has floating $ sign
 2b       if SrcDS.oConstant = FloatDollar;
             xe = %scan('9': EditedDS: 1);
 3b          if xe > 1;
                xe -= 1;
                %subst(EditedDS: xe: 1) = '$';
 3e          endif;
 2e       endif;
 1e    endif;
       endsr;
