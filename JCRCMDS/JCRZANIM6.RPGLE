       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRZANIM6 - Animation- Racquetball cutthroat serve rotate
       //  Screen showing proper rotation of players during serve changes.
       //  Simple really, the next server always swaps places with the out server.
       //  This ensures that all players will play all positions every other player.
       //---------------------------------------------------------
       /define ControlStatements
       /define FunctionKeys
       /define f_GetDayName
       /define Dspatr
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRZANIM6D workstn infds(infds);
       dcl-ds Infds;
        fkey char(1) pos(369);
       end-ds;
 
       dcl-s IsFirstMove ind;
       dcl-s IsPlaced ind;
       dcl-s IsWinner ind;
 
       dcl-ds DspDS;
        Grid12Row1;
        Grid12Row2;
        Grid12Row3;
        Grid12Row4;
 
        Grid12Row5;
        Grid31Row1;
        Grid31Row2;
        Grid31Row3;
        Grid31Row4;
 
        Grid31Row5;
        Grid33Row1;
        Grid33Row2;
        Grid33Row3;
        Grid33Row4;
        Grid33Row5;
       end-ds;
 
       dcl-ds ATRDS;
        atr12;
        atr31;
        atr33;
       end-ds;
 
       // row, column, then 5 lines 3d array
       dcl-ds DspCol likeds(DspColx) dim(3) based(DspPtr);
       dcl-ds DspColx qualified;
        DspLine char(9) dim(5);
       end-ds;
       dcl-s DspPtr pointer inz(%addr(DspDs));
 
       dcl-s AtrPos char(1) dim(3) based(AtrPtr);
       dcl-s AtrPtr pointer inz(%addr(AtrDs));
 
       //---------------------------------------------------------
       scDow = f_GetDayName();
       RotateCnt = 1;
       exsr srStartRotation;
 
       //---------------------------------------------------------
 1b    dou 1 = 2;
          exfmt screen;
 2b       if fkey = f03 or fkey = f12;
             *inlr = *on;
             return;
 2e       endif;
 
          // six rotations for all players to play all positions
          RotateCnt += 1;
 2b       if RotateCnt = 7;
             RotateCnt = 1;
 2e       endif;
 2b       if RotateCnt = 1;
             exsr srStartRotation;
 2x       elseif RotateCnt = 2;
             exsr srRotation2;
 2x       elseif RotateCnt = 3;
             exsr srRotation3;
 2x       elseif RotateCnt = 4;
             exsr srRotation4;
 2x       elseif RotateCnt = 5;
             exsr srRotation5;
 2x       elseif RotateCnt = 6;
             exsr srRotation6;
 2e       endif;
 1e    enddo;
       //---------------------------------------------------------
       begsr srStartRotation;
       DspCol(1).DspLine = f_FillGrid('A');
       DspCol(2).DspLine = f_FillGrid('B');
       DspCol(3).DspLine = f_FillGrid('C');
       AtrPos(1) = White;
       AtrPos(2) = Yellow;
       AtrPos(3) = Pink;
       MsgL1 = 'Now it is B turn to serve.';
       MsgL2 = 'B will swap places with A.';
       MsgR1 = *blanks;
       MsgR2 = *blanks;
       endsr;
 
       begsr srRotation2;
       DspCol(2).DspLine = f_FillGrid('A');
       DspCol(1).DspLine = f_FillGrid('B');
       DspCol(3).DspLine = f_FillGrid('C');
       AtrPos(2) = White;
       AtrPos(1) = Yellow;
       AtrPos(3) = Pink;
       MsgR1 = 'Now it is C turn to serve.';
       MsgR2 = 'C will swap places with B.';
       MsgL1 = *blanks;
       MsgL2 = *blanks;
       endsr;
 
       begsr srRotation3;
       DspCol(2).DspLine = f_FillGrid('A');
       DspCol(3).DspLine = f_FillGrid('B');
       DspCol(1).DspLine = f_FillGrid('C');
       AtrPos(2) = White;
       AtrPos(3) = Yellow;
       AtrPos(1) = Pink;
       MsgL1 = 'Now it is A turn to serve.';
       MsgL2 = 'A will swap places with C.';
       MsgR1 = *blanks;
       MsgR2 = *blanks;
       endsr;
 
       begsr srRotation4;
       DspCol(1).DspLine = f_FillGrid('A');
       DspCol(3).DspLine = f_FillGrid('B');
       DspCol(2).DspLine = f_FillGrid('C');
       AtrPos(1) = White;
       AtrPos(3) = Yellow;
       AtrPos(2) = Pink;
       MsgR1 = 'Now it is B turn to serve.';
       MsgR2 = 'B will swap places with A.';
       MsgL1 = *blanks;
       MsgL2 = *blanks;
       endsr;
 
       begsr srRotation5;
       DspCol(3).DspLine = f_FillGrid('A');
       DspCol(1).DspLine = f_FillGrid('B');
       DspCol(2).DspLine = f_FillGrid('C');
       AtrPos(3) = White;
       AtrPos(1) = Yellow;
       AtrPos(2) = Pink;
       MsgL1 = 'Now it is C turn to serve.';
       MsgL2 = 'C will swap places with B.';
       MsgR1 = *blanks;
       MsgR2 = *blanks;
       endsr;
 
       begsr srRotation6;
       DspCol(3).DspLine = f_FillGrid('A');
       DspCol(2).DspLine = f_FillGrid('B');
       DspCol(1).DspLine = f_FillGrid('C');
       AtrPos(3) = White;
       AtrPos(2) = Yellow;
       AtrPos(1) = Pink;
       MsgR1 = 'Now it is A turn to serve.';
       MsgR2 = 'A will swap places with C.';
       MsgL1 = *blanks;
       MsgL2 = *blanks;
       endsr;
 
       //---------------------------------------------------------
       // Return 5 X 9 array of selected character
       dcl-proc f_FillGrid;
        dcl-pi *n char(9) dim(5);
         pBaseChar char(1) const;
        end-pi;
        dcl-s Line char(9) dim(5);
 
 1x     if pBaseChar = 'A';
           Line(1) = '   AAA   ';
           Line(2) = ' AA   AA ';
           Line(3) = 'AAAAAAAAA';
           Line(4) = 'AA     AA';
           Line(5) = 'AA     AA';
 1x     elseif pBaseChar = 'B';
           Line(1) = 'BBBBBBB  ';
           Line(2) = 'BB    BB ';
           Line(3) = 'BBBBBB   ';
           Line(4) = 'BB    BB ';
           Line(5) = 'BBBBBBB  ';
 1b     elseif pBaseChar = 'C';
           Line(1) = '   CCCCC ';
           Line(2) = ' CCC     ';
           Line(3) = 'CCC      ';
           Line(4) = ' CCC     ';
           Line(5) = '   CCCCC ';
 1e     endif;
        return Line;
       end-proc;
