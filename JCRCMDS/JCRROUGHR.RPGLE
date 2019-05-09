       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRROUGHR- Generate external print file from splf cpy to pf
       //---------------------------------------------------------
       /define ControlStatements
       /define Constants
       /define f_GetQual
       /define f_SndCompMsg
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f CPYSPLF disk(132) extfile(extifile) usropn;
       dcl-ds inputDS;
        input char(132);
       end-ds;
 
       dcl-f DDSSRC disk(92) usage(*output) extfile(extofile) extmbr(p_DdsMbr)
       usropn;
 
       dcl-ds OutDS qualified inz;
        SrcSeq zoned(6:2) pos(1) inz(0);
        SrcDate zoned(6) pos(7) inz(0);
        SrcType      char(1) pos(18);
        oAndOr       char(1) pos(19);
        CommentLine  char(73) pos(20);
        Indicator    char(9) pos(20);
        FormatR      char(1) pos(29);
        FormatName   char(10) pos(31);
        Referenced   char(1) pos(41);
        Length       char(4) pos(43);
        DataType     char(1) pos(47);
        DecimalPos   char(1) pos(49);
        LinePosition char(3) pos(54);
        Keyword      char(36) pos(57);
       end-ds;
 
       dcl-s LineCount packed(6: 2) inz(0);
       dcl-s ExceptLineCnt uns(5);
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_DdsMbr char(10);
        p_DdsFileQual char(20);
        p_CpySplfPFQual char(20);
       end-pi;
       //---------------------------------------------------------
 
       extIfile = f_GetQual(p_CpySplfPFQual);
       extOfile = f_GetQual(p_DdsFileQual);
 
       // open input file and output
       open CPYSPLF;
       open DDSSRC;
       read CPYSPLF inputDS;
 1b    dow not %eof;
 
          exsr srFormatLine;
          exsr srFieldLine;
          exsr srSpaceAfter;
 
          read CPYSPLF inputDS;
 1e    enddo;
 
       // all processed
       close CPYSPLF;
       close DDSSRC;
       f_SndCompMsg('JCRROUGH for ' + %trimr(p_DDsMbr) + ' in ' +
       %trimr(extOfile) + ' - completed.');
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       // Generate record format code for either except lines
       // or when new line is coded in original RPG.
       //---------------------------------------------------------
       begsr srFormatLine;
       ExceptLineCnt += 1;
       OutDS.FormatName = 'LINE' +
       %triml(%editc(ExceptLineCnt:'3'));
 
       OutDS.FormatR = 'R';
       exsr srWriteSrcCode;
       endsr;
 
       //---------------------------------------------------------
       // use check to find start of string and scan to find end
       //---------------------------------------------------------
       begsr srFieldLine;
 1b    for aa = 1 to 132;
 
 2b       if %subst(Input:aa:1) > *blanks;
             bb = %scan(' ':Input: aa);
 3b          if bb = 0;
                bb = 133;
 3e          endif;
 
             evalr OutDS.LinePosition = %char(aa);
             OutDS.Keyword = qs + %subst(Input:aa: (bb - aa)) + qs;
             exsr srWriteSrcCode;
             aa = bb;
 2e       endif;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // Generate Skip or Space after DDS code
       //---------------------------------------------------------
       begsr srSpaceAfter;
       OutDS.Keyword = 'SPACEA(1)';
       exsr srWriteSrcCode;
       endsr;
 
       //---------------------------------------------------------
       // Write records to DDS member
       //---------------------------------------------------------
       begsr srWriteSrcCode;
       OutDS.SrcType = 'A';
       linecount += .01;
       OutDS.SrcSeq = linecount;
       write ddssrc OutDS;
       clear OutDS;
       endsr;
