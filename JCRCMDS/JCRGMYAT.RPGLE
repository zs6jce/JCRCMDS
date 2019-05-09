       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRGMYAT - Yahtzee
       //---------------------------------------------------------
       /define ControlStatements
       /define Sds
       /define Dspatr
       /define FunctionKeys
       /define f_GetRandom
       /define f_GetDayName
       /define f_RmvSflMsg
       /define f_SndSflMsg
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRGMYATD workstn infds(infds) indds(ind);
       dcl-ds Infds;
        InfdsFkey char(1) pos(369);
       end-ds;
 
       dcl-s Color char(1);
       dcl-s DiceNum uns(3);
       dcl-s xx uns(3);
       dcl-s yy uns(3);
       dcl-s row uns(3);
       dcl-s col uns(3);
       dcl-s Throw uns(3);
       dcl-s OriginalDice uns(3);
       dcl-s UserDice uns(3) dim(5) ascend;
       dcl-s FourDice uns(3) dim(4);
       dcl-s DropDice uns(3);
       dcl-s SumAllDots uns(3);
       dcl-s IsOneXed ind;
       dcl-s ThreeShots uns(3);
       dcl-s pCount uns(3);
       dcl-s TotGrandA char(3);
 
       dcl-ds SumDS;
        CalcSixes uns(3);
        CalcFives uns(3);
        CalcFours uns(3);
        CalcThrees uns(3);
        CalcTwos uns(3);
        CalcOnes uns(3);
        Calc3ofaKind uns(3);
        Calc4ofaKind uns(3);
        CalcFullHouse uns(3);
        CalcRunof4s uns(3);
        CalcRunof5s uns(3);
        CalcYahtzee uns(3);
        CalcChance uns(3);
        SumArry uns(3) dim(13) pos(1);
       end-ds;
 
       // array of what selections will score
       dcl-ds IsScoreDS;
        IsSixes ind;
        IsFives ind;
        IsFours ind;
        IsThrees ind;
        IsTwos ind;
        IsOnes ind;
        Is3ofaKind ind;
        Is4ofaKind ind;
        IsFullHouse ind;
        IsRunof4s ind;
        IsRunof5s ind;
        IsYahtzee ind;
        IsChance ind;
        IsScoreArry ind dim(13) pos(1);
       end-ds;
 
       // Protect already made selections
        dcl-s ProtectArry char(1) dim(13);
 
       // Total up selections
       dcl-ds TotalsDS;
        Tot6S;
        Tot5S;
        Tot4S;
        Tot3S;
        Tot2S;
        Tot1S;
        Tot3OfKind;
        Tot4OfKind;
        TotFullHou;
        Tot4InRow;
        Tot5InRow;
        TotYahtzee;
        TotChance;
        TotArry dim(13) pos(1) like(Tot6S);
       end-ds;
 
       // highlight selections that will score
       dcl-ds BucketAttrDS;
        A6SA;
        A5SA;
        A4SA;
        A3SA;
        A2SA;
        A1SA;
        A3OFA;
        A4OFA;
        AFULLA;
        A4ROWA;
        A5ROWA;
        AYAHA;
        aChanceA;
        BucketArryAtr char(1) dim(13) pos(1);
       end-ds;
 
       // highlight text of selections that will score
       dcl-ds TextAttrDS;
        A6SB;
        A5SB;
        A4SB;
        A3SB;
        A2SB;
        A1SB;
        A3OFB;
        A4OFB;
        AFULLB;
        A4ROWB;
        A5ROWB;
        AYAHB;
        aChanceB;
        TextArryAtr char(1) dim(13) pos(1);
       end-ds;
 
       // highlight totals of selections that will score
       dcl-ds TotAttrDS;
        A6SC;
        A5SC;
        A4SC;
        A3SC;
        A2SC;
        A1SC;
        A3OFC;
        A4OFC;
        AFULLC;
        A4ROWC;
        A5ROWC;
        AYAHC;
        aChanceC;
        TotArryAtr char(1) dim(13) pos(1);
       end-ds;
 
       // highlight ancillary text of selections that will score
       dcl-ds Text2AttrDS;
        A3OFD pos(7);
        A4OFD pos(8);
        AFULLD pos(9);
        A4ROWD pos(10);
        A5ROWD pos(11);
        AYAHD pos(12);
        aChanceD pos(13);
        Text2ArryAtr char(1) dim(13) pos(1);
       end-ds;
 
       // load selections into array for validity checking
       dcl-ds BucketsDS;
        Sel6S;
        Sel5S;
        Sel4S;
        Sel3S;
        Sel2S;
        Sel1S;
        Sel3OfKind;
        Sel4OfKind;
        SelFullHou;
        Sel4InRow;
        Sel5InRow;
        SelYahtzee;
        SelChance;
        xBucketArry char(1) dim(13) pos(1);
       end-ds;
 
       // dice outline Border attributes
       dcl-ds BorderADS;
        Border1A;
        Border2A;
        Border3A;
        Border4A;
        Border5A;
        BorderA char(1) dim(5) pos(1);
       end-ds;
 
       // Name screen indicators
       dcl-ds ind qualified;
        ScreenCtl ind pos(10);
       end-ds;
 
       // map screen fields into DS so pointers to data can overlay
       dcl-ds DiscardDS;
        Discard1;
        Discard2;
        Discard3;
        Discard4;
        Discard5;
        DiscardArry char(1) dim(5) pos(1);
       end-ds;
 
       // dice faces and attributes 3d array
       dcl-ds Face dim(5) qualified based(ptr1);
        row likeds(Rowx) dim(3);
       end-ds;
       dcl-ds Rowx qualified;
        col char(1) dim(3);
       end-ds;
       dcl-s ptr1 pointer inz(%addr(s0111));
 
       dcl-ds FaceAttr dim(5) likeds(Face) based(ptr2);
       dcl-s ptr2 pointer inz(%addr(s0111a));
 
       // large roll counter and final total 2d array
       dcl-ds RollCnt dim(7) qualified based(ptr6);  // large roll counter
        col char(1) dim(4);
       end-ds;
       dcl-s ptr6 pointer inz(%addr(C111));
       dcl-ds RollCntA dim(7) likeds(RollCnt) based(ptr7);
       dcl-s ptr7 pointer inz(%addr(C111a));
 
       dcl-ds LargeGrand10s dim(7) likeds(RollCnt) based(ptr8); // large grand 10s
       dcl-s ptr8 pointer inz(%addr(C211));
       dcl-ds LargeGrand10sA dim(7) likeds(RollCnt) based(ptr9);
       dcl-s ptr9 pointer inz(%addr(C211a));
 
       dcl-ds LargeGrand1s dim(7) likeds(RollCnt) based(ptr10); // large grand 1s
       dcl-s ptr10 pointer inz(%addr(C311));
       dcl-ds LargeGrand1sA dim(7) likeds(RollCnt) based(ptr11);
       dcl-s ptr11 pointer inz(%addr(C311a));
 
       // map screen fields into DS so arrays can manipulate values
       // Dice Faces
       dcl-ds *n;
        s0111;
        s0112;
        s0113;
        s0121;
        s0122;
        s0123;
        s0131;
        s0132;
        s0133;
        s0211;
        s0212;
        s0213;
        s0221;
        s0222;
        s0223;
        s0231;
        s0232;
        s0233;
        s0311;
        s0312;
        s0313;
        s0321;
        s0322;
        s0323;
        s0331;
        s0332;
        s0333;
        s0411;
        s0412;
        s0413;
        s0421;
        s0422;
        s0423;
        s0431;
        s0432;
        s0433;
        s0511;
        s0512;
        s0513;
        s0521;
        s0522;
        s0523;
        s0531;
        s0532;
        s0533;
        C111;
        C112;
        C113;
        C114;
        C121;
        C122;
        C123;
        C124;
        C131;
        C132;
        C133;
        C134;
        C141;
        C142;
        C143;
        C144;
        C151;
        C152;
        C153;
        C154;
        C161;
        C162;
        C163;
        C164;
        C171;
        C172;
        C173;
        C174;
        C211;
        C212;
        C213;
        C214;
        C221;
        C222;
        C223;
        C224;
        C231;
        C232;
        C233;
        C234;
        C241;
        C242;
        C243;
        C244;
        C251;
        C252;
        C253;
        C254;
        C261;
        C262;
        C263;
        C264;
        C271;
        C272;
        C273;
        C274;
        C311;
        C312;
        C313;
        C314;
        C321;
        C322;
        C323;
        C324;
        C331;
        C332;
        C333;
        C334;
        C341;
        C342;
        C343;
        C344;
        C351;
        C352;
        C353;
        C354;
        C361;
        C362;
        C363;
        C364;
        C371;
        C372;
        C373;
        C374;
       // dice face attributes
        s0111a;
        s0112a;
        s0113a;
        s0121a;
        s0122a;
        s0123a;
        s0131a;
        s0132a;
        s0133a;
        s0211a;
        s0212a;
        s0213a;
        s0221a;
        s0222a;
        s0223a;
        s0231a;
        s0232a;
        s0233a;
        s0311a;
        s0312a;
        s0313a;
        s0321a;
        s0322a;
        s0323a;
        s0331a;
        s0332a;
        s0333a;
        s0411a;
        s0412a;
        s0413a;
        s0421a;
        s0422a;
        s0423a;
        s0431a;
        s0432a;
        s0433a;
        s0511a;
        s0512a;
        s0513a;
        s0521a;
        s0522a;
        s0523a;
        s0531a;
        s0532a;
        s0533a;
        C111A;
        C112A;
        C113A;
        C114A;
        C121A;
        C122A;
        C123A;
        C124A;
        C131A;
        C132A;
        C133A;
        C134A;
        C141A;
        C142A;
        C143A;
        C144A;
        C151A;
        C152A;
        C153A;
        C154A;
        C161A;
        C162A;
        C163A;
        C164A;
        C171A;
        C172A;
        C173A;
        C174A;
        C211A;
        C212A;
        C213A;
        C214A;
        C221A;
        C222A;
        C223A;
        C224A;
        C231A;
        C232A;
        C233A;
        C234A;
        C241A;
        C242A;
        C243A;
        C244A;
        C251A;
        C252A;
        C253A;
        C254A;
        C261A;
        C262A;
        C263A;
        C264A;
        C271A;
        C272A;
        C273A;
        C274A;
        C311A;
        C312A;
        C313A;
        C314A;
        C321A;
        C322A;
        C323A;
        C324A;
        C331A;
        C332A;
        C333A;
        C334A;
        C341A;
        C342A;
        C343A;
        C344A;
        C351A;
        C352A;
        C353A;
        C354A;
        C361A;
        C362A;
        C363A;
        C364A;
        C371A;
        C372A;
        C373A;
        C374A;
       end-ds;
 
       //---------------------------------------------------------
       scDow = f_GetDayName();
       f_RmvSflMsg(ProgId);
 
       exsr srNewStart;
       // Load initial splash screen to get game started
       Face(1).Row(*) = f_LoadFace('Y');
       Face(2).Row(*) = f_LoadFace('A');
       Face(3).Row(*) = f_LoadFace('H');
       Face(4).Row(*) = f_LoadFace('T');
       Face(5).Row(*) = f_LoadFace('Z');
       BorderA(*) = Green;
 
 1b    for DiceNum = 1 to 5;
 2b       if DiceNum = 1 or DiceNum = 5;
             Color = %bitor(Red: RI);
 2x       elseif DiceNum = 2;
             Color = %bitor(White: RI);
 2x       elseif DiceNum = 3;
             Color = %bitor(Yellow: RI);
 2x       elseif DiceNum = 4;
             Color = %bitor(Blue:RI);
 2e       endif;
          // load Dice colors
 2b       for row = 1 to 3;
 3b          for col = 1 to 3;
 4b             if Face(DiceNum).Row(row).Col(col) > ' ';
                   FaceAttr(DiceNum).Row(row).Col(col) = Color;
 4e             endif;
 3e          endfor;
 2e       endfor;
 1e    endfor;
 
       // initially protect selections
       BucketArryAtr(*) = %bitor(ND: PR);
       ThreeShots = 0;
       pCount = 0;
       exsr srColorRollCnt;
 
       // show splash screen
       exfmt screen;
 1b    if InfdsFkey = f03 or InfdsFkey = f12;
          *inlr = *on;
          return;
 1e    endif;
       BorderA(*) = Green;
       exsr srNewStart;
 
       //---------------------------------------------------------
       // Play the game
 1b    dou 1 = 2;
 2b       for ThreeShots = 1 to 3;
             exsr srColorRollCnt;
 
 3b          if ThreeShots = 1;
                DiscardArry(*) = *blanks;
                Ind.ScreenCtl = *on;
 3x          elseif ThreeShots = 3;
                Ind.ScreenCtl = *off;
 3e          endif;
 
 3b          if pCount = 13; // all selected
                exsr srShowFinalScore;
 3x          else;
                exsr srRollDaBones;
                exsr srCalcTotals;
 
     C     fixerror      tag
 
 4b             if ThreeShots = 3;
                   f_SndSflMsg(ProgId: 'Select a section category');
 4e             endif;
 3e          endif;
 
             write msgctl;
             exfmt screen;
             f_RmvSflMsg(ProgId);
 3b          if InfdsFkey = f03 or InfdsFkey = f12;
                *inlr = *on;
                return;
 
 3x          elseif InfdsFkey = F05
                or pCount = 13;
                exsr srNewStart;
 2v             leave;
 3e          endif;
 
             // See if any selection has been 'X'ed thus ending turn
             // If player tries to X multiple categories, use first X.
             IsOneXed = *off;
 3b          for xx = 1 to 13;
 4b             if ProtectArry(xx) <> 'P'; // protected
 5b                if XbucketArry(xx) > ' ';
 6b                   if IsOneXed;
                         XbucketArry(xx) = *blanks;
 6e                   endif;
                      IsOneXed = *on;
 5e                endif;
 4e             endif;
 3e          endfor;
 
 3b          if Threeshots = 3 and not IsOneXed;
                f_SndSflMsg(ProgId: 'Must select category after three rolls');
 GO  C                   goto      fixerror
 3e          endif;
 
 3b          for xx = 1 to 13;
 4b             if xBucketArry(xx) > ' ';
                   xBucketArry(xx) = ' ';
                   ProtectArry(xx) = 'P';
                   BucketArryAtr(xx) = %bitor(ND: PR);
                   TextArryAtr(xx) = %bitor(Blue: RI);
                   TotArryAtr(xx) = %bitor(Blue: RI);
                   Text2ArryAtr(xx) = Blue;
 4e             endif;
 3e          endfor;
 
 3b          if IsOneXed;
 2v             leave;
 3e          endif;
 2e       endfor;
 
          // get grand total for protected totals
 2b       if InfdsFkey <> F05;
             TotGrand = 0;
             TotUpper = 0;
             TotBonus = 0;
             pCount = 0;
 3b          for xx = 1 to 13;
 4b             if ProtectArry(xx) = 'P';
                   pCount += 1;
                   TotGrand += TotArry(xx);
 5b                if xx < 7;
                      TotUpper += TotArry(xx);
 5e                endif;
 4e             endif;
 3e          endfor;
 3b          if TotUpper >= 63;
                TotBonus = 35;
                TotGrand += 35;
 3e          endif;
 2e       endif;
 1e    enddo;
 
       //---------------------------------------------------------
       // Show final score in large characters
       //  Using roll count as hundreds digit, then two other
       //   large characters for 10s and 1s.
       //---------------------------------------------------------
       begsr srShowFinalScore;
       RollMsg = 'Final Score';
       Ind.ScreenCtl = *off;
       f_SndSflMsg(ProgId: 'Game Over - Press F5 for new game');
       Ind.ScreenCtl = *off;
       evalr TotgrandA = '000' + %char(TotGrand);
       ThreeShots = %dec(%subst(TotGrandA:3:1) :1 :0);
       exsr srColorRollCnt;
 
       LargeGrand1s(*) = RollCnt(*);
       LargeGrand1sA(*) = RollCntA(*);
       ThreeShots = %dec(%subst(TotGrandA:2:1) :1 :0);
       exsr srColorRollCnt;
 
       LargeGrand10s(*) = RollCnt(*);
       LargeGrand10sA(*) = RollCntA(*);
       ThreeShots = %dec(%subst(TotGrandA:1:1) :1 :0);
       exsr srColorRollCnt;
       endsr;
 
       //---------------------------------------------------------
       // Throw dice to replace dice user has X ed.
       // To make game a bit easier,  if roll is exact same number
       // as before, roll again to give a new number.
       //---------------------------------------------------------
       begsr srRollDaBones;
 1b    if ThreeShots = 1;
          UserDice(*) = 0;
 1e    endif;
 1b    for Throw = 1 to 5;
 2b       if DiscardArry(Throw) > ' '
             or ThreeShots = 1;
             OriginalDice = UserDice(Throw);
 
 3b          dou UserDice(Throw) <> OriginalDice;
                UserDice(Throw) = f_GetRandom(6);
 3e          enddo;
 2e       endif;
 1e    endfor;
 
       sorta UserDice;
       exsr srLoadUserScreen;
       DiscardArry(*) = *blanks;
       endsr;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srColorRollCnt;
       RollCnt = f_LoadRollCnt(ThreeShots);
 1b    for row = 1 to 7;
 2b       for col = 1 to 4;
 3b          if RollCnt(row).Col(col) > ' ';
                RollCntA(row).Col(col) = %bitor(Blue: RI);
 3x          else;
                RollCntA(row).Col(col) = ND;
 3e          endif;
 2e       endfor;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // Load Dice images to screen.
       // Mostly concerned with loading proper headings, messages, and setting indicators.
       //---------------------------------------------------------
       begsr srLoadUserScreen;
 1b    for DiceNum = 1 to 5;
          Face(DiceNum) = *blanks;
          FaceAttr(DiceNum) = ND;
          Face(DiceNum).Row(*) = f_LoadFace(%char(UserDice(DiceNum)));
 2b       for row = 1 to 3;
 3b          for col = 1 to 3;
 4b             if Face(DiceNum).Row(row).Col(col) > ' ';
 5b                if UserDice(DiceNum) = 1;
                      FaceAttr(DiceNum).Row(row).Col(col) = %bitor(White: RI);
 5x                elseif UserDice(DiceNum) = 2;
                      FaceAttr(DiceNum).Row(row).Col(col) = %bitor(Yellow: RI);
 5x                elseif UserDice(DiceNum) = 3;
                      FaceAttr(DiceNum).Row(row).Col(col) = %bitor(Green: RI);
 5x                elseif UserDice(DiceNum) = 4;
                      FaceAttr(DiceNum).Row(row).Col(col) = %bitor(Pink: RI);
 5x                elseif UserDice(DiceNum) = 5;
                      FaceAttr(DiceNum).Row(row).Col(col) = %bitor(Red: RI);
 5x                elseif UserDice(DiceNum) = 6;
                      FaceAttr(DiceNum).Row(row).Col(col) = %bitor(Blue: RI);
 5e                endif;
 4e             endif;
 3e          endfor;
 2e       endfor;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // See what will score!
       //---------------------------------------------------------
       begsr srCalcTotals;
       SumAllDots = %xfoot(UserDice);
       IsScoreArry(*) = *off;
       IsChance = *on;
       SumArry(*) = 0;
       CalcChance = SumAllDots;
 
       // Check for large straight of 5
       DiceNum = 1;
 1b    if UserDice(DiceNum) = UserDice(DiceNum + 1) -1
          and UserDice(DiceNum) = UserDice(DiceNum + 2) -2
          and UserDice(DiceNum) = UserDice(DiceNum + 3) -3
          and UserDice(DiceNum) = UserDice(DiceNum + 4) -4;
          IsRunOf5s = *on;
          IsRunOf4s = *on;
 1e    endif;
 
       //---------------------------------------------------------
       // Check for small straight of 4
       // Small straight is complicated by the need
       // to remove one dice in hand from consideration.
       // Example 1 2 2 3 4
       // Exclude one of the 2s to check for straight.
       //  Remove dice 1 through 5 then check remaining 4 dice for a straight.
       //---------------------------------------------------------
 1b    if not IsRunOf5s;
 2b       for DropDice = 1 to 5;
             yy = 0;
 3b          for xx = 1 to 5;
 4b             if xx <> DropDice;
                   yy += 1;
                   FourDice(yy) = UserDice(xx);
 4e             endif;
 3e          endfor;
 3b          if FourDice(1) = FourDice(2) -1
                and FourDice(1) = FourDice(3) -2
                and FourDice(1) = FourDice(4) -3;
                IsRunOf4s = *on;
 2v             leave;
 3e          endif;
 2e       endfor;
 1e    endif;
 1b    if IsRunof5s;
          CalcRunof5s = 40;
 1e    endif;
 1b    if IsRunof4s;
          CalcRunof4s = 30;
 1e    endif;
 
       //---------------------------------------------------------
       // 5 of a kind or Yahtzee
       //---------------------------------------------------------
       DiceNum = 1;
 1b    if UserDice(DiceNum) = UserDice(DiceNum + 1)
          and UserDice(DiceNum) = UserDice(DiceNum + 2)
          and UserDice(DiceNum) = UserDice(DiceNum + 3)
          and UserDice(DiceNum) = UserDice(DiceNum + 4);
          IsYahtzee = *on;
          Is4ofaKind = *on;
          Is3ofaKind = *on;
 1e    endif;
 
       //---------------------------------------------------------
       // 4 of a kind
       //---------------------------------------------------------
 1b    if not IsYahtzee;
 2b       for DiceNum = 1 to 2;
 3b          if UserDice(DiceNum) = UserDice(DiceNum + 1)
                and UserDice(DiceNum) = UserDice(DiceNum + 2)
                and UserDice(DiceNum) = UserDice(DiceNum + 3);
                Is4ofaKind = *on;
                Is3ofaKind = *on;
 2v             leave;
 3e          endif;
 2e       endfor;
 
          //---------------------------------------------------------
          // 3 of a kind
 2b       if not Is4ofaKind;
 3b          for DiceNum = 1 to 3;
 4b             if UserDice(DiceNum) = UserDice(DiceNum + 1)
                   and UserDice(DiceNum) = UserDice(DiceNum + 2);
                   Is3ofaKind = *on;
 3v                leave;
 4e             endif;
 3e          endfor;
 2e       endif;
 1e    endif;
 
 1b    if Is3ofaKind;
          Calc3ofaKind = SumAllDots;
 1e    endif;
 1b    if Is4ofaKind;
          Calc4ofaKind = SumAllDots;
 1e    endif;
 1b    if IsYahtzee;
          CalcYahtzee = 50;
 1e    endif;
 
       //---------------------------------------------------------
       // Check for Full House.  If first 2 match then last 3 must match
       // or first 3 match then last 2 must match.
       //---------------------------------------------------------
 1b    if (UserDice(1) = UserDice(2)
          and UserDice(3) = UserDice(4)
          and UserDice(3) = UserDice(5))
          and UserDice(1) <> UserDice(5)
          or
          (UserDice(1) = UserDice(2)
          and UserDice(1) = UserDice(3)
          and UserDice(4) = UserDice(5))
          and UserDice(1) <> UserDice(5);
          IsFullHouse = *on;
          CalcFullHouse = 25;
 1e    endif;
 
       //---------------------------------------------------------
       // Check for upper section numbers
       //---------------------------------------------------------
 1b    for DiceNum = 1 to 5;
 2b       if UserDice(DiceNum) = 1;
             IsOnes = *on;
             CalcOnes += 1;
 2x       elseif UserDice(DiceNum) = 2;
             IsTwos = *on;
             CalcTwos += 2;
 2x       elseif UserDice(DiceNum) = 3;
             IsThrees = *on;
             CalcThrees += 3;
 2x       elseif UserDice(DiceNum) = 4;
             IsFours = *on;
             CalcFours += 4;
 2x       elseif UserDice(DiceNum) = 5;
             IsFives = *on;
             CalcFives += 5;
 2x       elseif UserDice(DiceNum) = 6;
             IsSixes = *on;
             CalcSixes += 6;
 2e       endif;
 1e    endfor;
 
       //---------------------------------------------------------
       // now figure out what can score
       //---------------------------------------------------------
 1b    for xx = 1 to 13;
 2b       if ProtectArry(xx) <> 'P';
 3b          if IsScoreArry(xx);
                TotArry(xx) = SumArry(xx);
                BucketArryAtr(xx) = %bitor(White: UL);
                TextArryAtr(xx) = White;
                TotArryAtr(xx) = White;
                Text2ArryAtr(xx) = White;
 3x          else;
                TotArry(xx) = 0;
                BucketArryAtr(xx) = x'00';
                TextArryAtr(xx) = x'00';
                TotArryAtr(xx) = x'00';
                Text2ArryAtr(xx) = x'00';
 3e          endif;
 2e       endif;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       begsr srNewStart;
       RollMsg = 'Roll Count';
       ProtectArry(*) = *blanks;
       BucketArryAtr(*) = x'00';
       TextArryAtr(*) = x'00';
       TotArryAtr(*) = x'00';
       Text2ArryAtr(*) = x'00';
       XbucketArry(*) = *blanks;
       TotGRAND = 0;
       TotUpper = 0;
       TotBonus = 0;
 
 1b    for row = 1 to 7;
          LargeGrand10s(row).Col(*) = ND;
          LargeGrand1s(row).Col(*) = ND;
          RollCntA(row).Col(*) = ND;
 1e    endfor;
 
       TotArry(*) = 0;
       pCount = 0;
       endsr;
 
       //---------------------------------------------------------
       // Return 4 column X 7 row array of roll count number
       //---------------------------------------------------------
       dcl-proc f_LoadRollCnt;
        dcl-pi *n char(4) dim(7);
         pBaseNum uns(3);
        end-pi;
        dcl-s Line char(4) dim(7);
 
 1b     if pBaseNum = 3;
           Line(1) = '333 ';
           Line(2) = '   3';
           Line(3) = '   3';
           Line(4) = ' 333';
           Line(5) = '   3';
           Line(6) = '   3';
           Line(7) = '333 ';
 1x     elseif pBaseNum = 2;
           Line(1) = '222 ';
           Line(2) = '   2';
           Line(3) = '   2';
           Line(4) = ' 22 ';
           Line(5) = '2   ';
           Line(6) = '2   ';
           Line(7) = '2222';
 1x     elseif pBaseNum = 1;
           Line(*) = '  1';
           Line(1) = ' 11 ';
           Line(7) = ' 111';
 1x     elseif pBaseNum = 0;
           Line(*) = '0  0';
           Line(1) = ' 00 ';
           Line(7) = ' 00 ';
 1x     elseif pBaseNum = 9;
           Line(1) = '9999';
           Line(2) = '9  9';
           Line(3) = '9  9';
           Line(4) = '9999';
           Line(5) = '   9';
           Line(6) = '   9';
           Line(7) = '9999';
 1x     elseif pBaseNum = 8;
           Line(*) = '8  8';
           Line(1) = '8888';
           Line(4) = '8888';
           Line(7) = '8888';
 1x     elseif pBaseNum = 7;
           Line(1) = '7777';
           Line(2) = '   7';
           Line(3) = '   7';
           Line(4) = '  7 ';
           Line(5) = ' 7  ';
           Line(6) = '7   ';
           Line(7) = '7   ';
 1x     elseif pBaseNum = 6;
           Line(1) = '6666';
           Line(2) = '6   ';
           Line(3) = '6   ';
           Line(4) = '6666';
           Line(5) = '6  6';
           Line(6) = '6  6';
           Line(7) = '6666';
 1x     elseif pBaseNum = 5;
           Line(1) = '5555';
           Line(2) = '5   ';
           Line(3) = '5   ';
           Line(4) = '5555';
           Line(5) = '   5';
           Line(6) = '   5';
           Line(7) = '5555';
 1x     elseif pBaseNum = 4;
           Line(1) = '  44';
           Line(2) = ' 4 4';
           Line(3) = '4  4';
           Line(4) = '4444';
           Line(5) = '   4';
           Line(6) = '   4';
           Line(7) = '   4';
 1e     endif;
        return Line;
       end-proc;
 
       //---------------------------------------------------------
       // Return 3 X 3 array of dice face
       //---------------------------------------------------------
       dcl-proc f_LoadFace;
        dcl-pi *n char(3) dim(3);
         pBaseNum char(1) const;
        end-pi;
        dcl-s Line char(3) dim(3);
 
 1b     if pBaseNum = '6';
           Line(1) = '666';
           Line(2) = '   ';
           Line(3) = '666';
 1x     elseif pBaseNum = '5';
           Line(1) = '5 5';
           Line(2) = ' 5 ';
           Line(3) = '5 5';
 1x     elseif pBaseNum = '4';
           Line(1) = '4 4';
           Line(2) = '   ';
           Line(3) = '4 4';
 1x     elseif pBaseNum = '3';
           Line(1) = '3  ';
           Line(2) = ' 3 ';
           Line(3) = '  3';
 1x     elseif pBaseNum = '2';
           Line(1) = '2  ';
           Line(2) = '   ';
           Line(3) = '  2';
 1x     elseif pBaseNum = '1';
           Line(1) = '   ';
           Line(2) = ' 1 ';
           Line(3) = '   ';
 1x     elseif pBaseNum = 'Y';
           Line(1) = 'Y Y';
           Line(2) = ' Y ';
           Line(3) = ' Y ';
 1x     elseif pBaseNum = 'A';
           Line(1) = ' A ';
           Line(2) = 'A A';
           Line(3) = 'A A';
 1x     elseif pBaseNum = 'H';
           Line(1) = 'H H';
           Line(2) = 'HHH';
           Line(3) = 'H H';
 1x     elseif pBaseNum = 'T';
           Line(1) = 'TTT';
           Line(2) = ' T ';
           Line(3) = ' T ';
 1x     elseif pBaseNum = 'Z';
           Line(1) = 'ZZ ';
           Line(2) = ' Z ';
           Line(3) = ' ZZ';
 1e     endif;
        return Line;
       end-proc;
