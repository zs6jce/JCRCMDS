       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRHEXR - hex to decimal to hex convertor
       //
       // The TCP/IP security exit program documentation shows
       // the hex values X'1803 etc.. for the various functions. Nice, as
       // as the exit program parameters are int(10) numbers.
       //
       // This program helps you translate the hex documentation to actual numbers.
       //---------------------------------------------------------
       /define ControlStatements
       /define f_GetDayName
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRHEXD workstn;
 
       dcl-s new uns(10);
       dcl-s work uns(10);
       dcl-s xx uns(3);
       dcl-s ss uns(3);
       dcl-s yy uns(10);
       dcl-s NextHex char(16) inz('123456789ABCDEF');
 
       //---------------------------------------------------------
       scDow = f_GetDayName();
 
 1b    dou 1 = 2;
          exfmt screen;
 2b       if *inkc or *inkl;
             *inlr = *on;
             return;
 2e       endif;
          message = *blanks;
 
 2b       if sdec > 0;
             work = sdec;
             shex = '00000';
             ss = 0;
 
 3b          for xx = 5 downto 1 by 1;
                yy = 16**(xx-1);
                ss += 1;
                new = %int(work / yy);
 4b             if new > 0;
                   %subst(shex:ss:1) = %subst(NextHex:new:1);
                   work -= (yy * new);
 4e             endif;
 3e          endfor;
 
             //-------------------------------------------------
 2x       elseif shex > *blanks;
             shex = %scanrpl(' ':'0':shex);
 3b          if %check('0'+NextHex:shex) > 0;
                message = 'Invalid Hex Character';
 1i             iter;
 3e          endif;
 
             work = 0;
             ss = 0;
 
 3b          for xx = 5 downto 1 by 1;
                yy = 16**(xx-1);
                ss += 1;
 
 4b             if not(%subst(shex:ss:1) = '0');
                   new = %scan(%subst(shex:ss:1):NextHex);
                   work += new * yy;
 4e             endif;
 3e          endfor;
             message = %triml(%editc(work:'1'));
 
 2e       endif;
 1e    enddo;
