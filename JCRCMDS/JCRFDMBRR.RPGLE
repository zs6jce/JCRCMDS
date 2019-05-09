       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRFDMBRR - File descriptions member list
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCRFDMBRD workstn sfile(sbfdta1: rrn) infds(infds) indds(ind);
 
       /define ApiErrDS
       /define Constants
       /define DspAtr
       /define Infds
       /define FunctionKeys
       /define Ind
       /define Quslmbr
       /define f_Qusrmbrd
       /define f_GetApiISO
       /define f_GetApiHMS
       /define Sds
       /define f_RunOptionFile
       /define f_GetQual
       /define f_Quscrtus
       /define f_RmvSflMsg
       /define f_SndSflMsg
       /define f_SndStatMsg
       /define f_GetFileUtil
       /define f_GetDayName
       /define BitMask
       /define Qdbldbr
       /define Qdbrtvfd
       /define f_RunCmd
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s HeaderLib char(10);
       dcl-s HeaderObj char(10);
       dcl-s KeyFld char(10) inz('SCMBR');
       dcl-s SortSequence char(10) inz('Ascend');
       dcl-s MbrCnt int(10);
       dcl-s DeleteCount uns(5);
       dcl-s NumberOfRecs uns(5);
       dcl-s RRNsave like(rrn);
       dcl-s dbUtility char(8);
       dcl-s p_AllowOption char(4) inz('*YES');
       dcl-s apiformat char(8);
       dcl-s IsRefresh ind inz(*off);
       dcl-s IsFirstTime ind;
 
       dcl-s PfFile char(10);
       dcl-s PfLib char(10);
       dcl-s ForCount1 like(ApiHead.listentrycount);
       dcl-s IsLF ind;
 
       dcl-ds HeaderSection qualified based(HeaderPtr);
         FileUsed char(10) pos(1);
         LibUsed char(10) pos(11);
         FileText char(30) pos(31);
       end-ds;
 
       // load screen fields for sorting
       dcl-ds Sortds dim(9999) qualified;
         Mbr char(10);
         Type char(10);
         ChgDate char(10);
         ChgTime char(8);
         Recs zoned(9);
         RecDlt zoned(9);
         Size zoned(9);
         Text char(50);
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
         p_FileQual char(20);
         p_MbrType char(10);
       end-pi;
       //---------------------------------------------------------
 
       SortDescen = 'F14=Sort Descend';
       IsFirstTime = *on;
 
       f_SndStatMsg('Retrieving ' +
       %trimr(f_GetQual(p_FileQual)) + ' - in progress');
       scDow = f_GetDayName();
 
       DbUtility = '2=' + f_GetFileUtil();
       scHeadOpt = '1=Field Descriptions   ' +
       %trimr(DbUtility) + '   4=Rmvmbr   5=Wrkmbrpdm   9=Clrpfm';
 
 1b    if p_AllowOption = '*NO';
         aOptionSfl = %bitor(ND: PR);
         aOptions = ND;
 1x    else;
         aOptionSfl = %bitor(Green: UL);
         aOptions = Blue;
 1e    endif;
 
       // Create user space/retrieve pointer to user space
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
       HeaderObj = %subst(p_FileQual: 1: 10);
       HeaderLib = %subst(p_FileQual: 11: 10);
       exsr srRefreshScreen;
 
       //---------------------------------------------------------
 1b    dou 1 = 2;
         Ind.sfldsp = (rrn > 0);
         Ind.sfldspctl = *on;
 2b      if (not Ind.sfldsp);
           f_RmvSflMsg(ProgId);
           f_SndSflMsg(ProgId: 'No members were found');
 2e      endif;
 
         write msgctl;
         write sfooter1;
         exfmt sbfctl1;
 2b      if InfdsFkey = f03 or InfdsFkey = f12;
           *inlr = *on;
           return;
 2e      endif;
 
         f_RmvSflMsg(ProgId);
 
         //-------------------------------
 2b      if InfdsFkey = f05;
           IsRefresh = *on;
           exsr srRefreshScreen;
           IsRefresh = *off;
 1i        iter;
 2e      endif;
 
 2b      if InfdsSflRcdNbr > 0;
           SflRcdNbr = InfdsSflRcdNbr;
 2x      else;
           SflRcdNbr = 1;
 2e      endif;
 
         // re-sort subfile
 2b      if InfdsFkey = f13
            or InfdsFkey = f14;
 3b        if InfdsFkey = f13;
             SortSequence = 'Ascend';
 3e        endif;
 3b        if InfdsFkey = f14;
             SortSequence = 'Descend';
 3e        endif;
 
           KeyFld = curfld;
           exsr srSortAndReload;
           SflRcdNbr = 1;
 1i        iter;
 2e      endif;
 
         //-----------------------------------------
         DeleteCount = 0;
 2b      if p_AllowOption = '*YES';
           readc sbfdta1;
 3b        dow not %eof;
 
             // as a precaution, limit options to those visible on screen
 4b          if sbfOption = 1
                or sbfOption = 2
                or sbfOption = 4
                or sbfOption = 5
                or sbfOption = 9;
 
 5b            if sbfOption = 4;
                 exsr srRemoveMember;
 5x            else;
                 f_RunOptionFile(
                 sbfOption:
                 HeaderObj:
                 HeaderLib:
                 '*FIRST':
                 scmbr:
                 ProgId);
 5e            endif;
 
               // Update subfile to reflect changes
 5b            if sbfOption = 4 and ApiErrDS.BytesReturned = 0;
                 DeleteCount += 1;
 5x            else;
                 sbfOption = 0;
                 SflRcdNbr = rrn;
                 update sbfdta1;
 5e            endif;
 4e          endif;
             readc sbfdta1;
 3e        enddo;
 
 3b        if DeleteCount > 0;
             exsr srSortAndReload;
             DeleteCount = 0;
 3e        endif;
 2e      endif;
 1e    enddo;
 
       //---------------------------------------------------------
       // load object name list
       //---------------------------------------------------------
       begsr srRefreshScreen;
         sbfOption = 0;
         Ind.sfldsp = *off;
         Ind.sfldspctl = *off;
         write sbfctl1;
         rrn = 0;
 
         //-------------------------------------------------------
         // if member type = *all, let fastest api format run,
         // else run slower format so can check for member type.
       //  (still faster than calling retrieve member description for every member
         //-------------------------------------------------------
 1b      if p_MbrType = '*ALL';
           apiformat = 'MBRL0100';
 1x      else;
           apiformat = 'MBRL0200';
 1e      endif;
         //-------------------------------------------------------
 
         callp QUSLMBR(
               UserSpaceName:
               apiformat:
               p_FileQual:
               '*ALL':
               '0':
               ApiErrDS);
 
         // file text information
         HeaderPtr = ApiHeadPtr + ApiHead.OffSetToHeader;
 
         scObjHead = %trimr(HeaderSection.FileUsed) + '  ' +
         %trimr(HeaderSection.LibUsed) + '  ' +
         HeaderSection.FileText;
 
         // Process data from user space by moving pointer
         MbrCnt = 0;
         QuslmbrPtr = ApiHeadPtr + ApiHead.OffSetToList;
 
 1b      for ForCount = 1 to ApiHead.ListEntryCount;
 
 2b        if p_MbrType = '*ALL'
              or QuslmbrDS.MbrType = p_MbrType;
 
             QusrmbrdDS =
             f_Qusrmbrd(p_FileQual: QuslmbrDS.MbrName: 'MBRD0200');
 
             SCMBR = QusrmbrdDS.Mbr;
             SCMBRTYPE = QusrmbrdDS.MbrType;
             SCCHGDATE = f_GetApiISO(QusrmbrdDS.ChangeDateTime);
             SCCHGTIME = f_GetApiHMS(QusrmbrdDS.ChangeDateTime);
             SCRECS = QusrmbrdDS.CurrNumberRecs;
             SCSIZE =
             (QusrmbrdDS.SizeOfData * QusrmbrdDS.SizeOfDataMLT)/1024;
             SCRECDLT = QusrmbrdDS.DeletedRecs;
             SCTEXT = QusrmbrdDS.Text;
             rrn += 1;
             MbrCnt += 1;
 
             Sortds(MbrCnt).Mbr = scMbr;
             Sortds(MbrCnt).Type = scMbrType;
             Sortds(MbrCnt).ChgDate = scChgDate;
             Sortds(MbrCnt).ChgTime = scChgTime;
             Sortds(MbrCnt).Recs = scRecs;
             Sortds(MbrCnt).RecDlt = scRecDlt;
             Sortds(MbrCnt).Size = scSize;
             Sortds(MbrCnt).Text = scText;
 
 3b          if rrn = 9999;
 1v            leave;
 3e          endif;
 
 2e        endif;
           QuslmbrPtr += ApiHead.ListEntrySize;
 1e      endfor;
         RRNsave = rrn;
 
         // Allow user to make selection from subfile
         exsr srLoadFromSorter;
 
         // keep cursor in place on refreshs
 1b      if IsRefresh = *off  or SflRcdNbr <= 0;
           SflRcdNbr = 1;
 1e      endif;
       endsr;
 
       //---------------------------------------------------------
       // Read subfile and load records into sorting array
       //---------------------------------------------------------
       begsr srSortAndReload;
         NumberOfRecs = RRNsave;
 
 1b      if DeleteCount > 0;
           RRNsave -= DeleteCount;
 2b        if SflRcdNbr > RRNsave;
             SflRcdNbr = RRNsave;
 2e        endif;
 1e      endif;
 
         MbrCnt = 0;
 1b      for rrn = 1 to NumberOfRecs;
           chain rrn sbfdta1;
 2b        if not(sbfOption = 4);  //DELETE OPTION
             MbrCnt += 1;
             Sortds(MbrCnt).Mbr = scMbr;
             Sortds(MbrCnt).Type = scMbrType;
             Sortds(MbrCnt).ChgDate = scChgDate;
             Sortds(MbrCnt).ChgTime = scChgTime;
             Sortds(MbrCnt).Recs = scRecs;
             Sortds(MbrCnt).RecDlt = scRecDlt;
             Sortds(MbrCnt).Size = scSize;
             Sortds(MbrCnt).Text = scText;
 2e        endif;
 1e      endfor;
         exsr srLoadFromSorter;
         rrn = RRNsave;
       endsr;
 
       //---------------------------------------------------------
       // Sort array and load back into subfile
       //---------------------------------------------------------
       begsr srLoadFromSorter;
         Ind.sfldsp = *off;
         Ind.sfldspctl = *off;
         write sbfctl1;
         rrn = 0;
 1b      if MbrCnt > 0;
 
 2b        if KeyFld = 'SCMBR';
 3b          if SortSequence = 'Descend';
               sorta(d) %subarr(Sortds(*).Mbr: 1: MbrCnt);
 3x          else;
               sorta(a) %subarr(Sortds(*).Mbr: 1: MbrCnt);
 3e          endif;
             f_SndSflMsg(ProgId: 'Sort ' + %trimr(SortSequence) +
             ' by Member');
 
           //----------------------------
 2x        elseif KeyFld = 'SCMBRTYPE';
 3b          if SortSequence = 'Descend';
               sorta(d) %subarr(Sortds(*).Type: 1: MbrCnt);
 3x          else;
               sorta(a) %subarr(Sortds(*).Type: 1: MbrCnt);
 3e          endif;
             f_SndSflMsg(ProgId: 'Sort ' + %trimr(SortSequence) +
             ' by Member Type');
 
           //----------------------------
 2x        elseif KeyFld = 'SCCHGTIME' or KeyFld = 'SCCHGDATE';
 3b          if SortSequence = 'Descend';
               sorta(d) %subarr(Sortds(*).ChgDate: 1: MbrCnt);
 3x          else;
               sorta(a) %subarr(Sortds(*).ChgDate: 1: MbrCnt);
 3e          endif;
             f_SndSflMsg(ProgId: 'Sort ' + %trimr(SortSequence) +
             ' by Change Date/Time');
 
           //----------------------------
 2x        elseif KeyFld = 'SCRECS';
 3b          if SortSequence = 'Descend';
               sorta(d) %subarr(Sortds(*).Recs: 1: MbrCnt);
 3x          else;
               sorta(a) %subarr(Sortds(*).Recs: 1: MbrCnt);
 3e          endif;
             f_SndSflMsg(ProgId: 'Sort ' + %trimr(SortSequence) +
             ' by Number Records');
 
           //----------------------------
 2x        elseif KeyFld = 'SCRECDLT';
 3b          if SortSequence = 'Descend';
               sorta(d) %subarr(Sortds(*).RecDlt: 1: MbrCnt);
 3x          else;
               sorta(a) %subarr(Sortds(*).RecDlt: 1: MbrCnt);
 3e          endif;
             f_SndSflMsg(ProgId: 'Sort ' + %trimr(SortSequence) +
             ' by Deleted Records');
 
           //----------------------------
 2x        elseif KeyFld = 'SCSIZE';
 3b          if SortSequence = 'Descend';
               sorta(d) %subarr(Sortds(*).Size: 1: MbrCnt);
 3x          else;
               sorta(a) %subarr(Sortds(*).Size: 1: MbrCnt);
 3e          endif;
             f_SndSflMsg(ProgId: 'Sort ' + %trimr(SortSequence) +
             ' by Deleted Records');
 
           //----------------------------
 2x        elseif KeyFld = 'SCTEXT';
 3b          if SortSequence = 'Descend';
               sorta(d) %subarr(Sortds(*).Text: 1: MbrCnt);
 3x          else;
               sorta(a) %subarr(Sortds(*).Text: 1: MbrCnt);
 3e          endif;
             f_SndSflMsg(ProgId: 'Sort ' + %trimr(SortSequence) +
             ' by Text');
 2e        endif;
 
 2b        if MbrCnt >= 9999;
             f_RmvSflMsg(ProgId);
             f_SndSflMsg(ProgId: '9999+ members returned. Narrow search.');
             MbrCnt = 9999;
 2e        endif;
 
 2b        for aa = 1 to MbrCnt;
             scMbr = Sortds(aa).Mbr;
             scMbrType = Sortds(aa).Type;
             scChgDate = Sortds(aa).ChgDate;
             scChgTime = Sortds(aa).ChgTime;
             scRecs = Sortds(aa).Recs;
             scRecDlt = Sortds(aa).RecDlt;
             scSize = Sortds(aa).Size;
             scText = Sortds(aa).Text;
             sbfOption = 0;
             rrn += 1;
             write sbfdta1;
 2e        endfor;
 1e      endif;
       endsr;
 
       //---------------------------------------------------------
       //  remove members LF/PF multiple record format etc..
       //   get PF (or PFs file is based on)
       //     remove member from each data base relations
       //       remove member from PF(s)
       //---------------------------------------------------------
       begsr srRemoveMember;
         UserSpaceName2 = 'JCRRMVMBR QTEMP';
         ApiHeadPtr2 = f_Quscrtus(UserSpaceName2);
 
         AllocatedSize = f_GetAllocatedSize(HeaderObj+HeaderLib: '*FIRST');
 
 1b      if ApiErrDS.BytesReturned = 0;
           Fild0100ptr = %alloc(AllocatedSize);
           callp QDBRTVFD(
                 Fild0100ds:
                 AllocatedSize:
                 ReturnFileQual:
                 'FILD0100':
                 HeaderObj+HeaderLib:
                 scmbr:
                 '0':
                 '*FILETYPE':
                 '*EXT':
                 ApiErrDS);
 
           PfFile = %subst(ReturnFileQual: 1: 10);
           PfLib = %subst(ReturnFileQual: 11: 10);
           IsLF = (%bitand(bit2: Fild0100ds.TypeBits) = bit2);
           fscopePtr = Fild0100ptr + Fild0100ds.OffsFileScope;
 
 2b        if Not IsLF;
             exsr srDataBaseRelations;
             f_runcmd('RMVM FILE(' +
             %trimr(PfLib) + '/' +
             %trimr(PfFile) + ') MBR(' +
             %trimr(scmbr) + ')');
 
 2x        else;
 3b          for forcount2 = 1 to Fild0100ds.NumOfBasedPf;
               pffile = FileScopeArry.BasedOnPf;
               pflib = FileScopeArry.BasedOnPfLib;
               exsr srDataBaseRelations;
               fscopePtr += 160;
 3e          endfor;
 
             // now spin back through and remove PF members
             fscopePtr = Fild0100ptr + Fild0100ds.OffsFileScope;
 3b          for forcount2 = 1 to Fild0100ds.NumOfBasedPf;
               f_runcmd('RMVM FILE(' +
               %trimr(FileScopeArry.BasedOnPfLib) + '/' +
               %trimr(FileScopeArry.BasedOnPf) + ') MBR(' +
               %trimr(scmbr) + ')');
 
               fscopePtr += 160;
 3e          endfor;
 2e        endif;
 1e      endif;
 
       endsr;
 
       //---------------------------------------------------------
       begsr srDataBaseRelations;
 
         callp QDBLDBR(
               UserSpaceName2:
               'DBRL0100':
               PfFile + PfLib:
               scmbr :
               '*ALL':
               ApiErrDS);
 
         // the LF member may not be in the PF, if so try *FIRST member
 1b      if ApiErrDS.BytesReturned > 0;
           callp QDBLDBR(
                 UserSpaceName2:
                 'DBRL0100':
                 PfFile + PfLib:
                 '*FIRST ':
                 '*ALL':
                 ApiErrDS);
 1e      endif;
 1b      if ApiErrDS.BytesReturned = 0;
 
           QdbldbrPtr = ApiHeadPtr2 + ApiHead2.OffSetToList;
 2b        for ForCount1 = 1 to ApiHead2.ListEntryCount;
 
             f_runcmd('RMVM FILE(' +
             %trimr(QdbldbrDS.DependentLib) + '/' +
             %trimr(QdbldbrDS.DependentLF) + ') MBR(' +
             %trimr(scmbr) + ')');
 
             QdbldbrPtr += ApiHead2.ListEntrySize;
 
 2e        endfor;
 1e      endif;
       endsr;
