       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRSDENTR - Show Source Indentation for RPG or CL
       //  make CL indentation be previous continuation line sensitive
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f SRCMBR disk(112) extfile(extIfile) extmbr(p_SrcMbr)
       infds(Infds) usropn;
       dcl-ds InputDS len(112) qualified;
        CompileArry char(3) pos(13);
        SrcSeq zoned(6: 2) pos(1);
        SrcDat zoned(6: 0) pos(7);
        SpecType char(1) pos(18);
        Asterisk char(1) pos(19);
        Opcode char(10) pos(38);
        Part1src char(25) pos(13);
        Part2Src char(75) pos(38);
        Src100 char(100) pos(13);
        Src94 char(94) pos(19);
       end-ds;
 
       dcl-f JCRSDENTP printer oflind(IsOverFlow) usropn;
 
       /define Constants
       /define Infds
       /define f_BuildString
       /define f_DisplayLastSplf
       /define f_GetQual
       /define f_Qusrmbrd
       /define f_GetDayName
       /define f_RunCmd
       /define f_BlankCommentsCL
       /define f_Dltovr
       /define f_SndCompMsg
       /define f_IsCompileTimeArray
       /define f_CheckSameLineEnd
       /define f_IsIgnoreLine
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s IsContinuation ind;
       dcl-s WrkA like(opcodeds);
       dcl-s Upper like(srcall);
       dcl-s LevelsDeep uns(3);
       dcl-s LevelsDown uns(3);
       dcl-s LevelsUp uns(3);
       dcl-s xx uns(3);
       dcl-s yy uns(3);
       dcl-s IsArrowIn ind;
       dcl-s IsCalcSpec ind;
       dcl-s IsCasxx ind;
       dcl-s IsCompileTime ind;
       dcl-s IsFree ind;
       dcl-s IsSqlExec ind;
       dcl-s IsDo ind;
       dcl-s IsDoEnd ind;
       dcl-s string varchar(94);
       dcl-s src100 char(100);
       dcl-s qq uns(3);
       dcl-s qcnt uns(10);
       dcl-s quotepos uns(3) dim(100) ascend;
 
       dcl-ds OpCodeDS len(10) inz qualified;
        Two char(2) pos(1);
        Three char(3) pos(1);
        Four char(4) pos(1);
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_SrcMbr char(10);
        p_SrcFilQual char(20);
        p_Output char(8);
       end-pi;
       //---------------------------------------------------------
 
       f_RunCmd(f_BuildString(
       'OVRPRTF FILE(JCRSDENTP) PRTTXT(*BLANK) USRDFNOPT(*NONE) +
       SPLFNAME(&) OVRSCOPE(*JOB)': p_SrcMbr));
       open JCRSDENTP;
 
       // Get source type for heading and logic selection
       QusrmbrdDS = f_Qusrmbrd(p_SrcFilQual: p_SrcMbr: 'MBRD0100');
 
       scObjHead =
       f_BuildString('&   &   &   &':
       QusrmbrdDS.Mbr: QusrmbrdDS.File: QusrmbrdDS.Lib: QusrmbrdDS.Text);
 
       scDow = f_GetDayName();
       write PrtHead;
       IsOverFlow = *off;
 
       extIfile = f_GetQual(QusrmbrdDS.File + QusrmbrdDS.Lib);
       open SRCMBR;
       read SRCMBR inputds;
 1b    dow not %eof;
 
          Seqno = inputds.SrcSeq;
          OpCodeDs = inputds.Opcode;
          Part1Src = inputds.Part1Src;
          Src100 = inputds.Src100;
 
          // If 92 record length, blank out any garbage from 93 to 112
 2b       if InfdsRecLen = 92;
             %subst(Src100:81) = *all' ';
 2e       endif;
 
 2b       if QusrmbrdDS.MbrType = 'CLP' or
             QusrmbrdDS.MbrType = 'CLLE';
             exsr srClSrc;
 2x       else;
             exsr srRPGSrc;
 2e       endif;
 
          read SRCMBR inputds;
 1e    enddo;
 
       exsr srClose;
 
       //---------------------------------------------------------
       begsr srClose;
       close JCRSDENTP;
       close SRCMBR;
       f_Dltovr('JCRSDENTP');
       f_DisplayLastSplf('JCRSDENTR': p_Output);
       *inlr = *on;
       return;
       endsr;
 
       //---------------------------------------------------------
       begsr srRPGSrc;
       IsFree = *off;
       IsCalcSpec = *off;
 
       // do not process compile time arrays
 1b    if f_IsCompileTimeArray(inputds.CompileArry);
          IsCompileTime = *on;
 1x    else;
 
          string = %trimr(inputds.Src94);
          string = %xlate(lo: up: string);
 2b       if inputds.Asterisk = '*' or inputds.Asterisk = '/';
 
             // do not worry about indenting till get to C specs.
             // if C or c or /free, inside the C specs.
 2x       elseif inputds.SpecType = 'C' or inputds.SpecType = 'c';
             IsCalcSpec = *on;
             IsFree = *off;
 
 2x       elseif inputds.SpecType = ' ';
             IsCalcSpec = *on;
             IsFree = *on;
 2e       endif;
 1e    endif;
 
       exsr srIndent;
       endsr;
 
       //----------------------------------------------------------------
       //----------------------------------------------------------------
       begsr srIndent;
 1b    if IsCompileTime = *off
          and  IsCalcSpec = *on;
          LevelsDown = 0;
          LevelsUp = 0;
 
 2b       if not(inputds.Asterisk = '*'
             or inputds.Asterisk = '+'     //no sql
             or inputds.Asterisk = '/');  //no copy statements
 
             //---------------------------------------------------------
             // For /free code, extract opcode into OpCodeDS field.
             // Look for first ';' and first ';'  , the one not
             // zero and lowest value is end of opcode
             //---------------------------------------------------------
 3b          if IsFree and %len(string) > 0;
                WrkA = %triml(string);
                clear OpCodeDS;
 
 4b             if not IsContinuation;
                   aa = %scan(' ': WrkA: 1);
                   bb = %scan(';': WrkA: 1);
 
 5b                if aa > 0 and (aa < bb or bb = 0);
                      OpCodeDS = %subst(WrkA: 1: aa - 1);
 5x                elseif bb > 0 and (bb < aa or aa = 0);
                      OpCodeDS = %subst(WrkA: 1: bb - 1);
 5e                endif;
 
                   opcodeDS = f_CheckSameLineEnd(opcodeDS: string);
 
 4e             endif;
 
                exsr srContinuationCheck;
 3e          endif;
 
             OpCodeDS = %xlate(lo: up: OpCodeDS);
             // bad person had field named END in their free code
             // ENDblank is valid in fixed column format, but not in free
 3b          if IsFree and OpCodeDS = 'END';
                OpCodeDS = *blanks;
 3e          endif;
 
             //---------------------------------------------------------
             // do not format SQL statements
             //  Ignore everything between EXEC and terminating;
             //---------------------------------------------------------
 3b          if OpcodeDS = 'EXEC';
                IsSqlExec = *on;
 3e          endif;
 
 3b          if not IsSqlExec;
 4b             if (OpCodeDS.Two = 'DO' and IsFree = *off)
                   or (OpCodeDS.Two = 'IF' and IsFree = *off)
 
                   or (IsFree and
                   (OpCodeDS = 'DOU'
                   or OpCodeDS.Four = 'DOU('
                   or OpCodeDS = 'DOW'
                   or OpCodeDS.Four = 'DOW('
                   or OpCodeDS = 'IF'
                   or OpCodeDS.Three = 'IF('
                   or OpCodeDS = 'DCL-DS'
                   or OpCodeDS = 'DCL-PR'
                   or OpCodeDS = 'DCL-PI'
                   or OpCodeDS = 'DCL-PROC'))
                   or OpCodeDS = 'FOR'
                   or OpCodeDS = 'MONITOR'
                   or OpcodeDS.Four = 'FOR(';
                   LevelsDown = 1;
 
 4x             elseif OpCodeDS = 'SELECT';
                   LevelsDown = 2;
 
                   //---------------------------------------------------------
                   // process cas opcode.  There could be several
                   // cas in a row and only first one in each group
                   // used to trigger offset.
                   //---------------------------------------------------------
 4x             elseif OpCodeDS.Three = 'CAS'
                   and IsCasxx = *off
                   and IsFree = *off;
                   LevelsDown = 1;
                   IsCasxx = *on;
 
                   //---------------------------------------------------------
                   // Set indicator to load marker for these opcodes
                   //---------------------------------------------------------
 4x             elseif (OpCodeDS.Two = 'WH' and IsFree = *off)
                   or OpCodeDS = 'OTHER'
                   or OpCodeDS = 'ELSE'
                   or OpCodeDS = 'ELSEIF'
                   or OpCodeDS = 'ON-ERROR'
                   or OpCodeDS = 'WHEN';
                   IsArrowIn = *on;
 
                   //---------------------------------------------------------
                   // Set Flag if END is found, reset CAS indicator
                   //---------------------------------------------------------
 4x             elseif OpCodeDS <> 'ENDSR'
                   and ((OpCodeDS.Three = 'END' and IsFree = *off)
                   or OpCodeDS.Four = 'END-'
                   or OpCodeDS = 'END'
                   or OpCodeDS = 'ENDSL'
                   or OpCodeDS = 'ENDIF'
                   or OpCodeDS = 'ENDDO'
                   or OpCodeDS = 'ENDMON'
                   or OpCodeDS = 'ENDFOR');
                   LevelsUp = 1;
                   IsCasxx = *off;
 4e             endif;
 
                //---------------------------------------------------------
                // Step up for WHEN/OTHER  under WHEN, OTHER statement
                //---------------------------------------------------------
 4b             if OpCodeDS = 'ENDSL';
                   LevelsUp = 2;
 4e             endif;
 
 4b             if ((OpCodeDS.Two = 'WH' and IsFree = *off)
                   or OpCodeDS = 'WHEN'
                   or OpCodeDS = 'OTHER');
                   LevelsDeep -= 1;
 4e             endif;
 3e          endif;
 
             // look for line terminating in semi-colon
 3b          if IsSqlExec;
                IsSqlExec = (%scan(';': inputds.Src94: 1) = 0);
 3e          endif;
 2e       endif;
 
          //---------------------------------------------------------
          // Load indent char and source line for printing
          //---------------------------------------------------------
 2b       if (LevelsDeep = 0 and  LevelsUp > 0);
             f_SndCompMsg('WARNING: Unmatched ENDxx Opcode at ' +
             %triml(%editc(seqno:'4')) + ' - JCRSDENT canceled!');
             exsr srClose;
 
 2x       elseif LevelsDeep = 38;
             f_SndCompMsg('WARNING: Nesting Over 38 Levels at ' +
             %triml(%editc(seqno:'4')) + ' - JCRSDENT canceled!');
             exsr srClose;
 2e       endif;
 
          LevelsDeep -= LevelsUp;
 
          // Step over how far to indent
          clear LineOfCode;
          xx = 1;
 2b       for yy = 1 to LevelsDeep;
             %subst(LineOfCode: xx: 3) = '|  ';
 
 3b          if IsArrowIn = *on
                and LevelsDeep = yy;
                %subst(LineOfCode: xx: 3) = '|> ';
                IsArrowIn = *off;
 3e          endif;
             xx += 3;
 2e       endfor;
 
 2b       if IsFree = *on
             or inputds.Asterisk = '*'
             or inputds.Asterisk = '+'
             or inputds.Asterisk = '/';
             %subst(LineOfCode: xx) = %triml(inputds.Src94);
             %subst(Part1Src: 7) = *all' ';
 2x       else;
             %subst(LineOfCode: xx) = inputds.Part2Src;
 2e       endif;
          write PrtCspec;
          LevelsDeep += LevelsDown;
 
          // step back down level for stuff under WHEN/OTHER
 2b       if not(inputds.Asterisk = '*'
             or inputds.Asterisk = '+'
             or inputds.Asterisk = '/');
 3b          if (OpCodeDS.Two = 'WH' and IsFree = *off)
                or OpCodeDS = 'WHEN'
                or OpCodeDS = 'OTHER';
                LevelsDeep += 1;
 3e          endif;
 2e       endif;
 1x    else;
          SrcAll = Src100;
          write PrtXspec;
 1e    endif;
       endsr;
 
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
       begsr srContinuationCheck ;
       IsContinuation = *off;
 1b    if not f_IsIgnoreLine(string);  // skip comments and such
          aa = %len(string);
 2b       if aa > 0;
 3b          if %subst(string: aa: 1) = '+'
                or %subst(string: aa: 1) = '-';
                IsContinuation = *on;
 3e          endif;
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srCLSrc;
       // slam everything to left for indentation then upper case
       Src100 = ' ' + %triml(Src100);
 
       // It is easier to blank out all comments before scanning
       Upper = f_BlankCommentsCL(%xlate(lo: up: Src100));
       IsDo = *off;
       IsDoEnd = *off;
 
 1b    if Upper > *blanks;
 
          // get number of quotes in this line
          quotepos(*) = 0;
          qq = 0;
 
          bb = 1;
 2b       dou aa = 0;
             aa = %scan(qs: upper: bb);
 3b          if aa > 0;
                qq += 1;
                quotepos(qq) = aa;
                bb = aa+1; // position next scan
 4b             if bb > %len(upper);
 2v                leave;
 4e             endif;
 3e          endif;
 2e       enddo;
 
 
          // Check for indent start and end commands
          xx = %scan(' DO ': Upper);
 2b       if xx = 0;
             xx = %scan('(DO)': Upper);
 3b          if xx = 0;
                xx =  %scan('DOUNTIL': Upper);
 4b             if xx = 0;
                   xx = %scan('DOWHILE': Upper);
 5b                if xx = 0;
                      xx = %scan('DOFOR': Upper);
 6b                   if xx = 0;
                         xx = %scan(' SELECT ': Upper);
 7b                      if xx = 0;
                            xx = %scan('(SELECT ': Upper);
 7e                      endif;
 6e                   endif;
 5e                endif;
 4e             endif;
 3e          endif;
 2e       endif;
 
          // set indent flag in relation to number of quotes
 2b       if xx > 0;
             IsDo = f_checkquotes();
 2x       else;
 
             xx = %scan('ENDDO ': Upper);
 3b          if xx = 0;
                xx =  %scan('ENDSELECT': Upper);
 3e          endif;
 
 3b          if xx > 0;
                IsDoEnd = f_checkquotes();
 3e          endif;
 2e       endif;
 
          qcnt += qq;
 1e    endif;
 
       //---------------------------------------------------------
       // If ENDDO is found, sub one from counter.
       //  Spin though number of DO levels deep and load ' |' char.
       //   If DO, increment counter by one for next time.
       //---------------------------------------------------------
 1b    if IsDoEnd;
 2b       if LevelsDeep > 0;
             LevelsDeep -= 1;
 2e       endif;
 1e    endif;
       clear LineOfCode;
 1b    for cc = 1 to LevelsDeep;
          LineOfCode = %trimr(LineOfCode) + '  |';
 1e    endfor;
       LineOfCode = %trimr(LineOfCode) + Src100;
 
 1b    if IsDo;
          LevelsDeep += 1;
 1e    endif;
       write PrtCLspec;
       endsr;
 
       //--------------------------------
       // I am saying if the number of quotes over to xx is even,
       // then this is a valid command, else it is between quotes
       //--------------------------------
       dcl-proc f_checkquotes;
        dcl-pi *n ind;
        end-pi;
 
        bb = 0;
 
       // if current line has quotes, see where xx is in relationship.
 1b     if qq > 0;
           bb = %lookuplt(xx:quotepos:1:qq);
 1e     endif;
 
        return (%rem(qcnt+bb:  2) = 0);
 
       end-proc;
