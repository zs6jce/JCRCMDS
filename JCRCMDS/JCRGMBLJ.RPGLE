       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRGMBLJ - Black Jack 21
       //---------------------------------------------------------
       /define ControlStatements
       /define Dspatr
       /define FunctionKeys
       /define f_GetCardFace
       /define f_ShuffleDeck
       /define f_GetDayName
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRGMBLJD workstn infds(infds) indds(ind);
       dcl-ds Infds;
        InfdsFkey char(1) pos(369);
       end-ds;
 
       dcl-s PlayerHas uns(3);
       dcl-s DealerShow uns(3);
       dcl-s yy uns(3);
       dcl-s yyAlpha char(3);
       dcl-s Color char(1);
       dcl-s CardFace char(2);
       dcl-s DealerDownCrd char(2);
       dcl-s DeckArry char(2) dim(52);
       dcl-s hh uns(3);
       dcl-s Dealer uns(3) inz(1);
       dcl-s Player uns(3) inz(2);
       dcl-s Card uns(3);
       dcl-s row uns(3);
       dcl-s col uns(3);
       dcl-s Deal uns(3);
       dcl-s HandValue uns(3);
       dcl-s NxtCardDealt uns(3);
       dcl-s NxtDealerCard uns(3);
       dcl-s NxtPlayerCard uns(3);
       dcl-s IsCompleted ind;
 
       // card faces and screen field attributes 4d array
       dcl-ds Hand dim(2) qualified based(ptr);
        Card dim(6) likeds(CardDS);
       end-ds;
 
       dcl-ds CardDS qualified;
        row dim(3) likeds(ColumnDS);
       end-ds;
 
       dcl-ds ColumnDS qualified;
        col char(1) dim(3);
       end-ds;
 
       dcl-s ptr pointer inz(%addr(s0111));
 
       //------------------------------------------------------
       dcl-ds HandA dim(2) likeds(Hand) based(ptr2);
       dcl-s  ptr2 pointer inz(%addr(s0111a));
 
       // Card ID attributes at top and bottom of card 2d array
       dcl-ds CardIdA dim(2) qualified;
        Card char(1) dim(6);
       end-ds;
 
       // Card ID values 2d array
       dcl-ds CardId dim(2) qualified;
        Card char(2) dim(6);
       end-ds;
 
       // card outline border attributes 2d array
       dcl-ds BorderA dim(2) qualified based(ptr5);
        Card char(1) dim(6);
       end-ds;
       dcl-s ptr5 pointer inz(%addr(Border1A));
 
       // large hand values 2d array
       dcl-ds Big dim(7) qualified;
        col char(1) dim(4);
       end-ds;
       dcl-ds BigA dim(7) likeds(Big);
 
       dcl-ds Deal10s dim(7) likeds(Big) based(ptr8); // 10s position
       dcl-s ptr8 pointer inz(%addr(D111));
 
       dcl-ds Deal10sA dim(7) likeds(Big) based(ptr9);
       dcl-s ptr9 pointer inz(%addr(D111a));
 
       dcl-ds Deal1s dim(7) likeds(Big) based(ptr10); // 1s position
       dcl-s ptr10 pointer inz(%addr(D211));
 
       dcl-ds Deal1sA dim(7) likeds(Big) based(ptr11);
       dcl-s ptr11 pointer inz(%addr(D211a));
 
       dcl-ds User10s dim(7) likeds(Big) based(ptr13); // 10s
       dcl-s ptr13 pointer inz(%addr(U111));
 
       dcl-ds User10sA dim(7) likeds(Big) based(ptr14);
       dcl-s ptr14 pointer inz(%addr(U111a));
 
       dcl-ds User1s dim(7) likeds(Big) based(ptr15); // 1s
       dcl-s ptr15 pointer inz(%addr(U211));
 
       dcl-ds User1sA dim(7) likeds(Big) based(ptr16);
       dcl-s ptr16 pointer inz(%addr(U211a));
 
       // map screen fields into DS so arrays can manipulate values
       dcl-ds *n inz;
       // card value sum
        d111;
        d112;
        d113;
        d114;
        d121;
        d122;
        d123;
        d124;
        d131;
        d132;
        d133;
        d134;
        d141;
        d142;
        d143;
        d144;
        d151;
        d152;
        d153;
        d154;
        d161;
        d162;
        d163;
        d164;
        d171;
        d172;
        d173;
        d174;
        d211;
        d212;
        d213;
        d214;
        d221;
        d222;
        d223;
        d224;
        d231;
        d232;
        d233;
        d234;
        d241;
        d242;
        d243;
        d244;
        d251;
        d252;
        d253;
        d254;
        d261;
        d262;
        d263;
        d264;
        d271;
        d272;
        d273;
        d274;
        d111a;
        d112a;
        d113a;
        d114a;
        d121a;
        d122a;
        d123a;
        d124a;
        d131a;
        d132a;
        d133a;
        d134a;
        d141a;
        d142a;
        d143a;
        d144a;
        d151a;
        d152a;
        d153a;
        d154a;
        d161a;
        d162a;
        d163a;
        d164a;
        d171a;
        d172a;
        d173a;
        d174a;
        d211a;
        d212a;
        d213a;
        d214a;
        d221a;
        d222a;
        d223a;
        d224a;
        d231a;
        d232a;
        d233a;
        d234a;
        d241a;
        d242a;
        d243a;
        d244a;
        d251a;
        d252a;
        d253a;
        d254a;
        d261a;
        d262a;
        d263a;
        d264a;
        d271a;
        d272a;
        d273a;
        d274a;
        u111;
        u112;
        u113;
        u114;
        u121;
        u122;
        u123;
        u124;
        u131;
        u132;
        u133;
        u134;
        u141;
        u142;
        u143;
        u144;
        u151;
        u152;
        u153;
        u154;
        u161;
        u162;
        u163;
        u164;
        u171;
        u172;
        u173;
        u174;
        u211;
        u212;
        u213;
        u214;
        u221;
        u222;
        u223;
        u224;
        u231;
        u232;
        u233;
        u234;
        u241;
        u242;
        u243;
        u244;
        u251;
        u252;
        u253;
        u254;
        u261;
        u262;
        u263;
        u264;
        u271;
        u272;
        u273;
        u274;
        u111a;
        u112a;
        u113a;
        u114a;
        u121a;
        u122a;
        u123a;
        u124a;
        u131a;
        u132a;
        u133a;
        u134a;
        u141a;
        u142a;
        u143a;
        u144a;
        u151a;
        u152a;
        u153a;
        u154a;
        u161a;
        u162a;
        u163a;
        u164a;
        u171a;
        u172a;
        u173a;
        u174a;
        u211a;
        u212a;
        u213a;
        u214a;
        u221a;
        u222a;
        u223a;
        u224a;
        u231a;
        u232a;
        u233a;
        u234a;
        u241a;
        u242a;
        u243a;
        u244a;
        u251a;
        u252a;
        u253a;
        u254a;
        u261a;
        u262a;
        u263a;
        u264a;
        u271a;
        u272a;
        u273a;
        u274a;
        Border1a;
        Border2a;
        Border3a;
        Border4a;
        Border5a;
        Border6a;
        Border7a;
        Border8a;
        Border9a;
        Border10a;
        Border11a;
        Border12a;
       // Card Faces
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
        s0611;
        s0612;
        s0613;
        s0621;
        s0622;
        s0623;
        s0631;
        s0632;
        s0633;
        s0711;
        s0712;
        s0713;
        s0721;
        s0722;
        s0723;
        s0731;
        s0732;
        s0733;
        s0811;
        s0812;
        s0813;
        s0821;
        s0822;
        s0823;
        s0831;
        s0832;
        s0833;
        s0911;
        s0912;
        s0913;
        s0921;
        s0922;
        s0923;
        s0931;
        s0932;
        s0933;
        s1011;
        s1012;
        s1013;
        s1021;
        s1022;
        s1023;
        s1031;
        s1032;
        s1033;
        s1111;
        s1112;
        s1113;
        s1121;
        s1122;
        s1123;
        s1131;
        s1132;
        s1133;
        s1211;
        s1212;
        s1213;
        s1221;
        s1222;
        s1223;
        s1231;
        s1232;
        s1233;
       // card face attributes
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
        s0611a;
        s0612a;
        s0613a;
        s0621a;
        s0622a;
        s0623a;
        s0631a;
        s0632a;
        s0633a;
        s0711a;
        s0712a;
        s0713a;
        s0721a;
        s0722a;
        s0723a;
        s0731a;
        s0732a;
        s0733a;
        s0811a;
        s0812a;
        s0813a;
        s0821a;
        s0822a;
        s0823a;
        s0831a;
        s0832a;
        s0833a;
        s0911a;
        s0912a;
        s0913a;
        s0921a;
        s0922a;
        s0923a;
        s0931a;
        s0932a;
        s0933a;
        s1011a;
        s1012a;
        s1013a;
        s1021a;
        s1022a;
        s1023a;
        s1031a;
        s1032a;
        s1033a;
        s1111a;
        s1112a;
        s1113a;
        s1121a;
        s1122a;
        s1123a;
        s1131a;
        s1132a;
        s1133a;
        s1211a;
        s1212a;
        s1213a;
        s1221a;
        s1222a;
        s1223a;
        s1231a;
        s1232a;
        s1233a;
       end-ds;
 
       // name screen indicators
       dcl-ds ind qualified;
        IsStand ind pos(06);
       end-ds;
 
       dcl-ds CurrCard qualified;
        NumVal uns(3) inz;
        Suite char(1);
       end-ds;
 
       //---------------------------------------------------------
       // Load Splash alt red-blue strips. Load BLACK JACK to card face.
       IsCompleted = *on;
       Hand(*) = *all' ';
       HandA(*) = *allx'00';
       CardIdA(*) = *allx'00';
       CardId(*) = *all' ';
       Credits = 100;
       hh = Dealer;
       Hand(hh).Card(1) = *all'B';
       CardId(hh).Card(1) = 'B';
       Hand(hh).Card(2) = *all'L';
       CardId(hh).Card(2) = 'L';
       Hand(hh).Card(3) = *all'A';
       CardId(hh).Card(3) = 'A';
       Hand(hh).Card(4) = *all'C';
       CardId(hh).Card(4) = 'C';
       Hand(hh).Card(5) = *all'K';
       CardId(hh).Card(5) = 'K';
       Hand(hh).Card(6) = *all' ';
       CardId(hh).Card(6) = '  ';
       hh = Player;
       Hand(hh).Card(1) = *all'J';
       CardId(hh).Card(1) = 'J';
       Hand(hh).Card(2) = *all'A';
       CardId(hh).Card(2) = 'A';
       Hand(hh).Card(3) = *all'C';
       CardId(hh).Card(3) = 'C';
       Hand(hh).Card(4) = *all'K';
       CardId(hh).Card(4) = 'K';
       Hand(hh).Card(5) = *all'2';
       CardId(hh).Card(5) = '2';
       Hand(hh).Card(6) = *all'1';
       CardId(hh).Card(6) = '1';
       scDow = f_GetDayName();
 
       //-load card colors----------
 1b    for hh = Dealer to Player;
 2b       for Card = 1 to 6;
 3b          if Card = 1 or Card = 5;
                Color = %bitor(RED: RI);
 3x          elseif Card = 2 or Card = 6;
                Color = %bitor(WHITE: RI);
 3x          elseif Card = 3;
                Color = %bitor(YELLOW: RI);
 3x          elseif Card = 4;
                Color = %bitor(BLUE: RI);
 3e          endif;
             BorderA(hh).Card(Card) = Color;
 3b          for row = 1 to 3;
                HandA(hh).Card(Card).Row(row).Col(*) = Color;
 3e          endfor;
 2e       endfor;
 1e    endfor;
 
       DealerShow = 21;
       PlayerHas = 21;
 
       //---------------------------------------------------------
       // Play the game.
 1b    dou 1 = 2;
 
 2b       if DealerShow > 0;
             exsr srShowBigTot;
 2e       endif;
 
          exfmt screen;
 2b       if InfdsFkey = f03 or InfdsFkey = f12;
             *inlr = *on;
             return;
 2e       endif;
 
          // If current hand is completed, reset all for next hand.
          // Load new hands to restart game.
 2b       if IsCompleted;
             exsr srNextHand;
 2x       elseif InfdsFkey = f02;
             exsr srStand;
 2x       else;
             exsr srHitPlayer1Card;
 2e       endif;
 1e    enddo;
 
       //---------------------------------------------------------
       // Stand.  first turn up dealer down card
       // Evaluate total in dealers hand.
       // If < 17, deal computer cards until count is greater 17 or busted.
       //---------------------------------------------------------
       begsr srStand;
       hh = Dealer;
       Card = 1;
       CurrCard = DealerDownCrd;
       exsr srLoadCardFace;
       exsr srCalcHandValue;
       DealerShow = Handvalue;
       exsr srShowBigTot;
       write screen;
 
 1b    dow DealerShow < 17
          and DealerShow < PlayerHas;
          NxtDealerCard += 1;
          Card = NxtDealerCard;
          NxtCardDealt += 1;
          CurrCard = DeckArry(NxtCardDealt);
          exsr srLoadCardFace;
          exsr srCalcHandValue;
          DealerShow = Handvalue;
          exsr srShowBigTot;
          write screen;
 2b       if NxtDealerCard = 6;
 1v          leave;
 2e       endif;
 1e    enddo;
 
       //---------------------------------------------------------
       // Now the moment of truth!  Who won?-
       //---------------------------------------------------------
 1b    if DealerShow > 21;  //dealer BUSTED!
          PlayerMsg = '** W I N N E R **';
          PlayerMsgA = %bitor(WHITE: RI);
          DealerMsg = '**DEALER BUSTED**';
          DealerMsgA = %bitor(RED: HI: RI);
          hh = Player;
          exsr srWinnerBorderColor;
          credits += YouBet;
          Youbet = 0;
 
 1x    elseif DealerShow < PlayerHas;  //Player Won
          PlayerMsg = '** W I N N E R **';
          PlayerMsgA = %bitor(WHITE: RI);
          DealerMsg = *blanks;
          DealerMsgA = x'00';
          credits += YouBet;
          Youbet = 0;
          hh = Player;
          exsr srWinnerBorderColor;
 
 1x    elseif DealerShow > PlayerHas;  //Dealer Won
          DealerMsg = '** DEALER WINS **';
          DealerMsgA = %bitor(WHITE: RI);
          PlayerMsg = *blanks;
          PlayerMsgA = x'00';
          hh = Dealer;
          exsr srWinnerBorderColor;
          credits -= YouBet;
          Youbet = 0;
 
 1x    elseif DealerShow = PlayerHas;  //Tie
          DealerMsg = '** T I E       **';
          DealerMsgA = %bitor(WHITE: RI);
          PlayerMsg = '** BET DOUBLED **';
          PlayerMsgA = %bitor(WHITE: RI);
 2b       for hh = Dealer to Player;
             exsr srWinnerBorderColor;
 2e       endfor;
 1e    endif;
 
       ind.IsStand = *off;
       IsCompleted = *on;
       endsr;
 
       //---------------------------------------------------------
       // Deal next hand. Reset messages and load new deck of cards.
       //---------------------------------------------------------
       begsr srNextHand;
       Hand(*) = *all' ';
       HandA(*) = *allx'00';
       CardIdA(*) = *allx'00';
       CardId(*) = *all' ';
 1b    for hh = Dealer to Player;
 2b       for Card = 1 to 6;
             BorderA(hh).Card(Card) = ND;
 2e       endfor;
 1e    endfor;
       DealerMsg = *blanks;
       DealerMsgA = x'00';
       PlayerMsg = *blanks;
       PlayerMsgA = x'00';
       PlayerHas = 0;
       DealerShow = 0;
       YouBet += 10;
       NxtPlayerCard = 2;
       NxtDealerCard = 2;
       NxtCardDealt = 4;
       IsCompleted = *off;
       ind.IsStand = *on;
       DeckArry = f_ShuffleDeck();  //sort deck
       exsr srDeal2Cards;  //deal 1st hand
       hh = Dealer;
       exsr srCalcHandValue;
       DealerShow = Handvalue;
       hh = Player;
       exsr srCalcHandValue;
       PlayerHas = Handvalue;
       endsr;
 
       //---------------------------------------------------------
       // Deal player next card from deck.
       //---------------------------------------------------------
       begsr srHitPlayer1Card;
       hh = Player;
       NxtPlayerCard += 1;
 1b    if NxtPlayerCard < 7;
          Card = NxtPlayerCard;
          NxtCardDealt += 1;
          CurrCard = DeckArry(NxtCardDealt);
          exsr srLoadCardFace;
 1e    endif;
       exsr srCalcHandValue;
       PlayerHas = Handvalue;
 
       //---------------------------------------------------------
       // See if greedy overachieving player went past 21.
       // 1. Load busted message.
       // 2. Turn Over dealer Face card, and load dealers hand value.
       // 3. Load dealer wins message.
       // 4. Subtract out lost bet
       // 5  set complete flag to reset screen for next hand
       //---------------------------------------------------------
 1b    if PlayerHas > 21;  //BUSTED!
          PlayerMsg = '** B U S T E D **';
          PlayerMsgA = %bitor(RED: RI: HI);
          DealerMsg = '** DEALER WINS **';
          DealerMsgA = %bitor(WHITE: RI);
          hh = Dealer;
          Card = 1;
          CurrCard = DealerDownCrd;
 2b       for row = 1 to 3;
             Hand(hh).Card(Card).Row(row) = *all' ';
             HandA(hh).Card(Card).Row(row) = *allx'00';
 2e       endfor;
          exsr srLoadCardFace;
          exsr srCalcHandValue;
          DealerShow = Handvalue;
          Credits -= YouBet;
          Youbet = 0;
          hh = Dealer;
          exsr srWinnerBorderColor;
          ind.IsStand = *off;
          IsCompleted = *on;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       begsr srWinnerBorderColor;
       //---------------------------------------------------------
 1b    for Card = 1 to 6;
 2b       if CardId(hh).Card(Card) = '  ';
 1v          leave;
 2e       endif;
 
          BorderA(hh).Card(Card) = CardIdA(hh).Card(Card);
 
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // Problem here is ACE can count 1 or 11.
       // Cannot accumulate values of cards as they
       // are dealt as ACE = 11 till player goes over 21
       //---------------------------------------------------------
       begsr srCalcHandValue;
       HandValue = 0;
 
 1b    for Card = 1 to 6;
 2b       if CardId(hh).Card(Card) = '  ';
 1v          leave;
 2e       endif;
 
 2b       if CardId(hh).Card(Card) = 'A1';
             HandValue += 1;
 2x       elseif CardId(hh).Card(Card) = 'A';
             HandValue += 11;
          elseif CardId(hh).Card(Card) = 'J'
             or CardId(hh).Card(Card) = 'Q'
             or CardId(hh).Card(Card) = 'K';
             HandValue += 10;
 2x       elseif CardId(hh).Card(Card) <> '**';
              HandValue += %int(CardId(hh).Card(Card));
 2e       endif;
 1e    endfor;
 
       //---------------------------------------------------------
       // if hand value is over 21, cycle back through
       //  and see if any Aces can be valued at 1.
       //---------------------------------------------------------
 1b    if HandValue > 21;
 2b       for Card = 1 to 6;  //spin through cards
 3b          if CardId(hh).Card(Card) = 'A';
                CardId(hh).Card(Card) = 'A1';
                HandValue -= 10;
 2v             leave;
 3e          endif;
 2e       endfor;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Deal 2 cards to players and computers hand.
       //---------------------------------------------------------
       begsr srDeal2Cards;
       hh = Player;
       Card = 0;
 1b    for Deal = 1 by 2 to 3;  //deal 1 & 3
          Card += 1;
          CurrCard = DeckArry(Deal);
          exsr srLoadCardFace;
 1e    endfor;
 
       //---------------------------------------------------------
       // Save first card dealt to dealer as that is the 'down' card.
       //---------------------------------------------------------
       hh = Dealer;
       Card = 0;
 1b    for Deal = 2 by 2 to 4;  //deal 2 & 4
          Card += 1;
          CurrCard = DeckArry(Deal);
 2b       if Card = 1;  //dealer down card
             DealerDownCrd = CurrCard;
             exsr srLoadDownCard;
 2x       elseif Card = 2;
             exsr srLoadCardFace;
 2e       endif;
 1e    endfor;
       Card = 0;
       endsr;
 
       //---------------------------------------------------------
       // Make dealers 1st card appear as down card.
       //---------------------------------------------------------
       begsr srLoadDownCard;
       CardId(hh).Card(Card) = '**';
       BorderA(hh).Card(Card) = Blue;
 1b    for row = 1 to 3;
 2b       for col = 1 to 3;
             HandA(hh).Card(Card).Row(row).Col(col) = %bitor(Red: RI);
 3b          if col = 2;
                HandA(hh).Card(Card).Row(row).Col(col) = %bitor(Blue: RI);
 3e          endif;
 2e       endfor;
 1e    endfor;
       Hand(hh).Card(Card).Row(1).Col(*) = '*';
       Hand(hh).Card(Card).Row(2).Col(*) = '*';
       Hand(hh).Card(Card).Row(3).Col(*) = '*';
       endsr;
 
       //---------------------------------------------------------
       // Load card images to screen
       //---------------------------------------------------------
       begsr srLoadCardFace;
       CardFace = f_GetCardFace(CurrCard.NumVal);
       CardId(hh).Card(Card) = CardFace;
 1b    if CardFace = 'A' or CardFace = 'A1';
          Hand(hh).Card(Card).Row(*) = 'A A';
          Color = %bitor(Red: RI);
 1x    elseif CardFace = 'K';
          Hand(hh).Card(Card).Row(*) = 'K K';
          Color = %bitor(Yellow: RI);
 1x    elseif CardFace = 'Q';
          Hand(hh).Card(Card).Row(*) = 'Q Q';
          Color = %bitor(White: RI);
 1x    elseif CardFace = 'J';
          Hand(hh).Card(Card).Row(*) = 'J J';
          Color = %bitor(Green: RI);
 1x    elseif CardFace = '10';
          Hand(hh).Card(Card).Row(*) = '1 0';
          Color = %bitor(Red: RI);
 1x    elseif CardFace = '9';
          Hand(hh).Card(Card).Row(*) = '999';
          Color = %bitor(Blue:RI);
 1x    elseif CardFace = '8';
          Hand(hh).Card(Card).Row(1) = '888';
          Hand(hh).Card(Card).Row(2) = '8 8';
          Hand(hh).Card(Card).Row(3) = '888';
          Color = %bitor(Yellow: RI);
 1x    elseif CardFace = '7';
          Hand(hh).Card(Card).Row(1) = '777';
          Hand(hh).Card(Card).Row(2) = ' 7 ';
          Hand(hh).Card(Card).Row(3) = '777';
          Color = %bitor(White: RI);
 1x    elseif CardFace = '6';
          Hand(hh).Card(Card).Row(1) = '666';
          Hand(hh).Card(Card).Row(2) = '    ';
          Hand(hh).Card(Card).Row(3) = '666';
          Color = %bitor(Green: RI);
 1x    elseif CardFace = '5';
          Hand(hh).Card(Card).Row(1) = '5 5';
          Hand(hh).Card(Card).Row(2) = ' 5 ';
          Hand(hh).Card(Card).Row(3) = '5 5';
          Color = %bitor(Red: RI);
 1x    elseif CardFace = '4';
          Hand(hh).Card(Card).Row(1) = '4 4';
          Hand(hh).Card(Card).Row(2) = '   ';
          Hand(hh).Card(Card).Row(3) = '4 4';
          Color = %bitor(Blue:RI);
 1x    elseif CardFace = '3';
          Hand(hh).Card(Card).Row(1) = '3  ';
          Hand(hh).Card(Card).Row(2) = ' 3 ';
          Hand(hh).Card(Card).Row(3) = '  3';
          Color = %bitor(Yellow: RI);
 1x    elseif CardFace = '2';
          Hand(hh).Card(Card).Row(1) = '2  ';
          Hand(hh).Card(Card).Row(2) = '   ';
          Hand(hh).Card(Card).Row(3) = '  2';
          Color = %bitor(White: RI);
 1e    endif;
 
       CardIdA(hh).Card(Card) = Color;
 1b    for row = 1 to 3;
 2b       for col = 1 to 3;
 3b          if Hand(hh).Card(Card).Row(row).Col(col) = ' ';
                HandA(hh).Card(Card).Row(row).Col(col) = x'00';
 3x          else;
                HandA(hh).Card(Card).Row(row).Col(col) = Color;
 3e          endif;
 2e       endfor;
 1e    endfor;
       BorderA(hh).Card(Card) = White;
       endsr;
 
       //---------------------------------------------------------
       // show card values in large characters
       //---------------------------------------------------------
       begsr srShowBigTot;
       evalr yyAlpha = '000' + %char(DealerShow);
       yy = %dec(%subst(yyAlpha:3:1) :1 :0);
       exsr srColorBig;
       Deal1s(*) = Big(*);
       Deal1sA(*) = BigA(*);
 
       yy = %dec(%subst(yyAlpha:2:1) :1 :0);
 1b    if yy = 0;  // zero suppress
 2b       for yy = 1 to 7;
             Deal10s(yy).col(*) = *blanks;
             Deal10sA(yy).col(*) = ND;
 2e       endfor;
 1x    else;
          exsr srColorBig;
          Deal10s(*) = Big(*);
          Deal10sA(*) = BigA(*);
 1e    endif;
 
       evalr yyAlpha = '000' + %char(PlayerHas);
       yy = %dec(%subst(yyAlpha:3:1) :1 :0);
       exsr srColorBig;
       User1s(*) = Big(*);
       User1sA(*) = BigA(*);
 
       yy = %dec(%subst(yyAlpha:2:1) :1 :0);
 1b    if yy = 0;  // zero suppress
 2b       for yy = 1 to 7;
             User10s(yy).col(*) = *blanks;
             User10sA(yy).col(*) = ND;
 2e       endfor;
 1x    else;
          exsr srColorBig;
          User10s(*) = Big(*);
          User10sA(*) = BigA(*);
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       begsr srColorBig;
       Big = f_LoadBig(yy);
 1b    for row = 1 to 7;
 2b       for col = 1 to 4;
 3b          if Big(row).Col(col) > ' ';
                BigA(row).Col(col) = %bitor(Blue: RI);
 3x          else;
                BigA(row).Col(col) = ND;
 3e          endif;
 2e       endfor;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       // Return 4 row X 7 column array
       dcl-proc f_LoadBig;
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
           Line(*) = '  1 ';
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
           Line(1) = '8888';
           Line(2) = '8  8';
           Line(3) = '8  8';
           Line(4) = '8888';
           Line(5) = '8  8';
           Line(6) = '8  8';
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
