       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCR4MAXR4 - Generate D specs for program defined fields  (except parms)
       //  Generate standard H specs in converted source.
       //---------------------------------------------------------
       /define ControlStatements
       /define Constants
       /define f_IsCompileTimeArray
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f MODIFYSRC disk(112) usage(*update: *output);
       dcl-f NEWSRC disk(112) usage(*output);
 
       dcl-s FldStorage dim(%elem(defined)) like(storageds);
       dcl-s DataType char(1);
       dcl-s Defined char(14) dim(32767);
       dcl-s HeaderSrc char(70);
       dcl-s likeDefine char(20);
       dcl-s DefinedCount uns(10);
       dcl-s IsAlreadyDone ind;
       dcl-s IsDefined ind;
 
       dcl-ds StorageDS inz;
        dsUppercas char(14);
        dsFactor1 char(14);
        dsFactor2 char(14);
        dsResult char(14);
        dsLength char(5);
        dsDecimals char(2);
        dsText char(20);
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_CreateNew ind;
       end-pi;
 
       //--*INPUT SPECS-------------------------------------------
     ImodifySrc ns
     I                             s    1    6 2SrcSeqno
     I                             a   13   15  CompileArray
     I                             a   18   18  SpecType
     I                             a   19   19  Asterisk
     I                             a   19   33  SrcDspecs
     I                             a   24   37  SrcFactor1
     I                             a   38   47  SrcOpcode
     I                             a   48   61  SrcFactor2
     I                             a   62   75  SrcResult
     I                             a   76   80  SrcLength
     I                             a   81   82  SrcDecimal
     I                             a   93  112  SrcText
     I                             a    1  112  AllSrc
       //---------------------------------------------------------
 
       p_CreateNew = *off;
       read modifySrc;
 1b    dow not %eof;
 
          // All lines that are comment or have eject character are
          // ignored. The first compile time table or array that is
          // found will exit read loop.
 2b       if f_IsCompileTimeArray(CompileArray);
 1v          leave;
 2e       endif;
 
 2b       if not(Asterisk = '*'
             or Asterisk = '/'
             or Asterisk = '+');
 
 3b          if (SpecType = 'D'
                or SpecType = 'd')
                and SrcDspecs > *blanks;
                SrcDspecs = %xlate(lo: up: Srcdspecs);
                bb += 1;
                Defined(bb) = %triml(SrcDspecs);
 
 3x          elseif (SpecType = 'C'
                or SpecType = 'c')
                and SrcOpcode > *blanks
                and %scan('(': SrcResult: 1) = 0;  //skip arrays
                SrcOpcode = %xlate(lo: up: SrcOpcode);
 
 4b             if (SrcOpcode <> 'IF'
                   and SrcOpcode <> 'WHEN'
                   and SrcOpcode <> 'FOR'
                   and SrcOpcode <> 'AND'
                   and SrcOpcode <> 'OR'
                   and SrcOpcode <> 'DOU'
                   and SrcOpcode <> 'DOW'
                   and SrcOpcode <> 'ELSEIF'
                   and %subst(SrcOpcode: 1: 4) <> 'EVAL'
                   and %subst(SrcOpcode: 1: 5) <> 'CALLP'
                   and SrcLength > *blanks)
                   or SrcOpcode = 'DEFINE';
 
                   IsDefined = *off;
 5b                if SrcOpcode = 'DEFINE';
                      SrcFactor1 = %xlate(lo: up: Srcfactor1);
                      IsDefined = (SrcFactor1 <> '*LIKE');
 6b                   if IsDefined = *off;
 7b                      if %scan('(': Srcfactor2) > 0;
                            IsDefined = *on;
 7e                      endif;
 6e                   endif;
 5e                endif;
 
 5b                if not IsDefined;
                      dsUppercas = %xlate(lo: up: SrcResult);
                      cc = %lookup(dsUppercas: Defined: 1: bb);
                      IsDefined = (cc > 0);
 6b                   if not IsDefined;
                         bb += 1;
                         Defined(bb) = dsUppercas;  //Set as defined
 
                         // if SrcOpcode <> 'PARM ';
                         dsFactor1 = SrcFactor1;
                         dsFactor2 = SrcFactor2;
 
                         //---------------------------------------------------------
                         // Caution: Result fields could have
                         //  :(date type) extender.
                         // example  a  subdur  b  c:*D     3  0
                         // I only want to load up to ':'
                         //---------------------------------------------------------
                         aa = %scan(':': SrcResult: 1);
 7b                      if aa > 0;
                            SrcResult = %subst(SrcResult: 1: aa - 1);
 7e                      endif;
 
                         dsResult = SrcResult;
                         dsLength = SrcLength;
                         dsDecimals = SrcDecimal;
                         dsText = SrcText;
                         DefinedCount += 1;
                         FldStorage(DefinedCount) = StorageDS;
 6e                   endif;
 
 6b                   if SrcOpcode = 'PARM'
                         and not IsDefined;  //leave defined
 6x                   elseif SrcOpcode = 'DEFINE';
                         except deleterec;
 6x                   else;
                         except removelen;
 6e                   endif;
 5e                endif;
 4e             endif;
 3e          endif;
 2e       endif;
          read modifySrc;
 1e    enddo;
 
       //---------------------------------------------------------
       // To insert records into source member, must write out new member.
       // Read original source and write it to new source.
       //  When first D, or if no D then C spec is found,
       //   execute subroutine to write newly generated D specs.
       //---------------------------------------------------------
 1b    if DefinedCount > 0;
          p_CreateNew = *on;
          SrcSeqno += .01;
          HeaderSrc =
          '  ctl-opt DFTACTGRP(*NO) ACTGRP(*CALLER) EXPROPTS(*RESDECPOS)';
          except Header;
 
          SrcSeqno += .01;
          HeaderSrc =
          '  DATFMT(*ISO) TIMFMT(*ISO) OPTION(*NODEBUGIO: *NOUNREF);';
          except Header;
 
          setll *start modifySrc;
          read modifySrc;
 2b       dow not %eof;
 3b          if not IsAlreadyDone;
 4b             if SpecType = 'D'
                   or SpecType = 'd'
                   or SpecType = 'C'
                   or SpecType = 'c'
                   or SpecType = 'I'
                   or SpecType = 'i';
                   IsAlreadyDone = *on;
 
                   // Process back through array and write D specs
                   HeaderSrc = *blanks;
                   SrcSeqno += .01;
                   except Header;
                   SrcSeqno += .01;
                   HeaderSrc =
             ' //--*STAND ALONE-------------------------------------------';
                   except Header;
 
 5b                if DefinedCount > 1;
                      sorta %subarr(FldStorage: 1: DefinedCount);
 5e                endif;
 
 5b                for cc = 1 to DefinedCount;
                      SrcSeqno += .01;
                      StorageDS = FldStorage(cc);
                      *in11 = *off;
                      DataType = *blanks;
 6b                   if dsFactor1 = '*LIKE';
                         *in11 = *on;
                         LikeDefine = 'like(' + %trimr(dsFactor2) + ')';
 6x                   else;
                         // load data type
 7b                      if dsLength > *blanks;
 8b                         if dsDecimals > *blanks;
                               DataType = 'p';
 8x                         else;
                               DataType = 'a';
 8e                         endif;
 7e                      endif;
 6e                   endif;
                      except gendefine;
 5e                endfor;
 
                   HeaderSrc = *blanks;
                   SrcSeqno += .01;
                   except Header;
 4e             endif;
 3e          endif;
             except writeall;
             read modifySrc;
 2e       enddo;
 1e    endif;
       *inlr = *on;
       return;
 
     ONEWSRC    e            Header
     O                       SrcSeqno             6
     O                                           12 '000000'
     O                       HeaderSrc           87
 
     O          e            writeall
     O                       allSrc             112
 
     O          e            gendefine
     O                       SrcSeqno             6
     O                                           12 '000000'
     O                                           18 'D'
     O                       dsResult            33
     O                                           36 's'
     O                       dsLength            51
     O                       DataType            52
     O                       dsDecimals          54
     O               11      LikeDefine          75
     O                       dsText             112
 
     OModifySrc e            removelen
     O                                           82 '       '
 
     O          edel         deleterec
