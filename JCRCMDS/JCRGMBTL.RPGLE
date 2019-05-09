       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRGMBTL - BattleShip
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define Dspatr
       /define FunctionKeys
       /define QsnGetCsrAdr
       /define f_GetRandom
       /define f_GetDayName
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRGMBTLD workstn infds(Infds);
       dcl-ds Infds;
        InfdsFkey char(1) pos(369);
       end-ds;
 
       dcl-s col uns(3);
       dcl-s ForCount uns(3);
       dcl-s HashCol uns(3) dim(51);
       dcl-s HashRow uns(3) dim(51);
       dcl-s row uns(3);
       dcl-s TimesHit2 uns(3);
       dcl-s TimesHit3 uns(3);
       dcl-s TimesHit4 uns(3);
       dcl-s TimesHit5 uns(3);
       dcl-s UserxHit2 uns(3);
       dcl-s UserxHit3 uns(3);
       dcl-s UserxHit4 uns(3);
       dcl-s UserxHit5 uns(3);
       dcl-s HitCol1 uns(3);
       dcl-s HitCol2 uns(3);
       dcl-s HitRow1 uns(3);
       dcl-s HitRow2 uns(3);
       dcl-s xx uns(3);
       dcl-s yy uns(3);
       dcl-s IsCollision ind;
       dcl-s IsDeployed ind;
       dcl-s IsGoodRowCol ind;
       dcl-s IsHit ind;
       dcl-s IsHitFirst ind;
       dcl-s IsHitSecond ind;
       dcl-c Left 1;
       dcl-c Right 2;
       dcl-c Up 3;
       dcl-c Down 4;
 
       dcl-ds GridDS qualified template;
        col char(1) dim(10);
       end-ds;
 
       dcl-ds Deployed dim(10) likeds(GridDS);
       dcl-ds Attack dim(10) likeds(GridDS) based(ptr);  // enemy screen fields
       dcl-ds AttackA dim(10) likeds(GridDS) based(ptr2); // enemy attrib array
       dcl-ds Defend dim(10) likeds(GridDS) based(ptr3);  // defend screen fields
       dcl-ds DefendA dim(10) likeds(GridDS) based(ptr4); // defend attrib array
       dcl-ds DefendSave dim(10) likeds(GridDS);
 
       dcl-s ptr pointer inz(%addr(r01c01));
       dcl-s ptr2 pointer inz(%addr(atr0101));
       dcl-s ptr3 pointer inz(%addr(b01c01));
       dcl-s ptr4 pointer inz(%addr(btr0101));
 
       // map screen fields into DS so arrays can manipulate values
       dcl-ds *n;
        r01c01;
        r01c02;
        r01c03;
        r01c04;
        r01c05;
        r01c06;
        r01c07;
        r01c08;
        r01c09;
        r01c10;
        r02c01;
        r02c02;
        r02c03;
        r02c04;
        r02c05;
        r02c06;
        r02c07;
        r02c08;
        r02c09;
        r02c10;
        r03c01;
        r03c02;
        r03c03;
        r03c04;
        r03c05;
        r03c06;
        r03c07;
        r03c08;
        r03c09;
        r03c10;
        r04c01;
        r04c02;
        r04c03;
        r04c04;
        r04c05;
        r04c06;
        r04c07;
        r04c08;
        r04c09;
        r04c10;
        r05c01;
        r05c02;
        r05c03;
        r05c04;
        r05c05;
        r05c06;
        r05c07;
        r05c08;
        r05c09;
        r05c10;
        r06c01;
        r06c02;
        r06c03;
        r06c04;
        r06c05;
        r06c06;
        r06c07;
        r06c08;
        r06c09;
        r06c10;
        r07c01;
        r07c02;
        r07c03;
        r07c04;
        r07c05;
        r07c06;
        r07c07;
        r07c08;
        r07c09;
        r07c10;
        r08c01;
        r08c02;
        r08c03;
        r08c04;
        r08c05;
        r08c06;
        r08c07;
        r08c08;
        r08c09;
        r08c10;
        r09c01;
        r09c02;
        r09c03;
        r09c04;
        r09c05;
        r09c06;
        r09c07;
        r09c08;
        r09c09;
        r09c10;
        r10c01;
        r10c02;
        r10c03;
        r10c04;
        r10c05;
        r10c06;
        r10c07;
        r10c08;
        r10c09;
        r10c10;
        atr0101;
        atr0102;
        atr0103;
        atr0104;
        atr0105;
        atr0106;
        atr0107;
        atr0108;
        atr0109;
        atr0110;
        atr0201;
        atr0202;
        atr0203;
        atr0204;
        atr0205;
        atr0206;
        atr0207;
        atr0208;
        atr0209;
        atr0210;
        atr0301;
        atr0302;
        atr0303;
        atr0304;
        atr0305;
        atr0306;
        atr0307;
        atr0308;
        atr0309;
        atr0310;
        atr0401;
        atr0402;
        atr0403;
        atr0404;
        atr0405;
        atr0406;
        atr0407;
        atr0408;
        atr0409;
        atr0410;
        atr0501;
        atr0502;
        atr0503;
        atr0504;
        atr0505;
        atr0506;
        atr0507;
        atr0508;
        atr0509;
        atr0510;
        atr0601;
        atr0602;
        atr0603;
        atr0604;
        atr0605;
        atr0606;
        atr0607;
        atr0608;
        atr0609;
        atr0610;
        atr0701;
        atr0702;
        atr0703;
        atr0704;
        atr0705;
        atr0706;
        atr0707;
        atr0708;
        atr0709;
        atr0710;
        atr0801;
        atr0802;
        atr0803;
        atr0804;
        atr0805;
        atr0806;
        atr0807;
        atr0808;
        atr0809;
        atr0810;
        atr0901;
        atr0902;
        atr0903;
        atr0904;
        atr0905;
        atr0906;
        atr0907;
        atr0908;
        atr0909;
        atr0910;
        atr1001;
        atr1002;
        atr1003;
        atr1004;
        atr1005;
        atr1006;
        atr1007;
        atr1008;
        atr1009;
        atr1010;
        b01c01;
        b01c02;
        b01c03;
        b01c04;
        b01c05;
        b01c06;
        b01c07;
        b01c08;
        b01c09;
        b01c10;
        b02c01;
        b02c02;
        b02c03;
        b02c04;
        b02c05;
        b02c06;
        b02c07;
        b02c08;
        b02c09;
        b02c10;
        b03c01;
        b03c02;
        b03c03;
        b03c04;
        b03c05;
        b03c06;
        b03c07;
        b03c08;
        b03c09;
        b03c10;
        b04c01;
        b04c02;
        b04c03;
        b04c04;
        b04c05;
        b04c06;
        b04c07;
        b04c08;
        b04c09;
        b04c10;
        b05c01;
        b05c02;
        b05c03;
        b05c04;
        b05c05;
        b05c06;
        b05c07;
        b05c08;
        b05c09;
        b05c10;
        b06c01;
        b06c02;
        b06c03;
        b06c04;
        b06c05;
        b06c06;
        b06c07;
        b06c08;
        b06c09;
        b06c10;
        b07c01;
        b07c02;
        b07c03;
        b07c04;
        b07c05;
        b07c06;
        b07c07;
        b07c08;
        b07c09;
        b07c10;
        b08c01;
        b08c02;
        b08c03;
        b08c04;
        b08c05;
        b08c06;
        b08c07;
        b08c08;
        b08c09;
        b08c10;
        b09c01;
        b09c02;
        b09c03;
        b09c04;
        b09c05;
        b09c06;
        b09c07;
        b09c08;
        b09c09;
        b09c10;
        b10c01;
        b10c02;
        b10c03;
        b10c04;
        b10c05;
        b10c06;
        b10c07;
        b10c08;
        b10c09;
        b10c10;
        btr0101;
        btr0102;
        btr0103;
        btr0104;
        btr0105;
        btr0106;
        btr0107;
        btr0108;
        btr0109;
        btr0110;
        btr0201;
        btr0202;
        btr0203;
        btr0204;
        btr0205;
        btr0206;
        btr0207;
        btr0208;
        btr0209;
        btr0210;
        btr0301;
        btr0302;
        btr0303;
        btr0304;
        btr0305;
        btr0306;
        btr0307;
        btr0308;
        btr0309;
        btr0310;
        btr0401;
        btr0402;
        btr0403;
        btr0404;
        btr0405;
        btr0406;
        btr0407;
        btr0408;
        btr0409;
        btr0410;
        btr0501;
        btr0502;
        btr0503;
        btr0504;
        btr0505;
        btr0506;
        btr0507;
        btr0508;
        btr0509;
        btr0510;
        btr0601;
        btr0602;
        btr0603;
        btr0604;
        btr0605;
        btr0606;
        btr0607;
        btr0608;
        btr0609;
        btr0610;
        btr0701;
        btr0702;
        btr0703;
        btr0704;
        btr0705;
        btr0706;
        btr0707;
        btr0708;
        btr0709;
        btr0710;
        btr0801;
        btr0802;
        btr0803;
        btr0804;
        btr0805;
        btr0806;
        btr0807;
        btr0808;
        btr0809;
        btr0810;
        btr0901;
        btr0902;
        btr0903;
        btr0904;
        btr0905;
        btr0906;
        btr0907;
        btr0908;
        btr0909;
        btr0910;
        btr1001;
        btr1002;
        btr1003;
        btr1004;
        btr1005;
        btr1006;
        btr1007;
        btr1008;
        btr1009;
        btr1010;
       end-ds;
 
       //---------------------------------------------------------
       scDow = f_GetDayName();
       exsr srSetupUserShips;
 
 1b    dou 1 = 2;
          exfmt screen2;
          // get cursor Row and Column
          QsnGetCsrAdr(QsnCursorRow: QsnCursorCol: 0: ApiErrDS);
          csrRow = QsnCursorRow;
          cSrCol = QsnCursorCol;
 
          // F5 = Restart
 2b       if InfdsFkey = f05;
             exsr srSetupUserShips;
 1i          iter;
 2e       endif;
 2b       if InfdsFkey = f03 or InfdsFkey = f12;
 1v          leave;
 2e       endif;
 
          // Process users attack, then let computer have shot at it!
          exsr srUserAttack;
 
          // Check and see if ALL enemy ships are sunk
 2b       if UserxHit2 = 9
             and UserxHit3 = 9
             and UserxHit4 = 9
             and UserxHit5 = 9;
             GameOver = 'CONGRATULATIONS! YOU WIN!';
             aGameover = %bitor(Green: RI);
 2x       else;
             exsr srComputerAttack;
 2e       endif;
 
 1e    enddo;
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       // Spin through Rows and Columns looking for attacks
       begsr srUserAttack;
 1b    for row = 1 to 10;
 2b       for col = 1 to 10;
 3b          if Attack(row).Col(col) = 'X';
 4b             if Deployed(row).Col(col) = ' ';
                   Attack(row).Col(col) = '.';
                   AttackA(row).Col(col) = %bitor(BLUE: PR);
 4x             else;
                   f_UpdateHits(row: col:
                   Attack: AttackA: Deployed:
                   edspatr2: edspatr3: edspatr4: edspatr5:
                   UserxHit2: UserxHit3: UserxHit4: UserxHit5);
 4e             endif;
 3e          endif;
 2e       endfor;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // Blow users stuff outta the water!!
       // Computer will spin down users defend array looking
       // for place it has already gotten a hit.   When it finds one
       // check all adjacent Row/Columns for un-hit space
       //
       // Until computer gets a hit, use a hash table to
       // select random shots from not-hit locations.
       //
       // If one is found, FIRE ONE! If no hits are found or all
       // adjacent places are filled, continue with hash table random.
       // Three different types of activity.
       // 1. Multiple Hits detected
       // 2. Single Hit detected
       // 3. No hits detected
       //---------------------------------------------------------
       begsr srComputerAttack;
       HitRow1 = 0;
       HitCol1 = 0;
       HitRow2 = 0;
       HitCol2 = 0;
       IsHitFirst = *off;
       IsHitSecond = *off;
       IsHit = *off;
       // analyze previous hits
 1b    for row = 1 to 10;
 2b       for col = 1 to 10;
 3b          if Defend(row).Col(col) = 'H';
 4b             if HitRow1 = 0;
                   HitRow1 = row;
                   HitCol1 = col;
                   IsHitFirst = *on;
 4x             else;
                   HitRow2 = row;
                   HitCol2 = col;
                   IsHitSecond = *on;
 2v                leave;
 4e             endif;
 3e          endif;
 2e       endfor;
 2b       if IsHitSecond;
 1v          leave;
 2e       endif;
 1e    endfor;
 
       //---------------------------------------------------------
       // Single Hit - Fire on next random contiguous grid location
 1b    if IsHitFirst
          and not IsHitSecond;
          f_SingleNextHit();
 
          //---------------------------------------------------------
          // Multiple Hits - Run Left, then Right, Up, then Down to get next hit
 1x    elseif IsHitFirst
          and IsHitSecond;
 2b       if HitRow1 = HitRow2;
             IsHit = f_MultNextHit(LEFT);
 3b          if not IsHit;
                IsHit = f_MultNextHit(RIGHT);
 3e          endif;
 2e       endif;
 
 2b       if HitCol1 = HitCol2
             or (not IsHit);  //side by side boats
             IsHit = f_MultNextHit(UP);
 3b          if not IsHit;
                IsHit = f_MultNextHit(DOWN);
 3e          endif;
 2e       endif;
 
          //---------------------------------------------------------
          // If multiple hits on-screen, but preceding section
          // could not find new hit, then there are two ships
          // side-by-side.  Try to hit first ship with another shot.
 2b       if not IsHit;
             f_SingleNextHit();
 2e       endif;
 1x    else;
          //---------------------------------------------------------
          // Nothing has been hit yet.
          // Load hash table with all even un-hit indexes.
          // Use random value (with upper limit = count of available indexes.)
          // to access hash table entry containing index to be targeted.
          yy = 0;
 2b       for row = 1 to 10;
 3b          for col = 1 to 10;
 4b             if not(Defend(row).Col(col) = 'm'
                   or Defend(row).Col(col) = 'H'
                   or Defend(row).Col(col) = 'S');
 
 5b                if %rem(row + col: 2) = 0;
                      yy += 1;
                      HashRow(yy) = row;
                      HashCol(yy) = col;
 5e                endif;
 4e             endif;
 3e          endfor;
 2e       endfor;
 2b       if yy > 0;
             xx = f_GetRandom(yy);
             f_DropBombOnX(HashRow(xx): HashCol(xx));
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Let user set up right side ship locations
       begsr srSetupUserShips;
       csrRow = 5;
       cSrCol = 8;
       BlueRi = %bitor(WHITE: RI);
       RedRi = %bitor(RED: RI);
       Attack(*) = *all' ';
       AttackA(*) = *allx'00';
       Deployed(*) = *all' ';
       // load big F5 to grid so player knows what button to hit
       Defend(1) = 'FFFF 55555';
       Defend(2) = 'FFFF 55555';
       Defend(3) = 'FF   55   ';
       Defend(4) = 'FF   55   ';
       Defend(5) = 'FFF  555  ';
       Defend(6) = 'FFF   555 ';
       Defend(7) = 'FF      55';
       Defend(8) = 'FF      55';
       Defend(9) = 'FF   5555 ';
       Defend(10) = 'FF   555  ';
 1b    for row = 1 to 10;
 2b       for col = 1 to 10;
 3b          if Defend(row).Col(col) = ' ';
                Defend(row).Col(col) = '.';
                DefendA(row).Col(col) = Blue;
 3x          else;
                DefendA(row).Col(col) = %bitor(Blue: RI);
 3e          endif;
 2e       endfor;
 1e    endfor;
       TimesHit2 = 0;
       TimesHit3 = 0;
       TimesHit4 = 0;
       TimesHit5 = 0;
       Udspatr2 = x'00';
       Udspatr3 = x'00';
       Udspatr4 = x'00';
       Udspatr5 = x'00';
       UserxHit2 = 0;
       UserxHit3 = 0;
       UserxHit4 = 0;
       UserxHit5 = 0;
       edspatr2 = x'00';
       edspatr3 = x'00';
       edspatr4 = x'00';
       edspatr5 = x'00';
       GameOver = *blanks;
       aGameover = ND;
       aDeployMsg = ND;
       IsDeployed = *off;
 
 1b    dou 1 = 2;
          exfmt screen1;
 2b       if InfdsFkey = f03 or InfdsFkey = f12;
             *inlr = *on;
             return;
 2e       endif;
          aDeployMsg = ND;
 
          //---------------------------------------------------------
          // Computer generate defense grid layout
 2b       if InfdsFkey = f05;
             f_GenerateDeployment();
             Defend(*) = Deployed(*);
             BlueRi = %bitor(Blue: RI);
             RedRi = %bitor(Blue: RI);
 
 3b          for row = 1 to 10;
 4b             for col = 1 to 10;
 5b                if Defend(row).Col(col) = ' ';
                      Defend(row).Col(col) = '.';
                      DefendA(row).Col(col) = BLUE;
 5x                else;
 6b                   if Defend(row).Col(col) = '2';
                         DefendA(row).Col(col) = %bitor(Turq: RI);
 6x                   elseif Defend(row).Col(col) = '3';
                         DefendA(row).Col(col) = %bitor(Yellow: RI);
 6x                   elseif Defend(row).Col(col) = '4';
                         DefendA(row).Col(col) = %bitor(PINK: RI);
 6x                   elseif Defend(row).Col(col) = '5';
                         DefendA(row).Col(col) = %bitor(RED: RI);
 6e                   endif;
 5e                endif;
 4e             endfor;
 3e          endfor;
             IsDeployed = *on;
 1i          iter;
 2x       else;
             //---------------------------------------------------------
             // Let battle begin.  turn all ships reverse image green for stealth
 3b          if IsDeployed;
 4b             for row = 1 to 10;
 5b                for col = 1 to 10;
 6b                   if not(Defend(row).Col(col) = '.');
                         DefendA(row).Col(col) = %bitor(Green: RI);
 6e                   endif;
 5e                endfor;
 4e             endfor;
 1v             leave;
 3x          else;
                aDeployMsg = %bitor(Green: RI);
 1i             iter;
 3e          endif;
 2e       endif;
 1e    enddo;
       DefendSave(*) = Defend(*);  //Save for sunk placement
       f_GenerateDeployment();  //Set random left side ships
       endsr;
 
       //---------------------------------------------------------
       // Find next random location to hit after single hit
       dcl-proc f_SingleNextHit;
        dcl-pi *n end-pi;
 
 1b     dou IsGoodRowCol;
           row = HitRow1;
           col = HitCol1;
           IsGoodRowCol = f_MoveReticle(row: col: f_GetRandom(4): 'SGL');
 2b        if IsGoodRowCol;
              f_DropBombOnX(row: col);
              return;
 2e        endif;
 1e     enddo;
       end-proc;
 
       //---------------------------------------------------------
       // Find next location to nuke after multiple hits
       dcl-proc f_MultNextHit;
        dcl-pi *n ind;
         p_Vector uns(3) const;
        end-pi;
 
        row = HitRow1;
        col = HitCol1;
 1b     dou not IsGoodRowCol;
           IsGoodRowCol = f_MoveReticle(row: col: p_Vector: 'MLT');
 
 2b        if IsGoodRowCol
              and not(Defend(row).Col(col) = 'H');
              f_DropBombOnX(row: col);
              return *on;
 2e        endif;
 1e     enddo;
        return *off;
       end-proc;
 
       //---------------------------------------------------------
       // Update Hits on grid and set display attributes
       dcl-proc f_UpdateHits;
        dcl-pi *n;
         row uns(3);
         col uns(3);
         GridRow likeds(Defend) dim(10);
         GridRowA likeds(DefendA) dim(10);
         GridSave likeds(DefendSave) dim(10);
         HitAttr2 char(1);
         HitAttr3 char(1);
         HitAttr4 char(1);
         HitAttr5 char(1);
         HitCount2 uns(3);
         HitCount3 uns(3);
         HitCount4 uns(3);
         HitCount5 uns(3);
        end-pi;
        dcl-s rowx uns(3);
        dcl-s colx uns(3);
 
 1b     if GridSave(row).Col(col) = '2';
           HitAttr2 = %bitor(YELLOW: RI);
           HitCount2 += 1;
 1x     elseif GridSave(row).Col(col) = '3';
           HitAttr3 = %bitor(YELLOW: RI);
           HitCount3 += 1;
 1x     elseif GridSave(row).Col(col) = '4';
           HitAttr4 = %bitor(YELLOW: RI);
           HitCount4 += 1;
 1x     elseif GridSave(row).Col(col) = '5';
           HitAttr5 = %bitor(YELLOW: RI);
           HitCount5 += 1;
 1e     endif;
 
 1b     if HitCount2 = 2;
           HitAttr2 = RED;
           exsr srSetToSunk;
           HitCount2 = 9;
 1x     elseif HitCount3 = 3;
           HitAttr3 = RED;
           exsr srSetToSunk;
           HitCount3 = 9;
 1x     elseif HitCount4 = 4;
           HitAttr4 = RED;
           exsr srSetToSunk;
           HitCount4 = 9;
 1x     elseif HitCount5 = 5;
           HitAttr5 = RED;
           exsr srSetToSunk;
           HitCount5 = 9;
 1x     else;
           GridRow(row).Col(col) = 'H';
           GridRowA(row).Col(col) = %bitor(YELLOW: RI);
 1e     endif;
 
       //---------------------------------------------------------
       // if totally sunk, turn to 'S' and Red color
        begsr srSetToSunk;
 1b     for rowx = 1 to 10;
 2b        for colx = 1 to 10;
 3b           if GridSave(rowx).Col(colx) = GridSave(row).Col(col);
                 GridRow(rowx).Col(colx) = 'S';
                 GridRowA(rowx).Col(colx) = %bitor(RED: RI);
 3e           endif;
 2e        endfor;
 1e     endfor;
        endsr;
       end-proc;
 
       //---------------------------------------------------------
       // Unload the BOMB!!!
       dcl-proc f_DropBombOnX;
        dcl-pi *n;
         row uns(3);
         col uns(3);
        end-pi;
 
        dcl-s rowx uns(3);
        dcl-s colx uns(3);
 
 1b     if Defend(row).Col(col) = '.';
           Defend(row).Col(col) = 'm';
           DefendA(row).Col(col) = %bitor(BLUE: RI);
 1x     else;
           f_UpdateHits(row: col:
           Defend: DefendA: DefendSave:
           udspatr2:  udspatr3:  udspatr4:  udspatr5:
           TimesHit2: TimesHit3: TimesHit4: TimesHit5);
 1e     endif;
 
       //---------------------------------------------------------
       // Check and see if ALL user ships are sunk.
       // Set loser indicator and show remaining computer ships locations.
 1b     if TimesHit2 = 9
           and TimesHit3 = 9
           and TimesHit4 = 9
           and TimesHit5 = 9;
           GameOver = 'LOSER! PRESS F5 TO RESTART.';
           aGameover = %bitor(Green: RI);
 2b        for rowx = 1 to 10;
 3b           for colx = 1 to 10;
 4b              if Attack(rowx).Col(colx) = ' ';
                    Attack(rowx).Col(colx) = Deployed(rowx).Col(colx);
 4e              endif;
 3e           endfor;
 2e        endfor;
 1e     endif;
       end-proc;
 
       //---------------------------------------------------------
       // Return *off if next Row/Col not valid target
       dcl-proc f_MoveReticle;
        dcl-pi *n ind;
         row uns(3);
         col uns(3);
         Direction uns(3) const;
         TypeScan char(3) const;
        end-pi;
 
       // move targeting reticule one in selected direction
 1b     if Direction = UP;
           row -= 1;
 1x     elseif Direction = DOWN;
           row += 1;
 1x     elseif Direction = LEFT;
           col -= 1;
 1x     elseif Direction = RIGHT;
           col += 1;
 1e     endif;
 1b     if row = 0
           or row = 11
           or col = 0
           or col = 11
           or Defend(row).Col(col) = 'S'
           or Defend(row).Col(col) = 'm'
           or (Defend(row).Col(col) = 'H'
           and TypeScan = 'SGL');
           return *off;
 1e     endif;
        return *on;
       end-proc;
 
       //---------------------------------------------------------
       // randomly deploy ship positions
       dcl-proc f_GenerateDeployment;
        dcl-pi *n end-pi;
        dcl-s ShipSize uns(3);
        dcl-s randVector uns(3);
        dcl-s sizeCount uns(3);
        dcl-s row uns(3);
        dcl-s col uns(3);
        dcl-s rowx uns(3);
        dcl-s colx uns(3);
 
        dcl-ds rowDS dim(10) qualified;
         col char(1) dim(10);
        end-ds;
 
       //---------------------------------------------------------
       // randVector=1,2,3 or 4.   1=up, 2=right, 3=down, 4=left
       // ShipSize = number of indexes occupied by each ship.
 1b     for ShipSize = 2 to 5;
           randVector = f_GetRandom(4);
 2b        dou not IsCollision;
              sizeCount = 0;
              row = f_GetRandom(10);
              col = f_GetRandom(10);
              exsr srLoadShips;
 2e        enddo;
 1e     endfor;
        Deployed(*) = rowDS(*);  //update global DS
        return;
 
       //---------------------------------------------------------
       // Load grid
       // Be concerned about ships trying to run off grid
       // and about ships trying to overlay each other.
       // Known is the length of ship, direction ship is going,
       // size of grid. If ship would run off the grid,
       // back up starting point until ship will fit.
       //---------------------------------------------------------
        begsr srLoadShips;
        IsCollision = *off;
 1b     if randVector = 1;  //go up from start
 2b        dow ShipSize > row;
              row += 1;
 2e        enddo;
 1x     elseif randVector = 3;  //go down from start
 2b        dow (11 - ShipSize) < row;
              row -= 1;
 2e        enddo;
 1x     elseif randVector = 2;  //go right from start
 2b        dow (11 - ShipSize) < col;
              col -= 1;
 2e        enddo;
 1x     elseif randVector = 4;  //go left from start
 2b        dow ShipSize > col;
              col += 1;
 2e        enddo;
 1e     endif;
 
       //---------------------------------------------------------
       // Before any values are loaded, make sure that none
       // of this ships coordinates are occupied by another ship.
       // If so, get new random numbers for starting point
        rowx = row;
        colx = col;
 1b     for ForCount = 1 to ShipSize;
 2b        if randVector = 1;  //go up from start
 3b           if rowDs(rowx).Col(colx) > *blanks;
                 IsCollision = *on;
 LV              leavesr;
 3e           endif;
              rowx -= 1;
 2x        elseif randVector = 3;  //go down from start
 3b           if rowDs(rowx).Col(colx) > *blanks;
                 IsCollision = *on;
 LV              leavesr;
 3e           endif;
              rowx += 1;
 2x        elseif randVector = 2;  //go right from start
 3b           if rowDs(rowx).Col(colx) > *blanks;
                 IsCollision = *on;
 LV              leavesr;
 3e           endif;
              colx += 1;
 2x        elseif randVector = 4;  //go left from start
 3b           if rowDs(rowx).Col(colx) > *blanks;
                 IsCollision = *on;
 LV              leavesr;
 3e           endif;
              colx -= 1;
 2e        endif;
 1e     endfor;
       //---------------------------------------------------------
       // Load values for ships
 1b     for ForCount = 1 to ShipSize;
 2b        if randVector = 1;
              rowDs(row).Col(col) = %char(ShipSize);
              row -= 1;
 2x        elseif randVector = 3;
              rowDs(row).Col(col) = %char(ShipSize);
              row += 1;
 2x        elseif randVector = 2;
              rowDs(row).Col(col) = %char(ShipSize);
              col += 1;
 2x        elseif randVector = 4;
              rowDs(row).Col(col) = %char(ShipSize);
              col -= 1;
 2e        endif;
 1e     endfor;
        endsr;
       end-proc;
