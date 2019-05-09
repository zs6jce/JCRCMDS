       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRPRTFR - Generate external print file from RPGLE Ospecs
       //---------------------------------------------------------
       /define ControlStatements
       /define FieldsArry
       /define Constants
       /define FieldsAttrDS
       /define f_BuildString
       /define f_BuildEditWord
       /define f_GetQual
       /define f_SndCompMsg
       /define f_SndEscapeMsg
       /define f_IsCompileTimeArray
       /define SrcDS
       /define p_JCRGETFLDR
       // *ENTRY
       /define p_JCRPRTFR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f RPGSRC disk(112) extfile(extifile) extmbr(p_rpgmbr) usropn;
 
       dcl-f DDSSRC disk(92) usage(*output) extfile(extofile) extmbr(p_ddsmbr)
       usropn;
       dcl-ds OutDS qualified inz;
        SrcSeq zoned(6:2) pos(1) inz(0);
        SrcDate zoned(6) pos(7) inz(0);
        SrcType char(1) pos(18);
        oAndOr char(1) pos(19);
        CommentLine char(73) pos(20);
        Indicator char(9) pos(20);
        FormatR char(1) pos(29);
        FormatName char(10) pos(31);
        Referenced char(1) pos(41);
        Length char(4) pos(43);
        DataType char(1) pos(47);
        DecimalPos char(1) pos(49);
        LinePosition char(3) pos(54);
        Keyword char(36) pos(57);
       end-ds;
 
       //---------------------------------------------------------
       dcl-s KeywordSkipa like(OutDS.Keyword);
       dcl-s KeywordSkipb like(OutDS.Keyword);
       dcl-s KeywordSpacea like(OutDS.Keyword);
       dcl-s KeywordSpaceb like(OutDS.Keyword);
       dcl-s LinePosSav like(OutDS.LinePosition);
       dcl-s oooFMT like(SrcDS.oConstant);
       dcl-s Commas char(1);
       dcl-s DDsSrcFile char(10);
       dcl-s DDsSrcLib char(10);
       dcl-s EditCodeArry char(1) dim(16) ctdata perrcd(1);
       dcl-s EditDataArry char(2) dim(16) alt(EditCodeArry);
       dcl-s Field char(15);
       dcl-s FloatDollar char(3) inz('''$''');
       dcl-s HaveFields char(27);
       dcl-s JustDidFmt char(27);
       dcl-s LastExceptName char(15);
       dcl-s LookupName char(15);
       dcl-s NegativeType char(1);
       dcl-s RpgSrcFile char(10);
       dcl-s RpgSrcLib char(10);
       dcl-s DimSizeA char(5);
       dcl-s WriteLine char(1);
       dcl-s vspos int(5);
       dcl-s vswork int(5);
       dcl-s DecimalPos zoned(1);
       dcl-s CommaRemainder uns(5);
       dcl-s CommaResult uns(5);
       dcl-s DetailLineCnt uns(5);
       dcl-s ExceptLineCnt uns(5);
       dcl-s HeaderLineCnt uns(5);
       dcl-s jj uns(5);
       dcl-s kk uns(5);
       dcl-s LenActual uns(5);
       dcl-s NewEndingPos uns(5);
       dcl-s pe uns(5);
       dcl-s ps uns(5);
       dcl-s pStart uns(5);
       dcl-s TotalLineCnt uns(5);
       dcl-s xd uns(5);
       dcl-s xx uns(5);
       dcl-s yy uns(5);
       dcl-s IsWrite ind;
       dcl-s PepCnt packed(3);
       dcl-s LineCount packed(6: 2) inz(0);
 
       //---------------------------------------------------------
       RpgSrcFile = %subst(p_RpgFileQual: 1: 10);
       RpgSrcLib = %subst(p_RpgFileQual: 11: 10);
       DDsSrcFile = %subst(p_DDsFileQual: 1: 10);
       DDsSrcLib = %subst(p_DDsFileQual: 11: 10);
       extIfile = f_GetQual(p_RpgFileQual);
       extOfile = f_GetQual(p_DDsFileQual);
 
       //---------------------------------------------------------
       // Get program field attributes
       // Load JCRCMDSSRV clipboard array with field names and attributes
       //---------------------------------------------------------
       callp p_JCRGETFLDR(
             p_RpgFileQual:
             p_RpgMbr:
             DiagSeverity:
             PepCnt);
 1b    if DiagSeverity > '20';
          f_SndEscapeMsg('*ERROR*  Diagnostic severity ' +
          DiagSeverity + '. Please check listing for errors.');
 1e    endif;
 
       //---------------------------------------------------------
       // open input file and output
       //---------------------------------------------------------
       open RPGSRC;
       open DDSSRC;
       read RPGSRC SrcDS;
 1b    dow not %eof;
 
 2b       if f_IsCompileTimeArray(SrcDS.CompileArray)
             or SrcDS.SpecType = 'P'      //procedure
             or SrcDS.SpecType = 'p';
 1v          leave;
 2e       endif;
 
 2b       if  SrcDS.Asterisk <> '/'     // Eject
             and (SrcDS.SpecType = 'O' or SrcDS.SpecType = 'o');
 
             // If comment lines, then translate over as is
 3b          if SrcDS.Asterisk = '*';  //COMMENT LINE
                OutDS.oAndOr = SrcDS.Asterisk;  //LOAD DS
                OutDS.CommentLine = SrcDS.Commentln;  //LOAD DS
                exsr srWriteSrcCode;
 3x          else;
                SrcDS.UpperCase = %xlate(lo: up: SrcDS.UpperCase);
 4b             if SrcDS.oLineType > *blanks   and //IPO LINES D,E,H
                   SrcDS.oAndOr <> 'OR'  and     //IPO LINES D,E,H
                   SrcDS.oAndOr <> 'AND';  //IPO LINES D,E,H
                   exsr srFormatLine;
 4x             else;  //FIELD/LITERAL
                   exsr srFieldLine;
 4e             endif;
 3e          endif;
 2e       endif;
 
          *in01 = *off;
          *in03 = *off;
          read RPGSRC SrcDS;
 1e    enddo;
       // all processed
       exsr srSpaceAfter;
       close RPGSRC;
       close DDSSRC;
       f_SndCompMsg('JCRPRTF for ' + %trimr(p_DDsMbr) + ' in ' +
       %trimr(extOfile) + ' - completed.');
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       // Generate record format code for either except lines
       // or when new line is coded in original RPG.
       //---------------------------------------------------------
       begsr srFormatLine;
       IsWrite = *on;
 
       // If previous record format had no printable fields
       // or constants defined, then generate space/skip
       // BEFORE code at record format level.
 1b    if HaveFields = 'Record Format had no fields';
          exsr srSpaceBefore;
 1e    endif;
       exsr srSpaceAfter;
 
 1b    if SrcDS.oLineType = 'E';  //EXCPT
 2b       if SrcDS.oEname > *blanks
             and SrcDS.oEname = LastExceptName;  //SAME NAMED LINE
             IsWrite = *off;
 2x       else;
 3b          if SrcDS.oEname = *blanks;
                ExceptLineCnt += 1;
                SrcDS.oEname = %trimr('EXP') +
                %triml(%editc(ExceptLineCnt:'3'));
 3e          endif;
 
             OutDS.FormatName = SrcDS.oEname;
             LastExceptName = SrcDS.oEname;
 2e       endif;
 
 1x    elseif SrcDS.oLineType = 'H';  //HEADER LINE
          HeaderLineCnt += 1;  //HEADER LINE CNT
          OutDS.FormatName = %trimr('HDR') +
          %triml(%editc(HeaderLineCnt:'3'));
          LastExceptName = *blanks;
 
 1x    elseif SrcDS.oLineType = 'D';  //DETAIL
          DetailLineCnt += 1;
          OutDS.FormatName = %trimr('DTL') +
          %triml(%editc(DetailLineCnt:'3'));
          LastExceptName = *blanks;
 
 1x    elseif SrcDS.oLineType = 'T';  //TOTAL
          TotalLineCnt += 1;
          OutDS.FormatName = %trimr('TOT') +
          %triml(%editc(TotalLineCnt:'3'));
          LastExceptName = *blanks;
 1e    endif;
 
 1b    if IsWrite;
          OutDS.FormatR = 'R';
          exsr srWriteSrcCode;
 1e    endif;
 
       //---------------------------------------------------------
       // Space or Skip before must after first field
       // (or constant) defined after record format record.
       // They are saved for after first field in rcdfmt.
       //---------------------------------------------------------
 1b    if SrcDS.oSpaceB > ' ';  //SPACE BEFORE
          KeywordSpaceb = %trimr('SPACEB(') + SrcDS.oSpaceB+')';
 1e    endif;
 1b    if SrcDS.oSkipB > ' ';  //SKIP BEFORE
          KeywordSkipb = %trimr('SKIPB(') + SrcDS.oSkipB + ')';
 1e    endif;
 
       //---------------------------------------------------------
       // Space or Skip after must go at end of each group.
       // Checked at beginning of each record format.
       //---------------------------------------------------------
 1b    if SrcDS.oSpaceA > ' ';  //SPACE AFTER
          KeywordSpacea = %trimr('SPACEA(') + SrcDS.oSpaceA+')';
 1e    endif;
 
 1b    if SrcDS.oSkipA > ' ';  //SKIP AFTER
          KeywordSkipa = %trimr('SKIPA(') + SrcDS.oSkipA+')';
 1e    endif;
 
       vspos = 0;
       HaveFields = 'Record Format had no fields';
       JustDidFmt = 'Just did record format';
       endsr;
 
       //---------------------------------------------------------
       // Generate Skip or Space before DDs code
       //---------------------------------------------------------
       begsr srSpaceBefore;
 1b    if KeywordSpaceb > *blanks;  //SPACE BEFORE
          OutDS.Keyword = KeywordSpaceb;
          exsr srWriteSrcCode;
 1e    endif;
 
 1b    if KeywordSkipb > *blanks;  //SKIP BEFORE
          OutDS.Keyword = KeywordSkipb;
          exsr srWriteSrcCode;
 1e    endif;
 
       KeywordSpaceb = *blanks;
       KeywordSkipb = *blanks;
       endsr;
 
       //---------------------------------------------------------
       // Generate Skip or Space after DDs code
       //---------------------------------------------------------
       begsr srSpaceAfter;
 1b    if KeywordSpacea > *blanks;  //SPACE AFTER
          OutDS.Keyword = KeywordSpacea;
          exsr srWriteSrcCode;
 1e    endif;
 
 1b    if KeywordSkipa > *blanks;  //SKIP AFTER
          OutDS.Keyword = KeywordSkipa;
          exsr srWriteSrcCode;
 1e    endif;
 
       KeywordSpacea = *blanks;
       KeywordSkipa = *blanks;
       endsr;
 
       //---------------------------------------------------------
       // Determine whether field name or constant is to be loaded
       //---------------------------------------------------------
       begsr srFieldLine;  //IPP SPECS
       LenActual = 0;
       HaveFields = 'Record Format has fields';
 
 1b    if SrcDS.oEname > *blanks;  //FIELD NAMES
          WriteLine = 'N';  //SET TO NO
 
          Field = SrcDS.oEname;
 
          // There could be indexed array name as output field.
          // Do lookup with array name to get attributes
          LookupName = SrcDS.oEname;
          aa = %scan('(': LookupName: 1);
 2b       if aa <> 0;
             LookupName = %subst(LookupName: 1: aa - 1);
 2e       endif;
          aa = %lookup(LookupName: FieldsArry(*).Name: 1: FieldsArryCnt);
 2b       if aa > 0;
             FieldsAttrDS = FieldsArry(aa).Attr;
 3b          if FieldsAttrDS.DecimalPos = *blanks;
                DecimalPos = 0;
 3x          else;
                DecimalPos = FieldsAttrDS.DecimalPosN;
 3e          endif;
             OutDS.FormatName = SrcDS.oEname;
 
             //---------------------------------------------------------
             // Back to array fun!  It could be that
             // that un-indexed array name was on a O spec.
             // JCRGETFLDR program loads array definitions
             // in two parts.  Multiply element length by num elements.
             //---------------------------------------------------------
             ps = %scan('DIM(': FieldsAttrDS.Text: 1);
 3b          if ps <> 0                    //start of DIM(
                and LookupName = SrcDS.oEname;  //not indexed
                pe = %scan(')': FieldsAttrDS.Text: ps);
 
 4b             if pe <> 0;  //end of )
                   xd = (pe - 1) - 4;
                   pStart = 6 - xd;
                   DimSizeA = *blanks;
                   %subst(dimsizea: pStart: xd) =
                   %subst(FieldsAttrDS.Text: 5: xd);
 5b                if DimSizeA = *blanks;
                      DimSizeA = '00000';
 5e                endif;
                   FieldsAttrDS.Length = FieldsAttrDS.Length * %uns(DimSizeA);
 4e             endif;
 3e          endif;
             OutDS.Indicator = SrcDS.oIndicator;
 
             //---------------------------------------------------------
             // If field was defined via external file definition and
             // user specified that field references are to be used,
             // use REFFLD keyword, otherwise hardcode actual field attributes.
             //---------------------------------------------------------
 3b          if FieldsAttrDS.FromFile <> ' ' and  //INTERNALLY DESC
                p_RefFields = '*YES';  //USE REFERENCES
                OutDS.Referenced = 'R';
 
                OutDS.Keyword = 'REFFLD(' + %trimr(OutDS.FormatName) +
                ' *LIBL/' + %trimr(FieldsAttrDS.FromFile) + ')';
 3x          else;
                // Hard code fields that are not referenced
 4b             if FieldsAttrDS.DataType = 'A';
                   evalr OutDS.Length = %editc(FieldsAttrDS.Length:'4');
                   clear OutDS.DataType;
                   clear OutDS.DecimalPos;
 
 4x             elseif FieldsAttrDS.DataType = 'D'
                   or FieldsAttrDS.DataType = 'T'
                   or FieldsAttrDS.DataType = 'Z';
                   clear OutDS.Length;
 5b                if FieldsAttrDS.DataType = 'D';
                      OutDS.DataType = 'L';
 5x                else;
                      OutDS.DataType = FieldsAttrDS.DataType;
 5e                endif;
                   clear OutDS.DecimalPos;
 4x             else;
                   evalr OutDS.Length = %editc(FieldsAttrDS.Length:'4');
                   clear OutDS.DataType;
                   OutDS.DecimalPos = %editc(DecimalPos:'3');
 4e             endif;
                WriteLine = 'Y';
 3e          endif;
 2e       endif;
 
          // Calculate starting Position of either field or constant
          LenActual = FieldsAttrDS.Length;
 2b       if SrcDS.oEditCode > ' ';
             exsr srAllowForEditCode;
 2x       elseif SrcDS.oConstant > *blanks;  //GET CONST LENGT
 3b          if FieldsAttrDS.DataType = 'D'
                or FieldsAttrDS.DataType = 'T'
                or FieldsAttrDS.DataType = 'Z';
                exsr srMakeLikeAnEditWord;
 3e          endif;
 
             kk = %checkr(' ': SrcDS.oConstant);
             LenActual = kk - 2;  //CALC LENGTH
 2e       endif;
          exsr srBlankOrPlusSign;
          vswork = vswork - LenActual;
          vswork += 1;
          evalr OutDS.LinePosition = %editc(vswork:'4');
 
          // Handle exception of UDATE.  Entire line is cleared and
          // starting Position and new DATE keyword are written.
 2b       if OutDS.FormatName = 'UDATE';
             LinePosSav = OutDS.LinePosition;
             WriteLine = 'N';
             clear OutDS;
             OutDS.LinePosition = LinePosSav;
             OutDS.Keyword = 'DATE';
 2e       endif;
 
 2b       if WriteLine <> 'Y';
             exsr srWriteSrcCode;
 2e       endif;
 
          // If floating dollar sign, include in EDTCDE keyword)
 2b       if SrcDS.oEditCode > ' ';
             OutDS.Keyword = 'EDTCDE(' + SrcDS.oEditCode + ')';
 3b          if SrcDS.oConstant = FloatDollar;
                OutDS.Keyword = 'EDTCDE(' + SrcDS.oEditCode + ' $)';
 3e          endif;
             exsr srWriteSrcCode;
             clear WriteLine;
 
 2x       elseif SrcDS.oConstant > *blanks;  //EDTWRD SPECIFID
 3b          if FieldsAttrDS.DataType = 'D'
                or FieldsAttrDS.DataType = 'T'
                or FieldsAttrDS.DataType = 'Z';
                OutDS.Keyword = oooFMT;
 3x          else;
                OutDS.Keyword = 'EDTWRD(' + %trimr(SrcDS.oConstant) + ')';
 3e          endif;
             exsr srWriteSrcCode;
             clear WriteLine;
 2e       endif;
 
 2b       if WriteLine = 'Y';
             exsr srWriteSrcCode;
 2e       endif;
 
 1x    elseif SrcDS.oConstant > *blanks;  //CONSTANTS
          jj = %checkr(' ': SrcDS.oConstant);
          OutDS.Indicator = SrcDS.oIndicator;
          exsr srBlankOrPlusSign;
          vswork -= jj;
          vswork += 3;
          evalr OutDS.LinePosition = %editc(vswork:'4');  //LOAD FLD LENGTH
          OutDS.Keyword = SrcDS.oConstant;  //LOAD CONSTANT
          exsr srWriteSrcCode;
 1e    endif;
 
 1b    if JustDidFmt = 'Just did record format';
          exsr srSpaceBefore;
          JustDidFmt = 'Not';
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // If ending Position is blank, load +0 and let
       // the calc ending subroutine handle it.  If there
       //  is + sign in end position, then calc ending pos.
       //---------------------------------------------------------
       begsr srBlankOrPlusSign;
 1b    if SrcDS.oEndPos = *blanks;
          SrcDS.oEndPos = '   +0';
 1e    endif;
       bb = %scan('+': SrcDS.oEndPos: 1);
 1b    if bb <> 0;
 
          //load zeros into any spaces between + and value, ie +   1 = +0001
 2b       for yy = bb to 5;
 3b          if %subst(SrcDS.oEndPos: yy: 1) = ' ';
                %subst(SrcDS.oEndPos: yy: 1) = '0';
 3e          endif;
 2e       endfor;
 
          // Calculate ending positions
          yy = 2;
          xx = 0;
 2b       if SrcDS.oEname <> ' '
             and %subst(SrcDS.oConstant: 1: 1) <> ' '
             and SrcDS.oConstant <> FloatDollar;
 3b          dow %subst(SrcDS.oConstant: yy: 1) <> '''';
                xx += 1;
                yy += 1;
 3e          enddo;
 
 2x       elseif SrcDS.oEname = ' '
             and %subst(SrcDS.oConstant: 1: 1) <> ' ';
 3b          dow yy < 29
                and %subst(SrcDS.oConstant: yy: 1) <> '''';
                xx += 1;
                yy += 1;
 3e          enddo;
 2e       endif;
          NewEndingPos = vspos + %uns(%subst(SrcDS.oEndPos: bb + 1)) + xx;
 
 2b       if xx = 0;  //no edit word
             NewEndingPos += LenActual;
 2e       endif;
          SrcDS.oEndPosN = NewEndingPos;
 1e    endif;
 
       vspos = SrcDS.oEndPosN;
       vswork = vspos;
       endsr;
 
       //---------------------------------------------------------
       // New to O specs is ability to format date, time and and timestamp fields.
       // Build an edit word based on type field and formatting settings.
       //---------------------------------------------------------
       begsr srMakeLikeAnEditWord;
       clear oooFMT;
 1b    if FieldsAttrDS.DataType = 'Z';
 1x    else;
          SrcDS.oConstant = %xlate(lo: up: SrcDS.oConstant);
 
 2b       if FieldsAttrDS.DataType = 'T';
             oooFMT = 'TIMFMT(' + %trimr(SrcDS.oConstant) + ')';
 
 2x       elseif FieldsAttrDS.DataType = 'D';
             oooFMT = 'DATFMT(' + %trimr(SrcDS.oConstant) + ')';
 2e       endif;
 1e    endif;
       SrcDS.oConstant =
       f_BuildEditWord(SrcDS.oConstant: FieldsAttrDS.DataType);
       endsr;
 
       //---------------------------------------------------------
       // Allow for effects of edit codes on overall field length
       //---------------------------------------------------------
       begsr srAllowForEditCode;
 1b    if SrcDS.oEditCode = 'Y';
 2b       if FieldsAttrDS.Length = 3
             or FieldsAttrDS.Length = 4;
             LenActual += 1;
 2x       elseif FieldsAttrDS.Length >= 5
             and FieldsAttrDS.Length <= 9;
             LenActual += 2;
 2e       endif;
 1x    else;
          jj = %lookup(SrcDS.oEditCode: EditCodeArry: 1);
 2b       if jj > 0;
             Commas = %subst(EditDataArry(jj): 1: 1);  //USE COMMAS?
             NegativeType = %subst(EditDataArry(jj): 2: 1);  //WHAT TYPE NEG
 
 3b          if SrcDS.oConstant = FloatDollar;  //FLOATING $
                LenActual += 1;
 3e          endif;
 
 3b          if DecimalPos > 0;  //ADJUST FOR DEC
                LenActual += 1;
 3e          endif;
 
 3b          if NegativeType = '-';  //MINUS SIGN
                LenActual += 1;
 3x          elseif NegativeType = 'C';  //CR SIGN
                LenActual += 2;
 3e          endif;
 
 3b          if Commas = 'Y';  //ALLOW FOR COMMA
                CommaResult = FieldsAttrDS.Length - DecimalPos;
                CommaResult = %div(CommaResult: 3);  //HOW MANY COMMAS
                CommaRemainder = %rem(CommaResult: 3);  //HOW MANY COMMAS
 
 4b             if CommaRemainder = 0 and CommaResult > 0;  //EVENLY DIVIDED
                   CommaResult -= 1;
 4e             endif;
                LenActual += CommaResult;
 3e          endif;
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Write records to DDS member
       begsr srWriteSrcCode;
       OutDS.SrcType = 'A';
       linecount += .01;
       OutDS.SrcSeq = linecount;
       write ddssrc OutDS;
       clear OutDS;
       endsr;
 
      *EDIT CODE  COMMAS (Y/N)  TYPE SIGN(None,Cr,or -)
**
1YN             1
2YN             2
3NN             3
4NN             4
AYC             5
BYC             6
CNC             7
DNC             8
JY-             9
KY-            10
LN-            11
MN-            12
NY-            13
OY-            14
PN-            15
QN-            16
