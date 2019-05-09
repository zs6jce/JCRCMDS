       //---------------------------------------------------------
       // This program is free software, you can redistribute it and/or modify it
       // under the terms of the GNU General Public License as published by
       // the Free Software Foundation. See GNU General Public License for detail
       // Copyright (C) 2013   Erdos Tibor  < erdostibor2@gmail.com >  and
       //                      Craig Rutledge  <www.jcrcmds.com>
       //---------------------------------------------------------
       //?Aknakereso - Minesweeper
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define Dspatr
       /define FunctionKeys
       /define QsnGetCsrAdr
       /define f_GetRandom
       /define f_GetDayName
       /define f_CenterText
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRGMMINED workstn infds(infds);
       dcl-ds Infds;
        InfdsFkey char(1) pos(369);
       end-ds;
 
       dcl-s col uns(3);
       dcl-s row uns(3);
       dcl-c Akna const('*'); // Mine
       dcl-c MFlag const('!'); // Win mine
       dcl-c NoBomb const(':'); // No mine
       dcl-c Sorok const(8); // Rows
       dcl-c Oszlop const(40); // Column
       dcl-s akt uns(3);
       dcl-s aknak uns(3) inz(0);
       dcl-s Ures uns(5);
       dcl-s jeloles uns(3);
       dcl-s rowK int(3);
       dcl-s colK int(3);
       dcl-s rows int(3);
       dcl-s cols int(3);
       dcl-s i int(3);
       dcl-s j int(3);
       dcl-s aa int(3);
       dcl-s bb int(3);
       dcl-s xx uns(3);
       dcl-s Number uns(3);
       dcl-s vanNulla char(1);
       dcl-s language char(1);  // E-English,H-Hungaria
       dcl-s XKeypress uns(3);
 
       dcl-ds wstempds inz;
        wstemp1 char(40);
        wstemp2 char(40);
        wstemp3 char(40);
        wstemp4 char(40);
        wstemp5 char(40);
        wstemp6 char(40);
        wstemp7 char(40);
        wstemp8 char(40);
        wstempArry dim(8) like(wstemp1) pos(1);
       end-ds;
 
       dcl-ds Wsmezods inz;
        Wsmezo1;
        Wsmezo2;
        Wsmezo3;
        Wsmezo4;
        Wsmezo5;
        Wsmezo6;
        Wsmezo7;
        Wsmezo8;
        WsmezoArry dim(8) like(Wsmezo1) pos(1);
       end-ds;
 
       dcl-ds Mines dim(Sorok) qualified;
        col char(1) dim(Oszlop);
       end-ds;
 
       dcl-ds TempM dim(Sorok) qualified;
        col char(1) dim(Oszlop);
       end-ds;
 
       //---------------------------------------------------------
       exsr DetailSettings;
 
       *in80 = *On;
       GameOver = *blanks;
       WsmezoArry(1) = 'Press F5 to start the game!';
       WsmezoArry(3) = 'Nyomj F5-ot a jatek elkezdesehez!';
 
       //?detail cursor position
       csrRow = 10;
       cSrCol = 23;
       row = 1;
       col = 1;
 
 1b    dou 1 = 2;
          exfmt screen1;
 2b       if InfdsFkey = f03 or InfdsFkey = f12;
             *inlr = *on;
             return;
 2e       endif;
 
          QsnGetCsrAdr(QsnCursorRow: QsnCursorCol: 0: ApiErrDS);
          csrRow = QsnCursorRow;
          cSrCol = QsnCursorCol;
 
          //?Kiertekeles
          exsr Kiertekeles; // evaluation
 
          //---------------------------------------------------------
          //?F9 Change Language
 2b       if InfdsFkey = f09;
 3b          if language = 'H';
                exsr DetailSettings;
 3x          else;
                language = 'H';
                WSF3 = 'F3=Kilepes';
                WSF5 = 'F5=Uj jatek';
                WSF9 = 'F9=English';
                WSF12= 'F12=Kilepes';
                WSHDR1= 'AKNAKERESO';
                WSDES = 'Kijeloles';
                WSDES2= 'Uss'+White+'X-et'+Green+', majd Entert!';
                WSMINES='    Aknak szama:';
                WSDESC1= ':    Itt nincs bomba';
                WSDESC2= '1..8 Szomszedos bombak szama';
 3e          endif;
 1i          iter;
 
             //---------------------------------------------------------
             //?F5 Computer generate mines
 2x       elseif InfdsFkey = f05;
             *in80 = *off;
             csrRow = 6;
             cSrCol = 4;
             aGameover = *blanks;
             GameOver = *blanks;
             WsmezoArry(*) = *blanks;
             wstempArry(*) = *blanks;
             WsBumm1 = *blanks;
             WsBumm2 = *blanks;
             WsBumm3 = *blanks;
             WsBumm4 = *blanks;
             WsBumm5 = *blanks;
             Mines(*) = *all'0';
             TempM(*) = *all' ';
             aknak = 0;
 
             // number of mines
             xx = f_GetRandom(30);
 3b          if xx < 11;
                xx += 10;
 3e          endif;
 
             // mine placement
 3b          for akt = 1 to xx;
                Mines(f_GetRandom(Sorok)).Col(f_GetRandom(Oszlop)) = Akna;
 3e          endfor;
 
 3b          for row = 1 to Sorok;
 4b             for col = 1 to Oszlop;
 5b                if Mines(row).Col(col) = Akna;
                      aknak += 1;
                      exsr Korbe;
 5e                endif;
 4e             endfor;
 3e          endfor;
 
             WSAkna = aknak;
 1i          iter;
 2e       endif;
 1e    enddo;
 
       //---------------------------------------------------------
       //?Kiertekeles
       begsr Kiertekeles;
 1b    for row = 1 to Sorok;
 2b       if %Scan('X':WsmezoArry(row)) > 0;
             jeloles = %Scan('X':WsmezoArry(row));
             XKeypress += 1;
 3b          if Mines(row).Col(jeloles) = Akna;
                exsr eGameOver;
 3x          else;
                %Subst(WsmezoArry(row):jeloles:1) = 'x';
                exsr NezzukMeg;
 3e          endif;
 2e       endif;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       //?Nezzuk meg
       begsr NezzukMeg;
 
       rowK = row;
       colK = jeloles;
 1b    if Mines(row).Col(jeloles) <> '0';
          %Subst(WsmezoArry(row):jeloles:1) = Mines(row).Col(jeloles);
 1x    else;
          clear TempM;
 
          %Subst(WsmezoArry(row):jeloles:1) = '0';
          TempM(row).Col(colK) = '0';
          //?<-
 2b       Dow Mines(row).Col(colK) <> Akna AND
             Mines(row).Col(colK) = '0'  AND colK > 1;
             colK -= 1;
             %Subst(WsmezoArry(row):colK:1) = Mines(row).Col(colK);
             TempM(row).Col(colK) = Mines(row).Col(colK);
 2e       Enddo;
          //?->
          colK = jeloles;
 2b       Dow Mines(row).Col(colK) <> Akna AND
             Mines(row).Col(colK) = '0'  AND colK < %len(WsmezoArry(row));
             colK += 1;
             %Subst(WsmezoArry(row):colK:1) = Mines(row).Col(colK);
             TempM(row).Col(colK) = Mines(row).Col(colK);
 2e       Enddo;
 
          exsr Felkutat;
 1e    endif;
 
       Ures = 0;
 1b    for i = 1 to Sorok;
 2b       for j = 1 to Oszlop;
 3b          if %Subst(WsmezoArry(i):j:1) = ' ';
                Ures += 1;
 3e          endif;
 2e       endfor;
 1e    endfor;
 
 1b    if Ures = aknak and XKeypress > 2;
          //?WIN!
          exsr YouWin;
 1e    endif;
       endsr;
       //---------------------------------------------------------
       //?Korbe
       begsr Korbe;
       rowK = row;
       colK = col;
 1b    for rows = 1 to 3;
 2b       for cols = 1 to 3;
             i = (rowK - 2) + rows;
             j = (colK - 2) + cols;
 3b          if (i) < 1 or (i) > sorok  OR
                (j) < 1 or (j) > %len(WsMezo1);
 3x          else;
                // ?kiszamolas
 
 4b             if Mines(i).Col(j) <> '*';
 5b                monitor;
                      Number = %dec(Mines(i).Col(j):1:0);
 5x                on-error;
                      Number = 0;
 5e                endmon;
 
                   Number += 1;
                   Mines(i).Col(j) = %char(Number);
 4e             endif;
 
 3e          endif;
 2e       endfor;
 1e    endfor;
       endsr;
       //---------------------------------------------------------
       //?GameOver
       begsr eGameOver;
       *in80 = *on;
       *in85 = *on;
       WsBumm1 = 'BBB    U   U   M   M   M   M';
       WsBumm2 = 'B  B   U   U   MM MM   MM MM';
       WsBumm3 = 'BBB    U   U   M M M   M M M';
       WsBumm4 = 'B  B   U   U   M   M   M   M';
       WsBumm5 = 'BBB     UUU    M   M   M   M';
       GameOver= f_CenterText('A jateknak vege!  GAME OVER!':30);
       aGameover = %bitor(Red: RI);
 
 1b    for row = 1 to Sorok;
 2b       for col = 1 to Oszlop;
 3b          if Mines(row).Col(col) = Akna;
                %Subst(WsmezoArry(row):col:1) = Akna;
 3e          endif;
 2e       endfor;
 1e    endfor;
 
       endsr;
       //---------------------------------------------------------
       //?You Win!!!
       begsr YouWin;
       *in80 = *on;
       *in85 = *off;
       WsBumm1 = '   W  W  W    I    N   N';
       WsBumm2 = '   W  W  W    I    NN  N';
       WsBumm3 = '   W  W  W    I    N N N';
       WsBumm4 = '   W  W  W    I    N  NN';
       WsBumm5 = '    WWWWW     I    N   N';
       GameOver= f_CenterText('NYERTEL! YOU WIN!':30);
       aGameover = %bitor(Green: RI);
 
 1b    for row = 1 to Sorok;
 2b       for col = 1 to Oszlop;
 3b          if Mines(row).Col(col) = Akna;
                %Subst(WsmezoArry(row):col:1) = MFlag;
 3x          else;
                %Subst(WsmezoArry(row):col:1) = ' ';
 3e          endif;
 2e       endfor;
 1e    endfor;
 
       endsr;
       //---------------------------------------------------------
       //?Felkutat;
       begsr Felkutat;
       rowK = row;
       colK = col;
 
 1b    for aa = 1 to Oszlop;
 2b       for bb = 1 to Sorok;
             %Subst(wstempArry(bb):aa:1) = TempM(bb).Col(aa);
 2e       endfor;
 1e    endfor;
 
       //?ha van 0-s, akkor kell veluk foglalkozni
       vanNulla = ' ';
 1b    for bb = 1 to Sorok;
 2b       if %Scan('0':wstempArry(bb)) > 0;
             vanNulla = 'Y';
 1v          leave;
 2e       endif;
 1e    endfor;
 
 1b    Dow vanNulla = 'Y';
          vanNulla = ' ';
 2b       for aa = 1 to Oszlop;
 3b          for bb = 1 to Sorok;
 4b             if TempM(bb).Col(aa) = '0';
 5b                for rows = 1 to 3;
 6b                   for cols = 1 to 3;
                         i = (bb - 2) + rows;
                         j = (aa - 2) + cols;
 7b                      if (i) < 1 or (i) > sorok  OR
                            (j) < 1 or (j) > %len(WsMezo1);
 7x                      else;
                            //?  ahol meg Ures - where is empty
 8b                         if TempM(i).Col(j) = ' ';
                               TempM(i).Col(j) = Mines(i).Col(j);
 9b                            if TempM(i).Col(j) = '0';
                                  vanNulla = 'Y';
 9e                            endif;
 8e                         endif;
 7e                      endif;
 6e                   endfor;
 5e                endfor;
 4e             endif;
 3e          endfor;
 2e       endfor;
 1e    Enddo;
 
 1b    for aa = 1 to Oszlop;
 2b       for bb = 1 to Sorok;
             %Subst(wstempArry(bb):aa:1) = TempM(bb).Col(aa);
 3b          If TempM(bb).Col(aa) = '0';
                %Subst(WsmezoArry(bb):aa:1) = NoBomb;
 3x          else;
 4b             If TempM(bb).Col(aa) <> ' ';
                   %Subst(WsmezoArry(bb):aa:1) = TempM(bb).Col(aa);
 4e             endif;
 3e          endif;
 2e       endfor;
 1e    endfor;
       endsr;
 
       //?Detail settings --------------------------------------------------
       begsr DetailSettings;
       scDow = f_GetDayName();
       XKeypress = 0;
       language = 'E';
       WSF3 = 'F3=Quit';
       WSF5 = 'F5=New Game';
       WSF9 = 'F9=Magyar';
       WSF12= 'F12=Quit';
       WSHDR1= 'MINESWEEPER';
       WSDES = 'Designation';
       WSDES2= 'Press'+White+'X'+Green+', and Enter';
       WSMINES='Number of mines:';
       WSDESC1= ':    There is no bomb';
       WSDESC2= '1..8 Number of adjacent bombs';
       endsr;
