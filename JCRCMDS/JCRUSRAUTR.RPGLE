       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRUSRAUTR - List user profile class/special authorities
       //  use new(to me) likds method to bring in list of entries.  cool
       //---------------------------------------------------------
       /define ControlStatements
       /define f_Quscrtus
       /define ApiErrDS
       /define f_GetApiISO
       /define f_DisplayLastSplf
       /define f_GetDayName
       /define ListAuthorizedUsers
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRUSRAUTP printer oflind(IsOverFlow) usropn;
 
       dcl-s xx uns(3);
       dcl-s IsKeeper ind;
 
       dcl-ds PrtfHeading inz;
        pAuth1;
        pAuth2;
        pAuth3;
        pAuth4;
        pAuth5;
        pAuth6;
        pAuth7;
        pAuth8;
        pAuth9;
        pHeadArry char(9) dim(8) pos(1);
       end-ds;
 
       dcl-ds PrtfDetail;
        PALLOBJ;
        PSECADM;
        PJOBCTL;
        PSPLCTL;
        PSAVSYS;
        PSERVICE;
        PAUDIT;
        PIOSYSCH;
        pDetailArry char(1) dim(8) pos(1);
       end-ds;
 
       dcl-ds entlistds qualified;
        Count uns(5);
        Arry char(9) dim(8);
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_Class char(7);
        p_AuthList likeds(entlistds);
        p_Status char(9);
        p_Output char(8);
       end-pi;
       //---------------------------------------------------------
 
       // load input parms into print fields
       open JCRUSRAUTP;
       pClass = p_Class;
       scDow = f_GetDayName();
 
       pHeadArry = %subarr(p_AuthList.Arry: 1: p_AuthList.Count);
       write PrtHead;
       IsOverFlow = *off;
 
       // load user profile names into user space
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
       callp QSYLAUTU(UserSpaceName: 'AUTU0200':  ApiErrDS);
       Autu0200ptr = ApiHeadPtr + ApiHead.OffSetToList;
 
 1b    for ForCount = 1 to ApiHead.ListEntryCount;
 
          // retrieve values from user profile
          callp QSYRUSRI(
                Usri0300DS:
                %len(Usri0300DS):
                'USRI0300':
                UsrPrf:
                ApiErrDS);
 
          // Check selection conditions
          IsKeeper = *off;
 2b       if p_Status = '*ALL' or
             Usri0300DS.Status = p_Status;
 
 3b          if p_Class = '*ALL'
                or Usri0300DS.UserClass = p_Class;
 
 4b             if p_AuthList.Arry(1) = '*ALL';
                   IsKeeper = *on;
 4x             else;
 5b                if (Usri0300DS.SpecialAuthArry(1) = 'Y'
                      and %lookup('*ALLOBJ': p_AuthList.Arry:
                      1: p_AuthList.Count) > 0)
 
                      or (Usri0300DS.SpecialAuthArry(2) = 'Y'
                      and %lookup('*SECADM': p_AuthList.Arry:
                      1: p_AuthList.Count) > 0)
 
                      or (Usri0300DS.SpecialAuthArry(3) = 'Y'
                      and %lookup('*JOBCTL': p_AuthList.Arry:
                      1: p_AuthList.Count) > 0)
 
                      or (Usri0300DS.SpecialAuthArry(4) = 'Y'
                      and %lookup('*SPLCTL': p_AuthList.Arry:
                      1: p_AuthList.Count) > 0)
 
                      or (Usri0300DS.SpecialAuthArry(5) = 'Y'
                      and %lookup('*SAVSYS': p_AuthList.Arry:
                      1: p_AuthList.Count) > 0)
 
                      or (Usri0300DS.SpecialAuthArry(6) = 'Y'
                      and %lookup('*SERVICE': p_AuthList.Arry:
                      1: p_AuthList.Count) > 0)
 
                      or (Usri0300DS.SpecialAuthArry(7) = 'Y'
                      and %lookup('*AUDIT': p_AuthList.Arry:
                      1: p_AuthList.Count) > 0)
                      or (Usri0300DS.SpecialAuthArry(8) = 'Y'
                      and %lookup('*IOSYSCFG': p_AuthList.Arry:
                      p_AuthList.Count) > 0);
                      IsKeeper = *on;
 5e                endif;
 4e             endif;
 3e          endif;
 2e       endif;
 
 2b       if IsKeeper;
             LastUsed = f_GetApiISO(Usri0300DS.PrvSignDatTim);
 
 3b          for xx = 1 to 8;
 4b             if Usri0300DS.SpecialAuthArry(xx) = 'Y';
                   pDetailArry(xx) = 'Y';
 4x             else;
                   pDetailArry(xx) = '.';
 4e             endif;
 3e          endfor;
             pdClass = Usri0300DS.UserClass;
             Text33 = UsrPrfTxt;
 
             write PrtDetail;
 3b          if IsOverFlow;
                write PrtHead;
                IsOverFlow = *off;
 3e          endif;
 2e       endif;
 
          Autu0200Ptr += ApiHead.ListEntrySize;
 1e    endfor;
 
       close JCRUSRAUTP;
       f_DisplayLastSplf('JCRUSRAUTR': p_Output);
       *inlr = *on;
