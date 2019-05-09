       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //----------------------------------------------------------
       // JCRZANIM0 - display binary clock
       // Array naming is there are 3 lines of characters on screen. BitPlace correspond to bit
       // place holders 6 to 1 with 1 being ones place.  Rows are number of rows that make up
       // each character
       // Fun to watch for about two minutes.
       //  uses a dataq to monitor if command key was pressed as there is no display file read
       //----------------------------------------------------------
       /define ControlStatements
       /define f_GetDayName
       /define usleep
       /define f_RunCmd
       /define ApiErrDS
       /define FunctionKeys
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRZANIM0D workstn infds(infds) usropn;
       dcl-ds Infds;
        InfdsFkey char(1) pos(369);
       end-ds;
 
       dcl-s PreviousSecond uns(3);
       dcl-s CurrTime time inz;
       dcl-s BitPlace uns(3);
       dcl-s dtaqEntry char(80);
 
       // binary clock face 3d array
       dcl-ds HmsLine dim(3) qualified based(DspPtr);
        BitPlace likeds(BitPlacex) dim(6);
       end-ds;
 
       dcl-ds BitPlacex qualified;
        row char(9) dim(5);
       end-ds;
       dcl-s DspPtr pointer inz(%addr(DspDs));
 
       dcl-ds HmsAtr dim(3) qualified based(AtrPtr);
        BitPlace char(1) dim(6);
       end-ds;
       dcl-s AtrPtr pointer inz(%addr(AtrDs));
 
       dcl-ds DspDS;
        Grid16Row1;
        Grid16Row2;
        Grid16Row3;
        Grid16Row4;
        Grid16Row5;
        Grid15Row1;
        Grid15Row2;
        Grid15Row3;
        Grid15Row4;
        Grid15Row5;
        Grid14Row1;
        Grid14Row2;
        Grid14Row3;
        Grid14Row4;
        Grid14Row5;
        Grid13Row1;
        Grid13Row2;
        Grid13Row3;
        Grid13Row4;
        Grid13Row5;
        Grid12Row1;
        Grid12Row2;
        Grid12Row3;
        Grid12Row4;
        Grid12Row5;
        Grid11Row1;
        Grid11Row2;
        Grid11Row3;
        Grid11Row4;
        Grid11Row5;
        Grid26Row1;
        Grid26Row2;
        Grid26Row3;
        Grid26Row4;
        Grid26Row5;
        Grid25Row1;
        Grid25Row2;
        Grid25Row3;
        Grid25Row4;
        Grid25Row5;
        Grid24Row1;
        Grid24Row2;
        Grid24Row3;
        Grid24Row4;
        Grid24Row5;
        Grid23Row1;
        Grid23Row2;
        Grid23Row3;
        Grid23Row4;
        Grid23Row5;
        Grid22Row1;
        Grid22Row2;
        Grid22Row3;
        Grid22Row4;
        Grid22Row5;
        Grid21Row1;
        Grid21Row2;
        Grid21Row3;
        Grid21Row4;
        Grid21Row5;
        Grid36Row1;
        Grid36Row2;
        Grid36Row3;
        Grid36Row4;
        Grid36Row5;
        Grid35Row1;
        Grid35Row2;
        Grid35Row3;
        Grid35Row4;
        Grid35Row5;
        Grid34Row1;
        Grid34Row2;
        Grid34Row3;
        Grid34Row4;
        Grid34Row5;
        Grid33Row1;
        Grid33Row2;
        Grid33Row3;
        Grid33Row4;
        Grid33Row5;
        Grid32Row1;
        Grid32Row2;
        Grid32Row3;
        Grid32Row4;
        Grid32Row5;
        Grid31Row1;
        Grid31Row2;
        Grid31Row3;
        Grid31Row4;
        Grid31Row5;
       end-ds;
 
       dcl-ds ATRDS;
        atr16;
        atr15;
        atr14;
        atr13;
        atr12;
        atr11;
        atr26;
        atr25;
        atr24;
        atr23;
        atr22;
        atr21;
        atr36;
        atr35;
        atr34;
        atr33;
        atr32;
        atr31;
       end-ds;
 
       dcl-pr qclrdtaq extpgm('QCLRDTAQ'); // Clear Data Queue
        *n char(10) const; // Name
        *n char(10) const; // Library
       end-pr;
 
       dcl-pr qrcvdtaq extpgm('QRCVDTAQ'); // Receive Dtaq Entry
        *n char(10) const; // Name
        *n char(10) const; // Library
        *n packed(5) const; // Length of Data
        *n char(80); // Data
        *n packed(5) const; // Wait Time
       end-pr;
       //---------------------------------------------------------
       scDow = f_GetDayName();
       f_RunCmd('CRTDTAQ DTAQ(QTEMP/JCRZANIM0) ' +
       'MAXLEN(80) SEQ(*FIFO)');
 1b    if ApiErrDS.BytesReturned > 0;
          callp QCLRDTAQ('JCRZANIM0 ':'QTEMP');
 1e    endif;
 
       f_RunCmd('OVRDSPF FILE(JCRZANIM0D) DTAQ(QTEMP/JCRZANIM0) +
       OVRSCOPE(*JOB)');
       open JCRZANIM0D;
 
 1b    dou 1 = 2;
 2b       dou not(eSecond = PreviousSecond);
             usleep(50000);  // check every half second
             CurrTime = %time();
             eSecond = %subdt(CurrTime:*S);
 2e       enddo;
 
          PreviousSecond = eSecond;
          f_FillGrid(3:eSecond);
 
          eMinute = %subdt(CurrTime:*MN);
          f_FillGrid(2:eMinute);
 
          eHour = %subdt(CurrTime:*H);
          f_FillGrid(1:eHour);
 
          //-------------------------------------------------------
          // read data queue to see if dspf is signaling f3 or f12
          callp qrcvdtaq(
                'JCRZANIM0':
                'QTEMP':
                80:
                dtaqEntry:
                0);
 
 2b       if %subst(dtaqEntry:1:5) = '*DSPF';
             read JCRZANIM0D;
 3b          if InfdsFkey = f03 or InfdsFkey = f12;
 1v             leave;
 3e          endif;
 2e       endif;
          //-------------------------------------------------------
 
          write clockd;
 1e    enddo;
 
       close JCRZANIM0D;
       f_RunCmd('DLTOVR FILE(JCRZANIM0D LVL(*JOB)');
       *inlr = *on;
 
       //---------------------------------------------------------
       // Load characters and attributes for binary values
       // As first 0 is set to 1, every thing before that position = 0
       //  works slick.
       //---------------------------------------------------------
       dcl-proc f_FillGrid;
        dcl-pi *n;
         pLine uns(3) const;
         pValue packed(2);
        end-pi;
 
        dcl-s binary uns(3) inz dim(6);
        dcl-s xx uns(3);
        dcl-s yy uns(3);
        dcl-s zz uns(3);
        dcl-c White const(x'22');
        dcl-c Pink const(x'38');
 
        binary(*) = 0;
 1b     for xx = 1 to pValue;
           yy = %lookup(0:binary);
           binary(yy) = 1;
 2b        for zz = 1 to (yy-1);
              binary(zz) = 0;
 2e        endfor;
 1e     endfor;
 
 1b     for BitPlace = 6 downto 1;
 2b        if binary(BitPlace) = 1;
              HmsAtr(pLine).BitPlace(BitPlace) = Pink;
              HmsLine(pLine).BitPlace(BitPlace).Row(*) = '   111';
              HmsLine(pLine).BitPlace(BitPlace).Row(1) = '  1111';
              HmsLine(pLine).BitPlace(BitPlace).Row(5) = ' 1111111';
 2x        else;
              HmsAtr(pLine).BitPlace(BitPlace) = White;
              HmsLine(pLine).BitPlace(BitPlace).Row(1) = '  00000';
              HmsLine(pLine).BitPlace(BitPlace).Row(2) = ' 00   00';
              HmsLine(pLine).BitPlace(BitPlace).Row(3) = '00     00';
              HmsLine(pLine).BitPlace(BitPlace).Row(4) = ' 00   00';
              HmsLine(pLine).BitPlace(BitPlace).Row(5) = '  00000';
 2e        endif;
 1e     endfor;
       end-proc;
