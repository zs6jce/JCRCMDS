       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRNUMBR - Number logic structures in RPGLE source
       //  Updates RPGLE fixed or free source code with structured programming operation
       //  statements in left margin of source.
       //    generate end matching in same text case as end opcode.
       //     free source code reformat based on logic structures.
       //      strip comment line colors
       //       skip continuation lines that begin with an opcode.
       //
       //  Added indent V7 free DCL- codes.
       //  Nested DCLs are indented one space, independent of mainline reformatting.
       //  11/07/17 JSB Added Upper case conversion to check for SQL Statements.
       //---------------------------------------------------------
       /define ControlStatements
       /define Constants
       /define f_GetQual
       /define f_IsValidSrcType
       /define f_SndCompMsg
       /define f_IsIgnoreLine
       /define f_CheckSameLineEnd
       /define f_IsCompileTimeArray
       /define f_SndEscapeMsg
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f RPGSRC disk(112) usage(*update)
       extfile(extIfile) extmbr(p_SrcMbr) usropn;
       dcl-ds SrcDS qualified inz;
        SeqNo char(4) pos(1);
        SeqDec char(2) pos(5);
        CompileArray char(3) pos(13);
        SpecType char(1) pos(18);
        Asterisk char(1) pos(19);
        SlashComment char(2) pos(19);
        SlashEject char(6) pos(19);
        OpCode char(10) pos(38);
        Src18 char(18) pos(1);
        Src94 char(94) pos(19);
       end-ds;
 
       dcl-s WrkA like(opcodeds);
       dcl-s WrkUP like(opcodeds);
       dcl-s FirstDigitOpc char(1);
       dcl-s p_SrcFil char(10);
       dcl-s p_SrcLib char(10);
       dcl-s op char(3) dim(100);
       dcl-s SecondDigitOpc char(1);
       dcl-s StructNumb char(4);
       dcl-s TypeOutput char(13);
       dcl-s WBlanks varchar(94);
       dcl-s WrkB char(188);
       dcl-s WrkB2 char(188);
       dcl-s ado int(5) dim(100);
       dcl-s dd int(5);
       dcl-s ee int(5);
       dcl-s EndOfCode uns(3);
       dcl-s pp uns(3);
       dcl-s q1 uns(3);
       dcl-s q2 uns(3);
       dcl-s StartOfComment uns(3);
       dcl-s ww uns(3);
       dcl-s IsCalcSpec ind;
       dcl-s IsCallp ind;
       dcl-s IsCasxx ind;
       dcl-s IsContinuation ind;
       dcl-s IsCSR ind;
       dcl-s IsEndCheat ind;
       dcl-s IsFree ind;
       dcl-s IsFunction ind;
       dcl-s IsInsideCalcs ind;
       dcl-s IsSqlExec ind;
       dcl-s string varchar(94);
       dcl-s SelectDepth ind dim(100);
       dcl-c WhiteHex const(x'22');
       dcl-s IndentLvl uns(3) inz(0);
       dcl-s ApostropheCnt uns(10) inz(0);
       dcl-s aCheck varchar(74);
       dcl-s DoNotIndentMinus ind;
       dcl-s IsComment ind;
       dcl-s SubRoutine char(2);
       dcl-ds SrcUpdateDS len(112) end-ds;
 
       dcl-ds OpCodeDS len(10) inz qualified;
        One char(1) pos(1);
        Two char(2) pos(1);
        Three char(3) pos(1);
        Four char(4) pos(1);
        Six char(6) pos(1);
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_SrcMbr char(10);
        p_SrcFilQual char(20);
        p_HighLight char(4);
        p_EndLabel char(4);
        p_Indentfree char(4);
        p_Indentspace packed(1);
        p_BlankEjects char(4);
        p_CallingCmd char(10);
       end-pi;
       //---------------------------------------------------------
 
 1b    if not f_IsValidSrcType(p_SrcFilQual: p_SrcMbr:'RPGLE':'SQLRPGLE');
          f_SndEscapeMsg('Member ' + %trimr(p_SrcMbr) +
          ' is not type RPGLE or SQLRPGLE.');
          *inlr = *on;
          return;
 1e    endif;
 
       extIfile = f_GetQual(p_SrcFilQual);
       p_SrcFil = %subst(p_SrcFilQual: 1: 10);
       p_SrcLib = %subst(p_SrcFilQual: 11: 10);
 
       open RPGSRC;
       read RPGSRC SrcDS;
 1b    dow not %eof;
          // do not process compile time arrays
 2b       if f_IsCompileTimeArray(srcds.CompileArray);
 1v          leave;
 2e       endif;
          SubRoutine = srcds.SlashComment;
          OpCodeDS = srcds.Opcode;
 
          IsComment = *off;
          IsCalcSpec = *off;
          IsFree = *off;
          srcds.Src18 = f_RemoveHexColorCodes(srcds.Src18:18);
          srcds.Src94 = f_RemoveHexColorCodes(srcds.Src94:94);
 
          string = %trimr(srcds.Src94);
          string = %xlate(lo: up: string);
 2b       if f_IsIgnoreLine(string);
             IsComment = *on;
             TypeOutput = 'COMMENT-';
 
 3b          if srcds.SlashComment = '//'
                or srcds.Asterisk = '*';
                exsr srFormatOutput;
 
 3x          elseif  srcds.Asterisk <> '/';
                exsr srIndentFree;
                exsr srFormatOutput;
 
 3x          elseif p_BlankEjects = '*YES'
                and srcds.Asterisk = '/'
                and (%xlate(lo:up:srcds.SlashEject) = '/EJECT'
                or %xlate(lo:up:srcds.SlashEject) = '/SPACE');
                TypeOutput = '/EJECT';
                exsr srFormatOutput;
 3e          endif;
 
             //--------------------------------------------------------
             // spin through until I get into C specs proper.
             // if C or c or /free, then inside C specs.
             //--------------------------------------------------------
 2x       elseif srcds.SpecType = 'C'
             or srcds.SpecType = 'c';
             IsCalcSpec = *on;
 
 2x       elseif srcds.SpecType = 'O'
             or srcds.SpecType = 'o'
             or srcds.SpecType = 'D'
             or srcds.SpecType = 'd'
             or srcds.SpecType = 'F'
             or srcds.SpecType = 'f'
             or srcds.SpecType = 'P'
             or srcds.SpecType = 'p'
             or srcds.SpecType = 'I'
             or srcds.SpecType = 'i';
             IsCalcSpec = *off;
 
 2x       else;
             //--------------------------------------------
             // if a free statements ends in - and
             // is between quotes, do not indent!
             //--------------------------------------------
             aCheck = %trimr(%subst(srcds.Src94:1:74));
 3b          for aa = 1 to %len(aCheck);
 4b             if %subst(aCheck:aa:1) = qs;
                   ApostropheCnt += 1;
 4e             endif;
 3e          endfor;
 
 3b          if %rem(ApostropheCnt: 2) <> 0
                and %len(acheck) > 0
                and %subst(acheck: %len(acheck): 1) = '-';
                DoNotIndentMinus = *on;
 3e          endif;
 
 3b          if DoNotIndentMinus = *on;
                IsFree = *off;
                IsCalcSpec = *off;
 3x          else;
                IsFree = *on;
                IsCalcSpec = *on;
 3e          endif;
 
 3b          if %rem(ApostropheCnt: 2) = 0;
                DoNotIndentMinus = *off;
 3e          endif;
 2e       endif;
 
          //---------------------------------------------------------
 2b       if IsCalcSpec
             and (not IsComment);
             IsCSR = *off;  //SR remove
             IsInsideCalcs = *on;
 
 3b          if srcds.Asterisk = '/' //skip SQL stuff
                or srcds.Asterisk = '+';
                TypeOutput = 'CLEAR';
                exsr srFormatOutput;
 3x          else;
                //---------------------------------------------------------
                // For /free code, extract opcode into OpcodeDS field.
                // Look for first ' ' and first ';'  , then the one not
                // zero and lowest value is end of opcode.
                //---------------------------------------------------------
 4b             if IsFree
                   and srcds.Src94 > *blanks;
                   WrkA = %triml(srcds.Src94);
                   clear OpcodeDS;
 
 5b                if not IsContinuation;
                      aa = %scan(' ': WrkA: 1);
                      bb = %scan(';': WrkA: 1);
 6b                   if aa > 0 and (aa < bb or bb = 0);
                         OpcodeDS = %subst(WrkA: 1: aa - 1);
 6x                   elseif bb > 0 and (bb < aa or aa = 0);
                         OpcodeDS = %subst(WrkA: 1: bb - 1);
 6e                   endif;
 5e                endif;
 
                   //---------------------------------------------------------
                   // I must be careful if previous line of
                   // code ended in continuation character + or -.
                   // if that is case, blank out opcode so
                   // program is not fooled into thinking a constant
                   // is a valid opcode.
                   // example:    if A = 'a +
                   //               if b';
                   // The second If is not really opcode!
                   //---------------------------------------------------------
                   IsContinuation = *off;
                   aa = %len(string);
 5b                if aa > 0;
 6b                   if %subst(string: aa: 1) = '+'
                         or %subst(string: aa: 1) = '-';
                         IsContinuation = *on;
 6e                   endif;
 5e                endif;
 4e             endif;
 
                //---------------------------------------------------------
                // save case of opcode for matching ends
                //---------------------------------------------------------
                FirstDigitOpc = %subst(OpcodeDS: 1: 1);
                SecondDigitOpc = %subst(OpcodeDS: 2: 1);
                OpcodeDS = %xlate(lo: up: OpcodeDS);
 
                // bad person had field named END in their free code
                // ENDblank is valid in fixed column, but not in free
 4b             if IsFree and OpCodeDS = 'END';
                   OpCodeDS = *blanks;
 4e             endif;
 
                //---------------------------------------------------------
                // do not format SQL statements
                //  Ignore everything between EXEC and terminating;
                //---------------------------------------------------------
                WrkUP = %xlate(lo:up:OpcodeDS);
 4b             if WrkUP = 'EXEC';
                   IsSqlExec = *on;
 4e             endif;
 
 4b             if not IsFree;
                   SubRoutine = %xlate(lo: up: SubRoutine);
                   IsCSR = (SubRoutine = 'SR');
 4e             endif;
 
 4b             if not IsSqlExec;
                   TypeOutput = 'CALC LINE';
                   // Load xB for IF and SELECT opcodes
 5b                if (OpcodeDS.Two = 'IF' and (not IsFree))
                      or (OpcodeDS = 'IF' and IsFree)
                      or (OpcodeDS.Three = 'IF(' and IsFree);
                      exsr srLoadBeginB;
 
 5x                elseif (OpcodeDS = 'SELECT');
                      exsr srLoadBeginB;
                      SelectDepth(cc) = *on;
 
                      //---------------------------------------------------------
                      // save most recent 'DO'/FOR number for use as indent notation
                      // on iter and leave operations.  Number is saved into array
                      // whose element position is how many dos and element
                      // value represents number of that do.
                      //---------------------------------------------------------
 5x                elseif (OpcodeDS.Two = 'DO' and (not IsFree))
                      or (OpcodeDS = 'DO' and IsFree)
                      or (OpcodeDS = 'DOU' and IsFree)
                      or (OpcodeDS = 'DOW' and IsFree)
                      or OpcodeDS = 'MONITOR'
                      or OpcodeDS = 'FOR'
                      or OpcodeDS.Four = 'FOR(';
                      exsr srLoadBeginB;
                      dd += 1;
                      ado(dd) = cc;
 
                      //---------------------------------------------------------
                      // CASxx opcodes.  Trick is there could be several
                      // cas opcodes in row and only first each group is
                      // used to trigger record update.
                      // IsCasxx is setof when end is found.
                      //---------------------------------------------------------
 5x                elseif OpcodeDS.Three = 'CAS'
                      and (not IsCasxx)
                      and (not IsFree);
                      exsr srLoadBeginB;
                      IsCasxx = *on;
 
                      //---------------------------------------------------------
                      // process else, wh, & other op codes.  Update record
                      // and count remains same.
                      //---------------------------------------------------------
 5x                elseif OpcodeDS = 'GOTO'
                      and (not IsFree);
                      StructNumb = 'GO';
                      exsr srFormatOutput;
 
                      //---------------------------------------------------------
                      // flag LEAVESR for easy viewing
                      //---------------------------------------------------------
 5x                elseif OpcodeDS = 'LEAVESR';
                      StructNumb = 'LV';
 6b                   if p_Indentfree = '*YES' and IsFree;
                         exsr srIndentFree;
 6e                   endif;
                      exsr srFormatOutput;
 
                      //---------------------------------------------------------
                      // process else, wh, & other op codes.  Update
                      //  record and count remains same.
                      //---------------------------------------------------------
 5x                elseif (OpcodeDS.Two = 'WH' and (not IsFree))
                      or OpcodeDS = 'OTHER'
                      or OpcodeDS = 'ELSE'
                      or OpcodeDS = 'ELSEIF'
                      or OpcodeDS = 'ON-ERROR'
                      or OpcodeDS = 'WHEN';
                      StructNumb = %char(cc) + 'x';
 6b                   if p_Indentfree = '*YES' and IsFree;
                         IsEndCheat = *on;
                         exsr srIndentFree;
                         IsEndCheat = *off;
 6e                   endif;
                      exsr srFormatOutput;
 
                      //---------------------------------------------------------
                      // process iter Opcode.  i is moved into code
                      //  and record is updated using innermost
                      // do count depth save array.
                      //---------------------------------------------------------
 5x                elseif OpcodeDS = 'ITER';
 
 6b                   if dd > 0;
                         StructNumb = %char(ado(dd)) + 'i';
 6x                   else;
                         StructNumb = '00';
 6e                   endif;
 
 6b                   if p_Indentfree = '*YES' and IsFree;
                         exsr srIndentFree;
 6e                   endif;
 
                      exsr srFormatOutput;
 
                      //---------------------------------------------------------
                      // process leave opcode.  Load V into code and
                      // record is updated using innermost do count from do
                      // depth save array.
                      //---------------------------------------------------------
 5x                elseif OpcodeDS = 'LEAVE';
 
 6b                   if dd > 0;
                         StructNumb = %char(ado(dd)) + 'v';
 6x                   else;
                         StructNumb = '00';
 6e                   endif;
 
 6b                   if p_Indentfree = '*YES' and IsFree;
                         exsr srIndentFree;
 6e                   endif;
                      exsr srFormatOutput;
 
                      //---------------------------------------------------------
                      // process endxx.  E is moved into code and record
                      // is updated. depth has 1 subtracted after update.
                      //---------------------------------------------------------
 5x                elseif OpcodeDS <> 'ENDSR'
                      and ((OpcodeDS.Three = 'END' and (not IsFree))
                      or OpcodeDS = 'END'
                      or OpcodeDS = 'ENDSL'
                      or OpcodeDS = 'ENDIF'
                      or OpcodeDS = 'ENDDO'
                      or OpcodeDS = 'ENDMON'
                      or OpcodeDS = 'ENDFOR');
                      IsCasxx = *off;
                      StructNumb = %char(cc) + 'e';
 
                      //---------------------------------------------------------
                      // if cc = 0 then there are too many END opcodes.
                      // Send message with error statement number.
                      //---------------------------------------------------------
 6b                   if cc <= 0;
                         close RPGSRC;
                         f_SndCompMsg('WARNING: Unmatched ENDxx Opcode at ' +
                         srcds.SeqNo + '.' +
                         srcds.SeqDec + ' - JCRNUMB canceled!');
                         *inlr = *on;
                         return;
 6e                   endif;
 
                      //---------------------------------------------------------
                      // match proper endxx to opcode that started the
                      // structure.  ie. if/endif , do/enddo
                      // If END is free format, is required to have proper endXX suffix.
                      //---------------------------------------------------------
 6b                   if p_EndLabel = '*YES';
 7b                      if op(cc) = 'SE';
                            OpcodeDS = 'endsl';
 7x                      elseif op(cc) = 'CA';
                            OpcodeDS = 'endcs';
 7x                      else;
                            OpcodeDS = 'end' + op(cc);
 7e                      endif;
 
                         //---------------------------------------------------------
                         // Determine text case of end opcode.  Write out
                         // matching ENDxx in same case as it was before.
                         //---------------------------------------------------------
 7b                      if %scan(FirstDigitOpc: up) = 0;
                            OpcodeDS = %xlate(up: lo: OpcodeDS);
 7x                      elseif %scan(SecondDigitOpc: up) > 0;
                            OpcodeDS = %xlate(lo: up: OpcodeDS);
 7x                      else;
                            OpcodeDS = %xlate(up: lo: OpcodeDS);
                            OpcodeDS.One = %xlate(lo: up: OpcodeDS.One);
 7e                      endif;
 
 7b                      if not IsFree;
                            TypeOutput = 'ENDXX';
                            exsr srFormatOutput;
 7x                      else;
                            //---------------------------------------------------------
                            // determine size of existing end statement, then use %replace
                            //---------------------------------------------------------
                            aa = %scan('END': string);
                            bb = %scan(';': srcds.Src94: aa);
 
                            //---------------------------------------------------------
                            // if bb = 0 then there is 'END' statement
                            // coded that does not terminate with semi-colon.
                            //---------------------------------------------------------
 8b                         if bb = 0;
                               close RPGSRC;
                               f_SndCompMsg(
                               'WARNING: Unterminated ENDxx opcode at ' +
                               srcds.SeqNo + '.' + srcds.SeqDec +
                               ' - JCRNUMB canceled!');
                               *inlr = *on;
                               return;
 8e                         endif;
 
                            srcds.Src94 = %replace(%trimr(OpcodeDS) + ';':
                            srcds.Src94: aa: (bb - aa) + 1);
 8b                         if p_Indentfree = '*YES';
                               IsEndCheat = *on;
                               exsr srIndentFree;
                               IsEndCheat = *off;
 8e                         endif;
                            exsr srFormatOutput;
 7e                      endif;
 6e                   endif;
 
                      //---------------------------------------------------------
                      // if END is for innermost do, then clear that
                      // element of do number array.
                      //---------------------------------------------------------
 6b                   if (dd > 0) and (ado(dd) = cc);
                         ado(dd) = 0;
                         dd -= 1;
 6e                   endif;
                      cc -= 1;
                      ee -= 1;
 6b                   if cc > 0;
                         SelectDepth(cc) = *off;
 6e                   endif;
 5x                else;
                      //---------------------------------------------------------
                      // if none of above conditions are met, the excpt
                      // clears record from whatever may have been there before.
                      //---------------------------------------------------------
 6b                   if p_Indentfree = '*YES' and IsFree;
                         exsr srIndentFree;
 6e                   endif;
                      TypeOutput = 'CLEAR';
                      exsr srFormatOutput;
 5e                endif;
 4e             endif;
 
                // look for line terminating in semi-colon
 4b             if IsSqlExec;
                   IsSqlExec = (%scan(';': srcds.Src94: 1) = 0);
                   TypeOutput = 'CLEAR';
                   exsr srFormatOutput;
 4e             endif;
 3e          endif;
 2e       endif;
          read RPGSRC SrcDS;
 1e    enddo;
       close RPGSRC;
 
       // Completion message was overlaying JCR4MAX messages,
       //  so only send completion message if JCRNUMB command is running
 1b    if p_CallingCmd = 'JCRNUMB ';
 
          // send message if unmatched ENDXX codes
 2b       if cc > 0;
             f_SndCompMsg('WARNING: ' + %triml(%editc(cc:'4')) +
             ' ENDxx opcodes are missing. - JCRNUMB canceled!');
 2x       else;
             f_SndCompMsg('JCRNUMB for ' + %trimr(p_SrcMbr) + ' in ' +
             %trimr(extIfile) + ' - completed');
 2e       endif;
 1e    endif;
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       // Format output depending on line type;
       //---------------------------------------------------------
       begsr srFormatOutput;
       SrcUpdateDS = srcds.Src18 + srcds.Src94;
       %subst(SrcUpdateDS: 13: 1) = ' ';  //remove color
 
 1b    if TypeOutput = 'CALC LINE';
 2b       if IsCSR;
             %subst(SrcUpdateDS: 19: 2) = *blanks;
 2e       endif;
          %subst(SrcUpdateDS: 14: 4) = StructNumb;
 
          //---------------------------------------------------------
 1x    elseif TypeOutput = 'COMMENT-';
          %subst(SrcUpdateDS: 13: 6) = *blanks;
 2b       if p_HighLight = '*YES';
             %subst(SrcUpdateDS: 16: 1) = WhiteHex;
 2x       else;
             %subst(SrcUpdateDS: 16: 1) = ' ';
 2e       endif;
 
          //---------------------------------------------------------
 1x    elseif TypeOutput = 'CLEAR';
 2b       if IsInsideCalcs;
             %subst(SrcUpdateDS: 13: 5) = *blanks;
 2e       endif;
 2b       if IsCSR;
             %subst(SrcUpdateDS: 19: 2) = *blanks;
 2e       endif;
 
          //---------------------------------------------------------
 1x    elseif TypeOutput = 'ENDXX';
          %subst(SrcUpdateDS: 14: 4) = StructNumb;
 2b       if IsCSR;
             %subst(SrcUpdateDS: 19: 2) = *blanks;
 2e       endif;
 2b       if p_EndLabel = '*YES';
             %subst(SrcUpdateDS: 38: 10) = OpcodeDS;
 2e       endif;
 
 1x    elseif TypeOutput = '/EJECT';
          %subst(SrcUpdateDS: 13) = *blanks;
 1e    endif;
 
       //--------------------------------------------
       // Indent nested DCL-* by one position
       //-----------------------------------------------
 1b    if not(TypeOutput = 'ENDXX'
          or TypeOutput = 'COMMENT-'
          or TypeOutput = '/EJECT');
          SrcUpdateDS = f_DclNestedIndent(OpCodeDS: SrcUpdateDS);
 1e    endif;
 
       update RPGSRC SrcUpdateDS;
       endsr;
 
       //---------------------------------------------------------
       // load number of begin and opcode name for use when flagging ends.
       //---------------------------------------------------------
       begsr srLoadBeginB;
 1b    if p_Indentfree = '*YES' and IsFree;
          exsr srIndentFree;
 1e    endif;
       cc += 1;
       ee += 1;
       StructNumb = %char(cc) + 'b';
       TypeOutput = 'CALC LINE';
       exsr srFormatOutput;
 1b    if OpcodeDS = 'MONITOR';
          op(cc) = 'MON';
 1x    elseif OpcodeDS.Two = 'FO';
          op(cc) = 'FOR';
 1x    else;
          op(cc) = OpcodeDS.Two;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // reformat indentions for /free code.
       // if indention would make calc line go past 74
       // then indent line as much as possible but do not go past 74.
       //---------------------------------------------------------
       begsr srIndentFree;
 1b    if srcds.Src94 > *blanks;
 2b       if IsEndCheat;
 
             //---------------------------------------------------------
             // if ee = 0 then there are too many END opcodes.
             // Send message with error statement number.
             //---------------------------------------------------------
             ee -= 1;
 3b          if ee < 0;
                close RPGSRC;
                f_SndCompMsg('WARNING: Unmatched ENDxx Opcode at ' +
                srcds.SeqNo + '.' + srcds.SeqDec +
                ' - JCRNUMB canceled!');
                *inlr = *on;
                return;
 3e          endif;
 2e       endif;
 
          // parms under callp are synced to start of program name
 2b       if IsCallp
             or IsFunction;
             wrkb = *blanks;
             %subst(wrkb: pp) = %triml(srcds.Src94);
 2x       else;
             %len(wblanks) = p_Indentspace * ee;
             wrkb = ' ' + Wblanks + %triml(srcds.Src94);
 2e       endif;
 
          exsr srIndentOrNot;
 2b       if IsEndCheat;
             ee += 1;
 2e       endif;
 
 2b       if (not IsComment);
 
             //---------------------------------------------------------
             // set CALLPARM flag if within callp
             // first ; outside comment resets to off
             //---------------------------------------------------------
 3b          if OpcodeDS.Six = 'CALLP ' or OpcodeDS.Six = 'CALLP(';
                IsCallp = *on;
 
                // get program name start position
                // callp(e) pgm(   I want to line up with pgm.
                pp = %scan('(': srcds.Src94);
 4b             if OpcodeDS.Six = 'CALLP(';
                   pp = %scan('(': srcds.Src94: pp + 1);
 4e             endif;
 4b             for aa = pp downto 1;
 5b                if %subst(srcds.Src94: aa: 1) = ' ';
 4v                   leave;
 5e                endif;
 4e             endfor;
                pp = aa + 1;
 3e          endif;
 
             //---------------------------------------------------------
             // My personal standard is all function names must
             // must begin with f_.  Given this, I want all parms
             // under function name to line up with function name.
             //---------------------------------------------------------
 3b          if not IsFunction;  //already in function
                aa = %scan('f_': srcds.Src94);
 4b             if aa > 0 and
                   %scan('(': srcds.Src94: aa) > 0;
                   IsFunction = *on;
                   pp = aa;
 4e             endif;
 3e          endif;
 
             // now to turn callp flag off.  Trigger is first
             // ; that is not behind comment line.
             aa = %scan(';': srcds.Src94);
 3b          if aa > 0;
                bb = %scan('//': srcds.Src94);
 4b             if bb = 0 or bb > aa;
                   IsCallp = *off;
                   IsFunction = *off;
 4e             endif;
 3e          endif;
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Two pieces distinct pieces of information on /free line
       // with different rules for code placement.
       // 1. code   2.comment
       // 1. code is defined as everything before // (if // is not inside
       // Quotations)
       //      x='  // this is not a comment'    // this is a comment
       // 2. comment is anything after unquoted // including //.
       // This 'code can only go to 92 but comments can go to 112' adds
       // whole new level of complexity to the whole thing!
       // After indentation,
       // 1. If code will not fit at position 92.  Cannot Indent.
       // 2. If code will fit at 92 and comment will fit at 112.  Indent OK
       // 3. If code will fit at 92 and comment will NOT fit at 112:
       // Is there enough space between end of code and
       // start of comment to compress out spaces?
       //       x=a                   // qweqweqwe
       //      x=a //qweqweqwe
       // If after compression, (see 2), else if it still will not fit,
       // do not indent.
       //---------------------------------------------------------
       begsr srIndentOrNot;
 1b    if %len(%trimr(wrkb)) <= 74  // all good it will fit
          or (IsComment
          and %len(%trimr(wrkb)) <= 94);
          srcds.Src94 = wrkb;
 1x    else;
          //---------------------------------------------------------
          // determine length of code,
          //  if will not fit in 74, cannot indent
          //   find starting position of last // in code
          //---------------------------------------------------------
          StartOfComment = 0;
          ww = 0;
 2b       dou ww = 0;
             ww = %scan('//': wrkb: ww + 1);
 3b          if ww > 0;
                StartOfComment = ww;
 3e          endif;
 2e       enddo;
 
 2b       if StartOfComment = 0;  //source will not fit in 74
 LV          leavesr;
 2e       endif;
          //---------------------------------------------------------
          // determine if // is between two Quotes
          // This could get tripped up if there are Quotes in comment and code.
          // Sure bet is not to put Quotes after //.
          // If no Quotes after //, then it is a legit comment.
          //---------------------------------------------------------
          q2 = %scan(qs: wrkb: StartOfComment);
 2b       if q2 > 0;
             q1 = 0;
 3b          for ww = StartOfComment downto 1;
 4b             if %subst(wrkb: ww: 1) = qs;
                   q1 = ww;
 3v                leave;
 4e             endif;
 3e          endfor;
 3b          if q1 > 0 and (q1 < StartOfComment and q2 > StartOfComment);
 LV             leavesr;  //the comment marker is within Quotes
 3e          endif;
 2e       endif;
 
          //---------------------------------------------------------
          // Source that will fit but comments will not.
          // see if there are any spaces between end of code
          // and start of comment that can be compressed
          // out. If so, compress and see if indented line will fit.
          //---------------------------------------------------------
          EndOfCode = %checkr(' ': wrkb: StartOfComment - 1);
 2b       if EndOfCode < 92;
             %len(wblanks) = StartOfComment - EndofCode;
 3b          dou %len(wblanks) = 1;
                wrkb2 = %subst(wrkb: 1: EndOfCode) +
                wblanks + %subst(wrkb: StartOfComment);
 4b             if %len(%trimr(wrkb2)) <= 94;
                   srcds.Src94 = wrkb2;
 LV                leavesr;
 4e             endif;
                %len(wblanks) = %len(wblanks) - 1;
 3e          enddo;
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // indent nested DCL-F over one position
       //---------------------------------------------------------
       dcl-proc f_DclNestedIndent;
        dcl-pi *n char(112);
         pOpCode char(10);
         pSource char(112);
        end-pi;
 
        dcl-s string varchar(94);
        dcl-s xx uns(3);
 
       // some DCL- have END- on same line,  ignore these lines
        string = %trimr(%subst(pSource:19));
        string = %xlate(lo: up: string);
        pOpcode = f_CheckSameLineEnd(pOpcode: string);
 
 1b     if pOpcode = 'END-DS'
           or pOpcode = 'END-PI'
           or pOpcode = 'END-PR'
           or pOpcode = 'END-PROC';
 2b        if IndentLvl > 0;
              IndentLvl -= 1;
 2e        endif;
 1e     endif;
 
 1b     for xx = 1 to IndentLvl;
           pSource = %replace('  ':pSource: 19: 1);
 1e     endfor;
 
 1b     if pOpcode = 'DCL-DS'
           or pOpcode = 'DCL-PI'
           or pOpcode = 'DCL-PR'
           or pOpcode = 'DCL-PROC';
           IndentLvl += 1;
 1e     endif;
 
        return pSource;
       end-proc;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       dcl-proc f_RemoveHexColorCodes;
        dcl-pi *n char(94);
         string char(94) options(*varsize);
         parmlen uns(3) const;
        end-pi;
 
        dcl-c Hex21 const(x'21');
        dcl-c Hex3F const(x'3F');
        dcl-s xx uns(3);
 
 1b     for xx = 1 to ParmLen;
 2b        if %subst(string: xx: 1) >= Hex21
              and %subst(string: xx: 1) <= Hex3F;
              %subst(string: xx: 1) = *blanks;
 2e        endif;
 1e     endfor;
 
        return string;
       end-proc;
