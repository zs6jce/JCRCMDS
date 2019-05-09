       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // XMLPREVINR - extract embedded installer code from text.
       //  read XML input member. use tags in text to extract installer source.
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f XMLINPUT disk(112);  // uploaded text
       dcl-ds inputDS;
        xmltag1 char(17) pos(13);
        xmltag2 char(18) pos(18);
        xmlcode char(100) pos(13);
       end-ds;
 
       dcl-f XMLEXTRACT disk(112) usage(*output);  // parsed out
       dcl-ds OutDS len(112);
        seqNum zoned(6:2) pos(1) inz(0);
        seqDate zoned(6:0) pos(7) inz(0);
        SrcOut char(100) pos(13);
       end-ds;
 
       dcl-s IsWrite ind inz(*off);
 
       //---------------------------------------------------------
       read xmlinput inputDS;
 1b    dow not %eof;
 
          // write records to temp installer source after start is found
 2b       if IsWrite;
 3b          if xmltag2 = '</install_program>';
                *inlr = *on;
                return;
 3e          endif;
 
             seqNum += .01;
             srcout = xmlcode;
             write XMLEXTRACT OutDS;
 
             // Start of data to copy.
 2x       elseif xmltag1 = '<install_program>';
             IsWrite = *on;
 2e       endif;
 
          read xmlinput inputDS;
 1e    enddo;
       *inlr = *on;
       return;
