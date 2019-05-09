       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRGMPYR - Pyramid Solitaire
       // Addictive fun!
       // Select two cards whose sum=13 till all cards played
       // J + 2 = 13   Q + A = 13
       //
       // Program re-deals hands that are mathmatically impossible to win.
       // It is still not easy to win.
       //
       // 'Auto-match' code cuts down on number times tab key must be pressed.
       // If 9 is selected, the program will find the corresponding 4. etc.
       //---------------------------------------------------------
       /define ControlStatements
       /define Sds
       /define Dspatr
       /define FunctionKeys
       /define f_GetCardFace
       /define f_RmvSflMsg
       /define f_ShuffleDeck
       /define f_SndSflMsg
       /define f_GetRowColumn
       /define f_GetDayName
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRGMPYRD workstn infds(infds);
       dcl-ds Infds;
        InfdsFile char(10) pos(83);
        InfdsLib char(10) pos(93);
        InfdsRcdfmt char(10) pos(261);
        InfdsFkey char(1) pos(369);
       end-ds;
 
       dcl-s scrCardFaces char(2) dim(35) based(ptr1);
       dcl-s scrSelect char(1) dim(35) based(ptr2);
       dcl-s PrvCards char(2) dim(17) based(ptr3);
       dcl-s ptr1 pointer inz(%addr(r1c1));
       dcl-s ptr2 pointer inz(%addr(x1c1));
       dcl-s ptr3 pointer inz(%addr(prvCard));
       dcl-s XinArrayCnt uns(3);
       dcl-s XinTotalCnt uns(3);
       dcl-s IndexFrom uns(3);
       dcl-s IndexTo uns(3);
       dcl-s xx uns(3);
       dcl-s yy uns(3);
       dcl-s zz uns(3);
       dcl-s row uns(3) inz(1);
       dcl-s col uns(3) inz(1);
       dcl-s AutoMatchVal uns(3);
       dcl-s FaceCounts uns(3) dim(13);
       dcl-s RowHigh uns(3) dim(13);
       dcl-s RowLow uns(3) dim(13);
       dcl-s RowMapper uns(3) dim(35);
       dcl-s ColMapper uns(3) dim(35);
       dcl-s SaveXIndex uns(3) dim(2);
       dcl-s UnDoArray dim(37) like(screends);
       dcl-s UnDoCount uns(3);
       dcl-s IsError ind;
       dcl-s IsPlayFromDeck ind;
       dcl-s IsPlayFromPrv ind;
       dcl-s IsPossible ind;
       dcl-s IsAutoMatch ind;
       dcl-s AutoMatchXLOC char(10);
 
       dcl-ds Deck len(2) dim(52) qualified;
        Card uns(3);
       end-ds;
 
       dcl-ds CardAtr dim(8) qualified based(ptr4);
        col char(1) dim(7);
       end-ds;
       dcl-s ptr4 pointer inz(%addr(CardAtrDS));
 
       dcl-ds SelcRow dim(8) likeds(CardAtr) based(ptr5);
       dcl-s ptr5 pointer inz(%addr(SelcAtrDS));
 
       dcl-ds scrCardFaces2d dim(8) likeds(CardAtr) inz;
 
       // map screen fields into DS so ptrs to data can overlay
       // and undo function can work
       dcl-ds screends inz;
        r1c1;
        r2c1;
        r2c2;
        r3c1;
        r3c2;
        r3c3;
        r4c1;
        r4c2;
        r4c3;
        r4c4;
        r5c1;
        r5c2;
        r5c3;
        r5c4;
        r5c5;
        r6c1;
        r6c2;
        r6c3;
        r6c4;
        r6c5;
        r6c6;
        r7c1;
        r7c2;
        r7c3;
        r7c4;
        r7c5;
        r7c6;
        r7c7;
        rfc1;
        rfc2;
        rfc3;
        rfc4;
        rfc5;
        rfc6;
        rfc7;
        x1c1;
        x2c1;
        x2c2;
        x3c1;
        x3c2;
        x3c3;
        x4c1;
        x4c2;
        x4c3;
        x4c4;
        x5c1;
        x5c2;
        x5c3;
        x5c4;
        x5c5;
        x6c1;
        x6c2;
        x6c3;
        x6c4;
        x6c5;
        x6c6;
        x7c1;
        x7c2;
        x7c3;
        x7c4;
        x7c5;
        x7c6;
        x7c7;
        xfc1;
        xfc2;
        xfc3;
        xfc4;
        xfc5;
        xfc6;
        xfc7;
        NextX;
        PrvX;
        PrvCard;
        PrvCard2;
        PrvCard3;
        PrvCard4;
        PrvCard5;
        PrvCard6;
        PrvCard7;
        PrvCard8;
        PrvCard9;
        PrvCard10;
        PrvCard11;
        PrvCard12;
        PrvCard13;
        PrvCard14;
        PrvCard15;
        PrvCard16;
        PrvCard17;
        CardsLeft;
        CardsInDec;
        NextCard;
        PrvCardVal uns(3);
        DeckCardVal uns(3);
        NxtPlayC uns(3);
       end-ds screends;
 
       // Asymmetrical 2 dim array in the shape of a pyramid
       //  row 1 is 1,1
       //  row 2 is 2,1 then 2,2, etc.
       dcl-ds CardAtrDS;
        CardAtr11;
        CardAtr21 pos(8);
        CardAtr22;
        CardAtr31 pos(15);
        CardAtr32;
        CardAtr33;
        CardAtr41 pos(22);
        CardAtr42;
        CardAtr43;
        CardAtr44;
        CardAtr51 pos(29);
        CardAtr52;
        CardAtr53;
        CardAtr54;
        CardAtr55;
        CardAtr61 pos(36);
        CardAtr62;
        CardAtr63;
        CardAtr64;
        CardAtr65;
        CardAtr66;
        CardAtr71 pos(43);
        CardAtr72;
        CardAtr73;
        CardAtr74;
        CardAtr75;
        CardAtr76;
        CardAtr77;
        CardAtr81 pos(50);
        CardAtr82;
        CardAtr83;
        CardAtr84;
        CardAtr85;
        CardAtr86;
        CardAtr87;
       end-ds CardAtrDS;
 
       dcl-ds SelcAtrDS;
        SelcAtr11;
        SelcAtr21 pos(8);
        SelcAtr22;
        SelcAtr31 pos(15);
        SelcAtr32;
        SelcAtr33;
        SelcAtr41 pos(22);
        SelcAtr42;
        SelcAtr43;
        SelcAtr44;
        SelcAtr51 pos(29);
        SelcAtr52;
        SelcAtr53;
        SelcAtr54;
        SelcAtr55;
        SelcAtr61 pos(36);
        SelcAtr62;
        SelcAtr63;
        SelcAtr64;
        SelcAtr65;
        SelcAtr66;
        SelcAtr71 pos(43);
        SelcAtr72;
        SelcAtr73;
        SelcAtr74;
        SelcAtr75;
        SelcAtr76;
        SelcAtr77;
        SelcAtr81 pos(50);
        SelcAtr82;
        SelcAtr83;
        SelcAtr84;
        SelcAtr85;
        SelcAtr86;
        SelcAtr87;
       end-ds SelcAtrDS;
 
       //--------------------------------------------------------------------
       // If user selects a single X and there is not
       // auto-match, Position the cursor on the field name
       // that was X'ed.  Need to know the name of that field
       // to retrieve row/column to put the cursor
       //--------------------------------------------------------------------
       dcl-ds PositionToDS;
        *n char(10) inz('X1C1');
        *n char(10) inz('X2C1');
        *n char(10) inz('X2C2');
        *n char(10) inz('X3C1');
        *n char(10) inz('X3C2');
        *n char(10) inz('X3C3');
        *n char(10) inz('X4C1');
        *n char(10) inz('X4C2');
        *n char(10) inz('X4C3');
        *n char(10) inz('X4C4');
        *n char(10) inz('X5C1');
        *n char(10) inz('X5C2');
        *n char(10) inz('X5C3');
        *n char(10) inz('X5C4');
        *n char(10) inz('X5C5');
        *n char(10) inz('X6C1');
        *n char(10) inz('X6C2');
        *n char(10) inz('X6C3');
        *n char(10) inz('X6C4');
        *n char(10) inz('X6C5');
        *n char(10) inz('X6C6');
        *n char(10) inz('X7C1');
        *n char(10) inz('X7C2');
        *n char(10) inz('X7C3');
        *n char(10) inz('X7C4');
        *n char(10) inz('X7C5');
        *n char(10) inz('X7C6');
        *n char(10) inz('X7C7');
        *n char(10) inz('XFC1');
        *n char(10) inz('XFC2');
        *n char(10) inz('XFC3');
        *n char(10) inz('XFC4');
        *n char(10) inz('XFC5');
        *n char(10) inz('XFC6');
        *n char(10) inz('XFC7');
        FieldsNameArry char(10) dim(35) pos(1);
       end-ds;
 
       scDow = f_GetDayName();
       //---------------------------------------------------------
       // The program deals with cards either as a string of values or a two dim array.
       // Load a 'mapper' array of rows and columns.
       // string position 1 = row 1, column 1
       // string position 2 = row 2, column 1
       // string position 3 = row 2, column 2
       //---------------------------------------------------------
 1b    for xx = 1 to 35;
          RowMapper(xx) = row;
          ColMapper(xx) = col;
 2b       if col = row;
             col = 0;
             row += 1;
 2e       endif;
          col += 1;
 1e    endfor;
 
       f_RmvSflMsg(ProgId);
       exsr srNewStart;
 
 1b    dou 1 = 2;
 2b       if cardsleft = 0;
             f_SndSflMsg(ProgId: ' **************  WINNER  **************');
 2e       endif;
 
 2b       if not(IsError or InfdsFkey = f05);
             UnDoCount += 1;
             UnDoArray(UnDoCount) = ScreenDS;
 2e       endif;
 
          write msgctl;
          exfmt screen;
          f_RmvSflMsg(ProgId);
          AutoMatchXLOC = *blanks;
          csrrow = 9;
          csrcol = 7;
 
 2b       if InfdsFkey = f03 or InfdsFkey = f12;
             *inlr = *on;
             return;
 
 2x       elseif InfdsFkey = f01 and CardsInDec > 0;
             exsr srNextCard;
 
 2x       elseif InfdsFkey = f05;
             exsr srUnDo;
             exsr srSetHiLite;
 
 2x       elseif InfdsFkey = F09;
             exsr srNewStart;
 
 2x       else;
             exsr srEditSelect;
 3b          if not IsError;
                exsr srSetHiLite;
 3e          endif;
 2e       endif;
 1e    enddo;
 
       //---------------------------------------------------------
       // Reset screen back to previous state
       //---------------------------------------------------------
       begsr srUnDo;
 1b    if UnDoCount > 1;
          UnDoCount -= 1;
 1e    endif;
 
       ScreenDS = UnDoArray(UnDoCount);
 1b    for row = 7 to 8;
          SelcRow(row).Col(*) = %bitor(Green:UL);
 1e    endfor;
 
 1b    if UnDoCount = 1;
          f_SndSflMsg(ProgId: '    GAME START.  X TWO CARDS=13. PRESS ENTER');
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srGetPrevC;
       PrvCard = *blank;
       PrvX = *blanks;
       PrvCardVal = 0;
 1b    if prvCards(2) > *blanks;
 2b       for zz = 2 to 17;
             PrvCards(zz-1) = PrvCards(zz);
 2e       endfor;
 
          // Load numeric value from face value
 2b       if PrvCards(1) = 'A';
             PrvCardVal = 1;
 2x       elseif PrvCards(1) = 'J';
             PrvCardVal = 11;
 2x       elseif PrvCards(1) = 'Q';
             PrvCardVal = 12;
 2x       elseif PrvCards(1) = 'K';
             PrvCardVal = 13;
 2x       else;
             PrvCardVal = %uns(PrvCards(1));
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Autoskip if King is next card
       //---------------------------------------------------------
       begsr srNextCard;
       PrvX = *blanks;
       NextX = *blanks;
       scrSelect(*) = *blanks;
 
 1b    if NxtPlayC < 53;
 2b       if not(IsPlayFromDeck or IsPlayFromPrv);
 3b          for zz = 17 downto 2;
                PrvCards(zz) = PrvCards(zz-1);
 3e          endfor;
             PrvCards(1) = NextCard;
             PrvCardVal = DeckCardVal;
 2e       endif;
          IsPlayFromDeck = *off;
 
 2b       dou not(Deck(NxtPlayC).Card = 13);
             NxtPlayC += 1;
 3b          if NxtPlayC >= 53;
                NextCard = *blanks;
                DeckCardVal = 0;
                CardsInDec = 0;
 2v             leave;
 3x          else;
                NextCard = f_GetCardFace(Deck(NxtPlayC).Card);
                DeckCardVal = Deck(NxtPlayC).Card;
                CardsInDec -= 1;
 3e          endif;
 2e       enddo;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Make sure user only X's two selections and they total 13.
       // If single value is selected, that evokes the auto-match
       // function to find the corresponding = 13 matching card.
       // It is important to know the single X location (AutoMatchXLOC)
       // as different search patterns routines are executed based on
       // what the user is most likely wanting to do.
       //---------------------------------------------------------
       begsr srEditSelect;
       IsError = *off;
       XinTotalCnt = 0;
       XinArrayCnt = 0;
       yy = 0;
 1b    if Nextx > ' ';
          AutoMatchVal = DeckCardVal;
          AutoMatchXLOC = 'SIDE NEXT';
          XinTotalCnt += 1;
 1e    endif;
 1b    if PrvX > ' ';
          AutoMatchVal = PrvCardVal;
          AutoMatchXLOC = 'SIDE PRV';
          XinTotalCnt += 1;
 1e    endif;
 
 1b    for xx = 1 to 35;
 2b       if scrSelect(xx) > ' ';
             XinTotalCnt += 1;
             XinArrayCnt += 1;
 3b          if XinTotalCnt < 3;
                yy += 1;
                SaveXIndex(yy) = xx;  // index of card with 'X'
                AutoMatchVal = Deck(xx).Card;
 4b             if xx <= 28;
                   AutoMatchXLOC = 'MIDDLE';
 4x             else;
                   AutoMatchXLOC = 'BOTTOM';
 4e             endif;
 3e          endif;
 2e       endif;
 1e    endfor;
 
 1b    if XinTotalCnt = 1;  //only selected one
          IsError = *off;
          exsr SrAutoMatch;
 2b       if not IsAutoMatch;
             f_SndSflMsg(ProgId: '  NO AUTO-MATCH FOUND');
             IsError = *on;
 
             //-----------------------------------------------------------
             // execute function to return row/column for position cursor
             // first find the X.
             //-----------------------------------------------------------
 3b          if NextX > ' ';
                CsrRowColDS =
                f_GetRowColumn('NEXTX':InfdsFile:InfdsLib:InfdsRcdfmt);
 3x          elseif PrvX > ' ';
                CsrRowColDS =
                f_GetRowColumn('PRVX':InfdsFile:InfdsLib:InfdsRcdfmt);
 3x          else;
 4b             for xx = 1 to 35;
 5b                if scrSelect(xx) > ' ';
                      CsrRowColDS =
                      f_GetRowColumn(FieldsNameArry(xx):
                      InfdsFile:InfdsLib:InfdsRcdfmt);
 4v                   leave;
 5e                endif;
 4e             endfor;
 3e          endif;
 2e       endif;
 1e    endif;
 
 1b    if XinTotalCnt > 2;  //more than 2 selected
          f_SndSflMsg(ProgId: '    TOO MANY CARDS SELECTED');
          IsError = *on;
 
 1x    elseif XinTotalCnt < 1;  //None selected
          f_SndSflMsg(ProgId: '    PLEASE SELECT CARDS');
          IsError = *on;
 
 1x    elseif XinTotalCnt = 2;
 2b       if XinArrayCnt = 2;  //both from array
 3b          if Deck(SaveXIndex(1)).Card +
                Deck(SaveXIndex(2)).Card <> 13;
                f_SndSflMsg(ProgId: '    SELECT TWO CARDS = 13');
                IsError = *on;
 3x          else;  //two selected = 13
                f_RmvSflMsg(ProgId);
                scrCardFaces(SaveXIndex(1)) = *blanks;
                scrCardFaces(SaveXIndex(2)) = *blanks;
                scrSelect(SaveXIndex(1)) = *blanks;
                scrSelect(SaveXIndex(2)) = *blanks;
 3e          endif;
 
             // picked next card and one from tree
 2x       elseif XinArrayCnt = 1 and NextX > ' ';
 3b          if Deck(SaveXIndex(1)).Card +
                DeckCardVal <> 13;
                f_SndSflMsg(ProgId: '    SELECT TWO CARDS = 13');
                IsError = *on;
 
 3x          else;  //two selected = 13
                f_RmvSflMsg(ProgId);
                scrCardFaces(SaveXIndex(1)) = *blanks;
                scrSelect(SaveXIndex(1)) = *blanks;
                IsPlayFromDeck = *on;
                exsr srNextCard;
 3e          endif;
 
             // picked prv card and one from tree
 2x       elseif XinArrayCnt = 1 and PrvX > ' ';
 3b          if Deck(SaveXIndex(1)).Card + PrvCardVal <> 13;
                f_SndSflMsg(ProgId: '    SELECT TWO CARDS = 13');
                IsError = *on;
 3x          else;  //two selected = 13
                f_RmvSflMsg(ProgId);
                scrCardFaces(SaveXIndex(1)) = *blanks;
                scrSelect(SaveXIndex(1)) = *blanks;
                exsr srGetPrevC;
 3e          endif;
 
             // picked next card from deck and prv card from deck
 2x       elseif NextX > ' ' and PrvX > ' ';
 3b          if (DeckCardVal + PrvCardVal) <> 13;
                f_SndSflMsg(ProgId: '    SELECT TWO CARDS = 13');
                IsError = *on;
 3x          else;  //two selected = 13
                f_RmvSflMsg(ProgId);
                NextX = *blanks;
                PrvX = *blanks;
                IsPlayFromPrv = *on;
                exsr srNextCard;
                exsr srGetPrevC;
                IsPlayFromPrv = *off;
 3e          endif;
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // If two cards that would overlap this card from below are = *blanks and
       // card > *blanks, then highlight new available field.
       // First step is to get cards into 2 dim pyramid array.
       //---------------------------------------------------------
       begsr srSetHiLite;
       CardsLeft = 0;
 1b    for xx = 1 to 35;
          scrCardFaces2d(RowMapper(xx)).Col(ColMapper(xx)) = scrCardFaces(xx);
 2b       if scrCardFaces(xx) > *blanks and RowMapper(xx) <> 8;
             CardsLeft += 1;
 2e       endif;
 1e    endfor;
 
       // now that cards are in two dim array, set screen attributes
 1b    for xx = 1 to 35;
          row = RowMapper(xx);
          col = ColMapper(xx);
 
 2b       if row <= 6;
 3b          if (scrCardFaces2d(row).Col(col) = *blanks
                or
                (scrCardFaces2d(row).Col(col) > *blanks
                and (scrCardFaces2d(row + 1).Col(col) > *blanks
                or scrCardFaces2d(row + 1).Col(col + 1) > *blanks)));
                CardAtr(row).Col(col) = Green;
                SelcRow(row).Col(col) = %bitor(ND: PR);
 3x          else;
                CardAtr(row).Col(col) = White;
                SelcRow(row).Col(col) = %bitor(Green: UL);
 3e          endif;
 2x       else;
 3b          if scrCardFaces2d(row).Col(col) = *blanks;
                SelcRow(row).Col(col) = %bitor(ND: PR);
 3x          else;
                CardAtr(row).Col(col) = White;
 3e          endif;
 2e       endif;
 1e    endfor;
       endsr;
 
       //-------------------------------------------------------------------------
       // Complete the auto match process.
       // User has to select at least one card, for example they X an 8.
       // The program will search in sequence
       // 1) the middle (triangle) starting at the bottom right and
       //    working up to the top to find a 5 that is open to play.
       // 2) the side (previous card first then card from deck)
       // 3) the free card or bottom.
       // This feature will significantly reduce number of times user has to press tab key
       // and really speed up play
       // Screen attributes that are white can be tested for = 13.
       //
       // If X is on Next card (SIDE NEXT) then only search the middle for a match.
       // If X is on Previous card (SIDE PRV) then search middle, the free cards
       //  for a match.
       // If X is in middle triangle, (MIDDLE) search middle, then PRV, then NEXT, then FREE
       // if X is in Bottom or Free card (BOTTOM) search middle.
       //-------------------------------------------------------------------------
       begsr SrAutoMatch;
       isAutoMatch = *off;
       IndexFrom = 28;
       IndexTo = 1;
       exsr srAutoMatch_Search;
 
 1b    if AutoMatchXLOC = 'SIDE NEXT' or AutoMatchXLOC = 'SIDE PRV';
 2b       if isAutoMatch;
             SaveXIndex(1) = xx;
             scrSelect(xx) = 'X';
 2x       else;
             // search bottom
             IndexFrom = 35;
             IndexTo = 29;
             exsr srAutoMatch_Search;
 3b          if isAutoMatch;
                SaveXIndex(1) = xx;
                scrSelect(xx) = 'X';
 3e          endif;
 2e       endif;
 
 1x    elseif AutoMatchXLOC = 'MIDDLE';
 2b       if isAutoMatch;
             SaveXIndex(2) = xx;
             scrSelect(xx) = 'X';
 2x       else;
             // check previous card
 3b          if PrvCardVal + AutoMatchVal = 13;
                PrvX = 'X';
                IsAutoMatch = *on;
                XinTotalCnt += 1;
                // next next dealt card
 3x          elseif DeckCardVal + AutoMatchVal = 13;
                NextX = 'X';
                IsAutoMatch = *on;
                XinTotalCnt += 1;
                // check across bottom of free cards
 3x          else;
                IndexFrom = 35;
                IndexTo = 29;
                exsr srAutoMatch_Search;
 4b             if isAutoMatch;
                   SaveXIndex(2) = xx;
                   scrSelect(xx) = 'X';
 4e             endif;
 3e          endif;
 2e       endif;
 
 1x    elseif AutoMatchXLOC = 'BOTTOM';
 2b       if isAutoMatch;
             SaveXIndex(2) = xx;
             scrSelect(xx) = 'X';
 2e       endif;
 1e    endif;
       endsr;
 
       //-------------------------------------------------------------------------
       //-------------------------------------------------------------------------
       begsr srAutoMatch_Search;
 1b    for xx = IndexFrom downto IndexTo;
 2b       if scrCardFaces(xx) > *blanks
             and %bitand(CardAtr(RowMapper(xx)).Col(ColMapper(xx)):
             White) = White
             and (Deck(xx).Card + AutoMatchVal) = 13;
             isAutoMatch = *on;
             XinTotalCnt += 1;
             XinArrayCnt += 1;
 1v          leave;
 2e       endif;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srNewStart;
       csrrow = 9;
       csrcol = 7;
       clear screenDS;
 
       // Deal 35 cards to pyramid and free use cards
 1b    dou IsPossible;
          RowHigh(*) = 9;
          RowLow(*) = 0;
          IsPossible = *on;
          FaceCounts(*) = 0;
          Deck = f_ShuffleDeck();
 
          // easier if free deck is full (no kings)
 2b       for xx = 29 to 35;
 3b          if Deck(xx).Card = 13;
                IsPossible = *off;
 2v             leave;
 3e          endif;
 2e       endfor;
 2b       if not IsPossible;
 1i          iter;
 2e       endif;
          sorta %subarr(Deck(*).Card :29:7);
          scrCardFaces(*) = *blanks;
 
          //---------------------------------------------------------
          // check for hands that are impossible to win
          //  FaceCounts array is loaded with count of each type card
          //  Element 1 is total count of aces in pyramid.
          //  Element 2 is total count of two in pyramid.
          //---------------------------------------------------------
 2b       for xx = 1 to 35;
             zz = Deck(xx).Card;
 
 3b          if xx < 29;
                FaceCounts(zz) += 1;
 4b             if RowMapper(xx) < RowHigh(zz);
                   RowHigh(zz) = RowMapper(xx);
 4e             endif;
 4b             if RowMapper(xx) > RowLow(zz);
                   RowLow(zz) = RowMapper(xx);
 4e             endif;
 3e          endif;
 
 3b          if not(zz = 13);
                scrCardFaces(xx) = f_GetCardFace(zz);
 3e          endif;
 2e       endfor;
 
          // four of anything in not-free rows will 99% spell defeat
 2b       for xx = 1 to 12;
 3b          if FaceCounts(xx) = 4;
                IsPossible = *off;
 2v             leave;
 3e          endif;
 
             //---------------------------------------------------------
             // Next winner killer is 3 of same card higher or lower than 2 of
             // that card's =13 partner.   Ex. 3 Aces over 2 Queens usually cannot win.
             //---------------------------------------------------------
 3b          if FaceCounts(xx) = 3;
 4b             if FaceCounts(13 - xx) > 1;
 5b                if RowLow(xx) < RowHigh(13 - xx) or
                      RowHigh(xx) > RowLow(13 - xx);
                      IsPossible = *off;
 2v                   leave;
 5e                endif;
 4e             endif;
 3e          endif;
 2e       endfor;
 1e    enddo;
 
       xx = 36;
 1b    dow Deck(xx).Card = 13;
          xx += 1;
 1e    enddo;
 
       CardsInDec = 53 - xx;
       NextCard = f_GetCardFace(Deck(xx).Card);
       DeckCardVal = Deck(xx).Card;
       NxtPlayC = xx;
 
 1b    for row = 7 to 8;
          SelcRow(row).Col(*) = %bitor(Green:UL);
 1e    endfor;
       exsr srSetHiLite;
       UnDoCount = 0;
       f_SndSflMsg(ProgId: '    X TWO CARDS=13. PRESS ENTER');
       endsr;
