       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRSMLTRC - Choice program for predefined source lists
       // Used by command JCRSMLT and JCRFSET to return choicekeys list to command prompt.
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCRSMLTCHF keyed;
 
       dcl-ds BinDS qualified;
        Length int(5) inz;
       end-ds;
 
       dcl-ds p1DS qualified;
        Command char(10) pos(1);
        Keyword char(10) pos(11);
        CorP char(1) pos(21);
       end-ds;
 
       dcl-s NumberOfEntries uns(5);
       dcl-s Offset uns(5);
       dcl-s stringvar varchar(32);
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p1 char(21);
        p2 char(2000);
       end-pi;
       //---------------------------------------------------------
 
       p1ds = p1;
       p2 = *blanks;
 
       // return initial headings when command is executed
 1b    if  p1DS.CorP = 'C';
          p2='Files or F4 Predefined Key';
 
 1x    elseif p1DS.CorP = 'P';
          NumberOfEntries = 0;
          Offset = 3;
 
          setll *loval JCRSMLTCHR;
          read JCRSMLTCHR;
 2b       dow not %eof;
 3b          if ChoiceTxt > *blanks;
                stringvar = %trimr(ChoiceKey) + ' = ' +%trimr(ChoiceTxt);
 3x          else;
                stringvar = %trimr(ChoiceKey);
 3e          endif;
 
             BinDS.Length = %len(stringvar);
 
             %subst(p2:Offset) = BinDS + stringvar;
             Offset += (BinDS.Length + 2);
 
             NumberOfEntries += 1;
 
             // only select 1st record of each group
             setgt ChoiceKey JCRSMLTCHR;
             read JCRSMLTCHR;
 2e       enddo;
 
          BinDS.Length = NumberOfEntries;
          %subst(p2:1:2) = BinDS;
 1e    endif;
 
       *inlr = *on;
       return;
