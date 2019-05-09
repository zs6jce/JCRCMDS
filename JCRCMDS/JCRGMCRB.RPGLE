       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRGMCRB - Cribbage
       //---------------------------------------------------------
       /define ControlStatements
       /define Dspatr
       /define FunctionKeys
       /define f_GetCardFace
       /define f_GetCardColor
       /define f_ShuffleDeck
       /define f_GetDayName
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRGMCRBD workstn infds(infds) indds(ind) sfile(sbfdta1: rrn);
       dcl-ds Infds;
        InfdsFkey char(1) pos(369);
       end-ds;
 
       dcl-s NextStepFlg char(31);
       dcl-s ShowScoreSbf char(3);
       dcl-s srCraigStat char(30);
       dcl-s srUserStat char(30);
       dcl-s WhoPlayed char(5) inz('Craig');
       dcl-s WhoPlayedLast char(3);
       dcl-s CurrentCard uns(3);
       dcl-s ab uns(3);
       dcl-s ac uns(3);
       dcl-s ad uns(3);
       dcl-s ah uns(3);
       dcl-s AllGroupings uns(3) dim(8);
       dcl-s an uns(3);
       dcl-s ax uns(3);
       dcl-s ay uns(3);
       dcl-s az uns(3);
       dcl-s BestA uns(3);
       dcl-s BestB uns(3);
       dcl-s BestC uns(3);
       dcl-s BestD uns(3);
       dcl-s BestDiscard1 uns(3);
       dcl-s BestDiscard2 uns(3);
       dcl-s BestScore uns(3);
       dcl-s ByHowMuch uns(3);
       dcl-s CardCount uns(3);
       dcl-s CardsToScore uns(3);
       dcl-s Check uns(3);
       dcl-s Deal uns(3);
       dcl-s HandScore uns(3);
       dcl-s NxtPlayC uns(3);
       dcl-s NxtPlayCard uns(3);
       dcl-s NxtPlayU uns(3);
       dcl-s PickHighCard uns(3);
       dcl-s PlayAbleCnt uns(3);
       dcl-s PlayThisCard uns(3);
       dcl-s RemainingCnt uns(3);
       dcl-s rrn uns(3);
       dcl-s RunningTot uns(3);
       dcl-s sbfx uns(3);
       dcl-s Sbfxb uns(3);
       dcl-s sFifteens uns(3);
       dcl-s sFourOfKind uns(3);
       dcl-s sPairs uns(3);
       dcl-s sRunOf3s uns(3);
       dcl-s sRunOf4s uns(3);
       dcl-s sRunOf5s uns(3);
       dcl-s sRunOf6s uns(3);
       dcl-s sRunOf7s uns(3);
       dcl-s sThreeOfKind uns(3);
       dcl-s WhoseCrib uns(3);  // 1=Player 2=Craig
       dcl-s CraigLeadAny ind;
       dcl-s CraigLeadFive ind;
       dcl-s CraigLeadFour ind;
       dcl-s CraigLeadNine ind;
       dcl-s CraigLeadSix ind;
       dcl-s CraigLeadTen ind;
       dcl-s CraigLeadThree ind;
       dcl-s CraigLeadTwo ind;
       dcl-s IsCardSelected ind dim(6);
       dcl-s IsCraigCardPlayed ind dim(4); // what has been played
       dcl-s IsCraigGo ind;
       dcl-s IsCraigOut ind;  // Craig out of card
       dcl-s IsFlush ind;
       dcl-s IsFound ind;
       dcl-s IsGameOver ind;  // we have a winner
       dcl-s IsGO ind;
       dcl-s IsLoadGraph ind;
       dcl-s IsOver31 ind;
       dcl-s IsPickBest ind;  // Craig play logic
       dcl-s IsUserCardPlayed ind dim(4);
       dcl-s IsUserGo ind;
       dcl-s IsUserOut ind;  // user out of cards
       dcl-s DiscardX char(1) dim(6) based(ptr7);
       dcl-s ptr7 pointer inz(%addr(discard1));
       dcl-c QuoteMark const('''');
 
       // card face 3d array
       dcl-ds Face dim(4) qualified based(ptr1);
        row likeds(RowDsx) dim(3);
       end-ds;
 
       dcl-ds RowDsx qualified;
        col char(2) dim(4);
       end-ds;
       dcl-s ptr1 pointer inz(%addr(chand11));
 
       // screen field attributes 3d array
       dcl-ds Attr dim(4) qualified based(ptr2);
        row likeds(RowDsy) dim(3);
       end-ds;
 
       dcl-ds RowDsy qualified;
        col char(1) dim(4);
       end-ds;
       dcl-s ptr2 pointer inz(%addr(chand11a));
 
       // cards Craig will play 2d array
       dcl-ds PlayCraig dim(3) qualified based(ptr3);
        col char(2) dim(4);
       end-ds;
       dcl-s ptr3 pointer inz(%addr(Play11));
 
       dcl-ds PlayCraigA dim(3) qualified based(ptr4);
        col char(1) dim(4);
       end-ds;
       dcl-s ptr4 pointer inz(%addr(Play11a));
 
       // cards user will play 2d array
       dcl-ds PlayUser dim(3) qualified based(ptr5);
        col char(2) dim(4);
       end-ds;
       dcl-s ptr5 pointer inz(%addr(Play15));
 
       dcl-ds PlayUserA dim(3) qualified based(ptr6);
        col char(1) dim(4);
       end-ds;
       dcl-s ptr6 pointer inz(%addr(Play15a));
 
       // name screen indicators
       dcl-ds ind qualified;
        sfldsp ind pos(01);
        sfldspctl ind pos(02);
        Play1stCard ind pos(10);
        Play2ndCard ind pos(20);
        Play3rdCard ind pos(30);
        Play4thCard ind pos(40);
        PlayMsg ind pos(45);
        Play5thCard ind pos(50);
        Play6thCard ind pos(60);
        CribMsgCraig ind pos(70);
        CribMsgUser ind pos(71);
        ColrBarCraig ind pos(72);
        ColrBarUser ind pos(73);
        CraigSaysGo ind pos(74);
        UserSaysGo ind pos(75);
        BorderRed ind pos(76);
        BorderBlue ind pos(77);
       end-ds;
 
       dcl-ds indsav qualified;
        Play1stCard ind;
        Play2ndCard ind;
        Play3rdCard ind;
        Play4thCard ind;
       end-ds;
 
       dcl-ds *n;
        NewDeck char(2) dim(52);  // newly sorted deck
        NewCard uns(3) overlay(newdeck:1);
        NewSuite char(1) overlay(newdeck:*next);
       end-ds;
 
       dcl-ds *n;
        uDealt char(2) dim(6) ascend;  // users hand
        uFace uns(3) overlay(uDealt:1);
        uSuite char(1) overlay(uDealt:*next);
       end-ds;
 
       dcl-ds *n;
        uPlay4 char(2) dim(4) ascend;  // 4 cards to play
        uFace4 uns(3) overlay(uPlay4:1);
        uSuite4 char(1) overlay(uPlay4:*next);
       end-ds;
 
       dcl-ds *n;
        cDealt char(2) dim(6) ascend;  // Craigs hand
        cFace uns(3) overlay(cDealt:1);
        cSuite char(1) overlay(cDealt:*next);
       end-ds;
 
       dcl-ds *n;
        cPlay4 char(2) dim(4) ascend;  // 4 cards to play
        cFace4 uns(3) overlay(cPlay4:1);
        cSuite4 char(1) overlay(cPlay4:*next);
       end-ds;
 
       dcl-ds *n;
        CribCards char(2) dim(4) ascend inz;  // either crib
        CribFace uns(3) overlay(CribCards:1);
        CribSuite char(1) overlay(CribCards:*next);
       end-ds;
 
       dcl-ds *n;
        PlayIt char(2) dim(8);  // cards played
        pFace uns(3) overlay(PlayIt:1);
        pSuite char(1) overlay(PlayIt:*next);
       end-ds;
 
       dcl-ds BestIndexDS inz;
        BestIndexA uns(3);
        BestIndexB uns(3);
        BestIndexC uns(3);
        BestIndexD uns(3);
        BestArry uns(3) dim(4) pos(1);
       end-ds;
 
       // Craig hand AI and scoring variables
       dcl-ds *n;
        TstDeck char(2) dim(8) descend inz;  // work deck to compare
        TstCard uns(3) overlay(TstDeck:1);
        TstSuite char(1) overlay(TstDeck:*next);
       end-ds;
 
       dcl-ds *n;
        RunDeck char(2) dim(8) descend inz;  // drop when runs of
        RunCard uns(3) overlay(RunDeck:1);
       end-ds;
 
       dcl-ds *n;
        SavDeck char(2) dim(8);  // Original Deck
        SavCard uns(3) overlay(Savdeck:1) inz;
        SavSuite char(1) overlay(Savdeck:*next);
       end-ds;
 
       dcl-ds aIndex inz;
        a1 uns(3);
        a2 uns(3);
        a3 uns(3);
        a4 uns(3);
        a5 uns(3);
        a6 uns(3);
        a7 uns(3);
        IndexArry uns(3) dim(7) pos(1);
       end-ds;
 
       // load cards that scored to window
       dcl-ds sbfSC inz;  // scoring cards
        sbfSC1 char(2);
        sbfSC2 char(2);
        sbfSC3 char(2);
        sbfSC4 char(2);
        sbfSC5 char(2);
        sbfSCval char(2) dim(5) pos(1);
       end-ds;
 
       dcl-ds sbfSCa inz;  // scoring card attributes
        sbfSC1a char(1);
        sbfSC2a char(1);
        sbfSC3a char(1);
        sbfSC4a char(1);
        sbfSC5a char(1);
        sbfSCatr char(1) dim(5) pos(1);
       end-ds;
 
       // move bar graph to represent total scores
       dcl-ds BarCds inz;  // Craigs graph
        trackc1;
        trackc2;
        trackc3;
        BarCarry char(1) dim(120) pos(1);
       end-ds;
 
       dcl-ds BarUds inz;  // users graph
        tracku1;
        tracku2;
        tracku3;
        BarUarry char(1) dim(120) pos(1);
       end-ds;
 
       // map screen fields into DS so pointers to data can overlay
       dcl-ds *n;
        chand11a;
        chand12a;
        chand13a;
        chand14a;
        chand21a;
        chand22a;
        chand23a;
        chand24a;
        chand31a;
        chand32a;
        chand33a;
        chand34a;
        ccrib11a;
        ccrib12a;
        ccrib13a;
        ccrib14a;
        ccrib21a;
        ccrib22a;
        ccrib23a;
        ccrib24a;
        ccrib31a;
        ccrib32a;
        ccrib33a;
        ccrib34a;
        uhand11a;
        uhand12a;
        uhand13a;
        uhand14a;
        uhand21a;
        uhand22a;
        uhand23a;
        uhand24a;
        uhand31a;
        uhand32a;
        uhand33a;
        uhand34a;
        ucrib11a;
        ucrib12a;
        ucrib13a;
        ucrib14a;
        ucrib21a;
        ucrib22a;
        ucrib23a;
        ucrib24a;
        ucrib31a;
        ucrib32a;
        ucrib33a;
        ucrib34a;
        play11a;
        play12a;
        play13a;
        play14a;
        play21a;
        play22a;
        play23a;
        play24a;
        play31a;
        play32a;
        play33a;
        play34a;
        play15a;
        play16a;
        play17a;
        play18a;
        play25a;
        play26a;
        play27a;
        play28a;
        play35a;
        play36a;
        play37a;
        play38a;
        uhand15a;
        uhand16a;
        uhand25a;
        uhand26a;
        uhand35a;
        uhand36a;
        play11;
        play12;
        play13;
        play14;
        play21;
        play22;
        play23;
        play24;
        play31;
        play32;
        play33;
        play34;
        play15;
        play16;
        play17;
        play18;
        play25;
        play26;
        play27;
        play28;
        play35;
        play36;
        play37;
        play38;
        chand11;
        chand12;
        chand13;
        chand14;
        chand21;
        chand22;
        chand23;
        chand24;
        chand31;
        chand32;
        chand33;
        chand34;
        ccrib11;
        ccrib12;
        ccrib13;
        ccrib14;
        ccrib21;
        ccrib22;
        ccrib23;
        ccrib24;
        ccrib31;
        ccrib32;
        ccrib33;
        ccrib34;
        uhand11;
        uhand12;
        uhand13;
        uhand14;
        uhand21;
        uhand22;
        uhand23;
        uhand24;
        uhand31;
        uhand32;
        uhand33;
        uhand34;
        ucrib11;
        ucrib12;
        ucrib13;
        ucrib14;
        ucrib21;
        ucrib22;
        ucrib23;
        ucrib24;
        ucrib31;
        ucrib32;
        ucrib33;
        ucrib34;
        uhand15;
        uhand16;
        uhand25;
        uhand26;
        uhand35;
        uhand36;
        discard1;
        discard2;
        discard3;
        discard4;
        discard5;
        discard6;
       end-ds;
 
       scDow = f_GetDayName();
       //---------------------------------------------------------
       // load initial screen to show lots of pretty colors
       Face(*) = *all' ';
       Attr(*) = *allx'00';
 
 1b    for ah = 1 to 4;
          Attr(ah).Row(1).Col(*) = %bitor(RED: RI);
          Attr(ah).Row(2).Col(*) = %bitor(WHITE: RI);
          Attr(ah).Row(3).Col(*) = %bitor(BLUE: RI);
 1e    endfor;
 
       PlayCraig(*) = *blanks;
       PlayUser(*) = *blanks;
       PlayCraigA(1).Col(*) = %bitor(YELLOW: RI);
       PlayCraigA(2).Col(*) = %bitor(RED: RI);
       PlayCraigA(3).Col(*) = %bitor(GREEN: RI);
       PlayUserA(1).Col(*) = %bitor(YELLOW: RI);
       PlayUserA(2).Col(*) = %bitor(RED: RI);
       PlayUserA(3).Col(*) = %bitor(GREEN: RI);
       Deck1 = *blanks;
       Deck2 = *blanks;
       Deck3 = *blanks;
       Deck1A = %bitor(YELLOW: RI);
       Deck2A = %bitor(RED: RI);
       Deck3A = %bitor(GREEN: RI);
 
       // --load bar graphs--
       BarCArry(*) = 'R';  //red
       BarUArry(*) = 'B';  //blue
       barccnt = 120;
       barucnt = 120;
       u121 = *blanks;
       c121 = *blanks;
       runningtot = 31;
       ind.CribMsgCraig = *on;
       ind.CribMsgUser = *on;
       ind.ColrBarCraig = *off;
       ind.ColrBarUser = *off;
       ind.PlayMsg = *off;
       PlayMsg = *blanks;
       UserMsg = 'Press Enter to begin!';
 
       exfmt screen;
       exsr srCheckExit;
 
       // Initialize stuff for new game to begin
       WhoseCrib = 2;  //player 1st crib
       barucnt = 0;
       barccnt = 0;
       u121 = *blanks;
       c121 = *blanks;
       IsGameOver = *off;
       barCds = *all'.';
       barUds = *all'.';
       ind.CribMsgCraig = *off;
       ind.CribMsgUser = *off;
       ind.ColrBarCraig = *off;
       ind.ColrBarUser = *off;
       ind.CraigSaysGo = *off;
       ind.UserSaysGo = *off;  //user GO flag
       exsr srNextHand;
       exsr srUserDealt;
 
       //---------------------------------------------------------
       // Play the game.  logic for non-linear game. Displays and logic depend
       // on where in play, what card values, who went first last time.
       // Use a flag concept to keep track of what is happening.
       //---------------------------------------------------------
 1b    dou 1 = 2;
 2b       if NextStepFlg = 'Craig Plays a Card'
             or NextStepFlg = 'Play Craig 1st card';
 2x       else;
             exfmt screen;
 2e       endif;
 2b       if InfdsFkey = f03 or InfdsFkey = f12;
 1v          leave;
 2e       endif;
          usermsga = *blanks;
          UserMsg = *blanks;
 
          //---------------------------------------------------------
          // Show users hand and prompt selection of discards.
          // User discard editing and beginning game play.
          //---------------------------------------------------------
 2b       if NextStepFlg = 'Show User Discard Screen';
             exsr srUserDealt;
 2x       elseif NextStepFlg = 'Edit Discard Selection';
             exsr srUserDiscard;
 
             //---------------------------------------------------------
             // Use savant subroutines to do simple steps (or not so simple).
             // They will report status back of what they did and all grim complicated
             //  control logic is here.
             // ------------------------------
             // GO logic. If person can play card, check other players hand for GO
             // condition. If found, set flag and allow current person to continue.
             // ------------------------------
             // User plays card.
             // 1).  Craig has cards but 2) cannot play without going over 31.
             // Set on Craig go message.
             // Allow user to play another card.
             // user plays until 1)runs out of cards 2)makes 31  3)not play without over 31.
             // At end of one these sequences,
             // give user GO for 1, reset play, let Craig play next card.
             // ------------------------------
             // Craig plays card.
             // 1) User has cards but 2) cannot play without going over 31.
             // set on user GO message.
             // FRCWTR and allow Craig to spin through playing all possible cards until
             // 1)runs out of cards 2)makes 31  3)not play without over 31.
             // At end of one these sequences,
             // give Craig GO for 1, reset play, let user play next card.
             // ------------------------------
             // Special circumstance
             // If Craig is out of cards and user cannot play, still give Craig
             // a GO for 1 to reset deck count.
             // or vice versa if user is out of cards and Craig cannot play.
             //---------------------------------------------------------
 2x       elseif NextStepFlg = 'Craig Plays a Card';
             exsr srCraigPlay;
             WhoPlayed = 'Craig';
 
 3b          if NextStepFlg = 'Edit Discard Selection';  //HAND OVER
 
                //user at GO /Craig has cards /Craig can still play
 3x          elseif IsUserGo and      //User cannot play
                (not IsCraigOut) and   //Craig has cards
                (not IsCraigGo);  //Craig has cards
                NextStepFlg = 'Craig Plays a Card';
                write screen;
 
                //user at GO /Craig has cards /Craig cannot play
 3x          elseif IsUserGo and       //User cannot play
                (not IsCraigOut) and   //Craig has cards
                IsCraigGo;  //Craig cannot play
                ind.CraigSaysGo = *off;
                IsGO = *on;
                exsr srScorePlayed;
                IsGO = *off;
                NextStepFlg = 'User Selects a Card for Play';
 
                // - user at GO / Craig has no cards
 3x          elseif IsUserGo and       //User cannot play
                IsCraigOut;  //Craig played all
                ind.CraigSaysGo = *off;
                IsGO = *on;
                exsr srScorePlayed;
                IsGO = *off;
                NextStepFlg = 'User Selects a Card for Play';
 
                // - Craig played normally or Craig played last card
 3x          elseif srCraigStat = 'Craig Played Card OK'
                or IsCraigOut;  //Craig played all
                ind.CraigSaysGo = *off;
                NextStepFlg = 'User Selects a Card for Play';
 3e          endif;
 
             //---------------------------------------------------------
             // USER selects card for play
             //---------------------------------------------------------
 2x       elseif NextStepFlg = 'User Selects a Card for Play';
             exsr srUserPlay;
             WhoPlayed = 'You';
 
 3b          if NextStepFlg = 'Edit Discard Selection';  //HAND OVER
 
                //---------------------------------------------------------
                // Check for error messages
                //---------------------------------------------------------
                // picked card with too high face value
 3x          elseif srUserStat = 'Over 31. Select a lower card.';
                usermsga = %bitor(GREEN: RI);
                UserMsg = 'Over 31. Select lower card';
                NextStepFlg = 'User Selects a Card for Play';
 
                // must select one card
 3x          elseif srUserStat = 'User must select 1 card';
                usermsga = %bitor(GREEN: RI);
                UserMsg = 'Select 1 card to Play.    ';
                NextStepFlg = 'User Selects a Card for Play';
 
                //Craig at GO /User has cards /User can play
 3x          elseif IsCraigGo and      //Craig cannot play
                (not IsCraigOut) and   //Craig has cards
                (not IsUserOut) and   //User has cards
                (not IsUserGo);  //User can play
                NextStepFlg = 'User Selects a Card for Play';
 
                //Craig at GO /User has cards /User cannot play
 3x          elseif IsCraigGo and       //Craig cannot play
                (not IsCraigOut) and   //Craig has cards
                (not IsUserOut) and   //User has cards
                IsUserGo;  //User cannot play
                ind.UserSaysGo = *off;
                IsGO = *on;
                exsr srScorePlayed;
                IsGO = *off;
                NextStepFlg = 'Craig Plays a Card';
 
                //Craig at GO /User has played all cards
 3x          elseif IsCraigGo and       //Craig cannot play
                (not IsCraigOut) and   //Craig has cards
                IsUserOut;  //User played all card
                ind.UserSaysGo = *off;
                IsGO = *on;
                exsr srScorePlayed;
                IsGO = *off;
                NextStepFlg = 'Craig Plays a Card';
                // - user played normally or played last card
 3x          elseif srUserStat = 'User Played Card OK'
                or IsUserOut;  //User has no cards
                NextStepFlg = 'Craig Plays a Card';
 3e          endif;
 
             //---------------------------------------------------------
             // Strategy for Craig to pick 1st card to play
             //---------------------------------------------------------
 2x       elseif NextStepFlg = 'Play Craig 1st card';
             exsr srCraigLead1st;  //play Craig 1st card
 2e       endif;
          srCraigStat = *blanks;
          srUserStat = *blanks;
 1e    enddo;
       *inlr = *on;
       return;
       write assume;
 
       //---------------------------------------------------------
       // Craig selects and plays card.
       // Make sure Craig has any cards left.
       // Make sure Craigs selection will not go over 31.
       // Spin through all plays and find highest scoring play.
       //---------------------------------------------------------
       begsr srCraigPlay;
       srCraigStat = *blanks;
       exsr srChkAllPlayd;
 1b    if not IsCraigOut;
 
          //---------------------------------------------------------
          // See if Craig has any cards that will score 31.
          // If so select that card 1st.
          //---------------------------------------------------------
 2b       if RunningTot >= 21;
 3b          for ad = 1 to 4;
 4b             if not IsCraigCardPlayed(ad)
                   and f_KQJcount10(CFace4(ad)) + RunningTot = 31;
                   ah = 1;
                   PlayThisCard = ad;
                   WhoPlayed = 'Craig';
                   exsr srPlayOneCard;
                   exsr srScorePlayed;  //load message to scr
                   srCraigStat = 'Craig Played Card OK';
 3v                leave;
 4e             endif;
 3e          endfor;
 2e       endif;
 
 2b       if srCraigStat <> 'Craig Played Card OK';
             ah = 1;
 
             //---------------------------------------------------------
             // Pickbest
             // Craig has cards that will score less than 31.
             // One at a time load each card into playIt array
             // that will score less than 32 and check scores.
             // Card resulting in highest score is selected.
             // If nothing scores, play highest card.
             //---------------------------------------------------------
             NxtPlayCard += 1;
             PlayThisCard = 0;
             BestScore = 0;
             PickHighCard = 0;
             IsLoadGraph = *off;
             IsPickBest = *on;  //set flag to scoring subroutine
 
 3b          for ad = 1 to 4;
 4b             if not IsCraigCardPlayed(ad)
                   and f_KQJcount10(CFace4(ad)) + RunningTot < 32;
                   PlayIt(NxtPlayCard) = cPlay4(ad);
                   exsr srScorePlayed;  //score hand
                   exsr srGetBarScore;  //add total
 
 5b                if HandScore > BestScore;  //pick highest score
                      BestScore = HandScore;
                      PlayThisCard = ad;
 5e                endif;
 
 5b                if BestScore = 0 and CFace4(ad) > PickHighCard;               //pick highest card
                      PickHighCard = CFace4(ad);
                      PlayThisCard = ad;
 5e                endif;
 4e             endif;
 3e          endfor;
             //---------------------------------------------------------
             pface(NxtPlayCard) = 0;  //remove test card
             psuite(NxtPlayCard) = *blanks;  //remove test card
             NxtPlayCard -= 1;  //reset nxt play cnt
             IsPickBest = *off;  //flag to scoring subr
             IsLoadGraph = *on;
             WhoPlayed = 'Craig';
             exsr srPlayOneCard;
             exsr srScorePlayed;  //load message to scr
             srCraigStat = 'Craig Played Card OK';
 2e       endif;
 1e    endif;
       exsr srChkForGO;
       endsr;
 
       //---------------------------------------------------------
       // Move bar graph to reflect totals.
       //  Check for end of game / winner conditions.
       //---------------------------------------------------------
       begsr srMoveBarGraph;
       IsGameOver = *off;
 1b    if IsLoadGraph;
 2b       if HandScore > 0;
 3b          if WhoPlayed = 'Craig';  //Craig scored
                BarCcnt += HandScore;
 4b             if BarCcnt >= 121;  //Craig Won
                   BarCcnt = 121;
                   ByHowMuch = BarCcnt - BarUcnt;
                   ind.ColrBarCraig = *on;
                   c121 = 'X';
                   BarCds = *all'R';
                   IsGameOver = *on;
 4x             else;
 5b                for ab = 1 to BarCcnt;
                      barcarry(ab) = 'X';
 5e                endfor;
 4e             endif;
 3x          else;
                //---------------------------------------------------------
                BarUcnt += HandScore;
 4b             if BarUcnt >= 121;  //Craig Won
                   BarUcnt = 121;
                   ByHowMuch = BarUcnt - BarCcnt;  //difference for end
                   ind.ColrBarUser = *on;
                   u121 = 'X';
                   BarUds = *all'B';
                   IsGameOver = *on;
 4x             else;
 5b                for ab = 1 to BarUcnt;
                      barUarry(ab) = 'X';
 5e                endfor;
 4e             endif;
 3e          endif;
 2e       endif;
 1e    endif;
 
       //---------------------------------------------------------
       // If is a winner, stop game and show results.
       //---------------------------------------------------------
 1b    if IsGameOver;
          ind.PlayMsg = *on;
          PlayMsg = %trimr(WhoPlayed) +
          ' WON by ' +
          %triml(%editc(ByHowMuch:'4')) + ' .' +
          ' Thank you for good game.';
          ind.Play1stCard = *off;
          ind.Play2ndCard = *off;
          ind.Play3rdCard = *off;
          ind.Play4thCard = *off;
          ind.Play5thCard = *off;
          ind.Play6thCard = *off;
          usermsga = *blanks;
          usermsg = *blanks;
 
          exfmt screen;
          *inlr = *on;
          return;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // If running total > 21, check both hands to see if
       // either player can next play under 32.
       //---------------------------------------------------------
       begsr srChkForGO;
       IsCraigGo = *off;
       ind.CraigSaysGo = *off;
       IsUserGo = *off;
       ind.UserSaysGo = *off;
       PlayAbleCnt = 0;
       exsr srChkAllPlayd;
 
 1b    if RunningTot > 21;
 2b       if not IsUserOut;
 3b          for ad = 1 to 4;
 4b             if not IsUserCardPlayed(ad)
                   and f_KQJcount10(uFace4(ad)) + RunningTot < 32;
                   PlayAbleCnt += 1;
 3v                leave;
 4e             endif;
 3e          endfor;
 3b          if PlayAbleCnt = 0;  //GO button
                IsUserGo = *on;
                ind.UserSaysGo = *on;
 3e          endif;
 2e       endif;
          //---------------------------------------------------------
 2b       if not IsCraigOut;
             PlayAbleCnt = 0;
 3b          for ad = 1 to 4;
 4b             if not IsCraigCardPlayed(ad)
                   and f_KQJcount10(cFace4(ad)) + RunningTot < 32;
                   PlayAbleCnt += 1;
 3v                leave;
 4e             endif;
 3e          endfor;
 3b          if PlayAbleCnt = 0;  //GO button
                IsCraigGo = *on;
                ind.CraigSaysGo = *on;
 3e          endif;
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // play users selection
       //---------------------------------------------------------
       begsr srUserPlay;
       srUserStat = *blanks;
       exsr srChkAllPlayd;
 1b    if not IsUserOut;
 
          // Make sure user has selected single card
          ax = 0;
 2b       for ad = 1 to 4;
 3b          if Discardx(ad) > ' ';
                ax += 1;
                PlayThisCard = ad;
 3e          endif;
 2e       endfor;
 
 2b       if ax <> 1;
             srUserStat = 'User must select 1 card';
 2x       else;
             // User has cards that will play
 3b          if f_KQJcount10(uFace4(PlayThisCard)) + RunningTot > 31;
                srUserStat = 'Over 31. Select a lower card.';
 3x          else;
                //---------------------------------------------------------
                // Ok, user has got card to play and they have selected
                // one with total below 31.  Load card into arena.
                // remove X selection for that space.
                //---------------------------------------------------------
                ah = 3;
                exsr srPlayOneCard;
 4b             if ind.Play1stCard;
                   ind.Play1stCard = (1 <> PlayThisCard);
 4e             endif;
 4b             if ind.Play2ndCard;
                   ind.Play2ndCard = (2 <> PlayThisCard);
 4e             endif;
 4b             if ind.Play3rdCard;
                   ind.Play3rdCard = (3 <> PlayThisCard);
 4e             endif;
 4b             if ind.Play4thCard;
                   ind.Play4thCard = (4 <> PlayThisCard);
 4e             endif;
 
                // Score hand
                WhoPlayed = 'You';
                exsr srScorePlayed;  //load message to scr
                srUserStat = 'User Played Card OK';
 3e          endif;
             DiscardX(*) = *blanks;
 2e       endif;
 1e    endif;
       exsr srChkForGO;  //Check Craig GO
       endsr;
 
       //---------------------------------------------------------
       // Show users hand and prompt selection of discards
       //---------------------------------------------------------
       begsr srUserDealt;
       ind.Play1stCard = *on;
       ind.Play2ndCard = *on;
       ind.Play3rdCard = *on;
       ind.Play4thCard = *on;
       ind.Play5thCard = *on;
       ind.Play6thCard = *on;
       indsav.Play1stCard = *on;
       indsav.Play2ndCard = *on;
       indsav.Play3rdCard = *on;
       indsav.Play4thCard = *on;
       DiscardX(*) = *blanks;
       UserMsga = *blanks;
       UserMsg = 'Use X to select 2 cards to discard.';
       NextStepFlg = 'Edit Discard Selection';
       endsr;
 
       //---------------------------------------------------------
       // Make sure user has selected only 2 cards for discard.
       // Load and 'turn over' starting card.
       // Load discard into crib
       // Load 4 remaining cards into user hand array
       //---------------------------------------------------------
       begsr srUserDiscard;
       srUserStat = *blanks;
       ax = 0;
 1b    for ad = 1 to 6;
 2b       if DiscardX(ad) > ' ';
             ax += 1;
 2e       endif;
 1e    endfor;
 1b    if ax < 2
          or ax > 2;
          usermsga = %bitor(GREEN: RI);
          UserMsg = 'Use X to select 2 cards to discard.';
 1x    else;
          // 2 selected *
          usermsga = *blanks;
          UserMsg = 'X card to Play.';
          NextStepFlg = 'User Selects a Card for Play';
 
          // 'turn over' 13th card from deck to be to start card.
          ind.Play5thCard = *off;
          ind.Play6thCard = *off;
          Deck1 = f_GetCardFace(NewCard(13));
          Deck1a = %bitor(WHITE: PR: UL);
          Deck2a = f_GetCardColor(NewSuite(13));
          Deck3a = f_GetCardColor(NewSuite(13));
 
          //---------------------------------------------------------
          // Load two user discards into crib .
          // Load four 'keepers' into users Play array.
          //---------------------------------------------------------
          ac = 0;
          ax = 0;
          ay = 0;
          UPlay4(*) = *blanks;
 
 2b       for ad = 1 to 6;
 3b          if DiscardX(ad) > ' ';
                ax += 1;
                CribCards(ax) = uDealt(ad);
 3x          else;
                ac += 1;
                uPlay4(ac) = uDealt(ad);
 3e          endif;
 2e       endfor;
 
          // Load screen with four playing cards. Clear 5 & 6
          sorta uPlay4;
          Attr(3).Row(1).Col(*) = %bitor(WHITE: PR: UL);
          Attr(3).Row(3).Col(*) = x'00';
 
 2b       for ax = 1 to 4;
             Face(3).Row(1).Col(ax) = f_GetCardFace(uFace4(ax));
             Attr(3).Row(2).Col(ax) = f_GetCardColor(uSuite4(ax));
 2e       endfor;
 
          uHand15 = *blanks;
          uhand16 = *blanks;
          uhand15a = *blanks;
          uhand16a = *blanks;
          uhand25a = *blanks;
          uhand26a = *blanks;
          uhand35a = *blanks;
          uhand36a = *blanks;
          DiscardX(*) = *blanks;
 
 2b       if WhoseCrib = 1;
             NextStepFlg = 'Play Craig 1st card';
             ah = 4;
 2x       else;
             NextStepFlg = 'User Selects a Card for Play';
             ah = 2;
 2e       endif;
 
          Face(ah).Row(1).Col(1) = *blanks;
          Face(ah).Row(2).Col(1) = *blanks;
          Face(ah).Row(3).Col(1) = *blanks;
          Face(ah).Row(1).Col(2) = *blanks;
          Face(ah).Row(2).Col(2) = *blanks;
          Face(ah).Row(3).Col(2) = *blanks;
          Attr(ah).Row(1).Col(1) = %bitor(RED: RI);
          Attr(ah).Row(2).Col(1) = %bitor(WHITE: RI);
          Attr(ah).Row(3).Col(1) = %bitor(BLUE: RI);
          Attr(ah).Row(1).Col(2) = %bitor(RED: RI);
          Attr(ah).Row(2).Col(2) = %bitor(WHITE: RI);
          Attr(ah).Row(3).Col(2) = %bitor(BLUE: RI);
          // Check Starter Card for 'Heels'
          exsr srScoreHeels;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Score 'Heels'
       //---------------------------------------------------------
       begsr srScoreHeels;
 1b    if NewCard(13) = 11;  //starter card = jack
 2b       if WhoseCrib = 1;
             WhoPlayed = 'You';
 2x       else;
             WhoPlayed = 'Craig';
 2e       endif;
 
          HandScore = 2;
          ind.PlayMsg = *on;
          PlayMsg = %trimr(WhoPlayed) +
          ' scored Heels for 2.  Press Enter';
          exsr srMoveBarGraph;
          exfmt screen;
          exsr srCheckExit;
          PlayMsg = *blanks;
          ind.PlayMsg = *off;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Craig picks 1st card to play.  There are lots of strategies that
       // could be applied here.
       // This subroutine can be executed after GO, so is sensitive
       // about what cards have already been played out of the hand.
       // Array IsCraigCardPlayed = *off if that card is available to play.
       // Probably easiest just to spin through Craigs hand and load flags.
       // Check flags, Spin back through and play selected card.
       //---------------------------------------------------------
       begsr srCraigLead1st;
       CraigLeadTwo = *off;
       CraigLeadThree = *off;
       CraigLeadFour = *off;
       CraigLeadFive = *off;
       CraigLeadSix = *off;
       CraigLeadNine = *off;
       CraigLeadTen = *off;
       CraigLeadAny = *off;
 
 1b    for ad = 1 to 4;
 2b       if not IsCraigCardPlayed(ad);
             CraigLeadAny = *on;
 3b          if cFace4(ad) = 2;
                CraigLeadTwo = *on;
 3x          elseif cFace4(ad) = 3;
                CraigLeadThree = *on;
 3x          elseif cFace4(ad) = 4;
                CraigLeadFour = *on;
 1v             leave;
 3x          elseif cFace4(ad) = 5;
                CraigLeadFive = *on;
 3x          elseif cFace4(ad) = 6;
                CraigLeadSix = *on;
 3x          elseif cFace4(ad) = 9;
                CraigLeadNine = *on;
 3x          elseif cFace4(ad) >= 10;
                CraigLeadTen = *on;
 3e          endif;
 2e       endif;
 1e    endfor;
       // ----
 1b    if CraigLeadAny;
          //---------------------------------------------------------
          // Play a 4.
          // Play 6 if Craig has a 9.
          // Play 10 if Craig has a 5.
          // Play a 2 or 3.   (save aces for 31s!).
          // Play first non-5 / non-ace card.
          // if only thing left is 5 or ace, play the 5.
          // Leave loop when card is found that matches one of strategy criteria.
          //---------------------------------------------------------
          IsFound = *off;
 2b       for ad = 1 to 4;
 3b          if not IsCraigCardPlayed(ad);
 4b             if CraigLeadFour
                   and cFace4(ad) = 4;
                   IsFound = *on;
 2v                leave;
 4x             elseif CraigLeadSix
                   and CraigLeadNine
                   and cFace4(ad) = 6;
                   IsFound = *on;
 2v                leave;
 4x             elseif CraigLeadTen
                   and CraigLeadFive
                   and cFace4(ad) >= 10;
                   IsFound = *on;
 2v                leave;
 4x             elseif CraigLeadThree
                   and cFace4(ad) = 3;
                   IsFound = *on;
 2v                leave;
 4x             elseif CraigLeadTwo
                   and cFace4(ad) = 2;
                   IsFound = *on;
 2v                leave;
 4e             endif;
 3e          endif;
 2e       endfor;
 
          // Else play first non-5 / non-ace card
          // if only thing left is 5 or ace, play the 5
 2b       if not IsFound;
 3b          for ad = 1 to 4;
 4b             if not IsCraigCardPlayed(ad);
 5b                if cFace4(ad) = 1
                      or cFace4(ad) = 5;
 5x                else;
                      IsFound = *on;
 3v                   leave;
 5e                endif;
 4e             endif;
 3e          endfor;
 2e       endif;
 
          // If still nothing, play 1st available card
 2b       if not IsFound;
 3b          for ad = 1 to 4;
 4b             if not IsCraigCardPlayed(ad);
                   IsFound = *on;
 3v                leave;
 4e             endif;
 3e          endfor;
 2e       endif;
 
          //---------------------------------------------------------
          // At this point, AD will equal index of
          // card from Craigs hand to play.
          //---------------------------------------------------------
          ah = 1;
          PlayThisCard = ad;
          exsr srPlayOneCard;
 1e    endif;
       NextStepFlg = 'User Selects a Card for Play';
       endsr;
 
       //---------------------------------------------------------
       // 1. If card go past 31, return error.
       // 2. load Craigs/users card into play array.
       // 3. load play card array to play card screen hand.
       // 4. blank out card in Craig/users screen hand
       // 5. Check and see if is last card played.
       //---------------------------------------------------------
       begsr srPlayOneCard;
       IsOver31 = *off;
       WhoPlayedLast = *blanks;
       RunningTot = 0;
 1b    for ax = 1 to 8;
 2b       if pFace(ax) = 0;
 1v          leave;
 2e       endif;
          RunningTot += f_KQJcount10(pFace(ax));
 1e    endfor;
 
 1b    if ah = 1;
 2b       if RunningTot + f_KQJcount10(cFace4(PlayThisCard)) > 31;
             IsOver31 = *on;
 2e       endif;
 1x    else;
 2b       if RunningTot + f_KQJcount10(uFace4(PlayThisCard)) > 31;
             IsOver31 = *on;
 2e       endif;
 1e    endif;
 
 1b    if not IsOver31;
          NxtPlayCard += 1;
 2b       if ah = 1;
             NxtPlayc += 1;
             RunningTot += f_KQJcount10(cFace4(PlayThisCard));
             IsCraigCardPlayed(PlayThisCard) = *on;
             PlayIt(NxtPlayCard) = cPlay4(PlayThisCard);
             PlayCraigA(1).Col(NxtPlayC) = %bitor(WHITE: PR: UL);
             PlayCraigA(2).Col(NxtPlayC) =
             f_GetCardColor(pSuite(NxtPlayCard));
             PlayCraigA(3).Col(NxtPlayC) =
             f_GetCardColor(pSuite(NxtPlayCard));
             PlayCraig(1).Col(NxtPlayC) =
             f_GetCardFace(pFace(NxtPlayCard));
             WhoPlayedLast = 'Craig';
 2x       else;
             NxtPlayU += 1;
             RunningTot += f_KQJcount10(uFace4(PlayThisCard));
             IsUserCardPlayed(PlayThisCard) = *on;
             PlayIt(NxtPlayCard) = uPlay4(PlayThisCard);
             PlayUserA(1).Col(NxtPlayU) = %bitor(WHITE: PR: UL);
             PlayUserA(2).Col(NxtPlayU) =
             f_GetCardColor(pSuite(NxtPlayCard));
             PlayUserA(3).Col(NxtPlayU) =
             f_GetCardColor(pSuite(NxtPlayCard));
             PlayUser(1).Col(NxtPlayU) =
             f_GetCardFace(pFace(NxtPlayCard));
             WhoPlayedLast = 'You';
 2e       endif;
 
          //Spin back through blanking out Craig/user card from hand
 2b       for ax = 1 to 3;
             Face(ah).Row(ax).Col(PlayThisCard) = *blanks;
             Attr(ah).Row(ax).Col(PlayThisCard) = x'00';
 2e       endfor;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Show score window for each hand.
       // Player that does not have crib is scored first and moved first.
       // 1).  Turn Crib hand Over.
       // 2).  Determine who to score first.
       // 3).  Check 4 cards in players hand for flush.
       // 4).  Combine 4 cards in players hand with start card.
       // 5).  Position window relative to hand being scored.
       // 6).  pop-up window.
       // 7)   repeat steps 3 through 6 for player with crib.
       //  Flush processing is different for crib,
       //  all 4 cards must match suite of starting card.
       //---------------------------------------------------------
       begsr srScoreWindow;
       PlayMsg = *blanks;
       ind.PlayMsg = *off;
       ind.BorderRed = *off;
       ind.BorderBlue = *off;
       savdeck(*) = *blanks;
       SavCard = 0;
       SavDeck(1) = Newdeck(13);  //load start card
       CardsToScore = 5;
       ShowScoreSbf = 'YES';  //Load cards to sbf
       pos = 27;  //position window
 
       exsr srResetPlay;
       exsr srReShowHands;
       write screen;
 
 1b    if WhoseCrib = 1;  //player has crib
          lin = 1;  //position window
          exsr srScoreCraig;
 2b       if not IsGameOver;  //Craig did not win
             exsr srScoreUser;
 2e       endif;
 1x    else;  //Craig has crib
          lin = 6;  //position window
          exsr srScoreUser;
 2b       if not IsGameOver;  //user did not win
             exsr srScoreCraig;
 2e       endif;
 1e    endif;
 
       // Give crib points to crib holder
 1b    if not IsGameOver;  //nobody won yet
          SavDeck(2) = CribCards(1);
          SavDeck(3) = CribCards(2);
          SavDeck(4) = CribCards(3);
          SavDeck(5) = CribCards(4);
          TstDeck = SavDeck;
 2b       if WhoseCrib = 1;  //player has crib
             scoremsg = ' Your Crib';
             ind.BorderRed = *off;
             ind.BorderBlue = *on;
 2x       else;  //Craig has crib
             ind.BorderRed = *on;
             ind.BorderBlue = *off;
             scoremsg = ' Craig' + QuoteMark + 's Crib';
 2e       endif;
          IsLoadGraph = *off;
          exsr srScoreHand;
 
          // Flush?  Flush is different for crib.  All five must match
          IsFlush = *off;
 2b       if NewSuite(13) = CribSuite(1)
             and NewSuite(13) = CribSuite(2)
             and NewSuite(13) = CribSuite(3)
             and NewSuite(13) = CribSuite(4);
             IsFlush = *on;
             HandScore += 5;
             sbfTotal = HandScore;
             // -- write flush record ----
             sbfscval(*) = *blanks;
             sbfscatr(*) = *blanks;
             sbfscMsg = 'Flush for 5';
 3b          for sbfx = 1 to 5;
                sbfSCatr(sbfx) = f_GetCardColor(NewSuite(13));
 3e          endfor;
             rrn += 1;
             write sbfdta1;
             ind.sfldsp = *on;
 2e       endif;
          exsr srScoreNobs;
          exsr srScoreNada;  //see if no score
          write sbfctl1;
          exfmt sfooter1;
          exsr srCheckExit;
          IsLoadGraph = *on;
          exsr srMoveBarGraph;
 1e    endif;
       ShowScoreSbf = 'NO';
       endsr;
 
       //---------------------------------------------------------
       // Load subfile for Craigs scores
       //---------------------------------------------------------
       begsr srScoreCraig;
       ind.BorderRed = *on;
       ind.BorderBlue = *off;
       SavDeck(2) = cPlay4(1);
       SavDeck(3) = cPlay4(2);
       SavDeck(4) = cPlay4(3);
       SavDeck(5) = cPlay4(4);
       TstDeck = SavDeck;
       scoremsg = ' Craig' + QuoteMark + 's Hand';
       WhoPlayed = 'Craig';
       IsLoadGraph = *off;
       exsr srScoreHand;
       // check for flush
       IsFlush = *off;
 1b    if csuite4(1) = csuite4(2)
          and csuite4(1) = csuite4(3)
          and csuite4(1) = csuite4(4);
          IsFlush = *on;
          HandScore += 4;
          sbfTotal = HandScore;
          // -- write flush record ----
          sbfscval(*) = *blanks;
          sbfscatr(*) = *blanks;
          sbfscMsg = 'Flush for 4';
 2b       for sbfx = 1 to 4;
             sbfSCatr(sbfx) = f_GetCardColor(csuite4(1));
 2e       endfor;
          rrn += 1;
          write sbfdta1;
          ind.sfldsp = *on;
 1e    endif;
       exsr srScoreNobs;
       exsr srScoreNada;
       write sbfctl1;
       exfmt sfooter1;
       exsr srCheckExit;
       IsLoadGraph = *on;
       exsr srMoveBarGraph;
       endsr;
 
       //---------------------------------------------------------
       // Load subfile for users scores
       //---------------------------------------------------------
       begsr srScoreUser;
       ind.BorderRed = *off;
       ind.BorderBlue = *on;
       SavDeck(2) = uPlay4(1);
       SavDeck(3) = uPlay4(2);
       SavDeck(4) = uPlay4(3);
       SavDeck(5) = uPlay4(4);
       TstDeck = SavDeck;
       scoremsg = ' Your Hand';
       WhoPlayed = 'You';
       IsLoadGraph = *off;
       exsr srScoreHand;
       // check for user flush
       IsFlush = *off;
 1b    if usuite4(1) = usuite4(2)
          and usuite4(1) = usuite4(3)
          and usuite4(1) = usuite4(4);
          IsFlush = *on;
          HandScore += 4;
          sbfTotal = HandScore;
          // -- write flush record ----
          sbfscval(*) = *blanks;
          sbfscatr(*) = *blanks;
          sbfscMsg = 'Flush for 4';
 2b       for sbfx = 1 to 4;
             sbfSCatr(sbfx) = f_GetCardColor(usuite4(1));
 2e       endfor;
          rrn += 1;
          write sbfdta1;
          ind.sfldsp = *on;
 1e    endif;
       exsr srScoreNobs;
       exsr srScoreNada;
       write sbfctl1;
       exfmt sfooter1;
       exsr srCheckExit;
       IsLoadGraph = *on;
       exsr srMoveBarGraph;
       endsr;
 
       //---------------------------------------------------------
       // Check for Nobs.  Any hand that has Jack of
       // same suite as start card gets 1 point.
       //---------------------------------------------------------
       begsr srScoreNobs;
 1b    for ax = 2 to 5;
 2b       if SavCard(ax) = 11
             and SavSuite(ax) = NewSuite(13);
             HandScore += 1;
             sbfTotal = HandScore;
             // write nobs sbf record
             sbfscval(*) = *blanks;
             sbfscatr(*) = *blanks;
             sbfscMsg = 'Nobs For 1';
             sbfSCatr(1) = f_GetCardColor(SavSuite(ax));
             sbfSCval(1) = f_GetCardFace(SavCard(ax));
             rrn += 1;
             write sbfdta1;
             ind.sfldsp = *on;
 1v          leave;
 2e       endif;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // If no score, write nothing for zero record
       //---------------------------------------------------------
       begsr srScoreNada;
 1b    if HandScore = 0;
          sbfscatr(*) = *blanks;
          sbfscMsg = 'Nothing for Zero';
          sbfSCval = '00';
          rrn += 1;
          write sbfdta1;
          ind.sfldsp = *on;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Select highest possible scoring hand for Craig
       // from six cards he was dealt.
       // Discard other two to appropriate crib
       //---------------------------------------------------------
       begsr srLoadCraigHand;
       SavDeck(*) = *blanks;
       savCard = 0;
       TstDeck(*) = *blanks;
       TstCard = 0;
       BestB = 0;
       BestC = 0;
       BestD = 0;
       BestScore = 0;
       ShowScoreSbf = 'NO';
       IsLoadGraph = *off;
       IsFlush = *off;
 1b    for BestA = 1 to 6;
 2b       for BestB = (BestA + 1) to 6;
 3b          for BestC = (BestB + 1) to 6;
 4b             for BestD = (BestC + 1) to 6;
                   SavDeck(1) = cDealt(BestA);
                   SavDeck(2) = cDealt(BestB);
                   SavDeck(3) = cDealt(BestC);
                   SavDeck(4) = cDealt(BestD);
 
                   // See what this hand is worth
                   TstDeck = SavDeck;
                   CardsToScore = 4;
                   exsr srScoreHand;
 5b                if cSuite(BestA) = cSuite(BestB)
                      and cSuite(BestA) = cSuite(BestC)
                      and cSuite(BestA) = cSuite(BestD);
                      IsFlush = *on;
                      HandScore += 4;
 5e                endif;
 5b                if HandScore > BestScore;
                      BestIndexA = BestA;
                      BestIndexB = BestB;
                      BestIndexC = BestC;
                      BestIndexD = BestD;
                      BestScore = handscore;
 5e                endif;
 4e             endfor;
 3e          endfor;
 2e       endfor;
 1e    endfor;
 
       //---------------------------------------------------------
       // Craig got crummy hand and nothing scored.
       // There is room for strategy here but to keep it simple,
       // keep any ACE or any 5 or any Jack(nobs)
       // Beyond that keep lowest cards for better opportunities
       // while in play.
       //---------------------------------------------------------
 1b    if BestScore = 0;
          IsCardSelected = *off;
          ax = 0;
 
 2b       for ay = 1 to 6;
 3b          if cFace(ay) = 1;
                ax += 1;
                BestArry(ax) = ay;
                IsCardSelected(ay) = *on;
 3x          elseif cFace(ay) = 5;
                ax += 1;
                BestArry(ax) = ay;
                IsCardSelected(ay) = *on;
 3x          elseif cFace(ay) = 11;
                ax += 1;
                BestArry(ax) = ay;
                IsCardSelected(ay) = *on;
 3e          endif;
 2e       endfor;
 
          // At best only loaded three cards
 2b       for ay = 1 to 6;
 3b          if not IsCardSelected(ay);
                ax += 1;
 4b             if ax = 5;
 2v                leave;
 4e             endif;
                BestArry(ax) = ay;
 3e          endif;
 2e       endfor;
 1e    endif;
 
       //---------------------------------------------------------
       // Discard 2 indexes that are not best index values
       //---------------------------------------------------------
       BestDiscard1 = 0;
       BestDiscard2 = 0;
 1b    for BestA = 1 to 6;
 2b       if BestA = BestIndexA
             or BestA = BestIndexB
             or BestA = BestIndexC
             or BestA = BestIndexD;
 2x       else;
 3b          if BestDiscard1 = 0;
                BestDiscard1 = BestA;
 3x          else;
                BestDiscard2 = BestA;
 3e          endif;
 2e       endif;
 1e    endfor;
       //---------------------------------------------------------
       // load best cards to Craig playing hand/load discards to crib
       //---------------------------------------------------------
       cPlay4(1) = cDealt(BestIndexa);
       cPlay4(2) = cDealt(BestIndexb);
       cPlay4(3) = cDealt(BestIndexc);
       cPlay4(4) = cDealt(BestIndexd);
       CribCards(*) = *blanks;
       CribFace = 0;
       CribCards(3) = cDealt(BestDiscard1);
       CribCards(4) = cDealt(BestDiscard2);
 
       Face(1).Row(1).Col(*) = *blanks;
       Face(1).Row(2).Col(*) = *blanks;
       Face(1).Row(3).Col(*) = *blanks;
       Attr(1).Row(1).Col(*) = %bitor(RED: RI);
       Attr(1).Row(2).Col(*) = %bitor(WHITE: RI);
       Attr(1).Row(3).Col(*) = %bitor(BLUE: RI);
 
 1b    if WhoseCrib = 1;  //Player 1st crib
          ah = 4;
 1x    else;
          ah = 2;
 1e    endif;
 
       Face(ah).Row(1).Col(3) = *blanks;
       Face(ah).Row(2).Col(3) = *blanks;
       Face(ah).Row(3).Col(3) = *blanks;
       Face(ah).Row(1).Col(4) = *blanks;
       Face(ah).Row(2).Col(4) = *blanks;
       Face(ah).Row(3).Col(4) = *blanks;
       Attr(ah).Row(1).Col(3) = %bitor(RED: RI);
       Attr(ah).Row(2).Col(3) = %bitor(WHITE: RI);
       Attr(ah).Row(3).Col(3) = %bitor(BLUE: RI);
       Attr(ah).Row(1).Col(4) = %bitor(RED: RI);
       Attr(ah).Row(2).Col(4) = %bitor(WHITE: RI);
       Attr(ah).Row(3).Col(4) = %bitor(BLUE: RI);
       IsLoadGraph = *on;  //enable graph load
       endsr;
 
       //---------------------------------------------------------
       // Turn up Crib Cards
       //---------------------------------------------------------
       begsr srShowCrib;
       sorta CribCards;
 1b    if WhoseCrib = 1;
          ah = 4;
 1x    else;
          ah = 2;
 1e    endif;
       Attr(ah).Row(1).Col(*) = %bitor(WHITE: PR: UL);
 1b    for ax = 1 to 4;
          Face(ah).Row(1).Col(ax) = f_GetCardFace(CribFace(ax));
          Attr(ah).Row(2).Col(ax) = f_GetCardColor(CribSuite(ax));
          Attr(ah).Row(3).Col(ax) = f_GetCardColor(CribSuite(ax));
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // Deal next hand
       //---------------------------------------------------------
       begsr srNextHand;
       Face(*) = *all' ';
       Attr(*) = *allx'00';
       PlayCraig(*) = *all' ';
       PlayCraigA(*) = *allx'00';
       PlayUser(*) = *all' ';
       PlayUserA(*) = *allx'00';
       NxtPlayC = 0;
       NxtPlayU = 0;
       Deck1A = *blanks;
       Deck2A = *blanks;
       Deck3A = *blanks;
       Deck1 = *blanks;
       Deck2 = *blanks;
       Deck3 = *blanks;
       PlayIt(*) = *blanks;
       WhoPlayedLast = *blanks;
       IsUserGo = *off;
       IsCraigGo = *off;
       IsUserOut = *off;
       IsCraigOut = *off;
       IsPickBest = *off;
       NxtPlayCard = 0;
       pFace(*) = 0;
       PlayThisCard = 0;
       uFace(*) = 0;
       uFace4(*) = 0;
       cFace(*) = 0;
       cFace4(*) = 0;
       CribFace(*) = 0;
       TstCard(*) = 0;
       RunCard(*) = 0;
       SavCard(*) = 0;
       RunningTot = 0;
       srCraigStat = *blanks;
       srUserStat = *blanks;
       ShowScoreSbf = 'NO';
       ind.CribMsgCraig = *off;
       ind.CribMsgUser = *off;
       ind.ColrBarCraig = *off;
       ind.ColrBarUser = *off;
       ind.CraigSaysGo = *off;
       ind.UserSaysGo = *off;
       // --swap crib
 1b    if WhoseCrib = 2;
          WhoseCrib = 1;
          ind.CribMsgUser = *on;
 1x    else;
          WhoseCrib = 2;
          ind.CribMsgCraig = *on;
 1e    endif;
       IsCraigCardPlayed = *off;
       IsUserCardPlayed = *off;
       IsOver31 = *off;
       IsGO = *off;
       NewDeck = f_ShuffleDeck();
       exsr srDeal6Cards;  //deal 1st hand
       endsr;
 
       //---------------------------------------------------------
       // Deal 6 cards to users/Craigs hand
       begsr srDeal6Cards;
       ax = 0;
 1b    for Deal = 1 by 2 to 11;
          ax += 1;
          uDealt(ax) = NewDeck(Deal);
 1e    endfor;
 
       // load even cards to Craig
       ax = 0;
 1b    for Deal = 2 by 2 to 12;
          ax += 1;
          cDealt(ax) = NewDeck(Deal);
 1e    endfor;
       ax = 0;
 
       //---------------------------------------------------------
       // Load 6 user card faces to screen.
       // Only first four cards are in array.  5th and 6th card are
       // only used for crib selection and play minor part in overall scheme.
       // Load cards function returns card face (A 1 2 3 4 J Q K) and color
       // attribute for card in hand.
       //---------------------------------------------------------
       sorta uDealt;
       Attr(3).Row(1).Col(*) = %bitor(WHITE: PR: UL);
       Attr(3).Row(3).Col(*) = x'00';
 1b    for ax = 1 to 4;
          Face(3).Row(1).Col(ax) = f_GetCardFace(uFace(ax));
          Attr(3).Row(2).Col(ax) = f_GetCardColor(uSuite(ax));
 1e    endfor;
       uHand15 = f_GetCardFace(uface(5));
       uhand16 = f_GetCardFace(uface(6));
       uhand15a = %bitor(WHITE: PR: UL);
       uhand16a = %bitor(WHITE: PR: UL);
       uhand25a = f_GetCardColor(uSuite(5));
       uhand26a = f_GetCardColor(uSuite(6));
       uhand35a = x'00';
       uhand36a = x'00';
       exsr srLoadCraigHand;
       endsr;
 
       //---------------------------------------------------------
       // Load scoring cards and colors into subfile
       //---------------------------------------------------------
       begsr srLoadSbfRec;
       sbfscval(*) = *blanks;
       sbfscatr(*) = *blanks;
 1b    if sbfscMsg = 'Run of 5 for 5'
          or sbfscMsg = 'Run of 4 for 4'
          or sbfscMsg = 'Run of 3 for 3';
          sbfx = cardcount;
 2b       for sbfxb = 1 to CardCount;
             sbfSCatr(sbfxb) = f_GetCardColor(TstSuite(IndexArry(sbfx)));
             sbfSCval(sbfxb) = f_GetCardFace(TstCard(IndexArry(sbfx)));
             sbfx -= 1;
 2e       endfor;
 1x    else;
 2b       for sbfx = 1 to CardCount;
             sbfSCatr(sbfx) = f_GetCardColor(TstSuite(IndexArry(sbfx)));
             sbfSCval(sbfx) = f_GetCardFace(TstCard(IndexArry(sbfx)));
 2e       endfor;
 1e    endif;
       rrn += 1;
       write sbfdta1;
       ind.sfldsp = *on;
       endsr;
 
       //---------------------------------------------------------
       // Scoring while in play is concerning with cards played IN SEQUENCE backwards
       // from last card played.
       // Even runs of are different. Only count runs starting from card played.
       // Add of total face value of cards and any scoring combinations.
       // Process GO by giving message but no other processing
       //---------------------------------------------------------
       begsr srScorePlayed;
 1b    if not IsGO;
          SavDeck = Playit;
          TstDeck = SavDeck;
          AllGroupings(*) = 0;
          sFifteens = 0;
          sPairs = 0;
          sThreeOfKind = 0;
          sFourOfKind = 0;
          sRunOf3s = 0;
          sRunOf4s = 0;
          sRunOf5s = 0;
          sRunOf6s = 0;
          sRunOf7s = 0;
 
          // Check all cards played for 15 total
          Check = 0;
 2b       for ax = 1 to NxtPlayCard;
             Check += f_KQJcount10(TstCard(ax));
 3b          if check > 15;
 2v             leave;
 3e          endif;
 2e       endfor;
 2b       if Check = 15;
             sFifteens = 1;
 2e       endif;
          //---------------------------------------------------------
          // look for 4 of a kinds, 3 of a kinds and pairs.
          // Cannot count same cards twice.
          // ie if 4 of a kind, do not count same cards as 2 pairs.
          //  Look for 4s first.
          //---------------------------------------------------------
 2b       dou '1';  // one time do so leave will work
             an = NxtPlayCard;
 
 3b          if NxtPlayCard >= 4;
 4b             if TstCard(an) = TstCard(an - 1)
                   and TstCard(an) = TstCard(an - 2)
                   and TstCard(an) = TstCard(an - 3);
                   sFourOfKind += 1;
 2v                leave;
 4e             endif;
 3e          endif;
 
             // Repeat process for 3 of a kind
 3b          if NxtPlayCard >= 3;
 4b             if TstCard(an) = TstCard(an - 1)
                   and TstCard(an) = TstCard(an - 2);
                   sThreeOfKind += 1;
 2v                leave;
 4e             endif;
 3e          endif;
 
             // Repeat process for pairs
 3b          if NxtPlayCard >= 2;
 4b             if TstCard(an) = TstCard(an - 1);
                   sPairs += 1;
 2v                leave;
 4e             endif;
 3e          endif;
 2e       enddo;
          // Check for runs in a row
          exsr srRunsInRow;
 1e    endif;  //end GO skip
 
 1b    if not IsPickBest;
          //---------------------------------------------------------
          // Load score message on screen.
          // 2 cards active - pair or 15 for 2
          // 3 cards active - 3 of a kind or run of 3
          // 4 cards active - 4 of a kind or run of 4
          // 5 cards active and up - run of that number of cards.
          //---------------------------------------------------------
          HandScore = 0;
          PlayMsg = *blanks;
          ind.PlayMsg = *off;
          indsav.Play1stCard = ind.Play1stCard;
          indsav.Play2ndCard = ind.Play2ndCard;
          indsav.Play3rdCard = ind.Play3rdCard;
          indsav.Play4thCard = ind.Play4thCard;
          ind.Play1stCard = *off;
          ind.Play2ndCard = *off;
          ind.Play3rdCard = *off;
          ind.Play4thCard = *off;
 
 2b       if not IsGO;
 3b          if sFifteens > 0;
                HandScore = 2;
                ind.PlayMsg = *on;
                PlayMsg = %trimr(WhoPlayed) +
                ' scored 15 for 2.  Press Enter';
                exsr srMoveBarGraph;
                exfmt screen;
                exsr srCheckExit;
 3e          endif;
 
 3b          if sRunOf7s > 0;
                HandScore = 7;
                ind.PlayMsg = *on;
                PlayMsg = %trimr(WhoPlayed) +
                ' scored Run of 7 for 7.  Press Enter';
                exsr srMoveBarGraph;
                exfmt screen;
                exsr srCheckExit;
 
 3x          elseif sRunOf6s > 0;
                HandScore = 6;
                ind.PlayMsg = *on;
                PlayMsg = %trimr(WhoPlayed) +
                ' scored Run of 6 for 6.  Press Enter';
                exsr srMoveBarGraph;
                exfmt screen;
                exsr srCheckExit;
 
 3x          elseif sRunOf5s > 0;
                HandScore = 5;
                ind.PlayMsg = *on;
                PlayMsg = %trimr(WhoPlayed) +
                ' scored Run of 5 for 5. Press Enter';
                exsr srMoveBarGraph;
                exfmt screen;
                exsr srCheckExit;
 
 3x          elseif sFourOfKind > 0;
                HandScore = 12;
                ind.PlayMsg = *on;
                PlayMsg = %trimr(WhoPlayed) +
                ' scored 4 of a kind for 12.  Press Enter';
                exsr srMoveBarGraph;
                exfmt screen;
                exsr srCheckExit;
 
 3x          elseif sRunOf4s > 0;
                HandScore = 4;
                ind.PlayMsg = *on;
                PlayMsg = %trimr(WhoPlayed) +
                ' scored Run of 4 for 4.  Press Enter';
                exsr srMoveBarGraph;
                exfmt screen;
                exsr srCheckExit;
 
 3x          elseif sThreeOfKind > 0;
                HandScore = 6;
                ind.PlayMsg = *on;
                PlayMsg = %trimr(WhoPlayed) +
                ' scored 3 of a kind for 6.  Press Enter';
                exsr srMoveBarGraph;
                exfmt screen;
                exsr srCheckExit;
 
 3x          elseif sRunOf3s > 0;
                HandScore = 3;
                ind.PlayMsg = *on;
                PlayMsg = %trimr(WhoPlayed) +
                ' scored Run of 3 for 3.  Press Enter';
                exsr srMoveBarGraph;
                exfmt screen;
                exsr srCheckExit;
 
 3x          elseif sPairs > 0;
                HandScore = 2;
                ind.PlayMsg = *on;
                PlayMsg = %trimr(WhoPlayed) +
                ' scored Pair for 2.  Press Enter';
                exsr srMoveBarGraph;
                exfmt screen;
                exsr srCheckExit;
 3e          endif;
 
 3b          if RunningTot = 31;
                ind.CraigSaysGo = *off;
                ind.UserSaysGo = *off;
                HandScore = 1;
                ind.PlayMsg = *on;
                PlayMsg = %trimr(WhoPlayed) +
                ' scored 31 for 1.  Press Enter';
                exsr srMoveBarGraph;
                exfmt screen;
                exsr srCheckExit;
                exsr srResetPlay;
 3e          endif;
 2x       else;
             //---------------------------------------------------------
             // Process Go scoring here
             //---------------------------------------------------------
             HandScore = 1;
             ind.PlayMsg = *on;
             PlayMsg = %trimr(WhoPlayed) +
             ' scored GO for 1.  Press Enter';
             exsr srMoveBarGraph;
             exfmt screen;
             exsr srCheckExit;
             exsr srResetPlay;
 2e       endif;
 
          //---------------------------------------------------------
          // Process last Card played scoring
          // score 1 if count <> 31
          // score 1 regardless
          // score 1 if count <> 31 score 2 if count = 31,  etc.
          //---------------------------------------------------------
          exsr srChkAllPlayd;
 2b       if IsUserOut
             and IsCraigOut;
             HandScore = 1;
             ind.PlayMsg = *on;
             PlayMsg = %trimr(WhoPlayed) +
             ' scored Last Card for 1.  Press Enter';
             exsr srMoveBarGraph;
             exfmt screen;
             exsr srCheckExit;
 
             // If all cards played, pop up score window for each hand
             exsr srShowCrib;
             exsr srScoreWindow;
             exsr srNextHand;
             exsr srUserDealt;
 2e       endif;
          PlayMsg = *blanks;
          ind.PlayMsg = *off;
          ind.Play1stCard = indsav.Play1stCard;
          ind.Play2ndCard = indsav.Play2ndCard;
          ind.Play3rdCard = indsav.Play3rdCard;
          ind.Play4thCard = indsav.Play4thCard;
          IsGO = *off;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Check for runs in a Row
       //---------------------------------------------------------
       begsr srRunsInRow;
 1b    if NxtPlayCard >= 7;
          ax = (-6) + NxtPlayCard;
          TstDeck(*) = *blanks;
          TstCard = 0;
 2b       for a1 = ax to 8;
             TstDeck(a1) = SavDeck(a1);
 2e       endfor;
          sorta TstCard;
          //---------------------------------------------------------
          // run of 7 (yeah, just maybe possible)
          //---------------------------------------------------------
 2b       for a1 = 1      to 7;
 3b          for a2 = (a1 + 1) to 7;
 4b             for a3 = (a2 + 1) to 7;
 5b                for a4 = (a3 + 1) to 7;
 6b                   for a5 = (a4 + 1) to 7;
 7b                      for a6 = (a5 + 1) to 7;
 8b                         for a7 = (a6 + 1) to 7;
 9b                            if TstCard(a1) = TstCard(a2) + 1
                                  and TstCard(a1) = TstCard(a3) + 2
                                  and TstCard(a1) = TstCard(a4) + 3
                                  and TstCard(a1) = TstCard(a5) + 4
                                  and TstCard(a1) = TstCard(a6) + 5
                                  and TstCard(a1) = TstCard(a7) + 6;
                                  sRunOf7s += 1;
 LV                               leavesr;
 9e                            endif;
 8e                         endfor;
 7e                      endfor;
 6e                   endfor;
 5e                endfor;
 4e             endfor;
 3e          endfor;
 2e       endfor;
 1e    endif;
 
       //---------------------------------------------------------
       // run of 6s
       //---------------------------------------------------------
 1b    if NxtPlayCard >= 6;
          ax = (-5) + NxtPlayCard;
          TstDeck(*) = *blanks;
          TstCard = 0;
 2b       for a1 = ax to 8;
             TstDeck(a1) = SavDeck(a1);
 2e       endfor;
          sorta TstCard;
 2b       for a1 = 1      to 6;
 3b          for a2 = (a1 + 1) to 6;
 4b             for a3 = (a2 + 1) to 6;
 5b                for a4 = (a3 + 1) to 6;
 6b                   for a5 = (a4 + 1) to 6;
 7b                      for a6 = (a5 + 1) to 6;
 8b                         if TstCard(a1) = TstCard(a2) + 1
                               and TstCard(a1) = TstCard(a3) + 2
                               and TstCard(a1) = TstCard(a4) + 3
                               and TstCard(a1) = TstCard(a5) + 4
                               and TstCard(a1) = TstCard(a6) + 5;
                               sRunOf6s += 1;
 LV                            leavesr;
 8e                         endif;
 7e                      endfor;
 6e                   endfor;
 5e                endfor;
 4e             endfor;
 3e          endfor;
 2e       endfor;
 1e    endif;
 
       //---------------------------------------------------------
       // run of 5s
 1b    if NxtPlayCard >= 5;
          ax = (-4) + NxtPlayCard;
          TstDeck(*) = *blanks;
          TstCard = 0;
 2b       for a1 = ax to 8;
             TstDeck(a1) = SavDeck(a1);
 2e       endfor;
          sorta TstCard;
 2b       for a1 = 1      to 5;
 3b          for a2 = (a1 + 1) to 5;
 4b             for a3 = (a2 + 1) to 5;
 5b                for a4 = (a3 + 1) to 5;
 6b                   for a5 = (a4 + 1) to 5;
 7b                      if TstCard(a1) = TstCard(a2) + 1
                            and TstCard(a1) = TstCard(a3) + 2
                            and TstCard(a1) = TstCard(a4) + 3
                            and TstCard(a1) = TstCard(a5) + 4;
                            sRunOf5s += 1;
 LV                         leavesr;
 7e                      endif;
 6e                   endfor;
 5e                endfor;
 4e             endfor;
 3e          endfor;
 2e       endfor;
 1e    endif;
 
       //---------------------------------------------------------
       // run of 4s
 1b    if NxtPlayCard >= 4;
          ax = (-3) + NxtPlayCard;
          TstDeck(*) = *blanks;
          TstCard = 0;
 2b       for a1 = ax to 8;
             TstDeck(a1) = SavDeck(a1);
 2e       endfor;
          sorta TstCard;
 2b       for a1 = 1      to 4;
 3b          for a2 = (a1 + 1) to 4;
 4b             for a3 = (a2 + 1) to 4;
 5b                for a4 = (a3 + 1) to 4;
 6b                   if TstCard(a1) = TstCard(a2) + 1
                         and TstCard(a1) = TstCard(a3) + 2
                         and TstCard(a1) = TstCard(a4) + 3;
                         sRunOf4s += 1;
 LV                      leavesr;
 6e                   endif;
 5e                endfor;
 4e             endfor;
 3e          endfor;
 2e       endfor;
 1e    endif;
 
       //---------------------------------------------------------
       // run of 3s
 1b    if NxtPlayCard >= 3;
          ax = (-2) + NxtPlayCard;
          TstDeck(*) = *blanks;
          TstCard = 0;
 2b       for a1 = ax to 8;
             TstDeck(a1) = SavDeck(a1);
 2e       endfor;
          sorta TstCard;
 2b       for a1 = 1      to 3;
 3b          for a2 = (a1 + 1) to 3;
 4b             for a3 = (a2 + 1) to 3;
 5b                if TstCard(a1) = TstCard(a2) + 1
                      and TstCard(a1) = TstCard(a3) + 2;
                      sRunOf3s += 1;
 LV                   leavesr;
 5e                endif;
 4e             endfor;
 3e          endfor;
 2e       endfor;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Check both hands for all cards Played
       //---------------------------------------------------------
       begsr srChkAllPlayd;
       IsUserOut = *off;
       IsCraigOut = *off;
 1b    if IsCraigCardPlayed(1)
          and IsCraigCardPlayed(2)
          and IsCraigCardPlayed(3)
          and IsCraigCardPlayed(4);
          IsCraigOut = *on;
 1e    endif;
 1b    if IsUserCardPlayed(1)
          and IsUserCardPlayed(2)
          and IsUserCardPlayed(3)
          and IsUserCardPlayed(4);
          IsUserOut = *on;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Now add up score
       begsr srGetBarScore;
       HandScore = (sFifteens * 2) +
       (sPairs * 2) +
       (sThreeOfKind * 6) +
       (sFourOfKind  * 12) +
       (sRunOf3s * 3) +
       (sRunOf4s * 4) +
       (sRunOf5s * 5) +
       (sRunOf6s * 6) +
       (sRunOf7s * 7);
 1b    if not IsPickBest;
          exsr srMoveBarGraph;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Reset Played cards/count array after 31 total or a GO
       begsr srResetPlay;
       RunningTot = 0;
       PlayIt(*) = *blanks;
       NxtPlayCard = 0;
       pFace(*) = 0;
       PlayCraig(*) = *blanks;
       PlayCraigA(*) = *blanks;
       PlayUser(*) = *blanks;
       PlayUserA(*) = *blanks;
       NxtPlayC = 0;
       NxtPlayU = 0;
       IsCraigGo = *off;
       ind.CraigSaysGo = *off;
       IsUserGo = *off;
       ind.UserSaysGo = *off;
       endsr;
 
       //---------------------------------------------------------
       // Add total face value of cards and any scoring combinations
       begsr srScoreHand;
 1b    if ShowScoreSbf = 'YES';
          ind.sfldsp = *off;
          ind.sfldspctl = *off;
          rrn = 0;
          clear sbfdta1;
          write sbfctl1;
          ind.sfldspctl = *on;
 1e    endif;
       //---------------------------------------------------------
       sFifteens = 0;
       // groups of twos
       AllGroupings(*) = 0;
 1b    for a1 = 1 to CardsToScore;
 2b       for a2 = (a1 + 1) to CardsToScore;
             AllGroupings(1) = f_KQJcount10(TstCard(a1));
             AllGroupings(2) = f_KQJcount10(TstCard(a2));
             Check = %xfoot(AllGroupings);
 3b          if Check = 15;
                sFifteens += 1;
 
 4b             if ShowScoreSbf = 'YES';
                   sbfscMsg = 'Fifteen for 2';
                   CardCount = 2;
                   exsr srLoadSbfRec;
 4e             endif;
 3e          endif;
 2e       endfor;
 1e    endfor;
 
       // groups of threes
 1b    if CardsToScore >= 3;
 2b       for a1 = 1 to CardsToScore;
 3b          for a2 = (a1 + 1) to CardsToScore;
 4b             for a3 = (a2 + 1) to CardsToScore;
                   AllGroupings(1) = f_KQJcount10(TstCard(a1));
                   AllGroupings(2) = f_KQJcount10(TstCard(a2));
                   AllGroupings(3) = f_KQJcount10(TstCard(a3));
                   Check = %xfoot(AllGroupings);
 5b                if Check = 15;
                      sFifteens += 1;
 6b                   if ShowScoreSbf = 'YES';
                         sbfscMsg = 'Fifteen for 2';
                         CardCount = 3;
                         exsr srLoadSbfRec;
 6e                   endif;
 5e                endif;
 4e             endfor;
 3e          endfor;
 2e       endfor;
 1e    endif;
 
       // groups of 4
 1b    if CardsToScore >= 4;
 2b       for a1 = 1 to CardsToScore;
 3b          for a2 = (a1 + 1) to CardsToScore;
 4b             for a3 = (a2 + 1) to CardsToScore;
 5b                for a4 = (a3 + 1) to CardsToScore;
                      AllGroupings(1) = f_KQJcount10(TstCard(a1));
                      AllGroupings(2) = f_KQJcount10(TstCard(a2));
                      AllGroupings(3) = f_KQJcount10(TstCard(a3));
                      AllGroupings(4) = f_KQJcount10(TstCard(a4));
                      Check = %xfoot(AllGroupings);
 6b                   if Check = 15;
                         sFifteens += 1;
 7b                      if ShowScoreSbf = 'YES';
                            sbfscMsg = 'Fifteen for 2';
                            CardCount = 4;
                            exsr srLoadSbfRec;
 7e                      endif;
 6e                   endif;
 5e                endfor;
 4e             endfor;
 3e          endfor;
 2e       endfor;
 1e    endif;
       // groups of 5
 1b    if CardsToScore >= 5;
 2b       for a1 = 1 to CardsToScore;
 3b          for a2 = (a1 + 1) to CardsToScore;
 4b             for a3 = (a2 + 1) to CardsToScore;
 5b                for a4 = (a3 + 1) to CardsToScore;
 6b                   for a5 = (a4 + 1) to CardsToScore;
                         AllGroupings(1) = f_KQJcount10(TstCard(a1));
                         AllGroupings(2) = f_KQJcount10(TstCard(a2));
                         AllGroupings(3) = f_KQJcount10(TstCard(a3));
                         AllGroupings(4) = f_KQJcount10(TstCard(a4));
                         AllGroupings(5) = f_KQJcount10(TstCard(a5));
                         Check = %xfoot(AllGroupings);
 7b                      if Check = 15;
                            sFifteens += 1;
 8b                         if ShowScoreSbf = 'YES';
                               sbfscMsg = 'Fifteen for 2';
                               CardCount = 5;
                               exsr srLoadSbfRec;
 8e                         endif;
 7e                      endif;
 6e                   endfor;
 5e                endfor;
 4e             endfor;
 3e          endfor;
 2e       endfor;
 1e    endif;
       // groups of 6
 1b    if CardsToScore >= 6;
 2b       for a1 = 1 to CardsToScore;
 3b          for a2 = (a1 + 1) to CardsToScore;
 4b             for a3 = (a2 + 1) to CardsToScore;
 5b                for a4 = (a3 + 1) to CardsToScore;
 6b                   for a5 = (a4 + 1) to CardsToScore;
 7b                      for a6 = (a5 + 1) to CardsToScore;
                            AllGroupings(1) = f_KQJcount10(TstCard(a1));
                            AllGroupings(2) = f_KQJcount10(TstCard(a2));
                            AllGroupings(3) = f_KQJcount10(TstCard(a3));
                            AllGroupings(4) = f_KQJcount10(TstCard(a4));
                            AllGroupings(5) = f_KQJcount10(TstCard(a5));
                            AllGroupings(6) = f_KQJcount10(TstCard(a6));
                            Check = %xfoot(AllGroupings);
 8b                         if Check = 15;
                               sFifteens += 1;
 8e                         endif;
 7e                      endfor;
 6e                   endfor;
 5e                endfor;
 4e             endfor;
 3e          endfor;
 2e       endfor;
 1e    endif;
       // groups of 7
 1b    if CardsToScore >= 7;
 2b       for a1 = 1 to CardsToScore;
 3b          for a2 = (a1 + 1) to CardsToScore;
 4b             for a3 = (a2 + 1) to CardsToScore;
 5b                for a4 = (a3 + 1) to CardsToScore;
 6b                   for a5 = (a4 + 1) to CardsToScore;
 7b                      for a6 = (a5 + 1) to CardsToScore;
 8b                         for a7 = (a6 + 1) to CardsToScore;
                               AllGroupings(1) = f_KQJcount10(TstCard(a1));
                               AllGroupings(2) = f_KQJcount10(TstCard(a2));
                               AllGroupings(3) = f_KQJcount10(TstCard(a3));
                               AllGroupings(4) = f_KQJcount10(TstCard(a4));
                               AllGroupings(5) = f_KQJcount10(TstCard(a5));
                               AllGroupings(6) = f_KQJcount10(TstCard(a6));
                               AllGroupings(7) = f_KQJcount10(TstCard(a7));
                               Check = %xfoot(AllGroupings);
 9b                            if Check = 15;
                                  sFifteens += 1;
 9e                            endif;
 8e                         endfor;
 7e                      endfor;
 6e                   endfor;
 5e                endfor;
 4e             endfor;
 3e          endfor;
 2e       endfor;
 1e    endif;
 
       // group of CardsToScore
 1b    if CardsToScore = 8;
 2b       for check = 1 to 8;
             AllGroupings(Check) = f_KQJcount10(TstCard(Check));
 2e       endfor;
          Check = %xfoot(AllGroupings);
 2b       if Check = 15;
             sFifteens += 1;
 2e       endif;
 1e    endif;
 
       //---------------------------------------------------------
       // look for 4 of a kinds, 3 of a kinds and pairs.
       // Look for 4s first. If found, add 1 to 4 counter.
       // Drop cards from test deck
       //---------------------------------------------------------
       sFourOfKind = 0;
 1b    if CardsToScore >= 4;
 2b       for a1 = 1 to CardsToScore;
             CurrentCard = TstCard(a1);
 3b          for a2 = (a1 + 1) to CardsToScore;
 4b             for a3 = (a2 + 1) to CardsToScore;
 5b                for a4 = (a3 + 1) to CardsToScore;
 6b                   if CurrentCard = TstCard(a1)
                         and CurrentCard = TstCard(a2)
                         and CurrentCard = TstCard(a3)
                         and CurrentCard = TstCard(a4);
                         sFourOfKind += 1;
 
 7b                      if ShowScoreSbf = 'YES';
                            sbfscMsg = 'Four of a kind for 12';
                            CardCount = 4;
                            exsr srLoadSbfRec;
 7e                      endif;
 7b                      for az = 1 to CardsToScore;
 8b                         if CurrentCard = TstCard(az);
                               TstCard(az) = 0;
 8e                         endif;
 7e                      endfor;
 6e                   endif;
 5e                endfor;
 4e             endfor;
 3e          endfor;
 2e       endfor;
 1e    endif;
 
       //---------------------------------------------------------
       // Repeat process to check for 3 of a kinds
       //---------------------------------------------------------
       sThreeOfKind = 0;
 1b    if CardsToScore >= 3;
 2b       for a1 = 1 to CardsToScore;
 3b          if TstCard(a1) > 0;  //may have been dropped
                CurrentCard = TstCard(a1);
 4b             for a2 = (a1 + 1) to CardsToScore;
 5b                for a3 = (a2 + 1) to CardsToScore;
 6b                   if CurrentCard = TstCard(a1)
                         and CurrentCard = TstCard(a2)
                         and CurrentCard = TstCard(a3);
                         sThreeOfKind += 1;
 7b                      if ShowScoreSbf = 'YES';
                            sbfscMsg = 'Three of a kind for 6';
                            CardCount = 3;
                            exsr srLoadSbfRec;
 7e                      endif;
 7b                      for az = 1 to CardsToScore;
 8b                         if CurrentCard = TstCard(az);
                               TstCard(az) = 0;
 8e                         endif;
 7e                      endfor;
 6e                   endif;
 5e                endfor;
 4e             endfor;
 3e          endif;
 2e       endfor;
 1e    endif;
 
       //---------------------------------------------------------
       // Repeat process to check for 2 of a kind
       sPairs = 0;
 1b    for a1 = 1 to CardsToScore;
 2b       if TstCard(a1) > 0;
             CurrentCard = TstCard(a1);
 3b          for a2 = (a1 + 1) to CardsToScore;
 4b             if CurrentCard = TstCard(a1)
                   and CurrentCard = TstCard(a2);
                   sPairs += 1;
 5b                if ShowScoreSbf = 'YES';
                      sbfscMsg = 'Pair for 2';
                      CardCount = 2;
                      exsr srLoadSbfRec;
 5e                endif;
 5b                for az = 1 to CardsToScore;
 6b                   if CurrentCard = TstCard(az);
                         TstCard(az) = 0;
 6e                   endif;
 5e                endfor;
 4e             endif;
 3e          endfor;
 2e       endif;
 1e    endfor;
 
       //---------------------------------------------------------
       // Now it really gets hard!  haha just kidding(NOT!)
       // Check for number of cards in a run.
       // This is complicated as if a pair is in a run,
       // the run has to be counted twice
       // 234 =run of 3  2344=2 runs of three.
       // If a larger number run, supersedes any smaller run.
       // ie 1234=1 run of 4 NOT 2 runs of three
       // RunDeck.  Use it to drop cards from.
       //---------------------------------------------------------
       TstDeck = SavDeck;
       sorta TstCard;
       RunDeck = TstDeck;
       RemainingCnt = CardsToScore;
 
       //---------------------------------------------------------
       // run of 7 (yeah, it could happen)
       sRunOf7s = 0;
 1b    if RemainingCnt >= 7;
 2b       for a1 = 1      to RemainingCnt;
 3b          for a2 = (a1 + 1) to RemainingCnt;
 4b             for a3 = (a2 + 1) to RemainingCnt;
 5b                for a4 = (a3 + 1) to RemainingCnt;
 6b                   for a5 = (a4 + 1) to RemainingCnt;
 7b                      for a6 = (a5 + 1) to RemainingCnt;
 8b                         for a7 = (a6 + 1) to RemainingCnt;
 9b                            if TstCard(a1) = TstCard(a2) + 1
                                  and TstCard(a1) = TstCard(a3) + 2
                                  and TstCard(a1) = TstCard(a4) + 3
                                  and TstCard(a1) = TstCard(a5) + 4
                                  and TstCard(a1) = TstCard(a6) + 5
                                  and TstCard(a1) = TstCard(a7) + 6;
                                  sRunOf7s += 1;
                                  RunCard(a1) = 0;
                                  RunCard(a2) = 0;
                                  RunCard(a3) = 0;
                                  RunCard(a4) = 0;
                                  RunCard(a5) = 0;
                                  RunCard(a6) = 0;
                                  RunCard(a7) = 0;
 9e                            endif;
 8e                         endfor;
 7e                      endfor;
 6e                   endfor;
 5e                endfor;
 4e             endfor;
 3e          endfor;
 2e       endfor;
 1e    endif;
       //---------------------------------------------------------
       // If there was a run of 7,  'remove' those
       // runs from the 'deck' so they do not count as a smaller run
       // Reload from deck with cards
       // removed and get a new RemainingCnt count.
       //---------------------------------------------------------
 1b    if sRunOf7s > 0;
          sorta RunDeck;
          TstDeck = RunDeck;
 2b       for a1 = 1 to 8;
 3b          if TstCard(a1) = 0;
                RemainingCnt = (a1 - 1);
 2v             leave;
 3e          endif;
 2e       endfor;
 1e    endif;
       //---------------------------------------------------------
       // run of 6s
       sRunOf6s = 0;
 1b    if RemainingCnt >= 6;
 2b       for a1 = 1      to RemainingCnt;
 3b          for a2 = (a1 + 1) to RemainingCnt;
 4b             for a3 = (a2 + 1) to RemainingCnt;
 5b                for a4 = (a3 + 1) to RemainingCnt;
 6b                   for a5 = (a4 + 1) to RemainingCnt;
 7b                      for a6 = (a5 + 1) to RemainingCnt;
 8b                         if TstCard(a1) = TstCard(a2) + 1
                               and TstCard(a1) = TstCard(a3) + 2
                               and TstCard(a1) = TstCard(a4) + 3
                               and TstCard(a1) = TstCard(a5) + 4
                               and TstCard(a1) = TstCard(a6) + 5;
                               sRunOf6s += 1;
                               RunCard(a1) = 0;
                               RunCard(a2) = 0;
                               RunCard(a3) = 0;
                               RunCard(a4) = 0;
                               RunCard(a5) = 0;
                               RunCard(a6) = 0;
 8e                         endif;
 7e                      endfor;
 6e                   endfor;
 5e                endfor;
 4e             endfor;
 3e          endfor;
 2e       endfor;
 1e    endif;
       //---------------------------------------------------------
       // run of 6s
 1b    if sRunOf6s > 0;
          sorta RunDeck;
          TstDeck = RunDeck;
 2b       for a1 = 1 to 8;
 3b          if TstCard(a1) = 0;
                RemainingCnt = (a1 - 1);
 2v             leave;
 3e          endif;
 2e       endfor;
 1e    endif;
       //---------------------------------------------------------
       // run of 5s
       sRunOf5s = 0;
 1b    if RemainingCnt >= 5;
 2b       for a1 = 1      to RemainingCnt;
 3b          for a2 = (a1 + 1) to RemainingCnt;
 4b             for a3 = (a2 + 1) to RemainingCnt;
 5b                for a4 = (a3 + 1) to RemainingCnt;
 6b                   for a5 = (a4 + 1) to RemainingCnt;
 7b                      if TstCard(a1) = TstCard(a2) + 1
                            and TstCard(a1) = TstCard(a3) + 2
                            and TstCard(a1) = TstCard(a4) + 3
                            and TstCard(a1) = TstCard(a5) + 4;
                            sRunOf5s += 1;
 8b                         if ShowScoreSbf = 'YES';
                               sbfscMsg = 'Run of 5 for 5';
                               CardCount = 5;
                               exsr srLoadSbfRec;
 8e                         endif;
                            RunCard(a1) = 0;
                            RunCard(a2) = 0;
                            RunCard(a3) = 0;
                            RunCard(a4) = 0;
                            RunCard(a5) = 0;
 7e                      endif;
 6e                   endfor;
 5e                endfor;
 4e             endfor;
 3e          endfor;
 2e       endfor;
 1e    endif;
       //---------------------------------------------------------
       // Run of 5s
 1b    if sRunOf5s > 0;
          sorta RunDeck;
          TstDeck = RunDeck;
 2b       for a1 = 1 to 8;
 3b          if TstCard(a1) = 0;
                RemainingCnt = (a1 - 1);
 2v             leave;
 3e          endif;
 2e       endfor;
 1e    endif;
       //---------------------------------------------------------
       // run of 4s
       sRunOf4s = 0;
 1b    if RemainingCnt >= 4;
 2b       for a1 = 1      to RemainingCnt;
 3b          for a2 = (a1 + 1) to RemainingCnt;
 4b             for a3 = (a2 + 1) to RemainingCnt;
 5b                for a4 = (a3 + 1) to RemainingCnt;
 6b                   if TstCard(a1) = TstCard(a2) + 1
                         and TstCard(a1) = TstCard(a3) + 2
                         and TstCard(a1) = TstCard(a4) + 3;
                         sRunOf4s += 1;
 7b                      if ShowScoreSbf = 'YES';
                            sbfscMsg = 'Run of 4 for 4';
                            CardCount = 4;
                            exsr srLoadSbfRec;
 7e                      endif;
                         RunCard(a1) = 0;
                         RunCard(a2) = 0;
                         RunCard(a3) = 0;
                         RunCard(a4) = 0;
 6e                   endif;
 5e                endfor;
 4e             endfor;
 3e          endfor;
 2e       endfor;
 1e    endif;
       //---------------------------------------------------------
       // Run of 4s
 1b    if sRunOf4s > 0;
          sorta RunDeck;
          TstDeck = RunDeck;
 2b       for a1 = 1 to 8;
 3b          if TstCard(a1) = 0;
                RemainingCnt = (a1 - 1);
 2v             leave;
 3e          endif;
 2e       endfor;
 1e    endif;
       //---------------------------------------------------------
       // run of 3s
       sRunOf3s = 0;
 1b    if RemainingCnt >= 3;
 2b       for a1 = 1      to RemainingCnt;
 3b          for a2 = (a1 + 1) to RemainingCnt;
 4b             for a3 = (a2 + 1) to RemainingCnt;
 5b                if TstCard(a1) = TstCard(a2) + 1
                      and TstCard(a1) = TstCard(a3) + 2;
                      sRunOf3s += 1;
 6b                   if ShowScoreSbf = 'YES';
                         sbfscMsg = 'Run of 3 for 3';
                         CardCount = 3;
                         exsr srLoadSbfRec;
 6e                   endif;
 5e                endif;
 4e             endfor;
 3e          endfor;
 2e       endfor;
 1e    endif;
 
       //---------------------------------------------------------
       // subroutine to add up total score and load bar graph
       //---------------------------------------------------------
       exsr srGetBarScore;
 1b    if ShowScoreSbf = 'YES';
          sbfTotal = HandScore;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Reshow hands after Play is complete
       //---------------------------------------------------------
       begsr srReShowHands;
       sorta cPlay4; // show craigs hand in numerical sequence
 
       Attr(1).Row(1).Col(*) = %bitor(WHITE: PR: UL);
       Attr(3).Row(1).Col(*) = %bitor(WHITE: PR: UL);
 1b    for ax = 1 to 4;
          Face(1).Row(1).Col(ax) = f_GetCardFace(cFace4(ax));
          Attr(1).Row(2).Col(ax) = f_GetCardColor(cSuite4(ax));
          Attr(1).Row(3).Col(ax) = f_GetCardColor(cSuite4(ax));
          Face(3).Row(1).Col(ax) = f_GetCardFace(uFace4(ax));
          Attr(3).Row(2).Col(ax) = f_GetCardColor(uSuite4(ax));
          Attr(3).Row(3).Col(ax) = f_GetCardColor(uSuite4(ax));
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       begsr srCheckExit;
 1b    if InfdsFkey = f03 or InfdsFkey = f12;
          *inlr = *on;
          return;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // King, Queen and Jack card values count as 10
       //---------------------------------------------------------
       dcl-proc f_KQJcount10;
        dcl-pi *n uns(3);
         p_Num1to13 uns(3) const;
        end-pi;
 
 1b     if p_Num1to13 > 10;
           return 10;
 1x     else;
           return %uns(p_Num1to13);
 1e     endif;
       end-proc;
