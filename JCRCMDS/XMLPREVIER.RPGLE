       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // XMLPREVIER - Preview uploaded XML install members
       // It is recommended to run this program over any
       //  uploaded XMLGEN generated source before installing to list
       //   1. source members installed.
       //   2. source files created.
       //   3. any commands executed during installation.
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f XMLINPUT disk(112);
       dcl-ds inputDS;
        xmltag1 char(9) pos(13);
        xmlinstallpgm char(17) pos(13);
        xmltag2 char(10) pos(18);
        xmlcode char(100) pos(13);
       end-ds;
 
       dcl-f XMLPREVIED workstn sfile(sbfdta1: rrn) infds(infds) indds(ind);
 
       /define FunctionKeys
       /define Infds
       /define Dspatr
       /define Ind
       /define Sds
       /define Constants
       /define f_GetDayName
       /define f_BuildString
       /define f_RmvSflMsg
       /define f_SndSflMsg
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s string varchar(500);
       dcl-s SequenceNum packed(3);
       dcl-s IsEnableInst ind;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_SrcMbr char(10);
        p_SrcFil char(10);
        p_SrcLib char(10);
        p_UsrsFil char(10);
        p_Install char(1);
       end-pi;
       //---------------------------------------------------------
 
       aInstall = ND;
       p_Install = 'N';
       f_RmvSflMsg(ProgId);
       scDow = f_GetDayName();
       scObjHead = f_BuildString('&  &  &': P_SrcMbr: p_SrcFil: p_SrcLib);
 
       read xmlinput inputDS;
 1b    dow not %eof;
          // determine if install_program source is included in text
 2b       if xmlinstallpgm = '<install_program>';
             IsEnableInst = *on;
             aInstall = White;
 
             // Extract values based on XML tags and load to subfile record(s)
 2x       elseif xmltag1 = 'mbrname =';
             SequenceNum += 1;
             xdata = %trimr(%editc(SequenceNum:'4'));
             %subst(xdata: 5: 3) = 'mbr';
             %subst(xdata: 9: 10) = %subst(xmlcode: 13: 10);
 
 2x       elseif xmltag1 = 'mbrtype =';
             %subst(xdata: 20: 10) = %subst(xmlcode: 13: 10);
 
 2x       elseif xmltag1 = 'mbrtext =';
             %subst(xdata: 43) = %subst(xmlcode: 13: 50);
 
 2x       elseif xmltag1 = 'srcfile =';
 3b          if p_UsrsFil = '*DEFAULTS';
                %subst(xdata: 31: 10) = %subst(xmlcode: 13: 10);
 3x          else;
                %subst(xdata: 31: 10) = p_UsrsFil;
 3e          endif;
 
 2x       elseif xmltag1 = 'srcccsid=' or xmltag1 = 'srccssid=';
             rrn += 1;
             write sbfdta1;
 
             //---------------------------------------------------------
             // qcmdexc statement. Build statement from record between start
             // and stop tags.  When stop tag, process into subfile records
 2x       elseif xmltag1 = '<qcmdexc>';
             clear string;
             aa = 1;
             read xmlinput inputDS;
 3b          dow not(xmltag2 = '</qcmdexc>');
                %len(string) += 100;
                %subst(string: aa: 100) = xmlcode;
                aa += 100;
                read xmlinput inputDS;
 3e          enddo;
 
             //---------------------------------------------------------
             // Replace &tolib (no matter how many times in string)
             // with whatever library user has selected at run time.
             // Must replace create-from source files if user has selected override.
             //---------------------------------------------------------
             string = %scanrpl('&tolib': %trimr(p_SrcLib): string);
 
 3b          if not(p_UsrsFil = '*DEFAULTS');
                aa = %scan('SRCFILE(': string);
 4b             if aa > 0;
                   aa = %scan('/': string: aa);
 5b                if aa > 0;
                      bb = %scan(')': string: aa);
                      string = %replace(%trimr(p_UsrsFil): string:
                      aa + 1: bb-(aa + 1));
 5e                endif;
 4e             endif;
 3e          endif;
 
             // parse out commands and write to subfile
             clear xdata;
             rrn += 1;
             write sbfdta1;
             SequenceNum += 1;
             xdata = %trimr(%editc(SequenceNum:'4'));
             %subst(xdata: 5: 3) = 'cmd';
             aa = 1;
             bb = %len(string);
             // see if one line command
 3b          if bb - aa < 69;
                %subst(xdata: 9) = %subst(string: aa: (bb - aa) + 1);
                rrn += 1;
                write sbfdta1;
 3x          else;
                // multiline command
 4b             dou aa > bb;
                   %subst(xdata: 9) = %subst(string: aa);
                   rrn += 1;
                   write sbfdta1;
                   clear xdata;
                   aa += 69;
 4e             enddo;
 3e          endif;
             clear xdata;
             rrn += 1;
             write sbfdta1;
 2e       endif;
 
          read xmlinput inputDS;
 1e    enddo;
 
       //---------------------------------------------------------
       // Show subfile.  F3/F12 = Exit   F10=Run Install
       //---------------------------------------------------------
       Ind.sfldsp = (rrn > 0);
       Ind.sfldspctl = *on;
 1b    if rrn = 0;
          f_SndSflMsg(ProgId: 'No XMLGEN tags found in source member');
 1x    elseif not IsEnableInst;
          f_SndSflMsg(ProgId: 'Install Program not included in XML');
 1e    endif;
 
       write msgctl;
       write sfooter1;
       exfmt sbfctl1;
       f_RmvSflMsg(ProgId);
 
       // send parm back to CL to run installer
 1b    if InfdsFkey = f10 and IsEnableInst;
          p_Install = 'Y';
 1e    endif;
       *inlr = *on;
       return;
