       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRGETFILR - Record format/file xref for RPG source  (Fspec or dcl-f)
       //  this program does the dirty work of extracting information from
       //  F or dcl-f specs.
       //    Called from jcrrfilr (show files in source)
       //                jcrhfdr  (convert f specs to free).
       //                jcranzov (verify printer declaration in source)
       //                jcrfsetr  (file set where used)
       //  Return string array with one element per file, with
       //  associated F spec keywords in that single string
 
       //  Note: I cannot comprehend why ibm decided to require a
       //  usage(*delete) keyword if the file or any record format in that
       //  file has a delete opcode in the main or any F definitions
       //  inside any dcl-proc.  This massively complicates the F specs
       //  as now the entire source must be read looking for delete
       //  opcodes by file or included record formats and keep track
       //  is the delete in the main or in a procedure (and track the procedure name)
       //---------------------------------------------------------
       /define ControlStatements
       /define f_GetQual
       /define Constants
       /define f_EllipsisLoc
       /define f_IsIgnoreLine
       /define f_IsCompileTimeArray
       /define f_ReturnZeroIfBetweenQuotes
       /define f_ReturnZeroIfAfterComments
       /define ApiErrDS
       /define Qdbrtvfd
       /define BitMask
       /define f_Quscrtus
       /define f_Qusrobjd
       /define FspecDS
       /define p_JCRGETFILR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f RPGSRC disk(112) extfile(extIfile) extmbr(p_SrcMbr) usropn;
 
       dcl-s LowRec like(InputDS.Src74);
       dcl-s Semi uns(3);
       dcl-s SlashSlash uns(3);
       dcl-s IsDclf ind inz(*off);
       dcl-s ContinuationString varchar(1024);
       dcl-s SemiColonIsFound ind;
       dcl-s UpSpec char(1);
       dcl-s string varchar(94);
       dcl-s Dots uns(3);
       dcl-s dxname char(74);
       dcl-s xx uns(3);
       dcl-s DeleteCnt uns(5);
       dcl-s char74 char(74);
       dcl-s canidate char(10);
       dcl-s FormatIncludeOrIgnore char(10) dim(32);
       dcl-s CountIncExc uns(3);
       dcl-s CountRename uns(3);
       dcl-s FileNameSave char(10);
       dcl-s FileHowUsed char(1);
       dcl-s FileAddition char(1);
       dcl-s RenamedFmt char(10) dim(32);
       dcl-s BeingRenamed char(10) dim(32);
       dcl-s WorkFileQual char(20);
       dcl-s NextRename uns(5);
       dcl-s ff uns(5);
       dcl-s EndParenthesis uns(5);
       dcl-s CurrentColon uns(5);
       dcl-s OnePerCnt uns(5);
       dcl-s IsFile ind;
       dcl-s IsProcess ind;
       dcl-s IsIgnore ind;
       dcl-s IsInclude ind;
       dcl-s IsCloseParenth ind;
       dcl-s IsLF ind;
       dcl-s FileExt char(10);
       dcl-s LibExt char(10);
       dcl-s RenameSave char(10);
       dcl-s QuoteStart uns(3);
       dcl-s QuoteEnd uns(3);
       dcl-s fstring varchar(512);
       dcl-s ThisFileName char(10);
       dcl-s ThisFileProc char(74);
       dcl-s IsFoundInThisProc ind;
       dcl-s ccu like(cc);
 
       dcl-ds DeleteStatements dim(1000) qualified;
        PrName char(74);
        FileOrRcdFmt char(14);
       end-ds;
 
       // capture fspec comments for dcl-f conversion program
       dcl-ds InputDS len(112) qualified;
        CompileArry char(3) pos(13);
        SpecType char(1) pos(18);
        FileName char(10) pos(19);
        Asterisk char(1) pos(19);
        Src74 char(74) pos(19);
        OpCode char(6) pos(38);
        Factor2 char(14) pos(48);
        fKeyWord char(37) pos(56);
        Comment char(20) pos(93);
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_SrcMbr char(10);
        p_SrcFilQual char(20);
        p_FileCount uns(5);
        p_OnePerRcdFmt like(OnePerRcdFmt) dim(256); // JCRRFILR
        p_FspecArry    like(FspecArry)    dim(256); // JCRHFDR & JCRANZOV
        p_CommentArry  like(CommentArry)  dim(256);    // JCRHFDR   1 to 1 with FspecArry
        p_PrNameArry   like(PrNameArry)   dim(256);    // JCRHFDR   1 to 1 with FspecArry
        p_DeleteArry   like(DeleteArry)   dim(256);    // JCRHFDR   1 to 1 with FspecArry
       end-pi;
       //---------------------------------------------------------
 
       p_FileCount = 0;
       clear p_OnePerRcdFmt;
       p_FspecArry(*) = *blanks;
       p_CommentArry(*) = *blanks;
       p_PrNameArry(*) = *blanks;
       p_DeleteArry(*) = *blanks;
       DeleteStatements(*) = *blanks;
       clear OnePerRcdFmt;
       Fild0100ptr = %alloc(1);  // so realloc will work
 
       extIfile = f_GetQual(p_SrcFilQual);
       open RPGSRC;
       read RPGSRC InputDS;
 1b    dow not %eof;
 
 2b       if f_IsCompileTimeArray(InputDS.CompileArry);
 1v          leave;
 2e       endif;
 
          string = %trimr(InputDS.Src74);
 2b       if not f_IsIgnoreLine(string);
             exsr srProcessSource;
 2e       endif;
 
          read RPGSRC InputDS;
 1e    enddo;
 
       close RPGSRC;
       exsr srLoadOnePerRcdfmt;
       dealloc(n) Fild0100ptr;
 
       exsr srMarryUpDeletes;
       p_OnePerRcdFmt(*) = OnePerRcdFmt(*);
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       // OnePerRcdFmt - has file/rcdfmt/renamed rcdfmts and procedure name
       //  p_FspecArry - has file name and element # is control
       //  p_PrNameArry - 1 to 1 with FspecArry - this element# is in this proc.
       //  p_DeleteArry - 1 to 1 with FspecArry - record 'Y' if delete is found
 
       //  DeleteStatements dim(1000) qualified; -
       //   PrName char(74);
       //   FileOrRcdFmt char(14);
       //
       // Spin through and figure what gets deleted where.
       //
       // watch out for a procedure deleting a file or record format that could be
       // defined in main or defined in a procedure.
       //---------------------------------------------------------
       begsr srMarryUpDeletes;
 1b    for ff = 1 to p_FileCount;
          FspecDS = %xlate(lo: up: p_FspecArry(ff));
 
          // no free format for primary, secondary, table.
 2b       if  FspecDS.FileType = 'U'
             and
             (FspecDS.Designation = ' '
             or FspecDS.Designation = 'F')
             and (
             FspecDS.RecordAddressType = ' '
             or  FspecDS.RecordAddressType = 'A'
             or  FspecDS.RecordAddressType = 'K');
 
             ThisFileName = FspecDS.name;
             ThisFileProc = p_PrNameArry(ff);
 
             exsr srSpinCycle;
 
 2e       endif;
 1e    endfor;
 
       //---------------------------------------------------------
       // now to check if any procedures have a delete statement
       // and that file or record format is not defined in that procedure.
       // need to update the p_DeleteArry for the main defined files.
       // The usage delete keyword is a pain.
       //---------------------------------------------------------
       // spin through all procedure delete statements
 1b    for bb = 1 to DeleteCnt;
 2b       if DeleteStatements(bb).PrName > *blanks;
             ThisFileProc = DeleteStatements(bb).PrName;
             IsFoundInThisProc = *off;
 
 3b          for aa = 1 to OnePerCnt;
 4b             if OnePerRcdFmt(aa).ProcName = ThisFileProc;
 
 5b                if f_IsFoundInThisProc();
                      IsFoundInThisProc = *on;
 3v                   leave;
 5e                endif;
 
 4e             endif;
 3e          endfor;
 
             //----------------------------------------------------
             // now go find the main procedure file definition
             //----------------------------------------------------
 3b          if not IsFoundInThisProc;
 4b             for aa = 1 to OnePerCnt;
 5b                if OnePerRcdFmt(aa).ProcName = *blanks;
 
 6b                   if f_IsFoundInThisProc();
 7b                      for ff = 1 to p_FileCount;
 8b                         if p_PrNameArry(ff) = *blanks;
                               FspecDS = %xlate(lo: up: p_FspecArry(ff));
 9b                            if FspecDS.name = OnePerRcdFmt(aa).file;
                                  p_DeleteArry(ff) = 'Y';
 7v                               leave;
 9e                            endif;
 8e                         endif;
 7e                      endfor;
 6e                   endif;
 5e                endif;
 4e             endfor;
 3e          endif;
 2e       endif;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       // spin through the record formats for this procedure file
       //---------------------------------------------------------
       begsr srSpinCycle;
 1b    for aa = 1 to OnePerCnt;
 2b       if OnePerRcdFmt(aa).File = ThisFileName
             and OnePerRcdFmt(aa).ProcName = ThisFileProc;
 
             // spin through the delete statements in this proc
 3b          for bb = 1 to DeleteCnt;
 4b             if DeleteStatements(bb).PrName = ThisFileProc;
 
 5b                if f_IsFoundInThisProc();
                      p_DeleteArry(ff) = 'Y';
 LV                   leavesr;
 5e                endif;
 
 4e             endif;
 3e          endfor;
 2e       endif;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srLoadOnePerRcdfmt;
 1b    for ff = 1 to p_FileCount;
          fstring = %trimr(p_FspecArry(ff));
          fstring = %xlate(lo: up: fstring);
 
          //---------------------------------------------------------
          // load fields from f spec externally described fields.
          //---------------------------------------------------------
          FileExt = *blanks;
          LibExt = '*LIBL';
          CountRename = 0;
          FormatIncludeOrIgnore(*) = *blanks;
          CountIncExc = 0;
          IsIgnore = *off;
          IsInclude = *off;
          RenamedFmt(*) = *blanks;
          BeingRenamed(*) = *blanks;
 
          //---------------------------------------------------------
          IsFile = *off;
 2b       if %subst(fstring:1:1) > *blanks;  // fixed column
 
 3b          if %subst(fstring:16:1) = 'E'
                and %subst(fstring:30:4) = 'DISK';
 
                FileNameSave = %subst(fstring:1:10);
                FileHowUsed = %subst(fstring:11:1);
                FileAddition = %subst(fstring:14:1);
                IsFile = *on;
 3e          endif;
 2x       else;
 
             //---------------------------------------------------------------------
             // extract file name from dcl-f string
             // make sure DCL-F is first thing in the string;
             //---------------------------------------------------------------------
             cc = %scan('DCL-F': fstring);
 3b          if cc> 0 and cc = %check(' ': fstring);
                FileNameSave = *blanks;
                FileHowUsed = 'I';  // default
                FileAddition  = *blanks;
 
                // first non-blank is start of file name
                cc = %check(' ': fstring: cc + 5);
 4b             for bb = cc to %len(fstring);
 5b                if %subst(fstring:bb:1) = ' ' or %subst(fstring:bb:1) = ';';
                      FileNameSave = %subst(fstring: cc: bb-cc);
 4v                   leave;
 5e                endif;
 4e             endfor;
 
 4b             if %subst(fstring:bb:1) = ';';
                   IsFile = *on;
 4x             else;
 
                   // check for printer or workstn and skip these
 5b                if %scan('WORKSTN': fstring: bb) = 0
                      and %scan('PRINTER': fstring: bb) = 0;
                      IsFile = *on;
 5e                endif;
 4e             endif;
 
                // get first usage
 4b             if IsFile;
                   cc = %scan('USAGE(': fstring);
 5b                if cc > 0;
                      cc = %scan('*':fstring: cc + 6);
 6b                   if cc>0;
                         FileHowUsed = %subst(fstring:cc+1:1);
 
                         ccu = cc; // save for update scan
                         FileAddition = *blanks;
                         cc = %scan('*OUTPUT':fstring: cc + 6);
 7b                      if cc>0;
                            FileAddition = 'A';
 7e                      endif;
 
                         cc = %scan('*UPDATE':fstring: ccu + 6);
 7b                      if cc>0;
                            FileHowUsed = 'U';
 7e                      endif;
 
 6e                   endif;
 5e                endif;
 4e             endif;
 3e          endif;
 2e       endif;
 
 2b       if IsFile;
             exsr srLoadExtFile;
             exsr srLoadRenamed;
             exsr srLoadIncludeOrIgnore;
             exsr srLoadFileData;
 2e       endif;
 1e    endfor;
       endsr;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srProcessSource;
       UpSpec = %xlate(lo: up: InputDS.SpecType);
 
       // get delete statements as they roll by
 1b    if UpSpec = 'C' and
          %xlate(lo:up:InputDS.OpCode) = 'DELETE';
          DeleteCnt += 1;
          DeleteStatements(DeleteCnt).PrName = dxname;
          DeleteStatements(DeleteCnt).FileOrRcdfmt =
          %xlate(lo: up: InputDS.Factor2);
 
          // get procedure names as they roll by
 1x    elseif UpSpec = 'P' and InputDS.FileName > *blanks;
 
          //----------------------------------------
          // Deal with ... to extract field name
          //----------------------------------------
          Dots = f_EllipsisLoc(InputDS.Src74);
 2b       if Dots = 0;
             dxname = %trim(%subst(InputDS.Src74:1:15));
 2x       else;
             dxname = %trim(%subst(InputDS.Src74:1:Dots-1));
 2e       endif;
          dxname = %xlate(lo: up: dxname);
 
 1x    elseif InputDS.SpecType = *blanks
          and InputDS.Asterisk = *blanks;
 
          string = %xlate(lo: up: string);
          xx = %scan('DCL-PROC':string);
 2b       if xx > 0 and
             f_ReturnZeroIfBetweenQuotes(xx:String) > 0 and
             f_ReturnZeroIfAfterComments(xx:String) > 0;
 
             char74 = string;
             Dots = f_EllipsisLoc(char74);
 3b          if Dots = 0;
                aa = %scan(';':string);
                dxname = %trimr(%subst(char74:xx + 9:aa-(xx+9)));
 3x          else;
                dxname = %trim(%subst(char74:xx+9:Dots-1));
 3e          endif;
 2x       else;
             canidate = f_GetFreeDeleteName(Inputds.Src74);
 3b          if canidate > *blanks;
                DeleteCnt += 1;
                DeleteStatements(DeleteCnt).PrName = dxname;
                DeleteStatements(DeleteCnt).FileOrRcdfmt = Canidate;
 3e          endif;
 2e       endif;
 1e    endif;
 
       //-----------------------------------------------
       // since v6r1 allows files in the procedures, must read entire source
       //-----------------------------------------------
 1b    if f_StartNewFspec;
          p_FileCount += 1;
 
          //--------------------------------------------------------
          // if dcl then move the comments out to the comment field
          // so calling programs will know where comment ends
          //--------------------------------------------------------
 2b       if IsDclf and SlashSlash > 0;
             InputDS.Comment = %subst(InputDS.Src74:SlashSlash) +
             InputDS.Comment;
             %subst(InputDS.Src74:SlashSlash) = *blanks;
 2e       endif;
          p_FspecArry(p_FileCount) = InputDS.Src74;
          p_CommentArry(p_FileCount) = InputDS.Comment;
          p_PrNameArry(p_FileCount) = dxname;
 
          //-----------------------------------------------------
          // now spin through until all keywords are loaded
          //-----------------------------------------------------
          // -- free format read until find ending ;
 2b       if IsDclf;
             Semi = %scan(';':InputDS.Src74);
 3b          if Semi = 0 or
                (SlashSlash > 0 and Semi > SlashSlash);    // ;
                exsr srLoadFreeKeywords;
 3e          endif;
 
 2x       else;
             //-----------------------------------------------------
             // -- fixed column read until find next File start spec
             //-----------------------------------------------------
             exsr srLoadFixedKeywords;
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srLoadFreeKeywords;
       // read and load until semi colon is found
       // drop comments from all lines by dcl-f line.
       SemiColonIsFound = *off;
       %len(ContinuationString) = 0;
 
 1b    dou SemiColonIsFound;
          read RPGSRC InputDS;
 2b       if %eof;
 LV          leavesr;
 2e       endif;
 
 2b       if not f_IsComment;
 3b          if SlashSlash > 0;
                %subst(InputDS.Src74:SlashSlash) = *blanks;
 3e          endif;
             ContinuationString += ' ' + %trim(InputDS.Src74);
 2e       endif;
 
          Semi = %scan(';':InputDS.Src74);
 2b       if (Semi > 0 and (SlashSlash = 0 or Semi < SlashSlash));
             p_FspecArry(p_FileCount) =
             %trimr(p_FspecArry(p_FileCount)) + ' ' + ContinuationString;
             p_PrNameArry(p_FileCount) = dxname;
             SemiColonIsFound = *on;
 2e       endif;
 
 1e    enddo;
       endsr;
 
       //---------------------------------------------------------
       //FFile      is   e           k disk    rename(
       //F                                            xxx010r:r)
       //F                                     include(xxx010r
       //F                                                    :xxx010t)
       // could be a legitimate
       // include/Ignore of multiple record formats that goes across multiple source
       // lines.  Load data from however many records into a single string.
       //---------------------------------------------------------
       begsr srLoadFixedKeywords;
       %len(ContinuationString) = 0;
 
 1b    dou 1 = 2;
          read RPGSRC InputDS;
 2b       if %eof;
 1v          leave;
 2e       endif;
 
 2b       if not f_IsComment;
 3b          if f_StartNewFspec
                or not(InputDS.SpecType = 'F' or InputDS.SpecType = 'f');
                readp RPGSRC InputDS;
 1v             leave;
 3e          endif;
 
 3b          if (InputDS.SpecType = 'F' or InputDS.SpecType = 'f')
                and InputDS.fKeyWord > *blanks;
                ContinuationString += ' ' + %trim(InputDS.fKeyWord);
 3e          endif;
 2e       endif;
 1e    enddo;
 
       //---------------------------------------------------------
       // Cram everything together but do not
       // crowd out the spaces at end of device 'DISK   '
       //---------------------------------------------------------
 1b    if %len(%trimr(p_FspecArry(p_FileCount))) <= 36;
          %subst(p_FspecArry(p_FileCount): 37) = ContinuationString;
 1x    else;  // now start cramming
          p_FspecArry(p_FileCount) =
          %trimr(p_FspecArry(p_FileCount)) + ' ' + ContinuationString;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // extract extfile( or extdesc( values
       // 1) Ignore extfile(*extdesc),  will get those looking for extdesc(
       // 2) only process extfile('  with a tic mark after the (.
       // 3) extract library name (if given) and file name.
       //---------------------------------------------------------
       begsr srLoadExtFile;
       bb = %scan('EXTFILE(': fstring);
 1b    if bb > 0;
 2b       if %subst(fstring: bb+8: 1) = qs;
             exsr srExtractExtFileandLib;
 2e       endif;
 1e    endif;
 
       bb = %scan('EXTDESC(': fstring);
 1b    if bb > 0;
 2b       if %subst(fstring: bb+8: 1) = qs;
             exsr srExtractExtFileandLib;
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       begsr srExtractExtFileandLib;
       FileExt = *blanks;
       LibExt = '*LIBL';
       QuoteStart = bb+8;
       QuoteEnd = %scan(qs: fstring: QuoteStart + 1);
 
 1b    monitor;
          /IF DEFINED(*V7R3M0)
          bb = %scan('/':  fstring: QuoteStart + 1: QuoteEnd-QuoteStart);
          /ELSE
          bb = %scan('/':  fstring: QuoteStart + 1);
           /ENDIF
 1x    on-error;
          bb=0;
 1e    endmon;
 
 1b    if bb = 0; // no library
          FileExt =
          %subst(fstring: QuoteStart + 1: (QuoteEnd-QuoteStart)-1);
 1x    else;
          LibExt = %subst(fstring: QuoteStart+1: (bb-QuoteStart)-1);
          FileExt = %subst(fstring: bb + 1: (QuoteEnd-bb)-1);
 2b       if LibExt = 'QTEMP';
             LibExt = '*LIBL';
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // extract RENAME values
       //---------------------------------------------------------
       begsr srLoadRenamed;
       NextRename = 0;
 
 1b    dou 1 = 2;
          NextRename = %scan('RENAME(': fstring: NextRename + 1);
 2b       if NextRename = 0;
 1v          leave;
 2e       endif;
 
          CountRename += 1;
          aa = %scan(':': fstring: NextRename);
 
          BeingRenamed(CountRename) =
          %triml(%subst(fstring: NextRename + 7: aa - (NextRename + 7)));
 
          bb = %scan(')': fstring: aa);
          RenamedFmt(CountRename) =
          %triml(%subst(fstring: aa + 1: (bb - aa) - 1));
 1e    enddo;
       endsr;
 
       //---------------------------------------------------------
       // Check IGNORED record formats in this file.
       // Multiple formats could be in one statement separated by :  .
       //  Extract all formats that are included/ignored and return
       //   them in array of record formats.
       //---------------------------------------------------------
       begsr srLoadIncludeOrIgnore;
 1b    if %scan('IGNORE(': fstring) > 0;
          IsIgnore = *on;
 1x    elseif %scan('INCLUDE(': fstring) > 0;
          IsInclude = *on;
 1e    endif;
 
       //---------------------------------------------------------
       // Could rename(a:b) ignore(ccc) on a single line.
       // Look for INCLUDE or IGNORE (could be in string many times)
       //  IGNORE(A) IGNORE(b:c)
       //---------------------------------------------------------
 1b    if %scan('IGNORE(': fstring) > 0
          or %scan('INCLUDE(': fstring) > 0;
 
 2b       if IsIgnore;
             cc = %scan('IGNORE(': fstring);
 3b          dow cc > 0;
                cc += 7;
                exsr srExtractNames;
                cc = %scan('IGNORE(': fstring: cc);
 3e          enddo;
 2e       endif;
 
 2b       if IsInclude;
             cc = %scan('INCLUDE(': fstring);
 3b          dow cc > 0;
                cc += 8;
                exsr srExtractNames;
                cc = %scan('INCLUDE(': fstring: cc+1);
 3e          enddo;
 2e       endif;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // So look for end parenthesis, process between parenthesis, then check for more
       //---------------------------------------------------------
       begsr srExtractNames;
       EndParenthesis = %scan(')': fstring: cc);
 
       //----------------------------------------------
       // cc = after ( of ignore( or include(.
       //  Only process this keyword to )
       //----------------------------------------------
       CurrentColon = cc;
       CurrentColon = %scan(':': fstring: CurrentColon + 1);
 1b    if CurrentColon = 0 or CurrentColon > EndParenthesis;  //(singlename)
          CountIncExc += 1;
          FormatIncludeOrIgnore(CountIncExc) =
          %triml(%subst(fstring: cc: EndParenthesis - cc));
 1x    else;
 
          // tiptoe through the colon(s)   (a  :b:c) etc...
 2b       dou CurrentColon = 0 or CurrentColon > EndParenthesis;
             CountIncExc += 1;
             FormatIncludeOrIgnore(CountIncExc) =
             %triml(%subst(fstring: cc: CurrentColon - cc));
             cc = CurrentColon + 1;
             CurrentColon = %scan(':': fstring: cc);
 
 3b          if CurrentColon = 0 or CurrentColon > EndParenthesis;
                CountIncExc += 1;
                FormatIncludeOrIgnore(CountIncExc) =
                %triml(%subst(fstring:
                cc: EndParenthesis - cc));
 2v             leave;
 3e          endif;
 2e       enddo;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // load fields from files
       begsr srLoadFileData;
 
 1b    if FileExt > *blanks;
          WorkFileQual = FileExt + LibExt;
 1x    else;
          WorkFileQual = FileNameSave + LibExt;
 1e    endif;
 
       AllocatedSize = f_GetAllocatedSize(WorkFileQual: '*FIRST');
 1b    if ApiErrDS.BytesReturned > 0;
          OnePerCnt += 1;
          OnePerRcdFmt(OnePerCnt).File = FileNameSave;
          OnePerRcdFmt(OnePerCnt).FileExt = FileExt;
          OnePerRcdFmt(OnePerCnt).Lib = *all'*';
          OnePerRcdFmt(OnePerCnt).Format = *all'*';
          OnePerRcdFmt(OnePerCnt).FormatReName = *all'*';
          OnePerRcdFmt(OnePerCnt).BasedOnPF = '*NOT FOUND';
          OnePerRcdFmt(OnePerCnt).Usage = *blanks;
          OnePerRcdFmt(OnePerCnt).FileAddition = *blanks;
          OnePerRcdFmt(OnePerCnt).Text = '*FILE NOT FOUND';
          OnePerRcdFmt(OnePerCnt).ProcName = p_PrNameArry(ff);
          OnePerRcdFmt(OnePerCnt).FileCount = ff;
 
 1x    else;
          Fild0100ptr = %realloc(Fild0100ptr: AllocatedSize);
          callp QDBRTVFD(
                Fild0100ds:
                AllocatedSize:
                ReturnFileQual:
                'FILD0100':
                WorkFileQual:
                '*FIRST':
                '0':
                '*FILETYPE':
                '*EXT':
                ApiErrDS);
          fscopePtr = Fild0100ptr + Fild0100ds.OffsFileScope;
          IsLF = (%bitand(bit2: Fild0100ds.TypeBits) = bit2);
 
          //---------------------------------------------------------
          // Process record formats
          //---------------------------------------------------------
 2b       for ForCount = 1 to Fild0100ds.NumOfBasedPf;
 
             RenameSave = *blanks;
             // apply all includes/ignores and renames
 3b          if CountRename > 0;
                aa = %lookup(FileScopeArry.RcdFmt:
                BeingRenamed: 1: CountRename);
 4b             if aa> 0;
                   RenameSave = RenamedFmt(aa);
 4e             endif;
 3e          endif;
 
             IsProcess = *on;
 3b          if CountIncExc > 0;
                aa = %lookup(FileScopeArry.RcdFmt:
                FormatIncludeOrIgnore: 1: CountIncExc);
 
 4b             if IsInclude and aa = 0;
                   IsProcess = *off;
 4e             endif;
 
 4b             if IsIgnore and aa > 0;
                   IsProcess = *off;
 4e             endif;
 3e          endif;
 
 3b          if IsProcess;
                OnePerCnt += 1;
                OnePerRcdFmt(OnePerCnt).File = FileNameSave;
                OnePerRcdFmt(OnePerCnt).FileExt = FileExt;
                OnePerRcdFmt(OnePerCnt).Lib = %subst(ReturnFileQual: 11: 10);
                OnePerRcdFmt(OnePerCnt).Format = FileScopeArry.RcdFmt;
                OnePerRcdFmt(OnePerCnt).FormatReName = RenameSave;
                OnePerRcdFmt(OnePerCnt).Usage = FileHowUsed;
                OnePerRcdFmt(OnePerCnt).FileAddition = FileAddition;
                OnePerRcdFmt(OnePerCnt).ProcName = p_PrNameArry(ff);
                OnePerRcdFmt(OnePerCnt).FileCount = ff;
 
 4b             if IsLF;
                   OnePerRcdFmt(OnePerCnt).BasedOnPF
                   = FileScopeArry.BasedOnPf;
                   QusrObjDS = f_QUSROBJD(FileScopeArry.BasedOnPf +
                               FileScopeArry.BasedOnPfLib: '*FILE');
                   OnePerRcdFmt(OnePerCnt).Text = QusrObjDS.Text;
 4x             else;
                   OnePerRcdFmt(OnePerCnt).BasedOnPF = *blanks;
                   OnePerRcdFmt(OnePerCnt).Text = Fild0100ds.FileText;
 4e             endif;
 
 3e          endif;
             fscopePtr += 160;
 2e       endfor;
 1e    endif;
       endsr;
 
       //----------------------------------------------------------
       //----------------------------------------------------------
       dcl-proc f_IsFoundInThisProc;
        dcl-pi *n ind end-pi;
 
 1b     if OnePerRcdFmt(aa).FormatReName > *blanks
           and
           OnePerRcdFmt(aa).FormatReName =
           DeleteStatements(bb).FileOrRcdFmt;
           return *on;
 
 1x     elseif OnePerRcdFmt(aa).Format > *blanks
           and
           OnePerRcdFmt(aa).Format =
           DeleteStatements(bb).FileOrRcdFmt;
           return *on;
 
 1x     elseif OnePerRcdFmt(aa).File =
           DeleteStatements(bb).FileOrRcdFmt;
           return *on;
 1e     endif;
 
        return *off;
       end-proc;
 
       //----------------------------------------------------------
       //----------------------------------------------------------
       // return on if start of new File spec
       dcl-proc f_StartNewFspec;
        dcl-pi *n ind;
        end-pi;
        IsDclf = *off;
 
 1b     if f_IsComment;
           return *off;
 
 1x     elseif ((InputDS.SpecType = 'F' or InputDS.SpecType = 'f') and
           InputDS.FileName > *blanks);
           return *on;
 
 1x     else;
           LowRec = %xlate(up: lo: InputDS.Src74);
           IsDclf = (%scan('dcl-f': LowRec) > 0);
 2b        if IsDclf;
              return *on;
 2e        endif;
 1e     endif;
 
        return *off;
       end-proc;
 
       //-----------------------------------------------------------
       // return on if is a comment line
       dcl-proc f_IsComment;
        dcl-pi *n ind;
        end-pi;
        dcl-s FirstCharacter uns(3);
 
 1b     if (InputDS.Asterisk = '*' or InputDS.Asterisk = '/');
           return *on;
 1e     endif;
 
        SlashSlash = %scan('//': InputDS.Src74);
        FirstCharacter = %check (' ': InputDS.Src74);
 1b     if SlashSlash = FirstCharacter;
           return *on;
 1e     endif;
 
        return *off;
       end-proc;
 
       //------------------------------
       // return file or record format name for delete opcode
       // delete name;
       // delete(e) name ;
       // delete (key:key2) name    ;
       // delete key name    ;
       //
       // Find the ; and then back up to the beginning of the name.
       //-
       // if someone wants to write a multi-line extraction
       //   delete
       //           a
       //               name;
       // please send me the code.
       //------------------------------
       dcl-proc f_GetFreeDeleteName;
        dcl-pi *n char(14);
         pstring char(74);
        end-pi;
 
        dcl-s canidate char(14);
        dcl-s EndPos uns(3);
        dcl-s bb uns(3);
        dcl-s StartPos uns(3);
        dcl-s NameStart uns(3);
        dcl-s NameEnd uns(3);
        dcl-s AfterCommentCheck varchar(94);
        dcl-s string char(74);
 
        string = %xlate(lo:up:pstring);
        canidate = *blanks;
        StartPos = %scan(' DELETE':string:1);
 1b     if StartPos > 0;
 
           AfterCommentCheck = %trimr(string);
           StartPos =
           f_ReturnZeroIfAfterComments(StartPos: AfterCommentCheck);
 2b        if StartPos > 0;
              StartPos =
              f_ReturnZeroIfBetweenQuotes(StartPos: AfterCommentCheck);
 2e        endif;
 
 2b        if StartPos > 0;
             // now get end of the line pos
              EndPos = %scan(';':string:StartPos+1);
 3b           if EndPos > 0;
 
                //-------------------------------------------------
                 NameStart = 0;
                 NameEnd = 0;
 
 4b              for bb = (EndPos - 1) downto (StartPos + 6);
 5b                 if NameEnd = 0 and %subst(string:bb:1) > ' ';
                       NameEnd = bb;
 5e                 endif;
 
 5b                 if NameEnd > 0 and %subst(string:bb:1) = ' ';
                       NameStart = bb + 1;
 4v                    leave;
 5e                 endif;
 
 4e              endfor;
 
 
 4b              if NameStart > 0
                    and NameEnd > 0
                    and NameEnd >= NameStart;
 
                    canidate =
                    %subst(string:
                    NameStart:
                    NameEnd - NameStart + 1);
 4e              endif;
                 return canidate;
 
 3e           endif;
 2e        endif;
 1e     endif;
 
        return *blanks;
       end-proc;
