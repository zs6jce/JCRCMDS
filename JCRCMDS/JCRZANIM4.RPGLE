       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRZANIM4 - Animation- classic I'm With Stupid pointing finger
       //---------------------------------------------------------
       /define ControlStatements
       /define Dspatr
       /define usleep
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRZANIM4D workstn;
 
       dcl-s cc uns(3);
       dcl-s col uns(3);
       dcl-s DoCount uns(3);
       dcl-s SpinCount uns(3);
       dcl-s aText char(11);
       dcl-s xx uns(3);
 
       dcl-ds ImageDS;
        *n char(11) inz('  XX       ');
        *n char(11) inz(' X  X      ');
        *n char(11) inz(' X  XXX    ');
        *n char(11) inz(' X  X X    ');
        *n char(11) inz(' X  X XXXX ');
        *n char(11) inz(' X  X X X X');
        *n char(11) inz('XX  X X X X');
        *n char(11) inz('X X   X X X');
        *n char(11) inz('X  X      X');
        *n char(11) inz('X         X');
        *n char(11) inz(' X       X ');
        *n char(11) inz('  X     X  ');
        *n char(11) inz('  XXXXXX   ');
        *n char(11) inz('  X    X   ');
         FingArry char(11) dim(14) pos(1);
       end-ds;
 
       dcl-ds GridRow dim(11) qualified based(ptr);
        col char(1) dim(48);
       end-ds;
       dcl-s Ptr pointer inz(%addr(LIN001));
 
       // map screen fields into DS so arrays can manipulate values
       dcl-ds *n;
        LIN001;
        LIN002;
        LIN003;
        LIN004;
        LIN005;
        LIN006;
        LIN007;
        LIN008;
        LIN009;
        LIN010;
        LIN011;
       end-ds;
 
       //---------------------------------------------------------
       im = 'I''M';
 1b    for xx = 1 to 48;
          col = xx;
          aText = FingArry(1);
          exsr srWriteScreen;
 
          SpinCount = 0;
 2b       for DoCount = 2 to xx;
             aText = FingArry(2);
             exsr srWriteScreen;
             SpinCount += 1;
 3b          if SpinCount = 19;
 2v             leave;
 3e          endif;
 2e       endfor;
 
 2b       if xx >= 21;
             aText = FingArry(3);
             exsr srWriteScreen;
 2e       endif;
 2b       if xx >= 22;
             aText = FingArry(4);
             exsr srWriteScreen;
 2e       endif;
 2b       if xx >= 23;
             aText = FingArry(5);
             exsr srWriteScreen;
 2e       endif;
 2b       if xx >= 24;
             aText = FingArry(6);
             exsr srWriteScreen;
 2e       endif;
 2b       if xx >= 25;
             aText = FingArry(6);
             exsr srWriteScreen;
 2e       endif;
 2b       if xx >= 26;
             aText = FingArry(6);
             exsr srWriteScreen;
 2e       endif;
 2b       if xx >= 27;
             aText = FingArry(6);
             exsr srWriteScreen;
 2e       endif;
 2b       if xx >= 28;
             aText = FingArry(6);
             exsr srWriteScreen;
 2e       endif;
 2b       if xx >= 29;
             aText = FingArry(7);
             exsr srWriteScreen;
 2e       endif;
 2b       if xx >= 30;
             aText = FingArry(8);
             exsr srWriteScreen;
 2e       endif;
 2b       if xx >= 31;
             aText = FingArry(9);
             exsr srWriteScreen;
 2e       endif;
 2b       if xx >= 32;
             aText = FingArry(10);
             exsr srWriteScreen;
 2e       endif;
 2b       if xx >= 33;
             aText = FingArry(10);
             exsr srWriteScreen;
 2e       endif;
 2b       if xx >= 34;
             aText = FingArry(11);
             exsr srWriteScreen;
 2e       endif;
 2b       if xx >= 35;
             aText = FingArry(11);
             exsr srWriteScreen;
 2e       endif;
 2b       if xx >= 36;
             aText = FingArry(12);
             exsr srWriteScreen;
 2e       endif;
 2b       if xx >= 37;
             aText = FingArry(12);
             exsr srWriteScreen;
 2e       endif;
 2b       if xx >= 38;
             aText = FingArry(13);
             exsr srWriteScreen;
 2e       endif;
 2b       if xx >= 39;
             aText = FingArry(13);
             exsr srWriteScreen;
 2e       endif;
 2b       if xx >= 40;
             aText = FingArry(14);
             exsr srWriteScreen;
 2e       endif;
 1e    endfor;
 
 1b    for cc = 1 to 10;
          atr01 = White;
          write screen;
          usleep(50000); // delay milliseconds
 
          atr01 = Red;
          write screen;
          usleep(50000);
 
          atr01 = Blue;
          write screen;
          usleep(50000);
 1e    endfor;
 
       exfmt screen;
       *inlr = *on;
 
       //---------------------------------------------------------
       // Translate the X and blanks in the text string
       // into Xs at the row,col of the screen array.
       // Example: '   X X '  and ColCount = 2
       //  the first X is in position 4, so grid.row(4).col(2) = 'X'
       //  second X is in position 6, so grid.row(5).col(2) = 'X'
       //  so I would have X
       //                  X  on the screen
       //---------------------------------------------------------
       begsr srWriteScreen;
 1b    for cc = 1 to 11;  // number of lines on screen
          GridRow(cc).Col(col) = %subst(aText:cc:1);
 1e    endfor;
       col -= 1;
       write screen;
       endsr;
