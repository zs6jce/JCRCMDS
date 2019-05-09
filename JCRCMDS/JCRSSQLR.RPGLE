       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRSSQLR - Scan strsql sessions for sql statements
       //
       // Process the dmpsysobj of interactive sql commands. The dump consists of STRSQL
       // sessions broken in 32 character blocks per record with embedded IBM control characters.
       //  Reconstruct all these short blocks into single sql statements then present a
       //  subfile of sql statements that meet selection criteria.
       //
       // This screen is useful to cut/paste from the subfile into a STRSQL session, or
       // just to see how previously did something. Choosing option X (eXecute) will attempt to
       // run the SQL. All UPDATE, DELETE, INSERT sqls can be run directly from this utility. See
       // program JCRSSQLE for sql cli interface.
       //
       // To process SELECT statements, download the utility EXCSQL from
       // Martin Rowe's website www.dbg400.net . JCRSSQL will detect if Martin's utility is
       // installed.
       //
       // This utility may be operating system sensitive due to using a system dump file.
       // Meaning IBM has been known to change the format of dumps on different OS releases.
       // This program works on current v7 releases.
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCRSSQLD workstn sfile(data1: rrn1) infds(infds) indds(ind);
       dcl-f JCRSSQL disk(264) infds(infds2) extfile('QTEMP/JCRSSQL');
 
       /define ApiErrDS
       /define Constants
       /define Dspatr
       /define Infds
       /define FunctionKeys
       /define Ind
       /define Sds
       /define BitMask
       /define f_RmvSflMsg
       /define f_SndSflMsg
       /define f_SndStatMsg
       /define f_GetRowColumn
       /define f_GetDayName
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s savScRelation like(screlation);
       dcl-s savScVal1 like(scval1);
       dcl-s savScVal2 like(scval2);
       dcl-s WrkSC like(sc);
       dcl-s Asterisk char(1);
       dcl-s ConstantPeriod char(50) inz(*all'.');
       dcl-s InPrgVary varchar(50) inz;
       dcl-s InProgressMsg char(50);
       dcl-s KeysMsg char(75);
       dcl-s LastStatement char(69) inz('A');
       dcl-s LongString varchar(32767) inz;
       dcl-s RawDumpData char(32);
       dcl-s ScanStart varchar(64) inz;
       dcl-s Sql varchar(2500) inz;
       dcl-s Sql_and_Msg varchar(2500) inz;
       dcl-s SqlKeyWord char(5);
       dcl-s SqlMsg char(67);
       dcl-s SqlWrk varchar(2500) inz;
       dcl-s StatementStart char(12) inz('TH');
       dcl-s UpperCased varchar(2500) inz;
       dcl-s NextSc uns(10);
       dcl-s PercentComp uns(10);
       dcl-s RecordCnt uns(10);
       dcl-s rrn1 like(rrn);
       dcl-s sc uns(10);
       dcl-s TestLen uns(10);
       dcl-s TwoPercent uns(10);
       dcl-s xm uns(5);
       dcl-s xx uns(5);
       dcl-s IsAllRead ind inz(*off);
       dcl-s IsDoubleByte ind inz(*off);
       dcl-s IsStarted ind inz(*off);
       dcl-s IsFirstTime ind;
 
       dcl-ds Infds2;
        NbrOfRcds int(10) pos(156);
        MiscFlags char(1) pos(196);
       end-ds;
 
       // Double Byte Character Set - IO data structure
       dcl-ds DoubleByteChar len(264) qualified inz;
        NotAuthorized char(20) pos(2);
        Asterisk char(1) pos(88);
        DumpText char(32) pos(89);
       end-ds;
 
       // Single Byte Character Set - IO data structure
       dcl-ds SingleByteChar len(264) qualified inz;
        NotAuthorized char(20) pos(1);
        Asterisk char(1) pos(87);
        DumpText char(32) pos(88);
       end-ds;
 
       // Run SQL
       dcl-pr p_JCRSSQLE extpgm('JCRSSQLE');
        *n char(2500);  // sql statement
        *n char(75);  // return message
       end-pr;
 
       //---------------------------------------------------------
       IsDoubleByte = (%bitand(bit6: MiscFlags) = bit6);
       eval(h) TwoPercent = NbrOfRcds/50;
       scDow = f_GetDayName();
 
       //---------------------------------------------------------
       // Prompt user for scan values
       //---------------------------------------------------------
 1b    dou 1 = 2;
 
     C     Showfull      tag
 
          exsr srShowSubfile;
 1e    enddo;
 
       //---------------------------------------------------------
       // show subfile / edit check scan requests
       //---------------------------------------------------------
       begsr srShowSubfile;
 1b    dow not(InfdsFkey = f03);
          savScVal1 = scval1;
          savScRelation = screlation;
          savScVal2 = scval2;
 
          Ind.sfldsp = (rrn1 > 0);
 2b       if not(Ind.sfldsp or isFirstTime);
             f_SndSflMsg(ProgId: 'No SQL Statements match selection');
 2e       endif;
 
          isFirstTime = *off;
          Ind.sfldspctl = *on;
          write msgctl;
          write keys;
          exfmt contrl1;
 2b       if InfdsFkey = f03 or InfdsFkey = f12;
 1v          leave;
 2e       endif;
 
          f_RmvSflMsg(ProgId);
          ascVal1 = %bitor(Green: UL);
          ascRelat = %bitor(Green: UL);
          SflRcdNbr = 1;
 
          //---------------------------------------------------------
          // 1) at least value1 must be entered.
          // 2) if value2 entered,
          // relationship must be 'AND' or 'OR'
          // 3) if relationship eq 'AND' or 'OR',
          // value2 must be entered.
          //---------------------------------------------------------
 2b       if scval1 = *blanks;
             CsrRowColDS =
             f_GetRowColumn('SCVAL1':InfdsFile:InfdsLib:InfdsRcdfmt);
             ascval1 = %bitor(White: RI);
             f_SndSflMsg(ProgId: 'Must enter Scan For string');
 1i          iter;
 2e       endif;
 
          // and or relationship
 2b       if scval2 <> *blanks
             and not(screlation = 'AND' or screlation = 'OR');
             CsrRowColDS =
             f_GetRowColumn('SCRELATION':InfdsFile:InfdsLib:InfdsRcdfmt);
             ASCRELAT = %bitor(White: RI);
             f_SndSflMsg(ProgId: 'And/Or must = AND or OR');
 1i          iter;
 2e       endif;
 
          // do not need relationship if factor2 = *blanks
 2b       if scval2 = *blanks;
             screlation = *blanks;
 2e       endif;
 
 2b       if not(savScVal1 = scval1
             and savScRelation = screlation
             and savScVal2 = scval2);
             exsr srReadDumpData;
 1i          iter;
 2e       endif;
 
          //---------------------------------------------------------
 2b       if (not Ind.sfldsp);  //no records
 1i          iter;
 2e       endif;
 
          //---------------------------------------------------------
          readc data1;
 2b       dow not %eof;
 
 3b          if sbfOption > ' ';
                SflRcdNbr = rrn1;
 4b             if sbfOption = 'X';
                   callp p_JCRSSQLE(SqlHid: KeysMsg);
 5b                if KeysMsg > *blanks;
                      f_SndSflMsg(ProgId: KeysMsg);
 5e                endif;
 4e             endif;
 
                clear sbfOption;
                aOptions = %bitor(Green:UL);
                update data1;
                aOptions = ND;
 3e          endif;
 
             readc data1;
 2e       enddo;
 1e    enddo;
       *inlr = *on;
       return;
       endsr;
 
       //---------------------------------------------------------
       // Read down to 1st StatementStart characters.  The problem is StatementStart
       // can be split across 2 two records in the input.
       // Read 1st record, load into ScanStart.  Load next record into ScanStart
       // Scan for StatementStart.
       // If NOT found, shift cur RawDumpData to begin of ScanStart and repeat.
       //---------------------------------------------------------
       begsr srReadDumpData;
       %len(InPrgVary) = 0;
       %len(LongString) = 0;
       %len(Sql) = 0;
       %len(Sql_and_Msg) = 0;
       %len(SqlWrk) = 0;
       RecordCnt = 8;
       PercentComp = 0;
       SqlMsg = *blanks;
       vdata = *blanks;
       SflRcdNbr = 1;
       IsStarted = *off;
       IsAllRead = *off;
       Ind.sfldsp = *off;
       Ind.sfldspctl = *off;
       rrn1 = 0;
       write contrl1;
 1b    if IsDoubleByte;
          chain 8 JCRSSQL DoubleByteChar;
 1x    else;
          chain 8 JCRSSQL SingleByteChar;
 1e    endif;
 
 1b    if DoubleByteChar.NotAuthorized = 'USER NOT AUTHORIZED'
          or SingleByteChar.NotAuthorized = 'USER NOT AUTHORIZED';
          vdata = 'USER NOT AUTHORIZED TO DUMP OBJECT';
          f_SndSflMsg(ProgId: 'USER NOT AUTHORIZED TO DUMP OBJECT');
          rrn1 += 1;
          write data1;
 1x    else;
 
          exsr srGetData;
 
          ScanStart = RawDumpData;
 
 2b       dou IsStarted;
 3b          if IsDoubleByte;
                read JCRSSQL DoubleByteChar;
 3x          else;
                read JCRSSQL SingleByteChar;
 3e          endif;
 
             exsr srGetData;
 
             exsr srInProgress;
 3b          if %eof;
 2v             leave;
 3e          endif;
 
             ScanStart = ScanStart + RawDumpData;
             sc = %scan(StatementStart: ScanStart);
             //---------------------------------------------------------
             // 'TH' and 10 blanks and an SQL keyword is
             // ONLY reliable way to determine start of sql statement
             // So if found 'TH        ' and is not followed by a
             // keyword, then set scan value to zero
             //---------------------------------------------------------
 3b          if sc > 0;
 4b             if (sc + 14 + 5) > %len(ScanStart);
                   sc = 0;
 4x             else;
                   SqlKeyWord = %subst(Scanstart: Sc + 14: 5);
                   SqlKeyWord = %xlate(lo: up: SqlKeyWord);
 5b                if not(SqlKeyWord = 'SELEC'
                      or SqlKeyWord = 'UPDAT'
                      or SqlKeyWord = 'DELET'
                      or SqlKeyWord = 'INSER'
                      or SqlKeyWord = 'CALL'
                      or SqlKeyWord = 'COMME'
                      or SqlKeyWord = 'COMMI'
                      or SqlKeyWord = 'CONNE'
                      or SqlKeyWord = 'CREAT'
                      or SqlKeyWord = 'DISCO'
                      or SqlKeyWord = 'DROP'
                      or SqlKeyWord = 'GRANT'
                      or SqlKeyWord = 'LABEL'
                      or SqlKeyWord = 'LOCK'
                      or SqlKeyWord = 'RENAM'
                      or SqlKeyWord = 'RELEA'
                      or SqlKeyWord = 'REVOK'
                      or SqlKeyWord = 'ROLLB'
                      or SqlKeyWord = 'ALTER'
                      or SqlKeyWord = 'SET C'
                      or SqlKeyWord = 'SET T');
                      sc = 0;
 5e                endif;
 4e             endif;
 3e          endif;
             //---------------------------------------------------------
 3b          if sc = 0;
                ScanStart = RawDumpData;
 3x          else;
                IsStarted = *on;
 3e          endif;
 2e       enddo;
 
          //---------------------------------------------------------
          // Load 1000 records into LongString
          //---------------------------------------------------------
 2b       if IsStarted;
             LongString = %subst(ScanStart: Sc);
 
     C     Next1000      tag
 
             xx = 0;
 3b          dou 1 = 2;
 4b             if IsDoubleByte;
                   read JCRSSQL DoubleByteChar;
 4x             else;
                   read JCRSSQL SingleByteChar;
 4e             endif;
 
                exsr srGetData;
 
                exsr srInProgress;
 4b             if %eof;
                   IsAllRead = *on;
 3v                leave;
 4e             endif;
 4b             if Asterisk = '*';
                   xx += 1;
                   LongString = LongString + RawDumpData;
 5b                if xx = 1000;
 3v                   leave;
 5e                endif;
 4e             endif;
 3e          enddo;
             //---------------------------------------------------------
             sc = 1;
 3b          dou nextsc = 0;
 4b             if %len(LongString) > (sc + 12 + 14);
                   wrksc = sc;
 
     C     NotTrueTH     tag
 
                   nextsc = %scan(StatementStart:
                   LongString: wrksc + 12);
                   //---------------------------------------------------------
                   // 'TH' and 10 blanks and an SQL keyword is the
                   // ONLY reliable way to determine start of sql statement
                   // So if found 'TH        ' and it is not followed by a
                   // keyword, then set the scan value to zero
                   //---------------------------------------------------------
 5b                if nextsc > 0
                      and (nextsc + 18) < %len(longString);
                      SqlKeyWord = %subst(LongString: nextsc + 14: 5);
                      SqlKeyWord = %xlate(lo: up: SqlKeyWord);
 6b                   if not(SqlKeyWord = 'SELEC'
                         or SqlKeyWord = 'UPDAT'
                         or SqlKeyWord = 'DELET'
                         or SqlKeyWord = 'INSER'
                         or SqlKeyWord = 'CALL'
                         or SqlKeyWord = 'COMME'
                         or SqlKeyWord = 'COMMI'
                         or SqlKeyWord = 'CONNE'
                         or SqlKeyWord = 'CREAT'
                         or SqlKeyWord = 'DISCO'
                         or SqlKeyWord = 'DROP'
                         or SqlKeyWord = 'GRANT'
                         or SqlKeyWord = 'LABEL'
                         or SqlKeyWord = 'LOCK'
                         or SqlKeyWord = 'RENAM'
                         or SqlKeyWord = 'RELEA'
                         or SqlKeyWord = 'REVOK'
                         or SqlKeyWord = 'ROLLB'
                         or SqlKeyWord = 'ALTER'
                         or SqlKeyWord = 'SET C'
                         or SqlKeyWord = 'SET T');
                         wrksc = nextsc - 10;
 
 GO  C                   goto      NotTrueTH
 
 6e                   endif;
 5e                endif;
 
                   //---------------------------------------------------------
                   // (LastStatement)
                   // If nextsc = 0 then there are no more begin statements in file,
                   // there is however the last statement to process.
                   // Looking at the dump output, it appears an 'A' followed by
                   // 69 spaces should be a safe event to monitor.
                   //---------------------------------------------------------
 5b                if nextsc = 0
                      and %len(LongString) > (sc + 12 + 69);
                      nextsc = %scan(LastStatement: LongString: Sc + 12);
 5e                endif;
 4x             else;
                   nextsc = 0;
 4e             endif;
 4b             if nextsc > 0;
                   SqlWrk = %subst(LongString: Sc + 12: +
                   ((nextsc - 1) - (sc + 12) + 1));
 
                   //---------------------------------------------------------
                   // All statements end in with SQLnnnn and a message.
                   // Only want to include the 1st sql message in our output.
                   //---------------------------------------------------------
                   TestLen = %len(SqlWrk);
 5b                for xm = 71 to TestLen  by 82;
 6b                   if %subst(SqlWrk: xm: 1) <> 'T';
 
 7b                      if TestLen > (xm + 14 + 68);
                            SqlMsg = %subst(SqlWrk: xm + 14: 68);
 7x                      else;
 8b                         if testlen <= xm + 14 + 1;
                               SqlMsg = *blanks;
 8x                         else;
                               SqlMsg = %subst(SqlWrk: xm + 14:
                               (TestLen - (xm + 14) + 1));
 8e                         endif;
 7e                      endif;
 
                         %len(SqlWrk) = xm - 1;
 5v                      leave;
 6e                   endif;
 5e                endfor;
 
                   xm = %scan('not': SqlMsg);
 5b                if xm = 0;
 
                      //---------------------------------------------------------
                      // Now that all messages are stripped out,
                      // reconstruct SQL statement.
                      //---------------------------------------------------------
                      TestLen = %len(SqlWrk); // Allow for shorter strings
 6b                   if TestLen > 70;
                         TestLen = 70;
 6e                   Endif;
 
                      Sql = (%subst(SqlWrk: 1:TestLen));
                      TestLen = %len(SqlWrk);
 
 6b                   for xm = 71 to TestLen  by 82;
 7b                      if %subst(SqlWrk: xm: 1) = 'T';
 
 8b                         if TestLen > (xm + 14 + 68);
                               Sql = Sql +
                               (%subst(SqlWrk: xm + 14: 68));
 8x                         else;
                               Sql = Sql +
                               (%subst(SqlWrk: xm + 14:
                               (TestLen - (xm + 14) + 1)));
 8e                         endif;
 7e                      endif;
 6e                   endfor;
 
                      // some common errors to filter
 6b                   if not(Sql = 'select'
                         or Sql = 'SELECT'
                         or Sql = 'delete'
                         or Sql = 'DELETE'
                         or Sql = 'strsql'
                         or Sql = 'UPDATE'
                         or Sql = 'update'
                         or Sql = 'wrksplf'
                         or Sql = *blanks
                         or %subst(SqlMsg: 1: 9) = 'Prompting'
                         or %subst(SqlMsg: 1: 22) = 'Session ended abnormal');
 
                         // determine if completion message is included
 7b                      if SqlMsg > *blanks
                            and SqlMsg <> 'SELECT statement run complete.';
                            Sql_and_Msg = Sql + ' ' + SqlMsg;
 7x                      else;
                            Sql_and_Msg = Sql;
 7e                      endif;
 
                         // upper case sql statement then apply scans
                         %len(UpperCased) = %len(Sql_and_Msg);
                         UpperCased = %xlate(lo: up: Sql_and_Msg);
 
 7b                      if (%scan(%trimr(ScVal1): UpperCased: 1) > 0
                            and (scRelation = *blanks
                            or scRelation = 'OR'))
                            OR
                            (scRelation = 'OR'
                            and %scan(%trimr(ScVal2): UpperCased: 1) > 0)
                            OR
                            (%scan(%trimr(ScVal1): UpperCased: 1) > 0 and
                            scRelation = 'AND'
                            and %scan(%trimr(ScVal2): UpperCased: 1) > 0);
                            exsr srWriteSubfile;
 7e                      endif;
 
 6e                   endif;
 5e                endif;
                   sc = nextsc;
 4e             endif;
 3e          enddo;
 
             // load left over and loop back
 3b          if IsAllRead = *off;
                LongString = %subst(LongString: Sc);
 GO  C                   goto      Next1000
 3e          endif;
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       begsr srGetData;
 1b    if IsDoubleByte;
          Asterisk = DoubleByteChar.Asterisk;
          RawDumpData = DoubleByteChar.DumpText;
 1x    else;
          Asterisk = SingleByteChar.Asterisk;
          RawDumpData = SingleByteChar.DumpText;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       begsr srInProgress;
       RecordCnt += 1;
 1b    if TwoPercent > 0 and
          %rem(RecordCnt: TwoPercent) = 0;
          InPrgVary = InPrgVary + '>';
          InProgressMsg = InPrgVary + ConstantPeriod;
          PercentComp += 2;
          // Send status message
          f_SndStatMsg(%char(PercentComp) + '% completed:  ' +
          InProgressMsg);
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       begsr srWriteSubfile;
 
 1b    if rrn1 < 1699;
          aOptions = %bitor(Green:UL);
          xx = 1;
          Sql = %triml(Sql);
          SqlHid = %triml(Sql);
 2b       if %len(Sql) > 0;
 3b          dou xx > %len(Sql);
                vdata = %subst(Sql: xx);
                rrn1 += 1;
                write data1;
                xx += %size(vdata);
                clear SqlHid;
                aOptions = ND;
 3e          enddo;
 2e       endif;
 
 2b       if SqlMsg > *blanks
             and SqlMsg <> 'SELECT statement run complete.';
             vdata = '       Msg: ' + SqlMsg;
             rrn1 += 1;
             write data1;
 2e       endif;
 
          clear vdata;
          rrn1 += 1;
          write data1;
 1x    else;
          f_SndSflMsg(ProgId: '100++ pages returned.  Narrow search.');
 GO  C                   goto      ShowFull
 1e    endif;
       endsr;
