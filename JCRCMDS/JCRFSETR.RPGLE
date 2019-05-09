       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRFSETR - Scan File Set Where Used
       //  load data base relations for selected file in userspace1.
       //   load selected member names into userspace2.
       //    read source member and scan for all occurrences in userspace1.
       //
       // Search any number of preselected source library and files if
       // choice key is entered in file JCRSMLTCHF.
       //
       // new for v7 is to move all the rpgle fspec retrieval to jcrgetfilr so
       // traditional D specs and new DCL-F file specs are scanned. Slower than original.
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f MBRSRC disk(112) extfile(extifile) usropn  extmbr(openmbr)
       infds(infds);
       dcl-ds SrcDS qualified inz;
        Src112 char(100) pos(13);
       end-ds;
 
       dcl-f JCRFSETF usage(*output) extfile(extofile) extmbr(extombr) usropn;
       dcl-f JCRFSETP printer oflind(IsOverFlow) indds(ind) usropn;
       dcl-f JCRSMLTCHF keyed usropn;
 
       /define ApiErrDS
       /define Constants
       /define f_BlankCommentsCL
       /define Ind
       /define Infds
       /define Qdbldbr
       /define Qdbrtvfd
       /define f_GetDayName
       /define f_BuildString
       /define Quslmbr
       /define BitMask
       /define f_GetQual
       /define f_Quscrtus
       /define f_OvrPrtf
       /define f_DltOvr
       /define f_RunCmd
       /define f_IsCompileTimeArray
       /define p_JCRGETFILR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s BasedOnPfQual char(20);
       dcl-s extOMbr char(10);
       dcl-s OpenMbr char(10);
       dcl-s PhysicalFile char(10);
       dcl-s Displacement int(5) based(displaceptr);
       dcl-s NumOfLists int(5) based(srclistptr);
       dcl-s ForCount3 uns(5);
       dcl-s IsClMbr ind inz(*off);
       dcl-s IsFirstTime ind;
       dcl-s PredefinedKey like(ChoiceKey);
       dcl-s SrcFileQual char(20);
 
       dcl-ds LdaDS DTAARA(*usrctl: *LDA) qualified;
        SrcFiles char(398);
        DataFileQual char(20);
        ActualLib char(10) overlay(DataFileQual:11);
        LfSameLib char(4);
        Output char(8);
        OutFileQual char(20);
        OutMbrOpt char(22);
       end-ds;
 
       // Get source file/lib/mbr names selected
       dcl-ds InnerListDS based(InnerListPtr);
        SrcFil char(10) pos(3);
        SrcLib char(10) pos(13);
        SrcMbr char(10) pos(23);
        SrcMbrTyp char(10) pos(33);
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       // LDA is used for long parms
       //---------------------------------------------------------
 
       in LdaDS;
       //* Use pointers to overlay input parms with DS values
       SrcListPtr = %addr(LdaDS.SrcFiles);
       scDow = f_GetDayName();
 
       // open either print file or outfile depending
 1b    if LdaDS.OutPut = '*';
          LdaDS.OutPut = '*PRINT';
 1e    endif;
 
 1b    if LdaDS.Output = '*PRINT';
          f_OvrPrtf('JCRFSETP': '*JOB': %subst(LdaDS.DataFileQual: 1: 10));
          open JCRFSETP;
 
 1x    elseif LdaDS.Output = '*OUTFILE';
          extOmbr = %subst(LdaDS.OutMbrOpt: 3: 10);
          extOfile = f_GetQual(LdaDS.OutFileQual);
          open JCRFSETF;
 1e    endif;
 
       // Create user spaces/retrieve pointer
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
       ApiHeadPtr2 = f_Quscrtus(UserSpaceName2);
 
       // if selected file is LF, the based-on-PF name is found
       // and processing continues as if PF had been selected.
 
       AllocatedSize = f_GetAllocatedSize(LdaDS.DataFileQual: '*FIRST');
       Fild0100ptr = %alloc(AllocatedSize);
       callp QDBRTVFD(
             Fild0100ds:
             AllocatedSize:
             ReturnFileQual:
             'FILD0100':
             LdaDS.DataFileQual:
             '*FIRST':
             '0':
             '*FILETYPE':
             '*EXT':
             ApiErrDS);
 
       LdaDS.DataFileQual = ReturnFileQual;  //actual file lib
       BasedOnPfQual = ReturnFileQual;  //physical file
 
 1b    if %bitand(bit2: Fild0100ds.TypeBits) = bit2;
          fscopePtr = Fild0100ptr + Fild0100ds.OffsFileScope;
          BasedOnPfQual =
          FileScopeArry.BasedOnPf + FileScopeArry.BasedOnPfLib;
 1e    endif;
 
       PhysicalFile = %subst(BasedOnPfQual: 1: 10);
       scanFile = LdaDS.DataFileQual;
       IsFirstTime = *on;
 
        // make sure file library is in library list else scan will not work
        f_RunCmd(f_BuildString('ADDLIBLE LIB(&)':
        %subst(BasedOnPfQual: 11: 10)));
 
       //---------------------------------------------------------
 1b    if LdaDS.Output = '*PRINT';
          scObjHead =
          f_BuildString('&  &  &': %subst(ReturnFileQual: 1: 10):
          %subst(ReturnFileQual: 11: 10): Fild0100ds.FileText);
 
          write PrtHead;
          IsOverFlow = *off;
 
          // print one line per selected source file
          // Spin down number of offsets to list entries.
          // Inner list pointer (start of list + displacement pointer) moves DS through list
 
          DisplacePtr = SrcListPtr;
 2b       for ForCount3 = 1 to NumOfLists;
             DisplacePtr += 2;
             InnerListPtr = SrcListPtr + Displacement;
 
 3b          if not(%subst(SrcFil:1 :1) = '*');
                hSrcLib = SrcLib;
                hSrcFil = SrcFil;
                hSrcMbr = SrcMbr;
                hSrcMbrTyp = SrcMbrTyp;
                write PrtHead2;
 3x          else;
 4b             if not %open(JCRSMLTCHF);
                   open JCRSMLTCHF;
 4e             endif;
 
                PredefinedKey = %subst(SrcFil: 1: 10);
                setll PreDefinedKey JCRSMLTCHR;
                reade PredefinedKey JCRSMLTCHR;
 4b             dow not %eof;
                   hSrcLib = ChoiceLib;
                   hSrcFil = ChoiceFil;
                   hSrcMbr = ChoiceMbr;
                   hSrcMbrTyp = ChoiceTyp;
                   write PrtHead2;
 5b                if IsOverFlow;
                      write PrtHead;
                      IsOverFlow = *off;
 5e                endif;
                   Ind.HeadingSwitch = *on;
                   reade PredefinedKey JCRSMLTCHR;
 4e             enddo;
 3e          endif;
 
             Ind.HeadingSwitch = *on;
 2e       endfor;
 
          write PrtHead4;
 1e    endif;
 
       DisplacePtr = SrcListPtr;
 
 1b    for ForCount3 = 1 to NumOfLists;
          DisplacePtr += 2;
          InnerListPtr = SrcListPtr + Displacement;
          extIfile = f_GetQual(SrcFil + SrcLib);
 
 2b       if not(%subst(SrcFil:1 :1) = '*');
             exsr srGetMbrList;
 2x       else;
 3b          if not %open(JCRSMLTCHF);
                open JCRSMLTCHF;
 3e          endif;
 
             PredefinedKey = %subst(SrcFil: 1: 10);
             setll PreDefinedKey JCRSMLTCHR;
             reade PredefinedKey JCRSMLTCHR;
 3b          dow not %eof;
                SrcLib = ChoiceLib;
                SrcFil = ChoiceFil;
                SrcMbr = ChoiceMbr;
                SrcMbrTyp = ChoiceTyp;
                extIfile = f_GetQual(SrcFil + SrcLib);
                exsr srGetMbrList;
                reade PredefinedKey JCRSMLTCHR;
 3e          enddo;
 2e       endif;
 1e    endfor;
 
       // close either print file or outfile
 1b    if LdaDS.Output = '*PRINT';
          close JCRFSETP;
          f_DltOvr('JCRFSETP');
 
 1x    elseif LdaDS.Output = '*OUTFILE';
          close JCRFSETF;
 1e    endif;
 
       dealloc(n) Fild0100ptr;
       *inlr = *on;
       return;
 
       //-----------------------------------------------------
       // load user space with mbr name list for selected files
       //-----------------------------------------------------
       begsr srGetMbrList;
       callp QUSLMBR(
             UserSpaceName:
             'MBRL0200':
             SrcFil + SrcLib:
             SrcMbr:
             '0':
             ApiErrDS);
 
 1b    if ApiErrDS.BytesReturned = 0;  //no errors on return
 
          // Process members in user space
          QuslmbrPtr = ApiHeadPtr + ApiHead.OffSetToList;
 
 2b       for ForCount = 1 to ApiHead.ListEntryCount;
             // member type selection
 3b          if SrcMbrTyp = '*ALL'
                or SrcMbrTyp = QuslmbrDS.MbrType;
                OpenMbr = QuslmbrDS.MbrName;
 
 4b             if %subst(QuslmbrDS.MbrType: 1: 2) = 'CL';
                   //---------------------------------------------------------
                   // retrieve data base relation names
 5b                if IsFirstTime;
                      callp QDBLDBR(
                            UserSpaceName2:
                            'DBRL0100':
                            BasedOnPfQual:
                            '*ALL':
                            '*ALL':
                            ApiErrDS);
                      IsFirstTime = *off;
 5e                endif;
 
                   open MBRSRC;
                   exsr srReadClpMbr;
                   close MBRSRC;
 
 4x             elseif %subst(QuslmbrDS.MbrType: 1: 2) = 'RP'
                   or  %subst(QuslmbrDS.MbrType: 1: 2) = 'SQ';
                   exsr srRpgMbr;
 4e             endif;
 3e          endif;
 
             QuslmbrPtr += ApiHead.ListEntrySize;
 2e       endfor;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // program to load F and dcl-f into element per file record format
       //---------------------------------------------------------
       begsr srRpgMbr;
       IsClMbr = *off;
       sRelateF = PhysicalFile;
       SrcFileQual = SrcFil + SrcLib;
 
       callp p_JCRGETFILR(
             QuslmbrDS.MbrName:
             SrcFileQual:
             FileCount:
             OnePerRcdFmt:
             FspecArry:
             CommentArry:
             PrNameArry:
             DeleteArry);
 
       // get count of number of record formats returned
       bb = 0;
       aa = 1;
 
 1b    dou OnePerRcdFmt(aa).File = *blanks;
          aa += 1;
          bb += 1;
 1e    enddo;
 
 1b    for aa = 1 to bb;
 2b       if OnePerRcdFmt(aa).File = PhysicalFile or
             OnePerRcdFmt(aa).BasedOnPF = PhysicalFile;
             sRelateF = OnePerRcdFmt(aa).File;
 
             SrcDS.Src112 = FspecArry(OnePerRcdFmt(aa).FileCount);
             exsr srPrintLine;
 1v          leave;
 2e       endif;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // read through QCLSRC scanning for each DBRL selected. scan for DCLF, if found blank out
       // all comments in that line of source. scan again for DCLF in case it was commented out, if
       // found, proceed with source search.
       //---------------------------------------------------------
       begsr srReadClpMbr;
       IsClMbr = *on;
       read MBRSRC SrcDs;
 1b    dow not %eof;
 
          // If 92 record length, blank out any garbage from 93 to 112
 2b       if InfdsRecLen = 92;
             %subst(SrcDS: 93) = *blanks;
 2e       endif;
 
          SrcDS.Src112 = %xlate(lo: up: SrcDS.Src112);
 2b       if %scan('DCLF':SrcDS.Src112) > 0;
             SrcDS.Src112 = f_BlankCommentsCL(SrcDS.Src112);
             cc = %scan('DCLF':SrcDS.Src112);
 3b          if cc > 0;
 
                //---------------------------------------------------------
                // check and see if PF is used first
                //---------------------------------------------------------
                // if short file name like MON for example, check for
                // check for MON) or MON space.
                // This will not help if file name is MSG
                // but it will clean up a lot of scans.
                //---------------------------------------------------------
 4b             if %scan(%trimr(PhysicalFile) + ' ': SrcDS.Src112) > 0
                   or %scan(%trimr(PhysicalFile) + ')': SrcDS.Src112) > 0;
                   sRelateF = PhysicalFile;
                   exsr srPrintLine;
 LV                leavesr;
 4x             else;
                   // spin through DBRL user space looking for file name matches
                   QdbldbrPtr = ApiHeadPtr2 + ApiHead2.OffSetToList;
 
 5b                if not(QdbldbrDS.DependentLF = '*NONE');
 6b                   for ForCount2= 1 to ApiHead2.ListEntryCount;
 7b                      if %scan(%trimr(QdbldbrDS.DependentLF) + ' ':
                            SrcDS.Src112) > 0
                            or %scan(%trimr(QdbldbrDS.DependentLF) + ')':
                            SrcDS.Src112) > 0;
                            sRelateF = QdbldbrDS.DependentLF;
                            exsr srPrintLine;
 LV                         leavesr;
 7e                      endif;
                         QdbldbrPtr += ApiHead2.ListEntrySize;
 6e                   endfor;
 
 5e                endif;
 4e             endif;
 3e          endif;
 2e       endif;
          read MBRSRC SrcDs;
 1e    enddo;
       endsr;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srPrintLine;
       ListMbr = QuslmbrDS.MbrName;
       MbrType = QuslmbrDS.MbrType;
       SrcTxt = QuslmbrDS.Text;
 
 1b    if LdaDS.Output = '*PRINT';
          SrcDta80 = SrcDS.Src112;
          write PrtDetail;
 1x    else;
          SrcDta = SrcDS.Src112;
          write JCRFSETFR;
 1e    endif;
       endsr;
