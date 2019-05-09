       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRINDR - Indicator List
       //---------------------------------------------------------
       /define ControlStatements
       /define Constants
       /define f_BlankCommentsCL
       /define Dspatr
       /define SrcDS
       /define f_GetQual
       /define f_GetDayName
       /define f_Qusrmbrd
       /define f_BuildString
       /define f_SndCompMsg
       /define f_IsCompileTimeArray
       // *ENTRY
       /define p_JCRINDR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRINDD workstn;
       dcl-f RPGSRC disk(112) extfile(extIfile) extmbr(ExtMbr) usropn
       Infds(Infds);
       dcl-ds Infds;
        InfdsRecLen int(5) pos(125);
       end-ds;
 
       dcl-s MbrCount uns(3);
       dcl-s MbrColon char(4) inz('Mbr:');
       dcl-s OffsetToNext int(5) based(displaceptr);
       dcl-s NumOfLists int(5) based(parmptr);
       dcl-s col uns(3);
       dcl-s row uns(3);
       dcl-s CompMsgString varchar(36);
       dcl-s ExtMbr char(10);
       dcl-s FileQual char(20);
       dcl-s ExtendedF2 char(45);
       dcl-s yy uns(5);
       dcl-s IsCalcSpec ind;
       dcl-s IsFree ind;
       dcl-s IsComment ind;
       dcl-s MaybeIN char(6);  // CLLE
       dcl-s scObjHead dim(3) based(ptr1) like(scobjhead1);
       dcl-s ptr1 pointer inz(%addr(scobjhead1));
 
       // Get number of source file/lib/Mbr names
       dcl-ds MbrList based(MbrListPtr) qualified;
        SrcMbr char(10) pos(3);
        SrcFilQual char(20);
       end-ds;
 
       dcl-ds FoundOne qualified inz;
        Pos1 char(1) pos(1);
        Pos2 char(1) pos(2);
       end-ds;
 
       dcl-ds Indicators dim(12) qualified based(ptr2);
        col char(2) dim(18);
       end-ds;
       dcl-s ptr2 pointer inz(%addr(r0c01));
 
       dcl-ds Attr dim(12) qualified based(ptr3);
        col char(1) dim(18);
       end-ds;
       dcl-s ptr3 pointer inz(%addr(atr0c01));
 
       // map screen fields into program array
       dcl-ds *n;
        scObjHead1;
        scObjHead2;
        scObjHead3;
        r0c01;
        r0c02;
        r0c03;
        r0c04;
        r0c05;
        r0c06;
        r0c07;
        r0c08;
        r0c09;
        r0c10;
        r0c11;
        r0c12;
        r0c13;
        r0c14;
        r0c15;
        r0c16;
        r0c17;
        r0c18;
        r1c01;
        r1c02;
        r1c03;
        r1c04;
        r1c05;
        r1c06;
        r1c07;
        r1c08;
        r1c09;
        r1c10;
        r1c11;
        r1c12;
        r1c13;
        r1c14;
        r1c15;
        r1c16;
        r1c17;
        r1c18;
        r2c01;
        r2c02;
        r2c03;
        r2c04;
        r2c05;
        r2c06;
        r2c07;
        r2c08;
        r2c09;
        r2c10;
        r2c11;
        r2c12;
        r2c13;
        r2c14;
        r2c15;
        r2c16;
        r2c17;
        r2c18;
        r3c01;
        r3c02;
        r3c03;
        r3c04;
        r3c05;
        r3c06;
        r3c07;
        r3c08;
        r3c09;
        r3c10;
        r3c11;
        r3c12;
        r3c13;
        r3c14;
        r3c15;
        r3c16;
        r3c17;
        r3c18;
        r4c01;
        r4c02;
        r4c03;
        r4c04;
        r4c05;
        r4c06;
        r4c07;
        r4c08;
        r4c09;
        r4c10;
        r4c11;
        r4c12;
        r4c13;
        r4c14;
        r4c15;
        r4c16;
        r4c17;
        r4c18;
        r5c01;
        r5c02;
        r5c03;
        r5c04;
        r5c05;
        r5c06;
        r5c07;
        r5c08;
        r5c09;
        r5c10;
        r5c11;
        r5c12;
        r5c13;
        r5c14;
        r5c15;
        r5c16;
        r5c17;
        r5c18;
        r6c01;
        r6c02;
        r6c03;
        r6c04;
        r6c05;
        r6c06;
        r6c07;
        r6c08;
        r6c09;
        r6c10;
        r6c11;
        r6c12;
        r6c13;
        r6c14;
        r6c15;
        r6c16;
        r6c17;
        r6c18;
        r7c01;
        r7c02;
        r7c03;
        r7c04;
        r7c05;
        r7c06;
        r7c07;
        r7c08;
        r7c09;
        r7c10;
        r7c11;
        r7c12;
        r7c13;
        r7c14;
        r7c15;
        r7c16;
        r7c17;
        r7c18;
        r8c01;
        r8c02;
        r8c03;
        r8c04;
        r8c05;
        r8c06;
        r8c07;
        r8c08;
        r8c09;
        r8c10;
        r8c11;
        r8c12;
        r8c13;
        r8c14;
        r8c15;
        r8c16;
        r8c17;
        r8c18;
        r9c01;
        r9c02;
        r9c03;
        r9c04;
        r9c05;
        r9c06;
        r9c07;
        r9c08;
        r9c09;
        r9c10;
        r9c11;
        r9c12;
        r9c13;
        r9c14;
        r9c15;
        r9c16;
        r9c17;
        r9c18;
        r10c01;
        r10c02;
        r10c03;
        r10c04;
        r10c05;
        r10c06;
        r10c07;
        r10c08;
        r10c09;
        r10c10;
        r10c11;
        r10c12;
        r10c13;
        r10c14;
        r10c15;
        r10c16;
        r10c17;
        r10c18;
        r11c01;
        r11c02;
        r11c03;
        r11c04;
        r11c05;
        r11c06;
        r11c07;
        r11c08;
        r11c09;
        r11c10;
        r11c11;
        r11c12;
        r11c13;
        r11c14;
        r11c15;
        r11c16;
        r11c17;
        r11c18;
        atr0c01;
        atr0c02;
        atr0c03;
        atr0c04;
        atr0c05;
        atr0c06;
        atr0c07;
        atr0c08;
        atr0c09;
        atr0c10;
        atr0c11;
        atr0c12;
        atr0c13;
        atr0c14;
        atr0c15;
        atr0c16;
        atr0c17;
        atr0c18;
        atr1c01;
        atr1c02;
        atr1c03;
        atr1c04;
        atr1c05;
        atr1c06;
        atr1c07;
        atr1c08;
        atr1c09;
        atr1c10;
        atr1c11;
        atr1c12;
        atr1c13;
        atr1c14;
        atr1c15;
        atr1c16;
        atr1c17;
        atr1c18;
        atr2c01;
        atr2c02;
        atr2c03;
        atr2c04;
        atr2c05;
        atr2c06;
        atr2c07;
        atr2c08;
        atr2c09;
        atr2c10;
        atr2c11;
        atr2c12;
        atr2c13;
        atr2c14;
        atr2c15;
        atr2c16;
        atr2c17;
        atr2c18;
        atr3c01;
        atr3c02;
        atr3c03;
        atr3c04;
        atr3c05;
        atr3c06;
        atr3c07;
        atr3c08;
        atr3c09;
        atr3c10;
        atr3c11;
        atr3c12;
        atr3c13;
        atr3c14;
        atr3c15;
        atr3c16;
        atr3c17;
        atr3c18;
        atr4c01;
        atr4c02;
        atr4c03;
        atr4c04;
        atr4c05;
        atr4c06;
        atr4c07;
        atr4c08;
        atr4c09;
        atr4c10;
        atr4c11;
        atr4c12;
        atr4c13;
        atr4c14;
        atr4c15;
        atr4c16;
        atr4c17;
        atr4c18;
        atr5c01;
        atr5c02;
        atr5c03;
        atr5c04;
        atr5c05;
        atr5c06;
        atr5c07;
        atr5c08;
        atr5c09;
        atr5c10;
        atr5c11;
        atr5c12;
        atr5c13;
        atr5c14;
        atr5c15;
        atr5c16;
        atr5c17;
        atr5c18;
        atr6c01;
        atr6c02;
        atr6c03;
        atr6c04;
        atr6c05;
        atr6c06;
        atr6c07;
        atr6c08;
        atr6c09;
        atr6c10;
        atr6c11;
        atr6c12;
        atr6c13;
        atr6c14;
        atr6c15;
        atr6c16;
        atr6c17;
        atr6c18;
        atr7c01;
        atr7c02;
        atr7c03;
        atr7c04;
        atr7c05;
        atr7c06;
        atr7c07;
        atr7c08;
        atr7c09;
        atr7c10;
        atr7c11;
        atr7c12;
        atr7c13;
        atr7c14;
        atr7c15;
        atr7c16;
        atr7c17;
        atr7c18;
        atr8c01;
        atr8c02;
        atr8c03;
        atr8c04;
        atr8c05;
        atr8c06;
        atr8c07;
        atr8c08;
        atr8c09;
        atr8c10;
        atr8c11;
        atr8c12;
        atr8c13;
        atr8c14;
        atr8c15;
        atr8c16;
        atr8c17;
        atr8c18;
        atr9c01;
        atr9c02;
        atr9c03;
        atr9c04;
        atr9c05;
        atr9c06;
        atr9c07;
        atr9c08;
        atr9c09;
        atr9c10;
        atr9c11;
        atr9c12;
        atr9c13;
        atr9c14;
        atr9c15;
        atr9c16;
        atr9c17;
        atr9c18;
        atr10c01;
        atr10c02;
        atr10c03;
        atr10c04;
        atr10c05;
        atr10c06;
        atr10c07;
        atr10c08;
        atr10c09;
        atr10c10;
        atr10c11;
        atr10c12;
        atr10c13;
        atr10c14;
        atr10c15;
        atr10c16;
        atr10c17;
        atr10c18;
        atr11c01;
        atr11c02;
        atr11c03;
        atr11c04;
        atr11c05;
        atr11c06;
        atr11c07;
        atr11c08;
        atr11c09;
        atr11c10;
        atr11c11;
        atr11c12;
        atr11c13;
        atr11c14;
        atr11c15;
        atr11c16;
        atr11c17;
        atr11c18;
       end-ds;
 
       //---------------------------------------------------------
       // process parm list by moving data structure pointer
       ParmPtr = %addr(p_SrcMbrs);
       DisplacePtr = ParmPtr;
 
 1b    for MbrCount = 1 to NumOfLists;
          DisplacePtr += 2;
          MbrListPtr = ParmPtr + OffsetToNext;
          FileQual = MbrList.SrcFilQual;
          ExtMbr = MbrList.SrcMbr;
 
          // get member type
          QusrmbrdDS = f_Qusrmbrd(FileQual: ExtMbr: 'MBRD0200');
 
          scObjHead(MbrCount) =
          f_BuildString('& &  &  &  &':
          MbrColon: QusrmbrdDS.Mbr: QusrmbrdDS.File:
          QusrmbrdDS.Lib: QusrmbrdDS.Text);
          MbrColon = *blanks;
 
 2b       if MbrCount = 1;
             CompMsgString = %trimr(ExtMbr);
 2x       else;
             CompMsgString += ', ' + %trimr(ExtMbr);
 2e       endif;
 
          extIfile = f_GetQual(QusrmbrdDS.File + QusrmbrdDS.Lib);
          scDow = f_GetDayName();
 
          open RPGSRC;
          read RPGSRC SrcDS;
 
          // Execute different source reader based on source type
 2b       if QusrmbrdDS.MbrType = 'RPGLE'
             or QusrmbrdDS.MbrType = 'SQLRPGLE';
             exsr srReadSrcRPGLE;
 
 2x       elseif %subst(QusrmbrdDS.MbrType: 1: 4) = 'DSPF'
             or %subst(QusrmbrdDS.MbrType: 1: 4) = 'PRTF';
             exsr srReadSrcDDS;
 
 2x       elseif %subst(QusrmbrdDS.MbrType: 1: 2) = 'CL';
             exsr srReadSrcCL;
 2e       endif;
          close RPGSRC;
 1e    endfor;
 
       //---------------------------------------------------------
       // fill in any unused grid locations
       //---------------------------------------------------------
 1b    for row = 1 to 10;
 2b       for col = 1 to 18;
 3b          if Indicators(row).Col(col) = ' ';
                Indicators(row).Col(col) = '.';
                Attr(row).Col(col) = BLUE;
 3e          endif;
 2e       endfor;
 1e    endfor;
 
       exfmt screen;
       f_SndCompMsg('JCRIND for ' + %trimr(CompMsgString) + ' - completed');
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       // Read Rpg4 Source code.
       // Three types of lines scanned are calc, input, output.
       // all lines that are comment or have eject character are
       // ignored. Exit at first compile time table or array.
       // calculation, all conditioning, used as fields, and resulting
       // input record id, L indicators, field indicators
       // output conditioning indicators
       //---------------------------------------------------------
       begsr srReadSrcRPGLE;
 1b    dow not %eof;
          // do not process compile time arrays
 2b       if f_IsCompileTimeArray(SrcDS.CompileArray);
 LV          leavesr;
 2e       endif;
 
          // O specs will set IsCalcSpec off
          SrcDS.SpecType = %xlate(lo: up: SrcDS.SpecType);
 2b       if SrcDS.SpecType = 'O'
             or SrcDS.SpecType = 'P'
             or SrcDS.SpecType = 'D'
             or SrcDS.SpecType = 'I'
             or SrcDS.SpecType = 'F';
             IsCalcSpec = *off;
 2e       endif;
 
          // if C or c or /free, then inside C specs
 2b       if SrcDS.SpecType = 'C';
             IsCalcSpec = *on;
 2e       endif;
 
          // see if inside /free
          IsFree = *off;
 2b       if SrcDS.SpecType = ' ';
             IsFree = *on;
             IsCalcSpec = *on;
 2e       endif;
 
          // see if /free comment line or /copy / define etc..
          IsComment = *off;
 2b       if SrcDS.Asterisk = '*'
             or SrcDS.Asterisk = '/'
             or SrcDS.Asterisk = '+'
             or (%len(%triml(SrcDS.Src80)) > 1
             and %subst((%triml(SrcDS.Src80)): 1: 1) = '/');
             IsComment = *on;
 2e       endif;
 
          // check conditioning indicators for calc specs
 2b       if not IsComment;
 3b          if IsCalcSpec;
 4b             if IsFree;
                   SrcDS.Src80 = %xlate(lo: up: SrcDS.Src80);
                   cc = %scan('//': SrcDS.Src80: 1);
                   yy = 0;
 5b                dou yy = 0;
                      yy = %scan('*IN': SrcDS.Src80: yy + 1);
 6b                   if yy > 0;
                         // if indicator is past comment markers
 7b                      if cc > 0 and yy > cc;
 5v                         leave;
 7e                      endif;
 
                         f_Extract(%subst(SrcDS.Src80: yy: 6));
 6e                   endif;
 5e                enddo;
 4x             else;
                   SrcDS = %xlate(lo: up: SrcDS);
                   f_LoadMatrix(%subst(SrcDS: 22: 2)); //CONDITIONING IND
 
 5b                if %subst(SrcDS: 19: 2) = 'L0';
                      f_LoadMatrix('L0');
 5e                endif;
 
 5b                if (%subst(SrcDS: 38: 4) = 'EVAL')
                      or (%subst(SrcDS: 38: 5) = 'WHEN ')
                      or (%subst(SrcDS: 38: 4) = 'DOW ')
                      or (%subst(SrcDS: 38: 4) = 'DOU ')
                      or (%subst(SrcDS: 38: 3) = 'IF ')
                      or (%subst(SrcDS: 38: 5) = *blanks);
 
                      ExtendedF2 = %subst(SrcDS: 48: 45); //EXTENDED FACTOR2
                      yy = 0;
 6b                   dou yy = 0;
                         yy = %scan('*IN': ExtendedF2: yy + 1);
 7b                      if yy > 0;
                            f_Extract(%subst(ExtendedF2: yy: 6));
 7e                      endif;
 6e                   enddo;
 5x                else;
 6b                   if (%subst(SrcDS: 24: 3) = '*IN')
                         and (%subst(SrcDS: 27: 1) <> 'Z');
                         f_Extract(%subst(SrcDS: 24: 6));
 6e                   endif;
 
 6b                   if (%subst(SrcDS: 48: 3) = '*IN');  //FACTOR 2 *IN
                         f_Extract(%subst(SrcDS: 48: 6));
 6e                   endif;
 
 6b                   if (%subst(SrcDS: 62: 3) = '*IN');  //RESULT FIELD *IN
                         f_Extract(%subst(SrcDS: 62: 6));
 6e                   endif;
 
                      // load resulting indicators
 6b                   if %subst(SrcDS: 38: 4) <> 'CALL';
 7b                      if %subst(SrcDS: 83: 2) > *blanks;  //HIGH
                            f_Extract('   ' + %subst(SrcDS: 83: 2));
 7e                      endif;
 
 7b                      if %subst(SrcDS: 85: 2) > *blanks;  //LO
                            f_Extract('   ' + %subst(SrcDS: 85: 2));
 7e                      endif;
 
 7b                      if %subst(SrcDS: 87: 2) > *blanks;  //EQUAL
                            f_Extract('   ' + %subst(SrcDS: 87: 2));
 7e                      endif;
 6e                   endif;
 5e                endif;
 4e             endif;
 
                //---------------------------------------------------------
                // I spec indicators
                //---------------------------------------------------------
 3x          elseif SrcDS.SpecType = 'I'
                or SrcDS.SpecType = 'i';
                SrcDS = %xlate(lo: up: SrcDS);
 4b             if (%subst(SrcDS: 19: 10) > *blanks) or  //FILE NAME
                   (%subst(SrcDS: 29: 2) > *blanks);  //OR SEQ PRESENT?
 5b                if (%subst(SrcDS: 33: 2) > *blanks) and     // RECORD ID
                      (%subst(SrcDS: 33: 2) <> 'DS');
                      f_LoadMatrix(%subst(SrcDS: 33: 2));
 5e                endif;
 4e             endif;
 
                f_LoadMatrix(%subst(SrcDS: 75: 2)); //L INDICATORS
                f_LoadMatrix(%subst(SrcDS: 77: 2)); //MATCHING RECORDS
                f_LoadMatrix(%subst(SrcDS: 79: 2)); //RELATIONAL
                f_LoadMatrix(%subst(SrcDS: 81: 2)); //FIELD +
                f_LoadMatrix(%subst(SrcDS: 83: 2)); //FIELD -
                f_LoadMatrix(%subst(SrcDS: 85: 2)); //FIELD 0/*BLANK
 
                //---------------------------------------------------------
                // O spec indicators
                //---------------------------------------------------------
 3x          elseif SrcDS.SpecType = 'O'
                or SrcDS.SpecType = 'o';
                SrcDS = %xlate(lo: up: SrcDS);
                f_LoadMatrix(%subst(SrcDS: 34: 2)); //O SPEC INDICATOR 1
                f_LoadMatrix(%subst(SrcDS: 37: 2)); //O SPEC IND 2
                f_LoadMatrix(%subst(SrcDS: 40: 2)); //O SPEC IND 3
 
                //---------------------------------------------------------
                // F spec indicators
                //---------------------------------------------------------
 3x          elseif SrcDS.SpecType = 'F'
                or SrcDS.SpecType = 'f';
                SrcDS = %xlate(lo: up: SrcDS);
 
                yy = %scan('OFLIND(*IN': SrcDS);
 4b             if yy > 55 and yy < 93;
                   f_LoadMatrix(%subst(SrcDS: yy + 10: 2));
 4x             else;
                   yy = %scan('OFLIND(': SrcDS);
 5b                if yy > 55 and yy < 93;
                      f_LoadMatrix(%subst(SrcDS: yy + 7: 2));
 5e                endif;
 4e             endif;
                yy = %scan('EXTIND(*IN': SrcDS);
 4b             if yy > 55 and yy < 93;
                   f_LoadMatrix(%subst(SrcDS: yy + 10: 2));
 4e             endif;
 3e          endif;
 2e       endif;
          read RPGSRC SrcDS;
 1e    enddo;
       endsr;
 
       //---------------------------------------------------------
       // Display or Print file Indicators
       //---------------------------------------------------------
       begsr srReadSrcDDS;
 1b    dow not %eof;
          // ignore all lines that are comment or have eject characters
 2b       if SrcDS.SpecType = 'A'
             and not(SrcDS.Asterisk = '*' or SrcDS.Asterisk = '/');
 
 3b          if SrcDS.ddsCondIn1 >= '01' and SrcDS.ddsCondIn1 <= '99';
                f_LoadMatrix(SrcDS.ddsCondIn1);
 3e          endif;
 
 3b          if SrcDS.ddsCondIn2 >= '01' and SrcDS.ddsCondIn2 <= '99';
                f_LoadMatrix(SrcDS.ddsCondIn2);
 3e          endif;
 
 3b          if SrcDS.ddsCondIn3 >= '01' and SrcDS.ddsCondIn3 <= '99';
                f_LoadMatrix(SrcDS.ddsCondIn3);
 3e          endif;
 
             // extract indicators that are assigned to keywords
 3b          if SrcDS.ddsField10 = 'VLDCMDKEY(';
                f_LoadMatrix(%subst(SrcDS.ddsField: 11: 2));
 3x          elseif SrcDS.ddsField9 = 'PAGEDOWN('
                or SrcDS.ddsField9 = 'ROLLDOWN(';
                f_LoadMatrix(%subst(SrcDS.ddsField: 10: 2));
 3x          elseif SrcDS.ddsField7 = 'BLANKS('
                or SrcDS.ddsField7 = 'CHANGE('
                or SrcDS.ddsField7 = 'INDTXT('
                or SrcDS.ddsField7 = 'PAGEUP('
                or SrcDS.ddsField7 = 'ROLLUP(';
                f_LoadMatrix(%subst(SrcDS.ddsField: 8: 2));
 
 3x          elseif SrcDS.ddsField6 = 'CLEAR('
                or SrcDS.ddsField6 = 'SETOF('
                or (SrcDS.ddsField7 >= 'PRINT(0'
                and SrcDS.ddsField7 <= 'PRINT(9');
                f_LoadMatrix(%subst(SrcDS.ddsField: 7: 2));
 
 3x          elseif SrcDS.ddsField5 = 'HELP('
                or
                SrcDS.ddsField5 = 'HOME('
                or
                SrcDS.ddsField2 = 'CA'
                and SrcDS.ddsParenthesis = '('
                or
                SrcDS.ddsField2 = 'CF'
                and SrcDS.ddsParenthesis = '(';
                f_LoadMatrix(%subst(SrcDS.ddsField: 6: 2));
 3x          elseif SrcDS.ddsField4 = 'DUP(';
                f_LoadMatrix(%subst(SrcDS.ddsField: 5: 2));
 3e          endif;
 2e       endif;
          read RPGSRC SrcDS;
 1e    enddo;
       endsr;
 
       //---------------------------------------------------------
       // read CL source code
       //---------------------------------------------------------
       begsr srReadSrcCL;
 1b    dow not %eof;
          // If 92 record length, blank out any possible garbage from 93 to 112
 2b       if InfdsRecLen = 92;
             %subst(SrcDS: 93) = *blanks;
 2e       endif;
 
          SrcDS.Src112 = f_BlankCommentsCL(SrcDS.Src112);
          SrcDS.Src112 = %xlate(lo: up: SrcDS.Src112);
 
          yy = 0;
 2b       dou yy = 0;
             yy = %scan('&IN': SrcDS.Src112: yy + 1);
 3b          if yy > 0;
                MaybeIN = %subst(SrcDS.Src112: yy: 6);
 
                //---------------------------------------------------------
                // extract indicator values. &INxx) or &INxx  are acceptable
                // xx must equal numeric and position following must be ' ' or )
                //---------------------------------------------------------
 4b             if %subst(MaybeIN: 4: 1) >= '0'
                   and %subst(MaybeIN: 4: 1) <= '9'
                   and %subst(MaybeIN: 5: 1) >= '0'
                   and %subst(MaybeIN: 5: 1) <= '9';
 
 5b                if (%subst(MaybeIN: 6: 1) = ')')
                      or (%subst(MaybeIN: 6: 1) = *blanks);
                      f_LoadMatrix(%subst(MaybeIN: 4: 2));
 5e                endif;
 4e             endif;
 3e          endif;
 2e       enddo;
          read RPGSRC SrcDS;
 1e    enddo;
       endsr;
 
       //---------------------------------------------------------
       // global load indicator to proper Row/Col
       //---------------------------------------------------------
       dcl-proc f_LoadMatrix;
        dcl-pi *n;
         p_Ind char(2) const;
        end-pi;
 
 1b     if p_Ind <> 'ZS';  //not *inzsr
 
           FoundOne = p_Ind;
 2b        if FoundOne.Pos1 > ' ' and FoundOne.Pos2 > ' ';
 
              row = f_GetRow(FoundOne);
 3b           if row > 0;
                 col = f_GetColumn(FoundOne);
 4b              if col > 0;
                    Indicators(row).Col(col) = FoundOne;
                    Attr(row).Col(col) = WHITE;
 4e              endif;
 3e           endif;
 2e        endif;
 1e     endif;
 
        return;
       end-proc;
 
       //---------------------------------------------------------
       // load indicators that are used as field names.
       // *inxx or *in(xx) or *in(x) are tested for and loaded.
       // The index is checked for numeric.
       //---------------------------------------------------------
       dcl-proc f_Extract;
        dcl-pi *n;
         IndExtract char(6) const;
        end-pi;
 
        dcl-s TestByte char(1);
 
 1b     if (%subst(IndExtract: 4: 1) <> '('); //not array element
           FoundOne = %subst(IndExtract: 4: 2);  //load key
 2b        if FoundOne = 'OA' or FoundOne = 'OB' or FoundOne = 'OC' or
              FoundOne = 'OD' or FoundOne = 'OE' or FoundOne = 'OF' or
              FoundOne = 'OG' or FoundOne = 'OV' or FoundOne = 'L0' or
              FoundOne = 'RT' or FoundOne = 'LR'
              OR
              ((FoundOne >= 'KA' and FoundOne <= 'KN')
              or
              (FoundOne >= 'KP' and FoundOne <= 'KY'))
              OR
              ((%check('0123456789': FoundOne.Pos1: 1) = 0 OR
              FoundOne.Pos1 = 'M' or         // Matching
              FoundOne.Pos1 = 'H' or         // Halt
              FoundOne.Pos1 = 'U')           // User switch
              AND
              %check('0123456789': FoundOne.Pos2: 1) = 0);
              f_LoadMatrix(FoundOne);
 2e        endif;
 
 1x     else;  //used as index
           TestByte = %subst(IndExtract: 5: 1);
 2b        if %check('0123456789': TestByte) = 0;  //all numeric
 
 3b           if (%subst(IndExtract: 6: 1) = ')') or    //*in(9)
                 (%subst(IndExtract: 6: 1) = *blanks);  //or *in(9)
                 FoundOne = '0' + %subst(IndExtract: 5: 1);  //09
 3x           else;
                 FoundOne = %subst(IndExtract: 5: 2);  //whole number
 3e           endif;
 
 3b           if %check('0123456789': FoundOne) = 0;  //all numeric
                 f_LoadMatrix(FoundOne);
 3e           endif;
 2e        endif;
 1e     endif;
 
        return;
       end-proc;
 
       //---------------------------------------------------------
       // Returns screen Row number for passed indicator
       //---------------------------------------------------------
       dcl-proc f_GetRow;
        dcl-pi *n uns(3);
         p_Ind char(2) const;
        end-pi;
 
        dcl-s row uns(3);
 
        dcl-ds SplitIndDS qualified;
         pos1 char(1);
         pos2 char(1);
         pos2num zoned(1) overlay(pos2);
        end-ds;
 
        SplitIndDS = p_Ind;
 1b     if p_Ind < 'H1' or SplitIndDS.pos1 = ' ' or SplitIndDS.pos2 = ' ';
           row = 0;
 1x     elseif p_Ind = 'LR';
           row = 1;
 1x     elseif p_Ind = '1P';
           row = 2;
 1x     elseif p_Ind = 'RT';
           row = 3;
 
          // ie *in10 would go into row 1 ( 0 + 1)
          // *in11 would go into row 2 ( 1 + 1)  etc.
 1x     elseif SplitIndDS.pos2 >= '0'
           and SplitIndDS.pos2 <= '9';
           row = SplitIndDS.pos2num + 1;
 
          // process alpha. *INKA-*INKG maps same as OA-OG
 1x     elseif SplitIndDS.pos2 = 'A';
           row = 1;
 1x     elseif SplitIndDS.pos2 = 'B';
           row = 2;
 1x     elseif SplitIndDS.pos2 = 'C';
           row = 3;
 1x     elseif SplitIndDS.pos2 = 'D';
           row = 4;
 1x     elseif SplitIndDS.pos2 = 'E';
           row = 5;
 1x     elseif SplitIndDS.pos2 = 'F';
           row = 6;
 1x     elseif SplitIndDS.pos2 = 'G';
           row = 7;
 1x     elseif p_Ind = 'OV';
           row = 8;
          // process remaining *INKx indicators
 1x     elseif SplitIndDS.pos2 = 'H';
           row = 8;
 1x     elseif SplitIndDS.pos2 = 'I';
           row = 9;
 1x     elseif SplitIndDS.pos2 = 'J';
           row = 10;
 1x     elseif SplitIndDS.pos2 = 'K';
           row = 11;
 1x     elseif SplitIndDS.pos2 = 'L';
           row = 12;
 1x     elseif SplitIndDS.pos2 = 'M';
           row = 1;
 1x     elseif SplitIndDS.pos2 = 'N';
           row = 2;
 1x     elseif SplitIndDS.pos2 = 'P';
           row = 3;
 1x     elseif SplitIndDS.pos2 = 'Q';
           row = 4;
 1x     elseif SplitIndDS.pos2 = 'R';
           row = 5;
 1x     elseif SplitIndDS.pos2 = 'S';
           row = 6;
 1x     elseif SplitIndDS.pos2 = 'T';
           row = 7;
 1x     elseif SplitIndDS.pos2 = 'U';
           row = 8;
 1x     elseif SplitIndDS.pos2 = 'V';
           row = 9;
 1x     elseif SplitIndDS.pos2 = 'W';
           row = 10;
 1x     elseif SplitIndDS.pos2 = 'X';
           row = 11;
 1x     elseif SplitIndDS.pos2 = 'Y';
           row = 12;
 1e     endif;
        return row;
       end-proc;
 
       //---------------------------------------------------------
       // Returns location in Column for passed indicator
       //---------------------------------------------------------
       dcl-proc f_GetColumn;
        dcl-pi *n uns(3);
         p_Ind char(2) const;
        end-pi;
 
        dcl-s col uns(3);
        dcl-s pos1 char(1);
 
        pos1 = %subst(p_Ind: 1: 1);
 1b     if p_Ind = '1P'
           or p_Ind = 'RT'
           or p_Ind = 'LR';
           col = 18;
 1x     elseif pos1 = '0';
           col = 1;
 1x     elseif pos1 = '1';
           col = 2;
 1x     elseif pos1 = '2';
           col = 3;
 1x     elseif pos1 = '3';
           col = 4;
 1x     elseif pos1 = '4';
           col = 5;
 1x     elseif pos1 = '5';
           col = 6;
 1x     elseif pos1 = '6';
           col = 7;
 1x     elseif pos1 = '7';
           col = 8;
 1x     elseif pos1 = '8';
           col = 9;
 1x     elseif pos1 = '9';
           col = 10;
 1x     elseif pos1 = 'K';
 2b        if p_Ind < 'KM';
              col = 12;
 2x        else;
              col = 13;
 2e        endif;
 1x     elseif pos1 = 'L';
           col = 11;
 1x     elseif pos1 = 'O';
           col = 14;
 1x     elseif pos1 = 'M';
           col = 15;
 1x     elseif pos1 = 'U';
           col = 16;
 1x     elseif pos1 = 'H';
           col = 17;
 1e     endif;
        return col;
       end-proc;
