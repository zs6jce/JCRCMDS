       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRGMPOK - Video Poker
       //---------------------------------------------------------
       /define ControlStatements
       /define Dspatr
       /define FunctionKeys
       /define f_GetCardFace
       /define f_GetCardColor
       /define f_ShuffleDeck
       /define f_GetDayName
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRGMPOKD workstn infds(infds) indds(ind);
       dcl-ds Infds;
        InfdsFkey char(1) pos(369);
       end-ds;
 
       dcl-s Color char(1);
       dcl-s NewDeck char(2) dim(52);
       dcl-s ac uns(3);
       dcl-s AceBucket uns(3);
       dcl-s ax uns(3);
       dcl-s Deal uns(3);
       dcl-s JackBucket uns(3);
       dcl-s KingBucket uns(3);
       dcl-s QueenBucket uns(3);
       dcl-s xx uns(3);
       dcl-s IsFlush ind;
       dcl-s IsRoyalStraight ind;
       dcl-s IsStraight ind;
 
       dcl-ds *n;
        UserHand char(2) dim(5) ascend;
        UserCard uns(3) overlay(Userhand:1);
        UserSuite char(1) overlay(UserHand:*next);
       end-ds;
 
       // Name screen indicators
       dcl-ds ind qualified;
        ScreenCtl ind pos(10);
       end-ds;
 
       // Card faces and Card attributes 3d array
       dcl-ds Face dim(5) qualified based(ptr1);
        row likeds(Rowx) dim(7);
       end-ds;
       dcl-ds Rowx qualified;
        col char(1) dim(4);
       end-ds;
       dcl-s ptr1 pointer inz(%addr(c111));
 
       dcl-ds Attr dim(5) likeds(Face) based(ptr2);
       dcl-s ptr2 pointer inz(%addr(c111a));
 
       // map screen fields into DS so pointers to data can overlay
       dcl-ds DisCardDS inz;
        DisCard1;
        DisCard2;
        DisCard3;
        DisCard4;
        DisCard5;
        DisCardArry char(1) dim(5) pos(1);
       end-ds;
 
       // Card Id field attribute array
       dcl-ds CardIdAtrDS;
        CardId1A;
        CardId2A;
        CardId3A;
        CardId4A;
        CardId5A;
        CardIdAtr char(1) dim(5) pos(1);
       end-ds;
 
       // Card Side Border attributes array
       dcl-ds BorderAtrDS;
        Border1A;
        Border2A;
        Border3A;
        Border4A;
        Border5A;
        BorderAtr char(1) dim(5) pos(1);
       end-ds;
 
       dcl-ds BorderTopBotDS;
        BorderTop1;
        BorderBot1 overlay(BorderTop1);
        BorderTop2;
        BorderBot2 overlay(BorderTop2);
        BorderTop3;
        BorderBot3 overlay(BorderTop3);
        BorderTop4;
        BorderBot4 overlay(BorderTop4);
        BorderTop5;
        BorderBot5 overlay(BorderTop5);
        BorderTopBot char(11) dim(5) pos(1);
       end-ds;
 
       // top and bottom Border attributes
       dcl-ds TopBotAtrDS;
        TopBot1A;
        TopBot2A;
        TopBot3A;
        TopBot4A;
        TopBot5A;
        TopBotAtr char(1) dim(5) pos(1);
       end-ds;
 
       dcl-ds CardIdDS;
        CVALT1;
        CVALT2;
        CVALT3;
        CVALT4;
        CVALT5;
        CardId char(2) dim(5) pos(1);
       end-ds;
 
       dcl-ds BorderSidesDS;
        Side11L;
        Side12L overlay(Side11L);
        Side13L overlay(Side11L);
        Side14L overlay(Side11L);
        Side15L overlay(Side11L);
        Side16L overlay(Side11L);
        Side17L overlay(Side11L);
        Side18L overlay(Side11L);
        Side19L overlay(Side11L);
        Side110L overlay(Side11L);
        Side111L overlay(Side11L);
        Side11R overlay(Side11L);
        Side12R overlay(Side11L);
        Side13R overlay(Side11L);
        Side14R overlay(Side11L);
        Side15R overlay(Side11L);
        Side16R overlay(Side11L);
        Side17R overlay(Side11L);
        Side18R overlay(Side11L);
        Side19R overlay(Side11L);
        Side110R overlay(Side11L);
        Side111R overlay(Side11L);
        Side21L;
        Side22L overlay(Side21L);
        Side23L overlay(Side21L);
        Side24L overlay(Side21L);
        Side25L overlay(Side21L);
        Side26L overlay(Side21L);
        Side27L overlay(Side21L);
        Side28L overlay(Side21L);
        Side29L overlay(Side21L);
        Side210L overlay(Side21L);
        Side211L overlay(Side21L);
        Side21R overlay(Side21L);
        Side22R overlay(Side21L);
        Side23R overlay(Side21L);
        Side24R overlay(Side21L);
        Side25R overlay(Side21L);
        Side26R overlay(Side21L);
        Side27R overlay(Side21L);
        Side28R overlay(Side21L);
        Side29R overlay(Side21L);
        Side210R overlay(Side21L);
        Side211R overlay(Side21L);
        Side31L;
        Side32L overlay(Side31L);
        Side33L overlay(Side31L);
        Side34L overlay(Side31L);
        Side35L overlay(Side31L);
        Side36L overlay(Side31L);
        Side37L overlay(Side31L);
        Side38L overlay(Side31L);
        Side39L overlay(Side31L);
        Side310L overlay(Side31L);
        Side311L overlay(Side31L);
        Side31R overlay(Side31L);
        Side32R overlay(Side31L);
        Side33R overlay(Side31L);
        Side34R overlay(Side31L);
        Side35R overlay(Side31L);
        Side36R overlay(Side31L);
        Side37R overlay(Side31L);
        Side38R overlay(Side31L);
        Side39R overlay(Side31L);
        Side310R overlay(Side31L);
        Side311R overlay(Side31L);
        Side41L;
        Side42L overlay(Side41L);
        Side43L overlay(Side41L);
        Side44L overlay(Side41L);
        Side45L overlay(Side41L);
        Side46L overlay(Side41L);
        Side47L overlay(Side41L);
        Side48L overlay(Side41L);
        Side49L overlay(Side41L);
        Side410L overlay(Side41L);
        Side411L overlay(Side41L);
        Side41R overlay(Side41L);
        Side42R overlay(Side41L);
        Side43R overlay(Side41L);
        Side44R overlay(Side41L);
        Side45R overlay(Side41L);
        Side46R overlay(Side41L);
        Side47R overlay(Side41L);
        Side48R overlay(Side41L);
        Side49R overlay(Side41L);
        Side410R overlay(Side41L);
        Side411R overlay(Side41L);
        Side51L;
        Side52L overlay(Side51L);
        Side53L overlay(Side51L);
        Side54L overlay(Side51L);
        Side55L overlay(Side51L);
        Side56L overlay(Side51L);
        Side57L overlay(Side51L);
        Side58L overlay(Side51L);
        Side59L overlay(Side51L);
        Side510L overlay(Side51L);
        Side511L overlay(Side51L);
        Side51R overlay(Side51L);
        Side52R overlay(Side51L);
        Side53R overlay(Side51L);
        Side54R overlay(Side51L);
        Side55R overlay(Side51L);
        Side56R overlay(Side51L);
        Side57R overlay(Side51L);
        Side58R overlay(Side51L);
        Side59R overlay(Side51L);
        Side510R overlay(Side51L);
        Side511R overlay(Side51L);
        BorderSides char(1) dim(5) pos(1);
       end-ds;
 
       // Card Faces
       dcl-ds *n;
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
        C411;
        C412;
        C413;
        C414;
        C421;
        C422;
        C423;
        C424;
        C431;
        C432;
        C433;
        C434;
        C441;
        C442;
        C443;
        C444;
        C451;
        C452;
        C453;
        C454;
        C461;
        C462;
        C463;
        C464;
        C471;
        C472;
        C473;
        C474;
        C511;
        C512;
        C513;
        C514;
        C521;
        C522;
        C523;
        C524;
        C531;
        C532;
        C533;
        C534;
        C541;
        C542;
        C543;
        C544;
        C551;
        C552;
        C553;
        C554;
        C561;
        C562;
        C563;
        C564;
        C571;
        C572;
        C573;
       // Card face attributes
        C574;
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
        C411A;
        C412A;
        C413A;
        C414A;
        C421A;
        C422A;
        C423A;
        C424A;
        C431A;
        C432A;
        C433A;
        C434A;
        C441A;
        C442A;
        C443A;
        C444A;
        C451A;
        C452A;
        C453A;
        C454A;
        C461A;
        C462A;
        C463A;
        C464A;
        C471A;
        C472A;
        C473A;
        C474A;
        C511A;
        C512A;
        C513A;
        C514A;
        C521A;
        C522A;
        C523A;
        C524A;
        C531A;
        C532A;
        C533A;
        C534A;
        C541A;
        C542A;
        C543A;
        C544A;
        C551A;
        C552A;
        C553A;
        C554A;
        C561A;
        C562A;
        C563A;
        C564A;
        C571A;
        C572A;
        C573A;
        C574A;
       end-ds;
 
       //---------------------------------------------------------
       // Load initial splash screen to get game started
       scDow = f_GetDayName();
       Credits = 100;
       WonLost = 0;
       exsr srResetSides;
       Face(1).Row = f_LoadFace('P');
       Face(2).Row = f_LoadFace('O');
       Face(3).Row = f_LoadFace('K');
       Face(4).Row = f_LoadFace('E');
       Face(5).Row = f_LoadFace('R');
 1b    for ac = 1 to 5;
 2b       if ac = 1 or ac = 5;
             Color = %bitor(RED: RI);
 2x       elseif ac = 2;
             Color = %bitor(WHITE: RI);
 2x       elseif ac = 3;
             Color = %bitor(YELLOW: RI);
 2x       elseif ac = 4;
             Color = %bitor(BLUE: RI);
 2e       endif;
 
          TopBotAtr(ac) = Color;
          //-load Card colors----------
 2b       for ax = 1 to 7;  //Rows
             Attr(ac).Row(ax).Col(*) = Color;
 2e       endfor;
 1e    endfor;
 
       exfmt screen;
 1b    if InfdsFkey = f03 or InfdsFkey = f12;
          *inlr = *on;
          return;
 1e    endif;
 
       //---------------------------------------------------------
       // Play the game
       //---------------------------------------------------------
 1b    dou 1 = 2;
          NewDeck = f_ShuffleDeck();
 
          // Deal 5 Cards to users hand.
          // Sort hand by Card value then load images to screen.
          ax = 0;
 2b       for deal = 1 to 5;
             ax += 1;
             UserHand(ax) = NewDeck(Deal);
 2e       endfor;
          sorta UserHand;
          exsr srLoadUserScreen;
          exsr srEvalHandVal;
          Ind.ScreenCtl = *on;
          WonLost = 0;
          exfmt screen;
 2b       if InfdsFkey = f03 or InfdsFkey = f12;
 1v          leave;
 2e       endif;
 
          // Deal Cards from the deck to replace cards user has X ed
          ax = 5;
 2b       for deal = 1 to 5;
 3b          if DisCardArry(deal) > ' ';
                ax += 1;
                UserHand(Deal) = NewDeck(ax);
 3e          endif;
 2e       endfor;
          sorta UserHand;
          exsr srLoadUserScreen;
          clear disCardDS;
          exsr srEvalHandVal;
          exsr srCreditAdjust;
          Ind.ScreenCtl = *off;
          exfmt screen;
 2b       if InfdsFkey = f03 or InfdsFkey = f12;
 1v          leave;
 2e       endif;
 1e    enddo;
       *inlr = *on;
       return;
 
       //--------------------------------------------------
       // See what is highest value of hand and payout
       // Royal Flush   250: 1
       // Straight Flush 50: 1
       // Four of a kind 25: 1
       // Full House      8: 1
       // Flush           5: 1
       // Straight        4: 1
       // Three of a kind 3: 1
       // Two Pair        2: 1
       // Jacks or Better 1: 1
       //--------------------------------------------------
       begsr srEvalHandVal;
       HandValue = *blanks;
       IsFlush = *off;
       IsStraight = *off;
       IsRoyalStraight = *off;
 
       // Set Flush Flag
 1b    if UserSuite(1) = UserSuite(2)
          and UserSuite(1) = UserSuite(3)
          and UserSuite(1) = UserSuite(4)
          and UserSuite(1) = UserSuite(5);
          IsFlush = *on;
 1e    endif;
 
       // Set Straight Flag. Note an ACE can either be 1 or 11.
 1b    if UserCard(1) = UserCard(2) - 1
          and UserCard(1) = UserCard(3) - 2
          and UserCard(1) = UserCard(4) - 3
          and UserCard(1) = UserCard(5) - 4;
          IsStraight = *on;
 1e    endif;
 
 1b    if UserCard(1) = 1
          and UserCard(2) = 10
          and UserCard(3) = 11
          and UserCard(4) = 12
          and UserCard(5) = 13;
          IsRoyalStraight = *on;
 1e    endif;
 
       // Check for Straight Royal Flush
 1b    if IsFlush
          and IsRoyalStraight;
          HandValue = 'ROYAL FLUSH!  Pays 250 to 1';
          // set all Cards to reverse image outline
 2b       for ac = 1 to 5;
             exsr srReverseImageOutLine;
 2e       endfor;
 
          // Check for Straight Flush
 1x    elseif IsFlush
          and IsStraight;
          HandValue = 'STRAIGHT FLUSH!   Pays 50 to 1';
          // set all Cards to reverse image outline
 2b       for ac = 1 to 5;
             exsr srReverseImageOutLine;
 2e       endfor;
 
          // Check for 4 of a kind.  Either 1st four or last 4 must match
 1x    elseif (UserCard(1) = UserCard(2)
          or
          UserCard(4) = UserCard(5))
          and UserCard(2) = UserCard(3)
          and UserCard(2) = UserCard(4);
          HandValue = 'FOUR OF A KIND!   Pays 25 to 1';
          // Determine Cards to reverse image outline
 2b       for ac = 1 to 2;
 3b          if UserCard(ac) = UserCard(ac + 1);
                exsr srReverseImageOutLine;
                ac += 1;
                exsr srReverseImageOutLine;
                ac += 1;
                exsr srReverseImageOutLine;
                ac += 1;
                exsr srReverseImageOutLine;
 3e          endif;
 2e       endfor;
 
          // Check for Full House.  First 2 have to match and last 3 have to match
          // or first 3 have to match and last 2 have to match.
 1x    elseif (UserCard(1) = UserCard(2)
          and UserCard(3) = UserCard(4)
          and UserCard(3) = UserCard(5))
          or
          (UserCard(1) = UserCard(2)
          and UserCard(1) = UserCard(3)
          and UserCard(4) = UserCard(5));
          HandValue = 'FULL HOUSE!   Pays 8 to 1';
          // set all Cards to reverse image outline
 2b       for ac = 1 to 5;
             exsr srReverseImageOutLine;
 2e       endfor;
 
          // Check for Flush
 1x    elseif IsFlush;
          HandValue = 'FLUSH!  Pays 5 to 1';
          // set all Cards to reverse image outline
 2b       for ac = 1 to 5;
             exsr srReverseImageOutLine;
 2e       endfor;
 
          // Check for Straight
 1x    elseif IsStraight or IsRoyalStraight;
          HandValue = 'STRAIGHT!  Pays 4 to 1';
 
          // set all Cards to reverse image outline
 2b       for ac = 1 to 5;
             exsr srReverseImageOutLine;
 2e       endfor;
 
          // here Card 1,2,3 must match or 2,3,4 must match or 3,4,5 must match
 1x    elseif (UserCard(3) = UserCard(1)
          and UserCard(3) = UserCard(2))
          or
          (UserCard(3) = UserCard(2)
          and UserCard(3) = UserCard(4))
          or
          (UserCard(3) = UserCard(4)
          and UserCard(3) = UserCard(5));
          HandValue = '3 OF A KIND!  Pays 3 to 1';
 
          // Determine Cards to reverse image outline
 2b       for ac = 1 to 3;
 3b          if UserCard(ac) = UserCard(ac + 1);
                exsr srReverseImageOutLine;
                ac += 1;
                exsr srReverseImageOutLine;
                ac += 1;
                exsr srReverseImageOutLine;
 3e          endif;
 2e       endfor;
 
          // Check for 2 pairs
          // here Card if (1=2 then 3=4 or 4=5) or 2=3 and 4=5)
 1x    elseif (UserCard(1) = UserCard(2)
          and (UserCard(3) = UserCard(4)
          or
          UserCard(4) = UserCard(5)))
          or
          (UserCard(2) = UserCard(3)
          and UserCard(4) = UserCard(5));
          HandValue = '2 PAIR   Pays 2 to 1';
 
          // Determine Cards to reverse image outline
 2b       for ac = 1 to 4;
 3b          if UserCard(ac) = UserCard(ac + 1);
                exsr srReverseImageOutLine;
                ac += 1;
                exsr srReverseImageOutLine;
 3e          endif;
 2e       endfor;
 
          //---------------------------------------------------------
          // Check for 1 pair (any pair for now)
          // here Card 1=2 or 2=3 or 3=4 or 4=5)
          // To determine Jacks or better is again complicated by fact that aces
          // are represented by 1. If hand has two 1s, or 11s, or 12s, or 13s.
          // Fastest way might be to spin through array accumulating buckets.
          // If after loop if any bucket is > 2 then there are jacks or better.
          //---------------------------------------------------------
 1x    elseif UserCard(1) = UserCard(2) or
          UserCard(2) = UserCard(3) or
          UserCard(3) = UserCard(4) or
          UserCard(4) = UserCard(5);
          AceBucket = 0;
          JackBucket = 0;
          QueenBucket = 0;
          KingBucket = 0;
 2b       for ax = 1 to 5;
 3b          if UserCard(ax) = 1;
                AceBucket += 1;
 3x          elseif UserCard(ax) = 11;
                JackBucket += 1;
 3x          elseif UserCard(ax) = 12;
                QueenBucket += 1;
 3x          elseif UserCard(ax) = 13;
                KingBucket += 1;
 3e          endif;
 2e       endfor;
 
 2b       if AceBucket = 2
             or JackBucket = 2
             or QueenBucket = 2
             or KingBucket = 2;
             HandValue = 'JACKS OR BETTER.  Pays 1 to 1';
 2x       else;
             HandValue = 'PAIR    Need Jacks or Better.';
 2e       endif;
          // Determine Cards to reverse image outline
 2b       for ac = 1 to 4;
 3b          if UserCard(ac) = UserCard(ac + 1);
                exsr srReverseImageOutLine;
                ac += 1;
                exsr srReverseImageOutLine;
 3e          endif;
 2e       endfor;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // set Card outline to reverse image outline and same color as Card face
       begsr srReverseImageOutLine;
       TopBotAtr(ac) = CardIdAtr(ac);
       BorderTopBot(ac) = *blanks;
       BorderSides(ac) = *blanks;
       BorderAtr(ac) = CardIdAtr(ac);
       endsr;
 
       //---------------------------------------------------------
       // Adjust credit balance
       begsr srCreditAdjust;
 1b    if HandValue = 'ROYAL FLUSH!  Pays 250 to 1';
          WonLost = 2500;
 1x    elseif HandValue = 'STRAIGHT FLUSH!   Pays 50 to 1';
          WonLost = 1000;
 1x    elseif HandValue = 'FOUR OF A KIND!   Pays 25 to 1';
          WonLost = 500;
 1x    elseif HandValue = 'FULL HOUSE!   Pays 8 to 1';
          WonLost = 160;
 1x    elseif HandValue = 'FLUSH!  Pays 5 to 1';
          WonLost = 100;
 1x    elseif HandValue = 'STRAIGHT!  Pays 4 to 1';
          WonLost = 80;
 1x    elseif HandValue = '3 OF A KIND!  Pays 3 to 1';
          WonLost = 60;
 1x    elseif HandValue = '2 PAIR   Pays 2 to 1';
          WonLost = 40;
 1x    elseif HandValue = 'JACKS OR BETTER.  Pays 1 to 1';
          WonLost = 20;
 1x    else;  //LOSER!
          WonLost = -(10);
 1e    endif;
       Credits += WonLost;
       endsr;
 
       //---------------------------------------------------------
       // Load Card images to screen.
       // Mostly concerned with loading proper headings, messages, and setting indicators.
       //---------------------------------------------------------
       begsr srLoadUserScreen;
       Face(*) = *blanks;
       Attr(*) = *blanks;
       exsr srResetSides;
       Attr(*) = *allx'00';
 1b    for ac = 1 to 5;
          CardIdAtr(ac) = f_GetCardColor(UserSuite(ac));
          CardId(ac) = f_GetCardFace(UserCard(ac));
          Face(ac).Row = f_LoadFace(CardId(ac));
 2b       for xx = 1 to 28;
 3b          if %subst(Face(ac):xx:1) <> ' ';
                %subst(Attr(ac):xx:1) = CardIdAtr(ac);
 3e          endif;
 2e       endfor;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // Set Card top and Sides to default outline
       //---------------------------------------------------------
       begsr srResetSides;
       BorderTopBot(*) = *blanks;
       BorderSides(*) = '|';
       TopBotAtr(*) = %bitor(WHITE: UL);
       BorderAtr(*) = WHITE;
       endsr;
 
       //---------------------------------------------------------
       // Return 7R X 4C array of selected character
       //---------------------------------------------------------
       dcl-proc f_LoadFace;
        dcl-pi *n char(4) dim(7);
         pBaseChar char(2) const;
        end-pi;
        dcl-s Line char(4) dim(7);
 
 1b     if pBaseChar = 'A' or pBaseChar = 'A1';
           Line(*) = 'A  A';
           Line(1) = ' AA ';
           Line(4) = 'AAAA';
 1x     elseif pBaseChar = 'K';
           Line(1) = 'K  K';
           Line(2) = 'K K ';
           Line(3) = 'KK  ';
           Line(4) = 'K   ';
           Line(5) = 'KK  ';
           Line(6) = 'K K ';
           Line(7) = 'K  K';
 1x     elseif pBaseChar = 'Q';
           Line(*) = 'Q  Q';
           Line(1) = ' QQ ';
           Line(6) = 'Q QQ';
           Line(7) = ' QQ ';
 1x     elseif pBaseChar = 'J';
           Line(*) = '  J ';
           Line(1) = 'JJJJ';
           Line(6) = 'J J ';
           Line(7) = 'JJJ ';
 1x     elseif pBaseChar = '10';
           Line(*) = '10 0';
           Line(1) = '1000';
           Line(7) = '1000';
 1x     elseif pBaseChar = '9';
           Line(1) = '9999';
           Line(2) = '9  9';
           Line(3) = '9  9';
           Line(4) = '9999';
           Line(5) = '   9';
           Line(6) = '   9';
           Line(7) = '9999';
 1x     elseif pBaseChar = '8';
           Line(1) = '8888';
           Line(2) = '8  8';
           Line(3) = '8  8';
           Line(4) = '8888';
           Line(5) = '8  8';
           Line(6) = '8  8';
           Line(7) = '8888';
 1x     elseif pBaseChar = '7';
           Line(1) = '7777';
           Line(2) = '   7';
           Line(3) = '   7';
           Line(4) = '  7 ';
           Line(5) = ' 7  ';
           Line(6) = '7   ';
           Line(7) = '7   ';
 1x     elseif pBaseChar = '6';
           Line(1) = '6666';
           Line(2) = '6   ';
           Line(3) = '6   ';
           Line(4) = '6666';
           Line(5) = '6  6';
           Line(6) = '6  6';
           Line(7) = '6666';
 1x     elseif pBaseChar = '5';
           Line(1) = '5555';
           Line(2) = '5   ';
           Line(3) = '5   ';
           Line(4) = '5555';
           Line(5) = '   5';
           Line(6) = '   5';
           Line(7) = '5555';
 1x     elseif pBaseChar = '4';
           Line(1) = '  44';
           Line(2) = ' 4 4';
           Line(3) = '4  4';
           Line(4) = '4444';
           Line(5) = '   4';
           Line(6) = '   4';
           Line(7) = '   4';
 1x     elseif pBaseChar = '3';
           Line(1) = '3333';
           Line(2) = '   3';
           Line(3) = '   3';
           Line(4) = ' 333';
           Line(5) = '   3';
           Line(6) = '   3';
           Line(7) = '3333';
 1x     elseif pBaseChar = '2';
           Line(1) = '2222';
           Line(2) = '   2';
           Line(3) = '   2';
           Line(4) = '2222';
           Line(5) = '2   ';
           Line(6) = '2   ';
           Line(7) = '2222';
 1x     elseif pBaseChar = 'P';
           Line(1) = 'PPPP';
           Line(2) = 'P  P';
           Line(3) = 'P  P';
           Line(4) = 'PPPP';
           Line(5) = 'P   ';
           Line(6) = 'P   ';
           Line(7) = 'P   ';
 1x     elseif pBaseChar = 'O';
           Line(*) = 'O  O';
           Line(1) = ' OO ';
           Line(7) = ' OO ';
 1x     elseif pBaseChar = 'E';
           Line(1) = 'EEEE';
           Line(2) = 'E   ';
           Line(3) = 'E   ';
           Line(4) = 'EEE ';
           Line(5) = 'E   ';
           Line(6) = 'E   ';
           Line(7) = 'EEEE';
 1x     elseif pBaseChar = 'R';
           Line(1) = 'RRR';
           Line(2) = 'R  R';
           Line(3) = 'R  R';
           Line(4) = 'RRR ';
           Line(5) = 'R R ';
           Line(6) = 'R  R';
           Line(7) = 'R  R';
 1e     endif;
        return Line;
       end-proc;
