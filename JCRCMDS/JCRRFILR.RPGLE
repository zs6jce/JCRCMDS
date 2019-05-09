       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRRFILR - File Record Format xref for RPG source (F spec or dcl-f)
       //  call common file get program JCRGETFILR to extract file names from source
       //   add f9 toggle to show distinct PFs only
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCRRFILD workstn sfile(sbfdta1:rrn) infds(infds) indds(ind);
 
       /define Infds
       /define FunctionKeys
       /define Ind
       /define Sds
       /define f_BuildString
       /define f_RunOptionFile
       /define f_GetFileUtil
       /define f_GetQual
       /define f_GetDayName
       /define f_Qusrmbrd
       /define f_RmvSflMsg
       /define f_SndCompMsg
       /define f_SndSflMsg
       /define Constants
       /define p_JCRGETFILR
       // *ENTRY
       /define p_JCRRFILR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s runfile char(10);
       dcl-s IsToggle07 ind inz(*off);
       dcl-s IsToggle09 ind inz(*off);
       dcl-s IsOk ind inz(*off);
       dcl-s dbUtility char(8);
       dcl-s uniquePf char(10) dim(256);
       dcl-s uu uns(5);
 
       //---------------------------------------------------------
       scDow = f_GetDayName();
       FootMsg07 = 'F7=Sort By Rcdmt';
       FootMsg09 = 'F9=Show Unique PFs Only';
 
       QusrmbrdDS = f_Qusrmbrd(p_SrcFilQual: p_SrcMbr: 'MBRD0100');
       %subst(p_SrcFilQual: 11: 10) = QusrmbrdDS.Lib;
 
       scObjHead =
       f_BuildString('&  &  &  &':
       QusrmbrdDS.Mbr: QusrmbrdDS.File: QusrmbrdDS.Lib: QusrmbrdDS.Text);
 
       // program to load F and dcl-f into element per file record format
       callp p_JCRGETFILR(
             p_SrcMbr:
             p_SrcFilQual:
             FileCount:
             OnePerRcdFmt:
             FspecArry:
             CommentArry:
             PrNameArry:
             DeleteArry);
 
       // prep indexes to unload arrays returned from jcrgetfilr
       bb = 0;
       aa = 1;
 1b    dou OnePerRcdFmt(aa).File = *blanks;
          aa += 1;
          bb += 1;
 1e    enddo;
 
       //---------------------------------------------------------
       f_RmvSflMsg(ProgId);
       exsr srSort;
       DbUtility = '2=' + f_GetFileUtil();
       scHeadOpt = '1=Field Descriptions   ' +
       %trimr(DbUtility) + '   3=Record Formats    7=Wrkobj *all';
 
       //---------------------------------------------------------
       //---------------------------------------------------------
 1b    dou 1 = 2;
          write msgctl;
          write sfooter1;
          exfmt sbfctl1;
          f_RmvSflMsg(ProgId);
 
 2b       if (not Ind.sfldsp)
             or InfdsFkey = f03 or InfdsFkey = f12;
             f_SndCompMsg(f_BuildString('JCRRFIL for & in & - completed.':
             p_SrcMbr:
             f_GetQual(p_SrcFilQual)));
             *inlr = *on;
             return;
 
 2x       elseif InfdsFkey = f07;
             IsToggle07 = (not IsToggle07);
 3b          if IsToggle07;
                FootMsg07 = 'F7=Sort By File';
 3x          else;
                FootMsg07 = 'F7=Sort By Rcdmt';
 3e          endif;
             exsr srSort;
 
 2x       elseif InfdsFkey = f09;
             IsToggle09 = (not IsToggle09);
 3b          if IsToggle09;
                FootMsg09 = 'F9=Show All';
                uniquePf(*) = *blanks;
                uu = 0;
 3x          else;
                FootMsg09 = 'F9=Show Unique PFs Only';
 3e          endif;
             exsr srSort;
 
             //---------------------------------------------------------
             // Process selected record in subfile.
             // as a precaution; only process on screen selection options
             //---------------------------------------------------------
 2x       else;
             readc sbfdta1;
 3b          dow not %eof;
 4b             if sbfOption = 1
                   or sbfOption = 2
                   or sbfOption = 3
                   or sbfOption = 7;
 
 5b                if HidFileExt > *blanks;
                      runfile = hidFileExt;
 5x                else;
                      runfile = ScrFileNam;
 5e                endif;
 
                   f_RunOptionFile(
                   sbfOption:
                   runfile:
                   HidLibNam:
                   HidRcdFmt:
                   '*FIRST':
                   ProgId);
 
 4x             else;
                   f_SndSflMsg(ProgId:
                   'Option ' + %char(sbfOption) + ' is not available');
 4e             endif;
 
                sbfOption = 0;
                update sbfdta1;
                SflRcdNbr = rrn;
                readc sbfdta1;
 3e          enddo;
 2e       endif;
 1e    enddo;
 
       //---------------------------------------------------------
       // load subfile fields from sorted array
       //---------------------------------------------------------
       begsr srSort;
       SflRcdNbr = 1;
       rrn = 0;
       Ind.sfldsp = *off;
       Ind.sfldspctl = *off;
       write sbfctl1;
 
 1b    if bb > 1;
 2b       if FootMsg07 = 'F7=Sort By Rcdmt';
             sorta %subarr(OnePerRcdFmt(*).File: 1: bb);
 2x       else;
             sorta %subarr(OnePerRcdFmt(*).Format: 1: bb);
 2e       endif;
 1e    endif;
 
 1b    for aa = 1 to bb;
 2b       if OnePerRcdFmt(aa).File > *blanks;
 
             ScrFileNam = OnePerRcdFmt(aa).File;
             HidLibNam = OnePerRcdFmt(aa).Lib;
             HidFileExt = OnePerRcdFmt(aa).FileExt;
 
             ScrLib = OnePerRcdFmt(aa).Lib;
             ScrRcdFmt = OnePerRcdFmt(aa).Format;
 
 3b          if OnePerRcdFmt(aa).FormatReName = *blanks;
                ScrRenamed = '.';
 3x          else;
                ScrRenamed = OnePerRcdFmt(aa).FormatReName;
 3e          endif;
 
 3b          if OnePerRcdFmt(aa).BasedOnPF = *blanks;
                ScrBasedPF = '.';
 3x          else;
                ScrBasedPF = OnePerRcdFmt(aa).BasedOnPF;
 3e          endif;
             ScrUsage = OnePerRcdFmt(aa).Usage;
             ScrAAdd  = OnePerRcdFmt(aa).FileAddition;
             ScrRecText = OnePerRcdFmt(aa).Text;
 
             // note:  footmsg09 is a toggle switch that is opposite
             //  of current action being taken
             //-----------------------------------------------------
 3b          if FootMsg09 = 'F9=Show Unique PFs Only';
                IsOk = *on;
 3x          else;
                IsOk = *off;
 4b             if ScrBasedPF <> '.';
                   ScrFileNam = ScrBasedPF;
 4e             endif;
 
 4b             if uu = 0 or %lookup(ScrFileNam: uniquePf: 1: uu) =0;
                   uu += 1;
                   uniquePf(uu) = ScrFileNam;
                   isOk = *on;
 4e             endif;
 3e          endif;
 
 3b          if IsOk;
                rrn += 1;
                write sbfdta1;
 3e          endif;
 2e       endif;
 1e    endfor;
 
       Ind.sfldspctl = *on;
       Ind.sfldsp = (rrn > 0);
 1b    if (not Ind.sfldsp);
          f_SndSflMsg(ProgId: 'Program uses no external data files.');
 1e    endif;
       endsr;
