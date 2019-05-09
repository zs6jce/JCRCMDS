       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRZANIM3 - raise USA flag
       //---------------------------------------------------------
       /define ControlStatements
       /define usleep
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRZANIM3D workstn;
 
       //---------------------------------------------------------
       wpos = 2;
 1b    for wlin = 10 downto 5;
          write screen;
          usleep(80000);  // delay milliseconds
 1e    endfor;
 
       exfmt screen;
       *inlr = *on;
       return;
