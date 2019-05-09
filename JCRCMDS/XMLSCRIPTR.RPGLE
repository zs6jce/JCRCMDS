       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // XMLSCRIPTR - XML Script Member Viewer
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f XMLSCRIPTD workstn sfile(sbfdta1: rrn) infds(infds) indds(ind);
       dcl-f SCRIPT disk(112) extfile(extifile) extmbr(p_srcmbr) usropn;
       dcl-ds inputDS len(112);
        xScriptSrc char(80) pos(13);
       end-ds;
 
       /define FunctionKeys
       /define Infds
       /define Dspatr
       /define Ind
       /define Constants
       /define f_BuildString
       /define f_GetDayName
       /define f_Qusrmbrd
       /define f_GetQual
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s xInclude char(4);
       dcl-s string varchar(500);
       dcl-s SequenceNum packed(3);
       dcl-s IsAllLoaded ind;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_SrcMbr char(10);
        p_SrcFilQual char(20);
       end-pi;
       //---------------------------------------------------------
 
       // Get actual source lib
       QusrmbrdDS = f_Qusrmbrd(p_SrcFilQual: p_SrcMbr: 'MBRD0100');
       %subst(p_SrcFilQual: 11: 10) = QusrmbrdDS.Lib;
 
       // override input
       extIfile = f_GetQual(p_SrcFilQual);
       open SCRIPT;
 
       //---------------------------------------------------------
       // Extract install include value from top of script
       // XMLGENINC  XINCLUDE(*YES) *YES, *NO
       //---------------------------------------------------------
       read SCRIPT inputDS;
 1b    dou aa > 0 or %eof;
          aa = %scan('XINCLUDE(': xScriptSrc);
 2b       if aa > 0;
             cc = %scan(')': xScriptSrc: aa + 9);
             xinclude = %subst(xScriptSrc: aa + 9: cc - (aa + 9));
 1v          leave;
 2e       endif;
          read SCRIPT inputDS;
 1e    enddo;
 
       //---------------------------------------------------------
       // read through member loading source record to outfile
       //---------------------------------------------------------
       read SCRIPT inputDS;
 1b    dow not %eof;
 
          //---------------------------------------------------------
          // Spin through driver file and load data from tags as they occur.
          // XMLGENINC  XINCLUDE(*YES) *YES, *NO
          // XMLGENMBR  XMBR(XMLGEN) XMBRATR(CLP) XFROMSRCF(JCLSRC) +
          // XFROMSRCL(JCRCMDS) XTOSRCF(QCLSRC) +
          // XOBJTYPE(*PGM) XGENCRT(*YES)
          // XMLGENCMD  XCMD(CRTDTAARA DTAARA(&TOLIB/TEST) +
          // TYPE(*CHAR) LEN(10) VALUE(A))
          //---------------------------------------------------------
          aa = %scan('XMLGENMBR': xScriptSrc);
 2b       if aa > 0;
             exsr srLoadString;
 
             // extract values from mbr script command
             xdata = %trimr(%editc(SequenceNum:'4'));
             %subst(xdata: 5: 3) = 'mbr';
             aa = %scan('XMBR(': string);
             cc = %scan(')': string: aa + 5);
             %subst(xdata: 9: 10) = %subst(string: aa + 5: cc - (aa + 5));
             aa = %scan('XMBRATR(': string: cc + 1);
             cc = %scan(')': string: aa + 8);
             %subst(xdata: 20: 10) = %subst(string: aa + 8: cc - (aa + 8));
             aa = %scan('XFROMSRCF(': string: cc + 1);
             cc = %scan(')': string: aa + 10);
             %subst(xdata: 31: 10) = %subst(string: aa + 10: cc - (aa + 10));
             aa = %scan('XFROMSRCL(': string: cc + 1);
             cc = %scan(')': string: aa + 10);
             %subst(xdata: 42: 10) = %subst(string: aa + 10: cc - (aa + 10));
             aa = %scan('XTOSRCF(': string: cc + 1);
             cc = %scan(')': string: aa + 8);
             %subst(xdata: 53: 10) = %subst(string: aa + 8: cc - (aa + 8));
             aa = %scan('XOBJTYPE(': string: cc + 1);
             cc = %scan(')': string: aa + 9);
             %subst(xdata: 64: 7) = %subst(string: aa + 9: cc - (aa + 9));
             aa = %scan('XGENCRT(': string: cc + 1);
             cc = %scan(')': string: aa + 8);
             %subst(xdata: 72: 1) = %subst(string: aa + 9: 1);
             rrn += 1;
             write sbfdta1;
 2x       else;
             aa = %scan('XMLGENCMD': xScriptSrc);
 3b          if aa > 0;
                exsr srLoadString;
                // extract command from string
                clear xdata;
                rrn += 1;
                write sbfdta1;
                xdata = %trimr(%editc(SequenceNum:'4'));
                %subst(xdata: 5: 3) = 'cmd';
 
                %len(string) = %len(string) - 2;
                bb = %len(string);
                aa = (%scan('XCMD(': string) + 5);
 
                // see if one line command
 4b             if bb - aa < 69;
                   %subst(xdata: 9) = %subst(string: aa: (bb - aa) + 1);
                   rrn += 1;
                   write sbfdta1;
 4x             else;
                   // multiline command
 5b                dou aa > bb;
                      %subst(xdata: 9) = %subst(string: aa);
                      rrn += 1;
                      write sbfdta1;
                      clear xdata;
                      aa += 69;
 5e                enddo;
 4e             endif;
                clear xdata;
                rrn += 1;
                write sbfdta1;
 3e          endif;
 2e       endif;
          read SCRIPT inputDS;
 1e    enddo;
 
       //---------------------------------------------------------
       // Show subfile
       //---------------------------------------------------------
       scDow = f_GetDayName();
 
       scObjHead =
       f_BuildString('&  &  &   Installer: &':
       QusrmbrdDS.Mbr: QusrmbrdDS.File: QusrmbrdDS.Lib: xinclude);
 
       Ind.sfldsp = (rrn > 0);
       Ind.sfldspctl = *on;
       write sfooter1;
       exfmt sbfctl1;
 
       *inlr = *on;
       close SCRIPT;
       return;
 
       //---------------------------------------------------------
       // read input file to load all parts of script command into
       // single string for processing.
       // Drop plus + sign and assume string completed when
       // current line does not terminate in + sign.
       //---------------------------------------------------------
       begsr srLoadString;
       SequenceNum += 1;
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
             read Script inputDS;
 2e       endif;
 1e    enddo;
       endsr;
