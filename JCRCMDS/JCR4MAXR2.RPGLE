       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCR4MAXR2 - convert codes to EVAL
       // Convert character Fields and Constant  moves to EVAL
       // MOVE rules are:   %size(Factor2) = %size(Result)
       //
       // MOVEL rules are:  %size(Factor2) = %size(Result) or
       //                   %size(Factor2) > %size(Result)
       //
       // Z-ADD rules are:  %size(Factor2) = %size(Result) or
       //                   %size(Factor2) > %size(Result)
       //
       // Z-SUB rules are:  same as z-add except no *zeros
       //
       // ADD rule :        %size(Factor1) < %size(Result) and
       //                   %size(Factor2) < %size(Result)
       //
       // MULT rule :       %size(Factor1) < %size(Result) and
       //                   %size(Factor2) < %size(Result)
       //---------------------------------------------------------
       /define ControlStatements
       /define FieldsArry
       /define Constants
       /define FieldsAttrDS
       /define p_JCRGETFLDR
       /COPY JCRCMDS,JCRCMDSCPY
 
     FMODIFYSRC UP   F  112        DISK
 
       dcl-s ExtendedF2 char(45);
       dcl-s Factor1typ char(1);
       dcl-s Factor2typ char(1);
       dcl-s NewOpcode char(10);
       dcl-s ResultType char(1);
       dcl-s WorkInd char(2);
       dcl-s WorkTyp char(1);
       dcl-s IsZeroBlank ind;
       dcl-s Factor1dec zoned(2);
       dcl-s Factor2dec zoned(2);
       dcl-s ResultDec zoned(2);
       dcl-s WorkDec zoned(2);
       dcl-s Factor1len uns(5);
       dcl-s Factor2len uns(5);
       dcl-s nn uns(5);
       dcl-s ResultLen uns(5);
       dcl-s WorkLen uns(5);
       dcl-s xx uns(5);
       dcl-s PepCnt packed(3);
 
       dcl-ds Work5 inz;
        fact1value zoned(5) pos(1);
       end-ds;
 
       dcl-ds FactorxDS qualified;
        First1 char(1) pos(1);
        First3 char(3) pos(1);
        IsLookup char(14) pos(1);
       end-ds;
 
       dcl-ds *n inz;
        Src char(92) pos(1);
        SrcFactor1 char(14) pos(24);
        SrcF1p1 char(1) overlay(SrcFactor1:1);
        SrcOpcode char(10) pos(38);
        opmove char(4) overlay(SrcOpcode:1);
        opsub char(4) overlay(SrcOpcode:1);
        opz_ char(2) overlay(SrcOpcode:1);
        opsubst char(5) overlay(SrcOpcode:1);
        SrcFactor2 char(14) pos(48);
        SrcResult char(14) pos(62);
        resltlook char(14) overlay(SrcResult:1);
        reslt_in char(3) overlay(SrcResult:1);
        SrcLength char(1) pos(80);
        SrcRstind char(6) pos(83);
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_SrcMbr char(10);
        p_SrcFil char(10);
        p_SrcLib char(10);
        p_DiagSeverity char(10);
       end-pi;
 
       //--*INPUT SPECS-------------------------------------------
     ImodifySrc ns  01   18 cC   19nc*   19nc/
     I         and               19nc+
     I         or        18 cc   19nc*   19nc/
     I         and               19nc+
     I                             a    1   92  Src
     I                             a   24   37  updFactor1
     I                             a   48   61  updFactor2
     I                             a   62   75  updResult
     I                             a   83   84  highind
     I                             a   85   86  lowind
     I                             a   87   88  equalind
     I          ns  05
 
       //---------------------------------------------------------
 
       // If a calc record spec
 1b    if *in01
          and SrcLength = *blanks;
          SrcOpcode = %xlate(lo: up: SrcOpcode);
 
 2b       if SrcRstind = *blanks
             AND (SrcOpcode = 'MOVE'
             or SrcOpcode = 'MOVEL'
             or SrcOpcode = 'MOVEL(P)'
             or SrcOpcode = 'MOVE(P)'
             or SrcOpcode = 'Z-ADD'
             or SrcOpcode = 'Z-SUB'
             or SrcOpcode = 'SUB'
             or SrcOpcode = 'ADD'
             or SrcOpcode = 'MULT'
             or SrcOpcode = 'MULT(H)'
             or SrcOpcode = 'SUBST'
             or SrcOpcode = 'SUBST(P)');
 
             //---------------------------------------------------------
             // Determine field sizes of Factor1, 2, Result Field
             //---------------------------------------------------------
             IsZeroBlank = *off;
             Src = %xlate(lo: up: Src);
 3b          if SrcFactor1 > *blanks;
                Factor1len = 0;
                FactorxDS = SrcFactor1;
                exsr srFact1Fact2;  //Get size of factor 1
                Factor1len = WorkLen;
                Factor1dec = WorkDec;
                Factor1typ = WorkTyp;
 3e          endif;
 
 3b          if SrcFactor2 = '*ON' or SrcFactor2 = '*OFF';
                Factor2len = 1;
                Factor2dec = 0;
                Factor2typ = 'A';
 3x          else;
                FactorxDS = SrcFactor2;
                exsr srFact1Fact2;  //Get size of factor 2
                Factor2len = WorkLen;
                Factor2dec = WorkDec;
                Factor2typ = WorkTyp;
 3e          endif;
 
             //---------------------------------------------------------
             // Get attributes of Result field
             //---------------------------------------------------------
 3b          if reslt_in = '*IN';
                Resultlen = 1;
                Resultdec = 0;
                ResultType = 'A';
 3x          else;
                nn=%lookup(resltlook: FieldsArry(*).Name: 1: FieldsArryCnt);
 4b             if nn = 0;
                   bb = %scan('(': SrcResult: 1);
 5b                if bb > 0;
                      resltlook = %subst(SrcResult: 1: (bb - 1));
                      nn = %lookup(resltlook: FieldsArry(*).Name: 1:
                      FieldsArryCnt);
 5e                endif;
 4e             endif;
 
 4b             if nn > 0;
                   FieldsAttrDS = FieldsArry(nn).Attr;
                   Resultlen = FieldsAttrDS.Length;
 5b                if FieldsAttrDS.DecimalPos = *blanks;
                      Resultdec = 0;
 5x                else;
                      Resultdec = FieldsAttrDS.DecimalPosN;
 5e                endif;
                   ResultType = FieldsAttrDS.DataType;
 4e             endif;
 3e          endif;
             exsr srMakeEval;
 2e       endif;
 
          //---------------------------------------------------------
          // Convert SETON and SETOF opcodes to move *ON or move *OFF
          //---------------------------------------------------------
 2b       if SrcOpcode = 'SETON' or SrcOpcode = 'SETOFF';
             WorkInd = *blanks;
 
 3b          if highind > *blanks
                and lowind = *blanks
                and equalind = *blanks;
                WorkInd = highind;
 3x          elseif highind = *blanks
                and lowind > *blanks
                and equalind = *blanks;
                WorkInd = lowind;
 3x          elseif highind = *blanks
                and lowind = *blanks
                and equalind > *blanks;
                WorkInd = equalind;
 3e          endif;
 
             // Match proper constant to type opcode
 3b          if WorkInd > *blanks;
                NewOpcode = 'EVAL';
 
 4b             if SrcOpcode = 'SETON';
                   ExtendedF2 = '*in' + WorkInd + ' = *on';
 4x             else;
                   ExtendedF2 = '*in' + WorkInd + ' = *off';
 4e             endif;
                except updateSrc;
 3e          endif;
 2e       endif;
 1e    endif;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srMakeEval;
 1b    if IsZeroBlank or
       (Factor2typ <> 'B'   and       //weird things
          ResultType <> 'B'   and       //with binary
          Factor2typ <> *blank);     // probable *DATE or *TIME
          NewOpcode = 'EVAL   ';
 
          // Convert MOVE BOOLEAN values to eval opcode
          //  Convert '1' to *on, '0' to *off
 2b       if SrcOpcode = 'MOVE' and  SrcLength = ' '
             and ResultType = 'A'
             and Resultlen = 1
             and (SrcFactor2 = '*ON'
             or SrcFactor2 = '*OFF'
             or SrcFactor2 = '''1'''
             or SrcFactor2 = '''0''');
 
 3b          if SrcFactor2 = '''1''';
                ExtendedF2 = %trimr(updResult) + ' = *on';
 3x          elseif SrcFactor2 = '''0''';
                ExtendedF2 = %trimr(updResult) + ' = *off';
 3x          else;
                ExtendedF2 = %trimr(updResult) + ' = ' +
                updFactor2;
 3e          endif;
             except updateSrc;
             //---------------------------------------------------------
 2x       elseif IsZeroBlank = *on
             and (opmove = 'MOVE'
             or SrcOpcode = 'Z-ADD');
 
 3b          if ResultType <> 'A';
                updFactor2 = '*ZEROS';
 
 3x          elseif updFactor2 = '*BLANK';
                updFactor2 = '*BLANKS';
 
 3x          elseif updFactor2 = '*ZERO';
                updFactor2 = '*ZEROS';
 3e          endif;
             exsr srUpdateCode;
             //---------------------------------------------------------
 2x       elseif Factor2typ = ResultType
             and ResultType = 'A'
             and Factor2len <= Resultlen
             and SrcOpcode = 'MOVEL(P) '
             OR
             Factor2typ = ResultType
             and Factor2dec = Resultdec
             and Factor2len = Resultlen
             and (opmove = 'MOVE'  or opz_ = 'Z-')
             OR
             opz_ = 'Z-'
             and ((Factor2len - Factor2dec) <=
             (Resultlen - Resultdec));
             exsr srUpdateCode;
             //---------------------------------------------------------
 2x       elseif opsub = 'SUB';
 3b          if SrcFactor1 = *blanks
                and ((Factor2len - Factor2dec) <=
                (Resultlen - Resultdec));
                ExtendedF2 = %trimr(updResult) + ' = ' +
                %trimr(updResult) + ' - ' + updFactor2;
                except updateSrc;
 
 3x          elseif SrcFactor1 > *blanks
                and ((Factor1len - Factor1dec) <=
                (Resultlen - Resultdec))
                and ((Factor2len - Factor2dec) <=
                (Resultlen - Resultdec));
                ExtendedF2 = %trimr(updResult) + ' = ' +
                %trimr(updFactor1) + ' - ' + updFactor2;
                except updateSrc;
 3e          endif;
             //---------------------------------------------------------
 2x       elseif opsub = 'ADD' and SrcFactor1 > *blanks;
 3b          if ((Factor1len - Factor1dec) <
                (Resultlen - Resultdec))
                and ((Factor2len - Factor2dec) <
                (Resultlen - Resultdec));
                ExtendedF2 = %trimr(updResult) + ' = ' +
                %trimr(updFactor1) + ' + ' + updFactor2;
                except updateSrc;
 3e          endif;
 
 2x       elseif opsub = 'MULT' and SrcFactor1 > *blanks;
 3b          if (((Factor1len - Factor1dec) +
                (Factor2len - Factor2dec)) <=
                (Resultlen - Resultdec));
                ExtendedF2 = %trimr(updResult) + ' = ' +
                %trimr(updFactor1) + ' * ' + updFactor2;
 
 4b             if SrcOpcode = 'MULT(H)';
                   NewOpcode = 'EVAL(H)';
 4e             endif;
                except updateSrc;
 3e          endif;
 
             //---------------------------------------------------------
             // Convert substring (padded) opcodes to Eval
             //---------------------------------------------------------
 2x       elseif opsubst = 'SUBST'
             and SrcLength = ' '
             and SrcFactor1 > *blanks;
 
 3b          if SrcOpcode = 'SUBST(P)';
                NewOpcode = 'eval';
 
                // If Factor2 does not not contain starting location
                // signified by :  then make start pos = 1.
                xx = %scan(':': updFactor2: 1);
 4b             if xx > 0;
                   ExtendedF2 = %trimr(updResult) + ' = %subst(' +
                   %trim(updFactor2) + ':' + %trim(updFactor1) + ')';
 4x             else;
                   ExtendedF2 = %trimr(updResult) + ' = %subst(' +
                   %trim(updFactor2) + ': 1:' + %trim(updFactor1) + ')';
 4e             endif;
                except updateSrc;
 3x          else;
 4b             if SrcF1p1 >= '0'
                   and SrcF1p1 <= '9'
                   and Factor1len < 6;
                   Work5 = %subst('00000': 1: 5 - Factor1len) +
                   %subst(updFactor1: 1: Factor1len);
 
 5b                if Work5 = *blanks;
                      fact1value = 0;
 5e                endif;
 5b                if fact1value >= Resultlen;
                      ExtendedF2 = %trimr(updResult) + ' = %subst(' +
                      %trim(updFactor2) + ':' + %trim(updFactor1) + ')';
                      except updateSrc;
 5e                endif;
 4e             endif;
 3e          endif;
 2e       endif;
 1e    endif;
 
       IsZeroBlank = *off;
       endsr;
 
       //---------------------------------------------------------
       // Build extended factor 2 and update source record
       //---------------------------------------------------------
       begsr srUpdateCode;
 1b    if SrcOpcode <> 'Z-SUB  ';
          ExtendedF2 = %trimr(updResult) + ' = ' +
          (updFactor2);
 1x    else;
          ExtendedF2 = %trimr(updResult) + ' = -(' +
          %trimr(updFactor2) + ')';
 1e    endif;
       except updateSrc;
       endsr;
 
       //---------------------------------------------------------
       // Determine field sizes of Factor1 and Factor2
       //---------------------------------------------------------
       begsr srFact1Fact2;
       WorkTyp = *blanks;
       WorkLen = 0;
       WorkDec = 0;
 
 1b    if FactorxDS.First1 = '''';  //CONSTANT
 2b       if %subst(FactorxDS: 14: 1) = '''';
             WorkLen = 12;
 2x       elseif %subst(FactorxDS: 1: 2) = ''''
             and %subst(FactorxDS: 1: 3) = ''''
             and %subst(FactorxDS: 1: 4) = '''';
             WorkLen = 1;
 2x       else;
             bb = %checkr(' ': FactorxDS);
             WorkLen = (bb - 2);
 2e       endif;
 
          WorkTyp = 'A';
          WorkDec = 0;
          //---------------------------------------------------------
 1x    elseif FactorxDS.First1 >= '0'  and    //NUMERIC
          FactorxDS.First1 <= '9'
          or FactorxDS.First1 = '.';
          aa = %scan('.': FactorxDS);
          bb = %scan(' ': FactorxDS);
 2b       if bb > 0;  //CALC NUMBER OF DECIMALS
             WorkLen = (bb) - 1;  //ASSUME NO DECIMALS
 2x       else;
             WorkLen = 14;
 2e       endif;
          WorkDec = 0;
 
          aa = %scan('.': FactorxDS);
 2b       if aa > 0;  //CALC NUMBER OF DECM
             WorkLen -= 1;
             WorkDec = (bb - aa) - 1;
 2e       endif;
          WorkTyp = 'P';
 
 1x    elseif FactorxDS.First3 = '*BL' or FactorxDS.First3 = '*ZE';
          IsZeroBlank = *on;
 
 1x    else;  //FIELD NAME
          nn = %lookup(FactorxDS: FieldsArry(*).Name: 1: FieldsArryCnt);
 
          //---------------------------------------------------------
          // if lookup not found, it could be an array or
          // date field with  : in it.  Test both ways.
          //---------------------------------------------------------
 2b       if nn = 0;
             bb = %scan('(': FactorxDS: 1);  //try array
 3b          if bb = 0;
                bb = %scan(':': FactorxDS: 1);  //try date
 3e          endif;
 
 3b          if bb > 0;
                FactorxDS.IsLookup = %subst(FactorxDS: 1: (bb - 1));
                nn = %lookup(FactorxDS.IsLookup: FieldsArry(*).Name: 1:
                FieldsArryCnt);
 3e          endif;
 2e       endif;
          //---------------------------------------------------------
 2b       if nn > 0;
             FieldsAttrDS = FieldsArry(nn).Attr;
             WorkLen = FieldsAttrDS.Length;
 3b          if FieldsAttrDS.DecimalPos = *blanks;
                WorkDec = 0;
 3x          else;
                WorkDec = FieldsAttrDS.DecimalPosN;
 3e          endif;
             WorkTyp = FieldsAttrDS.DataType;
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       begsr *inzsr;
       // Load JCRCMDSSRV clipboard array with field names and attributes
       callp p_JCRGETFLDR(
             p_SrcFil + p_SrcLib:
             p_SrcMbr:
             DiagSeverity:
             PepCnt);
 1b    if DiagSeverity > '20';
          p_DiagSeverity = DiagSeverity;
          *inlr = *on;
          return;
 1e    endif;
       endsr;
 
     OmodifySrc e            updateSrc
     O                                           37 '              '
     O                       NewOpcode           47
     O                       ExtendedF2          92
