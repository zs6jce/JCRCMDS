       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRGMTIC - TicTacToe
       //---------------------------------------------------------
       /define ControlStatements
       /define Dspatr
       /define FunctionKeys
       /define f_GetRandom
       /define f_GetDayName
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRGMTICD workstn infds(infds);
       dcl-ds Infds;
        InfdsFkey char(1) pos(369);
       end-ds;
 
       dcl-s CheckXO char(1);
       dcl-s row uns(3);
       dcl-s col uns(3);
       dcl-s IsFirstMove ind;
       dcl-s IsPlaced ind;
       dcl-s IsWinner ind;
 
       // control attributes of selection field  two-dim array
       dcl-ds ProtectA dim(3) qualified based(ProtectPtr);
        col char(1) dim(3);
       end-ds;
       dcl-s ProtectPtr pointer inz(%addr(ProtectDS));
 
       // selection grid two-dim array
       dcl-ds Choice dim(3) likeds(ProtectA) based(SelPtr);
       dcl-s SelPtr pointer inz(%addr(SelectionDS));
 
       // map screen fields into DS
       dcl-ds SelectionDS inz;
        Row1 char(3);
        r1c1 overlay(Row1:1);
        r1c2 overlay(Row1:2);
        r1c3 overlay(Row1:3);
        Row2 char(3);
        r2c1 overlay(Row2:1);
        r2c2 overlay(Row2:2);
        r2c3 overlay(Row2:3);
        Row3 char(3);
        r3c1 overlay(Row3:1);
        r3c2 overlay(Row3:2);
        r3c3 overlay(Row3:3);
       end-ds;
 
       dcl-ds ProtectDS;
        ProcAtr11;
        ProcAtr12;
        ProcAtr13;
        ProcAtr21;
        ProcAtr22;
        ProcAtr23;
        ProcAtr31;
        ProcAtr32;
        ProcAtr33;
       end-ds;
 
       dcl-ds DspDS;
        Grid11Row1;
        Grid11Row2;
        Grid11Row3;
        Grid11Row4;
        Grid11Row5;
        Grid12Row1;
        Grid12Row2;
        Grid12Row3;
        Grid12Row4;
        Grid12Row5;
        Grid13Row1;
        Grid13Row2;
        Grid13Row3;
        Grid13Row4;
        Grid13Row5;
        Grid21Row1;
        Grid21Row2;
        Grid21Row3;
        Grid21Row4;
        Grid21Row5;
        Grid22Row1;
        Grid22Row2;
        Grid22Row3;
        Grid22Row4;
        Grid22Row5;
        Grid23Row1;
        Grid23Row2;
        Grid23Row3;
        Grid23Row4;
        Grid23Row5;
        Grid31Row1;
        Grid31Row2;
        Grid31Row3;
        Grid31Row4;
        Grid31Row5;
        Grid32Row1;
        Grid32Row2;
        Grid32Row3;
        Grid32Row4;
        Grid32Row5;
        Grid33Row1;
        Grid33Row2;
        Grid33Row3;
        Grid33Row4;
        Grid33Row5;
       end-ds;
 
       dcl-ds ATRDS;
        atr11;
        atr12;
        atr13;
        atr21;
        atr22;
        atr23;
        atr31;
        atr32;
        atr33;
       end-ds;
 
       // row, column, then 5 lines three-dim array
       dcl-ds DspRow dim(3) qualified based(DspPtr);
        DspCol likeds(DspColx) dim(3);
       end-ds;
       dcl-ds DspColx qualified;
        DspLine char(9) dim(5);
       end-ds;
       dcl-s DspPtr pointer inz(%addr(DspDs));
 
       dcl-ds AtrRow dim(3) qualified based(AtrPtr);
        AtrCol char(1) dim(3);
       end-ds;
       dcl-s AtrPtr pointer inz(%addr(AtrDs));
 
       //---------------------------------------------------------
       scDow = f_GetDayName();
 
       // Load TIC TAC TOE in variety of colors to starting screen
       DspRow(1).DspCol(1).DspLine(*) = f_FillGrid('T');
       DspRow(1).DspCol(2).DspLine(*) = f_FillGrid('I');
       DspRow(1).DspCol(3).DspLine(*) = f_FillGrid('C');
       DspRow(2).DspCol(1).DspLine(*) = f_FillGrid('T');
       DspRow(2).DspCol(2).DspLine(*) = f_FillGrid('A');
       DspRow(2).DspCol(3).DspLine(*) = f_FillGrid('C');
       DspRow(3).DspCol(1).DspLine(*) = f_FillGrid('T');
       DspRow(3).DspCol(2).DspLine(*) = f_FillGrid('O');
       DspRow(3).DspCol(3).DspLine(*) = f_FillGrid('E');
       AtrRow(1).AtrCol(1) = Yellow;
       AtrRow(1).AtrCol(2) = White;
       AtrRow(1).AtrCol(3) = Red;
       AtrRow(2).AtrCol(1) = Turq;
       AtrRow(2).AtrCol(2) = Green;
       AtrRow(2).AtrCol(3) = Pink;
       AtrRow(3).AtrCol(1) = White;
       AtrRow(3).AtrCol(2) = Red;
       AtrRow(3).AtrCol(3) = Blue;
 1b    for row = 1 to 3;
          ProtectA(row).Col(*) = %bitor(ND: PR);
 1e    endfor;
       aWelcome = White;  // welcome message
       aStart = ND;    // game start message
       aNotes = ND;    // Game note
 
       exfmt screen;
 1b    if InfdsFkey = f03 or InfdsFkey = f12;
          *inlr = *on;
          return;
 1e    endif;
 
       DspRow(*) = *blanks;
       AtrRow(*) = *blanks;
 1b    for row = 1 to 3;
          ProtectA(row).Col(*) = %bitor(Green: UL);
 1e    endfor;
       aWelcome = ND;
       aStart = Pink;
       aNotes = Blue;
 
       //---------------------------------------------------------
 1b    dou 1 = 2;
          exfmt screen;
 2b       if InfdsFkey = f03 or InfdsFkey = f12;
             *inlr = *on;
             return;
 2e       endif;
 
 2b       if InfdsFkey = f05;
             Choice(*) = *blanks;
             DspRow(*) = *blanks;
             AtrRow(*) = *blanks;
             IsWinner = *off;
             IsFirstMove = *off;
             exsr srLoadCharacter;
 3b          for row = 1 to 3;
                ProtectA(row).Col(*) = %bitor(Green: UL);
 3e          endfor;
             aStart = Pink;
             aNotes = ND;
 1i          iter;
 2e       endif;
          aStart = ND;
          aNotes = ND;
 
          //---------------------------------------------------------
          // If first move and center square not X, load O to center square.
          //  If center square is X, load random O.
          //---------------------------------------------------------
 2b       if not IsFirstMove;
 3b          if Choice(2).Col(2) = ' ';
                Choice(2).Col(2) = 'O';
 3x          else;
 4b             dou not(row = 2 and col = 2);  //not in center
                   row = f_GetRandom(3);
                   col = f_GetRandom(3);
 4e             enddo;
 
                Choice(row).Col(col) = 'O';
 3e          endif;
             IsFirstMove = *on;
             exsr srLoadCharacter;
 2x       else;
             // See if X won
             exsr srLoadCharacter;
             exsr srCheckWinner;
 3b          if IsWinner;
 1i             iter;
 3e          endif;
 
             //---------------------------------------------------------
             // See if any single O will block X from win or if single O will win
             //---------------------------------------------------------
             exsr srBlockOrWin;  //Block that win!
             exsr srLoadCharacter;
             exsr srCheckWinner;
 3b          if IsWinner;
 1i             iter;
 3e          endif;
 
             // If no Block or Win assignment was made, then some strategy comes into play
 3b          if not IsPlaced;
                exsr srStrategy;
 
                //---------------------------------------------------------
                // If no available spaces for a strategy move, ie game is a tie and
                // there are only few spaces left, then use first available space.
                //---------------------------------------------------------
 4b             if not IsPlaced;
                   exsr srFirstOpen;
 4e             endif;
 
                exsr srLoadCharacter;
 3e          endif;
 2e       endif;
 1e    enddo;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srFirstOpen;
 1b    for Row = 1 to 3;
 2b       for Col = 1 to 3;
 3b          if Choice(row).Col(col) = ' ';
                Choice(row).Col(col) = 'O';
 LV             leavesr;
 3e          endif;
 2e       endfor;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // Protect selections from change
       //---------------------------------------------------------
       begsr srLoadCharacter;
 1b    for row = 1 to 3;
 2b       for col = 1 to 3;
 3b          if Choice(row).Col(col) = 'X';
                DspRow(row).DspCol(col).DspLine(*) = f_FillGrid('X');
                AtrRow(row).AtrCol(col) = Pink;
                ProtectA(row).Col(col) = %bitor(ND: PR);
 3x          elseif Choice(row).Col(col) = 'O';
                DspRow(row).DspCol(col).DspLine(*) = f_FillGrid('O');
                AtrRow(row).AtrCol(col) = White;
                ProtectA(row).Col(col) = %bitor(ND: PR);
 3e          endif;
 2e       endfor;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // Good for Offense or Defense!   First spin through all 24 possible
       // places that a single O could win game. If not a clear game winner
       // then make sure to block any scenarios where single X could win game.
       //---------------------------------------------------------
       begsr srBlockOrWin;
 1b    for col = 1 to 2;
 2b       if col = 1;
             CheckXO = 'O';
 2x       else;
             CheckXO = 'X';
 2e       endif;
 
          IsPlaced = *off;
 2b       for row = 1 to 3;
             // Row123----------------------------------------
 3b          if Choice(row).Col(1) = CheckXO and
                Choice(row).Col(1) =
                Choice(row).Col(2) and    // XX_  or OO_
                Choice(row).Col(3) = ' ';
                Choice(row).Col(3) = 'O';
                IsPlaced = *on;
 3x          elseif Choice(row).Col(1) = CheckXO and
                Choice(row).Col(1) =
                Choice(row).Col(3) and    // X_X  or O_O
                Choice(row).Col(2) = ' ';
                Choice(row).Col(2) = 'O';
                IsPlaced = *on;
 3x          elseif Choice(row).Col(2) = CheckXO and
                Choice(row).Col(2) =
                Choice(row).Col(3) and    // _XX  or _OO
                Choice(row).Col(1) = ' ';
                Choice(row).Col(1) = 'O';
                IsPlaced = *on;
                // col123---------------------------------------
 3x          elseif Choice(1).Col(row) = CheckXO  and
                Choice(1).Col(row) =
                Choice(2).Col(row) and    // XX_  or OO_
                Choice(3).Col(row) = ' ';
                Choice(3).Col(row) = 'O';
                IsPlaced = *on;
 3x          elseif Choice(1).Col(row) = CheckXO and
                Choice(1).Col(row) =
                Choice(3).Col(row) and    // X_X  or O_O
                Choice(2).Col(row) = ' ';
                Choice(2).Col(row) = 'O';
                IsPlaced = *on;
 3x          elseif Choice(2).Col(row) = CheckXO and
                Choice(2).Col(row) =
                Choice(3).Col(row) and    // _XX  or _OO
                Choice(1).Col(row) = ' ';
                Choice(1).Col(row) = 'O';
                IsPlaced = *on;
 3e          endif;
 3b          if IsPlaced;
 2v             leave;
 3e          endif;
 2e       endfor;
 
 2b       if not IsPlaced;
             // DIAGR  1,1   2,2   3,3 -----------------------
 3b          if Choice(1).Col(1) = CheckXO  and
                Choice(1).Col(1) =
                Choice(2).Col(2) and      // XX_  or OO_
                Choice(3).Col(3) = ' ';
                Choice(3).Col(3) = 'O';
                IsPlaced = *on;
 3x          elseif Choice(2).Col(2) = ' ' and
                Choice(1).Col(1) =
                Choice(3).Col(3) and
                Choice(1).Col(1) = CheckXO;
                Choice(2).Col(2) = 'O';
                IsPlaced = *on;
 3x          elseif Choice(1).Col(1) = ' ' and
                Choice(2).Col(2) =
                Choice(3).Col(3) and
                Choice(2).Col(2) = CheckXO;
                Choice(1).Col(1) = 'O';
                IsPlaced = *on;
                // DIAGL  1,3   2,2   3,1 ---------------------
 3x          elseif Choice(1).Col(3) = CheckXO and
                Choice(1).Col(3) =
                Choice(2).Col(2) and      // XX_  or OO_
                Choice(3).Col(1) = ' ';
                Choice(3).Col(1) = 'O';
                IsPlaced = *on;
 3x          elseif Choice(2).Col(2) = ' ' and
                Choice(1).Col(3) =
                Choice(3).Col(1) and
                Choice(1).Col(3) = CheckXO;
                Choice(2).Col(2) = 'O';
                IsPlaced = *on;
 3x          elseif Choice(1).Col(3) = ' ' and
                Choice(2).Col(2) =
                Choice(3).Col(1) and
                Choice(2).Col(2) = CheckXO;
                Choice(1).Col(3) = 'O';
                IsPlaced = *on;
 3e          endif;
 2e       endif;
 
 2b       if IsPlaced;
 1v          leave;
 2e       endif;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // See if someone WON!
       // Process Rows 1 , 2 and 3 first.
       // then check columns 1, 2 and 3
       // then check left diagonal then right diagonal
       //---------------------------------------------------------
       begsr srCheckWinner;
       IsWinner = *off;
       // Rows-----------------------------------
 1b    if Row1 = 'XXX' or Row1 = 'OOO';
          IsWinner = *on;
          AtrRow(1).AtrCol(1) = %bitor(AtrRow(1).AtrCol(1):RI);
          AtrRow(1).AtrCol(2) = %bitor(AtrRow(1).AtrCol(1):RI);
          AtrRow(1).AtrCol(3) = %bitor(AtrRow(1).AtrCol(1):RI);
 1x    elseif Row2 = 'XXX' or Row2 = 'OOO';
          IsWinner = *on;
          AtrRow(2).AtrCol(1) = %bitor(AtrRow(2).AtrCol(1):RI);
          AtrRow(2).AtrCol(2) = %bitor(AtrRow(2).AtrCol(1):RI);
          AtrRow(2).AtrCol(3) = %bitor(AtrRow(2).AtrCol(1):RI);
 1x    elseif Row3 = 'XXX' or Row3 = 'OOO';
          IsWinner = *on;
          AtrRow(3).AtrCol(1) = %bitor(AtrRow(3).AtrCol(1):RI);
          AtrRow(3).AtrCol(2) = %bitor(AtrRow(3).AtrCol(1):RI);
          AtrRow(3).AtrCol(3) = %bitor(AtrRow(3).AtrCol(1):RI);
          // Columns-----------------------------------
 1x    elseif Choice(1).Col(1) > ' ' and
          Choice(1).Col(1) = Choice(2).Col(1) and
          Choice(2).Col(1) = Choice(3).Col(1);
          IsWinner = *on;
          AtrRow(1).AtrCol(1) = %bitor(AtrRow(1).AtrCol(1):RI);
          AtrRow(2).AtrCol(1) = %bitor(AtrRow(1).AtrCol(1):RI);
          AtrRow(3).AtrCol(1) = %bitor(AtrRow(1).AtrCol(1):RI);
 1x    elseif Choice(1).Col(2) > ' ' and
          Choice(1).Col(2) = Choice(2).Col(2) and
          Choice(2).Col(2) = Choice(3).Col(2);
          IsWinner = *on;
          AtrRow(1).AtrCol(2) = %bitor(AtrRow(1).AtrCol(2):RI);
          AtrRow(2).AtrCol(2) = %bitor(AtrRow(1).AtrCol(2):RI);
          AtrRow(3).AtrCol(2) = %bitor(AtrRow(1).AtrCol(2):RI);
 1x    elseif Choice(1).Col(3) > ' ' and
          Choice(1).Col(3) = Choice(2).Col(3) and
          Choice(1).Col(3) = Choice(3).Col(3);
          IsWinner = *on;
          AtrRow(1).AtrCol(3) = %bitor(AtrRow(1).AtrCol(3):RI);
          AtrRow(2).AtrCol(3) = %bitor(AtrRow(1).AtrCol(3):RI);
          AtrRow(3).AtrCol(3) = %bitor(AtrRow(1).AtrCol(3):RI);
          // Right Diagonal----------------------------------
 1x    elseif Choice(1).Col(1) > ' ' and
          Choice(1).Col(1) = Choice(2).Col(2) and
          Choice(1).Col(1) = Choice(3).Col(3);
          IsWinner = *on;
          AtrRow(1).AtrCol(1) = %bitor(AtrRow(1).AtrCol(1):RI);
          AtrRow(2).AtrCol(2) = %bitor(AtrRow(1).AtrCol(1):RI);
          AtrRow(3).AtrCol(3) = %bitor(AtrRow(1).AtrCol(1):RI);
          // Left Diagonal-----------------------------------
 1x    elseif Choice(1).Col(3) > ' ' and
          Choice(1).Col(3) = Choice(2).Col(2) and
          Choice(1).Col(3) = Choice(3).Col(1);
          IsWinner = *on;
          AtrRow(1).AtrCol(3) = %bitor(AtrRow(1).AtrCol(3):RI);
          AtrRow(2).AtrCol(2) = %bitor(AtrRow(1).AtrCol(3):RI);
          AtrRow(3).AtrCol(1) = %bitor(AtrRow(1).AtrCol(3):RI);
 1e    endif;
 1b    if IsWinner; // reset all selections
 2b       for row = 1 to 3;
             ProtectA(row).Col(*) = %bitor(ND: PR);
 2e       endfor;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Code for block or win depending on how grid is filled to this point.
       begsr srStrategy;
       IsPlaced = *off;
       //---------------------------------------------------------
       // First one to squelch is
       //  __X
       //  _O_
       //  X__   opening gambit
       // Proper move for O here is 1,2 | 2,1 | 2,3 | or 3,2
       //---------------------------------------------------------
 1b    if Row1 = '  X' and
          Row2 = ' O ' and
          Row3 = 'X  ';
          Choice(1).Col(2) = 'O';
          IsPlaced = *on;
 
          //---------------------------------------------------------
          // Second one to squelch is ___   or  X__   or ___
          // _OX          _OX                              _OX
          // X__          ___      proper block is 1,3     _X_
          // proper move for O here is 3,3  block is 1,
          //---------------------------------------------------------
 1x    elseif Row1 = '   ' and
          Row2 = ' OX' and
          Row3 = 'X  ';
          Choice(3).Col(3) = 'O';
          IsPlaced = *on;
 
 1x    elseif Row1 = 'X  ' and
          Row2 = ' OX' and
          Row3 = '   ';
          Choice(1).Col(3) = 'O';
          IsPlaced = *on;
 
 1x    elseif Row1 = '   ' and
          Row2 = ' OX' and
          Row3 = ' X ';
          Choice(1).Col(3) = 'O';
          IsPlaced = *on;
 
          //---------------------------------------------------------
          // _X_              __X
          // _O_              _O_
          // __X              _X_
          // proper move for O here is 2,1  or 2,3 or 3,3
          //---------------------------------------------------------
 1x    elseif Row1 = ' X ' and
          Row2 = ' O ' and
          Row3 = '  X';
          Choice(2).Col(3) = 'O';
          IsPlaced = *on;
 
 1x    elseif Row1 = '  X' and
          Row2 = ' O ' and
          Row3 = ' X ';
          Choice(2).Col(3) = 'O';
          IsPlaced = *on;
 
 1x    elseif Row1 = 'X  ' and
          Row2 = ' O ' and
          Row3 = ' X ';
          Choice(2).Col(3) = 'O';
          IsPlaced = *on;
 
          //---------------------------------------------------------
          // These next 4 are defense related
          // O__  or    __O  or   X__   or __X
          // _X_       _X_       _X_      _X_
          // __X       X__       __O      O__
          // proper move for 1 is 3,1   2=3,3  3=1,3   4=1,1
          //---------------------------------------------------------
 1x    elseif Choice(1).Col(2) = ' ' and
          Choice(2).Col(1) = ' ' and
          Choice(2).Col(3) = ' ' and
          Choice(3).Col(2) = ' ' and
          Choice(2).Col(2) = 'X';
 
 2b       if Choice(1).Col(1) = 'O' and
             Choice(3).Col(3) = 'X';
             Choice(3).Col(1) = 'O';
             IsPlaced = *on;
 2x       elseif Choice(1).Col(3) = 'O' and
             Choice(3).Col(1) = 'X';
             Choice(3).Col(3) = 'O';
             IsPlaced = *on;
 2x       elseif Choice(3).Col(1) = 'O' and
             Choice(1).Col(3) = 'X';
             Choice(1).Col(1) = 'O';
             IsPlaced = *on;
 2x       elseif Choice(3).Col(3) = 'O' and
             Choice(1).Col(1) = 'X';
             Choice(1).Col(3) = 'O';
             IsPlaced = *on;
 2e       endif;
 
          //---------------------------------------------------------
          // If O goes first, always select center square on first move.
          // If first move is to center then game will always be tie,
          // Give X the widest range of options to make a mistake
          // but still cover our fannies.
          // if O has center square and X in any corner, place O in opposite corner.
          //---------------------------------------------------------
 1x    elseif Row1 = 'X  ' and
          Row2 = ' O ' and
          Row3 = '   ';
          Choice(3).Col(3) = 'O';
          IsPlaced = *on;
 1x    elseif Row1 = '  X' and
          Row2 = ' O ' and
          Row3 = '   ';
          Choice(3).Col(1) = 'O';
          IsPlaced = *on;
 1x    elseif Row1 = '   ' and
          Row2 = ' O ' and
          Row3 = 'X  ';
          Choice(1).Col(3) = 'O';
          IsPlaced = *on;
 1x    elseif Row1 = '   ' and
          Row2 = ' O ' and
          Row3 = '  X';
          Choice(1).Col(1) = 'O';
          IsPlaced = *on;
 
          //---------------------------------------------------------
          // Various other gambits
          //---------------------------------------------------------
 1x    elseif Row1 = 'OX ' and
          Row2 = ' O ' and
          Row3 = '  X';
          Choice(2).Col(1) = 'O';
          IsPlaced = *on;
 1x    elseif Row1 = 'X  ' and
          Row2 = ' OX' and
          Row3 = '  O';
          Choice(3).Col(2) = 'O';
          IsPlaced = *on;
 1x    elseif Row1 = 'X  ' and
          Row2 = ' O ' and
          Row3 = ' XO';
          Choice(2).Col(3) = 'O';
          IsPlaced = *on;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Return 5 X 9 array of characters
       //---------------------------------------------------------
       dcl-proc f_FillGrid;
        dcl-pi *n char(9) dim(5);
         pBaseChar char(1) const;
        end-pi;
        dcl-s Line char(9) dim(5);
 
 1b     if pBaseChar = 'X';
           Line(1) = 'xxx   xxx';
           Line(2) = ' xxx xxx ';
           Line(3) = '   xxx   ';
           Line(4) = ' xxx xxx ';
           Line(5) = 'xxx   xxx';
 1x     elseif pBaseChar = 'O';
           Line(1) = '  ooooo  ';
           Line(2) = ' oo   oo ';
           Line(3) = 'oo     oo';
           Line(4) = ' oo   oo ';
           Line(5) = '  ooooo  ';
 1x     elseif pBaseChar = 'T';
           Line(*) = '   TTT   ';
           Line(1) = 'TTTTTTTTT';
 1x     elseif pBaseChar = 'I';
           Line(*) = '   III   ';
           Line(1) = ' IIIIIII ';
           Line(5) = ' IIIIIII ';
 1x     elseif pBaseChar = 'C';
           Line(1) = '   CCCCC ';
           Line(2) = ' CCC     ';
           Line(3) = 'CCC      ';
           Line(4) = ' CCC     ';
           Line(5) = '   CCCCC ';
 1x     elseif pBaseChar = 'A';
           Line(1) = '   AAA   ';
           Line(2) = ' AA   AA ';
           Line(3) = 'AAAAAAAAA';
           Line(4) = 'AA     AA';
           Line(5) = 'AA     AA';
 1x     elseif pBaseChar = 'E';
           Line(1) = ' EEEEEE  ';
           Line(2) = 'EE       ';
           Line(3) = 'EEEEE    ';
           Line(4) = 'EE       ';
           Line(5) = ' EEEEEE  ';
 1e     endif;
        return Line;
       end-proc;
