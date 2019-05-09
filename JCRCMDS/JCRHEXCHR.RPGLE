       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRHEXCHR - display biton codes to produce hex characters.
       //  decode integer counter into pseudo-binary bit for checking.
       //   use %bitor biff to set screen character bits.
       //    use C function _cvth to generate hex representations.
       //---------------------------------------------------------
       /define ControlStatements
       /define BitMask
       /define Cvthc
       /define f_GetDayName
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRHEXCHRD workstn sfile(sbfdta1: rrn);
 
       dcl-s rrn uns(3);
       dcl-s Base2Divisor uns(3);
       dcl-s BitOn uns(10);
       dcl-s Count uns(3);
       dcl-s CountWrk uns(3);
 
       //---------------------------------------------------------
       rrn = 0;
       scDow = f_GetDayName();
 
 1b    for Count = 65 to 254;
          scBinVal = x'00';
          scBitOn = *blanks;
          CountWrk = Count;
          Base2Divisor = 128;
 
          //---------------------------------------------------------
 2b       for BitOn = 0 to 7;
 3b          if %uns(CountWrk/Base2Divisor) = 1;  //binary bit on
 
 4b             if BitOn = 0;
                   scBinVal = %bitor(bit0: scBinVal);
 4x             elseif BitOn = 1;
                   scBinVal = %bitor(bit1: scBinVal);
 4x             elseif BitOn = 2;
                   scBinVal = %bitor(bit2: scBinVal);
 4x             elseif BitOn = 3;
                   scBinVal = %bitor(bit3: scBinVal);
 4x             elseif BitOn = 4;
                   scBinVal = %bitor(bit4: scBinVal);
 4x             elseif BitOn = 5;
                   scBinVal = %bitor(bit5: scBinVal);
 4x             elseif BitOn = 6;
                   scBinVal = %bitor(bit6: scBinVal);
 4x             elseif BitOn = 7;
                   scBinVal = %bitor(bit7: scBinVal);
 4e             endif;
 
                scBitOn = %trimr(scBitOn) + %char(BitOn);
                CountWrk -= Base2Divisor;  //step to next binary
 4b             if CountWrk = 0;  //completely decoded
 2v                leave;
 4e             endif;
 3e          endif;
             Base2Divisor /= 2;
 2e       endfor;
 
          //---------------------------------------------------------
          cvthc(%addr(scHexCode): %addr(scBinVal): 2);  //make hex
 
          rrn += 1;
          write sbfdta1;
 1e    endfor;
 
       write sbfctl1;
       exfmt sfooter1;
       *inlr = *on;
       return;
