       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRFREESSR - Free/fixed side-by-side source view
       //---------------------------------------------------------
       // Originally designed to be conversion program between fixed format
       // and free. In the process, it became clear just how hard that would be without
       // intentional rewrites of the legacy code.
 
       // Any lines with ???????????????????? are invalid in /free and must be re-written.
       // Final page of report is summary/count of invalid opcodes.
       //---------------------------------------------------------
       /define ControlStatements
       /define SrcDS
       /define Constants
       /define f_DisplayLastSplf
       /define f_GetQual
       /define f_IsCompileTimeArray
       /define f_GetDayName
       /define f_BuildString
       /define f_RunCmd
       /define f_Qusrmbrd
       /define f_Dltovr
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f V4SRC disk(112) extfile(extifile) extmbr(p_srcmbr) usropn;
       dcl-f JCRFREESSP printer oflind(*in01) usropn;
 
       dcl-s ee like(levelsdeep);
       dcl-s ff like(levelsdeep);
       dcl-s F2upper like(f2);
       dcl-s OpUpsave like(opup);
       dcl-s RFupper like(srcds.resultfield);
       dcl-s Work like(srcds.src112);
       dcl-s WorkUpper like(srcds.src112);
       dcl-s xx like(levelsdeep);
       dcl-s yy like(levelsdeep);
       dcl-s OpCodeArry char(10) dim(200);
       dcl-s LF2 char(14);
       dcl-s LineOfCode char(112);
       dcl-s zz char(14);
       dcl-s CountArry uns(5) dim(200);
       dcl-s LevelsDeep uns(5);
       dcl-s DownOneLevel ind;
       dcl-s IsCalcSpec ind;
       dcl-s IsCallp ind;
       dcl-s IsCasxx ind;
       dcl-s IsWhenIndent ind;
       dcl-s UpOneLevel ind;
       dcl-s IsFree ind;
       dcl-s IsSQL ind;
       dcl-s IsComment ind;
 
       dcl-ds OpUp len(10);
        DoIfWh char(2) pos(1);
        EndOpcode char(3) pos(1);
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_SrcMbr char(10);
        p_SrcFilQual char(20);
        p_Output char(8);
       end-pi;
       //---------------------------------------------------------
 
       QusrmbrdDS = f_Qusrmbrd(p_SrcFilQual: p_SrcMbr: 'MBRD0100');
       %subst(p_SrcFilQual: 11: 10) = QusrmbrdDS.Lib;
 
       scObjHead =
       f_BuildString('&  &  &  &':
       QusrmbrdDS.Mbr: QusrmbrdDS.File: QusrmbrdDS.Lib: QusrmbrdDS.Text);
 
       extIfile = f_GetQual(p_SrcFilQual);
 
       f_RunCmd('OVRPRTF FILE(JCRFREESSP) ' +
       'SPLFNAME(' + %trimr(p_SrcMbr) + ') ' +
       'PRTTXT(*BLANK) OVRSCOPE(*JOB)');
 
       open v4Src;
       open JCRFREESSp;
       scDow = f_GetDayName();
       write PrtHead;
 
       //---------------------------------------------------------
       read v4Src SrcDs;
 1b    dow not %eof;
 
          Seqno = SrcDS.SeqNum6;
          F1 = SrcDS.Factor1;
          OP = SrcDS.OpCode;
          F2 = SrcDS.Factor2;
          RF = SrcDS.ResultField;
          RSI = SrcDS.ResultingInd;
 
 2b       if f_IsCompileTimeArray(SrcDS.CompileArray)
             or SrcDS.SpecType = 'P'
             or SrcDS.SpecType = 'p';
 1v          leave;
 2e       endif;
 
          // see if inside /free
 2b       if SrcDS.Asterisk = '/';
             SrcDS.FreeForm = %xlate(lo: up: SrcDS.FreeForm);
 3b          if SrcDS.FreeForm = '/FREE';
                IsFree = *on;
                IsCalcSpec = *on;
 3x          elseif SrcDS.FreeForm = '/END-FREE';
                IsFree = *off;
 3e          endif;
 
 3b          if SrcDS.FreeForm = '/EXEC SQL';
                IsSQL = *on;
                IsCalcSpec = *on;
 3x          elseif SrcDS.FreeForm = '/END-EXEC';
                IsSQL = *off;
 3e          endif;
 2e       endif;
 
 2b       if SrcDS.SpecType = 'C'
             or SrcDS.SpecType = 'c';
             IsCalcSpec = *on;
 2e       endif;
 
 2b       if SrcDS.SpecType = 'O'
             or SrcDS.SpecType = 'o'
             or SrcDS.SpecType = 'D'
             or SrcDS.SpecType = 'd'
             or SrcDS.SpecType = 'F'
             or SrcDS.SpecType = 'f';
             IsCalcSpec = *off;
 2e       endif;
 
 2b       if IsCalcSpec;
             DownOneLevel = *off;
             UpOneLevel = *off;
 
 3b          if not(SrcDS.Asterisk = '+' or SrcDS.Asterisk = '/');
 4b             if SrcDS.OpCode > *blanks;
                   IsCallp = *off;
 4e             endif;
 
                OpUp = %xlate(lo: up: SrcDS.OpCode);
 4b             if SrcDS.Asterisk = '*';
 4x             elseif EndOpcode = 'CAS';
                   IsCasxx = *on;
 4x             elseif DoIfWh = 'DO'
                   or DoIfWh = 'IF'
                   or OpUp = 'SELECT'
                   or OpUp = 'BEGSR'
                   or OpUp = 'FOR'
                   or OpUp = 'MONITOR'
                   or %subst(OpUp: 1: 4) = 'FOR(';
                   DownOneLevel = *on;
 
                   // Set Flag if END is found
 4x             elseif EndOpcode = 'END';
 5b                if not IsCasxx;
                      UpOneLevel = *on;
 5e                endif;
                   IsCasxx = *off;
 4e             endif;
 3e          endif;
 
             // Convert EVERYTHING to free format
             Work = *blanks;
             LineOfCode = *blanks;
             IsComment = *off;
 
 3b          if IsFree or IsSql;
                Work = SrcDS.Src112;
 
 3x          elseif SrcDS.Asterisk = '*';
 4b             if %subst(SrcDS.Src112: 8) = *blanks;
                   Work = *blanks;
 4x             else;
                   Work = '// ' + %triml(%subst(SrcDS.Src112: 8));
                   IsComment = *on;
 4e             endif;
 
 3x          elseif SrcDS.SlashComment = '/E' or
                SrcDS.SlashComment = '/e';
                Work = *blanks;
 
                //---------------------------------------------------------
                // All DO statements must be converted to FOR opcodes
                // There are 5 variations of on DO
                // DO              = FOR JCRCNT = 1 to 1
                // DO  xx          = FOR JCRCNT = 1 to xx
                // DO  xx   yy     = FOR yy = 1 to xx
                // aa   DO  xx          = FOR JCRCNT = aa to xx
                // aa   DO  xx   yy     = FOR yy = aa to xx
                // Counter field JCRCNT is provided to make FOR work
                //---------------------------------------------------------
 3x          elseif OpUp = 'DO';
 4b             if SrcDS.Factor1 > *blanks        //aa DO xx yy
                   and SrcDS.Factor2 > *blanks
                   and SrcDS.ResultField  > *blanks;
                   Work = 'for ' +
                   %trimr(SrcDS.ResultField) +
                   ' = ' +
                   %trimr(SrcDS.Factor1) +
                   ' to ' +
                   SrcDS.Factor2;
 
 4x             elseif SrcDS.Factor1 > *blanks     //aa DO xx
                   and SrcDS.Factor2 > *blanks
                   and SrcDS.ResultField = *blanks;
                   Work = 'for JCRCNT = ' +
                   %trimr(SrcDS.Factor1) +
                   ' to ' +
                   SrcDS.Factor2;
 
 4x             elseif SrcDS.Factor1 = *blanks     //DO xx  yy
                   and SrcDS.Factor2 > *blanks
                   and SrcDS.ResultField > *blanks;
                   Work = 'for ' + %trimr(SrcDS.ResultField) +
                   ' = 1 to ' + SrcDS.Factor2;
 
 4x             elseif SrcDS.Factor1 = *blanks     //DO xx
                   and SrcDS.Factor2 > *blanks
                   and SrcDS.ResultField = *blanks;
                   Work = 'for JCRCNT = 1 to ' + SrcDS.Factor2;
 
 4x             elseif SrcDS.Factor1 = *blanks     //DO
                   and SrcDS.Factor2 = *blanks
                   and SrcDS.ResultField = *blanks;
                   Work = 'dou ''''1''''';
 4e             endif;
 
 3x          elseif %subst(OpUp: 1: 6) = 'ADDDUR'
                or %subst(OpUp: 1: 6) = 'SUBDUR';
                exsr srADDDUR;
 
 3x          elseif %subst(OpUp: 1: 6) = 'EXTRCT';
                Work = 'eval ' +
                %trimr(SrcDS.ResultField) +
                ' = %subdt(' +
                %trimr(SrcDS.Factor2) + ')';
 
 3x          elseif %subst(OpUp: 1: 5) = 'CHECK';
                Work = 'eval ' +
                %trimr(SrcDS.ResultField) +
                ' = %' +
                %trimr(SrcDS.OpCode) +
                '(' +
                %trimr(SrcDS.Factor1) +
                ':' +
                %trimr(SrcDS.Factor2) + ')';
 
 3x          elseif %subst(OpUp: 1: 5) = 'XLATE';
                Work = 'eval ' +
                %trimr(SrcDS.ResultField) +
                ' = %' +
                %trimr(SrcDS.OpCode) +
                '(' +
                %trimr(SrcDS.Factor1) +
                ':' +
                %trimr(SrcDS.Factor2) + ')';
 
 3x          elseif %subst(OpUp: 1: 6) = 'LOOKUP';
                exsr srLOOKUP;
 
 3x          elseif %subst(OpUp: 1: 5) = 'XFOOT';
                exsr srXFOOT;
 
 3x          elseif %subst(OpUp: 1: 5) = 'OCCUR';
                exsr srOCCUR;
 
                //---------------------------------------------------------
                // FACTOR1  OP  FACTOR2  RESULT conversions.
                // FACTOR1  OP  FACTOR2
                // FACTOR1  OP
                // end result is opcode Factor1 Factor2  Result
                //---------------------------------------------------------
 3x          elseif %subst(OpUp: 1: 3) = 'ACQ'
                or OpUp = 'BEGSR '
                or OpUp = 'MONITOR'
                or OpUp = 'ON-ERROR'
                or %subst(OpUp: 1: 5) = 'CHAIN'
                or %subst(OpUp: 1: 6) = 'COMMIT'
                or %subst(OpUp: 1: 6) = 'DELETE'
                or %subst(OpUp: 1: 5) = 'DSPLY'
                or %subst(OpUp: 1: 4) = 'DUMP'
                or %subst(OpUp: 1: 4) = 'POST'
                or %subst(OpUp: 1: 3) = 'END'
                or %subst(OpUp: 1: 3) = 'IN '
                or %subst(OpUp: 1: 3) = 'IN('
                or %subst(OpUp: 1: 4) = 'NEXT'
                or %subst(OpUp: 1: 3) = 'OUT'
                or %subst(OpUp: 1: 4) = 'POST'
                or %subst(OpUp: 1: 5) = 'READE'
                or %subst(OpUp: 1: 6) = 'READPE'
                or %subst(OpUp: 1: 3) = 'REL'
                or %subst(OpUp: 1: 5) = 'RESET'
                or OpUp = 'CLEAR '
                or %subst(OpUp: 1: 5) = 'ROLBK'
                or %subst(OpUp: 1: 5) = 'SETGT'
                or %subst(OpUp: 1: 5) = 'SETLL'
                or %subst(OpUp: 1: 5) = 'TEST '
                or %subst(OpUp: 1: 5) = 'TEST('
                or %subst(OpUp: 1: 6) = 'UNLOCK';
 4b             if SrcDS.Factor1 = *blanks;
                   Work = %trimr(SrcDS.OpCode) +
                   '  ' +
                   %trimr(SrcDS.Factor2) +
                   ' ' +
                   SrcDS.ResultField;
 4x             else;
                   Work = %trimr(SrcDS.OpCode) +
                   '  ' +
                   %trimr(SrcDS.Factor1) +
                   ' ' +
                   %trimr(SrcDS.Factor2) +
                   ' ' +
                   SrcDS.ResultField;
 4e             endif;
 
                // resulting ind errors
 4b             if SrcDS.ResultingInd > *blanks;
                   Work = %trimr(Work) +
                   '    ??' +
                   %trim(SrcDS.ResultingInd) +
                   '????????????????';
                   OpUpsave = OpUp;
 
                   OpUp = 'ResultInd';
                   exsr srLoadError;
                   OpUp = OpUpsave;
 4e             endif;
 
                //---------------------------------------------------------
                // opcode FACTOR2  RESULT conversions.
                // opcode FACTOR2
                // end result is Opcode Factor2  Result
                //---------------------------------------------------------
 3x          elseif OpUp = 'EXCEPT '
                or OpUp = 'EXFMT'
                or OpUp = 'EXSR'
                or OpUp = 'ELSE'
                or OpUp = 'ELSEIF'
                or OpUp = 'FORCE'
                or OpUp = 'ITER'
                or OpUp = 'LEAVE'
                or OpUp = 'LEAVESR'
                or OpUp = 'OTHER '
                or %subst(OpUp: 1: 5) = 'CLOSE'
                or %subst(OpUp: 1: 4) = 'OPEN'
                or %subst(OpUp: 1: 5) = 'READ '
                or %subst(OpUp: 1: 5) = 'READ('
                or %subst(OpUp: 1: 5) = 'READC'
                or %subst(OpUp: 1: 5) = 'READP'
                or OpUp = 'SELECT '
                or OpUp = 'SORTA  '
                or %subst(OpUp: 1: 6) = 'UPDATE'
                or %subst(OpUp: 1: 5) = 'WRITE'
                or %subst(OpUp: 1: 4) = 'FEOD';
                Work = %trimr(SrcDS.OpCode) +
                '  ' +
                %trimr(SrcDS.Factor2) +
                ' ' +
                SrcDS.ResultField;
 
 4b             if SrcDS.ResultingInd > *blanks;
                   Work = %trimr(Work) +
                   '    ??' +
                   %trim(SrcDS.ResultingInd) +
                   '????????????????';
 
                   OpUpsave = OpUp;
                   OpUp = 'ResultInd';
                   exsr srLoadError;
                   OpUp = OpUpsave;
 4e             endif;
 
                //---------------------------------------------------------
                // Opcode RESULT field simple compressions
                //---------------------------------------------------------
 3x          elseif %subst(OpUp: 1:7) = 'DEALLOC';
                Work = %trimr(SrcDS.OpCode) +
                '  ' +
                SrcDS.ResultField;
 
                //---------------------------------------------------------
                // opcode Extended Factor2 compressions
                // Will need to revisit this for + signs to line up code.
                //---------------------------------------------------------
 3x          elseif %subst(OpUp: 1: 4) = 'DOU '
                or %subst(OpUp: 1: 4) = 'DOU('
                or %subst(OpUp: 1: 4) = 'DOW '
                or %subst(OpUp: 1: 4) = 'DOW('
                or %subst(OpUp: 1: 5) = 'CALLP'
                or %subst(OpUp: 1: 4) = 'EVAL'
                or %subst(OpUp: 1: 4) = 'FOR '
                or %subst(OpUp: 1: 4) = 'FOR('
                or %subst(OpUp: 1: 3) = 'IF '
                or %subst(OpUp: 1: 3) = 'IF('
                or %subst(OpUp: 1: 6) = 'RETURN'
                or %subst(OpUp: 1: 5) = 'WHEN '
                or %subst(OpUp: 1: 5) = 'WHEN(';
                Work = %trimr(SrcDS.OpCode) +
                '  ' +
                SrcDS.ExtendFactor2;
 
                // get position for callp parms to line up with factor2
                bb = %scan(SrcDS.ExtendFactor2: Work);
 4b             if %subst(OpUp: 1: 5) = 'CALLP';
                   IsCallp = *on;
 4e             endif;
 3x          else;
                //---------------------------------------------------------
 4b             if OpUp = *blanks;
 5b                if not IsCallp;
                      Work = SrcDS.ExtendFactor2;
 5x                else;
                      Work = *blanks;
                      %subst(Work: bb) = %trimr(SrcDS.ExtendFactor2);
 5e                endif;
 4x             else;
                   exsr srLoadError;
                   Work =
                   %trimr(SrcDS.OpCode) + ' ?????????????????????????';
 4e             endif;
 3e          endif;
             exsr srOutput;
 2e       endif;
 
          read v4Src SrcDs;
 1e    enddo;
 
       write PrtSumHead;
 1b    for ff = 1 to ee;
          sumopcod = OpCodeArry(ff);
          sumCount = CountArry(ff);
          write PrtSumDet;
 1e    endfor;
 
       close v4Src;
       close JCRFREESSp;
       f_DltOvr('JCRFREESSP');
       f_DisplayLastSplf('JCRFREESSR': p_Output);
 
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       // Save opcodes not converted and number of times used for summary report.
       //---------------------------------------------------------
       begsr srLoadError;
       ff = %lookup(OpUp: OpCodeArry);
 1b    if ff > 0;
          CountArry(ff) += 1;
 1x    else;
          ee += 1;
          OpCodeArry(ee) = OpUp;
          CountArry(ee) = 1;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srADDDUR;
       f2upper = %xlate(lo: up: SrcDS.Factor2);
       rfupper = %xlate(lo: up: SrcDS.ResultField);
       Work = 'eval';
 1b    if OpUp = 'ADDDUR(E)'
          or OpUp = 'SUBDUR(E)';
          Work = 'eval(e)';
 1e    endif;
       xx = %scan(':': SrcDS.Factor2);
 1b    if xx > 0;
          Work = %trimr(Work) +
          ' ' +
          %trimr(SrcDS.ResultField) + ' =';
 
 2b       if SrcDS.Factor1 = *blank;
             Work = %trimr(Work) + ' ' + SrcDS.ResultField;
 2x       else;
             Work = %trimr(Work) + ' ' + SrcDS.Factor1;
 2e       endif;
 
 2b       if %subst(OpUp: 1: 6) = 'ADDDUR';
             Work = %trimr(Work) + ' + ';
 2x       else;
             Work = %trimr(Work) + ' - ';
 2e       endif;
 
          xx = %scan(':': SrcDS.Factor2);
 2b       if %subst(F2upper: xx + 1) = '*MSECONDS'
             or %subst(F2upper: xx + 1) = '*MS';
             Work = %trimr(Work) + ' %mseconds(';
 2x       elseif %subst(F2upper: xx + 1) = '*SECONDS'
             or %subst(F2upper: xx + 1) = '*S';
             Work = %trimr(Work) + ' %seconds(';
 2x       elseif %subst(F2upper: xx + 1) = '*MINUTES'
             or %subst(F2upper: xx + 1) = '*MN';
             Work = %trimr(Work) + ' %minutes(';
 2x       elseif %subst(F2upper: xx + 1) = '*HOURS'
             or %subst(F2upper: xx + 1) = '*H';
             Work = %trimr(Work) + ' %hours(';
 2x       elseif %subst(F2upper: xx + 1) = '*DAYS'
             or %subst(F2upper: xx + 1) = '*D';
             Work = %trimr(Work) + ' %days(';
 2x       elseif %subst(F2upper: xx + 1) = '*MONTHS'
             or %subst(F2upper: xx + 1) = '*M';
             Work = %trimr(Work) + ' %months(';
 2x       elseif %subst(F2upper: xx + 1) = '*YEARS'
             or %subst(F2upper: xx + 1) = '*Y';
             Work = %trimr(Work) + ' %year(';
 2e       endif;
 
          Work = %trimr(Work) +
          %subst(SrcDS.Factor2: 1: xx - 1) +
          ')';
 1x    else;
          //---------------------------------------------------------
          // Process DIFF statements
          // first extract field from RF
          xx = %scan(':': SrcDS.ResultField);
          Work = %trimr(Work) +
          ' ' +
          %subst(SrcDS.ResultField: 1: xx - 1) +
          ' = %diff(' +
          %trimr(SrcDS.Factor1) +
          ':' +
          %trimr(SrcDS.Factor2) + ':' +
          %trimr(%subst(SrcDS.ResultField: xx + 1)) + ')';
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       begsr srLOOKUP;
       zz = *blanks;
       lf2 = SrcDS.Factor2;
       f2upper = %xlate(lo: up: SrcDS.Factor2);
       Work = 'eval';
 1b    if %subst(F2upper: 1: 3) = 'TAB';
          Work = 'eval *in' +
          %trim(SrcDS.ResultingInd) + ' = %tlookup';
 
 1x    else;
          xx = %scan('(': SrcDS.Factor2);
 2b       if xx = 0;
 3b          if (SrcDS.ResultingInd) > *blanks;
                Work = 'eval *in' +
                %trim(SrcDS.ResultingInd) + ' = %lookup';
 3x          else;
                Work = 'eval JCRInt = %lookup';
 3e          endif;
 2x       else;
             yy = %scan(')': SrcDS.Factor2: xx);
             lf2 = %subst(SrcDS.Factor2: 1: xx - 1);
             zz = %subst(SrcDS.Factor2: xx + 1: yy - (xx + 1));
             Work = 'eval ' +
             %trimr(zz) + ' = %lookup';
 2e       endif;
 1e    endif;
 
       // Now look at indicators assigned and tack on type lookup
 1b    if SrcDS.EQind > *blanks
          and SrcDS.HIind = *blanks
          and SrcDS.LOind = *blanks;
          Work = %trimr(Work) + 'EQ(';
 
 1x    elseif SrcDS.EQind = *blanks
          and SrcDS.HIind > *blanks
          and SrcDS.LOind = *blanks;
          Work = %trimr(Work) + 'GT(';
 
 1x    elseif SrcDS.EQind = *blanks
          and SrcDS.HIind = *blanks
          and SrcDS.LOind > *blanks;
          Work = %trimr(Work) + 'LT(';
 
 1x    elseif SrcDS.EQind > *blanks
          and SrcDS.HIind > *blanks
          and SrcDS.LOind = *blanks;
          Work = %trimr(Work) + 'GE(';
 
 1x    elseif SrcDS.EQind > *blanks
          and SrcDS.HIind = *blanks
          and SrcDS.LOind > *blanks;
          Work = %trimr(Work) + 'LE(';
 1x    else;
          Work = %trimr(Work) + '??(';
 1e    endif;
       Work = %trimr(Work) + %trimr(SrcDS.Factor1) + ':' +
       %trimr(lf2);
 
 1b    if not(%subst(F2upper: 1: 3) = 'TAB');
 2b       if zz = *blanks;
             Work = %trimr(Work) + ')';
 2x       else;
             Work = %trimr(Work) + ':' + %trimr(zz) + ')';
 2e       endif;
 1x    else;
 2b       if SrcDS.ResultField = *blanks;
             Work = %trimr(Work) + ')';
 2x       else;
             Work = %trimr(Work) +
             ':' +
             %trimr(SrcDS.ResultField) + ')';
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       begsr srXFOOT;
       Work = 'eval';
       xx = %scan('(': SrcDS.OpCode);
 1b    if xx > 0;
          Work = %trimr(Work) + %subst(SrcDS.OpCode: xx);
 1e    endif;
       Work = %trimr(Work) + ' ' +
       %trimr(SrcDS.ResultField) +
       ' = %xfoot(' +
       %trimr(SrcDS.Factor2) + ')';
       endsr;
 
       //---------------------------------------------------------
       begsr srOCCUR;
       Work = 'eval';
       xx = %scan('(': SrcDS.OpCode);
 1b    if xx > 0;
          Work = %trimr(Work) +  %subst(SrcDS.OpCode: xx);
 1e    endif;
 1b    if SrcDS.Factor1 > *blanks;
          Work = %trimr(Work) +
          ' %occur(' +
          %trimr(SrcDS.Factor2) +
          ') = ' + SrcDS.Factor1;
 1x    else;
          Work = %trimr(Work) +
          ' ' +
          %trimr(SrcDS.ResultField) +
          ' = %occur(' +
          %trimr(SrcDS.Factor2) + ')';
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       begsr srOutput;
 1b    if UpOneLevel;
          LevelsDeep -= 1;
 1e    endif;
 
       // deal with indenting code under WHEN, OTHER statement
 1b    if (OpUp = 'WHEN'
          or OpUp = 'OTHER')
          and
          IsWhenIndent = *on;
          LevelsDeep -= 1;
 1e    endif;
 
       LineOfCode = *blanks;
       xx = 1;
 1b    for yy = 1 to LevelsDeep;
 2b       if xx <= 109; // less than 37 levels deep
             %subst(LineOfCode: xx: 3) = *blanks;
 2e       endif;
          xx += 3;
 1e    endfor;
 
       // deal with indenting code under WHEN, OTHER statement
 1b    if OpUp = 'WHEN '
          or OpUp = 'OTHER';
          LevelsDeep += 1;
          IsWhenIndent = *on;
 1e    endif;
 
       // deal with lines ending in AND , OR , + , or :
       %subst(LineOfCode: xx) = Work;
       WorkUpper = %xlate(lo: up: Work);
       aa = %checkr(' ': WorkUpper);
 
 1b    if LineOfCode > *blanks
          and (aa > 3
          and (not IsComment)
          and (not IsSQL)
          and not(%subst(WorkUpper: aa: 1) = '+'
          or %subst(WorkUpper: aa: 1) = ':'
          or %subst(WorkUpper: aa: 1) = '<'
          or %subst(WorkUpper: aa: 1) = '>'
          or %subst(WorkUpper: aa: 1) = '='
          or %subst(WorkUpper: aa: 1) = '('
          or %subst(WorkUpper: aa - 3: 4) = ' AND'
          or %subst(WorkUpper: aa - 2: 3) = ' OR'));
          LineOfCode = %trimr(LineOfCode) + ';';
 1e    endif;
 
       // Tack on comment field
 1b    if SrcDS.SrcComment > *blanks
          and not IsComment;
 
 2b       if %subst(LineOfCode: 91: 2) = '  ';  //leave comments as is
             %subst(LineOfCode: 91: 2) = '//';
             %subst(LineOfCode: 93: 20) = SrcDS.SrcComment;
 2x       else;
             LineOfCode = %trimr(LineOfCode) + '  // ' + SrcDS.SrcComment;
 2e       endif;
 1e    endif;
 
 1b    if DownOneLevel;  //INDENT?
          LevelsDeep += 1;
 1e    endif;
 
 1b    if SrcDS.SlashComment > *blanks and not
          (%subst(SrcDS.SlashComment: 1: 1) = '/'
          or %subst(SrcDS.SlashComment: 1: 1) = '+'
          or %subst(SrcDS.SlashComment: 1: 1) = '*');
          LineOfCode = '??' +
          SrcDS.SlashComment +
          '???????   ' +
          LineOfCode;
 
          OpUpsave = OpUp;
          OpUp = 'LevelInd';
          exsr srLoadError;
          OpUp = OpUpsave;
 1e    endif;
 
 1b    if SrcDS.Conditioning > *blanks and not
          (%subst(SrcDS.SlashComment: 1: 1) = '/'
          or %subst(SrcDS.SlashComment: 1: 1) = '+'
          or %subst(SrcDS.SlashComment: 1: 1) = '*');
          LineOfCode = '??' +
          SrcDS.Conditioning +
          '???????   ' +
          LineOfCode;
 
          OpUpsave = OpUp;
          OpUp = 'ConditInd';
          exsr srLoadError;
          OpUp = OpUpsave;
 1e    endif;
 
 1b    if OpUp = 'KLIST' or OpUp = 'KFLD';
          LineOfCode = SrcDS.Src112;
 1e    endif;
       write PrtCspec;
       endsr;
