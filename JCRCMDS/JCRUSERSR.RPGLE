       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------------
       // JCRUSERSR -  Search User Profiles/ Outq / Jobd / Initial program
       //   add option to create directory (email entry) if not defined.
       //---------------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCRUSERSF usage(*output) extfile(extofile) extmbr(extombr) usropn;
       dcl-f JCRUSERSD workstn sfile(sbfdta1:rrn1) infds(infds);
       dcl-f JCRUSERSP printer oflind(IsOverFlow) usropn;
 
       /define Sds
       /define Infds
       /define Dspatr
       /define Constants
       /define FunctionKeys
       /define f_Quscrtus
       /define ApiErrDS
       /define f_GetDayName
       /define f_GetApiISO
       /define f_BuildString
       /define f_RunCmd
       /define f_RmvSflMsg
       /define f_SndSflMsg
       /define ListAuthorizedUsers
       /define f_GetEmail
       /define f_IsValidObj
       /define f_IsValidmbr
       /define f_GetFileLevelID
       /define f_RtvMsgApi
       /define f_getqual
       /define f_GetRowColumn
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s rrn1 uns(5);
       dcl-s xx uns(5);
       dcl-s yy uns(5);
       dcl-s isfirsttime ind;
       dcl-s IsOk1 ind;
       dcl-s IsOk2 ind;
       dcl-s IsOk3 ind;
       dcl-s IsOk4 ind;
       dcl-s IsOk5 ind;
       dcl-s lenscan uns(3);
       dcl-s upcase char(50);
       dcl-s extOmbr char(10);
 
       //--*DATA STRUCTURES---------------------------------------
       // name screen indicators
       dcl-ds ind qualified;
        changes ind pos(12) inz(*off);
        sfldsp ind pos(31) inz(*off);
        sfldspctl ind pos(32) inz(*off);
       end-ds;
 
       // overlay portion of user space to store usri info.
      //  I can sort, search, and redisplay without reloading from API
       dcl-ds Autu0100DS based(autu0100ptr) qualified;
        UsrPrf char(10);
        lastused char(10);
        Status char(10);
        Text char(39);
        Initialpgm char(10);
        InitialpgmL char(10);
        Jobd char(10);
        JobdL char(10);
        Outq char(10);
        OutqL char(10);
       end-ds;
 
       f_RmvSflMsg(ProgId);
       scDow = f_GetDayName();
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
       exsr srclearsfl;
       isfirsttime = *on;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
 1b    dou 1=2;
          *in31 = (rrn1 > 0);
          *in32 = *on;
 
          write msgctl;
          write SFOOTER1;
          exfmt SBFCTL1;
          f_RmvSflMsg(ProgId);
 
 2b       if infdsfkey = f03
             or infdsfkey = f12;
             *inlr = *on;
             return;
 
 2x       elseif infdsfkey = f05;
             scuser = *blanks;
             sctext = *blanks;
             scinit = *blanks;
             scjobd = *blanks;
             scoutq = *blanks;
             exsr srclearsfl;
 
 2x       elseif infdsfkey = f06;
             exsr srPrint;
             f_SndSflMsg(ProgId: 'Print Completed');
 
 2x       elseif infdsfkey = f08;
             f_RunCmd('WRKSPLF');
 
 2x       elseif infdsfkey = f09;
             exsr srOutfile;
             f_SndSflMsg(ProgId: errmsg);
 
 
 2x       elseif *in12;  // changes
 3b          if IsFirsttime;
                exsr srhardrefresh;
                isfirsttime = *off;
 3x          else;
                exsr srsearchuserspace;
 3e          endif;
 
             //----------------------------------------
 2x       elseif (rrn1 > 0);
 
             readc sbfdta1;
 3b          dow not %eof();
 
 4b             if sfopt = '2';
                   f_RunCmd(f_buildstring(
                   '?CHGUSRPRF USRPRF(&)':
                   sfusrprf));
 
 4x             elseif sfopt = '5';
                   f_RunCmd(f_buildstring(
                   'DSPUSRPRF USRPRF(&)':
                   sfusrprf));
 
 4x             elseif sfopt = '6';
                   wcusrprf = sfusrprf;
                   wctext = sftext;
                   wcAddress = f_GetEmail(sfusrprf);
 
                   wcF6msg = *blanks;
 
 5b                if wcAddress = *blanks;
                      wcAddress = 'User Not Setup In WRKDIRE';
                      wdtitle = 'Create a Directory Entry';
                      wcF6msg = 'F6=' + wdtitle;
 5x                elseif wcAddress = '@';
                      wcAddress = 'Email Address Not Setup In WRKDIRE';
 
                      //----------------------------------------------------
                      // when have a couple weeks, figure out how to
                      //  retrieve user and address from getemail function.
                      //   Documentation on QOKSCHD api will make head explode
                      //----------------------------------------------------
                      // wdtitle = 'Add Email To Directory Entry';
                      // wcF6msg = 'F6=' + wdtitle;
 5e                endif;
 
                   exfmt EMAILWIN;
 5b                if infdsfkey = f06;
                      exsr srDirectoryEntry;
 5e                endif;
 
 4x             elseif sfopt = '9';
                   f_RunCmd(f_buildstring(
                   'WRKUSRPRF USRPRF(&)':
                   sfusrprf));
 4e             endif;
 
                clear sfopt;
                update sbfdta1;
 
                readc sbfdta1;
 3e          enddo;
 
 2e       endif;
 1e    enddo;
 
       *inlr = *on;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srDirectoryEntry;
       f_RmvSflMsg(ProgId);
       wdusrid = WCUSRPRF;
       wdaddress = *blanks;
       wdbefore = *blanks;
       wdafter = *blanks;
 
 1b    dou 1 = 2;
          exfmt ADDDIRE;
 
          *in01 = *off;
          *in02 = *off;
          *in03 = *off;
          *in04 = *off;
          wderrmsg = *blanks;
 
 2b       if infdsfkey = f03
             or infdsfkey = f12;
             f_SndSflMsg(ProgId: 'Directory Entry Not Added');
 LV          leavesr;
 2e       endif;
 
 2b       if wdusrid = *blanks;
             *in01 = *on;
             wderrmsg = 'Populate User Indentifier';
 1i          iter;
 2e       endif;
 
 2b       if wdaddress = *blanks;
             *in02 = *on;
             wderrmsg = 'Populate Address';
 1i          iter;
 2e       endif;
 
 2b       if wdbefore = *blanks;
             *in03 = *on;
             wderrmsg = '{Populate Email';
 1i          iter;
 2e       endif;
 
 2b       if wdafter = *blanks;
             *in04 = *on;
             wderrmsg = 'Populate Email';
 1i          iter;
 2e       endif;
 
 2b       if %scan('.': wdafter ) = 0;
             *in04 = *on;
             wderrmsg = 'Address Needs a Period.';
 1i          iter;
 2e       endif;
 
          f_RunCmd('ADDDIRE USRID(' + %trimr(wdusrid) +
          ' ' + %trimr(wdaddress) + ') USRD(' + qs   +
          %trimr(wctext) + qs   + ') USER(' +
          %trimr(wcusrprf) + ') SYSNAME(*LCL) ' +
          'USRDFNFLD((SMTPAUSRID SMTP ' + qs   +
          %trimr(wdbefore) + qs   +
          ') (SMTPDMN SMTP ' + qs   +
          %trimr(wdafter) + qs   +
          ')) MSFSRVLVL(*SYSMS) PREFADR(*SMTP)') ;
 
 2b       if ApiErrDS.BytesReturned > 0;
             wderrmsg = ApiErrDS.ErrMsgId + ': ' +
             f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal);
 1i          iter;
 2e       endif;
 
          f_SndSflMsg(ProgId: 'Directory Entry Added');
 LV       leavesr;
 1e    enddo;
       endsr;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srPrint;
       open JCRUSERSP;
       write PrtHead;
       IsOverFlow = *off;
       yy = rrn1;
 
 1b    for xx = 1 to yy;
          chain xx sbfdta1;
          write PrtDetail;
 2b       if IsOverFlow;
             write PrtHead;
             IsOverFlow = *off;
 2e       endif;
 1e    endfor;
 
       close JCRUSERSP;
       endsr;
 
       //---------------------------------------------------------
       begsr srOutfile;
       errmsg = *blanks;
       OutMbrOpt = '*REPLACE';
       extombr = '*FIRST';
       InfdsRcdFmt = 'OUTFILEWIN';
       CsrRowColDS =
       f_GetRowColumn('OUTFILE':InfdsFile:InfdsLib:InfdsRcdfmt);
       pts01 = %bitor(Green: UL);
       pts02 = pts01;
       pts03 = pts01;
 
 1b    dou 1 = 2 ;
          exfmt outfilewin;
 2b       if *inkc or *inkl;
 LV          leavesr;
 2e       endif;
 
          pts01 = %bitor(Green: UL);
          pts02 = pts01;
          pts03 = pts01;
 
 2b       if OutMbrOpt = *blanks;
             OutMbrOpt = '*REPLACE';
 2e       endif;
 
 2b       if extombr = *blanks;
             extombr = '*FIRST';
 2e       endif;
 
 2b       if OutFile = *blanks;
             errmsg = ('Must select Outfile name');
             CsrRowColDS =
             f_GetRowColumn('OUTFILE':InfdsFile:InfdsLib:InfdsRcdfmt);
             pts01 = %bitor(Green: RI);
 1i          iter;
 2e       endif;
 
 2b       if not(OutLib = '*LIBL'
             or OutLib = '*CURLIB'
             or f_IsValidObj(OutLib: 'QSYS': '*LIB'));
             errmsg = 'Library Name Invalid';
             CsrRowColDS =
             f_GetRowColumn('OUTLIB':InfdsFile:InfdsLib:InfdsRcdfmt);
             pts02 = %bitor(Green: RI);
 1i          iter;
 2e       endif;
 
 2b       if not(OutMbrOpt = '*REPLACE' or OutMbrOpt = '*ADD');
             errmsg = 'Replace or add records Invalid';
             CsrRowColDS =
             f_GetRowColumn('OUTMBROPT':InfdsFile:InfdsLib:InfdsRcdfmt);
             pts03 = %bitor(Green: RI);
 1i          iter;
 2e       endif;
 
          // smurf
          ApiErrDS.ErrMsgId = *blanks;
          f_IsValidMbr(Outfile + Outlib: extombr);
 
 2b       if ApiErrDS.ErrMsgId = 'CPF9812';
 3b          if OutLib = '*LIBL';
                errmsg = ApiErrDS.ErrMsgId + ': ' +
                %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal));
 1i             iter;
 3x          else;
                f_RunCmd(
                f_BuildString('CRTDUPOBJ  OBJ(&) FROMLIB(*LIBL) +
                OBJTYPE(*FILE) TOLIB(&) NEWOBJ(&) +
                DATA(*NO) CST(*NO) TRG(*NO)':
                'JCRUSERSF ':
                OutLib:
                OutFile));
 
 4b             if ApiErrDS.BytesReturned > 0;
                   errmsg = ApiErrDS.ErrMsgId +
                   ': Error occurred on CRTPF';
 1i                iter  ;
 4e             endif;
 
 4b             if extombr = '*FIRST';
                   extOmbr = OutFile;
 4e             endif;
 
                // note ddl created files can not have all members removed
                f_RunCmd(
                f_BuildString('RNMM  FILE(&/&) MBR(&) NEWMBR(&)':
                OutLib:
                OutFile:
                'JCRUSERSF ':
                extOmbr));
 3e          endif;
 
             // if File exists but member does not,
             // make sure member can be added to File.
 2x       elseif ApiErrDS.ErrMsgId = 'CPF9815';
             ApiErrDS.ErrMsgId = *blanks;
 
 3b          if extombr = '*FIRST';
                extOmbr = OutFile;
 3e          endif;
             f_RunCmd(f_BuildString('ADDPFM &/& &':
             OutLib: OutFile: extOmbr));
 3b          if (ApiErrDS.ErrMsgId = 'CPF7306');
                errmsg = ('Members for OutFile more than MAX allowed.');
 1i             iter;
 3e          endif;
 
 2x       elseif ApiErrDS.ErrMsgId > *blanks;
             errmsg = ApiErrDS.ErrMsgId + ': ' +
             %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal));
 1i          iter;
 2e       endif;
 
 2b       if OutMbrOpt = '*REPLACE';
             f_RunCmd(
             f_BuildString('CLRPFM  FILE(&/&) MBR(&)':
             OutLib:
             OutFile:
             extOmbr));
 2e       endif;
 
          // compare record format ID for level check issues
 2b       if not(f_GetFileLevelID('JCRUSERSF ' + '*LIBL')
                 = f_GetFileLevelID(OutFile + OutLib));
 
             errmsg =
             f_BuildString('CPF4131: Level check on file & in library &.':
             OutFile:
             OutLib);
 1i          iter;
 2e       endif;
 
          extOfile = f_GetQual(OutFile + OutLib);
          open JCRUSERSF;
 
          yy = rrn1;
 
 2b       for xx = 1 to yy;
             chain xx sbfdta1;
             wcAddress = f_GetEmail(sfusrprf);
 3b          if wcAddress = '@';
                wcAddress = *blanks;
 3e          endif;
             write JCRUSERSFR;
 2e       endfor;
 
          close JCRUSERSF;
          errmsg = 'Outfile ' + %trimr(extOfile) +
          ' generated by JCRUSERS';
 LV       leavesr;
 1e    enddo;
       endsr;
 
       //---------------------------------------------------------
       // spin through user space applying filters
       //---------------------------------------------------------
       begsr srsearchuserspace;
       exsr srclearsfl;
       Autu0100ptr = ApiHeadPtr + ApiHead.OffSetToList;
 1b    for ForCount = 1 to ApiHead.ListEntryCount;
 
          exsr srApplyFilters;
 
          Autu0100Ptr += ApiHead.ListEntrySize;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // load user profile names into user space.
       //---------------------------------------------------------
       begsr srhardrefresh;
       exsr srclearsfl;
 1b    if not isfirsttime;
          scuser = *blanks;
          sctext = *blanks;
          scinit = *blanks;
          scjobd = *blanks;
          scoutq = *blanks;
 1e    endif;
 
       callp QSYLAUTU(
             UserSpaceName:
             'AUTU0100':
             ApiErrDS);
 
       //---------------------------------------------------------
       // get user id then load info from qsyrusri into user space
       //  do initial sbfile load as quickly as possible.
       //---------------------------------------------------------
       Autu0100ptr = ApiHeadPtr + ApiHead.OffSetToList;
 1b    for ForCount = 1 to ApiHead.ListEntryCount;
 
          // retrieve values from the user profile.
          callp QSYRUSRI(
                Usri0300DS:
                %len(Usri0300DS):
                'USRI0300':
                Autu0100DS.UsrPrf:
                ApiErrDS);
 
          Autu0100DS.LastUsed = f_GetApiISO(Usri0300DS.PrvSignDatTim);
          Autu0100DS.Status = usri0300DS.status;
          Autu0100DS.Text = usri0300DS.text;
          Autu0100DS.Initialpgm = usri0300DS.InitialPgm;
          Autu0100DS.InitialpgmL = usri0300DS.InitialPgmL;
          Autu0100DS.Jobd = usri0300DS.Jobd;
          Autu0100DS.JobdL = usri0300DS.JobdL;
          Autu0100DS.Outq = usri0300DS.Outq;
          Autu0100DS.OutqL = usri0300DS.OutqL;
 
          exsr srApplyFilters;
 
          Autu0100Ptr += ApiHead.ListEntrySize;
 1e    endfor;
       endsr;
 
       //-----------------------
       //-----------------------
       begsr srclearsfl;
       *in31 = *off;
       *in32 = *off;
       write SBFCTL1;
       *in32 = *on;
       rrn1 = 0;
       sfopt = *blanks;
       endsr;
 
       //-----------------------
       // if first character is blank, then filter is a wild card
       // if first character <> blank, then trailing is wild card
       // scuser is position to.
       // sctext, scinit, scjobd, scoutq is only show these.
       //-----------------------
       begsr srApplyFilters;
 
       IsOk1 = *off;
 1b    if scuser > *blanks;
 2b       if %subst(scuser:1:1)>*blanks;
             lenscan = %len(%trimr(scuser));
 3b          if %subst(Autu0100DS.usrprf:1:lenscan) >= scuser;
                IsOk1 = *on;
 3e          endif;
 2x       else;
 3b          if %scan(%trim(scuser): Autu0100DS.usrprf: 1) > 0;
                IsOk1 = *on;
 3e          endif;
 2e       endif;
 1x    else;
          IsOk1 = *on;
 1e    endif;
 
       //-----------------------------
       IsOk2 = *off;
 1b    if sctext > *blanks;
          upcase = %xlate(lo:up:Autu0100DS.text);
 
 2b       if %subst(sctext:1:1)>*blanks;
             lenscan = %len(%trimr(sctext));
 3b          if %subst(upcase:1:lenscan) = sctext;
                IsOk2 = *on;
 3e          endif;
 2x       else;
 3b          if %scan(%trim(sctext): upcase: 1) > 0;
                IsOk2 = *on;
 3e          endif;
 2e       endif;
 1x    else;
          IsOk2 = *on;
 1e    endif;
 
       //-----------------------------
       IsOk3 = *off;
 1b    if scinit > *blanks;
 
 2b       if %subst(scinit:1:1)>*blanks;
             lenscan = %len(%trimr(scinit));
 3b          if %subst(Autu0100DS.Initialpgm:1:lenscan) = scinit;
                IsOk3 = *on;
 3e          endif;
 2x       else;
 3b          if %scan(%trim(scinit): Autu0100DS.Initialpgm: 1) > 0;
                IsOk3 = *on;
 3e          endif;
 2e       endif;
 
 1x    else;
          IsOk3 = *on;
 1e    endif;
 
       //-----------------------------
       IsOk4 = *off;
 1b    if scjobd > *blanks;
 
 2b       if %subst(scjobd:1:1)>*blanks;
             lenscan = %len(%trimr(scjobd));
 3b          if %subst(Autu0100DS.Jobd:1:lenscan) = scjobd;
                IsOk4 = *on;
 3e          endif;
 2x       else;
 3b          if %scan(%trim(scjobd): Autu0100DS.Jobd: 1) > 0;
                IsOk4 = *on;
 3e          endif;
 2e       endif;
 
 1x    else;
          IsOk4 = *on;
 1e    endif;
 
       //-------------------------------------
       IsOk5 = *off;
 1b    if scoutq > *blanks;
 
 2b       if %subst(scoutq:1:1)>*blanks;
             lenscan = %len(%trimr(scoutq));
 3b          if %subst(Autu0100DS.Outq:1:lenscan) = scoutq;
                IsOk5 = *on;
 3e          endif;
 2x       else;
 3b          if %scan(%trim(scoutq): Autu0100DS.Outq: 1) > 0;
                IsOk5 = *on;
 3e          endif;
 2e       endif;
 
 1x    else;
          IsOk5 = *on;
 1e    endif;
 
 1b    if IsOk1 and IsOk2 and IsOk3 and IsOk4 and IsOk5;
          rrn1 += 1;
          sfusrprf = Autu0100DS.UsrPrf;
          sftext = Autu0100DS.text;
          sfLastUsed = Autu0100DS.lastused;
          sfstatus = Autu0100DS.status;
          sfinitpgm = Autu0100DS.Initialpgm;
          sfinitlib = Autu0100DS.InitialpgmL;
          sfjobd    = Autu0100DS.Jobd;
          sfjobdlib = Autu0100DS.JobdL;
          sfoutq =    Autu0100DS.Outq;
          sfoutqlib = Autu0100DS.OutqL;
          write sbfdta1;
 1e    endif;
       endsr;
