       /If defined(Title)
       //---------------------------------------------------------
       // This program is free software, you can redistribute it and/or modify it
       // under the terms of the GNU General Public License as published by
       // the Free Software Foundation. See GNU General Public License for detail.
       //   Craig Rutledge  < www.jcrcmds.com >
       //---------------------------------------------------------
       // JCRCMDSCPY - Copy Book for JCRCMDS
       //---------------------------------------------------------
       /endif
       /If defined(ControlStatements)
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
       /endif
       /If defined(ApiErrDS)
       //---------------------------------------------------------
       // API error return parm
       dcl-ds ApiErrDS qualified import;
        BytesProvided int(10) pos(1);
        BytesReturned int(10) pos(5);
        ErrMsgId char(7) pos(9);
        MsgReplaceVal char(112) pos(17);
       end-ds;
       /endif
       /If defined(Atof)
       //---------------------------------------------------------
       // C String to Float
       dcl-pr atof float(8) extproc(*dclcase);
        *n pointer value options(*string);
       end-pr;
       /endif
       /If defined(Constants)
       //---------------------------------------------------------
       dcl-s rrn uns(5);
       dcl-s aa uns(5);
       dcl-s bb uns(5);
       dcl-s cc uns(5);
       dcl-c qs const(''''); // quote single
       dcl-c qd const('"');  // quote double
       dcl-c up const('ABCDEFGHIJKLMNOPQRSTUVWXYZ');
       dcl-c lo const('abcdefghijklmnopqrstuvwxyz');
       /endif
       /If defined(Cvthc)
       //---------------------------------------------------------
       // Convert Hex to Character
       dcl-pr cvthc extproc(*dclcase);
        *n pointer value; // receiver pointer
        *n pointer value; // source pointer
        *n int(10) value; // receiver length
       end-pr;
       /endif
       /If defined(Infds)
       //---------------------------------------------------------
       // File Information Data Structure
       dcl-ds Infds;
        InfdsFile char(10) pos(83);
        InfdsLib char(10) pos(93);
        InfdsRecLen int(5) pos(125);
        InfdsMbr char(10) pos(129);
        InfdsCcsid int(5) pos(218);
        InfdsRcdfmt char(10) pos(261);
        InfdsFkey char(1) pos(369);
        InfdsSflRcdNbr int(5) pos(378);
        InfdsDbRrn int(10) pos(397);
       end-ds;
       /endif
       /If defined(Dspatr)
       //---------------------------------------------------------
       dcl-c Green const(x'20');
       dcl-c White const(x'22');
       dcl-c Red const(x'28');
       dcl-c Turq const(x'30');
       dcl-c Yellow const(x'32');
       dcl-c Pink const(x'38');
       dcl-c Blue const(x'3A');
       dcl-c ND const(x'27');
       dcl-c RI const(x'01');
       dcl-c HI const(x'02');
       dcl-c UL const(x'04');
       dcl-c PR const(x'80');
       /endif
       /If defined(FieldsAttrDS)
       //---------------------------------------------------------
       dcl-ds FieldsAttrDS qualified inz;
        Length uns(10);
        DecimalPos char(2);
        DecimalPosN zoned(2) overlay(DecimalPos);
        DataType char(1);
        FromFile char(10);
        QualifyingDS char(50);
        Text char(25);
       end-ds;
       /endif
       /If defined(FieldsArry)
       //---------------------------------------------------------
       dcl-s FieldsArryCnt uns(10) import;
       dcl-ds FieldsArry dim(5000) qualified import;
        Name char(100);
        Attr like(FieldsAttrDS);
       end-ds;
       /endif
       /If defined(FunctionKeys)
       //---------------------------------------------------------
       dcl-c f01 const(x'31');
       dcl-c f02 const(x'32');
       dcl-c f03 const(x'33');
       dcl-c f04 const(x'34');
       dcl-c f05 const(x'35');
       dcl-c f06 const(x'36');
       dcl-c f07 const(x'37');
       dcl-c f08 const(x'38');
       dcl-c f09 const(x'39');
       dcl-c f10 const(x'3A');
       dcl-c f11 const(x'3B');
       dcl-c f12 const(x'3C');
       dcl-c f13 const(x'B1');
       dcl-c f14 const(x'B2');
       dcl-c f15 const(x'B3');
       dcl-c f16 const(x'B4');
       dcl-c f17 const(x'B5');
       dcl-c f18 const(x'B6');
       dcl-c f19 const(x'B7');
       dcl-c f20 const(x'B8');
       dcl-c f21 const(x'B9');
       dcl-c f22 const(x'BA');
       dcl-c f23 const(x'BB');
       dcl-c f24 const(x'BC');
       dcl-c fPageup const(x'F4');
       dcl-c fPageDown const(x'F5');
       /endif
       /If defined(Ind)
       //---------------------------------------------------------
       // name screen indicators
       dcl-ds ind qualified inz;
        IsActivateF14 ind pos(04);
        IsKeysMode ind pos(05);
        sfldrop ind pos(06);
        HeadingSwitch ind pos(10);
        sflnxtchg ind pos(11);
        IsChangedDate ind pos(20);
        IsChange ind pos(23);
        ShowSrcData ind pos(27);
        sfldsp ind pos(31);
        sfldspctl ind pos(32);
        sflclr ind pos(33);
        sflend ind pos(34);
        sfldsp2 ind pos(41);
        sfldspctl2 ind pos(42);
        sflclr2 ind pos(43);
        sflend2 ind pos(44);
        sfldsp3 ind pos(51);
        sfldspctl3 ind pos(52);
        sfldsp4 ind pos(61);
        sfldspctl4 ind pos(62);
       end-ds;
       /endif
       /If defined(Qwcrneta)
       //---------------------------------------------------------
       // Retrieve Network Attributes
       dcl-pr Qwcrneta extpgm('QWCRNETA');
        *n char(200) options(*varsize);  // Receiver Variable
        *n int(10) const;  // Receiver Length
        *n int(10) const;  // Number Of Keys
        *n char(20) const;  // Constant
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds QwcrnetaDS len(200) qualified inz;
        NumberKeys int(10);
        TableOffset int(10);
       end-ds;
 
       // Network Attribute Information Table returned
       dcl-ds NetworkInfoDS qualified based(NetWorkInfoPtr);
        Attribute char(10) pos(1);
        TypeOfData char(1) pos(11);
        InfoStatus char(1) pos(12);
        LengthOfData int(10) pos(13);
        LocalSysName char(8) pos(17);
       end-ds;
       /endif
       /If defined(Qbnlpgmi)
       //---------------------------------------------------------
       // List ILE Program Information
       dcl-pr Qbnlpgmi extpgm('QBNLPGMI');
        *n char(20); // user space
        *n char(8) const; // api format
        *n char(20) const; // object and lib
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds QbnlpgmiDS qualified based(QbnlpgmiPTR);
        SrcFil char(10) pos(41);
        SrcLib char(10) pos(51);
        SrcMbr char(10) pos(61);
        SrcAttrb char(10) pos(71);
       end-ds;
       /endif
       /If defined(Qbnlspgm)
       //---------------------------------------------------------
       // List Service Program Information
       dcl-pr Qbnlspgm extpgm('QBNLSPGM');
        *n char(20);  // user space
        *n char(8) const; // api format
        *n char(20) const; // object and lib
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds SrvPgmDs qualified based(SrvPgmPtr);
       //these 2 fields are for SPGL0600 format
        LengthOfName int(10) pos(25);
        BigProcName char(256) pos(29);
 
       // SPGL0100 format
        SrcFil char(10) pos(41);
        SrcLib char(10) pos(51);
        SrcMbr char(10) pos(61);
        SrcAttrb char(10) pos(71);
       end-ds;
       /endif
       /If defined(Qbnrmodi)
       //---------------------------------------------------------
       // Retrieve Module Information
       dcl-pr Qbnrmodi extpgm('QBNRMODI');
        *n char(200);  // receiver
        *n int(10) const;  // receiver length
        *n char(8) const;  // api format
        *n char(20) const;  // object and lib
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds QbnrmodiDS len(200) qualified;
        SrcFil char(10) pos(52);
        SrcLib char(10) pos(62);
        SrcMbr char(10) pos(72);
       end-ds;
 
       /endif
       /If defined(Qclrpgmi)
       //---------------------------------------------------------
       // Retrieve Non-ile Program Information (like CLP)
       dcl-pr Qclrpgmi extpgm('QCLRPGMI');
        *n char(528);  // receiver
        *n int(10) const;  // receiver length
        *n char(8) const;  // api format
        *n char(20) const;  // file and lib
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds QclrpgmiDS len(528) qualified;
        SrcAttrb char(10) pos(39);
        SrcFil char(10) pos(62);
        SrcLib char(10) pos(72);
        SrcMbr char(10) pos(82);
        PgmType char(1) pos(161);  // B=ILE program
       end-ds;
       /endif
       /If defined(Qcmdchk)
       //---------------------------------------------------------
       // Check Command Syntax
       dcl-pr Qcmdchk extpgm('QCMDCHK');
        *n char(500);
        *n packed(15: 5) const;
       end-pr;
       /endif
       /If defined(Qdbldbr)
       //---------------------------------------------------------
       // List Database Relations
       dcl-pr Qdbldbr extpgm('QDBLDBR');
        *n char(20);  // user space
        *n char(8) const;  // api format
        *n char(20) const;  // file and lib
        *n char(10) const;  // mbr
        *n char(10) const;  // record format
        *n like(ApiErrDS);
       end-pr;
 
       //-DBRL0100 format-
       dcl-ds QdbldbrDS qualified based(QdbldbrPtr);
        DependentLF char(10) pos(21);
        DependentLib char(10) pos(31);
        DependentFile char(20) pos(21);
       end-ds;
       /endif
       /If defined(Qdbrtvfd)
       //---------------------------------------------------------
       // Retrieve Database File Description
       dcl-pr Qdbrtvfd extpgm('QDBRTVFD');
        *n char(16000) options(*varsize);  // receiver
        *n int(10) const;  // receiver length
        *n char(20);  // return file and lib
        *n char(8) const;  // api format
        *n char(20) const;  // file and lib
        *n char(10) const;  // record format
        *n char(1) const;  // overrides
        *n char(10) const;  // system
        *n char(10) const;  // format type
        *n like(ApiErrDS);
       end-pr;
 
       dcl-s ReturnFileQual char(20);
 
       // file header offsets
       dcl-ds Fild0100ds qualified based(Fild0100ptr);
        BytesReturned int(10) pos(1);
        TypeBits char(1) pos(9);
        NumOfBasedPf int(5) pos(15);
        MaxMbrs int(5) pos(42);
        NumMbrs int(5) pos(48);
        NumRcdFmts int(5) pos(62);
        FileText char(50) pos(85);
        NumOfFlds int(5) pos(207);
        FileRecLen int(5) pos(305);
        OffsFileScope int(10) pos(317);
        AccessType char(2) pos(337);
        OffsPFAttr int(10) pos(365);
        OffsLfAttr int(10) pos(369);
       end-ds;
 
       // file scope array
       dcl-ds FileScopeArry len(160) qualified based(fscopePtr);
        BasedOnPf char(10) pos(49);
        BasedOnPfLib char(10) pos(59);
        RcdFmt char(10) pos(69);
        NumOfKeys int(5) pos(116);
        NumSelectOmit int(5) pos(129);
        OffsSelectOmit int(10) pos(131);
        OffsKeySpecs int(10) pos(135);
       end-ds;
 
       // key specification array
       dcl-ds KeySpecsDS qualified based(KeySpecsPtr);
        KeyFieldName char(10) pos(1);
        KeySequenBits char(1) pos(14);
       end-ds;
 
       // select/omit specification array
       dcl-ds SelectOmitSpec qualified based(SelectOmitSpecPtr);
        StatementRule char(1) pos(3);
        CompRelation char(2) pos(4);
        FieldName char(10) pos(6);
        NumberOfParms int(5) pos(16);
        OffsToParms int(10) pos(29);
       end-ds;
 
       // select/omit parameters
       dcl-ds SelectOmitParm qualified based(SelectOmitParmPtr);
        OffsToNext int(10) pos(1);
        ParmLength int(5) pos(5);
        ParmValue char(30) pos(21);
       end-ds;
 
       // Logical file specific attributes
       dcl-ds LfSpecific len(48) qualified based(lfSpecificPtr);
        JoinOffset int(10) pos(1);
        AttrBits char(1) pos(31);
       end-ds;
 
       // join specifications linked list
       dcl-ds JoinSpecDS len(48) qualified based(JoinSpecPtr);
        NextLink int(10) pos(1);
        NumJFlds int(5) pos(9);
        JoinFileNum int(5) pos(13);
        OffsToJSA int(10) pos(41);
       end-ds;
 
       // join specification array  (JSA)
       dcl-ds JoinSpecArryDS len(48) qualified based(JoinSpecArryPtr);
        FromField char(10) pos(1);
        FromNumber int(5) pos(11);
        ToField char(10) pos(17);
        ToNumber int(5) pos(27);
       end-ds;
 
       // physical file attributes
       dcl-ds PfAttrDS based(PfAttrPtr) qualified;
        OffsTriggers int(10) pos(25);
        NumOfTriggers int(5) pos(29);
       end-ds;
 
       // trigger information array
       dcl-ds TriggerDS based(TriggerPtr) qualified;
        TTime char(1) pos(1);
        TEvent char(1) pos(2);
        TPrgNam char(10) pos(3);
        TPrgLib char(10) pos(13);
       end-ds;
 
       // file header for fild0200 format
       dcl-ds fild0200DS len(3000) qualified inz;
        BytesReturned int(10);
        BytesAvail int(10);
        LevelID char(13) pos(81);
       end-ds;
 
       //---------------------------------------------------------
       // size of memory to allocate for QDBRTVFD call
       dcl-pr f_GetAllocatedSize int(10);  // memory size
        *n char(20) const;  // qualified file name
        *n char(10) const;  // record format name
       end-pr;
 
       dcl-s AllocatedSize int(10);
 
       /endif
       /If defined(Qeccvtec)
       //---------------------------------------------------------
       // Convert Edit Code to Edit Mask
       dcl-pr Qeccvtec extpgm('QECCVTEC');
        *n char(256);  // receiver
        *n int(10);  // mask length
        *n int(10);  // receiver length
        *n char(1) const;  // 0 balance file
        *n char(1) const;  // edit code
        *n char(1) const;  // blank fill
        *n int(10) const;  // field length
        *n int(10) const;  // decimal location
        *n like(ApiErrDS);
       end-pr;
       /endif
       /If defined(Qecedt)
       //---------------------------------------------------------
       // Apply Edit Mask
       dcl-pr Qecedt extpgm('QECEDT');
        *n char(256);
        *n int(10);
        /if defined(QecedtAlpha)
        *n char(256);  // to be edited alpha
        /else
        *n packed(30:9); // to be edited numeric
        /endif
        *n char(10) const; // type
        *n int(10) const; // field length
        *n char(256); // edit mask
        *n int(10);  // mask length
        *n char(1) const; // 0 balance file
        *n like(ApiErrDS);
       end-pr;
       /endif
       /If defined(Qlgsort)
       //---------------------------------------------------------
       // Sort Api
       dcl-pr qlgsort extpgm('QLGSORT');
        *n char(1024) options(*varsize);  // sort ds
        *n char(20) dim(10);  // in buffer
        *n char(20) dim(10);  // out buffer
        *n int(10) const;  // length in buffer
        *n int(10) const;  // length out buffer
        *n like(ApiErrDS);
       end-pr;
 
       // QLGSORT Sort Control Block
       dcl-ds qlgSortDS len(1024) qualified inz;
        BlockLength int(10) pos(1);
        TypeRequest int(10) pos(5) inz(5);
        Reserved1 int(10) pos(9);
        Options int(10) pos(13);
        RecordLength int(10) pos(17);
        RecordCount int(10) pos(21);
        OffToKeyList int(10) pos(25) inz(80);
        NumOfKeys int(10) pos(29);
        OffNatLangInf int(10) pos(33);
        OffInpFileList int(10) pos(37);
        NumOfInpFiles int(10) pos(41);
        OffOutFileList int(10) pos(45);
        NumofOutFiles int(10) pos(49);
        KeyEntryLength int(10) pos(53) inz(16);
        SortSeqLength int(10) pos(57);
        LenInFileEntry int(10) pos(61);
        LenOutFileEntry int(10) pos(65);
        OffToNullMap int(10) pos(69);
        OffToVarRecInf int(10) pos(73);
        Reserved2 int(10) pos(77);
       end-ds;
 
       dcl-pr f_AddSortKey char(16);
        *n int(10) const; // start pos
        *n int(10) const; // string size
        *n int(10) const options(*nopass); // data type
        *n int(10) const options(*nopass); // sort order
       end-pr;
       /endif
       /If defined(Qmhqrdqd)
       //---------------------------------------------------------
       // Retrieve Data Queue Description
       dcl-pr Qmhqrdqd extpgm('QMHQRDQD');
        *n like(QmhqrdqdDS); // receiver
        *n int(10) const; // receiver length
        *n char(8) const; // api format
        *n char(20); // data queue and lib name
       end-pr;
 
       dcl-ds QmhqrdqdDS qualified inz;
        MsgLength int(10) pos(9);
        KeyLength int(10) pos(13);
        Sequence char(1) pos(17);
        SenderID char(1) pos(18);
        Text char(50) pos(20);
        LocalOrDDM char(1) pos(70);
        EntryCount int(10) pos(73);
        CurrAllocated int(10) pos(77);
        DtaqName char(10) pos(81);
        DtaqLib char(10) pos(91);
        MaxAllowed int(10) pos(101);
        CreateSize int(10) pos(109);
       end-ds;
       /endif
       /If defined(Qmhsndpm)
       //---------------------------------------------------------
       // Send Program Message
       dcl-pr Qmhsndpm extpgm('QMHSNDPM');
        *n char(7) const; // message id
        *n char(20) const; // file and lib
        *n char(75) const; // text
        *n int(10) const; // length
        *n char(10) const; // type
        *n char(10) const; // queue
        *n int(10) const; // stack entry
        *n char(4) const; // key
        *n like(ApiErrDS);
       end-pr;
       /endif
       /If defined(QsnGetCsrAdr)
       //---------------------------------------------------------
       // Get Cursor Address Row and Column
       dcl-pr QsnGetCsrAdr int(10) extproc(*dclcase);
        *n int(10) const; // row
        *n int(10) const; // col
        *n int(10) const; // low level handle
        *n like(ApiErrDS);
       end-pr;
 
       dcl-s QsnCursorRow int(10);
       dcl-s QsnCursorCol int(10);
       /endif
       /If defined(Qspclosp)
       //---------------------------------------------------------
       // Close Spooled File
       dcl-pr Qspclosp extpgm('QSPCLOSP');
        *n int(10);  // splf handle
        *n like(ApiErrDS);
       end-pr;
       /endif
       /If defined(Qspgetsp)
       //---------------------------------------------------------
       // Get Spooled File Data
       dcl-pr Qspgetsp extpgm('QSPGETSP');
        *n int(10);  // splf handle
        *n char(20);  // user space
        *n char(8) const;  // api format
        *n int(10);  // ordinal number
        *n char(10) const;  // end of open
        *n like(ApiErrDS);
       end-pr;
       /endif
       /If defined(Qspopnsp)
       //---------------------------------------------------------
       // Open Spooled File
       dcl-pr Qspopnsp extpgm('QSPOPNSP');
        *n int(10);  // splf handle
        *n char(26) const;  // qualified job
        *n char(16);  // internal job id
        *n char(16);  // internal spool num
        *n char(10) const;  // spool file name
        *n int(10) const;  // spool file num
        *n int(10) const;  // number of buffers
        *n like(ApiErrDS);
       end-pr;
       /endif
       /If defined(Quscmdln)
       //---------------------------------------------------------
       // Display Command Line Window
       dcl-pr Quscmdln extpgm('QUSCMDLN') end-pr;
       /endif
       /If defined(ListAuthorizedUsers)
       //---------------------------------------------------------
       // List Authorized Users
       dcl-pr qsylautu extpgm('QSYLAUTU');
        *n char(20);  // user space
        *n char(8) const;  // format
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds Autu0200DS based(Autu0200ptr);
        UsrPrf char(10) pos(1);
        UsrPrfTxt char(50) pos(21);
       end-ds;
 
       // Retrieve User Information
       dcl-pr qsyrusri extpgm('QSYRUSRI');
        *n char(309);  // user profile info
        *n int(10) const;  // receiver len
        *n char(8) const;  // format
        *n char(10);  // user profile
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds Usri0300DS qualified inz;
        PrvSignDatTim char(13) pos(19);
        Status char(10) pos(37);
        UserClass char(7) pos(74);
        SpecialAuth char(15) pos(84);
        AllObj char(1) overlay(SpecialAuth:1);
        Secadm char(1) overlay(SpecialAuth:2);
        JobCtl char(1) overlay(SpecialAuth:3);
        SplCtl char(1) overlay(SpecialAuth:4);
        SavSys char(1) overlay(SpecialAuth:5);
        Service char(1) overlay(SpecialAuth:6);
        Audit char(1) overlay(SpecialAuth:7);
        IoSysCfg char(1) overlay(SpecialAuth:8);
        SpecialAuthArry char(1) overlay(SpecialAuth:1) dim(8);
        InitialPgm char(10) pos(169);
        InitialPgmL char(10) pos(179);
        Text char(50) pos(199);
        Jobd char(10) pos(290);
        JobdL char(10) pos(300);
        Outq char(10) pos(361);
        OutqL char(10) pos(371);
       end-ds;
       /endif
       /If defined(Quslfld)
       //---------------------------------------------------------
       // List Fields
       dcl-pr Quslfld extpgm('QUSLFLD');
        *n char(20);  // user space
        *n char(8) const;  // api format
        *n char(20) const;  // file and lib
        *n char(10) const;  // record format
        *n char(1) const;  // overrides
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds QuslfldDS qualified based(QuslfldPtr);
        FieldName char(10) pos(1);
        FieldType char(1) pos(11);
        OutputPosition int(10) pos(13);
        InputPosition int(10) pos(17);
        FieldLengthA int(10) pos(21);
        Digits int(10) pos(25);
        DecimalPos int(10) pos(29);
        FieldText char(50) pos(33);
        AliasName char(10) pos(223);
        FieldCCSID int(10) pos(273);
        ScreenFieldRow int(10) pos(449);
        ScreenFieldCol int(10) pos(453);
       end-ds;
       /endif
       /If defined(Quslmbr)
       //---------------------------------------------------------
       // List Database File Members
       dcl-pr Quslmbr extpgm('QUSLMBR');
        *n char(20);  // user space
        *n char(8) const;  // api format
        *n char(20) const;  // file and lib
        *n char(10) const;  // mbr
        *n char(1) const;  // override
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds QuslmbrDS qualified based(QuslmbrPtr);
        MbrName char(10) pos(1);
        MbrType char(10) pos(11);
        CreateDateTime char(13) pos(21);
        ChangeDateTime char(13) pos(34);
        Text char(50) pos(47);
       end-ds;
       /endif
       /If defined(Quslobj)
       //---------------------------------------------------------
       // List Objects
       dcl-pr Quslobj extpgm('QUSLOBJ');
        *n char(20);  // user space
        *n char(8) const;  // api format
        *n char(20) const;  // object and lib
        *n char(10) const;  // object type
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds QuslobjDS qualified based(QuslobjPtr);
        ObjNam char(10) pos(1);
        ObjLib char(10) pos(11);
        ObjTyp char(10) pos(21);
        ExtendedAttr char(10) pos(32);
        ObjText char(50) pos(42);
        CreateStamp char(8) pos(125);
        CreatedByUser char(10) pos(216);
        LastUseStamp char(8) pos(533);
        NumDaysUsed int(10) pos(549);
        ObjSize int(10) pos(577);
        MultiplySize int(10) pos(581);
       end-ds;
       /endif
       /If defined(Quslspl)
       //---------------------------------------------------------
       // List Spooled Files
       dcl-pr Quslspl extpgm('QUSLSPL');
        *n char(20);  // user space
        *n char(8) const;  // api format
        *n char(10) const;  // user profile
        *n char(20);  // outq and lib
        *n char(10) const;  // form type
        *n char(10) const;  // user data
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds QuslsplDS qualified based(QuslsplPtr);
        InternalJobID char(16) pos(51);
        InternalSplfID char(16) pos(67);
       end-ds;
 
       dcl-ds splf0300DS qualified based(splf0300Ptr);
        JobName char(10) pos(1);
        UserID char(10) pos(11);
        JobNo char(6) pos(21);
        SplfName char(10) pos(27);
        SplfNum int(10) pos(37);
        Status int(10) pos(41);
        CreateYYMMDD char(6) pos(46);
        CreateHHMMSS char(6) pos(52);
        UsrDta char(10) pos(69);
        FormType char(10) pos(79);
        Outq char(10) pos(89);
        OutqLib char(10) pos(99);
        ASP int(10) pos(109);
        SplfSize int(10) pos(113);
        MultiplySize int(10) pos(117);
        PageNum int(10) pos(121);
        Copies int(10) pos(125);
        Priority char(1) pos(129);
       end-ds;
       /endif
       /If defined(Qusptrus)
       //---------------------------------------------------------
       // Retrieve Pointer to User Space
       dcl-pr Qusptrus extpgm('QUSPTRUS');
        *n char(20);  // user space
        *n pointer;  // pointer
        *n like(ApiErrDS);
       end-pr;
       /endif
       /If defined(Qusrusat)
       //---------------------------------------------------------
       // Retrieve User Space Attributes
       dcl-pr Qusrusat extpgm('QUSRUSAT');
        *n like(QusrusatDS);  // receiver
        *n int(10) const;  // receiver length
        *n char(8) const;  // api format
        *n char(20);  // user space
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds QusrusatDS qualified inz;
        BytesReturned int(10) pos(1);
        BytesAvailable int(10) pos(5);
        SpaceSize int(10) pos(9);
        Extendability char(1) pos(13);
        InitialValue char(1) pos(14);
        SpaceLibrary char(10) pos(15);
       end-ds;
       /endif
       /If defined(f_ZipIFS)
       //---------------------------------------------------------
       // zip files on the IFS drive
       dcl-pr f_ZipIFS;
        *n char(10); // file
        *n char(10); // attribute
        *n char(50); // ifs path
       end-pr;
       /endif
       /If defined(Sds)
       //---------------------------------------------------------
       dcl-ds *n PSDS;
        progid char(10) pos(1);
       end-ds;
       /endif
       /If defined(BitMask)
       //---------------------------------------------------------
       dcl-c bit0 const(x'80');  // 10000000
       dcl-c bit1 const(x'40');  // 01000000
       dcl-c bit2 const(x'20');  // 00100000
       dcl-c bit3 const(x'10');  // 00010000
       dcl-c bit4 const(x'08');  // 00001000
       dcl-c bit5 const(x'04');  // 00000100
       dcl-c bit6 const(x'02');  // 00000010
       dcl-c bit7 const(x'01');  // 00000001
       /endif
       /If defined(SrcDS)
       //---------------------------------------------------------
       // Define fields from different spec types
       dcl-ds SrcDS qualified inz;
        SeqNum6 zoned(6: 2) pos(1);
        CompileArray char(3) pos(13);
        SpecType char(1) pos(18);
        Asterisk char(1) pos(19);
        SlashComment char(2) pos(19);
        FreeForm char(9) pos(19);
        Src80 char(74) pos(19);
        Src112 char(100) pos(13);
       // C specs
        Conditioning char(2) pos(22);
        Factor1 char(14) pos(24);
        OpCode char(10) pos(38);
        Factor2 char(14) pos(48);
        ExtendFactor2 char(45) pos(48);
        ResultField char(14) pos(62);
        ResultingInd char(6) pos(83);
        HIind char(2) overlay(ResultingInd:1);
        LOind char(2) overlay(ResultingInd:3);
        EQind char(2) overlay(ResultingInd:5);
        SrcComment char(20) pos(93);
       // 0 specs
        Commentln char(73) pos(20);
        oAndOr char(4) pos(28);
        oLineType char(1) pos(29);
        oIndicator char(9) pos(33);
        oSpaceB char(1) pos(54);
        oSpaceA char(1) pos(57);
        oSkipB char(2) pos(59);
        oSkipA char(2) pos(62);
        oEname char(14) pos(42);
        oEditCode char(1) pos(56);
        oEndPos char(5) pos(59);
        oEndPosN zoned(5) pos(59);
        oConstant char(28) pos(65);
        Src63 char(63) pos(13);
        UpperCase char(51) pos(13);
       // DDS specs
        ddsCondIn1 char(2) pos(21);
        ddsCondIn2 char(2) pos(24);
        ddsCondIn3 char(2) pos(27);
        ddsParenthesis char(1) pos(61);
        ddsField char(12) pos(57);
        ddsField2 char(2) pos(57);
        ddsField4 char(4) pos(57);
        ddsField5 char(5) pos(57);
        ddsField6 char(6) pos(57);
        ddsField7 char(7) pos(57);
        ddsField9 char(9) pos(57);
        ddsField10 char(10) pos(57);
       end-ds;
       /endif
       /If defined(OpenCloseDir)
       //---------------------------------------------------------
       dcl-s pDir pointer;
 
       dcl-pr opendir pointer extproc(*dclcase);
        *n pointer value options(*string);
       end-pr;
 
       dcl-pr closedir int(10) extproc(*dclcase);
        *n pointer value;
       end-pr;
 
       dcl-pr readdir pointer extproc(*dclcase);
        *n pointer value;
       end-pr;
 
       dcl-pr stat int(10) extproc(*dclcase);
        *n pointer value options(*string);
        *n pointer value;
       end-pr;
 
       dcl-pr tmpnam pointer extproc(*dclcase);
        *n pointer value;
       end-pr;
       /endif
       //---------------------------------------------------------
       /If defined(f_CheckDir)
       dcl-pr f_CheckDir;
        *n char(50);
       end-pr;
       /endif
       /If defined(f_CrtCmdString)
       //---------------------------------------------------------
       dcl-pr f_CrtCmdString varchar(500);
        *n char(20) const;  // cmd name and lib
       end-pr;
       /endif
       /If defined(f_BuildString)
       //---------------------------------------------------------
       dcl-pr f_BuildString varchar(2048);
        *n varchar(2048) const;
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
        *n varchar(100) const options(*nopass:*trim);
       end-pr;
       /endif
       /If defined(f_CamelCase)
       //---------------------------------------------------------
       dcl-pr f_CamelCase char(50);
        *n char(50);
       end-pr;
       /endif
       /If defined(f_Centertext)
       //---------------------------------------------------------
       dcl-pr f_CenterText char(100) opdesc;
        *n char(100) const options(*varsize);
        *n uns(3) const options(*nopass);
       end-pr;
       /endif
       /If defined(f_CheckMbr)
       //---------------------------------------------------------
       dcl-pr f_CheckMbr;
        *n char(20) const; // file and lib
        *n char(10) const; // mbr
       end-pr;
       /endif
       /If defined(f_CheckObj)
       //---------------------------------------------------------
       // validate Object exists
       dcl-pr f_CheckObj;
        *n char(20) const;  // object and lib
        *n char(10) const;  // object type
       end-pr;
       /endif
       /If defined(f_GetDayName)
       //---------------------------------------------------------
       dcl-pr f_GetDayName char(9);
        *n date const options(*nopass);
       end-pr;
       /endif
       /If defined(f_DecodeApiTimeStamp)
       //---------------------------------------------------------
       dcl-pr f_DecodeApiTimeStamp char(16);
        *n char(8);
       end-pr;
 
       dcl-ds ApistampDS len(16) qualified inz;
        Century char(1) pos(1);  // 0=19  1=20
        MmDd char(4) pos(2);
        Yy char(2) pos(6);
        HhMmSs char(8) pos(8);
       end-ds;
       /endif
       /If defined(f_GetEmail)
       //---------------------------------------------------------
       dcl-pr f_GetEmail char(150);
        *n char(10) const options(*nopass);  // user profile
       end-pr;
       /endif
       /If defined(usleep)
       //---------------------------------------------------------
       // delay job up to 999999 milliseconds ~= 1 second
       dcl-pr usleep uns(10) extproc(*dclcase);
        *n uns(10) value;  // milliseconds
       end-pr;
 
       // delay job number of seconds
       dcl-pr sleep uns(10) extproc(*dclcase);
        *n uns(10) value; // seconds
       end-pr;
 
       /endif
       /If defined(f_DltOvr)
       //---------------------------------------------------------
       dcl-pr f_DltOvr;
        *n char(10) const;  // spooled file
       end-pr;
       /endif
       /If defined(f_DisplayLastSplf)
       //---------------------------------------------------------
       dcl-pr f_DisplayLastSplf;
        *n char(10) const; // program name
        *n char(8) const;  // * or *PRINT
       end-pr;
       /endif
       /If defined(f_RunOptionFile)
       //---------------------------------------------------------
       dcl-pr f_RunOptionFile;
        *n packed(1) const;  // option
        *n char(10) const;  // file
        *n char(10) const;  // lib
        *n char(10) const;  // record format
        *n char(10) const;  // member
        *n char(10); // program id
       end-pr;
       /endif
       /If defined(f_RunOptionJob)
       //---------------------------------------------------------
       dcl-pr f_RunOptionJob;
        *n packed(2);  // option
        *n char(10);  // job name
        *n char(10);  // User Name
        *n char(6);  // job number
        *n char(10);  // program id
       end-pr;
       /endif
       /If defined(f_RunOptionSplf)
       //---------------------------------------------------------
       dcl-pr f_RunOptionSplf;
        *n char(1);  // option
        *n char(10);  // spool file name
        *n char(6) const;  // spool file number
        *n char(10);  // job name
        *n char(10);  // User Name
        *n char(6);  // job number
        *n char(10);  // program id
       end-pr;
       /endif
       /If defined(f_BuildEditWord)
       //---------------------------------------------------------
       dcl-pr f_BuildEditWord char(28);
        *n char(28) const;
        *n char(1) const;  // date or time
       end-pr;
       /endif
       /If defined(f_GetCardFace)
       //---------------------------------------------------------
       dcl-pr f_GetCardFace char(2);
        *n uns(3);
       end-pr;
       /endif
       /If defined(f_GetCardColor)
       //---------------------------------------------------------
       dcl-pr f_GetCardColor char(1);
        *n char(1);
       end-pr;
       /endif
       /If defined(f_GetRowColumn)
       //---------------------------------------------------------
       dcl-pr f_GetRowColumn char(6);
        *n char(10) const; // field
        *n char(10); // file
        *n char(10); // lib
        *n char(10); // record format
       end-pr;
 
       dcl-ds CsrRowColDS;
        CsrRow zoned(3) inz;
        CsrCol zoned(3) inz;
       end-ds;
       /endif
       /If defined(f_GetApiISO)
       //---------------------------------------------------------
       dcl-pr f_GetApiISO char(10);  // return ISO from api
        *n char(13) const;
       end-pr;
       /endif
       /If defined(f_GetFileLevelID)
       //---------------------------------------------------------
       dcl-pr f_GetFileLevelID char(13);
        *n char(20) const;  // file    lib
        *n char(10) const options(*nopass);  // rcdfmt
       end-pr;
       /endif
       /If defined(f_GetFileUtil)
       //---------------------------------------------------------
       dcl-pr f_GetFileUtil char(6) end-pr;  // dbu or dfu or wrkdbf
       /endif
       /If defined(f_GetQual)
       //---------------------------------------------------------
       dcl-pr f_GetQual varchar(21);
        *n char(20) const;  // name and lib
       end-pr;
 
       dcl-s ExtIfile varchar(21);
       dcl-s ExtOFile varchar(21);
       /endif
       /If defined(f_GetRandom)
       //---------------------------------------------------------
       dcl-pr f_GetRandom uns(3);
        *n uns(3) const;  // upper limit value
       end-pr;
       /endif
       /If defined(f_GetApiHMS)
       //---------------------------------------------------------
       dcl-pr f_GetApiHMS char(8);  // from 13 digit api
        *n char(13);
       end-pr;
       /endif
       /If defined(f_IsSameMbr)
       //---------------------------------------------------------
       dcl-pr f_IsSameMbr ind;
        *n char(20) const;  // input file  lib
        *n char(10) const;  // input mbr
        *n char(20) const;  // output file  lib
        *n char(10) const;  // output mbr
       end-pr;
       /endif
       /If defined(f_IsValidMbr)
       //---------------------------------------------------------
       dcl-pr f_IsValidMbr ind;
        *n char(20) const;  // file    lib
        *n char(10) const options(*nopass);  // mbr
       end-pr;
       /endif
       /If defined(f_IsValidSrcType)
       //---------------------------------------------------------
       dcl-pr f_IsValidSrcType ind;
        *n char(20); // file and lib
        *n char(10) const; // mbr
        *n char(10) const; // mbr type 1
        *n char(10) const options(*nopass); // mbr type 2
        *n char(10) const options(*nopass); // mbr type 3
        *n char(10) const options(*nopass); // mbr type 4
       end-pr;
       /endif
       /If defined(f_IsValidObj)
       //---------------------------------------------------------
       dcl-pr f_IsValidObj ind;
        *n char(10) const; // object
        *n char(10) const; // library
        *n char(10) const; // object type
       end-pr;
       /endif
       /If defined(f_SrcFileAddPfm)
       //---------------------------------------------------------
       dcl-pr f_SrcFileAddPfm;
        *n char(20) const;  // new file qual
        *n char(10) const;  // new mbr
        *n char(8) const;  // mbr type
        *n char(50) const options(*nopass);  // mbr text
        *n char(20) const options(*nopass);  // org file qual
        *n char(10) const options(*nopass);  // org mbr
       end-pr;
       /endif
       /If defined(f_OutFileCrtDupObj)
       //---------------------------------------------------------
       dcl-pr f_OutFileCrtDupObj;
        *n char(20) const;  // out file and lib
        *n char(22) const;  // mbr options
        *n char(10) const;  // from object
       end-pr;
       /endif
       /If defined(f_OvrPrtf)
       //---------------------------------------------------------
       dcl-pr f_OvrPrtf;
        *n char(10) const;  // spooled file
        *n char(20) const;  // outq
        *n char(10) const;  // usrdta
       end-pr;
       /endif
       /If defined(f_PromptOverrideGetSource)
       //---------------------------------------------------------
       dcl-pr f_PromptOverrideGetSource char(5700);
        *n char(20);
       end-pr;
       /endif
       /If defined(f_Quscrtus)
       //---------------------------------------------------------
       dcl-pr f_Quscrtus pointer;
        *n char(20);  // user space name and library
       end-pr;
 
       // Get user space list info from header
       dcl-ds GenericHeader qualified template;
        JobScheduleEntry char(10) pos(10);
        ContinuationHandle char(16) pos(11);
        InformationStatus char(1) pos(104);  // P=Partail
        SizeOfUsrSpc int(10) pos(105);
        OffSetToHeader int(10) pos(117);
        OffSetToList int(10) pos(125);
        ListEntryCount int(10) pos(133);
        ListEntrySize int(10) pos(137);
       end-ds;
 
       // define 2 user space headers since needed in many programs
       dcl-ds ApiHead likeds(GenericHeader) based(ApiHeadPtr);
       dcl-ds ApiHead2 likeds(GenericHeader) based(ApiHeadPtr2);
       dcl-s UserSpaceName char(20) inz('JCRCMDS   QTEMP');
       dcl-s UserSpaceName2 char(20) inz('JCRCMDS2  QTEMP');
       dcl-s ForCount int(10);
       dcl-s ForCount2 int(10);
       /endif
       /If defined(f_Qmhrcvpm)
       //---------------------------------------------------------
       dcl-pr f_Qmhrcvpm char(75);  // receive program msg
        *n int(10) const;  // call stack counter
       end-pr;
       /endif
       /If defined(f_Qusrmbrd)
       //---------------------------------------------------------
       dcl-pr f_Qusrmbrd char(256);  // retrieve mbr desc
        *n char(20) const; // file and lib
        *n char(10) const; // mbr
        *n char(8) const; // api format
       end-pr;
 
       dcl-ds QusrmbrdDS len(256) qualified inz;
        File char(10) pos(9);
        Lib char(10) pos(19);
        Mbr char(10) pos(29);
        Attribute char(10) pos(39);
        MbrType char(10) pos(49);
        CreateDateTime char(13) pos(59);
        Text char(50) pos(85);
        IsSrcPF ind pos(135);
        CurrNumberRecs int(10) pos(141);
        DeletedRecs int(10) pos(145);
        SizeOfData int(10) pos(149);
        ChangeDateTime char(13) pos(161);
        SaveDateTime char(13) pos(174);
        LastUseCount int(10) pos(213);
        LastUseDateTime char(13) pos(217);
        SizeOfDataMLT int(10) pos(233);
       end-ds QusrmbrdDS;
 
       /endif
       /If defined(f_Qusrobjd)
       //---------------------------------------------------------
       dcl-pr f_Qusrobjd char(480);  // retrieve object desc
        *n char(20) const;  // object and lib
        *n char(10) const;  // oblect type
        *n char(8) const options(*nopass);  // api format
       end-pr;
 
       dcl-ds QusrObjDS qualified inz;
        ObjNam char(10) pos(9);
        Lib char(10) pos(19);
        Type char(10) pos(29);
        ReturnLib char(10) pos(39);
        ExtendedAttr char(10) pos(91);
        CreateDateTime char(13) pos(65);
        ChangeDateTime char(13) pos(78);
        Text char(50) pos(101);
        SrcFile char(10) pos(151);
        SrcLib char(10) pos(161);
        SrcMbr char(10) pos(171);
        SaveDateTime char(13) pos(194);
        RestoreDateTime char(13) pos(207);
        CreatedByUser char(10) pos(220);
        LastUsedDate char(7) pos(461);  // cyymmdd format
        NumDaysUsed int(10) pos(469);
        ObjSize int(10) pos(473);
        MultiplySize int(10) pos(477);
       end-ds;
       /endif
       /If defined(f_RmvSflMsg)
       //---------------------------------------------------------
       dcl-pr f_RmvSflMsg;
        *n char(10) const;  // program name
       end-pr;
       /endif
       /If defined(f_RtvMsgAPI)
       //---------------------------------------------------------
       dcl-pr f_RtvMsgAPI char(232);  // retrieve message api wrapper
        *n char(7) const; // message id
        *n char(112); // replace values
        *n char(20) const options(*nopass); // msg file qual
       end-pr;
       /endif
       /If defined(f_ShuffleDeck)
       //---------------------------------------------------------
       dcl-pr f_ShuffleDeck char(2) dim(52) end-pr;
       /endif
       /If defined(f_SndCompMsg)
       //---------------------------------------------------------
       dcl-pr f_SndCompMsg;  //send completion message
        *n char(75) const;
       end-pr;
       /endif
       /If defined(f_SndEscapeMsg)
       //---------------------------------------------------------
       dcl-pr f_SndEscapeMsg;  //send error message
        *n char(75) value;
       end-pr;
       /endif
       /If defined(f_SndSflMsg)
       //---------------------------------------------------------
       dcl-pr f_SndSflMsg;
        *n char(10) const; // program name
        *n char(75) const; // msg text
        *n char(7) const options(*nopass); // msg id
        *n char(10) const options(*nopass); // msg file
        *n char(10) const options(*nopass); // msg lib
       end-pr;
       /endif
       /If defined(f_SndStatMsg)
       //---------------------------------------------------------
       dcl-pr f_SndStatMsg;
        *n char(75) const;  // message text
       end-pr;
       /endif
       /If defined(f_RunCmd)
       //---------------------------------------------------------
       dcl-pr f_RunCmd; // run commands
        *n varchar(2048) const options(*trim);
       end-pr;
       /endif
       /If defined(f_BlankCommentsCL)
       //---------------------------------------------------------
       dcl-pr f_BlankCommentsCL char(100);
        *n char(100) const;
       end-pr;
       /endif
       /If defined(CEEDAYS)
       //---------------------------------------------------------
       // Convert Date to Lilian Format
        dcl-pr CEEDAYS extproc(*dclcase) opdesc;
         *n char(8) const;  // iso
         *n char(8) const;  // Picture
         *n int(10);        // lilian date
         *n char(12) const options(*omit);
        end-pr;
 
        dcl-s Pic char(8) inz('YYYYMMDD');
        dcl-s Lilian int(10);
       /endif
       /If defined(p_JCRBNDR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_ObjQual char(20);
        p_ObjTyp char(10);
        p_Output char(8);
        p_OutFileQual char(20);
        p_OutMbrOpt char(22);
       end-pi;
       /endif
       /If defined(p_JCRCALLR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_PgmQual char(20);
        p_SrcFil char(10);
        p_SrcLib char(10);
        p_SrcMbr char(10);
        p_Pgmatr char(10);
       end-pi;
       /endif
       /If defined(p_JCRFFDR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_FileQual char(20);
        p_RcdFmt char(10);
        p_UnPack char(4);
        p_Output char(8);
        p_OutFileQual char(20);
        p_OutMbrOpt char(22);
       end-pi;
       /endif
       /If defined(p_JCRFSETS)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_DtaFileQual char(20);
        p_SrcFiles char(398);
        p_LfSameLib char(4);
        p_Output char(8);
        p_OutFileQual char(20);
        p_OutMbrOpt char(22);
       end-pi;
       /endif
       /If defined(p_JCRSMLTRS)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_ScanStrings char(272);
        p_Case char(4);
        p_IfContains char(7);
        p_SrcFiles char(398);
        p_Listlvl char(6);
        p_ScanComment char(5);
        p_From packed(3);
        p_To packed(3);
        p_Output char(8);
        p_OutqQual char(20);
        p_OutFileQual char(20);
        p_OutMbrOpt char(22);
       end-pi;
       /endif
       /If defined(p_JCRGETFLDR)
       //---------------------------------------------------------
       dcl-pr p_JCRGETFLDR extpgm('JCRGETFLDR');
        *n char(20) const; // src file and lib
        *n char(10); // src mbr
        *n char(2); // severity
        *n packed(3); // parm count
       end-pr;
 
       dcl-s DiagSeverity char(2);
       /endif
       /If defined(p_JCRGETFILR)
       //--retrieve file names from source member-----------------
       dcl-pr p_JCRGETFILR extpgm('JCRGETFILR');
        *n char(10);
        *n char(20);
        *n like(FileCount);
        *n like(OnePerRcdFmt) dim(%elem(OnePerRcdFmt));
        *n like(FspecArry) dim(%elem(FspecArry));
        *n like(CommentArry) dim(%elem(CommentArry)); // 93-112 comments
        *n like(PrNameArry) dim(%elem(PrNameArry));
        *n like(DeleteArry) dim(%elem(DeleteArry));
       end-pr;
 
       dcl-s FileCount uns(5);
       dcl-s FspecArry char(512) dim(256);  // one element per file
       dcl-s CommentArry char(20) dim(256);
       dcl-s PrNameArry char(74) dim(256);  // JCRHFDR   1 to 1 with FspecArry
       dcl-s DeleteArry char(1) dim(256);   // JCRHFDR   1 to 1 with FspecArry
 
       dcl-ds OnePerRcdFmt dim(256) qualified;
        FileCount uns(5); // corresponds to fSpec and Comment index
        File char(10);
        FileExt char(10); // extfile(name)
        Lib char(10);
        Format char(10);
        FormatReName char(10);
        BasedOnPF char(10);
        Usage char(1);
        FileAddition char(1);
        Text char(50);
        ProcName char(74);
       end-ds;
       /endif
       /If defined(p_JCRGETCLPR)
       //---------------------------------------------------------
       dcl-pr p_JCRGETCLPR extpgm('JCRGETCLPR');
        *n char(20) const;  // src file and lib
        *n char(10);  // src mbr
        *n char(2);  // severity
       end-pr;
       /endif
       /If defined(p_JCRANZOR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_SrcMbr char(10);
        p_SrcFilQual char(20);
        p_ShowNames char(4);
        p_Output char(8);
       end-pi;
       /endif
       /If defined(p_JCRPRGENR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_InsertInMbr char(10);
        p_InsertFileQual char(20);
        p_PgmQual char(20);
        p_SrcFil char(10);
        p_SrcLib char(10);
        p_SrcMbr char(10);
        p_Pgmatr char(10);
       end-pi;
       /endif
       /If defined(p_JCRIFSCPYR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_IfsDir char(50);
       end-pi;
       /endif
       /If defined(p_JCRIFSMBRR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_SrcMbr char(10);
        p_SrcFile char(10);
        p_SrcLib char(10);
        p_SrcAttr char(10);
        p_IfsDir char(50);
        p_CreateZip char(4);
       end-pi;
       /endif
       /If defined(p_JCRIFSSAVR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_Savf char(10);
        p_Lib char(10);
        p_IfsDir char(50);
        p_CreateZip char(4);
       end-pi;
       /endif
       /If defined(p_JCRINDR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_SrcMbrs char(104);
       end-pi;
       /endif
       /If defined(p_JCRPRTFR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_RpgMbr char(10);
        p_RpgFileQual char(20);
        p_DDsMbr char(10);
        p_DDsFileQual char(20);
        p_RefFields char(4);
       end-pi;
       /endif
       /If defined(p_JCRLSRCR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_PgmQual char(20);
        p_Output char(8);
        p_OutFileQual char(20);
        p_OutMbrOpt char(22);
       end-pi;
       /endif
       /If defined(p_JCRRFLDR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_SrcMbr char(10);
        p_SrcFilQual char(20);
        p_Output char(8);
        p_OutFileQual char(20);
        p_OutMbrOpt char(22);
       end-pi;
       /endif
       /If defined(p_JCRNETFFR)
       //---------------------------------------------------------
       dcl-ds entlistds qualified template;
        Count uns(5);
        Arry char(10) dim(10);
       end-ds;
 
       dcl-ds entlistds2 qualified template;
        Count uns(5);
        MixedList char(118);
       end-ds;
 
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_Lib char(10);
        p_FileList likeds(entlistds);
        p_UsrList likeds(entlistds2);
       end-pi;
       /endif
       /If defined(p_JCRNETFMR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_FileQual char(20);
        p_UsrList char(120);
        p_MbrList char(242);
       end-pi;
       /endif
       /If defined(p_JCRPATTRR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_SrcMbr char(10);
        p_SrcFilQual char(20);
        p_CrtToLib char(10);
        p_LikePrtf char(20);
       end-pi;
       /endif
       /If defined(p_JCRRFILR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_SrcMbr char(10);
        p_SrcFilQual char(20);
       end-pi;
       /endif
       /If defined(p_JCRSPLFR)
 
        dcl-ds elemds template;
        Count uns(5);
        Usrprf char(10);
        UsrDta char(10);
        OutqQual char(20);
        SplfName char(10);
        Formtyp char(10);
        end-ds;
 
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p likeds(elemds);
       end-pi;
 
       /endif
       /If defined(p_JCRUFINDR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_ScanSpaces char(20);
        p_ScanString1 char(25);
        p_Relations char(4);
        p_ScanString2 char(25);
        p_Output char(8);
        p_OutFileQual char(20);
        p_OutMbrOpt char(22);
       end-pi;
       /endif
       /If defined(p_JCRPROTOR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_InMbr char(10);
        p_InFileQual char(20);
        p_OutMbr char(10);
        p_OutFileQual char(20);
       end-pi;
       /endif
       /If defined(p_JCRHFDR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_InMbr char(10);
        p_InFileQual char(20);
        p_OutMbr char(10);
        p_OutFileQual char(20);
       end-pi;
       /endif
       /If defined(p_JCRDDLR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_InFileQual char(20);
        p_ObjTyp char(10);
        p_OutMbr char(10);
        p_OutFileQual char(20);
       end-pi;
       /endif
       /If defined(p_JCR5FREER)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_InMbr char(10);
        p_InFileQual char(20);
        p_OutMbr char(10);
        p_OutFileQual char(20);
       end-pi;
       /endif
       /If defined(p_XMLGENR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_ScriptMbr char(10);
        p_ScriptQual char(20);
        p_OutFileQual char(20);
       end-pi;
       /endif
       /If defined(p_XMLSRCFILR)
       //--*entry-------------------------------------------------
       dcl-pi *n;
        p_InFileQual char(20);
        p_OutFileQual char(20);
       end-pi;
       /endif
       /If defined(f_IsIgnoreLine)
       //---------------------------------------------------------
       dcl-pr f_IsIgnoreLine ind;
        *n varchar(94);
       end-pr;
       /endif
       /If defined(f_ReturnZeroIfBetweenQuotes)
       //---------------------------------------------------------
       dcl-pr f_ReturnZeroIfBetweenQuotes uns(3);
        *n uns(3);
        *n varchar(94);
       end-pr;
       /endif
       /If defined(f_ReturnZeroIfAfterComments)
       //---------------------------------------------------------
       dcl-pr f_ReturnZeroIfAfterComments uns(3);
        *n uns(3);
        *n varchar(94);
       end-pr;
       /endif
       /If defined(f_CheckSameLineEnd)
       //---------------------------------------------------------
       dcl-pr f_CheckSameLineEnd char(10);
        *n char(10);
        *n varchar(94);
       end-pr;
       /endif
       /If defined(f_IsCompileTimeArray)
       //---------------------------------------------------------
       dcl-pr f_IsCompileTimeArray ind;
        *n char(3);
       end-pr;
       /endif
       /If defined(f_GetProcedureEntryPoint)
       //---------------------------------------------------------
       dcl-pr f_GetProcedureEntryPoint char(6);
        *n char(1);
        *n varchar(94);
       end-pr;
       /endif
       /If defined(f_GetParmFieldsArryIndex)
       //---------------------------------------------------------
       dcl-pr f_GetParmFieldsArryIndex uns(5);
        *n char(1);
        *n varchar(94);
       end-pr;
       /endif
       /If defined(f_GetDataTypeKeyWords)
       //---------------------------------------------------------
       dcl-pr f_GetDataTypeKeyWords char(16);
        *n char(1);
        *n uns(10);
        *n char(2);
        *n varchar(37) options(*nopass);
       end-pr;
       /endif
       /If defined(SourceOutDS)
       //---------------------------------------------------------
       dcl-ds OutDS qualified inz;
        SrcSeq zoned(6:2) pos(1) inz(0);
        SrcDate zoned(6) pos(7) inz(0);
        Src100 char(100) pos(13);
        SrcType char(1) pos(18);
        SrcCod char(74) pos(19);
        SrcCmt char(20) pos(93);
       end-ds;
       /endif
       /If defined(f_GetInternalProcNames)
       //---------------------------------------------------------
       dcl-pr f_GetInternalProcNames char(37002);
        *n char(10);
        *n char(20) const;
       end-pr;
       /endif
       /If defined(f_EllipsisLoc)
       //---------------------------------------------------------
       dcl-pr f_EllipsisLoc uns(3);
        *n char(74);
       end-pr;
       /endif
       /If defined(FspecDS)
       //---------------------------------------------------------
       dcl-ds FspecDS qualified;
        FixedFormat char(37) pos(1);
        Name char(10) pos(1);
        FileType char(1) pos(11);
        Designation char(1) pos(12);
        FileAddition char(1) pos(14);
        FixedOrExt char(1) pos(16);
        RecordLength char(5) pos(17);
        LengthOfKeyedField char(5) pos(23);
        RecordAddressType char(1) pos(28);
        Device char(7) pos(30);
        KeyWords char(2048) pos(38);
       end-ds;
       /endif
