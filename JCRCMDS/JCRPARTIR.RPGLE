       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRPARTIR - Retrieve Partition Info for current system
       //    *featured in 2010/01 iSeries News magazine
       //---------------------------------------------------------
       ctl-opt bnddir('QUSAPIBD');
       /define ControlStatements
       /define ApiErrDS
       /define f_Quscrtus
       /define Qmhsndpm
       /define Qwcrneta
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s OsVersion char(6);
       dcl-s EquivalentOS char(6);
       dcl-s MsgTxt varchar(78);
       dcl-s NonVary char(78);
       dcl-s LparFormat int(10) inz(1);
       dcl-s LparRcvLen int(10) inz(%len(lparinfods));
       dcl-s xx uns(3);
       dcl-s IsFoundIP ind inz(*off);
       dcl-s FirstActiveIP like(nifc0100DS.IP);
       dcl-s jobuser char(10) inz(*user);
 
       // Get LPAR Numerical Partition
       dcl-pr dlpar_get_info int(10) extproc(*dclcase);  // LPAR info
        *n like(LparInfoDS);  // Receiver
        *n int(10) value;  // Format
        *n int(10) value;  // Receiver Length
       end-pr;
 
       dcl-ds LparInfoDS qualified inz;
        LparNumber int(10) pos(41);
       end-ds;
 
       // Retrieve System Values
       dcl-pr Qwcrsval extPgm('QWCRSVAL');  // Get System Value
        *n char(200);  // Serial number
        *n int(10) const;  // QwcrsvalDS length
        *n int(10) const;  // Number of values
        *n char(20) const;  // Sysval names
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds qwcrsvalDS len(200) qualified;
        EntryCount int(10) pos(1);
        OffsetToVal int(10) pos(5) dim(2);
       end-ds;
 
       dcl-ds InfoTableDS len(50) qualified based(InfoTablePtr);
        ValueName char(10) pos(1);
        LenOfData int(10) pos(13);
        SystemValue char(10) pos(17);
       end-ds;
 
       // Check Target Release
       dcl-pr qszchktg extpgm('QSZCHKTG');
        *n char(10) const;  // OS version
        *n char(10) const;  // OS list
        *n int(10) const;  // Number of supported
        *n char(6);  // Validated release
        *n char(6);  // Equivalent release
        *n like(ApiErrDS);
       end-pr;
 
       //---------------------------------------------------------
       // List Network Interfaces
       dcl-pr QtocLstNetIfc extproc(*dclcase);
        *n char(20);      // user space
        *n char(8) const; // format
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds nifc0100DS qualified based(nifc0100Ptr);
        IP char(15) pos(1);
        NetworkAddr char(15) pos(21);
        NetworkName char(10) pos(41);
        LineDescript char(10) pos(51);
        InterfaceStatus int(10) pos(73);
       end-ds;
 
       //---------------------------------------------------------
       // get system name
       callp QWCRNETA(
             QwcrnetaDS:
             %size(QwcrnetaDS):
             1:
             'LCLCPNAME':
             ApiErrDS);
 
       NetWorkInfoPtr = %addr(QwcrnetaDS) + QwcrnetaDS.TableOffset;
       MsgTxt = %trimr(NetworkInfoDS.LocalSysName);
 
       //---------------------------------------------------------
       // get system serial number and model number
       callp QWCRSVAL(
             qwcrsvalDS:
             %size(qwcrsvalDS):
             2:
             'QMODEL    QSRLNBR':
             ApiErrDs);
 
 1b    for xx = 1 to qwcrsvalDS.EntryCount;
          InfoTablePtr = %addr(qwcrsvalDS) + qwcrsvalDS.OffsetToVal(xx);
 2b       if InfoTableDS.ValueName = 'QMODEL';
             MsgTxt += '  M:';
 2x       else;
             MsgTxt += '  S:';
 2e       endif;
 
          MsgTxt += %trim(
          %subst(InfoTableDS.SystemValue: 1: InfoTableDS.LenOfData));
 1e    endfor;
 
       //---------------------------------------------------------
       // get Lpar partition number
       callp dlpar_get_info(
             LparInfoDS:
             LparFormat:
             LparRcvLen);
 
       MsgTxt += '  Partition:' + %trimr(%char(LparInfoDS.LparNumber));
 
       //---------------------------------------------------------
       // get OS version
       callp QSZCHKTG(
             '*CURRENT':
             '*SAV':
             1:
             OsVersion:
             EquivalentOS:
             ApiErrDS);
       MsgTxt += '  ' + %trimr(OsVersion);
 
       // load user profile
       MsgTxt += '  ' + %trimr(JobUser);
 
       //---------------------------------------------------------
       // get IP address
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
 
       // load network interface names into user space
       callp QtocLstNetIfc(
             UserSpaceName:
             'NIFC0100':
             ApiErrDS);
 
       IsFoundIP = *off;
       nifc0100Ptr = ApiHeadPtr + ApiHead.OffSetToList;
 
 1b    for ForCount = 1 to ApiHead.ListEntryCount;
 2b       if nifc0100DS.InterfaceStatus > 0;
             FirstActiveIP = nifc0100DS.IP;
 
 3b          if nifc0100DS.LineDescript = 'ETHERNET';
                MsgTxt += '  ' + %trim(nifc0100DS.IP);
                IsFoundIP = *on;
 1v             leave;
 3e          endif;
 2e       endif;
 
          nifc0100Ptr += ApiHead.ListEntrySize;
 1e    endfor;
 
       // not everyone has their IP address labeled ETHERNET, if not found use first active
 1b    if not IsFoundIP;
          MsgTxt += '  ' + %trim(FirstActiveIP);
 1e    endif;
 
       //---------------------------------------------------------
       NonVary = MsgTxt;
       callp QMHSNDPM(
             ' ':
             ' ':
             NonVary:
             78:
             '*INFO':
             '*CTLBDY':
             1:
             ' ':
             ApiErrDS);
       *inlr = *on;
       return;
