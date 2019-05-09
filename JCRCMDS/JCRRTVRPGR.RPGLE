       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRRTVRPGR - Retrieve RPGLE source from compiled object
       // The DMPOBJ command only works for programs compiled *LIST or *ALL!!
 
       // Weird: if retrieving fixed format program (not free) and program has F specs.
       // The DMPOBJ will not retrieve first C spec and may have to delete last line in
       // generated code.
 
       // Due to this utility using object dump file, it is OS version
       // sensitive. Meaning IBM has been known to change format of dumps on different release
       // levels. This version works for programs compiled v5r1 to v7r2.
       //---------------------------------------------------------
       /define ControlStatements
       /define f_Quscrtus
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRRTVRPG disk(132);
       dcl-ds inputDS len(132);
        Asterisk char(1) pos(87);
        DumpText char(32) pos(88);
       end-ds;
 
       dcl-f RPGSRC disk(112) usage(*output);
       dcl-ds OutDS;
        SrcSeq zoned(6:2) pos(1) inz(0);
        SrcChgdat zoned(6:0) pos(7) inz(0);
        OutData char(95) pos(18);
       end-ds;
 
       //---------------------------------------------------------
       dcl-s BasedField like(dumptext) based(xPtr);
       dcl-s BasedField2 like(StartText) based(xPtr);
       dcl-s BasedSrc char(95) based(xPtr);
       dcl-s Check1st6 char(6) based(Ptr1);
       dcl-s Check2nd5 char(5) based(Ptr2);
       dcl-s Check3rd6 char(6) based(Ptr3);
       dcl-s StartText char(5) INZ('DBGV-');
       dcl-s ScanCount uns(10);
       dcl-s SizeOfSpace uns(10);
       dcl-s xCount uns(3);
       dcl-s StartOfUserSpacePtr pointer inz(*null);
       dcl-s IsFound ind;
 
       //---------------------------------------------------------
       // Create user space
       StartOfUserSpacePtr = f_Quscrtus(UserSpaceName);
 
       // Load blocks of dump data into user space so entire dump is in single long string
       xPtr = StartOfUserSpacePtr;
       read JCRRTVRPG inputDS;
 1b    dow not %eof;
 2b       if Asterisk = '*';
             BasedField = DumpText;
             xPtr += %len(DumpText);
             SizeOfSpace += %len(DumpText);
 2e       endif;
          read JCRRTVRPG inputDS;
 1e    enddo;
 
       //---------------------------------------------------------
       // Find source start
       //---------------------------------------------------------
       ScanCount = 1;
       IsFound = *off;
       xPtr = StartOfUserSpacePtr;
 1b    dou ScanCount > SizeOfSpace;
 2b       if BasedField2 = StartText;
             IsFound = *on;
 1v          leave;
 2e       endif;
          xPtr += 1;
          ScanCount += 1;
 1e    enddo;
 
       // Start writing records to source member
 1b    if IsFound;
          xPtr += 47;
          ScanCount += 47;
 
 2b       dou ScanCount > SizeOfSpace;
             OutData = BasedSrc;
             //---------------------------------------------------------
             // For inexplicable reasons, some records
             // are 'shorter than others and data from
             // following record could at end of
             // current records buffer.
             // This rather complex section determines if
             // condition exists and clears following records data from buffer.
             //---------------------------------------------------------
             IsFound = *off;
             Ptr1 = %addr(OutData) + 1;
             xCount = 1;
 
 3b          Dou xCount > %len(OutData) - 16;
                xCount += 1;
                Ptr1 += 1;
                Ptr2 = Ptr1 + 6;
                Ptr3 = Ptr1 + 11;
 
 4b             if %check('0123456789': check1st6: 1) = 0
                   and %check(' ': check2nd5: 1) = 0
                   and %check('0123456789': check3rd6: 1) = 0;
                   IsFound = *on;
 3v                leave;
 4e             endif;
 3e          enddo;
 3b          if IsFound;
                OutData = %subst(OutData: 1: xCount - 1);
 3e          endif;
 
             //---------------------------------------------------------
             // Another interesting Quirk, if code be retrieved
             // is old - style and still uses resulting
             // indicators, dump will put '--'
             // if there are 'empty' indicators. like so,
             //  10----
             //  - - 10--
             //  --- - 10
             // Remove -- before writing code.
             //---------------------------------------------------------
 3b          if %subst(OutData: 65: 1) = ' ';
 4b             if %subst(OutData: 66: 2) = '--';
                   %subst(OutData: 66: 2) = *blanks;
 4e             endif;
 4b             if %subst(OutData: 68: 2) = '--';
                   %subst(OutData: 68: 2) = *blanks;
 4e             endif;
 4b             if %subst(OutData: 70: 2) = '--';
                   %subst(OutData: 70: 2) = *blanks;
 4e             endif;
 3e          endif;
 
 3b          if not(%subst(OutData: 1: 19) = 'MAIN PROCEDURE EXIT');
                SrcSeq += .01;
                SrcChgdat = 0;
                write RPGSRC outDS;
 3e          endif;
 
             xPtr += 30;
             ScanCount += 30;
 
             //---------------------------------------------------------
             // After 1st source record, everything is random
             // located.  Only true indication of source record
             // beginning is location of date and sequence numbers.
             // Spin until finding 6 digits, 5 spaces, then 6 more digits.
             // At this point it is a constant value over to  start of source line.
             //---------------------------------------------------------
 3b          Dou %check('0123456789': check1st6: 1) = 0
                and %check(' ': check2nd5: 1) = 0
                and %check('0123456789': check3rd6: 1) = 0
                or ScanCount > SizeOfSpace;
                xPtr += 1;
                ScanCount += 1;
                Ptr1 = xPtr;
                Ptr2 = Ptr1 + 6;
                Ptr3 = Ptr1 + 11;
 3e          enddo;
             xPtr += 30;
             ScanCount += 30;
 2e       enddo;
 1e    endif;
 
       *inlr = *on;
       return;
