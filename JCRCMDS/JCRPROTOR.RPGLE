       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRPROTOR - Convert *entry/call parms to prototypes
       //
       //  read input source to load call and parm information into arrays,
       //   then spins back through the arrays to generate prototype structures and callp.
 
       //  Source lines with (columns 6 and 7 = blanks and columns 8 to 80 > *blanks)
       //   are free format. Any columns 6 or 7 > *blanks are fixed column.
       //---------------------------------------------------------
       /define ControlStatements
       /define f_IsIgnoreLine
       /define ApiErrDS
       /define FieldsArry
       /define Constants
       /define FieldsAttrDS
       /define f_GetQual
       /define f_Qusrobjd
       /define f_SndCompMsg
       /define f_IsCompileTimeArray
       /define f_SndEscapeMsg
       /define f_GetDataTypeKeyWords
       /define p_JCRGETFLDR
       // *ENTRY
       /define p_JCRPROTOR
       /COPY JCRCMDS,JCRCMDSCPY
 
       //------------------------------------------------
       // rpgle source member input file
       //------------------------------------------------
       dcl-f InputSrc disk(112) extfile(extIfile) extmbr(p_InMbr) usropn;
       dcl-ds InputDS len(112) qualified;
        CompileArry char(3) pos(13);
        SrcDat zoned(6: 0) pos(7);
        Src112 char(100) pos(13);
        Src94 char(94) pos(19);
        SpecType char(1) pos(18);
        n01 char(3) pos(21);
        Factor1 char(14) pos(24);
        Opcode char(10) pos(38);
        Opcode5 char(5) pos(38);
        Factor2 char(14) pos(48);
        ResFld char(14) Pos(62);
       end-ds;
 
       //------------------------------------------------
       // new source member written out with prototyped calls
       //------------------------------------------------
       dcl-f NewSrc disk(112) usage(*output) extfile(extOfile)
       extmbr(p_OutMbr) usropn;
       dcl-ds OutDS len(112) inz qualified;
        SrcSeq zoned(6: 2) pos(1);
        SrcDat zoned(6: 0) pos(7);
        SrcOut char(100) pos(13);
       end-ds;
 
       //------------------------------------------------
       dcl-s hyphens char(50) inz(*all'-');
       dcl-s string varchar(94);
       dcl-s Factor1 char(14);
       dcl-s Opcode5 char(5);
       dcl-s CalledPgmName char(14);
       dcl-s Pgm10 char(10);
       dcl-s PepCnt packed(3);
       dcl-s LoadIndex uns(5);
       dcl-s s8 char(8);
       dcl-s xx uns(5);
       dcl-s ii uns(5);
       dcl-s ParmCnt uns(5);
       dcl-s ResultField char(14);
       dcl-s SaveRrn like(rrn);
       dcl-s IsCompileArray ind;
       dcl-s IsWrite ind;
       dcl-s CallExtender char(3);
       dcl-s n01 char(3);
       dcl-s BaseLen uns(3) inz(74);
       dcl-s IsStackParms ind;
       dcl-s IsFitOnOneLine ind;
       dcl-s vstring varchar(112);
 
       //------------------------------------------------
       // capture the parm information for each call
       // as it is encoutered in the CALLP write out process.
       //------------------------------------------------
       dcl-ds ThisCall qualified;
        Type char(5);  // PLIST or PGM
        Name char(14);
        Plist char(14);
        Factor1 char(14) dim(255);
        Factor2 char(14) dim(255);
        ResFld char(14) dim(255);
       end-ds;
 
       //------------------------------------------------
       // Spin through the source first to load up each unique plist and called program
       //   so the *entry procedure interface and call prototypes can be generated
       //------------------------------------------------
       dcl-ds protoDS likeds(ThisCall) dim(1000);
 
       //---------------------------------------------------------
       // Load JCRCMDSSRV clipboard array with field names and attributes
       callp p_JCRGETFLDR(
             p_InFileQual:
             p_InMbr:
             DiagSeverity:
             PepCnt);
 
 1b    if DiagSeverity > '20';
          f_SndEscapeMsg('*ERROR*  Diagnostic severity ' +
          DiagSeverity + '. Please check listing for errors.');
 1e    endif;
 
       extIfile = f_GetQual(p_InFileQual);
       extOfile = f_GetQual(p_OutFileQual);
       open InputSrc;
       open NewSrc;
 
       exsr srLoadParmArrays;
       exsr srWriteCtlOpt;
       exsr srWritePrototypes;
       exsr srReplaceCalls;
 
       close InputSrc;
       close NewSrc;
       f_SndCompMsg('Prototype mbr ' + %trimr(p_OutMbr) + ' generated.');
       *inlr = *on;
       return;
 
       //---------------------------------------------
       // Write the original source member code to the outfile.
       //  When a CALL is hit, load up ThisCall structure
       //   then generate a CALLP statement replacing the CALL.
       // Use IsWrite to control not writting PLISTS, PARMS, AND CALLS to new source
       //---------------------------------------------
       begsr srReplaceCalls;
       IsCompileArray = *off;
       IsWrite = *on;
 
       setll 1 InputSrc;
       read InputSrc InputDS;
 1b    dow not %eof;
          SaveRrn += 1;
 
 2b       if not IsCompileArray;
 
 3b          if f_IsCompileTimeArray(InputDS.CompileArry);
                IsCompileArray = *on;
 3x          else;
 
                IsWrite = *on;
                string = %trimr(InputDS.Src94);
 4b             if not f_IsIgnoreLine(string)
                       and (InputDS.SpecType ='C'
                       or InputDS.SpecType ='c');
 
                   Opcode5 = %xlate(lo: up: InputDS.Opcode5);
 5b                if Opcode5 = 'CALL('
                      or OpCode5 = 'CALL';
                      exsr srLoadUpThisCall;
                      IsWrite = *off;
                      setgt SaveRrn InputSrc;
 
 5x                elseif OpCode5 = 'PLIST'
                      or Opcode5 = 'PARM';
                      IsWrite = *off;
 5e                endif;
 
 4e             endif;
 3e          endif;
 2e       endif;
 
          //---------------------------------------------
 2b       if IsCompileArray or IsWrite;
 3b          monitor;
                OutDS.SrcDat = InputDS.SrcDat;
 3x          on-error;
                OutDS.SrcDat = 0;
 3e          endmon;
             OutDS.SrcSeq += .01;
             OutDS.SrcOut = InputDS.Src112;
             write NewSrc OutDS;
 2e       endif;
 
          read InputSrc InputDS;
 1e    enddo;
       endsr;
 
       //---------------------------------------------
       // load up ThisCall structure then generate a CALLP statement replacing the CALL.
       //  Cannot easily know a structure has ended until
       //  EOF, Another call or plist, a compile time array. O or P specs
       //   The call could have a PLIST. in that case use same array logic
       //   as the dcl-pr code to get the parameter fields.
       //---------------------------------------------
       begsr srLoadUpThisCall;
       clear ThisCall;
 
       // if is a call(e)
       CallExtender = *blanks;
       xx = %scan('(':InputDS.OpCode);
 1b    if xx > 0;
          CallExtender = %scanrpl(' ':'':(%subst(InputDS.OpCode:xx)));
 1e    endif;
 
       n01 = InputDS.n01;
       Pgm10 = %scanrpl(qs:'': InputDS.Factor2);
       Pgm10 = %xlate(lo: up: Pgm10);
 
       // plists are easy!  Already loaded them to create the dcl-pi
 1b    if InputDS.ResFld > *blanks;
          ResultField = %xlate(lo: up: InputDS.ResFld);
          ii = f_GetProtoDSIndex(aa: ResultField: 'PLIST');
          ThisCall = protoDS(ii);
          exsr srWriteCallp;
 LV       leavesr;
 1e    endif;
 
       //-----------------------------------------
       // spin through and load up the parms for this call
       //-----------------------------------------
       bb = 0;
       read InputSrc InputDS;
 1b    dow not %eof;
 
          string = %trimr(InputDS.Src94);
 2b       if not f_IsIgnoreLine(string)
                 and (InputDS.SpecType ='C'
                 or InputDS.SpecType ='c');
 
             Opcode5 = %xlate(lo: up: InputDS.Opcode5);
 
 3b          if f_IsCompileTimeArray(InputDS.CompileArry)
                or OpCode5 = 'PLIST'
                or Opcode5 = 'CALL '
                or Opcode5 = 'CALL(';
                exsr srWriteCallp;
 LV             leavesr;
 
 3x          elseif Opcode5 = 'PARM';
                bb += 1;
                ThisCall.Factor1(bb) = InputDS.Factor1;
                ThisCall.Factor2(bb) = InputDS.Factor2;
                ThisCall.ResFld(bb) = InputDS.ResFld;
 3e          endif;
 
 2e       endif;
 
          read InputSrc InputDS;
 1e    enddo;
 
       // if loop terminates without a stop point being found
       // ie call is last lines in program
       exsr srWriteCallp;
 
       endsr;
 
       //---------------------------------------------
       // 1. Before CALLP, load factor2 into parms.
       // 2. Generate CALLP and parm value statements
       // 3. After CALLP, load parm fields into Factor1
       //---------------------------------------------
       begsr srWriteCallp;
       // ThisCall.Factor1
       // ThisCall.Factor2
       // ThisCall.ResFld
 
       ParmCnt = 0;
 
       //-----------------------------------------
       // if call has a conditioning indicator, write wrapper code
       //-----------------------------------------
 1b    if n01 > *blanks;
 2b       if %subst(n01:1:1) = 'N' or %subst(n01:1:1) = 'n';
             OutDS.SrcOut = s8 + 'if (not *in' + %subst(n01:2:2) + ');';
 2x       else;
             OutDS.SrcOut = s8 + 'if *in' + %subst(n01:2:2) + ';';
 2e       endif;
          OutDS.SrcSeq += .01;
          write NewSrc OutDS;
 1e    endif;
 
       //-----------------------------------------
       // write out calc specs for setting parm = factor 2
       //-----------------------------------------
 1b    for bb = 1 to 255;
 2b       if ThisCall.ResFld(bb) = *blanks;
 1v          leave;
 2e       endif;
          ParmCnt += 1;
 
 2b       if ThisCall.Factor2(bb) > *blanks;
             OutDS.SrcOut = s8 +
             %trimr(ThisCall.ResFld(bb)) + ' = ' +
             %trimr(ThisCall.Factor2(bb)) +';';
             OutDS.SrcSeq += .01;
             write NewSrc OutDS;
 2e       endif;
 1e    endfor;
 
       //-----------------------------------------
       // write out callp and parms here
       //-----------------------------------------
       OutDS.SrcOut = s8 + 'callp' +
       %trimr(CallExtender) + ' ' +
       'p_' + %trimr(Pgm10) + '(';
 
       //-----------------------------------------
       // Normally parameters are stacked, one to a line for readability.
       // However, if there are only one or two parameters and the names will fit
       // on the same line as the callp then I will put those on the same line.
       //  callp p(a: b);
       //-----------------------------------------
       IsStackParms = *on;
       IsFitOnOneLine = *on;
 
 1b    if ParmCnt = 0;
          OutDS.SrcOut = %trimr(OutDS.SrcOut) + ');';
          IsStackParms = *off;
 
 1x    elseif ParmCnt <= 2;
          vString = %trimr(ThisCall.ResFld(1));
 2b       If ParmCnt = 2;
             vString += ': ' +  %trimr(ThisCall.ResFld(2));
 2e       endif;
          vstring += ');';
 
 2b       if %len(%trimr(OutDS.SrcOut)) + %len(vstring) > 80;
             IsFitOnOneLine = *off;
 2x       else;
             OutDS.SrcOut = %trimr(OutDS.SrcOut) + vstring;
             IsStackParms = *off;
             IsFitOnOneLine = *on;
 2e       endif;
 1e    endif;
 
 1b    if IsFitOnOneLine;
          OutDS.SrcSeq += .01;
          write NewSrc OutDS;
 1e    endif;
 
 1b    if IsStackParms;
 2b       for bb = 1 to ParmCnt;
             OutDS.SrcOut = s8 + s8 + ' ' + ThisCall.ResFld(bb);
 3b          if bb = ParmCnt;
                OutDS.SrcOut = %trimr(OutDS.SrcOut) + ');';
 3x          else;
                OutDS.SrcOut = %trimr(OutDS.SrcOut) + ':';
 3e          endif;
             OutDS.SrcSeq += .01;
             write NewSrc OutDS;
 2e       endfor;
 1e    endif;
 
       //-----------------------------------------
       // write out calc specs for setting factor 1 = parm;
       //-----------------------------------------
 1b    for bb = 1 to ParmCnt;
 2b       if ThisCall.Factor1(bb) > *blanks;
             OutDS.SrcOut = s8 +
             %trimr(ThisCall.Factor1(bb)) + ' = ' +
             %trimr(ThisCall.ResFld(bb)) +';';
             OutDS.SrcSeq += .01;
             write NewSrc OutDS;
 2e       endif;
 1e    endfor;
 
       //-----------------------------------------
       // if indicator wrapper, close the logic structure
       //-----------------------------------------
 1b    if n01 > *blanks;
          OutDS.SrcOut = s8 + 'endif;';
          OutDS.SrcSeq += .01;
          write NewSrc OutDS;
 1e    endif;
 
       endsr;
 
       //---------------------------------------------
       // procedure interface requires default activation group *no.
       //  write some benign control options the user can delete if they wish
       //---------------------------------------------
       begsr srWriteCtlOpt;
       OutDS.SrcOut = s8 +
       'ctl-opt expropts(*resdecpos) option(*nodebugio: *nounref)';
       OutDS.SrcSeq += .01;
       write NewSrc OutDS;
 
       OutDS.SrcOut = s8 +
       'dftactgrp(*no) actgrp(*caller) datfmt(*iso) timfmt(*iso);';
       OutDS.SrcSeq += .01;
       write NewSrc OutDS;
 
       OutDS.SrcOut = *blanks;
       OutDS.SrcSeq += .01;
       write NewSrc OutDS;
       endsr;
 
       //---------------------------------------------
       // process call arrays into prototypes and any *ENTRY plist
       //---------------------------------------------
       begsr srWritePrototypes;
 
 1b    for cc = 1 to aa;
 2b       if protods(cc).Name = '*ENTRY';
             exsr srWriteDclPI;
             ii = cc;
             exsr srWriteDclParm;
             OutDS.SrcOut = s8 + 'end-pi;';
             OutDS.SrcSeq += .01;
             write NewSrc OutDS;
 
             //-----------------------------------
 2x       elseif protods(cc).Type = 'CALL';
             exsr srWriteDclPR;
             ii = cc;
             exsr srWriteDclParm;
             OutDS.SrcOut = s8 + 'end-pr;';
             OutDS.SrcSeq += .01;
             write NewSrc OutDS;
 
             // OutDS.SrcOut = *blanks;
             // OutDS.SrcSeq += .01;
             // write NewSrc OutDS;
 2e       endif;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       begsr srWriteDclPI;
       OutDS.SrcOut = s8 + '//-*ENTRY-----------------------------';
       OutDS.SrcSeq += .01;
       write NewSrc OutDS;
 
       OutDS.SrcOut = s8 + 'dcl-pi *n; ';
       OutDS.SrcSeq += .01;
       write NewSrc OutDS;
       endsr;
 
       //---------------------------------------------------------
       // Generate prototype specs for called programs
       //---------------------------------------------------------
       begsr srWriteDclPR;
 
       //little work here to extract program name
       Pgm10 = *blanks;
 
       xx = %scan(qs: protods(cc).Name);
 1b    if xx = 0;  //variable program name
          Pgm10 = 'v_' + protods(cc).Name;
          OutDS.SrcOut = s8 +
          '//---variable name--------------------------------------';
 1x    else;
          Pgm10 = %scanrpl(qs:'': protods(cc).Name);
          Pgm10 = %xlate(lo: up: Pgm10);
 
          QusrObjDS = f_QUSROBJD(Pgm10 + '*LIBL':'*PGM');
 2b       if ApiErrDS.BytesReturned = 0;
             QusrObjDS.Text = %trimr(QusrObjDS.Text) + hyphens;
 2x       else;
             QusrObjDS.Text = *all'-';
 2e       endif;
          OutDS.SrcOut = s8+ '//---' + QusrObjDS.Text + '-';
 1e    endif;
 
       OutDS.SrcSeq += .01;
       write NewSrc OutDS;
 
       OutDS.SrcOut = s8 + 'dcl-pr p_' +
       %trimr(%xlate(up: lo: Pgm10)) +
       ' extpgm(' + qs + %trimr(Pgm10) + qs + ');';
       OutDS.SrcSeq += .01;
       write NewSrc OutDS;
       endsr;
 
       //---------------------------------------------------------
       // if result field plist is used,
       //   get LoadIndex to find PLIST and continue on from there
       //---------------------------------------------------------
       begsr srWriteDclParm;
 
       // if call has a plist entry, substitute
       // start of plist elements
 
 1b    if protoDS(ii).Plist > *blanks;
          ii = f_GetProtoDSIndex(aa: protoDS(cc).Plist: 'PLIST');
 1e    endif;
 
 1b    for bb = 1 to 255;
 2b       if protoDS(ii).ResFld(bb) = *blanks;
 1v          leave;
 2e       endif;
 
          ResultField = %xlate(lo: up:
          f_RemoveIndex(protoDS(ii).ResFld(bb)));
 
          // get field attributes
          xx = %lookup(ResultField: FieldsArry(*).Name: 1: FieldsArryCnt);
 2b       if xx = 0;
             f_SndEscapeMsg('*ERROR*  Field definition for ' +
             %trimr(ResultField) + ' not found.');
 2e       endif;
 
          FieldsAttrDS = FieldsArry(xx).Attr;
 
 2b       if  not(protods(ii).Name = '*ENTRY');
             OutDS.SrcOut = s8 + ' *n ' +
             f_GetDataTypeKeyWords(
             FieldsAttrDS.DataType:
             FieldsAttrDS.Length:
             FieldsAttrDS.DecimalPos) +
             '// ' + %xlate(up: lo: ResultField);
 2x          else;
             OutDS.SrcOut = s8 + ' ' +
             %xlate(up: lo: (%trimr(protoDS(ii).ResFld(bb)))) + '  ' +
             f_GetDataTypeKeyWords(
             FieldsAttrDS.DataType:
             FieldsAttrDS.Length:
             FieldsAttrDS.DecimalPos);
 2e       endif;
 
          OutDS.SrcSeq += .01;
          write NewSrc OutDS;
 1e    endfor;
       endsr;
 
       //---------------------------------------------
       //---------------------------------------------
       begsr srLoadParmArrays;
       read InputSrc InputDS;
 1b    dow not %eof;
 
 2b       if f_IsCompileTimeArray(InputDS.CompileArry);
 1v          leave;
 2e       endif;
 
          string = %trimr(InputDS.Src94);
 2b       if not f_IsIgnoreLine(string)
                 and (InputDS.SpecType ='C'
                 or InputDS.SpecType ='c');
 
             // leave original case formatting to be written out
             Opcode5 = %xlate(lo: up: InputDS.Opcode5);
             Factor1 = %xlate(lo: up: InputDS.Factor1);
 
 3b          if OpCode5 = 'PLIST';
                aa += 1;
                bb = 0;
                protoDS(aa).Name = Factor1;
                protoDS(aa).Type = 'PLIST';
                protoDS(aa).Plist = *blanks;
                LoadIndex = 0;
 
 3x          elseif Opcode5 = 'CALL ' or Opcode5 = 'CALL(';
                CalledPgmName = %xlate(lo: up: InputDS.Factor2);
                LoadIndex = f_GetProtoDSIndex(aa:CalledPgmName: 'CALL');
 4b             if LoadIndex = 0;
                   aa += 1;
                   bb = 0;
                   protoDS(aa).Name = CalledPgmName;
                   protoDS(aa).Plist = %xlate(lo: up: InputDS.ResFld);
                   protoDS(aa).Type = 'CALL';
 4e             endif;
 
 3x          elseif Opcode5 = 'PARM' and LoadIndex = 0;
                bb += 1;
                protoDS(aa).Factor1(bb) = InputDS.Factor1;
                protoDS(aa).Factor2(bb) = InputDS.Factor2;
                protoDS(aa).ResFld(bb) = InputDS.ResFld;
 3e          endif;
 2e       endif;
 
          read InputSrc InputDS;
 1e    enddo;
       endsr;
 
       //---------------------------------------------
       //---------------------------------------------
       dcl-proc f_GetProtoDSIndex;
        dcl-pi *n uns(5);
         xx uns(5) const;
         Name char(14) const;
         Type char(5) const;
        end-pi;
        dcl-s yy uns(5);
 
 1b     for yy = 1 to xx;
 2b        if protoDS(yy).Name = Name
              and protoDS(yy).Type = Type;
              return yy;
 2e        endif;
 1e     endfor;
 
        return 0;
       end-proc;
 
       //---------------------------------------------
       //---------------------------------------------
       dcl-proc f_RemoveIndex;
        dcl-pi *n char(14);
         string char(14);
        end-pi;
        dcl-s xx uns(3);
 
        xx = %scan('(': string);
 1b     if xx > 0;
           %subst(string: xx) = *blanks;
 1e     endif;
 
        return string;
       end-proc;
