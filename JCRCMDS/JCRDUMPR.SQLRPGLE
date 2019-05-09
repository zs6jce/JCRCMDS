       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRDUMPR - Dump count by program
       //  spin through list of spooled files retrieved from qezdebug outq.
       //   extract information from spooled file to load into work file.
       //    display or print selections
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCRDUMPD workstn sfile(sbfdta1: rrn) infds(infds) indds(ind)
       usropn;
       dcl-f JCRDUMPP printer oflind(IsOverFlow) usropn;
 
       /define Constants
       /define Infds
       /define FunctionKeys
       /define Ind
       /define Sds
       /define f_RunOptionSplf
       /define f_RmvSflMsg
       /define f_SndSflMsg
       /define f_GetDayName
       /define f_GetQual
       /define f_Quscrtus
       /define f_SndCompMsg
       /define f_DisplayLastSplf
       /define Quscmdln
       /define ApiErrDS
       /define Qspclosp
       /define Qspgetsp
       /define Qspopnsp
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-ds ioDS;
        pgmnam char(10) ;
        pgmlib char(10);
        psdate date;
        pstime time;
        pmsgd char(60);
        psplfnam char(10);
        psplfnbr char(6);
        pjobnam char(10);
        pjobnbr char(6);
        pusernam char(10);
       end-ds;
 
       dcl-s Buffer char(5000) based(ptr4);
       dcl-s DumpType char(4);
       dcl-s InternalSplfID char(16);
       dcl-s IntJobID char(16);
       dcl-s SelectAll char(4) inz('*NO');
       dcl-s SpoolDump char(4) inz('*NO');
       dcl-s ip_isoDate date;
       dcl-s Handle int(10);
       dcl-s OffsetToOffset int(10) based(ptr2);
       dcl-s OrdinalNumber int(10) inz(-1);
       dcl-s dd uns(5);
       dcl-s IsRefresh ind inz(*off);
       dcl-s ppgm char(10);
       dcl-s plib char(10);
       dcl-s L1Cnt uns(10);
 
       dcl-c vDateEntered 'Date Entered System  . ';
       dcl-c vLibrary '   Library . ';
       dcl-c vProgramName 'Program Name . ';
       dcl-c vProgramStat 'Program Status .';
       dcl-c vRpg3Dump 'RPG/400 FORMATTED DU';
       dcl-c vRpg4Dump 'ILE RPG/400 FORMATTE';
       dcl-c vRpg4Dumpx 'Program Status Area:';
       dcl-c vRpg4v7r1 'ILE RPG FORMATTED DUMP';
 
       dcl-ds KeysToReturn qualified;  // API key values
        *n int(10) inz(0201);  // spooled file name
        *n int(10) inz(0202);  // job name
        *n int(10) inz(0203);  // user named
        *n int(10) inz(0204);  // job number
        *n int(10) inz(0205);  // spooled file number
        *n int(10) inz(0216);  // date opned
        *n int(10) inz(0217);  // time opened
        *n int(10) inz(0218);  // internal job ID
        *n int(10) inz(0219);  // internal spool ID
       end-ds;
 
       dcl-s NumberKeys int(10) inz(9); // number to return
 
       // buffer information
       dcl-ds BufferInfoDS qualified based(BufferInfoPtr);
        BufferLength int(10) pos(1);
        OrdinalNumber int(10) pos(5);
        OffsetGeneral int(10) pos(9);
        SizeGeneral int(10) pos(13);
        OffsetToPage int(10) pos(17);
        SizePageData int(10) pos(21);
        NumPageEntries int(10) pos(25);
        SizePageEntry int(10) pos(29);
        OffsetPrintDataSection int(10) pos(33);
        SizePrintDataSection int(10) pos(37);
       end-ds;
 
       // get end of line of print as determined by Qspgetsp API
       dcl-ds EndOfLineDS qualified;
        *n char(1) inz(x'00');
        *n char(1) inz(x'15');
        *n char(1) inz(x'00');
        *n char(1) inz(x'34');
       end-ds;
 
       dcl-ds cvt qualified;
        Alpha4 char(4) pos(1);
        Binary4 int(10) pos(1) inz;
       end-ds;
 
       // List Spooled Files
       dcl-pr Quslspl ExtPgm('QUSLSPL');
        *n char(20);  // user space
        *n char(8) const;  // format
        *n char(10) const;  // user
        *n char(20);  // outq and lib
        *n char(10) const;  // form type
        *n char(10) const;  // user data
        *n like(ApiErrDS);
        *n char(26) const;  // not used job info
        *n like(KeysToReturn);
        *n int(10);  // number of keys
       end-pr;
 
       dcl-ds QuslsplDS qualified based(QuslsplPtr);
        NumFieldRtn int(10) pos(1);  // 0200 format only
       end-ds;
 
       // extract repeating key value fields
       dcl-ds splf0200DS qualified based(splf0200Ptr);
        LenghtOfInfo int(10) pos(1);
        Keynum int(10) pos(5);
        TypeOfData char(1) pos(9);
        LenOfData int(10) pos(13);
        KeyData char(17) pos(17);
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_OutqQual char(20);
        p_ObjType char(10);
        p_Date char(7);
        p_Output char(8);
        p_PgmQual char(20);
       end-pi;
       //---------------------------------------------------------
 
       exec sql set option commit=*none,datfmt=*iso,dlyprp=*yes,naming=*sys;
       scDow = f_GetDayName();
 
       exec sql DROP TABLE qtemp/jcrdumpf;
       exec sql CREATE TABLE qtemp/jcrdumpf (
            PGMNAM CHAR(10) NOT NULL DEFAULT '' ,
            PGMLIB CHAR(10) NOT NULL DEFAULT '' ,
            PSDATE DATE NOT NULL DEFAULT CURRENT_DATE ,
            PSTIME TIME NOT NULL DEFAULT CURRENT_TIME ,
            PMSGD CHAR(60) NOT NULL DEFAULT '' ,
            PSPLFNAM CHAR(10) NOT NULL DEFAULT '' ,
            PSPLFNBR CHAR(6) NOT NULL DEFAULT '' ,
            PJOBNAM CHAR(10) NOT NULL DEFAULT '' ,
            PJOBNBR CHAR(6) NOT NULL DEFAULT '' ,
            PUSERNAM CHAR(10) NOT NULL DEFAULT '' );
 
       //---------------------------------------------------------
       // dates defined in cmds are CYYMMDD
       //  check special values for all or current only
       //---------------------------------------------------------
 1b    dou not IsRefresh;
 2b       if p_Date = '0222222';
             SelectAll = '*YES';
 2x       elseif p_Date = '0333333';
             ip_isoDate = %date();
 2x       elseif p_Date = '0444444';
             ip_isoDate = %date() - %days(1);
 2x       else;
             ip_isoDate = %date(%subst(p_Date: 2: 6): *ymd0);
 2e       endif;
 
          //---------------------------------------------------------
          // create user spaces for APIs and load spooled file list
          //---------------------------------------------------------
          ApiHeadPtr = f_Quscrtus(UserSpaceName);
          ApiHeadPtr2 = f_Quscrtus(UserSpaceName2);
 
          // load spooled file internal names to user space
          callp QUSLSPL(
                UserSpaceName:
                'SPLF0200':
                '*ALL':
                p_OutqQual:
                '*ALL':
                '*ALL':
                ApiErrDS:
                ' ':
                KeysToReturn:
                NumberKeys);
 
          //---------------------------------------------------------
          QuslsplPtr = ApiHeadPtr + ApiHead.OffSetToList;
 
 2b       for ForCount = 1 to ApiHead.ListEntryCount;
             // Spin through data to extract key values
             splf0200Ptr = QuslsplPtr + 4;
 
 3b          for ForCount2 = 1 to QuslsplDS.NumFieldRtn;
 4b             if splf0200DS.Keynum = 0201;
                   pSplfNam = splf0200DS.KeyData;
 4x             elseif splf0200DS.Keynum = 0202;
                   PJobNam = splf0200DS.KeyData;
 4x             elseif splf0200DS.Keynum = 0203;
                   pUserNam = splf0200DS.KeyData;
 4x             elseif splf0200DS.Keynum = 0204;
                   PJobNbr = splf0200DS.KeyData;
 4x             elseif splf0200DS.Keynum = 0205;
                   cvt.Alpha4 = splf0200DS.KeyData;
                   evalr pSplfNbr = '000000' + %char(cvt.Binary4);
 4x             elseif splf0200DS.Keynum = 0216;
                   pSdate = %date(%subst(splf0200DS.KeyData: 2: 6): *ymd0);
 4x             elseif splf0200DS.Keynum = 0217;
                   pStime = %time(%subst(splf0200DS.KeyData: 1: 6): *hms0);
 4x             elseif splf0200DS.Keynum = 0218;
                   IntJobID = splf0200DS.KeyData;
 4x             elseif splf0200DS.Keynum = 0219;
                   InternalSplfID = splf0200DS.KeyData;
 4e             endif;
                splf0200Ptr += splf0200DS.LenghtOfInfo;
 3e          endfor;
 
             // use internal identifiers to open spooled file
 3b          if SelectAll = '*YES'
                or ip_isoDate = pSdate;
                callp QSPOPNSP(
                      Handle:
                      '*INT':
                      IntJobID:
                      InternalSplfID:
                      '*INT':
                      0:
                      8:
                      ApiErrDS);
 
                // load 1st pages of print data
                callp QSPGETSP(
                      Handle:
                      UserSpaceName2:
                      'SPFR0200':
                      OrdinalNumber:
                      '*ERROR':
                      ApiErrDS);
 
                //---------------------------------------------------------
                // retrieve offset to page data offset.
                // get offsets to print data.
                // retrieve 1st buffer of print data.
                //---------------------------------------------------------
                Ptr2 = ApiHeadPtr2 + 92;  //Offset to Offset
                BufferInfoPtr = ApiHeadPtr2 + OffsetToOffset;
                Ptr4 =
                ApiHeadPtr2 + BufferInfoDS.OffsetPrintDataSection;
 
                // close spooled file
                callp QSPCLOSP(Handle: ApiErrDS);
 
                // extract info about dump and determine type dump
                SpoolDump = '*NO';
 4b             if %subst(Buffer: 48: 20) = vRpg3Dump;  //RPG3 dump
                   SpoolDump = '*YES';
                   DumpType = 'RPG3';
 4e             endif;
                // - - -
 4b             if %subst(Buffer: 48: 20) = vRpg4Dump
                   or %subst(Buffer: 51: 20) = vRpg4Dumpx   //RPG4 dump
                   or %subst(Buffer: 48: 22) = vRpg4v7r1;  //RPG4 v7r1
                   SpoolDump = '*YES';
                   DumpType = 'RPG4';
 4e             endif;
 
                //---------------------------------------------------------
                // extract job starting date and make sure this dump is for
                // desired date. RPG3 = 6 long so requires different extract.
                //---------------------------------------------------------
 4b             if SpoolDump = '*YES';
                   cc = %scan(vDateEntered: Buffer: 1000);
 5b                if cc > 0;
 
                      // get program name
                      cc = %scan(vProgramName: Buffer: 96);
 6b                   if cc > 0;
                         cc += 43;
 
                         //---------------------------------------------------------
                         // RPG3  extract program name and Library.
                         // lllllll/pppppppp    l=Lib  p=pgm.  Library and program
                         // are variable length and must be extracted.
                         // Position of '/' is retrieved, then position of
                         // end-of-line marker.  With these values, the
                         // desired data can be extracted.
                         // position  | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
                         // |---|---|---|---|---|---|---|---|-----
                         // data      |   | l | i | b | / | p | g | m | x'00150034'
                         // cc = 2   :    aa = 5    :   bb = 9
                         // It is 43 positions from beginning of constant
                         // to start of data.
                         //---------------------------------------------------------
 7b                      if DumpType = 'RPG3';
                            aa = %scan('/': Buffer: cc);
                            bb = %scan(EndOfLineDS: Buffer: cc);
                            dd = (aa - cc);
                            PgmLib = %subst(Buffer: cc: dd);
                            aa += 1;
                            dd = bb - aa;
                            PgmNam = %subst(Buffer: aa: dd);
 
                            //---------------------------------------------------------
                            // RPGv4 extract program name and Library.
                            // ILE dump has program/Library on separate lines.
                            // There is hex00 after name
                            // and Library.  (it does not leave spaces for name.)
                            //---------------------------------------------------------
 7x                      elseif DumpType = 'RPG4';
                            aa = %scan(x'00': Buffer: cc);     //find blank after name
                            PgmNam = %subst(Buffer: cc: aa - cc);
                            cc = %scan(vLibrary: Buffer: cc);
 8b                         if cc > 0;
                               cc += 43;
                               aa = %scan(x'00': Buffer: cc);     //find blank after name
                               PgmLib = %subst(Buffer: cc: aa - cc);
 8e                         endif;
 7e                      endif;
 
                         //---------------------------------------------------------
                         // extract program status message data.
                         // MSGID/DTA does not always have data.
                         // Extract status ID then extract ID message data (if any)
                         //---------------------------------------------------------
                         pMsgd = *blanks;
                         cc = %scan(vProgramStat: Buffer: cc);  //Start of msgd
                         bb = %scan(EndOfLineDS: Buffer: cc);  //End of line
 7b                      if cc > 0;
                            cc += 43;
                            dd = bb - cc;  //length of msgid
 8b                         if dd > 0;  //THERE IS MSG
                               pMsgd = %subst(Buffer: cc: dd);  //Message data
 
                               // Step over 7 places and extract message
 9b                            if pMsgd > '00000 ';  //found one
                                  cc = bb + 7;
                                  bb = %scan(EndOfLineDS: Buffer: cc);
                                  pMsgd = %trimr(pMsgd) + '  ' +
                                  %triml(%subst(Buffer: cc: bb - cc));
 9e                            endif;
 8e                         endif;
 
                     exec sql insert into qtemp/jcrdumpf
                     values(:PgmNam,
                            :PgmLib,
                            :pSdate,
                            :pStime,
                            :pMsgd,
                            :pSplfNam,
                            :pSplfNbr,
                            :PJobNam,
                            :PJobNbr,
                            :pUserNam);
 7e                      endif;
 6e                   endif;
 5e                endif;
 4e             endif;
 3e          endif;
             QuslsplPtr += ApiHead.ListEntrySize;
 2e       endfor;
 
 2b       if p_Output = '*PRINT';
             exsr srPrint;
 2x       else;
             exsr srDisplay;
 3b          if IsRefresh;
             exec sql delete from qtemp/jcrdumpf;
 3e          endif;
 2e       endif;
 1e    enddo;
 
       f_SndCompMsg('JCRDUMP for ' +
       f_GetQual(p_OutqQual) + ' - completed');
       *inlr = *on;
       return;
 
       //-----------------------------------------------------------
       //-----------------------------------------------------------
       begsr srPrint;
       exec sql Declare cursor02 cursor for
       SELECT PSDATE, PGMLIB, PGMNAM, PMSGD, count(*) FROM qtemp/jcrdumpf
       GROUP BY PSDATE, PGMLIB, PGMNAM, PMSGD
       ORDER BY PSDATE, PGMLIB, PGMNAM, PMSGD;
 
       open JCRDUMPP;
       write PrtHead;
       IsOverFlow = *off;
 
       exec sql open cursor02;
       exec sql fetch cursor02 into :PSDATE,:PGMLIB,:PGMNAM,:PMSGD,:L1CNT;
 1b    dow sqlstate = *zeros;
 
          ssdate = psdate;
          spgmnam = pgmnam;
          spgmlib = pgmlib;
          smsgd = pmsgd;
 
 2b       if IsOverFlow;
             write PrtHead;
             IsOverFlow = *off;
 2e       endif;
 
          write PrtL1;
          LRCnt += L1Cnt;
 
           exec sql fetch cursor02 into :PSDATE,:PGMLIB,:PGMNAM,:PMSGD,:L1CNT;
 1e    enddo;
 
       write PrtLR;
         exec sql close cursor02;
       close JCRDUMPP;
       f_DisplayLastSplf('JCRDUMPR2': '*PRINT');
       endsr;
 
       //-----------------------------------------------------------
       //-----------------------------------------------------------
       begsr srDisplay;
       open JCRDUMPD;
       pPgm = %subst(p_PgmQual:1:10);
       pLib = %subst(p_PgmQual:11:10);
 
         exec sql Declare cursor01 cursor for
         SELECT * FROM qtemp/jcrdumpf
         WHERE (:pPgm = '*ALL' or (:pPgm = PGMNAM and :pLib = PGMLIB))
         ORDER BY PSDATE, PGMLIB, PGMNAM, PMSGD;
 
       IsRefresh = *off;
       Ind.sfldsp = *off;
       Ind.sfldspctl = *off;
       rrn = 0;
       write sbfctl1;
 
         exec sql open cursor01;
         exec sql fetch cursor01 into :ioDS;
 1b    dow sqlstate = *zeros;
 
          SSPLFNAM = pSPLFNAM;
          SSPLFNBR = pSPLFNBR;
          SBFOPTION = *blanks;
          SPGMNAM  = PGMNAM;
          SPGMLIB  = PGMLIB;
          SUSERNAM = pUSERNAM;
          SJOBNAM  = pJOBNAM;
          SJOBNBR  = pJOBNBR;
          SSDATE   = pSDATE;
          SSTIME   = pSTIME;
          rrn += 1;
          write sbfdta1;
 
           exec sql fetch cursor01 into :ioDS;
 1e    enddo;
 
         exec sql close cursor01;
 
       // show subfile
       Ind.sfldsp = (rrn > 0);
 1b    if (not Ind.sfldsp);
 2b       if pPgm = '*ALL';
             f_SndSflMsg(ProgId:
             'No dump spooled files found for dates');
 2x       else;
             f_SndSflMsg(ProgId:
             'No dump spooled files found for program ' + %trimr(pPgm) +
             ' in ' + %trimr(pLib));
 2e       endif;
 1e    endif;
       Ind.sfldspctl = *on;
 
 1b    dou 1 = 2;
          write msgctl;
          write sfooter1;
          exfmt sbfctl1;
 2b       if InfdsFkey = f03 or InfdsFkey = f12;
             close JCRDUMPD;
 LV          leavesr;
 2e       endif;
 
          f_RmvSflMsg(ProgId);
 
 2b       if InfdsFkey = f05;
             IsRefresh = *on;
             close JCRDUMPD;
 LV          leavesr;
 2e       endif;
 
 2b       if InfdsFkey = f06;
             exsr srPrint;
             f_SndSflMsg(ProgId: 'Print Completed');
 1i          iter;
 2e       endif;
 
 2b       if (not Ind.sfldsp);
 1i          iter;
 2e       endif;
 
 2b       if InfdsFkey = f21;
             Quscmdln();
 2e       endif;
 
          // process user requests----------------------------
          readc sbfdta1;
 2b       dow not %eof;
 3b          if sbfOption > ' ';
                f_RunOptionSplf(
                sbfOption:
                sSplfNam:
                sSplfNbr:
                sJobNam:
                sUserNam:
                sJobNbr:
                ProgId);
                sbfOption = *blanks;
                update sbfdta1;
 3e          endif;
             readc sbfdta1;
 2e       enddo;
 1e    enddo;
       endsr;
