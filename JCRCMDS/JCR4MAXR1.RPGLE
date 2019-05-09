       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCR4MAXR1 - convert RPGIII style logic structures to extended F2.
       // Convert  FACTOR1  IFxx  FACTOR2s  statements to   IF   Extended FACTOR2.
       // Convert  *INxx = *ON  to *INxx    convert *INxx = *OFF to not *INxx
       // Convert  Factor1 *ON  to *INxx    convert *INxx = *OFF to not *INxx
       //---------------------------------------------------------
       // I thought it ironic to use RPGII technology to update RPGIV code.
       //  Multifile logic to enable look ahead.
       //   Look ahead to determine if following statement was AND or OR.
       //    Matching record logic to keep update and lookahead files in sync.
       //     Force logic to spin through lookahead file if required to get next
       //     executable line of source.
       //      Added code to ignore SQL statements
       //---------------------------------------------------------
       /define ControlStatements
       /define Constants
       /COPY JCRCMDS,JCRCMDSCPY
 
     FLOOKAHEADRIP   F  112        DISK
     FMODIFYSRC US   F  112        DISK
 
       //---------------------------------------------------------
       dcl-s tabrelat char(2) dim(6) ctdata perrcd(1);  // EQ NE GT LT GE LE
       dcl-s tabsymbol char(2) dim(6) alt(tabrelat);  // =  <> >  <  >= <=
       dcl-s OldOpcode like(NewOpcode);
       dcl-s look_aheadU like(look_ahead);
       dcl-s IsAndOr char(3);
       dcl-s Extendedf2 char(45);
       dcl-s NewOpcode char(10);
       dcl-s Relations char(2);
       dcl-s IsForced ind;  // nxt record is forced
 
       dcl-ds SrcDS len(92) inz;
        SrcFactor1 char(14) pos(24);
        SrcOpcode char(10) pos(38);
        OpWhen char(4) overlay(SrcOpcode:1);
        OpWhenRel char(2) overlay(SrcOpcode:5);
        OpDox char(3) overlay(SrcOpcode:1);
        OpDoxRel char(2) overlay(SrcOpcode:4);
        OpIf char(2) overlay(SrcOpcode:1);
        OpIfRel char(2) overlay(SrcOpcode:3);
        OpAnd char(3) overlay(SrcOpcode:1);
        OpAndRel char(2) overlay(SrcOpcode:4);
        OpOr char(2) overlay(SrcOpcode:1);
        OpOrRel char(2) overlay(SrcOpcode:3);
        SrcFactor2 char(14) pos(48);
        SrcResult char(14) pos(62);
        SrcLength char(1) pos(80);
       end-ds;
 
       //--*INPUT SPECS-------------------------------------------
       // All lines that are comment or have eject character are
       // ignored. The first compile time table or array that is
       // found sets on LR.  Record type indicators determine
       // which code is executed.
       //---------------------------------------------------------
     Ilookaheadrns  lr   13 c*   14 c*   15 c
     I         or        13 c*   14 c*   15 cc                                  named array
     I         or        13 c*   14 c*   15 cC                                  named array
 
     I          ns  01
     I                             a    1    6  look_SeqN       m1
     I          ns  **
     I                             a    1   42  look_ahead
     I                             a   18   18  look_type
     I                             a   19   19  look_comt
     IModifySrc ns  02   18 cC   19nc*   19nc/
     I         and               19nc+
     I         or        18 cc   19nc*   19nc/
     I         and               19nc+
     I                             a    1    6  MatchRecSeq     m1
     I                             a    1   92  SrcDS
     I                             a   24   37  updFactor1
     I                             a   38   47  updOpcode
     I                             a   48   61  updFactor2
     I                             a   62   75  updResult
     I          ns  05
     I                             a    1    6  MatchRecSeq     m1
 
       //---------------------------------------------------------
       // AND or OR opcode code may follow so look-ahead is
       // used to determine which. If a comment or copy statement
       // is found, FORCE checks next look ahead.
       //---------------------------------------------------------
 1b    if *in01;
          IsForced = *off;
          IsAndOr = *blanks;
 
 2b       if (look_type = 'C'
             or look_type = 'c')
             and (look_comt <> '*'
             and look_comt <> '/'
             and look_comt <> '+');
 
             look_aheadU = %xlate(lo:up:look_ahead);
 
 3b          if %subst(look_aheadU: 38: 3) = 'AND';
 4b             if (%subst(look_aheadU: 38 + 3: 1)) > ' ';
                   IsAndOr = 'and';
 4e             endif;
 
 3x          elseif %subst(look_aheadU: 38: 2) = 'OR';
 4b             if (%subst(look_aheadU: 38 + 2: 1)) > ' ';
                   IsAndOr = 'or';
 4e             endif;
 3e          endif;
 2x       else;
             FORCE lookaheadr;  //read next
             IsForced = *on;
 2e       endif;
 1e    endif;
 
       //---------------------------------------------------------
       // If calc record spec and it was not forced
       //---------------------------------------------------------
 1b    if *in02;
          SrcDS = %xlate(lo: up: SrcDS);
          NewOpcode = *blanks;
          OldOpcode = *blanks;
          *in11 = *off;
 
          // Only cat(p) with no padded spaces defined or :0 padded spaces or : 1
 2b       if SrcOpcode = 'CAT(P)' and SrcLength = ' ';
             NewOpcode = 'eval';
 
 3b          if updFactor1 = *blanks;
                updFactor1 = updResult;  //load implicit
 3e          endif;
 
             aa = %scan(':': updFactor2);
 3b          if aa = 0;  //append as is
                Extendedf2 = %trim(updResult) + ' = ' +
                %trim(updFactor1) + ' + ' + %trim(updFactor2);
                except UpdateSrc;
 3x          elseif %subst(updFactor2: aa: 3) = ':0 ';  //no spaces
                Extendedf2 = %trimr(updResult) + ' = %trimr(' +
                %trim(updFactor1) + ') + ' + %subst(updFactor2: 1: aa - 1);
                except UpdateSrc;
 3x          elseif %subst(updFactor2: aa: 3) = ':1 ';  //one space
                Extendedf2 = %trimr(updResult) +
                ' = %trimr(' + %trim(updFactor1) + ') + ' +
                '''' + ' ' + '''' + ' + ' + %subst(updFactor2: 1: aa - 1);
                except UpdateSrc;
 3e          endif;
 
             //---------------------------------------------------------
             // Rest of structure logic
             //---------------------------------------------------------
 2x       elseif OpWhen = 'WHEN'  and OpWhenRel > *blanks;
             NewOpcode = %subst(updOpcode: 1: 4);
             Relations = OpWhenRel;
             exsr srCalcExtend;
 
 2x       elseif (OpDox = 'DOW' or OpDox = 'DOU')
             and OpDoxRel > *blanks;
             NewOpcode = %subst(updOpcode: 1: 3);
             Relations = OpDoxRel;
             exsr srCalcExtend;
 
 2x       elseif OpIf = 'IF' and OpIfRel > *blanks;
             NewOpcode = %subst(updOpcode: 1: 2);
             Relations = OpIfRel;
             exsr srCalcExtend;
 
 2x       elseif OpAnd = 'AND' and OpAndRel > *blanks;
             NewOpcode = *blanks;
             Relations = OpAndRel;
             *in11 = *on;
             exsr srCalcExtend;
 2x       elseif OpOr = 'OR' and OpOrRel > *blanks;
             NewOpcode = *blanks;
             Relations = OpOrRel;
             *in11 = *on;
             exsr srCalcExtend;
 2e       endif;
 1e    endif;
 
       //---------------------------------------------------------
       // *in01 ifeq *on  converted to   if  *in01
       //---------------------------------------------------------
       begsr srCalcExtend;
 1b    if Relations = 'EQ'
          and %subst(SrcFactor1: 1: 3) = '*IN'
          and (SrcFactor2 = '*ON'
          or SrcFactor2 = '*OFF'
          or SrcFactor2 = '''1'''
          or SrcFactor2 = '''0''');
 
 2b       if SrcFactor2 = '*ON'
             or SrcFactor2 = '''1''';
             Extendedf2 = updFactor1;
 2x       elseif SrcFactor2 = '*OFF'
             or SrcFactor2 = '''0''';
             Extendedf2 = 'NOT ' + updFactor1;
 2e       endif;
 1x    else;
          //---------------------------------------------------------
          // Update Relationship testing code
          //---------------------------------------------------------
          *in10 = %tlookup(Relations: tabrelat: tabsymbol);
          Extendedf2 = %trimr(updFactor1) +     // FACTOR 1
          ' ' + %trim(tabsymbol) + ' ' +        //Relationship
          updFactor2;  //FACTOR 2
 1e    endif;
 
       // Tack 'and' or 'or' to end of factor two
 1b    if IsAndOr > *blanks;
          Extendedf2 = %trimr(Extendedf2) + '  ' +
          IsAndOr;
 1e    endif;
       except UpdateSrc;
       endsr;
 
     OModifySrc e            UpdateSrc
     O               11                          20 '  '
     O                                           37 '              '
     O                       NewOpcode           47
     O                       Extendedf2          92
**
EQ=
NE<>
LE<=
GE>=
LT<
GT>
