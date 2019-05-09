       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCR4MAXR3 - convert source code to lower case
       //---------------------------------------------------------
       /define ControlStatements
       /define Constants
       /define f_IsIgnoreLine
       /define f_IsCompileTimeArray
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f modifysrc disk(112) usage(*update);
       dcl-ds InputDS len(112) inz;
        CompileArray char(3) pos(13);
        SpecType char(1) pos(18);
        d_Extended char(38) pos(18);
        Src char(74) pos(19);
       end-ds;
 
       dcl-s ApostropheCnt uns(3);
       dcl-s string varchar(94);
       //---------------------------------------------------------
 
       read modifysrc InputDS;
 1b    dow not %eof;
 
 2b       if f_IsCompileTimeArray(CompileArray)
             or SpecType = 'P'
             or SpecType = 'p';
             *inlr = *on;
             return;
 2e       endif;
 
          string = %trimr(Src);
 2b       if not f_IsIgnoreLine(string);
             SpecType = %xlate(lo: up: SpecType);
 
             ApostropheCnt = 0;
 3b          for aa = 1 to 74;
 
 4b             if %subst(Src: aa: 1) = qs;
                   ApostropheCnt += 1;
 4e             endif;
 
                //---------------------------------------------------------
                // If extended D spec or record id characters,
                // or if first letter is L, as in L1, do not xlate
                //---------------------------------------------------------
 4b             if not (d_Extended = 'D'
                   or
                   (SpecType = 'I'
                   and (aa = 24 or aa = 32 or aa = 40))
                   or
                   (aa = 1 and %subst(Src: aa: 1) = 'L'))
                   and %rem(ApostropheCnt: 2) = 0;
 
                   %subst(Src:aa:1) = %xlate(up:lo:%subst(Src: aa: 1));
 
 4e             endif;
 3e          endfor;
 
             update modifysrc InputDS;
 2e       endif;
 
          read modifysrc InputDS;
 1e    enddo;
       *inlr = *on;
