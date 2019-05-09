       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRPATTRR- Crtprtf with attributes from existing PRTF
       // Uses Retrieve Printer File Attributes (QDFRPRTA) API. Only most used or
       // requested fields are being pulled.
       // Most of this program is mapping from API returned values into compile values.
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define Constants
       /define f_BuildString
       /define f_GetQual
       /define f_SndCompMsg
       // *ENTRY
       /define p_JCRPATTRR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s string1 char(500);
       dcl-s PageRotation char(5);
       dcl-s IGCdata char(4);
       dcl-s IGCextension char(4);
       dcl-s Save char(4);
       dcl-s Hold char(4);
       dcl-s OverFlow packed(3);
       dcl-s pageLen packed(6: 3);
       dcl-s pageWidth packed(6: 3);
       dcl-s CPI packed(3: 1);
       dcl-s LPI packed(3: 1);
       dcl-s FMD packed(7: 4);
       dcl-s FMA packed(7: 4);
       dcl-s FrontMargin char(19);
       dcl-s FrontOverlay char(50);
       dcl-s BackOverlay char(50);
       dcl-s FrontOvlDown packed(5: 3);
       dcl-s FrontOvlAccros packed(5: 3);
       dcl-s BackOvlDown packed(5: 3);
       dcl-s BackOvlAccros packed(5: 3);
       dcl-s BackConstant char(11);
       dcl-s Chrid char(11);
       dcl-s MaxRecordsNum packed(8);
       dcl-s MaxRecords char(8);
       dcl-s CharIdSet packed(5);
       dcl-s CharIdCodePage packed(5);
       dcl-s UsrRscLibl char(100);
       dcl-s Text char(100);
       dcl-s PrtTxt char(100);
       dcl-s UsrRscLiblEnt char(10) based(UsrRscLiblPtr);
       dcl-s UsrRscLiblPtr pointer;
 
       // Retrieve Printer File Attributes
       dcl-pr QDFRPRTA extpgm('QDFRPRTA');
        *n char(4000);  // receiver
        *n int(10) const;  // receiver length
        *n char(8) const;  // format
        *n char(20);  // file name and lib
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds qdfrprtaDS len(4000) qualified;
        BytesReturned int(10) pos(1);
        BytesAvail int(10) pos(5);
        PrintFileName char(10) pos(9);
        Lib char(10) pos(19);
        Device char(10) pos(29);
        DeviceType char(10) pos(39);
        PageSizeLen packed(15: 5) pos(49);
        PageSizeWidth packed(15: 5) pos(57);
        LPI packed(15: 5) pos(77);
        CPI packed(15: 5) pos(85);
        OverFlow int(10) pos(93);
        Text char(50) pos(98);
        FMarginDown packed(15: 5) pos(149);
        FMarginAccros packed(15: 5) pos(157);
        PrintQuality char(10) pos(219);
        FontIdentifier char(10) pos(249);
        CharIdSet int(10) pos(269);
        CharIdCodePage int(10) pos(273);
        DecimalFormat char(10) pos(277);
        PageRotation int(10) pos(417);
        PrtTxt char(30) pos(435);
        PrintBothSides char(10) pos(469);
        FrontOvlFile char(8) pos(490);
        FrontOvlLib char(10) pos(498);
        FrontOvlDown packed(15: 5) pos(509);
        FrontOvlAccros packed(15: 5) pos(517);
        BackOvlFile char(10) pos(525);
        BackOvlLib char(10) pos(535);
        BackOvlDown packed(15: 5) pos(545);
        BackOvlAccros packed(15: 5) pos(553);
        BackOvlConstant char(1) pos(561);
        IPDSPASTHR char(10) pos(563);
        UsrRscLiblOff int(10) pos(573);
        UsrRscLiblCnt int(10) pos(577);
        UsrRscLiblLen int(10) pos(581);
        FormType char(10) pos(688);
        MaxRecords int(10) pos(725);
        Hold char(1) pos(743);
        Save char(1) pos(744);
        UsrDBCSdata char(1) pos(1066);
        DBCSextension char(1) pos(1067);
       end-ds;
 
       dcl-pr Qcmdexc extpgm('QCMDEXC');
        *n char(125) options(*VarSize);
        *n packed(15: 5) const;
       end-pr;
 
       //---------------------------------------------------------
 1b    if p_CrtToLib = '*SRCLIB';
          p_CrtToLib = %subst(p_SrcFilQual:11:10);
 1e    endif;
 1b    if %subst(p_LikePrtf:1:10) = '*SRCMBR';
          %subst(p_LikePrtf:1:10) = p_SrcMbr;
 1e    endif;
 1b    if %subst(p_LikePrtf:11:10) = '*SRCLIB';
          %subst(p_LikePrtf:11:10) = %subst(p_SrcFilQual:11:10);
 1e    endif;
 
       callp QDFRPRTA(
             QDFRPRTAds:
             %size(QDFRPRTADS):
             'PRTF0100':
             p_LikePrtf:
             ApiErrds);
 
       //---------------------------------------------------------
       // User resource library list entries
       //---------------------------------------------------------
 1b    if qdfrprtaDS.UsrRscLiblCnt = 0;
          UsrRscLibl = '*DEVD';
 1x    else;
          UsrRscLiblPtr = %addr(qdfrprtaDS) + qdfrprtaDS.UsrRscLiblOff;
 2b       for aa = 1 to qdfrprtaDS.UsrRscLiblCnt;
             UsrRscLibl = %trimr(UsrRscLibl) + ' ' + UsrRscLiblEnt;
             UsrRscLiblPtr += qdfrprtaDS.UsrRscLiblLen;
 2e       endfor;
 1e    endif;
 
       IGCdata = '*NO';
 1b    if qdfrprtaDS.UsrDBCSdata = '1';
          IGCdata = '*YES';
 1e    endif;
 
       IGCextension = '*NO';
 1b    if qdfrprtaDS.DBCSextension = '1';
          IGCextension = '*YES';
 1e    endif;
 
       Hold = '*NO';
 1b    if qdfrprtaDS.Hold = '1';
          Hold = '*YES';
 1e    endif;
 
       Save = '*NO';
 1b    if qdfrprtaDS.Save = '1';
          Save = '*YES';
 1e    endif;
 
       // Degree 0=*DEVD but degree 360 = degree 0.  Go figure.
       PageRotation = %char(qdfrprtaDS.PageRotation);
 1b    if qdfrprtaDS.PageRotation = 0;
          PageRotation = '*DEVD';
 1x    elseif qdfrprtaDS.PageRotation = -1;
          PageRotation = '*COR';
 1x    elseif qdfrprtaDS.PageRotation = -2;
          PageRotation = '*AUTO';
 1x    elseif qdfrprtaDS.PageRotation = 360;
          PageRotation = '0';
 1e    endif;
 
 1b    if qdfrprtaDS.CharIdSet = 0;
          Chrid = '*DEVD';
 1x    elseif  qdfrprtaDS.CharIdSet = -1;
          Chrid = '*SYSVAL';
 1x    elseif  qdfrprtaDS.CharIdSet = -2;
          Chrid = '*JOBCCSID';
 1x    elseif  qdfrprtaDS.CharIdSet = -3;
          Chrid = '*CHRIDCTL';
 1x    else;
          CharIdSet = qdfrprtaDS.CharIdSet;
          CharIdCodePage = qdfrprtaDS.CharIdCodePage;
          Chrid = %char(CharIdSet) + ' ' + %char(CharIdCodePage);
 1e    endif;
       //---------------------------------------------------------
       pageLen = qdfrprtaDS.PageSizeLen;
       pageWidth = qdfrprtaDS.PageSizeWidth;
       CPI = qdfrprtaDS.CPI;
       LPI = qdfrprtaDS.LPI;
       Overflow = qdfrprtaDS.OverFlow;
 
 1b    if qdfrprtaDS.FMARGINACCROS = -2;
          FrontMargin = '*DEVD';
 1x    else;
          FMD = qdfrprtaDS.FMarginDown;
          FMA = qdfrprtaDS.FMarginAccros;
          FrontMargin = %char(fmd) + ' ' + %char(FMA);
 1e    endif;
 
 1b    if qdfrprtaDS.MaxRecords = 0;
          MaxRecords = '*NOMAX';
 1x    else;
          MaxRecordsNum = qdfrprtaDS.MaxRecords;
          MaxRecords = %char(MaxRecordsNum);
 1e    endif;
 
 1b    if qdfrprtaDS.FrontOvlFile = '*NONE';
          FrontOverlay = '*NONE';
 1x    else;
          FrontOvlDown = qdfrprtaDS.FrontOvlDown;
          FrontOvlAccros = qdfrprtaDS.FrontOvlAccros;
          FrontOverlay =
          f_GetQual(qdfrprtaDS.FrontOvlFile + '  ' +
          qdfrprtaDS.FrontOvlLib) + ' ' +
          %char(FrontOvlDown) + ' ' +
          %char(FrontOvlAccros);
 1e    endif;
 
 1b    if %subst(qdfrprtaDS.BackOvlFile:1:1) = '*';
          BackOverlay = qdfrprtaDS.BackOvlFile;
 1x    else;
          BackOvlDown = qdfrprtaDS.BackOvlDown;
          BackOvlAccros = qdfrprtaDS.BackOvlAccros;
 
 2b       if qdfrprtaDS.BackOvlConstant = '0';
             BackConstant = '*NOCONSTANT';
 2x       else;
             BackConstant = '*CONSTANT';
 2e       endif;
 
          BackOverlay =
          f_GetQual(qdfrprtaDS.BackOvlFile +
          qdfrprtaDS.BackOvlLib) + ' ' +
          %char(BackOvlDown) + ' ' +
          %char(BackOvlAccros) + ' ' +
          BackConstant;
 1e    endif;
 
       //---------------------------------------------------------
       // IBM represents quotes in quoted string with 2 quotes
       // 'This is a single quote '' in a string '
       // If object text or print text have single quotes,
       // need to replace with two single quotes so
       // command processer will recognize as single quote.
       //---------------------------------------------------------
       Text = %scanrpl(qs: qs+qs: qdfrprtaDS.Text);
       PrtTxt = %scanrpl(qs: qs+qs: qdfrprtaDS.PrtTxt);
 
       //---------------------------------------------------------
       // build create print file command
       //---------------------------------------------------------
       string1 =
       f_BuildString('CRTPRTF FILE(&) SRCFILE(&) +
       DEV(&) DEVTYPE(&) IGCDTA(&) IGCEXNCHR(&) +
       PAGESIZE(& &) LPI(&) CPI(&) FRONTMGN(&) +
       OVRFLW(&) PAGRTT(&) TEXT(&Q&&Q) FONT(&) PRTQLTY(&) +
       PRTTXT(&Q&&Q) FRONTOVL(&) DUPLEX(&) DECFMT(&) +
       BACKOVL(&) IPDSPASTHR(&) FORMTYPE(&Q&&Q) +
       CHRID(&) SAVE(&) HOLD(&) USRRSCLIBL(&) MAXRCDS(&) ':
       f_GetQual(p_SrcMbr + p_CrtToLib):
       f_GetQual(p_SrcFilQual):
       qdfrprtaDS.Device:
       qdfrprtaDS.DeviceType:
       IGCdata:
       IGCextension:
       %char(pageLen):
       %char(pageWidth):
       %char(LPI):
       %char(CPI):
       FrontMargin:
       %char(OverFlow):
       PageRotation:
       Text:
       qdfrprtaDS.FontIdentifier:
       qdfrprtaDS.PrintQuality:
       PrtTxt:
       FrontOverlay:
       qdfrprtaDS.PrintBothSides:
       qdfrprtaDS.DecimalFormat:
       BackOverlay:
       qdfrprtaDS.IPDSPASTHR:
       qdfrprtaDS.FormType:
       Chrid:
       Save:
       Hold:
       UsrRscLibl:
       MaxRecords);
 
       //---------------------------------------------------------
 1b    monitor;
          callp QCMDEXC(string1: %size(string1));
          f_SndCompMsg('Print file ' +%trimr(p_SrcMbr) + ' in library ' +
          %trimr(p_CrtToLib) + ' compiled by JCRPATTR.');
 1x    on-error *ALL;
          f_SndCompMsg('Print file ' +%trimr(p_SrcMbr) + ' in library ' +
          %trimr(p_CrtToLib) + ' compile FAILED.');
 1e    endmon;
 
       *inlr = *on;
       return;
