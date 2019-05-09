       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRGETFLDR - load EXPORT array with field name and attributes
       //  Generate diagnostic source listing
       //   Read spooled file
       //    Load JCRCMDSSRV clipboard array with field names and attributes
       //---------------------------------------------------------
       /define ControlStatements
       /define FieldsArry
       /define FieldsAttrDS
       /define f_IsValidMbr
       /define f_GetQual
       /define f_RunCmd
       /define f_Qusrmbrd
       /define f_BuildString
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRGETFLDF disk(132) usropn;
       dcl-ds inputDS len(132);
        iNotReferenced char(1) pos(1);
        iCheckComplete char(20) pos(1);
        iCheckCompleteSql char(20) pos(4);
        iMsgSummary char(7) pos(2);
        iEqual char(1) pos(7);
        iGlobalRef char(24) pos(7);
        iFileType char(1) pos(8);
        iExternalForma char(30) pos(9);
        iDFieldName char(10) pos(10);
        iFldShort char(17) pos(10);
        iFldLong char(123) pos(10);
        iOFieldName char(10) pos(32);
        iGlobAttr1 char(1) pos(28);
        iGlobAttr3 char(3) pos(27);
        iGlobLen char(17) pos(29);
        iFSname char(92) pos(41);
        iReference char(31) pos(50);
        iIFieldName char(15) pos(51);
        iDiagSeverity char(2) pos(31);
        iDiagSeveritySql char(2) pos(1);
        iFieldText char(39) pos(83);
        iFileSeq char(3) pos(122);
       end-ds;
 
       dcl-s aa uns(10);
       dcl-s readcount uns(10);
       dcl-s xx uns(10);
       dcl-s ii uns(10);
       dcl-s xOpen uns(3);
       dcl-s xComma uns(3);
       dcl-s xAster uns(3);
       dcl-s xClose uns(3);
       dcl-s FileNameArry char(10) dim(12767);
       dcl-s FileFldsArry char(15) dim(12767);
       dcl-s FileFldTxtArry dim(12767) like(ifieldtext);
       dcl-s FileName char(10);
       dcl-s FileSeq char(3);
       dcl-s IsGlobalRef ind inz(*off);
       dcl-s SavName char(100);
       dcl-s SavProcName char(100);
       dcl-s SavQualified char(100);
       dcl-s SavDim char(15);
       dcl-s IsUnReferenced ind;
       dcl-s IsQualified ind;
       dcl-s IsLookForSeverity ind;
       dcl-s IsServicePgm ind;
       dcl-s char8 char(8);
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_SrcFilQual char(20);
        p_SrcMbr char(10);
        p_DiagSeverity char(2);
        p_PepCnt packed(3);
       end-pi;
 
       p_PepCnt = 0;
 
       //---------------------------------------------------------
       // generate diagnostic listing and copy to data file
       //---------------------------------------------------------
       p_DiagSeverity = '00';
 1b    if f_IsValidMbr('JCRGETFLDF' + 'QTEMP');
          f_RunCmd('CLRPFM QTEMP/JCRGETFLDF');
 1x    else;
          f_RunCmd('CRTPF FILE(QTEMP/JCRGETFLDF) RCDLEN(132) SIZE(*NOMAX)');
 1e    endif;
 
       f_RunCmd('OVRPRTF FILE(' + p_SrcMbr + ') HOLD(*YES)');
 
       QusrmbrdDS = f_Qusrmbrd(p_SrcFilQual: p_SrcMbr: 'MBRD0100');
 1b    if QusrmbrdDS.MbrType = 'SQLRPGLE';
          f_RunCmd(f_BuildString('+
          CRTSQLRPGI OBJ(QTEMP/&) SRCFILE(&) OPTION(*NOXREF *GEN) +
          OUTPUT(*PRINT) COMPILEOPT(&QDFTACTGRP(*NO)&Q)':
          p_SrcMbr:
          f_GetQual(p_SrcFilQual)));
 
          f_RunCmd('CPYSPLF FILE(' + p_SrcMbr +
          ') TOFILE(QTEMP/JCRGETFLDF) SPLNBR(*LAST)');
 1x    else;
 
          //---------------------------------------------------------
          // weird. the compiler list will not show the pep unless *GEN the program
          //---------------------------------------------------------
          f_RunCmd(f_BuildString('+
          CRTBNDRPG PGM(QTEMP/&) SRCFILE(&) +
          OPTION(*XREF *NOSECLVL *SHOWCPY *EXPDDS +
          *NOEXT *NOSHOWSKP *NOSRCSTMT *NOEVENTF) DFTACTGRP(*NO)':
          p_SrcMbr:
          f_GetQual(p_SrcFilQual)));
 1e    endif;
 
       f_RunCmd('CPYSPLF FILE(' + p_SrcMbr +
       ') TOFILE(QTEMP/JCRGETFLDF) SPLNBR(*LAST)');
       f_RunCmd('DLTOVR FILE(' + p_SrcMbr + ')');
       f_RunCmd('DLTPGM PGM(QTEMP/' + p_SrcMbr+')');
 
       //---------------------------------------------------------
       // read listing
       open JCRGETFLDF;
       read JCRGETFLDF inputDS;
       readCount += 1;
 1b    dow not %eof;
 
 2b       if iGlobLen = 'ASED(_QRNL_PRM+)';
             p_PepCnt += 1;
 2e       endif;
 
 2b       if iGlobalRef = 'Indicator References:';
             IsLookForSeverity = *on;
 2e       endif;
 
 2b       if not IsLookForSeverity;
 3b          if IsGlobalRef;
                exsr srGlobalDefinitions;
 3x          else;
                exsr srFileFieldDefinitions;
 3e          endif;
 
 3b          if iGlobalRef = 'Global Field References:';
                IsGlobalRef = *on;
 3e          endif;
 2e       endif;
 
 2b       if IMsgSummary = 'RNF1304';
             IsServicePgm = *on;
 2e       endif;
 
 2b       if not IsServicePgm;
 3b          if iCheckComplete = 'Compilation stopped.';
                p_DiagSeverity = iDiagSeverity;
 1v             leave;
 3e          endif;
 
 3b          if iCheckCompleteSql = 'level severity error';
                p_DiagSeverity = iDiagSeveritySql;
 1v             leave;
 3e          endif;
 2e       endif;
 
          read JCRGETFLDF inputDS;
          readCount += 1;
 1e    enddo;
 
       //---------------------------------------------------------
 1b    if p_DiagSeverity <= '20';
          f_RunCmd('DLTSPLF FILE(' + p_SrcMbr + ') SPLNBR(*LAST)');
 1e    endif;
 
 1b    if ii > 1;
          sorta %subarr(FieldsArry(*).Name: 1: ii);
 1e    endif;
 
       FieldsArryCnt = ii;
       close JCRGETFLDF;
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       // Load up all the file field sequence numbers to reference later
       //---------------------------------------------------------
       begsr srFileFieldDefinitions;
 1b    if iExternalForma = '* External format  . . . . . :';
          aa = %scan('/':iFSname);
          FileName = %subst(iFSname: aa+1);
          FileSeq = iFileSeq;
 2b       dou iEqual = '=';
             read JCRGETFLDF inputDS;
             readCount += 1;
 3b          if iGlobalRef = 'Global Field References:';
 2v             leave;
 3e          endif;
 3b          if iGlobalRef = 'Indicator References:';
                IsLookForSeverity = *on;
 LV             leavesr;
 3e          endif;
 2e       enddo;
 1e    endif;
 
 1b    if iEqual = '=';
          xx += 1;
          FileNameArry(xx) = FileName;
 2b       if iFileType = 'D';
             FileFldsArry(xx) = iDFieldName;
 
 2x       elseif iFileType = 'I';
             FileFldsArry(xx) = iIFieldName;
 2x       elseif iFileType = 'O';
             FileFldsArry(xx) = iOFieldName;
 2e       endif;
          FileFldTxtArry(xx) = iFieldText;
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       begsr srGlobalDefinitions;
 1b    if iGlobalRef = 'Field References for sub';
          SavProcName = iFSname;
 1e    endif;
 
 1b    if iFldLong = 'No references in the source.';
          IsLookForSeverity = *on;
 LV       leavesr;
 1e    endif;
 
 1b    if iGlobAttr3 = ' A('
          or iGlobAttr3 = ' B('
          or iGlobAttr3 = ' F('
          or iGlobAttr3 = ' G('
          or iGlobAttr3 = ' I('
          or iGlobAttr3 = ' N('
          or iGlobAttr3 = ' P('
          or iGlobAttr3 = ' S('
          or iGlobAttr3 = ' D('
          or iGlobAttr3 = ' T('
          or iGlobAttr3 = ' U('
          or iGlobAttr3 = ' Z('
          or iGlobAttr3 = ' *('
          or iGlobAttr3 = ' DS'
          or iGlobAttr3 = ' CO';
          IsUnReferenced = *off;
          //---------------------------------------------------------
          // Extract the field name for these attributes.
          // The field name could be on the same line
          // RULER1ARRY(19)    A(10)
          // or read backwards a line
          // FieldsArryCnt...
          //                    U(5,0)           384D   1252
          // or if on a page break, spread across several lines
          //
          // If field name is not on same line, save rrn, read backwards
          // until ... is found for long field name
          //---------------------------------------------------------
          Savname = *blanks;
 2b       if iDFieldName > *blanks;
             IsQualified = (%subst(iFldShort:1 :1) = ' ');
             SavName = %triml(iFldShort);
 3b          if iNotReferenced = '*';
                IsUnReferenced = *on;
 3e          endif;
 2x       else;
 
             // find long field name reading backwards
             readp JCRGETFLDF inputDS;
 3b          dow not %eof;
                aa = %scan('...': iFldLong);
 4b             if aa > 0;
                   SavName = %triml(%subst(iFldLong: 1: aa - 1));
 5b                if iNotReferenced = '*';
                      IsUnReferenced = *on;
 5e                endif;
                   chain readcount JCRGETFLDF inputDS; // reposition
 3v                leave;
 4e             endif;
                readp JCRGETFLDF inputDS;
 3e          enddo;
 2e       endif;
 
          //--------------------------
          // load attributes from current record before looking for field name
          //--------------------------
          clear FieldsAttrDS;
          FieldsAttrDS.DecimalPos = *blanks;
 
          //--------------------------
 2b       if iGlobAttr3 = ' DS';
             FieldsAttrDS.DataType = 'A';
 2x       elseif iGlobAttr3 = ' CO';
             FieldsAttrDS.DataType = 'C';
 2x       else;
             FieldsAttrDS.DataType = iGlobAttr1;
 2e       endif;
 
          //--------------------------
          // Alpha sizes are (6) Numeric are (6,0) Date&Time are (8*ISO-)
          //--------------------------
 2b       if iGlobAttr3 <> ' CO';
             xOpen = %scan('(': iGlobLen);
             xComma = %scan(',': iGlobLen);
             xAster = %scan('*': iGlobLen);
             xClose = %scan(')': iGlobLen);
 
 3b          if xAster > 0;  // date or time
                char8 =
                %subst(iGlobLen: xOpen + 1: (xAster - xOpen) - 1);
                FieldsAttrDS.Length = %uns(char8);
                FieldsAttrDS.Text =
                %subst(iGlobLen: xAster + 1: (xClose - xAster)- 1);
 
 3x          elseif xComma > 0; // numeric
                char8 =
                %subst(iGlobLen: xOpen + 1: (xComma - xOpen) - 1);
                FieldsAttrDS.Length = %uns(char8);
                evalr FieldsAttrDS.DecimalPos = '  ' +
                %subst(iGlobLen: xComma + 1: (xClose - xComma)- 1);
 
 3x          else; // alpha
                char8 =
                %subst(iGlobLen: xOpen + 1: (xClose - xOpen) - 1);
                FieldsAttrDS.Length = %uns(char8);
 3e          endif;
 2e       endif;
 
 2b       if iGlobAttr3 = ' DS';
             FieldsAttrDS.Text = 'DS';
             SavQualified = SavName;
 2x       elseif iGlobAttr3 = ' CO';
             FieldsAttrDS.Text = 'CONST';
             FieldsAttrDS.DecimalPos = *blanks;
 
             //---------------------------------------------------------
             // Constants do not show as unreferenced (thanks IBM).
             // Also the reference numbers are in variable position
             //  based on the number of source statements in the code (Thanks Again).
             // 0123456789012345
             // 3000016M     012900M    7000016
             //  Start in pos 50, look for first non-blank, then first blank
             //  and check everything after that for blanks.
             //  In above example, look for the first space after the 3, position 8
             // if everything after position 8 is blank, then unreferenced.
             //---------------------------------------------------------
             aa = %check(' ':iReference);
             aa = %scan(' ':iReference: aa);
 3b          if %subst(iReference: aa) = *blanks;
 LV             leavesr;
 3e          endif;
 2e       endif;
 
 2b       if IsQualified;
             FieldsAttrDS.Text = SavQualified;
 2e       endif;
 
          //--------------------------
          // Now that the name is extracted, see if file defined field
          //--------------------------
 2b       if Savname > *blanks;
             aa = %lookup(SavName: FileFldsArry: 1: xx);
 3b          if aa > 0;
                FieldsAttrDS.FromFile = FileNameArry(aa);
                FieldsAttrDS.Text = FileFldTxtArry(aa);
 3e          endif;
 2e       endif;
 
          //--------------------------
          // DIM values are stored in field names between (10) = DIM 10
          // compress the DIM out of the field name
          //--------------------------
          SavDim = *blanks;
          xOpen = %scan('(': SavName);
 2b       if xOpen > 0;
             xClose = %scan(')': SavName);
             SavDim =
             'DIM' + %subst(SavName: xOpen: (xClose - xOpen)+1);
             SavName = %subst(SavName:1: xOpen - 1);
             FieldsAttrDS.Text = SavDim;
 2e       endif;
 
          //--------------------------
 2b       if SavProcName > *blanks;
             FieldsAttrDS.Text = SavProcName;
 2e       endif;
 
          //---------------------------------------------------------------
          // The JCRCALL (generate call prompt) may need the unreferenced
          // field definitions as an unreferenced field could be in the PR.
          //---------------------------------------------------------------
 2b       if IsUnreferenced;
             FieldsAttrDS.Text = '*NOT REFERENCED';
 2e       endif;
          //--------------------------
 2b       if %subst(SavName:1:1) <> '*';  // skip indicatiors
 3b          if ii = 0 or
                %lookup(SavName: FieldsArry(*).Name: 1: ii) = 0;
                ii += 1;
                FieldsArry(ii).Name = SavName;
                FieldsArry(ii).Attr = FieldsAttrDS;
 3e          endif;
 2e       endif;
 1e    endif;
       endsr;
