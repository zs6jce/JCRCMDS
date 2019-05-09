       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRJOBSIOR - Work with selected jobs - I/O display
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCRJOBSIOD workstn sfile(sbfdta1: rrn) infds(infds) indds(ind);
 
       /define ApiErrDS
       /define Constants
       /define Infds
       /define Sds
       /define FunctionKeys
       /define f_GetFileUtil
       /define f_RunOptionFile
       /define Ind
       /define Qlgsort
       /define f_Qusrobjd
       /define Qdbrtvfd
       /define f_RmvSflMsg
       /define f_GetDayName
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s KeyFld char(10);
       dcl-s Quick char(200) based(opPtr);
       dcl-s LengthOfBuffer int(10);
       dcl-s Count uns(5);
       dcl-s PfNamesArry char(20) dim(400);
       dcl-s FileLib char(20);
       dcl-s dbUtility char(8);
 
       // List Open Files
       dcl-pr qdmlopnf extpgm('QDMLOPNF');
        *n char(8) options(*varsize);  // Receiver
        *n int(10) const;  // Length
        *n char(8) const;  // Api Format
        *n like(jidf0100DS);  // Job ID
        *n char(8) const;  // Job ID Format
        *n like(ApiErrDS);
       end-pr;
 
       // header receiver variable
       dcl-ds opnf0100DS qualified based(opnf0100ptr);
        BytesReturned int(10);
        BytesAvail int(10);
        NumFilesOpen int(10);
        OffsetToList int(10);
        NumFilesRtrned int(10);
        LenOpenEntry int(10);
       end-ds;
 
       // repeating receiver variable
       dcl-ds opRepeatDS based(opPtr) qualified;
        FileName char(10);
        LibName char(10);
        Mbr char(10);
        FileType char(10);
        RcdFmt char(10);
        ActivatGroup char(10);
        ThreadID char(8);
        OpenOption char(1);
        Reserved char(3);
        TotalIO int(20);
        WriteCount int(20);
        ReadCount int(20);
        Write_Read int(20);
        OtherIO int(20);
        RRN int(20);
        SharedOpens int(20);
       end-ds;
 
       // Job identification information
       dcl-ds jidf0100DS inz qualified;
        JobName char(10);
        UserName char(10);
        JobNumber char(6);
        *n char(16) inz; // internal job ID
        *n char(2) inz(*allx'00'); // reserved
        *n int(10) inz(3); // thread indicator
        *n char(8) inz(*allx'00'); // thread id
       end-ds;
 
       dcl-ds GetAllocSizeDS qualified;
        SizeReturned int(10) pos(5);
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        pJobnam char(10);
        pJobUsr char(10);
        pJobNbr char(6);
       end-pi;
       //---------------------------------------------------------
 
       scDow = f_GetDayName();
       sflrcdnbr = 1;
       DbUtility = '2=' + f_GetFileUtil();
       scHeadOpt = '1=Field Descriptions ' +
       %trimr(DbUtility) + ' 3=Record Formats';
       FootF09 = 'F9=' + %trimr(%subst(DbUtility:3)) + ' PFs';
       rrn = 0;
       KeyFld = 'IO';
 
       OPNF0100ptr = %alloc(1);  // so realloc will work
       jidf0100DS.JobName = pJobnam;
       jidf0100DS.UserName = pJobUsr;
       jidf0100DS.JobNumber = pJobNbr;
       exsr srRefreshScreen;
 
       //---------------------------------------------------------
 1b    dou 1 = 2;
          Ind.sfldsp = (rrn > 0);
          Ind.sfldspctl = *on;
          write msgctl;
          write sfooter1;
          exfmt sbfctl1;
          f_RmvSflMsg(ProgId);
 
 2b       if InfdsSflRcdNbr > 0;
             SflRcdNbr = InfdsSflRcdNbr;
 2x       else;
             SflRcdNbr = 1;
 2e       endif;
 
 2b       if (not Ind.sfldsp)
             or InfdsFkey = f03 or InfdsFkey = f12;
             dealloc(n) OPNF0100ptr;
             *inlr = *on;
             return;
 
 2x       elseif InfdsFkey = f05;  //re-sort by whatever sequence is active
             exsr srRefreshScreen;
 
             // sort by io
 2x       elseif InfdsFkey = f07;
             KeyFld = 'IO';
             exsr srRefreshScreen;
 
             // sort by file name
 2x       elseif InfdsFkey = f08;
             KeyFld = 'FILENAME';
             exsr srRefreshScreen;
 
             // view PFs that are open
 2x       elseif InfdsFkey = f09;
             exsr srViewPfData;
             exsr srRefreshScreen;
 2x       else;
             //---------------------------------------------------------
             // as a precaution, limit options to those visible on screen
             //---------------------------------------------------------
             readc sbfdta1;
 3b          dow not %eof;
 4b             if sboption = 1 or sboption = 2 or sboption = 3;
                   f_RunOptionFile(
                   sboption:
                   sbFile:
                   sbLib:
                   '*FIRST':
                   '*FIRST':
                   ProgId);
 4e             endif;
 
                sboption = 0;
                update sbfdta1;
                SflRcdNbr = rrn;
                readc sbfdta1;
 3e          enddo;
 2e       endif;
 1e    enddo;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srRefreshScreen;
       Ind.sfldsp = *off;
       Ind.sfldspctl = *off;
       write sbfctl1;
       rrn = 0;
 
       // get open files list
       callp QDMLOPNF(
             GetAllocSizeDS:
             %len(GetAllocSizeDS):
             'OPNF0100':
             jidf0100DS:
             'JIDF0100':
             ApiErrDS);
 
       OPNF0100ptr = %realloc(OPNF0100ptr: GetAllocSizeDS.SizeReturned);
       callp QDMLOPNF(
             opnf0100DS:
             GetAllocSizeDS.SizeReturned:
             'OPNF0100':
             jidf0100DS:
             'JIDF0100':
             ApiErrDS);
 
       //---------------------------------------------------------
       // Problem is to sort by I/O, but total IO is sum of several fields.
       // Spin though offsets and total the IO into single field for sorting.
       //---------------------------------------------------------
       opPtr = opnf0100ptr + opnf0100DS.OffsetToList;
 1b    for Count = 1 to opnf0100DS.NumFilesRtrned;
          opRepeatDS.TotalIO = (
          opRepeatDS.WriteCount +
          opRepeatDS.ReadCount  +
          opRepeatDS.Write_Read +
          opRepeatDS.OtherIO);
 2b       if opRepeatDS.TotalIO > 999999999;
             opRepeatDS.TotalIO = 999999999;
 2e       endif;
 
 2b       if opRepeatDS.RRN > 999999999;
             opRepeatDS.RRN = 999999999;
 2e       endif;
          opPtr += opnf0100DS.LenOpenEntry;
 1e    endfor;
 
       // Sort ascend by name or descend by IO
       opPtr = opnf0100ptr + opnf0100DS.OffsetToList;
       qlgSortDS = %subst(qlgSortDS: 1: 80);
       qlgsortDS.RecordLength = opnf0100DS.LenOpenEntry;
       qlgsortDS.RecordCount = opnf0100DS.NumFilesRtrned;
       qlgsortDS.NumOfKeys = 1;
 
 1b    if KeyFld = 'FILENAME';
          qlgsortDS = %trimr(qlgsortDS) + f_AddSortKey(1: 10);
 1x    elseif KeyFld = 'IO';
          qlgsortDS = %trimr(qlgsortDS) + f_AddSortKey(73: 8: 0: 2);
 1e    endif;
       qlgsortDS.BlockLength = %len(%trimr(qlgsortDS));
       LengthOfBuffer = opnf0100DS.NumFilesRtrned * opnf0100DS.LenOpenEntry;
 
       callp QLGSORT(
             qlgsortDS:
             Quick:
             Quick:
             LengthOfBuffer:
             LengthOfBuffer:
             ApiErrDS);
 
 1b    for cc = 1 to opnf0100DS.NumFilesRtrned;
          sbFile = opRepeatDS.FileName;
          sbLib = opRepeatDS.LibName;
 
          // get object description
          QusrObjDS = f_QUSROBJD(sbFile + sbLib: '*FILE');
 2b       if ApiErrDS.BytesReturned = 0 or sbLib = 'QTEMP ';
             sbMbrDev = opRepeatDS.Mbr;
             sbRcdFmt = opRepeatDS.RcdFmt;
 
             sbOpenOpt = *blanks;
 3b          if opRepeatDS.OpenOption = '0';
                sbOpenOpt = 'I';
 3x          elseif opRepeatDS.OpenOption = '1';
                sbOpenOpt = 'O';
 3x          elseif opRepeatDS.OpenOption = '2';
                sbOpenOpt = 'IO';
 3e          endif;
 
             if  sbLib = 'QTEMP ';
             sbText = *blanks;
             else;
             sbText = QusrObjDS.Text;
             endif;
 
             sbTotalIO = opRepeatDS.TotalIO;
             sbRrn = opRepeatDS.RRN;
             sbFileType = %xlate(UP:LO:opRepeatDS.FileType);
 2x       else;
             sbMbrDev = *blanks;
             sbRcdFmt = *blanks;
             sbOpenOpt = *blanks;
             sbText = 'Not authorized';
             sbTotalIO = 0;
             sbRrn = 0;
             sbFileType = *blanks;
 2e       endif;
 
          rrn = cc;
          write sbfdta1;
          opPtr += opnf0100DS.LenOpenEntry;
 1e    endfor;
 
 1b    if rrn < SflRcdNbr;
          SflRcdNbr = rrn;
 1e    endif;
 
 1b    if SflRcdNbr <= 0;
          SflRcdNbr = 1;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // load array with distinct PF names
       //---------------------------------------------------------
       begsr srViewPfData;
       bb = 0;
 1b    for cc = 1 to opnf0100DS.NumFilesRtrned;
          chain cc sbfdta1;
 2b       if sbFileType = 'pf' or sbFileType = 'lf';
             FileLib = sbFile + sbLib;
 
             // if file type is LF, then go find first PF
 3b          if sbFileType = 'lf';
                AllocatedSize = f_GetAllocatedSize(FileLib:'*FIRST');
                Fild0100ptr = %alloc(AllocatedSize);
 
                callp QDBRTVFD(
                      Fild0100ds:
                      AllocatedSize:
                      ReturnFileQual:
                      'FILD0100':
                      FileLib:
                      '*FIRST':
                      '0':
                      '*FILETYPE':
                      '*EXT':
                      ApiErrDS);
 
                fscopePtr = Fild0100ptr + Fild0100ds.OffsFileScope;
                FileLib = FileScopeArry.BasedOnPf + FileScopeArry.BasedOnPfLib;
 3e          endif;
 
 3b          if bb = 0
                or %lookup(FileLib: PfNamesArry: 1: bb) = 0;
                bb += 1;
                PfNamesArry(bb) = FileLib;
 3e          endif;
 2e       endif;
 1e    endfor;
 
 1b    for aa = 1 to bb;
          f_RunOptionFile(2:
          %subst(PfNamesArry(aa): 1: 10):
          %subst(PfNamesArry(aa): 11: 10):
          '*FIRST':
          '*FIRST':
          ProgId);
 1e    endfor;
       endsr;
