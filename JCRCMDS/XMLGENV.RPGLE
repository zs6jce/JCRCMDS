       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // XMLGENV - Validity checking program for selected script
       //---------------------------------------------------------
       /define ControlStatements
       /define Constants
       /define Qcmdchk
       /define f_CheckMbr
       /define f_CheckObj
       /define f_GetQual
       /define f_SndEscapeMsg
       /define f_IsSameMbr
       /define f_SrcFileAddPfm
       // *ENTRY
       /define p_XMLGENR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f SCRIPT disk(112) extfile(extifile) extmbr(p_scriptmbr) usropn;
       dcl-ds scriptDS len(112);
        xScriptSrc char(80) pos(13);
       end-ds;
 
       //---------------------------------------------------------
       dcl-s InLib char(10);
       dcl-s bldexc char(500);
       dcl-s string varchar(500);
       dcl-s IsAllLoaded ind;
 
       // values extracted from mbr script command
       dcl-s xMbr char(10);
       dcl-s xMbratr char(10);
       dcl-s xfromSrcf char(10);
       dcl-s xfromSrcl char(10);
       dcl-s xtoSrcf char(10);
       dcl-s xobjtype char(7);
       dcl-s xgencrt char(4);
 
       //---------------------------------------------------------
       // Verify script member, source file and library exists
       f_CheckMbr(p_ScriptQual: p_ScriptMbr);
 
       // Verify target source file and library exists
       f_CheckObj(p_OutFileQual: '*FILE');
 
 1b    if f_IsSameMbr(p_ScriptQual: p_ScriptMbr:
        p_OutFileQual: p_ScriptMbr);
          f_SndEscapeMsg('Script file/lib/mbr cannot +
          be same as XML file/lib/mbr name.');
 1e    endif;
 
       // add outfile member;
       f_SrcFileAddPfm(p_OutFileQual: p_ScriptMbr: 'XML':
       'XML data for group ' + p_ScriptMbr);
 
       // Override file to script member
       extIfile = f_GetQual(p_ScriptQual);
       open script;
 
       // read through member loading source record to outfile
       read script scriptDS;
 1b    dow not %eof;
 
          //---------------------------------------------------------
          // Spin through driver file and load data from tags as they occur.
          // XMLGENMBR  XMBR(XMLGEN) XMBRATR(CLP) XFROMSRCF(JCLSRC) +
          // XFROMSRCL(JCRCMDS) XTOSRCF(QCLSRC) +
          // XOBJTYPE(*PGM) XGENCRT(*YES)
          // XMLGENCMD  XCMD(CRTDTAARA DTAARA(&TOLIB/TEST) +
          // TYPE(*CHAR) LEN(10) VALUE(A))
          //---------------------------------------------------------
          aa = %scan('XMLGENMBR': xScriptSrc);
 2b       if aa > 0;
             exsr srLoadString;
 
             //---------------------------------------------------------
             // extract values from mbr script command
             // xMbr  char(10)           member name
             // xMbratr char(10)         source mbr attr
             // xfromSrcf char(10)       copy from Src file
             // xfromSrcl char(10)       copy from Src lib
             // xtoSrcf char(10)         copy to Src file
             // xobjtype  char(7)        object type
             // xgencrt char(4)          gen compile code
             //---------------------------------------------------------
             aa = %scan('XMBR(': string);
             cc = %scan(')': string: aa + 5);
             xMbr = %subst(string: aa + 5: cc - (aa + 5));
 
             aa = %scan('XMBRATR(': string: cc + 1);
             cc = %scan(')': string: aa + 8);
             xMbratr = %subst(string: aa + 8: cc - (aa + 8));
 
             aa = %scan('XFROMSRCF(': string: cc + 1);
             cc = %scan(')': string: aa + 10);
             xfromSrcf = %subst(string: aa + 10: cc - (aa + 10));
 
             aa = %scan('XFROMSRCL(': string: cc + 1);
             cc = %scan(')': string: aa + 10);
             xfromSrcl = %subst(string: aa + 10: cc - (aa + 10));
 
             aa = %scan('XTOSRCF(': string: cc + 1);
             cc = %scan(')': string: aa + 8);
             xtoSrcf = %subst(string: aa + 8: cc - (aa + 8));
 
             aa = %scan('XOBJTYPE(': string: cc + 1);
             cc = %scan(')': string: aa + 9);
             xobjtype = %subst(string: aa + 9: cc - (aa + 9));
 
             aa = %scan('XGENCRT(': string: cc + 1);
             cc = %scan(')': string: aa + 8);
             xgencrt = %subst(string: aa + 8: cc - (aa + 8));
 
             f_CheckMbr(xfromSrcf + xfromSrcl: xMbr);
 2x       else;
             aa = %scan('XMLGENCMD': xScriptSrc);
 3b          if aa > 0;
                exsr srLoadString;
                %len(string) = %len(string) - 2;  //drop last)
 
                //---------------------------------------------------------
                // extract command from string, check with qcmdchk API
                // Replace &TOLIB (no matter how many times it is in string)
                // with lib QUSRSYS just to pass cmdchk.
                //---------------------------------------------------------
                string = %scanrpl('&TOLIB': 'QUSRSYS': string);
 
                aa = %scan('XCMD(': string);
                bldexc = %subst(string: aa + 5);
                callp QCMDCHK(bldexc: %len(%trimr(bldexc)));
 3e          endif;
 2e       endif;
 
          read script scriptDS;
 1e    enddo;
 
       close script;
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       // read input file to load all parts of script command into
       // single string for processing.
       // Drop plus + sign and assume string completed when
       // current line does not terminate in + sign.
       //---------------------------------------------------------
       begsr srLoadString;
       clear string;
       IsAllLoaded = *off;
 
 1b    dou IsAllLoaded;
          cc = %checkr(' ': xScriptSrc);
 2b       if %subst(xScriptSrc: cc: 1) >' ';
 3b          if %subst(xScriptSrc: cc: 1) = '+';
                %subst(xScriptSrc: cc: 1) = ' ';
 3x          else;
                IsAllLoaded = *on;
 3e          endif;
 2e       endif;
 
          string = string +
          %trim(xScriptSrc) + ' ';
 2b       if not IsAllLoaded;
             read Script scriptDS;
 2e       endif;
 1e    enddo;
       endsr;
