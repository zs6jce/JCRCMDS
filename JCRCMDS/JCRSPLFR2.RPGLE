       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRSPLFR2 - duplicate spooled file with overrides
       //  open existing spooled file.
       //   retrieve attributes from existing spooled file.
       //    create new spooled file from existing spooled file attributes.
       //     write old spooled file data into newly created spooled file.
 
       // changing overlay name on afpds file does not change the overlay.
       // See bottom of discussion at link
       //http://fixunix.com/ibm-as400/358192-adding-overlay-copied-spooled-file-*afpds-format.html
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define Qspclosp
       /define Qspgetsp
       /define Qspopnsp
       /define f_Quscrtus
       /define f_GetQual
       /define f_GetDayName
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRSPLFD2 workstn;
 
       dcl-s BufferOrdinal int(10) inz(-1);
       dcl-s p_Splfbin int(10);
       dcl-s SplfHandle1 int(10);
       dcl-s SplfHandle2 int(10);
 
       // Create Spooled File
       dcl-pr Qspcrtsp extpgm('QSPCRTSP');
        *n int(10); // splf handle
        *n like(QusrsplaDS); // attributes
        *n like(ApiErrDS);
       end-pr;
 
       // Create spooled file API requires DS as a parm
       dcl-ds QusrsplaDS len(4000) qualified inz;
        IntJobId char(16) pos(17);
        IntSplfId char(16) pos(33);
        SpflNum int(10) pos(85);
        FrmType char(10) pos(89);
        UsrDta char(10) pos(99);
        Hold char(10) pos(129);
        Save char(10) pos(139);
        TotPages int(10) pos(149);
        Copies int(10) pos(173);
        CopiesLeft int(10) pos(177);
        LPI int(10) pos(181);
        CPI int(10) pos(185);
        Outq char(10) pos(191);
        OutqLib char(10) pos(201);
        PageRotate int(10) pos(553);
        Duplex char(10) pos(561);
        FrontOverlay char(10) pos(737);
        FrontOverLib char(10) pos(747);
        BackOverlay char(10) pos(773);
        BackOverLib char(10) pos(783);
        AfpdsCreated char(1) pos(2857);
       end-ds;
 
       // Retrieve Spooled File Attributes
       dcl-pr Qusrspla extpgm('QUSRSPLA');
        *n like(QusrsplaDS);  // receiver
        *n int(10) const;  // receiver length
        *n char(8) const;  // api format
        *n char(26) const;  // qualified job
        *n char(16) const;  // internal job id
        *n char(16) const;  // internal spool id
        *n char(10) const;  // spool file name
        *n int(10) const;  // spool file Num
        *n like(ApiErrDS);
       end-pr;
 
       // Put Spooled File Data
       dcl-pr Qspputsp extpgm('QSPPUTSP');
        *n int(10);  // splf handle
        *n char(20);  // user space
        *n like(ApiErrDS);
       end-pr;
 
       // Delete User Space
       dcl-pr Qusdltus extpgm('QUSDLTUS');
        *n char(20);  // user space
        *n like(ApiErrDS);
       end-pr;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_JobName char(10);
        p_JobUser char(10);
        p_JobNumber char(6);
        p_SplfName char(10);
        p_SplfNumber zoned(6);
       end-pi;
       //---------------------------------------------------------
 
       scDow = f_GetDayName();
       UserSpaceName = 'JCRSPLFR2 QTEMP';
       p_SplfBin = p_SplfNumber;  //get into proper format
 
       // load spooled file attributes
       callp QUSRSPLA(
             QusrsplaDS:
             %size(QusrsplaDS):
             'SPLA0200':
             p_JobName + p_JobUser + p_JobNumber:
             ' ':
             ' ':
             p_SplfName:
             p_SplfBin:
             ApiErrDS);
 
       // load spooled file attributes to screen fields
       scSplNam = p_SplfName;
       scUsrid = p_JobUser;
       scUsrDta = QusrsplaDS.UsrDta;
       scPagNbr = QusrsplaDS.TotPages;
       scNumCopys = QusrsplaDS.Copies;
       scOutq = QusrsplaDS.outq;
       scPageRot = QusrsplaDS.PageRotate;
       scDuplex = %subst(QusrsplaDS.Duplex: 2: 1);
       scHold = %subst(QusrsplaDS.Hold: 2: 1);
       scSave = %subst(QusrsplaDS.Save: 2: 1);
 
       *in10 = *on;
 1b    if  not(QusrsplaDS.FrontOverlay = '*NONE');
          *in10 = *off;
          scfOverLay =
          f_GetQual(QusrsplaDS.FrontOverlay + QusrsplaDS.FrontOverLib);
 1e    endif;
 
       *in11 = *on;
 1b    if  QusrsplaDS.BackOverlay = '*FRONTOVL';
 2b       if  not(QusrsplaDS.FrontOverlay = '*NONE');
             *in11 = *off;
             scbOverlay = QusrsplaDS.BackOverlay;
 2e       endif;
 1x    elseif not(QusrsplaDS.BackOverlay = '*NONE');
          *in11 = *off;
          scbOverLay =
          f_GetQual(QusrsplaDS.BackOverlay + QusrsplaDS.BackOverLib);
 1e    endif;
 
       scLPI = QusrsplaDS.LPI;
       scCPI = QusrsplaDS.CPI/10;
 
       exfmt screen;
 1b    if *inkc or *inkl;
          *inlr = *on;
          return;
 1e    endif;
 
       // overlay attributes with screen fields
       QusrsplaDS.UsrDta = scUsrDta;
       QusrsplaDS.Copies = scNumCopys;
       QusrsplaDS.CopiesLeft = scNumCopys;
 
 1b    if QusrsplaDS.Outq <> scOutq;
          QusrsplaDS.OutqLib = '*LIBL ';
 1e    endif;
       QusrsplaDS.Outq = scOutq;
 
       QusrsplaDS.PageRotate = scPageRot;
       QusrsplaDS.LPI = scLPI;
       QusrsplaDS.CPI = scCPI * 10;
 1b    if scDuplex = 'N';
          QusrsplaDS.Duplex = '*NO';
 1x    else;
          QusrsplaDS.Duplex = '*YES';
 1e    endif;
 1b    if scHold = 'N';
          QusrsplaDS.Hold = '*NO';
 1x    else;
          QusrsplaDS.Hold = '*YES';
 1e    endif;
 1b    if scSave = 'N';
          QusrsplaDS.Save = '*NO';
 1x    else;
          QusrsplaDS.Save = '*YES';
 1e    endif;
 
       // create new spooled file
       callp QSPCRTSP(
             SplfHandle2:
             QusrsplaDS:
             ApiErrDS);
 
       // create user space
       f_Quscrtus(UserSpaceName);
 
       // open input spooled file
       callp QSPOPNSP(
             SplfHandle1:
             '*INT':
             QusrsplaDS.IntJobId:
             QusrsplaDS.IntSplfId:
             '*INT':
             0:
             -1:
             ApiErrDS);
 
       // get input spooled data
       callp QSPGETSP(
             SplfHandle1:
             UserSpaceName:
             'SPFR0200':
             BufferOrdinal:
             '*ERROR':
             ApiErrDS);
 
       // close input spooled file
       callp QSPCLOSP(
             SplfHandle1:
             ApiErrDS);
 
       // put spooled file data
       callp QSPPUTSP(
             SplfHandle2:
             UserSpaceName:
             ApiErrDS);
 
       // close output spooled file
       callp QSPCLOSP(
             SplfHandle2:
             ApiErrDS);
 
       // delete user space
       callp QUSDLTUS(
             UserSpaceName:
             ApiErrDS);
 
       *inlr = *on;
       return;
