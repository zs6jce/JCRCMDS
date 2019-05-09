       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCR5FREER - Convert V4 fixed column calc specs into V5 /free format
       // There is no 100% V4 fixed format to V5 free conversion tool.
       // Many differences between the two cannot be solved by a utility.
       //  Suggested read Path to /Free on the website.
       //
       // This program takes v4 fixed format calc specs that has
       //  been purposely written to cleanly convert into free format.
       // Use JCRFREESS utility to identify and then fix everything
       // that cannot be converted, before using this (or any) utility.
       //---------------------------------------------------------
       // Areas that will need manual modification after convert:
       // lookup opcodes will need to be scrutinized
       // and tested.  %found and %equal bif not set by lookup operation
       // It is good bet some code will have to be rewritten.
       //
       // ForCountxx FOR counter that is created will need a definition.
       // Be aware, Multiple line IF, WHEN, etc  statements that
       // do not end with AND or OR, are incorrectly flagged as
       // stand alone statements. After conversion, edit code
       // to remove unneeded ;.
       // example
       //       C    if     a=b
       //       C             or c=d
       // will convert to
       //            if a=b;
       //                 or c=d;
       // will need editing to be correct.
       // END opcodes will not match newly generated FOR, without JCRNUMB utility.
       //---------------------------------------------------------
       /define ControlStatements
       /define Constants
       /define f_GetQual
       /define f_IsCompileTimeArray
       /define f_SndCompMsg
       // *ENTRY
       /define p_JCR5FREER
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f V4SRC disk(112) extfile(extifile) extmbr(p_inmbr) usropn;
       dcl-f V5SRC disk(112) usage(*output) extfile(extofile) extmbr(p_outmbr)
       usropn;
 
       dcl-s F2upper like(f2);
       dcl-s RFupper like(rf);
       dcl-s SrcOut like(Src112);
       dcl-s Work like(Src112);
       dcl-s WorkUpper like(Src112);
       dcl-s LF2 char(14);
       dcl-s LineOfCode char(112);
       dcl-s NewOpCode varchar(10);
       dcl-s OpCode varchar(10);
       dcl-s opupsave char(10);
       dcl-s SrcCspec char(100);
       dcl-s toOpCode varchar(10) dim(999);
       dcl-s User char(6);
       dcl-s zz char(14);
       dcl-s ii int(10);
       dcl-s kk int(10);
       dcl-s SrcDat zoned(6);
       dcl-s SrcSeq zoned(6: 2);
       dcl-s LevelsDeep uns(5);
       dcl-s xx uns(5);
       dcl-s yy uns(5);
       dcl-s StartPosition uns(3) inz(10);
       dcl-s IndentPerLevel uns(3) inz(3);
       dcl-s DownOneLvl ind;
       dcl-s IsArray ind;
       dcl-s IsCalcSpec ind;
       dcl-s IsCallp ind;
       dcl-s IsCasxx ind;
       dcl-s IsContinuation ind;
       dcl-s IsFree ind;
       dcl-s IsLastTime ind inz(*on);
       dcl-s IsOutputSpec ind;
       dcl-s IsWhenIndent ind;
       dcl-s UpOneLvl ind;
       dcl-s IsComment ind;
       dcl-s IsFirstTime ind;
 
       dcl-ds OPup len(10);
        DoIfWh char(2) pos(1);
        EndOpcode char(3) pos(1);
       end-ds;
 
       //--*INPUT SPECS-------------------------------------------
     Iv4Src     ns
     I                             s    7   12 0chgDate
     I                             a   13   15  CompileArry
     I                             a   13  112  Src112
     I                             a   18   18  SpecType
     I                             a   19   19  Asterisk
     I                             a   19   20  LevlInd
     I                             a   22   23  CondInd
     I                             a   38   47  OP
     i                             a   24   37  F1
     i                             a   48   61  F2
     i                             a   48   92  ExtF2
     i                             a   62   75  RF
     i                             a   83   84  HIind
     i                             a   85   86  LOind
     i                             a   87   88  EQind
     i                             a   83   88  ResultingInd
     i                             a   93  112  SrcComment
       //---------------------------------------------------------
 
       extIfile = f_GetQual(p_InFileQual);
       extOfile = f_GetQual(p_OutFileQual);
       open v4Src;
       open v5Src;
 
       read v4Src;
 1b    dow not %eof;
 2b       if f_IsCompileTimeArray(CompileArry);
             IsArray = *on;
 2e       endif;
 
 2b       if not IsArray;
 3b          if not %eof;
                clear NewOpCode;
 
                //---------------------------------------------------------
                // check for continuation line, indicated by
                // colon at first non-blank position of
                // next line, e.g.:  msg = f_inzmsg('CPF9898'
                //                          :'Hello World|')
                //---------------------------------------------------------
                IsContinuation = *off;
 
                read v4Src;
 4b             if not %eof;
 5b                if SpecType = 'C' or SpecType = 'c';
                      ii = %check(' ': Src112: 19);
 6b                   if ii > 0;
 7b                      if %subst(Src112: ii: 1) = ':';
                            IsContinuation = *on;
 7e                      endif;
 6e                   endif;
 5e                endif;
                   readp  v4Src;
 4e             endif;
 3e          endif;
 
             // special code for GFD:
             // retain last change user and remove user
             // from comment field (user is added later)
             user = %subst(SrcComment: 15);
             %subst(SrcComment: 15) = '';
             %subst(Src112: 95) = '';
 
             // special code for GFD:
             // change op-code to lower case
             OP = %xlate(up: lo: OP);
 
             // ---------
 3b          if SpecType = 'C'
                or SpecType = 'c';
                IsCalcSpec = *on;
 4b             if not IsFirstTime;
                   IsFirstTime = *on;
                   // write a blank line
                   SrcCspec = '';
                   SrcSeq = SrcSeq + .01;
                   SrcDat = 0;
                   except CSPEC;
                   IsFree = *on;
 4e             endif;
 3e          endif;
 
 3b          if SpecType = 'D'
                or SpecType = 'd'
                or SpecType = 'F'
                or SpecType = 'f';
                IsCalcSpec = *off;
 3e          endif;
 
 3b          if SpecType = 'P'
                or SpecType = 'p';
 4b             if IsFree;
                   IsLastTime = *off;
                   IsFirstTime = *off;
                   IsCalcSpec = *off;
                   exsr srCommentLine;
                   IsFree = *off;
 4e             endif;
 3e          endif;
 
             // end-free after 1st o spec only
 3b          if SpecType = 'O'
                or SpecType = 'o';
 4b             if IsFree;
                   IsLastTime = *off;
                   IsFirstTime = *off;
                   IsCalcSpec = *off;
 5b                if not IsOutputSpec;
                      exsr srCommentLine;
                      IsFree = *off;
                      IsOutputSpec = *on;
 5e                endif;
 4e             endif;
 3e          endif;
 
             //---------------------------------------------------------
 2e       endif;
 2b       if IsArray or not IsCalcSpec;
             SrcSeq += .01;
             SrcOut = Src112;
             SrcDat = chgdate;
             except writenonC;
 2x       else;
             DownOneLvl = *off;
             UpOneLvl = *off;
 
 3b          if not(Asterisk = '+' or     //no sql
                Asterisk = '/');  //no copy statements
 4b             if op > *blanks;
                   IsCallp = *off;
 4e             endif;
 
                OPup = %xlate(lo: up: OP);
 4b             if Asterisk = '*';
 
 4x             elseif EndOpcode = 'CAS';
                   IsCasxx = *on;
 
 4x             elseif OPup = 'SELECT';
                   //        DownOneLvl = *on;
                   IsWhenIndent = *off;
 
 4x             elseif DoIfWh = 'DO'
                   or DoIfWh = 'IF'
                   or OPup = 'BEGSR'
                   or OPup = 'FOR'
                   or OPup = 'MONITOR'
                   or %subst(OPup: 1: 4) = 'FOR(';
                   DownOneLvl = *on;
 
                   //---------------------------------------------------------
                   // Set Flag if END is found
 4x             elseif EndOpcode = 'END';
 5b                if not IsCasxx;
                      UpOneLvl = *on;
 5e                endif;
                   IsCasxx = *off;
 4e             endif;
 3e          endif;
 
             //---------------------------------------------------------
             // Convert EVERYTHING to free format
             //---------------------------------------------------------
             Work = *blanks;
             LineOfCode = *blanks;
             IsComment = *off;
 
 3b          if Asterisk = '*';
 4b             if %subst(Src112: 8) = *blanks;
                   Work = *blanks;
 4x             else;
                   work = '// ' + %triml(%subst(Src112: 8));
                   IsComment = *on;
 4e             endif;
 
 3x          elseif LevlInd = '/E' or  //i hate ejects
                LevlInd = '/e';
                Work = *blanks;
 
                // there is no /free equivalent for these opcodes.  List as is.
                //---------------------------------------------------------
                // All DO statements must be converted to FOR opcodes
                // There are 5 variations of on DO
                // DO              =  DOU '1'
                // DO  xx          =  FOR ForCount = 1 to xx
                // DO  xx   yy     =  FOR yy = 1 to xx
                // aa   DO  xx          =  FOR ForCount = aa to xx
                // aa   DO  xx   yy     =  FOR yy = aa to xx
                //---------------------------------------------------------
 3x          elseif OPup = 'DO';
 
 4b             if F1 > *blanks     //aa DO xx yy
                   and F2 > *blanks
                   and RF  > *blanks;
                   work = 'for ' + %trimr(RF) + ' = ' +
                   %trimr(F1) + ' to ' + F2;
                   NewOpCode = 'endfor';
 
 4x             elseif F1 > *blanks      //aa DO xx
                   and F2 > *blanks
                   and RF = *blanks;
                   work = 'for ForCount' + %char(LevelsDeep) + ' = ' +
                   %trimr(F1) + ' to ' + F2;
                   NewOpCode = 'endfor';
 
 4x             elseif F1 = *blanks
                   and F2 > *blanks
                   and RF  > *blanks;
                   work = 'for ' + %trimr(RF) + ' = 1 to ' + F2;
                   NewOpCode = 'endfor';
 
 4x             elseif F1 = *blanks
                   and F2 > *blanks
                   and RF = *blanks;
                   work = 'for ForCount' + %char(LevelsDeep) +
                   ' = 1 to ' + F2;
                   NewOpCode = 'endfor';
 
 4x             elseif F1 = *blanks
                   and F2 = *blanks
                   and RF = *blanks;
                   work = 'dou ''''1''''';
 4e             endif;
 
 3x          elseif %subst(OPup: 1: 6) = 'ADDDUR'
                or %subst(OPup: 1: 6) = 'SUBDUR';
                exsr srADDDUR;
 
 3x          elseif %subst(OPup: 1: 6) = 'EXTRCT';
                work = %trimr(RF) + ' = %subdt(' + %trimr(F2) + ')';
 
 3x          elseif %subst(OPup: 1: 5) = 'CHECK';
                work = %trimr(RF) + ' = %' + %trimr(OP) + '(' +
                %trimr(F1) + ':' + %trimr(F2) + ')';
 
 3x          elseif %subst(OPup: 1: 5) = 'XLATE';
                work = %trimr(RF) + ' = %' + %trimr(OP) + '(' +
                %trimr(F1) + ':' + %trimr(F2) + ')';
 
 3x          elseif %subst(OPup: 1: 6) = 'LOOKUP';
                exsr srLOOKUP;
 
 3x          elseif %subst(OPup: 1: 5) = 'XFOOT';
                exsr srXFOOT;
 
 3x          elseif %subst(OPup: 1: 5) = 'OCCUR';
                exsr srOCCUR;
 
                //---------------------------------------------------------
                // FACTOR1  OP  FACTOR2  RESULT conversions.
                // FACTOR1  OP  FACTOR2
                // FACTOR1  OP
                // end result is opcode factor1  factor2  Result
                //---------------------------------------------------------
 3x          elseif %subst(OPup: 1: 3) = 'ACQ'
                or OPup = 'BEGSR'
                or OPup = 'MONITOR'
                or OPup = 'ON-ERROR'
                or %subst(OPup: 1: 5) = 'CHAIN'
                or %subst(OPup: 1: 6) = 'COMMIT'
                or %subst(OPup: 1: 6) = 'DELETE'
                or %subst(OPup: 1: 5) = 'DSPLY'
                or %subst(OPup: 1: 4) = 'DUMP'
                or %subst(OPup: 1: 4) = 'POST'
                or %subst(OPup: 1: 3) = 'END'
                or %subst(OPup: 1: 3) = 'IN '
                or %subst(OPup: 1: 3) = 'IN('
                or %subst(OPup: 1: 4) = 'NEXT'
                or %subst(OPup: 1: 3) = 'OUT'
                or %subst(OPup: 1: 4) = 'POST'
                or %subst(OPup: 1: 5) = 'READE'
                or %subst(OPup: 1: 6) = 'READPE'
                or %subst(OPup: 1: 3) = 'REL'
                or %subst(OPup: 1: 5) = 'RESET'
                or OPup = 'CLEAR '
                or %subst(OPup: 1: 5) = 'ROLBK'
                or %subst(OPup: 1: 5) = 'SETGT'
                or %subst(OPup: 1: 5) = 'SETLL'
                or %subst(OPup: 1: 5) = 'TEST '
                or %subst(OPup: 1: 5) = 'TEST('
                or %subst(OPup: 1: 6) = 'UNLOCK';
 4b             if F1 = *blanks;
                   work = %trimr(OP) + ' ' +  %trimr(F2) + ' ' + RF;
 4x             else;
                   work = %trimr(OP) + ' ' +
                   %trimr(F1) + ' ' + %trimr(F2) + ' ' + RF;
 4e             endif;
                // resulting ind errors
 4b             if ResultingInd > *blanks;
                   work = %trimr(Work) + '    ??' + %trim(ResultingInd) +
                   '????????????????';
                   opupsave = opup;
                   opup = 'ResultInd';
                   opup = opupsave;
 4e             endif;
 
                //---------------------------------------------------------
                // opcode FACTOR2  RESULT conversions.
                // opcode FACTOR2
                // end result is Opcode Factor2  Result
                //---------------------------------------------------------
 3x          elseif OPup = 'EXCEPT'
                or OPup = 'EXFMT'
                or OPup = 'EXSR'
                or OPup = 'ELSE'
                or OPup = 'FORCE'
                or OPup = 'ITER'
                or OPup = 'LEAVE'
                or OPup = 'LEAVESR'
                or OPup = 'OTHER'
                or %subst(OPup: 1: 5) = 'CLOSE'
                or %subst(OPup: 1: 4) = 'OPEN'
                or %subst(OPup: 1: 5) = 'READ '
                or %subst(OPup: 1: 5) = 'READ('
                or %subst(OPup: 1: 5) = 'READC'
                or %subst(OPup: 1: 5) = 'READP'
                or OPup = 'SELECT'
                or OPup = 'SORTA'
                or %subst(OPup: 1: 6) = 'UPDATE'
                or %subst(OPup: 1: 5) = 'WRITE'
                or %subst(OPup: 1: 4) = 'FEOD';
                work = %trimr(OP) + ' ' +
                %trimr(F2) + ' ' + RF;
 4b             if ResultingInd > *blanks;
                   work = %trimr(Work) + '    ??' + %trim(ResultingInd) +
                   '????????????????';
                   opupsave = opup;
                   opup = 'ResultInd';
                   opup = opupsave;
 4e             endif;
 
                //---------------------------------------------------------
                //  Opcode RESULT field simple compressions
                //---------------------------------------------------------
 3x          elseif %subst(OPup: 1:7) = 'DEALLOC';
                work = %trimr(OP) + ' ' + RF;
 
                //---------------------------------------------------------
                // opcode Extended Factor2 compressions
                // Will need to revisit this for + signs to line up code.
                //---------------------------------------------------------
 3x          elseif %subst(OPup: 1: 4) = 'DOU '
                or %subst(OPup: 1: 4) = 'DOU('
                or %subst(OPup: 1: 5) = 'DOWNE'
                or %subst(OPup: 1: 5) = 'DOUNE'
                or %subst(OPup: 1: 4) = 'DOW '
                or %subst(OPup: 1: 4) = 'DOW('
                or %subst(OPup: 1: 5) = 'CALLP'
                or %subst(OPup: 1: 4) = 'EVAL'
                or %subst(OPup: 1: 4) = 'FOR '
                or %subst(OPup: 1: 4) = 'FOR('
                or %subst(OPup: 1: 3) = 'IF '
                or %subst(OPup: 1: 3) = 'IF('
                or %subst(OPup: 1: 6) = 'RETURN'
                or %subst(OPup: 1: 5) = 'WHEN '
                or %subst(OPup: 1: 5) = 'WHEN(';
                work = %trimr(OP) + ' ' + ExtF2;
                // get position for callp parms to line up with factor2
                bb = %scan(ExtF2: Work);
 4b             if %subst(OPup: 1: 5) = 'CALLP';
                   IsCallp = *on;
 4e             endif;
 3x          else;
                //---------------------------------------------------------
 4b             if OPup = *blanks;
 5b                if not IsCallp;
                      work = ExtF2;
 5x                else;
                      Work = *blanks;
                      %subst(Work: bb) = %trimr(ExtF2);
 5e                endif;
 4x             else;
                   work = %trimr(OP) + ' ?????????????????????????';
 4e             endif;
 3e          endif;
             exsr srOutput;
 2e       endif;
 
          read v4Src;
 1e    enddo;
 1b    if IsLastTime;
 2b       if IsFree;
             // SrcCspec = '      /END-FREE';
             // SrcSeq = SrcSeq + .01;
             // SrcDat = 0;
             // except CSPEC;
             exsr srCommentLine;
             IsFree = *off;
 2e       endif;
 1e    endif;
       close v4Src;
       close v5Src;
       f_SndCompMsg('RPGLE /free mbr ' +%trimr(p_OutMbr) + ' generated.');
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       begsr srADDDUR;
       f2upper = %xlate(lo: up: f2);
       rfupper = %xlate(lo: up: RF);
       work = *blanks;
 1b    if OPup = 'ADDDUR(E)'
          or OPup = 'SUBDUR(E)';
          work = 'eval(e) ';
 1e    endif;
       xx = %scan(':': F2);
 1b    if xx > 0;
          work = %trimr(Work) + ' ' + %trimr(RF) + ' =';
 2b       if F1 = *blank;
             work = %trimr(Work) + ' ' + RF;
 2x       else;
             work = %trimr(Work) + ' ' + F1;
 2e       endif;
 2b       if %subst(OPup: 1: 6) = 'ADDDUR';
             work = %trimr(Work) + ' + ';
 2x       else;
             work = %trimr(Work) + ' - ';
 2e       endif;
          xx = %scan(':': F2);
 2b       if %subst(F2upper: xx + 1) = '*MSECONDS'
             or %subst(F2upper: xx + 1) = '*MS';
             work = %trimr(Work) + ' %mseconds(';
 2x       elseif %subst(F2upper: xx + 1) = '*SECONDS'
             or %subst(F2upper: xx + 1) = '*S';
             work = %trimr(Work) + ' %seconds(';
 2x       elseif %subst(F2upper: xx + 1) = '*MINUTES'
             or %subst(F2upper: xx + 1) = '*MN';
             work = %trimr(Work) + ' %minutes(';
 2x       elseif %subst(F2upper: xx + 1) = '*HOURS'
             or %subst(F2upper: xx + 1) = '*H';
             work = %trimr(Work) + ' %hours(';
 2x       elseif %subst(F2upper: xx + 1) = '*DAYS'
             or %subst(F2upper: xx + 1) = '*D';
             work = %trimr(Work) + ' %days(';
 2x       elseif %subst(F2upper: xx + 1) = '*MONTHS'
             or %subst(F2upper: xx + 1) = '*M';
             work = %trimr(Work) + ' %months(';
 2x       elseif %subst(F2upper: xx + 1) = '*YEARS'
             or %subst(F2upper: xx + 1) = '*Y';
             work = %trimr(Work) + ' %year(';
 2e       endif;
          work = %trimr(Work) + %subst(F2: 1: xx - 1) + ')';
 1x    else;
          //---------------------------------------------------------
          // Process DIFF statements
          // first extract field from RF
          //---------------------------------------------------------
          xx = %scan(':': RF);
          work = %trimr(Work) + ' ' + %subst(RF: 1: xx - 1) +
          ' = %diff(' + %trimr(F1) + ':' +
          %trimr(f2) + ':' +
          %trimr(%subst(rf: xx + 1)) + ')';
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       begsr srLOOKUP;
       zz = *blanks;
       lf2 = f2;
       f2upper = %xlate(lo: up: f2);
       work = *blanks;
 1b    if %subst(F2upper: 1: 3) = 'TAB';
          work = '*in' + %trim(ResultingInd) + ' = %tlookup';
 1x    else;
          xx = %scan('(': F2);
 2b       if xx = 0;
 3b          if (ResultingInd) > *blanks;
                work = '*in' + %trim(ResultingInd) + ' = %lookup';
 3x          else;
                work = 'jcrInt = %lookup';
 3e          endif;
 2x       else;
             yy = %scan(')': F2: xx);
             lf2 = %subst(f2: 1: xx - 1);
             zz = %subst(f2: xx + 1: yy - (xx + 1));
             work = %trimr(zz) + ' = %lookup';
 2e       endif;
 1e    endif;
 
       //---------------------------------------------------------
       // Now look at indicators assigned and tack on type lookup.
 1b    if EQind > *blanks
          and HIind = *blanks
          and LOind = *blanks;
 1x    elseif EQind = *blanks
          and HIind > *blanks
          and LOind = *blanks;
          work = %trimr(Work) + 'GT(';
 1x    elseif EQind = *blanks
          and HIind = *blanks
          and LOind > *blanks;
          work = %trimr(Work) + 'LT(';
 1x    elseif EQind > *blanks
          and HIind > *blanks
          and LOind = *blanks;
          work = %trimr(Work) + 'GE(';
 1x    elseif EQind > *blanks
          and HIind = *blanks
          and LOind > *blanks;
          work = %trimr(Work) + 'LE(';
 1x    else;
          work = %trimr(Work) + '??(';
 1e    endif;
       work = %trimr(Work) + %trimr(f1) + ':' +
       %trimr(lf2);
 1b    if %subst(F2upper: 1: 3) <> 'TAB';
 2b       if zz = *blanks;
             work = %trimr(Work) + ')';
 2x       else;
             work = %trimr(Work) + ':' + %trimr(zz) + ')';
 2e       endif;
 1x    else;
 2b       if RF = *blanks;
             work = %trimr(Work) + ')';
 2x       else;
             work = %trimr(Work) + ':' + %trimr(RF) + ')';
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       begsr srXFOOT;
       work = *blanks;
       xx = %scan('(': OP);
 1b    if xx > 0;
          work = %trimr(Work) +  %subst(OP: xx);
 1e    endif;
       work = %trimr(Work) + ' ' + %trimr(RF) +
       ' = %xfoot(' + %trimr(F2) + ')';
       endsr;
 
       //---------------------------------------------------------
       begsr srOCCUR;
       work = *blanks;
       xx = %scan('(': OP);
 1b    if xx > 0;
          work = %trimr(Work) +  %subst(OP: xx);
 1e    endif;
 1b    if F1 > *blanks;
          work = %trimr(Work) + ' %occur(' +
          %trimr(F2) + ') = ' + F1;
 1x    else;
          work = %trimr(Work) + ' ' + %trimr(RF) +
          ' = %occur(' + %trimr(F2) + ')';
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       begsr srOutput;
 1b    if UpOneLvl and LevelsDeep > 0;
 2b       if toOpCode(LevelsDeep) <> '';
             ii = %check(' ': Work);
 3b          if ii > 0;
                kk = %scan(' ': Work);
                Work = %replace(toOpCode(LevelsDeep): Work: ii: kk - ii);
 3e          endif;
 2e       endif;
          toOpCode(LevelsDeep) = '';
          LevelsDeep -= 1;
 1e    endif;
 
       //---------------------------------------------------------
       // come back up level for when and others
 1b    if (opup = 'WHEN'
          or opup = 'OTHER')
          and IsWhenIndent;
          LevelsDeep = LevelsDeep - 1;
 1e    endif;
       LineOfCode = *blanks;
       xx = (StartPosition - 7) + (LevelsDeep * IndentPerLevel);
 
       // deal with indenting code under WHEN, OTHER statement
 1b    if opup = 'WHEN'
          or opup = 'OTHER';
          LevelsDeep += 1;
          IsWhenIndent = *on;
 1e    endif;
 
 1b    if not IsComment;
          // special code for GFD:  strip out OpCode
 2b       if opup = 'CALLP';
             OpCode = 'CALLP';
             exsr srStripOpCode;
 2x       elseif opup = 'EVAL';
             OpCode = 'EVAL';
             exsr srStripOpCode;
 2e       endif;
 1e    endif;
 
       // deal with lines ending in AND / OR / +
       %subst(LineOfCode: xx) = Work;
       WorkUpper = %xlate(lo: up: Work);
       aa = %checkr(' ': WorkUpper);
 1b    if LineOfCode > *blanks
          and (aa > 3
          and IsComment = *off
          and not(%subst(WorkUpper: aa: 1) = '+'
          or %subst(WorkUpper: aa: 1) = ':'
          or %subst(WorkUpper: aa: 1) = '='
          or %subst(WorkUpper: aa: 1) = '>'
          or %subst(WorkUpper: aa: 1) = '<'
          or %subst(WorkUpper: aa: 1) = '('
          or %subst(WorkUpper: aa - 3: 4) = ' AND'
          or %subst(WorkUpper: aa - 2: 3) = ' OR'));
 2b       if not IsContinuation;
             LineOfCode = %trimr(LineOfCode) + ';';
 2e       endif;
 1e    endif;
 
       //---------------------------------------------------------
       // Tack on comment field
       //---------------------------------------------------------
 1b    if SrcComment > *blanks
          and  not IsComment;
 
 2b       if %subst(LineOfCode: 71: 8) = '       ';
             %subst(LineOfCode: 71: 2) = '//';
             %subst(LineOfCode: 73: 20) = SrcComment;
 2x       else;
             LineOfCode = %trimr(LineOfCode) + '  // ' + SrcComment;
 2e       endif;
 1e    endif;
 
       // special code for GFD:
 1b    if user > *blanks;
          %subst(LineOfCode: 86: 2) = '//';
          %subst(LineOfCode: 88: 6) = user;
 1e    endif;
 
 1b    if DownOneLvl;
          LevelsDeep = LevelsDeep + 1;
 2b       if NewOpCode <> '';
             toOpCode(LevelsDeep) = NewOpCode;
 2e       endif;
 1e    endif;
 
 1b    if LevlInd > *blanks and not
          (%subst(LevlInd: 1: 1) = '/'
          or %subst(LevlInd: 1: 1) = '*');
          LineOfCode = '??' + LevlInd + '???????   ' +
          LineOfCode;
          opupsave = opup;
          opup = 'LevelInd';
          opup = opupsave;
 1e    endif;
 
 1b    if CondInd > *blanks and not
          (%subst(LevlInd: 1: 1) = '/'
          or %subst(LevlInd: 1: 1) = '*');
          LineOfCode = '??' + CondInd + '???????   ' +
          LineOfCode;
          opupsave = opup;
          opup = 'ConditInd';
          opup = opupsave;
 1e    endif;
       SrcSeq += .01;
       SrcDat = chgDate;
 1b    if opup = 'KLIST'
          or opup = 'KFLD';
          evalr SrcCspec = Src112;
 1x    else;
          SrcCspec = '       '+LineOfCode;
 1e    endif;
       except CSPEC;
       endsr;
 
       //---------------------------------------------------------
       // STRIP OPCODE
       //---------------------------------------------------------
       begsr srStripOpCode;
       ii = %check(' ': Work);  //determine start position of OpCode
 1b    if ii > 0;
          kk = ii + %len(OpCode);  //set pointer after OpCode
 2b       if %subst(Work: kk: 1) = '';
             kk = %check(' ': Work: kk);  //find next character
 2e       endif;
 2b       if kk > 0;
 3b          if %subst(Work: kk: 1) <> '(';  //check for '('
                Work = %replace('': Work: ii: kk - ii);
 3e          endif;
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Write comment line
       //---------------------------------------------------------
       begsr srCommentLine;
       SrcCspec = '      *';
       SrcSeq += .01;
       SrcDat = 0;
       except CSPEC;
       endsr;
 
     Ov5Src     e            writenonC
     O                       SrcSeq               6
     O                       SrcDat              12
     O                       SrcOut             112
 
     Ov5Src     e            CSPEC
     O                       SrcSeq               6
     O                       SrcDat              12
     O                       SrcCspec           112
