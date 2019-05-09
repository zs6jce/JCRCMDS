       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------------
       // JCRJOBDR -  Search JOBD for Library or Outq or Jobq
       //---------------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCRJOBDD workstn sfile(sbfdta1:rrn1) infds(infds) indds(ind);
       dcl-f JCRJOBDP printer oflind(IsOverFlow) usropn;
 
       /define Sds
       /define Infds
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
       /define Quslobj
       /define f_Qusrobjd
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s rrn1 uns(5);
       dcl-s xx uns(5);
       dcl-s yy uns(5);
       dcl-s isfirsttime ind;
       dcl-s IsOk1 ind;
       dcl-s IsOk2 ind;
       dcl-s IsOk3 ind;
       dcl-s lenscan uns(3);
 
       // name screen indicators
       dcl-ds ind qualified;
        changes ind pos(12) inz(*off);
        sfldsp ind pos(31) inz(*off);
        sfldspctl ind pos(32) inz(*off);
       end-ds;
 
       // Retrieve Job Description Information
       dcl-pr Qwdrjobd extpgm('QWDRJOBD');
        *n char(1000) options(*varsize);  // receiver
        *n int(10) const;  // receiver length
        *n char(8) const;  // api format
        *n char(20) const;  // jobd and lib
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds Jobd0100DS len(3000) qualified;
        Jobd char(10) pos(9);
        JobdL char(10) pos(19);
        UsrPrf char(10) pos(29);
        Jobq char(10) pos(55);
        JobqL char(10) pos(65);
        Outq char(10) pos(87);
        OutqL char(10) pos(97);
        Text char(50) pos(310);
        LibraryOffset int(10) pos(361);
        LibraryCount int(10) pos(365);
       end-ds;
 
       dcl-s JobdLibl char(10) based(jobdliblptr);
       dcl-pi *n end-pi;
 
       f_RmvSflMsg(ProgId);
       scDow = f_GetDayName();
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
       exsr srclearsfl;
       isfirsttime = *on;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
 1b    dou 1=2;
          ind.sfldsp = (rrn1 > 0);
          ind.sfldspctl = *on;
 
          write msgctl;
          write SFOOTER1;
          exfmt SBFCTL1;
          f_RmvSflMsg(ProgId);
 
 2b       if infdsfkey = f03
             or infdsfkey = f12;
             *inlr = *on;
             return;
 
 2x       elseif infdsfkey = f05;
             sclib = *blanks;
             scjobq = *blanks;
             scoutq = *blanks;
             exsr srclearsfl;
 
 2x       elseif infdsfkey = f06;
             exsr srPrint;
             f_SndSflMsg(ProgId: 'Print Completed');
 
 2x       elseif infdsfkey = f08;
             f_RunCmd('WRKSPLF');
 
 2x       elseif ind.changes;
 3b          if IsFirsttime;
                exsr srhardrefresh;
                isfirsttime = *off;
 3x          else;
                exsr srclearsfl;
                exsr srApplyFilters;
 3e          endif;
 
             //----------------------------------------
 2x       elseif (rrn1 > 0);
 
             readc sbfdta1;
 3b          dow not %eof();
 
 4b             if sfopt = '5';
                   f_RunCmd(f_buildstring(
                   'DSPJOBD JOBD(&)':
                   %trim(SFJOBDLIB) +'/'+SFJOBD));
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
       begsr srPrint;
       open JCRJOBDP;
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
 
       close JCRJOBDP;
       endsr;
 
       //---------------------------------------------------------
       // load user profile names into user space.
       //---------------------------------------------------------
       begsr srhardrefresh;
       exsr srclearsfl;
 1b    if not isfirsttime;
          sclib = *blanks;
          scjobq = *blanks;
          scoutq = *blanks;
 1e    endif;
 
       callp QUSLOBJ(
             UserSpaceName:
             'OBJL0100':
             '*ALL      *ALL':
             '*JOBD':
             ApiErrDS);
 
       exsr srApplyFilters;
       endsr;
 
       //-----------------------
       //-----------------------
       begsr srclearsfl;
       ind.sfldsp = *off;
       ind.sfldspctl = *off;
       write SBFCTL1;
       ind.sfldspctl = *on;
       rrn1 = 0;
       sfopt = *blanks;
       endsr;
 
       //-----------------------
       // if first character is blank, then filter is a wild card
       // first character <> blank, then trailing is wild card
       //-----------------------
       begsr srApplyFilters;
       QuslobjPtr = ApiHeadPtr + ApiHead.OffSetToList;
 
 1b    for ForCount = 1 to ApiHead.ListEntryCount;
          callp Qwdrjobd(
                Jobd0100DS:
                %size(Jobd0100DS):
                'JOBD0100':
                QuslobjDS.ObjNam + QuslobjDS.ObjLib:
                ApiErrDS);
 
          IsOk1 = *off;
 2b       if sclib > *blanks;
             JobdLiblPtr = %addr(Jobd0100DS) + Jobd0100DS.LibraryOffset;
 
 3b          for ForCount2 = 1 to Jobd0100DS.LibraryCount;
 4b             if JobdLibl = sclib;
                   sflib = JobdLibl;
                   IsOk1 = *on;
 4e             endif;
                JobdLiblPtr += 11;
 3e          endfor;
 
 2x       else;
             sflib = *blanks;
             IsOk1 = *on;
 2e       endif;
 
          //-----------------------------
          IsOk2 = *off;
 2b       if scjobq > *blanks;
 
 3b          if %subst(scjobq:1:1)>*blanks;
                lenscan = %len(%trimr(scjobq));
 4b             if %subst(Jobd0100DS.JobQ:1:lenscan) = scjobq;
                   IsOk2 = *on;
 4e             endif;
 3x          else;
 4b             if %scan(%trim(scjobq): Jobd0100DS.JobQ: 1) > 0;
                   IsOk2 = *on;
 4e             endif;
 3e          endif;
 
 2x       else;
             IsOk2 = *on;
 2e       endif;
 
          //-------------------------------------
          IsOk3 = *off;
 2b       if scoutq > *blanks;
 
 3b          if %subst(scoutq:1:1)>*blanks;
                lenscan = %len(%trimr(scoutq));
 4b             if %subst(Jobd0100DS.Outq:1:lenscan) = scoutq;
                   IsOk3 = *on;
 4e             endif;
 3x          else;
 4b             if %scan(%trim(scoutq): Jobd0100DS.Outq: 1) > 0;
                   IsOk3 = *on;
 4e             endif;
 3e          endif;
 
 2x       else;
             IsOk3 = *on;
 2e       endif;
 
 2b       if IsOk1 and IsOk2 and IsOk3;
             QusrObjDS =
             f_QUSROBJD(QuslobjDS.ObjNam +  QuslobjDS.ObjLib:
             '*JOBD': 'OBJD0400');
 
 3b          if QusrobjDS.NumDaysUsed > 0;
                sfLastUsed = f_GetApiISO(QusrobjDS.LastUsedDate + '      ');
 3x          else;
                sfLastUsed = *blanks;
 3e          endif;
 
             sftext = Jobd0100DS.text;
             sfjobq    = Jobd0100DS.Jobq;
             sfjobqlib = Jobd0100DS.JobqL;
             sfjobd    = Jobd0100DS.Jobd;
             sfjobdlib = Jobd0100DS.JobdL;
             sfoutq =    Jobd0100DS.Outq;
             sfoutqlib = Jobd0100DS.OutqL;
             rrn1 += 1;
             write sbfdta1;
 2e       endif;
 
          QuslobjPtr += ApiHead.ListEntrySize;
 1e    endfor;
       endsr;
