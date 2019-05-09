       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRSPLFR - List spool files with Options
       //   Uses SPLF0300 API format that is way faster than WRKSPLF
       //    parms use likeds to match ELEM scheme of wrksplf
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCRSPLFD workstn sfile(sbfdta1: rrn) infds(infds) indds(ind);
 
       /define ApiErrDS
       /define Constants
       /define Infds
       /define f_IsValidObj
       /define FunctionKeys
       /define Ind
       /define Dspatr
       /define Quslspl
       /define Sds
       /define f_RunOptionSplf
       /define f_Quscrtus
       /define f_GetDayName
       /define f_RmvSflMsg
       /define f_SndSflMsg
       // *ENTRY
       /define p_JCRSPLFR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s OptionSav like(sbfoption);
       dcl-s SflRcdNbrSav like(sflrcdnbr);
       dcl-s rrnx like(rrn);
       dcl-s LastRrn like(rrn);
       dcl-s IsOption4 ind;
       dcl-s IsRefresh ind;
 
       dcl-s IsSndSplf ind;
       dcl-s IsEsend ind;
       dcl-c oE const('E=ESndMail   ');
       dcl-c oS const('S=SndSplf  ');
       dcl-c o2 const('2=Change  ');
       dcl-c o3 const('3=Hold   ');
       dcl-c o4 const('4=Delete   ');
       dcl-c o5 const('5=Display');
 
       dcl-pr p_JCRSPLFR2 extpgm('JCRSPLFR2');
         *n char(10);  // Job Name
         *n char(10);  // User Name
         *n char(6);  // Job Number
         *n char(10);  // Spooled File Name
         *n zoned(6) const;  // Spooled File Number
       end-pr;
 
       //---------------------------------------------------------
       scDow = f_GetDayName();
 
 1b    if %subst(p.OutqQual: 1: 4) = '*ALL';
         p.OutqQual = '*ALL';
 1e    endif;
 
       // If generic spooled file name, get length of non-generic name
       aa = %scan('*':p.SplfName);
 
       // create user space
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
 
       // line up option headings depending on what is installed
       IsSndSplf = f_IsValidObj('SNDSPLF': '*LIBL': '*CMD');
       IsEsend = f_IsValidObj('ESNDMAIL': 'ESEND': '*CMD');
 
 1b    if IsSndSplf and IsEsend;
         scOptions = oE + oS + o2 + o3 + o4 + o5;
 1x    elseif IsESend;
         scOptions = oE + o2 + '  ' + o3 + o4 + '  ' + o5;
 1x    elseif IsSndSplf;
         scOptions = oS + '  ' + o2 + '  ' + o3 + o4 + o5;
 1x    else;
         scOptions = o2 + '   ' + o3 + ' ' + o4 + o5;
 1e    endif;
       exsr srRefreshScreen;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
 1b    dou 1 = 2;
         write msgctl;
         write sfooter1;
         exfmt sbfctl1;
 
 2b      if InfdsFkey = f03 or InfdsFkey = f12;
           *inlr = *on;
           return;
 2e      endif;
 
         f_RmvSflMsg(ProgId);
 
         // refresh
         SflRcdNbr = InfdsSflRcdNbr;
 2b      if InfdsFkey = f05;
           IsRefresh = *on;
           SflRcdNbrSav = SflRcdNbr;
           Ind.sfldsp = *off;
           Ind.sfldspctl = *off;
           aoptions1 = %bitor(Green:UL);
           Ind.sflnxtchg = *off;
           write sbfctl1;
           rrn = 0;
           exsr srRefreshScreen;
 
 2x      elseif  Ind.sfldsp;
 
           // process user requests
           readc sbfdta1;
 
 3b        dow not %eof;
 4b          if sbfOption > ' ';
               IsOption4 = (sbfOption = '4');
               //---------------------------------------------------------
 5b            if InfdsFkey = f13;
                 exsr srRepeat_Option;
 3v              leave;
 
 5x            elseif sbfOption = '7';  //duplicate spooled file
                 callp p_JCRSPLFR2(
                       scJobName:
                       scUserID:
                       scJobNo:
                       scSplfName:
                       scSplno);
                 f_SndSflMsg(ProgId: 'Create duplicate +
                 Spooled File ' + %trimr(scSplfName) +
                 ' - completed');
 5x            else;
                 f_RunOptionSplf(
                 sbfOption:
                 scSplfName:
                 %editc(scSplno: 'X'):
                 scJobName:
                 scUserID:
                 scJobNo:
                 ProgId);
 5e            endif;
 
               // update subfile to reflect change
               aoptions1 = %bitor(Green:UL);
 5b            if sbfOption = '3';
                 scStatus = 'HLD';
 5x            elseif sbfOption = '6';
                 scStatus = 'RLS';
 5e            endif;
               clear sbfOption;
 
               update sbfdta1;
 
               // flag deleted spooled file in all views
 5b            if IsOption4;
                 chain rrn sbfdta1;
                 clear sbfdta1;
                 scSplfName = '*deleted';
                 aoptions1 = ND;
                 update sbfdta1;
 
 5e            endif;
               SflRcdNbr = rrn;
 4e          endif;
 
             readc sbfdta1;
 3e        enddo;
 2e      endif;
 1e    enddo;
 
       //---------------------------------------------------------
       // load user space with spooled file attributes
       //---------------------------------------------------------
       begsr srRefreshScreen;
         callp QUSLSPL(
               UserSpaceName:
               'SPLF0300':
               p.Usrprf:
               p.OutqQual:
               p.Formtyp:
               p.UsrDta:
               ApiErrDS);
 
         //---------------------------------------------------------
         // Move through user space to get spooled file attributes
         //---------------------------------------------------------
         splf0300Ptr = ApiHeadPtr + ApiHead.OffSetToList;
 
 1b      for ForCount = 1 to ApiHead.ListEntryCount;
 2b        if p.SplfName = '*ALL'
              or p.SplfName = splf0300DS.SplfName
              or (aa > 0 and
              %subst(p.SplfName:1:aa-1) =
              %subst(splf0300DS.SplfName: 1: aa-1));
 3b          if splf0300DS.Status = 1;
               scStatus = 'RDY';
 3x          elseif splf0300DS.Status = 2;
               scStatus = 'OPN';
 3x          elseif splf0300DS.Status = 3;
               scStatus = 'CLO';
 3x          elseif splf0300DS.Status = 4;
               scStatus = 'SAV';
 3x          elseif splf0300DS.Status = 5;
               scStatus = 'WTR';
 3x          elseif splf0300DS.Status = 6;
               scStatus = 'HLD';
 3x          elseif splf0300DS.Status = 7;
               scStatus = 'MSGW';
 3x          elseif splf0300DS.Status = 8;
               scStatus = 'PND';
 3x          elseif splf0300DS.Status = 9;
               scStatus = 'PRT';
 3x          elseif splf0300DS.Status = 10;
               scStatus = 'FIN';
 3x          elseif splf0300DS.Status = 11;
               scStatus = 'SND';
 3x          elseif splf0300DS.Status = 12;
               scStatus = 'DFR';
 3e          endif;
 
             scSplfName = splf0300DS.SplfName;
             scNumPages = splf0300DS.PageNum;
             scCopies = splf0300DS.Copies;
             scOutq = splf0300DS.Outq;
             scSplno = splf0300DS.SplfNum;
             scJobName = splf0300DS.JobName;
             scUserID = splf0300DS.UserID;
             scJobNo = splf0300DS.JobNo;
             scFormType = splf0300DS.FormType;
             scUsrDta = splf0300DS.UsrDta;
             scSplfDate = %char(%date(splf0300DS.CreateYYMMDD:*YMD0):*MDY/);
             scSplfTime = %char(%time(splf0300DS.CreateHHMMSS: *HMS0));
             clear sbfOption;
             rrn += 1;
 
 3b          if rrn = 9999;
 1v            leave;
 3e          endif;
 
             write sbfdta1;
 2e        endif;
           splf0300Ptr += ApiHead.ListEntrySize;
 1e      endfor;
         Lastrrn = rrn;
 
         //---------------------------------------------------------
         //---------------------------------------------------------
         SflRcdNbr = 1;
         Ind.sfldsp = (rrn > 0);
 1b      if (not Ind.sfldsp);
           f_SndSflMsg(ProgId: 'No spooled files match selection');
 1e      endif;
         Ind.sfldspctl = *on;
 
         //---------------------------------------------------------
 1b      if IsRefresh and Ind.sfldsp;
 2b        if SflRcdNbrSav > rrn;
             SflRcdNbr = rrn;
 2x        else;
 3b          if SflRcdNbrSav = 0;
               SflRcdNbr = 1;
 3x          else;
               SflRcdNbr = SflRcdNbrSav;
 3e          endif;
 2e        endif;
           IsRefresh = *off;
 1e      endif;
       endsr;
 
       //---------------------------------------------------------
       // Make 'repeat' option work same way it does in PDM.
       //  User can select option, then press
       //   f13 to have it repeat to end of subfile.
       //---------------------------------------------------------
       begsr srRepeat_Option;
         SflRcdNbr = rrn;
         OptionSav = sbfOption;
 1b      for rrnx = SflRcdNbr to LastRrn;
           chain rrnx sbfdta1;
 
 2b        if not %found;
 1v          leave;
 2e        endif;
           Ind.sflnxtchg = *on;
           sbfOption = OptionSav;
 
           update sbfdta1;
 1e      endfor;
         Ind.sflnxtchg = *off;
       endsr;
