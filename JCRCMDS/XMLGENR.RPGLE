       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // XMLGENR - Generate XML source member
       //  Read member script file to generate XML encapsulated data
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f xmlgenins disk(112) extfile('JCRCMDS') usropn  extmbr('XMLGENINS');
       dcl-ds InstallerDS len(112);
        InstallerSrc char(100) pos(13);
       end-ds;
 
       dcl-f SCRIPT disk(112) extfile(extifile) usropn  extmbr(p_scriptmbr);
       dcl-ds scriptDS len(112);
        xScriptSrc char(80) pos(13);
       end-ds;
 
       dcl-f XMLOUTFILE disk(112) usage(*update: *output)
       extfile(extxmloutfile) usropn  extmbr(p_scriptmbr);
       dcl-ds xmlinDS len(112);
        XmlDta char(100) pos(13);
       end-ds;
 
       dcl-f MBRSRC disk(112) extfile(extofile) usropn  extmbr(xmbr)
       infds(infds);
       dcl-ds mbrsrcDS len(112);
        SrcDta char(100) pos(13);
       end-ds;
 
       //---------------------------------------------------------
       /define ApiErrDS
       /define Infds
       /define Constants
       /define f_CrtCmdString
       /define f_GetQual
       /define f_Qusrmbrd
       /define f_SndCompMsg
       /define SourceOutDS
       // *ENTRY
       /define p_XMLGENR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s InstructArry char(100) dim(22) ctdata perrcd(1);
       dcl-s ba char(1) inz('[');
       dcl-s bc char(1) inz(']');
       dcl-s a17 char(17);
       dcl-s IsAllLoaded ind;
       dcl-s string varchar(500);
       dcl-s XmlToFile varchar(30);
       dcl-s extXmlOutfile char(21);
       dcl-s CopyFromRec uns(10);
       dcl-s CopyToRec uns(10);
       dcl-s RecordCount uns(10);
       dcl-s ParserLine uns(10);
 
       // values extracted from mbr script command
       dcl-s xMbr char(10);  // member name
       dcl-s xMbratr char(10);  // src mbr attr
       dcl-s xfromSrcf char(10);  // copy from Src file
       dcl-s xfromSrcl char(10);  // copy from Src lib
       dcl-s xtoSrcf char(10);  // copy to Src file
       dcl-s xobjtype char(7);  // object type
       dcl-s xgencrt char(4);  // gen compile code?
       dcl-s xinclude char(4);  // gen compile code?
 
       // Get source file length and CCSID of source file
       // from integer to alpha for load into XML.
       dcl-ds MakeAlpha1;
        SrcLenA char(5) pos(1);
        SrcLenD zoned(5) inz pos(1);
       end-ds;
 
       dcl-ds MakeAlpha2;
        SrcCcsidA char(5) pos(1);
        SrcCcsidD zoned(5) inz pos(1);
       end-ds;
 
       //---------------------------------------------------------
       clear Outds;
       extIfile = f_GetQual(p_ScriptQual);
       extXmlOutfile = f_GetQual(p_OutFileQual);
 
       open SCRIPT;
       open XmlOutfile;
 
       // generate XML header statement
       f_Write('<?xml version=' + qd + '1.0' +
       qd + ' encoding=' + qd + 'UTF-8' + qd + '?>');
 
       //---------------------------------------------------------
       // Read down in script to get whether or not to include installer.
       // XMLGENINC  XINCLUDE(*YES) *YES, *NO
       //---------------------------------------------------------
       read SCRIPT scriptDS;
 1b    dou aa > 0;
          aa = %scan('XINCLUDE(': xScriptSrc);
 2b       if aa > 0;
             cc = %scan(')': xScriptSrc: aa + 9);
             xinclude = %subst(xScriptSrc: aa + 9: cc - (aa + 9));
 1v          leave;
 2e       endif;
          read SCRIPT scriptDS;
 1e    enddo;
 
       //---------------------------------------------------------
       // Generate Install instructions and Install program
       //---------------------------------------------------------
 1b    if xinclude = '*YES';
          // load <upload attributes   Change 'Craig Rutledge' to your name here.
          f_Write('<upload' +
          '  appname=' + qd + %trimr(p_ScriptMbr) + qd +
          '  appauthor=' + qd + 'Craig Rutledge' + qd +
          '  appblddate=' + qd + %editc(*date:'Y') + qd + '>');
 
          //---------------------------------------------------------
          // load <install_instructions>
          // hex values BA=open  BC=close
          // Load instruction array to outfile.
          //---------------------------------------------------------
          f_Write('<install_instructions><!'+ba+'CDATA'+ba);
 
 2b       for aa = 1 to %elem(InstructArry);
             f_Write(InstructArry(aa));
 2e       endfor;
 
          //---------------------------------------------------------
          // load mbr names that are included in distribution.
          // Read through file looking for XMLGENMBR command,
          // from that extract member name, member type, and member text.
          //---------------------------------------------------------
          read SCRIPT scriptDS;
 2b       dow not %eof;
             aa = %scan('XMLGENMBR': xScriptSrc);
 3b          if aa > 0;
                exsr srLoadString;
                exsr srParseMbrVal;
                f_Write('*   ' + xMbr + ' ' + xMbratr + ' ' +
                f_GetMbrText(xfromSrcf + xfromSrcl: xMbr));
 3e          endif;
 
             read SCRIPT scriptDS;
 2e       enddo;
          chain 1 SCRIPT scriptDS;
 
          // write comment line / closing border line.
          f_Write('*');
          f_Write(InstructArry(1));
 
          // close brackets
          f_Write(bc+bc+'>  </install_instructions>');
 
          // load <install_program>    Load RPG Source array to outfile.
          f_Write('<install_program><!'+ba+'CDATA'+ba);
 
          open xmlgenins;
          read xmlgenins InstallerDS;
 2b       dow not %eof;
             f_Write(InstallerSrc);
             read xmlgenins InstallerDS;
 2e       enddo;
          close xmlgenins;
 
 
          // close brackets
          f_Write(bc+bc+'>  </install_program>');
 1x    else;
          f_Write('<upload>');
 1e    endif;
 
       //---------------------------------------------------------
       // Spin through script file and load data from tags as they occur.
       // XMLGENMBR  XMBR(XMLGEN) XMBRATR(CLP) XFROMSRCF(JCLSRC) +
       // XFROMSRCL(JCRCMDS) XTOSRCF(QCLSRC) +
       // XOBJTYPE(*PGM) XGENCRT(*YES)
       // XMLGENCMD  XCMD(CRTDTAARA DTAARA(&TOLIB/TEST) +
       // TYPE(*CHAR) LEN(10) VALUE(A))
       //---------------------------------------------------------
       read SCRIPT scriptDS;
 1b    dow not %eof;
 
          aa = %scan('XMLGENMBR': xScriptSrc);
 2b       if aa > 0;
             exsr srLoadString;
             exsr srParseMbrVal;
             exsr srLoadMbr;
 2x       else;
             aa = %scan('XMLGENCMD': xScriptSrc);
 3b          if aa > 0;
                exsr srLoadString;
                exsr srLoadExc;
 3e          endif;
 2e       endif;
          read SCRIPT scriptDS;
 1e    enddo;
 
       // generate completed message code.
       f_Write('<sendmsg  sendmsgid=' + qd +
       'CPF9897' + qd + ' ' +
       'sendmsgtype = ' + qd +
       '*COMP     ' + qd + '>' +
       '<!'+ba+'CDATA'+ba);
 
       f_Write('XML Package ' + %trimr(p_ScriptMbr) +
       ' completed successfully.');
 
       f_Write(bc+bc+'>  </sendmsg>');
 
       f_Write('</upload>');
       close SCRIPT;
 
       //---------------------------------------------------------
       // Now that all XML is generated, spin back through
       //  and get the install program record numbers.
       // Update installation copy instructions with
       //  From and To record numbers.
       //---------------------------------------------------------
 1b    if xinclude = '*YES';
          setll 1 XmlOutFile;
          read XmlOutFile xmlinDS;
 2b       dow not %eof;
             RecordCount += 1;
 3b          if %scan('TOMBR(parser) MBROPT(*REPLACE)':XmlDta) > 0;
                ParserLine = RecordCount;
 3e          endif;
 
 3b          if %scan('* /// START OF INSTALL PGM HERE ':XmlDta) > 0;
                CopyFromRec = RecordCount + 1;
 3e          endif;
 
 3b          if %scan('* /// END OF INSTALL PGM HERE ':XmlDta) > 0;
                CopyToRec = RecordCount - 1;
 2v             leave;
 3e          endif;
 
             read XmlOutfile xmlinDS;
 2e       enddo;
 
          chain ParserLine XmlOutfile xmlinDS;
          %subst(XmlDta:41) = 'FROMRCD(' + %char(CopyFromRec) +
          ') TORCD(' + %char(CopyToRec) + ')';
          update XmlOutfile xmlinDS;
 1e    endif;
 
       close XmlOutfile;
       f_SndCompMsg('XML member ' + %trimr(p_ScriptMbr) + ' generated.');
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       // Load member into XML output
       //---------------------------------------------------------
       begsr srLoadMbr;
       // send status message to user
       f_Write('<sendmsg  sendmsgid=' + qd +
       'CPF9897' + qd + ' ' +
       'sendmsgtype = ' + qd +
       '*STATUS   ' + qd + '>' +
       '<!'+ba+'CDATA'+ba);
 
       f_Write('Extracting ' + %trimr(xMbr) +
       '  type ' + %trimr(xMbratr) + ' - in progress.');
       f_Write(bc+bc+'>  </sendmsg>');
 
       // load F spec keywords.  Asynchronously load source records
       // into memory for faster reads.  Generate XML code.
       extOfile = %trimr(xfromSrcl) + '/' + xfromSrcf;
       open MBRSRC;
       SrclenD = InfdsRecLen;
       SrcCcsidD = InfdsCcsid;
 
       // member attributes
       f_Write('<!-- START OF MEMBER  -->');
 
       f_Write('<mbr');
 
       f_Write('mbrname =  ' + qd + xMbr + qd);
       f_Write('mbrtype =  ' + qd + xMbratr + qd);
 
       f_Write('mbrtext =  ' + qd +
       f_GetMbrText(xfromSrcf + xfromSrcl: xMbr) + qd);
 
       f_Write('srcfile =  ' + qd + xtoSrcf + qd);
       f_Write('srclib  =  ' + qd + 'selected  ' + qd);
       f_Write('srclen  =  ' + qd + Srclena + qd);
       f_Write('srcccsid=  ' + qd + Srcccsida + qd + '>');
 
       // load member data into text file.
       f_Write('<copysrc>' + '<!'+ba+'CDATA'+ba);
 
       //---------------------------------------------------------
       // read through member loading source record to outfile
       //---------------------------------------------------------
       read MBRSRC mbrsrcDS;
 1b    dow not %eof;
 2b       if InfdsRecLen = 92;
             %subst(SrcDta:81) = *blanks;
 2e       endif;
          f_Write(SrcDta);
 
          read MBRSRC mbrsrcDS;
 1e    enddo;
 
       close MBRSRC;
 
       // close brackets
       f_Write(bc+bc+'>  </copysrc>');
       f_Write('</mbr>');
 
       // generate object creation code
       // if flag is set to '*YES'
 1b    if xgencrt = '*YES';
 2b       if xMbratr = 'CMD';
             exsr srCrtCmd;
 2x       else;
             f_Write('<compile>' + '<!'+ba+'CDATA'+ba);
 
             XmlToFile = ' SRCFILE(&tolib/' + %trimr(xtoSrcf) + ')';
 
 3b          if xMbratr = 'RPGLE'
                and xobjtype = '*PGM';
                f_Write('CRTBNDRPG PGM(&tolib/' +
                %trimr(xMbr) + ')' + XmlToFile +
                ' TGTRLS(*CURRENT)');
                // Thanks to David George in UK
                // for coding these 2 module creation commands
 
 3x          elseif xMbratr = 'SQLRPGLE'
                and xobjtype = '*MODULE';
                f_Write('CRTSQLRPGI OBJ(&tolib/' +
                %trimr(xMbr) + ')' + XmlToFile +
                ' OBJTYPE(*MODULE)' +
                ' COMMIT(*NONE)' +
                ' TGTRLS(*CURRENT)');
 
 3x          elseif xMbratr = 'RPGLE'
                and xobjtype = '*MODULE';
                f_Write('CRTRPGMOD MODULE(&tolib/' +
                %trimr(xMbr) + ')' + XmlToFile +
                ' TGTRLS(*CURRENT)');
 
 3x          elseif xMbratr = 'SQLRPGLE'
                and xobjtype = '*PGM';
                f_Write('CRTSQLRPGI OBJ(&tolib/' +
                %trimr(xMbr) + ')' + XmlToFile +
                ' COMMIT(*NONE)' +
                ' TGTRLS(*CURRENT)');
 
 3x          elseif xMbratr = 'RPG'
                and xobjtype = '*PGM';
                f_Write('CRTRPGPGM PGM(&tolib/' +
                %trimr(xMbr) + ')' + XmlToFile +
                ' TGTRLS(*CURRENT)');
 
 3x          elseif xMbratr = 'CLP'
                and xobjtype = '*PGM';
                f_Write('CRTCLPGM PGM(&tolib/' +
                %trimr(xMbr) + ')' + XmlToFile +
                ' TGTRLS(*CURRENT)');
 
 3x          elseif xMbratr = 'CLLE'
                and xobjtype = '*PGM';
                f_Write('CRTBNDCL PGM(&tolib/' +
                %trimr(xMbr) + ')' + XmlToFile +
                ' TGTRLS(*CURRENT)');
 
 3x          elseif xMbratr = 'PNLGRP';
                f_Write('CRTPNLGRP PNLGRP(&tolib/' +
                %trimr(xMbr) + ')' + XmlToFile);
 
 3x          elseif xMbratr = 'DSPF';
                f_Write('CRTDSPF FILE(&tolib/' +
                %trimr(xMbr) + ')' + XmlToFile);
 
 3x          elseif xMbratr = 'PRTF';
                f_Write('CRTPRTF FILE(&tolib/' +
                %trimr(xMbr) + ')' + XmlToFile);
 
 3x          elseif xMbratr = 'PF';
                f_Write('CRTPF FILE(&tolib/' +
                %trimr(xMbr) + ')' + XmlToFile);
 
 3x          elseif xMbratr = 'DDL';
                f_Write('RUNSQLSTM ' + %trimr(XmlToFile)  +
                ' SRCMBR(' + %trimr(xMbr) + ') COMMIT(*NONE)');
 
 3x          elseif xMbratr = 'LF';
                f_Write('CRTLF FILE(&tolib/' +
                %trimr(xMbr) + ')' + XmlToFile);
 3e          endif;
 
             // close brackets
             f_Write(bc+bc+'>  </compile>');
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Command data was loaded into single string.  Break commands
       // into 100 byte chunks and write to XML.
       //---------------------------------------------------------
       begsr srLoadExc;
       f_Write('<qcmdexc><!'+ba+'CDATA'+ba);
       %len(string) = %len(string) - 2;
 
       // replace &TOLIB from command prompt with &tolib for XML
       cc = %scan('&TOLIB': string);
 1b    dow cc > 0;
          %subst(string: cc: 6) = '&tolib';
          cc = %scan('&TOLIB': string: cc + 1);
 1e    enddo;
       bb = %len(string);
       aa = (%scan('XCMD(': string) + 5);
       // see if one line command
 1b    if bb - aa < 101;
          f_Write(%subst(string: aa: (bb - aa) + 1));
 1x    else;
          // multiline command
 2b       dou aa > bb;
             f_Write(%subst(string: aa));
             aa += 100;
 2e       enddo;
 1e    endif;
       // close brackets
       f_Write(bc+bc+'>  </qcmdexc>');
       endsr;
 
       //---------------------------------------------------------
       // extract values from mbr script command
       // xMbr           s  10     member name
       // xMbratr        s  10     source mbr attr
       // xfromSrcf      s  10     copy from Src file
       // xfromSrcl      s  10     copy from Src lib
       // xtoSrcf        s  10     copy to Src file
       // xobjtype       s   7     object type
       // xgencrt        s   4     gen compile code
       //---------------------------------------------------------
       begsr srParseMbrVal;
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
       endsr;
 
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
 3b          if %subst(xScriptSrc: cc: 1) ='+';
                %subst(xScriptSrc: cc: 1) =' ';
 3x          else;
                IsAllLoaded = *on;
 3e          endif;
 2e       endif;
 
          string += %trim(xScriptSrc) + ' ';
 2b       if not IsAllLoaded;
             read SCRIPT scriptDS;
 2e       endif;
 1e    enddo;
       endsr;
 
       //---------------------------------------------------------
       // Extract command definition
       //---------------------------------------------------------
       begsr srCrtCmd;
       string = f_CrtCmdString(xMbr + xfromSrcl);
       string = ' XCMD(' + string;
 
       // remove question marks used by command recreate utility
       cc = %scan('?': string);
 1b    dow cc > 0;
          string = %replace('': string: cc: 1);
          cc = %scan('?': string: cc);
 1e    enddo;
 
       // replace source file with value from 'To Source'
       a17 = '&tolib/' + xtoSrcf;
       cc = %scan('SRCFILE(': string);
       aa = %scan(')': string: cc);
       string = %replace(a17: string: cc+8: aa-(cc+8));
 
       //---------------------------------------------------------
       // load '&tolib' everywhere *LIBL is not specified
       // look for qualifier / then back up to first open parenth (
       //---------------------------------------------------------
       cc = %scan('/': string);
 1b    dow cc > 0;
 2b       for aa = cc -1 downto cc-10;
 3b          if %subst(string:aa:1) = '(';
 4b             if %subst(string: aa+1: cc-(aa+1)) <> '*LIBL';
                   string = %replace('&tolib': string: aa+1: cc-(aa+1));
 4e             endif;
 2v             leave;
 3e          endif;
 2e       endfor;
          cc = %scan(')': string: aa); // get past compressed section
          cc = %scan('/': string: cc);
 1e    enddo;
       string += '  ';
       exsr srLoadExc;
       endsr;
 
       //---------------------------------------------------------
       // Write generated code to outfile
       //---------------------------------------------------------
       dcl-proc f_Write;
        dcl-pi *n;
         pSrcCod char(100) const;
        end-pi;
 
        OutDS.Src100 = pSrcCod;
        OutDS.SrcSeq += .01;
        write XmlOutFile OutDS;
        return;
       end-proc;
 
       //---------------------------------------------------------
       // get member description then xlate out invalid characters
       dcl-proc f_GetMbrText;
        dcl-pi *n char(50);
         p_SrcFile char(20) const;
         p_SrcMbr char(10);
        end-pi;
 
        QusrmbrdDS = f_Qusrmbrd(p_SrcFile: p_SrcMbr: 'MBRD0100');
        return %xlate(qd + qs + '<&%':'     ': QusrmbrdDS.Text);
 
       end-proc;
       //---------------------------------------------------------
**         install_instructions
//---------------------------------------------------------
*  1. Upload entire XML txt to source file 112 long, into any mbr
*     name not in this XML (suggest member name like ABCX or XYZX). Source
*     file must be in library where are to be installed.
*
*  2. Extract XML parser program (If XMLPREVIEW installed, skip to step 3.)
*     Copy text between start tag <install_program> and end
*     tag </install_program> into any member name (your choice)
*     in file QRPGLESRC member type RPGLE.   CRTBNDRPG to compile.
*        Example copy command (if you named member A in step 1)
*        CPYF FROMFILE(mylib/JCRCMDS) TOFILE(mylib/JCRCMDS) FROMMBR(a) +
*        TOMBR(parser) MBROPT(*REPLACE) FROMRCD(378) TORCD(704)
*
*  3. Call install program (or execute XMLPREVIEW) passing 3 Parms.
*       'your-member-name you uploaded this text into'
*       'your-source-file-name member is in'
*       'your-library-name source file is in'
*
*  Various source members are extracted and objects required
*   for application will be created in your-library-name.
*
*  Members in this install: (to view or manually extract members, scan <mbr)
