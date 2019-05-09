       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRSBSDR - List subsystem pools and routing ids
       //---------------------------------------------------------
       /define ControlStatements
       /define Constants
       /define ApiErrDS
       /define f_DisplayLastSplf
       /define f_Quscrtus
       /define f_GetDayName
       /define Qwcrneta
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRSBSDP printer oflind(IsOverFlow) usropn;
 
       dcl-s SBSArry char(20) dim(250);
       dcl-s a21 char(21);
       dcl-s PrtPools char(75);
       dcl-s PrtRouting char(30);
       dcl-s QualSbsName char(20);
       dcl-s RoutingExtract char(3);
       dcl-s SystemName char(8);
       dcl-s RoutingArry int(10) dim(50) ascend;
       dcl-s scDow char(9);
       dcl-s yy uns(5);
       dcl-s zz uns(10);
 
       // List Active Subsystems
       dcl-pr Qwclasbs extpgm('QWCLASBS');
        *n char(20);  // Space Name and Lib
        *n char(8) const;  // Api Format
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds QwclasbsDS qualified based(QwclasbsPtr);
        QualSbsName char(20) pos(1);
       end-ds;
 
       // Retrieve Subsystem Information
       dcl-pr Qwdrsbsd extpgm('QWDRSBSD');
        *n char(500);  // Receiver
        *n int(10) const;  // Length
        *n char(8) const;  // Api Format
        *n char(20);  // Subsystem Name
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds QwdrsbsdDS len(500) qualified;
        NumberOfPools int(10) pos(77);
       end-ds;
 
       dcl-ds PoolExtractDS qualified based(PoolExtractPtr);
        PoolNumber int(10);
        PoolName char(10);
       end-ds;
 
       // List Subsystem Entries
       dcl-pr Qwdlsbse extpgm('QWDLSBSE');
        *n char(20);  // User Space and Lib
        *n char(8) const;  // Api Format
        *n char(20);  // Qualified Sbs Name
        *n like(ApiErrDS);
       end-pr;
 
       // routing entries
       dcl-ds QwdlsbseDS qualified based(QwdlsbsePtr);
        RoutingEntry int(10) pos(49);
       end-ds;
 
       // load print string
       dcl-ds PoolPrintDS len(15) qualified;
        PoolNumber char(2) pos(1);
        PoolName char(11) pos(4);
       end-ds;
 
       //---------------------------------------------------------
       open JCRSBSDP;
       scDow = f_GetDayName();
 
       // retrieve Network attributes to get sys name
       callp QWCRNETA(
             QwcrnetaDS:
             %size(QwcrnetaDS):
             1:
             'SYSNAME':
             ApiErrDS);
 
       NetWorkInfoPtr = %addr(QwcrnetaDS) + QwcrnetaDS.TableOffset;
       SystemName = NetworkInfoDS.LocalSysName;
       write PrtHead;
       IsOverFlow = *off;
 
       //load active subsystem names to user space then to array
       ApiHeadPtr = f_QUSCRTUS(UserSpaceName);
       callp QWCLASBS(UserSpaceName: 'SBSL0100': ApiErrDS);
       QwclasbsPtr = ApiHeadPtr + ApiHead.OffSetToList;
 
 1b    for ForCount = 1 to ApiHead.ListEntryCount;
          SBSArry(ForCount) = QwclasbsDS.QualSbsName;
          QwclasbsPtr += ApiHead.ListEntrySize;
 1e    endfor;
 
       sorta %subarr(SBSArry: 1: ApiHead.ListEntryCount);
 
       //---------------------------------------------------------
       // Spin though subsystems and load pools and routing entries
       //---------------------------------------------------------
       yy = ApiHead.ListEntryCount;
 1b    for ForCount = 1 to yy;
          QualSbsName = SBSArry(ForCount);
 
          // Get POOL id number and names.   Load up to 5 entries
          callp QWDRSBSD(
                QwdrsbsdDS:
                %len(QwdrsbsdDS):
                'SBSI0100':
                QualSbsName:
                ApiErrDS);
 
          PoolExtractPtr = %addr(QwdrsbsdDS) + 80;
          PrtPools = *blanks;
          aa = 1;
 
 2b       for zz = 1 to QwdrsbsdDS.NumberOfPools;
 3b          if zz > 5;
 2v             leave;
 3e          endif;
 
             evalr PoolPrintDS.PoolNumber =
             %editc(PoolExtractDS.PoolNumber:'4');
             PoolPrintDS.PoolName = PoolExtractDS.PoolName;
             %subst(PrtPools: aa) = PoolPrintDS;
             aa += 15;
             PoolExtractPtr += 28;
 2e       endfor;
 
          // load routing entries for this subsystem into user space
          callp QWDLSBSE(UserSpaceName: 'SBSE0100': QualSbsName: ApiErrDS);
 
          //---------------------------------------------------------
          // Same routing pool entry ID could be in many
          // routing entries. Only want to show one.
          // Use array to lookup and see if entry is used yet.
          //---------------------------------------------------------
          aa = 0;
          RoutingArry(*) = 0;
          PrtRouting = *all'-    ';
          QwdlsbsePtr = ApiHeadPtr + ApiHead.OffSetToList;
 
 2b       for ForCount2 = 1 to ApiHead.ListEntryCount;
 3b          if aa = 0
                or %lookup(QwdlsbseDS.RoutingEntry: RoutingArry: 1: aa) = 0;
                aa += 1;
                RoutingArry(aa) = QwdlsbseDS.RoutingEntry;
 3e          endif;
             QwdlsbsePtr += ApiHead.ListEntrySize;
 2e       endfor;
 
          // Sort array and load it into print string
 2b       if aa > 1;
             sorta %subarr(RoutingArry: 1: aa);
 2e       endif;
 
          // Spin through array, loading print string
          cc = 1;
 2b       for bb = 1 to aa;
             evalr RoutingExtract = %editc(RoutingArry(bb):'4');
             %subst(PrtRouting: cc: 3) = RoutingExtract;
             cc += 3;
 2e       endfor;
 
          a21 = %subst(QualSbsName: 1: 10)+' '+%subst(QualSbsName: 11);
          write PrtDetail;
 1e    endfor;
 
       close JCRSBSDP;
       f_DisplayLastSplf('JCRSBSDR': '*');
       *inlr = *on;
       return;
