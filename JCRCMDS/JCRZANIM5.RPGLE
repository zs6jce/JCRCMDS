       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRZANIM5 - scrolling text on random star field
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CenterText
       /define f_GetRandom
       /define usleep
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRZANIM5D workstn sln(lineno);
 
       dcl-s LineNo packed(2);
       dcl-s StarsPerLine uns(3);
       dcl-s xx uns(3);
       dcl-s yy uns(3);
       //---------------------------------------------------------
       dcl-s Msg char(61) dim(7);
       msg(1)='Space ...';
       msg(2)='The final frontier ...';
       msg(3)='... These are the voyages of the starship, Enterprise ...';
       msg(4)='... Its five year mission: To explore strange, new worlds ...';
       msg(5)='... To seek out new life and new civilizations ...';
       msg(6)='... To boldly go where no person has gone before ...';
       msg(7)='... www.jcrcmds.com ...';
       //---------------------------------------------------------
 
 1b    for yy = 1 to %elem(Msg);
          *in10 = *off; // highlight text
 
          // load random star map max 6 stars per line;
 2b       for LineNo = 1 to 24;
             aText = *blanks;
             StarsPerLine = f_GetRandom(6);
 
 3b          for xx = 1 to StarsPerLine;
                %subst(aText: f_GetRandom(61): 1) = '*';
 3e          endfor;
 
             write DspRow;
 2e       endfor;
 
          // load text from array to screen field
          LineNo = 11;
          aText = f_CenterText(Msg(yy):61);
          *in10 = *on;
          write DspRow;
          sleep(2); // delay seconds
 1e    endfor;
 
       *inlr = *on;
       return;
