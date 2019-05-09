       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRIFSCPYR - Copy from IFS directory
       // Use 'Unix-API's to retrieve IFS directory entries.
       //     Opendir() function opens directory so that it can be
       //     read with readdir() function.
       //     Functions readdir(), rewinddir(), and closedir() can be called after
       //     successful call to opendir().  First readdir() call reads first directory entry
       //
       //  Read Directory readDir() returns pointer to dirent
       //  structure describing next directory entry in directory stream.
       //  Close Directory closeDir() closes directory stream indicated by pdir handle
 
       // Load entries into subfile.
       // Process user selections.
       //    1. Copy to selected member
       //    2. Run XMLPREVIEW and install.
       //
       // This utility was originally intended to make it easy to upload source
       // members, but it can be used to upload to data files.  In that
       // case, check max number of members allowed. If only 1,
       // then overlay member name in upload prompt with data files member.
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCRIFSCPYD workstn sfile(sbfdta1: rrn) infds(infds) indds(ind);
 
       /define ApiErrDS
       /define Constants
       /define Infds
       /define FunctionKeys
       /define Ind
       /define Sds
       /define f_Runcmd
       /define f_IsValidObj
       /define OpenCloseDir
       /define f_RmvSflMsg
       /define f_BuildString
       /define f_SndCompMsg
       /define f_SndSflMsg
       /define f_SndStatMsg
       /define f_GetDayName
       /define Qdbrtvfd
       /define f_Qusrmbrd
       // *ENTRY
       /define p_JCRIFSCPYR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s errFlag int(10);
       dcl-s dirName char(50);
       dcl-s EntryName char(1024);
       dcl-s stringv varchar(500);
       dcl-s IsSecondTime ind;
       dcl-s TempName char(16) based(pTempName);
 
       // structure must be aligned since C struct does NOT have _Packed
       dcl-ds d_dirEnt based(pDirEnt) align;  // <h/dirent.h>
        d_Reserved1 char(16);
        d_Fileno_id uns(10);
        d_Fileno uns(10);
        d_Reclen uns(10);
        d_Reserved2 int(10);
        d_Reserved3 char(8);
        d_nlsinfo like(qlg_nls_t);
        d_namelen uns(10);
        d_name char(640);
        nlink_t uns(5);
       end-ds;
 
       dcl-ds qlg_nls_t inz align;  // <sys/types.h>
        ccsid int(10);
        Country_id char(2);
        language_id char(3);
        nls_Reserved char(3);
       end-ds;
 
       dcl-ds st_stat inz align;  // <sys/stat.h>
        st_mode uns(10);
        st_ino uns(10);
        st_nlink uns(5);
        st_uid uns(10);
        st_gid uns(10);
        st_size uns(10);
        st_atime uns(10);
        st_mtime uns(10);
        st_ctime uns(10);
        st_dev uns(10);
        st_blksize uns(10);
        st_allocsize uns(10);
        st_ObjType char(11);
        st_codepage uns(5);
        st_Reservedl char(62);
        st_ino_gen_id uns(10);
       end-ds;
 
       //---------------------------------------------------------
       scDow = f_GetDayName();
       SflRcdNbr = 1;
 1b    if %subst(p_IfsDir: 1: 1) <> '/';
          p_IfsDir = '/' + p_IfsDir;
 1e    endif;
 
       wctoLib = *blanks;
       wctoFile = *blanks;
       wctoFile2 = '*DEFAULTS';
       wctoMbr = *blanks;
       wcMbrTyp = *blanks;
       PathHead = p_IfsDir;
 
       f_SndStatMsg('List files in path ' +
       %trimr(p_IfsDir) + ' - in progress.');
       pDir = openDir(%trim(p_IfsDir));
 
 1b    if pDir = *null;
          f_SndSflMsg(ProgId:
          'Error Found on OPEN DIRECTORY. Check path name.');
 1x    else;
          f_SndSflMsg(ProgId:
          'Select option and press Enter key');
          pDirEnt = readDir(pDir);
 2b       dow pDirEnt <> *null;
             dirName = %subst(d_name: 1: d_nameLen);
 
 3b          if %subst(dirname: 1: 1) <> '.';
                // ... get file information stat()
                EntryName = %trim(p_IfsDir) + '/' + dirName;
                errFlag = stat(%trim(EntryName): %addr(st_stat));
                ObjType = %str(%addr(st_ObjType));
 
                // extract file extension to allow future
                // sorting by extension types
                hidExten = *blanks;
                hidFileNam = *blanks;
                aa = %scan('.': dirName);
 4b             if aa > 1;
                   hidExten = %subst(dirName: aa + 1);
                   hidFileNam = %subst(dirName: 1: aa - 1);
 4x             else;
                   hidFileNam = dirName;
 4e             endif;
                rrn += 1;
                write sbfdta1;
 3e          endif;
             pDirEnt = readDir(pDir);
 2e       enddo;
 
 2b       if rrn = 0;
             f_SndSflMsg(ProgId: 'No entries found in directory');
 2e       endif;
          errFlag = closeDir(pDir);
 1e    endif;
 
       // allow user to make selection from subfile
       Ind.sfldsp = (rrn > 0);
       Ind.sfldspctl = *on;
 
 1b    dou 1 = 2;
          write sbfctl1;
          write msgctl;
          exfmt sfooter1;
 
 2b       if (not Ind.sfldsp)
             or InfdsFkey = f03 or InfdsFkey = f12;
             f_SndCompMsg('JCRIFSCPY for path '+
             %trimr(p_IfsDir)+' - completed.');
             *inlr = *on;
             return;
 2e       endif;
 
          f_RmvSflMsg(ProgId);
          //---------------------------------------
          readc sbfdta1;
 2b       dow not %eof;
 3b          if sbfOption > 0;
 4b             if sbfOption = 1 or sbfOption = 2;
                   exsr srExecuteOpts;
 4x             else;
                   f_SndSflMsg(ProgId:
                   'Option ' + %char(sbfOption) + ' is not defined.');
 4e             endif;
                sbfOption = 0;
                update sbfdta1;
 3e          endif;
             SflRcdNbr = rrn;
             readc sbfdta1;
 2e       enddo;
 1e    enddo;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srExecuteOpts;
       IsSecondTime = *off;
       f_RmvSflMsg(ProgId);
       wcdirname = %trimr(p_IfsDir) + '/' + dirname;
 
 1b    if sbfOption = 1;  //cpytostmf
          wctoMbr = %xlate(lo: up: hidFileNam);
          wcMbrTyp = %xlate(lo: up: hidExten);
 
 2b       dou 1 = 2;
 3b          if IsSecondTime;
                write msgctlw1;
 3e          endif;
             IsSecondTime = *on;
 
             exfmt window1;
             f_RmvSflMsg(ProgId);
 3b          if not(InfdsFkey = f03 or InfdsFkey = f12);
 
 4b             if wctoLib = *blanks
                   or not f_IsValidObj(wctoLib: 'QSYS': '*LIB');
                   f_SndSflMsg(ProgId:
                   'To Library ' + %trimr(wctoLib) + ' Not Valid.');
 2i                iter;
 
 4x             elseif wctoFile = *blanks
                   or not f_IsValidObj(wctoFile:wctoLib: '*FILE');
                   f_SndSflMsg(ProgId:
                   'To File ' + %trimr(wctoFile) +
                   ' Not Valid.');
 2i                iter;
 
 4x             elseif wctoMbr = *blanks;
                   f_SndSflMsg(ProgId:
                   'To Member must be entered.');
 2i                iter;
 4x             else;
                   //---------------------------------------------------------
                   // If uploading to data files, check max
                   // number of members allowed. If only 1 member is allowed,
                   // then overlay member name in upload prompt with data files member.
                   //---------------------------------------------------------
                   AllocatedSize =
                   f_GetAllocatedSize(wctoFile + wctoLib: '*FIRST');
                   Fild0100ptr = %alloc(AllocatedSize);
                   callp QDBRTVFD(
                         Fild0100ds:
                         AllocatedSize:
                         ReturnFileQual:
                         'FILD0100':
                         wctoFile + wctoLib:
                         '*FIRST':
                         '0':
                         '*FILETYPE':
                         '*EXT':
                         ApiErrDS);
 
 5b                if Fild0100ds.MaxMbrs = 1;
                      QusrmbrdDS =
                      f_Qusrmbrd(wctoFile + wctoLib: '*FIRST': 'MBRD0100');
                      wctoMbr = QusrmbrdDS.Mbr;
 5e                endif;
                   dealloc(n) Fild0100ptr;
 4e             endif;
 
                stringv = ('?CPYFRMSTMF FROMSTMF(' + qs +
                %trimr(%xlate(up: lo: wcdirname)) + qs +
                ') toMbr(' + qs +
                '/qsys.Lib/' + %trimr(wctoLib) +
                '.Lib/' + %trimr(wctoFile) +
                '.file/' + %trimr(wctoMbr) +
                '.mbr' + qs + ') ');
                f_Runcmd(stringv);
 
                stringv = ('CHGPFM FILE(' + %trimr(wctoLib) + '/' +
                %trimr(wctoFile) + ') ' +
                'MBR(' + %trimr(wctoMbr) + ') SRCTYPE(' +
                %trimr(wcMbrTyp) + ') TEXT(' +
                qs + 'member created by jcr JCRIFSCPY' + qs + ')');
                f_Runcmd(stringv);
 
                // load message to screen
                sbfAction = '*COPIED';
                f_SndSflMsg(ProgId:
                f_BuildString('File & copied to & in library &.':
                dirname: wctoFile: wctoLib));
 3x          else;
                sbfAction = *blanks;
                f_SndSflMsg(ProgId: 'Copy Canceled.');
 3e          endif;
 2v          leave;
 2e       enddo;
 
 1x    elseif sbfOption = 2;  //xmlpreview
          //---------------------------------------------------------
          // tmpnam() get temporary name
          // produces valid file name that is not the same as name of any existing file.
          // It stores this name in  pTempName. If pTempName is NULL, tmpnam leaves result in
          // an internal static buffer.
          //
          // Tmpnam function produces different name each time it is called within activation group
          // In AS/400 Data Management, tmpnam function creates new file named QTEMP/QACXxxxx
          //---------------------------------------------------------
          pTempName = tmpnam(*null);
 2b       if pTempName <> *null;
 3b          dou 1 = 2;
 
 4b             if IsSecondTime;
                   write msgctlw2;
 4e             endif;
                IsSecondTime = *on;
 
                exfmt window2;
                f_RmvSflMsg(ProgId);
 4b             if not(InfdsFkey = f03 or InfdsFkey = f12);
 
 5b                if wctoLib = *blanks
                      or not f_IsValidObj(wctoLib: 'QSYS': '*LIB');
                      f_SndSflMsg(ProgId:
                      'To Library ' + %trimr(wctoLib) +
                      ' Not Valid.');
 3i                   iter;
 5e                endif;
 
                   stringv = 'CRTSRCPF FILE(' +
                   %trimr(wctoLib) + '/' +
                   %subst(TempName: 7) +
                   ') RCDLEN(112) MBR(' +
                   %subst(TempName: 7) +
                   ') TEXT(' + qs + 'TEMP JCRIFSCPY' + qs + ')';
                   f_Runcmd(stringv);
 
                   stringv = 'CPYFRMSTMF FROMSTMF(' + qs +
                   %trimr(%xlate(up: lo: wcdirname)) + qs +
                   ') toMbr(' + qs +
                   '/qsys.Lib/' + %trimr(wctoLib) +
                   '.Lib/' + %subst(TempName: 7) +
                   '.file/' + %subst(TempName: 7) +
                   '.mbr' + qs + ') MBROPT(*REPLACE) CVTDTA(*AUTO)';
                   f_Runcmd(stringv);
 
                   stringv = 'XMLPREVIEW UPLOADMBR(' +
                   %subst(TempName: 7) + ') UPLOADSRCF(' +
                   %trimr(wctoLib) + '/' +
                   %subst(TempName: 7) + ') OUTPUTSRCF(' +
                   %trimr(wctoFile2) + ')';
                   f_Runcmd(stringv);
 
                   stringv = 'DLTF FILE(' +
                   %trimr(wctoLib) + '/' +
                   %subst(TempName: 7) + ')';
                   f_Runcmd(stringv);
                   // load message to screen
                   sbfAction = '*INSTALLED';
 
                   f_SndSflMsg(ProgId:
                   f_BuildString('File & copy/installed to & in library &.':
                   dirname: wctoFile: wctoLib));
 4x             else;
                   sbfAction = *blanks;
                   f_SndSflMsg(ProgId: 'Install Canceled.');
 4e             endif;
 3v             leave;
 3e          enddo;
 2e       endif;
 1e    endif;
       endsr;
