       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRCMDSSRV - Service program for JCRCMDS
       //---------------------------------------------------------
       // f_AddSortKey - concatenate sort key blocks for qlgsort
       // f_BuildString - build string with replacement values
       // f_BlankCommentsCL - CL source is easier to process if comments are blanked
       // f_CamelCase - upper case first letter of each word or following / ( or &
       // f_CenterText - return centered text for any length parm
       // f_CheckDir - check if IFS directory exists
       // f_CheckMbr - check if mbr exists
       // f_CheckObj - check if object exists
       // f_CrtCmdString - return command creation parameters in a string
       // f_GetEmail - gets user email from directory entry
       // f_GetDayName - return day name
       // f_DecodeApiTimeStamp - accept API time stamp and return data structure
       // f_DltOvr - delete file overrides
       // f_DisplayLastSplf - displays last spooled file and send send spooled file message
       // f_BuildEditWord - return edit for date/time format printing
       // f_GetAllocatedSize - return size of memory to be allocated for QDBRTVFD call
       // f_GetCardFace - return A,K,Q,J,10 downto 1 for numeric values passed in
       // f_GetRowColumn - return csrrow and csrcol for passed in display file field
       // f_GetCardColor - return hex value for Color attribute
       // f_GetApiHMS - return HH:MM:SS from 13 digit API date/time
       // f_GetApiISO - return *ISO- date from 13 digit API date/time
       // f_GetFileLevelID - return file level identifier
       // f_GetFileUtil - return DBU, PEEK, WRKDBF, or STRDFU data base utility name
       // f_GetQual - return lib/obj for 20 long input
       // f_GetRandom - return random number within range
       // f_IsValidMbr - return *on if member exists in file
       // f_IsSameMbr - return *on input file/lib/mbr same as output file/lib/mbr
       // f_IsValidSrcType - return *on if member type is a selected type
       // f_IsValidObj - return *on if object exists
       // f_SrcFileAddPfm - addpfm to select lib/file
       // f_OutFileCrtDupObj - validity check / create OutFiles
       // f_OvrPrtf - override prtf with outq and/or usrdta
       // f_PromptOverrideGetSource - return cmd prompt override command string
       // f_Quscrtus - create user space in qtemp, return pointer to that space
       // f_Qusrmbrd - retrieve member description data structure
       // f_Qusrobjd - retrieve object description data structure
       // f_RmvSflMsg - remove message from errmsg subfile
       // f_RtvMsgAPI - retrieve message with substitution values loaded
       // f_RunCmd - execute command with error monitoring
       // f_RunOptionFile - execute subfile options related to files
       // f_RunOptionJob - execute subfile options related to jobs
       // f_RunOptionSplf - execute subfile options related to Spooled Files
       // f_Qmhrcvpm - receive program messages
       // f_ShuffleDeck - return randomly shuffled new deck of cards
       // f_SndCompMsg - send completion message
       // f_SndEscapeMsg - send error messages for validity checking programs
       // f_SndSflMsg - send message to error message subfile
       // f_SndStatMsg - send status message
       // f_ZipIFS - execute QzipZip to zip IFS files
       // -----------------
       // free format H,F,D functions
       // f_IsIgnoreLine - return *on if blank, comment or /define
       // f_GetProcedureEntryPoint
       // f_ReturnZeroIfAfterComments
       // f_ReturnZeroIfBetweenQuotes
       // f_GetParmFieldsArryIndex
       // f_GetDataTypeKeyWords
       // f_GetInternalProcNames
       // f_EllipsisLoc
       //---------------------------------------------------------
       ctl-opt nomain datfmt(*iso) timfmt(*iso) expropts(*resdecpos)
       option(*nounref: *nodebugio) bnddir('QSYS/QUSAPIBD')
       STGMDL(*TERASPACE);
 
       /define DspAtr
       /define Qdbrtvfd
       /define Qmhsndpm
       /define Quslfld
       /define Qusptrus
       /define f_Qusrmbrd
       /define f_Qusrobjd
       /define f_Quscrtus
       /define Constants
       /define OpenCloseDir
       /define CEEDAYS
       /define Qbnlpgmi
       /define Qclrpgmi
       /COPY JCRCMDS,JCRCMDSCPY
 
       //--global data structures --------------------------------
       dcl-ds ApiErrDS qualified export;
        BytesProvided int(10) pos(1) inz(%size(ApiErrDS));
        BytesReturned int(10) pos(5) inz(0);
        ErrMsgId char(7) pos(9);
        MsgReplaceVal char(112) pos(17);
       end-ds;
 
       // Several utilities use common array to pass field attributes
       dcl-s FieldsArryCnt uns(10) export;
       dcl-ds FieldsArry len(192) dim(5000) qualified export;
        Name char(100);
       end-ds;
 
       //---------------------------------------------------------
       // return character field with integer values for qlgsort key block.
       // If third and fourth parms are not passed, return character defaults.
       //---------------------------------------------------------
       dcl-proc f_AddSortKey export;
        dcl-pi *n char(16);
         p_StartPos int(10) const;
         p_StringSize int(10) const;
         p_DataType int(10) const options(*nopass);
         p_SortOrder int(10) const options(*nopass);
        end-pi;
 
        dcl-ds KeyBlock len(16) qualified;
         aa int(10);
         bb int(10);
         cc int(10);
         dd int(10);
        end-ds;
 
        KeyBlock.aa = p_StartPos;
        keyBlock.bb = p_StringSize;
 
 1b     if %parms >= %parmnum(p_DataType);
           KeyBlock.cc = p_DataType;
           KeyBlock.dd = p_SortOrder;
 1x     else;
           KeyBlock.cc = 6;
           KeyBlock.dd = 1;
 1e     endif;
        return KeyBlock;
       end-proc;
 
       //---------------------------------------------------------
       // CL source is easier to process if comments are blanked
       //---------------------------------------------------------
       dcl-proc f_BlankCommentsCL export;
        dcl-pi *n char(100);
         LineCL char(100) const;
        end-pi;
 
        dcl-s IsPreviousLineEndedinPlus ind static;
        dcl-s IsBlanked ind;
        dcl-s IsComment ind;
        dcl-s aa int(5);
        dcl-s bb int(5);
        dcl-s Wrka char(100);
 
        ApiErrDS.BytesReturned = 0;  //default error handler
        Wrka = LineCL;
 1b     Dou IsBlanked;
           IsComment = *off;
 2b        if IsPreviousLineEndedinPlus;
              aa = 1;
              IsComment = *on;
 2x        else;
             //---------------------------------------------------------
             // Rules for when comment actually starts in CL program
             // 1) if /* starts in 1st position of source
             // 2) if _/* is found (blank space preceding /*)
             // 3) if /*_ is found (/* followed by blank space)
             //---------------------------------------------------------
              aa = %scan('/*':Wrka);
 3b           if aa >0;
 4b              if aa = 1
                    or %subst(Wrka: aa-1:1) = ' '
                    or %subst(Wrka: aa+1:1) = ' ';
                    IsComment = *on;
 4e              endif;
 3e           endif;
 2e        endif;
 
          // after comment is started, it can end with */ or '+'
 2b        if not IsComment;
              IsPreviousLineEndedinPlus = *off;
              IsBlanked = *on;
 2x        else;
 
              bb = %scan('*/':Wrka);
 3b           if bb > 0;
                 IsComment = *off;
                 IsPreviousLineEndedinPlus = *off;
                 IsBlanked = *off;    // check for second comment on same line
 
                //  fix this scenario later */  /*   */
 4b              if (bb-aa) < -1;
                    IsBlanked = *on;
 1v                 leave;
 4e              endif;
 
                 %subst(Wrka: aa: (bb-aa) + 2) = *blanks;
 3x           else;
                 %subst(Wrka: aa) = *blanks;
                 IsPreviousLineEndedinPlus = *on;
                 IsBlanked = *on;
 3e           endif;
 2e        endif;
 1e     enddo;
 
        return Wrka;
       end-proc;
 
       //---------------------------------------------------------
       // return string with replacement values loaded from parms. Accepts base string with
       // replacement values noted by & sign then accepts parms to replace & characters.
       // Special value &q is arbitrarily used to signify single Quote. Check
       // ApiErrDs data structure if string was returned as error.
       //---------------------------------------------------------
       dcl-proc f_BuildString export;
        dcl-pi *n varchar(2048);
         pString varchar(2048) const;
         pParm01 varchar(100) const options(*nopass:*trim);
         pParm02 varchar(100) const options(*nopass:*trim);
         pParm03 varchar(100) const options(*nopass:*trim);
         pParm04 varchar(100) const options(*nopass:*trim);
         pParm05 varchar(100) const options(*nopass:*trim);
         pParm06 varchar(100) const options(*nopass:*trim);
         pParm07 varchar(100) const options(*nopass:*trim);
         pParm08 varchar(100) const options(*nopass:*trim);
         pParm09 varchar(100) const options(*nopass:*trim);
         pParm10 varchar(100) const options(*nopass:*trim);
         pParm11 varchar(100) const options(*nopass:*trim);
         pParm12 varchar(100) const options(*nopass:*trim);
         pParm13 varchar(100) const options(*nopass:*trim);
         pParm14 varchar(100) const options(*nopass:*trim);
         pParm15 varchar(100) const options(*nopass:*trim);
         pParm16 varchar(100) const options(*nopass:*trim);
         pParm17 varchar(100) const options(*nopass:*trim);
         pParm18 varchar(100) const options(*nopass:*trim);
         pParm19 varchar(100) const options(*nopass:*trim);
         pParm20 varchar(100) const options(*nopass:*trim);
         pParm21 varchar(100) const options(*nopass:*trim);
         pParm22 varchar(100) const options(*nopass:*trim);
         pParm23 varchar(100) const options(*nopass:*trim);
         pParm24 varchar(100) const options(*nopass:*trim);
         pParm25 varchar(100) const options(*nopass:*trim);
         pParm26 varchar(100) const options(*nopass:*trim);
         pParm27 varchar(100) const options(*nopass:*trim);
         pParm28 varchar(100) const options(*nopass:*trim);
         pParm29 varchar(100) const options(*nopass:*trim);
         pParm30 varchar(100) const options(*nopass:*trim);
        end-pi;
 
        dcl-s xx uns(3);
        dcl-s ReplaceCount uns(3);
        dcl-s cc uns(5);
        dcl-s string varchar(2048);
        dcl-s ParmArry varchar(100) dim(30);
        dcl-s parmlen uns(3);
 
        ApiErrDS.BytesReturned = 0;
        string = %trimr(pString);
 
       // replace any quote place holders with actual quotes
        string = %scanrpl('&q':qs: string);
        string = %scanrpl('&Q':qs: string);
 
       // Load replacement value parms into array
       // so it is easier to process in the next step
        ReplaceCount = %parms - 1;
 1b     if ReplaceCount >= 1;
           ParmArry(1) = pParm01;
 1e     endif;
 1b     if ReplaceCount >= 2;
           ParmArry(2) = pParm02;
 1e     endif;
 1b     if ReplaceCount >= 3;
           ParmArry(3) = pParm03;
 1e     endif;
 1b     if ReplaceCount >= 4;
           ParmArry(4) = pParm04;
 1e     endif;
 1b     if ReplaceCount >= 5;
           ParmArry(5) = pParm05;
 1e     endif;
 1b     if ReplaceCount >= 6;
           ParmArry(6) = pParm06;
 1e     endif;
 1b     if ReplaceCount >= 7;
           ParmArry(7) = pParm07;
 1e     endif;
 1b     if ReplaceCount >= 8;
           ParmArry(8) = pParm08;
 1e     endif;
 1b     if ReplaceCount >= 9;
           ParmArry(9) = pParm09;
 1e     endif;
 1b     if ReplaceCount >= 10;
           ParmArry(10) = pParm10;
 1e     endif;
 1b     if ReplaceCount >= 11;
           ParmArry(11) = pParm11;
 1e     endif;
 1b     if ReplaceCount >= 12;
           ParmArry(12) = pParm12;
 1e     endif;
 1b     if ReplaceCount >= 13;
           ParmArry(13) = pParm13;
 1e     endif;
 1b     if ReplaceCount >= 14;
           ParmArry(14) = pParm14;
 1e     endif;
 1b     if ReplaceCount >= 15;
           ParmArry(15) = pParm15;
 1e     endif;
 1b     if ReplaceCount >= 16;
           ParmArry(16) = pParm16;
 1e     endif;
 1b     if ReplaceCount >= 17;
           ParmArry(17) = pParm17;
 1e     endif;
 1b     if ReplaceCount >= 18;
           ParmArry(18) = pParm18;
 1e     endif;
 1b     if ReplaceCount >= 19;
           ParmArry(19) = pParm19;
 1e     endif;
 1b     if ReplaceCount >= 20;
           ParmArry(20) = pParm20;
 1e     endif;
 1b     if ReplaceCount >= 21;
           ParmArry(21) = pParm21;
 1e     endif;
 1b     if ReplaceCount >= 22;
           ParmArry(22) = pParm22;
 1e     endif;
 1b     if ReplaceCount >= 23;
           ParmArry(23) = pParm23;
 1e     endif;
 1b     if ReplaceCount >= 24;
           ParmArry(24) = pParm24;
 1e     endif;
 1b     if ReplaceCount >= 25;
           ParmArry(25) = pParm25;
 1e     endif;
 1b     if ReplaceCount >= 26;
           ParmArry(26) = pParm26;
 1e     endif;
 1b     if ReplaceCount >= 27;
           ParmArry(27) = pParm27;
 1e     endif;
 1b     if ReplaceCount >= 28;
           ParmArry(28) = pParm28;
 1e     endif;
 1b     if ReplaceCount >= 29;
           ParmArry(29) = pParm29;
 1e     endif;
 1b     if ReplaceCount = 30;
           ParmArry(30) = pParm30;
 1e     endif;
 
       //---------------------------------------------------------
       // Load all replacement values into string
       //---------------------------------------------------------
        cc = %scan('&': string);
 1b     for xx = 1 to ReplaceCount;
           parmlen = %len(ParmArry(xx));
 2b        if parmlen = 0;
              parmlen = 1;
              ParmArry(xx) = ' ';
 2e        endif;
           string=%replace(%subst(ParmArry(xx):1:ParmLen): string: cc: 1);
 
          // avoid cc being past length of varchar;
 2b        if xx <  ReplaceCount;
 3b           monitor;
                 cc = %scan('&': string: cc + ParmLen);
 3x           on-error;
                 string = 'Too many replacement values specified.';
 3v              leave;
 3e           endmon;
 2e        endif;
 1e     endfor;
 
        return string;
       end-proc;
 
       //----------------------------------------------------------
       // upper case first letter of each word or following / ( or &
       //---------------------------------------------------------
       dcl-proc f_CamelCase export;
        dcl-pi *n char(50);
         pstring char(50);
        end-pi;
 
        dcl-s string char(50);
        dcl-s nextcharptr pointer;
        dcl-s nextchar char(1) based(nextcharptr);
 
        dcl-s isfirst ind;
        dcl-s xx uns(3);
        string = pstring;
        nextcharptr = %addr(string) -1;
 
 1b     for xx = 1 to 50;
           nextcharptr += 1;
 
 2b        if nextchar = ' ' or
              nextchar = '(' or
              nextchar = '/' or
              nextchar = '-' or
              nextchar = '&';
              isfirst = *on;
 2e        endif;
 
 2b        if xx = 1 or isfirst;
 3b           if not (nextchar = ' ' or
                 nextchar = '(' or
                 nextchar = '/' or
                 nextchar = '-' or
                 nextchar = '&');
                 isfirst = *off;
                 nextchar = %xlate(lo:up:nextchar);
 3e           endif;
 2x        else;
              nextchar = %xlate(up:lo:nextchar);
 2e        endif;
 
 1e     endfor;
        return string;
       end-proc;
 
       //---------------------------------------------------------
       // return centered text for any length Parm < 101
       //---------------------------------------------------------
       dcl-proc f_CenterText export;
        dcl-pi *n char(100) opdesc;
         p_String char(100) const options(*varsize);
         p_Length uns(3) const options(*nopass);
        end-pi;
 
        dcl-s xx uns(3);
        dcl-s centerstring char(100);
 
       // Get length of parameters
        dcl-pr CEEGSI extproc(*dclcase);
         *n int(10) const;  // position
         *n int(10);  // data type
         *n int(10);  // parm length
         *n int(10);  // max length
         *n char(12) options(*omit); // feedback
        end-pr;
 
        dcl-s MaxLen int(10);
        dcl-s DataType int(10);
        dcl-s ParmLen int(10);
 
 1b     if %parms = %parmnum(p_Length);
           ParmLen = p_Length;
 1x     else;
           CEEGSI(1: DataType: ParmLen: MaxLen: *omit);
 1e     endif;
 
        xx = %uns((ParmLen -
        %len(%trimr(%subst(p_String: 1: ParmLen)))) /  2) + 1;
 
        %subst(centerstring: xx) = %subst(p_String: 1: ParmLen);
 
        return centerstring;
       end-proc;
 
       //---------------------------------------------------------
       // Send error messages for validity checking programs
       //---------------------------------------------------------
       dcl-proc f_SndEscapeMsg export;
        dcl-pi *n;
         p_MsgTxt char(75) value;
        end-pi;
 
        p_MsgTxt = '0000' + p_MsgTxt;
        callp QMHSNDPM(
              'CPD0006':
              'QCPFMSG   *LIBL':
              p_MsgTxt:
              %size(p_MsgTxt):
              '*DIAG':
              '*CTLBDY':
              1:
              ' ':
              ApiErrDS);
 
        p_MsgTxt = *blanks;
        callp QMHSNDPM(
              'CPF0002':
              'QCPFMSG   *LIBL':
              p_MsgTxt:
              %size(p_MsgTxt):
              '*ESCAPE':
              '*CTLBDY':
              1:
              ' ':
              ApiErrDS);
        return;
       end-proc;
 
       //---------------------------------------------------------
       // Check if IFS directory exists.
       //---------------------------------------------------------
       dcl-proc f_CheckDir export;
        dcl-pi *n;
         p_IfsDir char(50);
        end-pi;
 
        pDir = openDir(%trim(p_IfsDir));
 1b     if pDir = *null;
           f_SndEscapeMsg('Error found on OPEN DIRECTORY. Check path name.');
 1x     else;
           closeDir(pDir);
 1e     endif;
 
        return;
       end-proc;
 
       //---------------------------------------------------------
       // Retrieve error message replacement values
       //---------------------------------------------------------
       dcl-proc f_RtvMsgAPI export;
        dcl-pi *n char(232);
         p_ErrMsgID char(7) const;
         p_MsgReplace char(112);
         p_MsgFileQual char(20) const options(*nopass);
        end-pi;
 
        dcl-s mMsgf char(20);
        dcl-s mMsgLen int(10) inz(%len(qmhrtvmds));
 
        dcl-ds ApiErrDS qualified;
         BytesProvided int(10) pos(1) inz(%size(ApiErrDS));
         BytesReturned int(10) pos(5) inz(0);
         ErrMsgId char(7) pos(9);
         MsgReplaceVal char(112) pos(17);
        end-ds;
 
        dcl-ds QmhrtvmDS qualified inz;
         MessageRtvLen int(10) pos(9);
         MessageRtv char(232) pos(25);
        end-ds;
 
        dcl-pr Qmhrtvm extpgm('QMHRTVM');  // retrieve messages
         *n char(256);  // message retrieved
         *n int(10);  // length Of message
         *n char(8) const;  // api format
         *n char(7) const;  // message indentifier
         *n char(20) const;  // msgf and lib
         *n char(100) const;  // replacement data
         *n int(10) const;  // replace data length
         *n char(10) const;  // substitution char
         *n char(10) const;  // format control char
         *n like(ApiErrDS);
        end-pr;
 
 1b     if %parms = %parmnum(p_MsgFileQual);
           mMsgf = p_MsgFileQual;
 1x     else;
           mMsgf = 'QCPFMSG   *LIBL';
 2b        if %subst(p_ErrMsgID: 1: 2) = 'RN';
              mMsgf = 'QRPGLEMSG QDEVTOOLS';
 2e        endif;
 1e     endif;
 
       // need a way to analyze message field data
       // for now address specific problems as they occur.
       // CPF0201 Command not created uses &2 and &3, ignores &1
 1b     if p_ErrMsgid = 'CPF0201';
           p_MsgReplace = '  ' + p_MsgReplace;
 1e     endif;
 
       // pull in substitution variables
        callp QMHRTVM(
              QmhrtvmDS:
              mMsgLen:
              'RTVM0100':
              p_ErrMsgID:
              mMsgf:
              p_MsgReplace:
              %size(p_MsgReplace):
              '*YES':
              '*NO':
              ApiErrDS);
 
       // If too long, set length to size of return value
 1b     if QmhrtvmDS.MessageRtvLen > %size(QmhrtvmDS.MessageRtv);
           QmhrtvmDS.MessageRtvLen = %size(QmhrtvmDS.MessageRtv);
 1e     endif;
 
       // Only return populated message length
        return %subst(QmhrtvmDS.MessageRtv: 1: QmhrtvmDS.MessageRtvLen);
       end-proc;
 
       //---------------------------------------------------------
       // return member description
       //---------------------------------------------------------
       dcl-proc f_Qusrmbrd export;
        dcl-pi *n char(256);
         p_FileQual char(20) const;
         p_Mbr char(10) const;
         p_ApiFormat char(8) const;
        end-pi;
 
        dcl-pr Qusrmbrd extpgm('QUSRMBRD');  // retrieve mbr desc api
         *n char(256) options(*varsize);  // receiver
         *n int(10) const;  // receiver length
         *n char(8) const;  // api format
         *n char(20) const; // file and lib
         *n char(10) const; // mbr
         *n char(1) const;  // overrides
         *n like(ApiErrDS);
        end-pr;
 
        callp Qusrmbrd(
              QusrmbrdDS:
              256:
              p_ApiFormat:
              p_FileQual:
              p_Mbr:
              '0':
              ApiErrDS);
 
        return QusrmbrdDS;
       end-proc;
 
       //---------------------------------------------------------
       // Check if member exists. If not, pull in
       // substitution variables and send escape message
       //---------------------------------------------------------
       dcl-proc f_CheckMbr export;
        dcl-pi *n;
         p_FileQual char(20) const;
         p_Mbr char(10) const;
        end-pi;
 
        f_Qusrmbrd(p_FileQual: p_Mbr: 'MBRD0100');
 1b     if ApiErrDS.BytesReturned > 0;
           f_SndEscapeMsg(ApiErrDS.ErrMsgId +': ' +
           %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal)));
 1e     endif;
        return;
       end-proc;
 
       //---------------------------------------------------------
       // Execute Qusrobjd API, included in copy is DS to extract values.
       // If format not passed, default OBJD0200.
       //---------------------------------------------------------
       dcl-proc f_Qusrobjd export;
        dcl-pi *n char(480);
         p_ObjQual char(20) const;
         p_ObjTyp char(10) const;
         p_ApiFormat char(8) const options(*nopass);
        end-pi;
 
        dcl-s LocalApiFormat char(8);
 
        dcl-pr Qusrobjd extpgm('QUSROBJD');  // object description
         *n char(472) options(*varsize);  // receiver
         *n int(10) const;  // receiver length
         *n char(8) const;  // api format
         *n char(20) const;  // object and lib
         *n char(10) const;  // object type
         *n like(ApiErrDS);
        end-pr;
 
 1b     if %parms = %parmnum(p_ApiFormat);
           LocalApiFormat = p_ApiFormat;
 1x     else;
           LocalApiFormat = 'OBJD0200';
 1e     endif;
 
        callp QUSROBJD(
              QusrobjDS:
              %len(QusrobjDS):
              LocalApiFormat:
              p_ObjQual:
              p_ObjTyp:
              ApiErrDS);
 
        return QUSROBJDS;
       end-proc;
 
       //---------------------------------------------------------
       // Check if object exists.
       //---------------------------------------------------------
       dcl-proc f_CheckObj export;
        dcl-pi *n;
         p_ObjQual char(20) const;
         p_ObjTyp char(10) const;
        end-pi;
 
        f_QUSROBJD(p_ObjQual: p_ObjTyp: 'OBJD0100');
 1b     if ApiErrDS.BytesReturned > 0;
           f_SndEscapeMsg(ApiErrDS.ErrMsgId + ': ' +
           %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal)));
 1e     endif;
 
        return;
       end-proc;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       dcl-proc f_ReturnZeroIfBetweenQuotes export;
        dcl-pi *n uns(3);
         TestPos uns(3);
         string varchar(94);
        end-pi;
 
        dcl-s QuotePos1 uns(3);
        dcl-s QuotePos2 uns(3);
        dcl-s aa uns(3);
 
 1b     if TestPos = 0;
           return TestPos;
 1e     endif;
 
       // Find position of Quotes (if any)
        QuotePos2 = 0;
        QuotePos1 = %scan(qs: string);
 1b     if QuotePos1 > 0;
           QuotePos2 = %scan(qs: string: QuotePos1 + 1);
 
          //  also return 0 if quote then end continuation character
 2b        if not f_IsIgnoreLine(string);  // skip comments
              aa = %len(string);
 3b           if aa > 0;
 4b              if %subst(string: aa: 1) = '+'
                    or %subst(string: aa: 1) = '-';
                    QuotePos2 = aa;
 4e              endif;
 3e           endif;
 2e        endif;
 1e     endif;
 
 1b     if QuotePos2 > 0 and TestPos > QuotePos1 and TestPos < QuotePos2;
           return 0;
 1x     else;
           return TestPos;
 1e     endif;
       end-proc;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       dcl-proc f_ReturnZeroIfAfterComments export;
        dcl-pi *n uns(3);
         TestPos uns(3);
         string varchar(94);
        end-pi;
 
        dcl-s SlashSlash uns(3);
 
 1b     if TestPos = 0;
           return TestPos;
 1e     endif;
 
        SlashSlash = %scan(' //':string);
        SlashSlash = f_ReturnZeroIfBetweenQuotes(SlashSlash:String);
 1b     if SlashSlash = 0;
           SlashSlash = 100;
 1e     endif;
 
 1b     if SlashSlash < TestPos;
           return 0;
 1x     else;
           return TestPos;
 1e     endif;
       end-proc;
 
       //---------------------------------------------------------
       // check for END-on same line as DCL-(see entry spec of JCRGMBLJ)
       // the LIKEDS or LIKEREC does not need END-DS
       //---------------------------------------------------------
       dcl-proc f_CheckSameLineEnd export;
        dcl-pi *n char(10);
         Opcode char(10);
         string varchar(94);
        end-pi;
 
        dcl-s xx uns(3);
 
 1b     if Opcode = 'DCL-DS'
           or Opcode = 'DCL-PI'
           or Opcode = 'DCL-PR';
 
           xx = %scan('END-':string);
 2b        if xx > 0 and
              f_ReturnZeroIfBetweenQuotes(xx:String) > 0 and
              f_ReturnZeroIfAfterComments(xx:String) > 0;
              return *blanks;
 2e        endif;
 1e     endif;
 
       // the LIKEDS or LIKEREC do not need END-DS
 1b     if Opcode = 'DCL-DS';
           xx = %scan('LIKEDS':string);
 2b        if xx = 0;
              xx = %scan('LIKEREC':string);
 2e        endif;
 
 2b        if xx > 0 and
              f_ReturnZeroIfBetweenQuotes(xx:String) > 0 and
              f_ReturnZeroIfAfterComments(xx:String) > 0;
              return *blanks;
 2e        endif;
 1e     endif;
        return opcode;
       end-proc;
 
       //---------------------------------------------------------
       // return LIB/OBJ for 'OBJ       LIB     ' passed in
       //---------------------------------------------------------
       dcl-proc f_GetQual export;
        dcl-pi *n varchar(21);
         p_String char(20) const;
        end-pi;
 
        return %trimr(%subst(p_String: 11: 10)) + '/' +
        %trimr(%subst(p_String: 1: 10));
 
       end-proc;
 
       //---------------------------------------------------------
       // Build command string to create command.
       //---------------------------------------------------------
       dcl-proc f_CrtCmdString export;
        dcl-pi *n varchar(500);
         p_CmdQual char(20) const;
        end-pi;
 
        dcl-s string varchar(500);
        dcl-s LimitUser char(10) inz('YES');
 
        dcl-pr Qcdrcmdi extpgm('QCDRCMDI');  // command definitions
         *n like(qcdrcmdiDS);  // receiver
         *n int(10) const;  // receiver length
         *n char(8) const;  // api format
         *n char(20) const;  // file and lib
         *n like(ApiErrDS);
        end-pr;
 
       // extracted command definition fields
        dcl-ds qcdrcmdiDS len(400) qualified;
         Cmd char(10) pos(9);
         Cmdlib char(10) pos(19);
         Cpgm char(10) pos(29);
         Clib char(10) pos(39);
         Sfile char(10) pos(49);
         Slib char(10) pos(59);
         Smbr char(10) pos(69);
         Vpgm char(10) pos(79);
         Vlib char(10) pos(89);
         Mode char(3) pos(99);
         ModeProd char(1) pos(99);
         ModeDebug char(1) pos(100);
         ModeService char(1) pos(101);
         Alw char(9) pos(109);
         AlwBpgm char(1) pos(109);
         AlwIpgm char(1) pos(110);
         AlwExec char(1) pos(111);
         AlwInteract char(1) pos(112);
         AlwBatch char(1) pos(113);
         AlwBrexx char(1) pos(114);
         AlwIrexx char(1) pos(115);
         AlwBmod char(1) pos(116);
         AlwImod char(1) pos(117);
         Limit char(1) pos(124);
         Pmfil char(10) pos(129);
         Pmlib char(10) pos(139);
         Msfil char(10) pos(149);
         Mslib char(10) pos(159);
         Hlpnl char(10) pos(169);
         Hlib char(10) pos(179);
         Hlpid char(10) pos(189);
         Ovpgm char(10) pos(239);
         Ovlib char(10) pos(249);
         Text char(50) pos(265);
        end-ds;
 
       // Extract command definitions
        callp QCDRCMDI(
              qcdrcmdiDS:
              %size(qcdrcmdiDS):
              'CMDI0100':
              p_CmdQual:
              ApiErrDS);
 
 1b     if ApiErrDS.BytesReturned > 0;  //try with *libl
           callp QCDRCMDI(
                 qcdrcmdiDS:
                 %size(qcdrcmdiDS):
                 'CMDI0100':
                 %subst(p_CmdQual:1:10) + '*LIBL':
                 ApiErrDS);
 1e     endif;
 
 1b     if qcdrcmdiDS.LIMIT = '0';
           LimitUser = '*NO';
 1e     endif;
 
        string =
        %trimr(f_BuildString(
               '?CRTCMD ??CMD(&) ??PGM(&) ??SRCFILE(&) ??SRCMBR(&) +
               ??ALWLMTUSR(&) ??HLPID(&)':
               f_GetQual(qcdrcmdiDS.CMD + qcdrcmdiDS.CMDLIB):
               f_GetQual(qcdrcmdiDS.CPGM + qcdrcmdiDS.CLIB):
               f_GetQual(qcdrcmdiDS.SFILE + qcdrcmdiDS.SLIB):
               qcdrcmdiDS.SMBR: LimitUser: qcdrcmdiDS.HLPID));
 
       // Mode where allowed to run
        string += ' ??MODE(';
 1b     if qcdrcmdiDS.MODE = '111';
           string += '*ALL';
 1x     else;
 2b        if qcdrcmdiDS.ModePROD = '1';
              string += ' *PROD';
 2e        endif;
 2b        if qcdrcmdiDS.ModeDEBUG = '1';
              string += ' *DEBUG';
 2e        endif;
 2b        if qcdrcmdiDS.ModeSERVICE = '1';
              string += ' *SERVICE';
 2e        endif;
 1e     endif;
        string += ')';
 
        string += ' ??ALLOW(';
 1b     if qcdrcmdiDS.ALW = '111111111';
           string += '*ALL';
 1x     else;
 2b        if qcdrcmdiDS.AlwBPGM = '1';
              string += ' *BPGM';
 2e        endif;
 2b        if qcdrcmdiDS.AlwIPGM = '1';
              string += ' *IPGM';
 2e        endif;
 2b        if qcdrcmdiDS.AlwEXEC = '1';
              string += ' *EXEC';
 2e        endif;
 2b        if qcdrcmdiDS.AlwINTERACT = '1';
              string += ' *INTERACT';
 2e        endif;
 2b        if qcdrcmdiDS.AlwBATCH = '1';
              string += ' *BATCH';
 2e        endif;
 2b        if qcdrcmdiDS.AlwBREXX = '1';
              string += ' *BREXX';
 2e        endif;
 2b        if qcdrcmdiDS.AlwIREXX = '1';
              string += ' *IREXX';
 2e        endif;
 2b        if qcdrcmdiDS.AlwBMOD = '1';
              string += ' *BMOD';
 2e        endif;
 2b        if qcdrcmdiDS.AlwIMOD = '1';
              string += ' *IMOD';
 2e        endif;
 1e     endif;
        string += ')';
 
       //---------------------------------------------------------
 1b     if not(qcdrcmdiDS.VPGM = *blanks or qcdrcmdiDS.VPGM = '*NONE');
           string += ' ??VLDCKR(' +
           f_GetQual(qcdrcmdiDS.VPGM + qcdrcmdiDS.VLIB) + ')';
 1e     endif;
 
 1b     if not(qcdrcmdiDS.PMFIL = *blanks or qcdrcmdiDS.PMFIL = '*NONE');
           string += ' ??PMTFILE(' +
           f_GetQual(qcdrcmdiDS.PMFIL + qcdrcmdiDS.PMLIB) + ')';
 1e     endif;
 
 1b     if not(qcdrcmdiDS.HLPNL = *blanks or qcdrcmdiDS.HLPNL = '*NONE');
           string += ' ??HLPPNLGRP(' +
           f_GetQual(qcdrcmdiDS.HLPNL + qcdrcmdiDS.HLIB) + ')';
 1e     endif;
 
 1b     if not(qcdrcmdiDS.OVPGM = *blanks or qcdrcmdiDS.OVPGM = '*NONE');
           string += ' ??PMTOVRPGM(' +
           f_GetQual(qcdrcmdiDS.OVPGM + qcdrcmdiDS.OVLIB) + ')';
 1e     endif;
 
        string += ' ??TEXT(*SRCMBRTXT)';
        return string;
       end-proc;
 
       //---------------------------------------------------------
       // Accept API time stamp and return data structure
       //---------------------------------------------------------
       dcl-proc f_DecodeApiTimeStamp export;
        dcl-pi *n char(16);
         p_ApiStamp char(8);
        end-pi;
 
        dcl-pr Qwccvtdt extpgm('QWCCVTDT');  // api date converter
         *n char(10) const;  // from format
         *n char(8);  // api date stamp
         *n char(10) const;  // to format
         *n char(16);  // to date
         *n like(ApiErrDS);
        end-pr;
 
        dcl-s string char(16);
 
        callp QWCCVTDT(
              '*DTS':
              p_ApiStamp:
              '*MDY':
              string:
              ApiErrDS);
 
        return string;
       end-proc;
 
       //---------------------------------------------------------
       // Use complex process command as apierrds is consistent
       //  for use with f_RtvMsgApi. (ie can send formatted error messages).
       //   qcmdexec psds retrieves message with replacement values embedded.
       //---------------------------------------------------------
       dcl-proc f_RunCmd export;
        dcl-pi *n;
         p_String varchar(2048) const options(*trim);
        end-pi;
 
        dcl-s ChangedSource char(1);
        dcl-s ChangedLen int(10);
 
        dcl-pr QCAPCMD extpgm('QCAPCMD'); // Process Commands
         *n char(2048) const options(*varsize);
         *n int(10) const; // Length of source
         *n like(cpop0100ds); // Options block
         *n int(10) const; // Options block len
         *n char(8) const; // Options format
         *n char(1); // Changed command
         *n int(10) const; // Length available
         *n int(10); // Length of changed
         *n like(apierrds); // Error Parm
        end-pr;
 
        dcl-ds cpop0100DS qualified;
         *n int(10) pos(1) inz(0); // TypeProcess
         *n char(1) pos(5) inz('0'); // DBCShandling
         *n char(1) pos(6) inz('2'); // PrompterAct
         *n char(1) pos(7) inz('0'); // CmdSyntax
         *n char(4) pos(8) inz(x'00000000'); // MessageKey
         *n int(10) pos(12) inz(0); // job ccsid
         *n char(5) pos(16) inz(x'0000000000'); // reserved
        end-ds;
 
        callp QCAPCMD(
              p_string:
              %len(p_string):
              cpop0100DS:
              %len(cpop0100ds):
              'CPOP0100':
              ChangedSource:
              0:
              ChangedLen:
              ApiErrDS);
 
        return;
       end-proc;
 
       //---------------------------------------------------------
       // Send completion messages
       //---------------------------------------------------------
       dcl-proc f_SndCompMsg export;
        dcl-pi *n;
         p_MsgTxt char(75) const;
        end-pi;
 
        callp QMHSNDPM(
              ' ':
              ' ':
              p_MsgTxt:
              75:
              '*INFO':
              '*CTLBDY':
              1:
              ' ':
              ApiErrDS);
        return;
       end-proc;
 
       //---------------------------------------------------------
       // Display last spooled file and send completion message
       //---------------------------------------------------------
       dcl-proc f_DisplayLastSplf export;
        dcl-pi *n;
         p_ProgName char(10) const;
         p_OutPut char(8) const;
        end-pi;
 
       // Retrieve Identity of Last Spooled File Created
        dcl-pr QSPRILSP extpgm('QSPRILSP');
         *n like(LastSplfInfoDS);
         *n int(10) const;
         *n char(8) const;
         *n like(ApiErrDS);
        end-pr;
 
        dcl-ds LastSplfInfoDS len(70) qualified inz;
         SplfName char(10) pos(9);
         SplfNum int(10) pos(45);
        end-ds;
 
        callp QSPRILSP(
              LastSplfInfoDS:
              %len(LastSplfInfoDS):
              'SPRL0100':
              ApiErrDS);
 
 1b     if p_OutPut = '*';
           f_RunCmd('DSPSPLF FILE('+ LastSplfInfoDS.SplfName +
           ') SPLNBR(*LAST)');
 1e     endif;
 
        f_SndCompMsg(f_BuildString('Splf & number & generated by &.':
        LastSplfInfoDS.SplfName: %char(LastSplfInfoDS.SplfNum): p_ProgName));
        return;
       end-proc;
 
       //---------------------------------------------------------
       // Delete file overrides
       //---------------------------------------------------------
       dcl-proc f_DltOvr export;
        dcl-pi *n;
         p_SplfName char(10) const;
        end-pi;
 
        f_RunCmd('DLTOVR FILE(' + p_SplfName + ') LVL(*JOB)');
        return;
       end-proc;
 
       //---------------------------------------------------------
       // If member exists, return *on;
       //---------------------------------------------------------
       dcl-proc f_IsValidMbr export;
        dcl-pi *n ind;
         p_FileQual char(20) const;
         p_Mbr char(10) const options(*nopass);
        end-pi;
 
        dcl-s mbrVar char(10);
 
 1b     if %parms = %parmnum(p_Mbr);
           mbrVar = p_Mbr;
 1x     else;
           mbrVar = '*FIRST';
 1e     endif;
 
        QusrmbrdDS = f_Qusrmbrd(p_FileQual: mbrVar: 'MBRD0100');
        return (ApiErrDS.BytesReturned = 0);
       end-proc;
 
       //------------------------------------------------------------------
       // must check ... is not between ( ) as in inz('...')
       //------------------------------------------------------------------
       dcl-proc f_EllipsisLoc export;
        dcl-pi *n uns(3);
         string char(74);
        end-pi;
        dcl-s Dots uns(3);
 
       // ignore ... in the keywords section
 1b     if %len(%trimr(string)) > 35 and
           %subst(string:1:35) = *blanks;
           return 0;
 1e     endif;
 
        Dots = %scan('...':string);
 1b     If Dots > 0
           and %scan('(':string) > 0
           and Dots > %scan('(':string);
           return 0;
 1e     endif;
 
        return Dots;
       end-proc;
 
       //---------------------------------------------------------
       // return edit for date/time format printing
       //---------------------------------------------------------
       dcl-proc f_BuildEditWord export;
        dcl-pi *n char(28);
         p_String char(28) const;
         p_DateType char(1) const;
        end-pi;
 
        dcl-s string varchar(28);
 
 1b     if p_DateType = 'Z';
           return qs + '    -  -  -  .  .  .      ' + qs;
 
 1x     elseif p_DateType = 'T';
           string = %xlate(lo: up: p_String);
 
 2b        if string = 'TIMFMT(*USA)'
              or string = '*USA';
              return qs + '  .   XM' + qs;
 
 2x        elseif string = 'TIMFMT(*HMS)'
              or string = 'TIMFMT(*JIS)'
              or string = '*HMS'
              or string = '*JIS';
              return qs + '  :  :  ' + qs;
 
 2x        elseif string = 'TIMFMT(*ISO)'
              or string = 'TIMFMT(*EUR)'
              or string = '*ISO'
              or string = '*EUR';
              return qs + '  .  .  ' + qs;
 2x        else;
              return qs + '  :  :  ' + qs;
 2e        endif;
 
 1x     elseif p_DateType = 'L'
           or p_DateType = 'D';
           string = %xlate(lo: up: p_String);
 
 2b        if string = 'DATFMT(*MDY)'
              or string = 'DATFMT(*YMD)'
              or string = 'DATFMT(*DMY)'
              or string = '*MDY'
              or string = '*YMD'
              or string = '*DMY';
              return qs + '  /  /  ' + qs;
 
 2x        elseif string = 'DATFMT(*JUL)'
              or string = '*JUL';
              return qs + '  /    ' + qs;
 
 2x        elseif string = 'DATFMT(*ISO)'
              or string = 'DATFMT(*JIS)'
              or string = '*ISO'
              or string = '*JIS';
              return qs + '    -  -  ' + qs;
 
 2x        elseif string = 'DATFMT(*USA)'
              or string = '*USA'
              or string = '    ';
              return qs + '  /  /    ' + qs;
 
 2x        elseif string = 'DATFMT(*EUR)'
              or string = '*EUR';
              return qs + '  .  .    ' + qs;
 
             // if no hit return *ISO Default
 2x        else;
              return qs + '    -  -  ' + qs;
 2e        endif;
 1e     endif;
        return p_String;
       end-proc;
 
       //---------------------------------------------------------
       // return size of memory to allocate for QDBRTVFD call.
       // calling programs must check ApiErrDS.BytesReturned
       //---------------------------------------------------------
       dcl-proc f_GetAllocatedSize export;
        dcl-pi *n int(10);  // returned size of data
         p_FileQual char(20) const;
         p_RcdFmt char(10) const;
        end-pi;
 
        dcl-ds GetAllocSizeDS qualified;
         SizeReturned int(10) pos(5);
        end-ds;
 
        callp QDBRTVFD(
              GetAllocSizeDS:
              %len(GetAllocSizeDS):
              ReturnFileQual:
              'FILD0100':
              p_FileQual:
              p_RcdFmt:
              '0':
              '*FILETYPE':
              '*EXT':
              ApiErrDS);
 
 1b     if ApiErrDS.BytesReturned > 0;
           return 1;
 1x     else;
           return GetAllocSizeDS.SizeReturned;
 1e     endif;
       end-proc;
 
       //---------------------------------------------------------
       // return HH:MM:SS time from 13 digit API date/time
       //---------------------------------------------------------
       dcl-proc f_GetApiHMS export;
        dcl-pi *n char(8);
         p_DateTime char(13);
        end-pi;
 
 1b     if %subst(p_DateTime: 8: 1) = ' '
           or %subst(p_DateTime: 8: 1) = x'00';
           return '        ';
 1e     endif;
 
        return %subst(p_DateTime:  8: 2) + ':' +
        %subst(p_DateTime: 10: 2) + ':' +
        %subst(p_DateTime: 12: 2);
       end-proc;
 
       //---------------------------------------------------------
       // return *ISO- from 13 digit API date/time
       //---------------------------------------------------------
       dcl-proc f_GetApiISO export;
        dcl-pi *n char(10);
         p_DateTime char(13) const;
        end-pi;
 
        dcl-s century char(2);
 
 1b     if %subst(p_DateTime: 1: 1) = ' '
           or %subst(p_DateTime: 1: 1) = x'00';
           return '          ';
 1e     endif;
 
 1b     if %subst(p_DateTime: 1: 1) = '1';
           century = '20';
 1x     else;
           century = '19';
 1e     endif;
 
        return century +
        %subst(p_DateTime: 2: 2) + '-' +
        %subst(p_DateTime: 4: 2) + '-' +
        %subst(p_DateTime: 6: 2);
       end-proc;
 
       //---------------------------------------------------------
       // return card color attribute
       //---------------------------------------------------------
       dcl-proc f_GetCardColor export;
        dcl-pi *n char(1);  //hex value
         p_CardSuite char(1);  // H S C D
        end-pi;
 
 1b     if p_CardSuite = 'H';
           return %bitor(RED: RI);
 
 1x     elseif p_CardSuite = 'S';
           return %bitor(BLUE: RI);
 
 1x     elseif p_CardSuite = 'C';
           return %bitor(YELLOW: RI);
 
 1x     elseif p_CardSuite = 'D';
           return %bitor(WHITE: RI);
 1e     endif;
       end-proc;
 
       //---------------------------------------------------------
       // return A,K,Q,J,10 for numeric values
       //---------------------------------------------------------
       dcl-proc f_GetCardFace export;
        dcl-pi *n char(2);
         p_CardNumVal uns(3);
        end-pi;
 
 1b     if p_CardNumVal = 01;
           return 'A ';
 
 1x     elseif p_CardNumVal = 11;
           return 'J ';
 
 1x     elseif p_CardNumVal = 12;
           return 'Q ';
 
 1x     elseif p_CardNumVal = 13;
           return 'K ';
 
 1x     else;
           return %char(p_CardNumVal);
 1e     endif;
       end-proc;
 
       //---------------------------------------------------------
       // date, time, procptr and object class types may require a suffix
       //---------------------------------------------------------
       dcl-proc f_GetDataTypeKeyWords export;
        dcl-pi *n char(16);
         datatype char(1);
         length uns(10);
         decimals char(2);
         pSuffix varchar(37) options(*nopass);
        end-pi;
 
        dcl-s suffix varchar(37);
        dcl-s keyword char(20);
        keyword = *blanks;
 
 1b     if %parms = %parmnum(pSuffix);
           suffix = pSuffix;
 1e     endif;
 
       // these keywords do not need length
 1b     if datatype = 'D'   // date definition
           or datatype = 'L';  // file definition
           return 'date' + suffix + ';';
 
 1x     elseif datatype = 'N';
           return 'ind;';
 
 1x     elseif datatype = 'T';
           return 'time' + suffix + ';';
 
 1x     elseif datatype = 'Z';
           return 'timestamp;';
 
 1x     elseif datatype = '*';
           return 'pointer' + suffix + ';';
 
 1x     elseif datatype = 'O';
           return 'object' + suffix + ';';
 
 1x     elseif datatype = '7';
           return 'xml' + suffix + ';';
 
          // these keywords will have length and possible decimal positions
 1x     elseif datatype = 'A';
           keyword = 'char(';
 
 1x     elseif datatype = 'V';
           keyword = 'varchar(';
 
 1x     elseif datatype = 'B';
           keyword = 'bindec(';
 
 1x     elseif datatype = 'F';
           keyword = 'float(';
 
 1x     elseif datatype = 'G';
           keyword = 'graph(';
 
 1x     elseif datatype = 'I';
           keyword = 'int(';
 
 1x     elseif datatype = 'P';
           keyword = 'packed(';
 
 1x     elseif datatype = 'S';
           keyword = 'zoned(';
 
 1x     elseif datatype = 'U';
           keyword = 'uns(';
 
 1x     elseif datatype = 'C';
           keyword = 'ucs2(';
 
 1x     elseif datatype = '&';  // data structures return len() (see jcrhfdr)
           keyword = 'len(';
 
          // type HEX is in some IBM security audit journals
 1x     elseif datatype = 'H';
           keyword = 'hex(';
 1e     endif;
 
 1b     if decimals = '  ' or decimals = ' 0' or decimals = '00';
           KeyWord = %trimr(KeyWord) + %char(length) + ');';
 1x     else;
           KeyWord = %trimr(KeyWord) + %char(length) +
           ': ' + %trim(decimals) + ');';
 1e     endif;
 
        return keyword;
       end-proc;
 
       //---------------------------------------------------------
       // return right justified day name from date field. use today if no parm
       //---------------------------------------------------------
       dcl-proc f_GetDayName export;
        dcl-pi *n char(9);
         p_DateISO date(*ISO) const options(*NoPass);
        end-pi;
 
       // Calculate Day of Week from Lilian Date
        dcl-pr CEEDYWK  extproc(*dclcase);
         *n int(10);  // lilian date
         *n int(10);  // dow number
         *n char(12) const options(*omit);
        end-pr;
 
        dcl-s xx int(10);
        ApiErrDS.BytesReturned = 0;
 
       //----------------------------------------------
 1b     if %parms = %parmnum(p_DateISO);
           callp CEEDAYS(%char(p_DateISO: *iso0): Pic: Lilian: *OMIT);
 1x     else;
           callp CEEDAYS(%char(%date(): *iso0): Pic: Lilian: *OMIT);
 1e     endif;
 
        callp CEEDYWK(Lilian: xx: *OMIT);
 
 1b     if xx = 1;
           return '   Sunday';
 1x     elseif xx = 2;
           return '   Monday';
 1x     elseif xx = 3;
           return '  Tuesday';
 1x     elseif xx = 4;
           return 'Wednesday';
 1x     elseif xx = 5;
           return ' Thursday';
 1x     elseif xx = 6;
           return '   Friday';
 1x     elseif xx = 7;
           return ' Saturday';
 1x     else;
           ApiErrDS.BytesReturned = 20;
           ApiErrDS.ErrMsgId = 'CPD5118';
           ApiErrDS.MsgReplaceVal = *blanks;
           return 'Bad Date';
 1e     endif;
       end-proc;
 
      //---------------------------------------------------------
      // Search directory for email address
      //  returns *blank if user not exists.
      //  returns @ if user does not have email address (wrkdire)
      //---------------------------------------------------------
       dcl-proc f_GetEmail export;
        dcl-pi *n char(150);
         p_User char(10) const options(*nopass);
        end-pi;
 
        dcl-s xx uns(3);
        dcl-s curruser char(10) inz(*user);
        dcl-s smtpusrid varchar(64);
        dcl-s smtpdmn varchar(256);
 
        dcl-pr p_QOKSCHD extpgm('QOKSCHD');   // search directory
         *n like(srcv0100DS); // receiver
         *n int(10) const; // length
         *n char(8) const; // format name of receiver
         *n char(10) const; // function
         *n char(1) const; // keep temporary resource indicator
         *n like(sreq0100DS); // request variable
         *n int(10) const; // length
         *n char(8) const; // format name of request variable
         *n like(ApiErrDS);
        end-pr;
 
        dcl-ds sreq0100DS qualified inz; // search parameters
         *n int(10) pos(1);  // ccsid
         *n int(10) pos(5);  // character set of input
         *n int(10) pos(9);  // code page
         *n char(4) pos(13); // wild card
         *n char(1) pos(17) inz('0');  // convert data
         *n char(1) pos(18) inz('0');  // search data
         *n char(1) pos(19) inz('0');  // run verify
         *n char(1) pos(20) inz('0');  // continuation handle
         *n char(16) pos(21);          // resource handle
         *n char(8) pos(37) inz('SREQ0101'); // format name of search array
         *n int(10) pos(45) inz(110);        // offset to search array
         *n int(10) pos(49) inz(1);          // number elements to return
         *n char(8) pos(53) inz('SREQ0103'); // format of names to return
         *n int(10) pos(61) inz(100);        // offset to fields array to return
         *n int(10) pos(65) inz(1);          // number elements to return
         *n char(8) pos(69) inz('SRCV0101'); // format name array of users
         *n int(10) pos(77) inz(1);          // number users to return
         *n char(8) pos(81) inz('SRCV0111'); // format fields for users
         *n char(8) pos(89);                 // format order to return fields
         *n char(1) pos(97) inz('0');        // order specified
         *n char(3) pos(98);                 // reserved
         *n char(10) pos(101) inz('*SMTP');
         SearchRequestArry like(sreq0101ds);
        end-ds;
 
        dcl-ds sreq0101ds qualified inz;  // search request array
         *n int(10) pos(1) inz(%size(sreq0101ds)); // length of entry
         *n char(1) pos(5) inz('1');     // compare value
         *n char(10) pos(6) inz('USER'); // field
         *n char(7) pos(16) inz('*IBM'); // product ID
         *n char(1) pos(23) inz('0');    // not case senstive
         *n char(1) pos(24);             // reserved
         *n int(10) pos(25) inz(10);     // length of value
         ValueToMatch char(10) pos(29);
        end-ds;
 
        dcl-ds srcv0100DS len(5000) qualified inz;  // receiver
         OffsetToUsersArry int(10) pos(9);
         EntriesReturned int(10) pos(13);
        end-ds;
 
        dcl-ds srcv0101ds qualified based(srcv0101Ptr);
         NumFieldsReturned int(10) pos(5);
        end-ds;
 
        dcl-ds FieldDS qualified based(srcv0111Ptr);
         Name char(10) pos(1);
         Len int(10) pos(29);
         Value char(256) pos(33);
        end-ds;
 
 1b     if %parms = %parmnum(p_User);
           sreq0101ds.ValueToMatch = p_User;
 1x     else;
           sreq0101ds.ValueToMatch = curruser;
 1e     endif;
 
        sreq0100DS.SearchRequestArry = sreq0101ds;
 
        callp p_QOKSCHD(
              srcv0100DS:
              %size(srcv0100DS):
              'SRCV0100':
              '*SEARCH':
              '0':
              sreq0100DS:
              %size(sreq0100DS):
              'SREQ0100':
              ApiErrDS);
 
 1b     if ApiErrDS.BytesReturned > 0 or srcv0100DS.EntriesReturned = 0;
           return *blanks;
 1e     endif;
 
        srcv0101Ptr = %addr(srcv0100DS) + srcv0100DS.OffsetToUsersArry;
        srcv0111Ptr = srcv0101Ptr + %size(srcv0101DS);
 
 1b     for xx = 1 to srcv0101DS.NumFieldsReturned;
 
 2b        if FieldDS.Name = 'SMTPUSRID';
              smtpusrid = %subst(FieldDS.Value: 1: FieldDS.Len);
 2x        elseif FieldDS.Name = 'SMTPDMN';
              smtpdmn = %subst(FieldDS.Value: 1: FieldDS.Len);
 2e        endif;
 
           srcv0111Ptr += (FieldDS.Len + 32);  // next offset
 1e     endfor;
 
        return smtpusrid + '@' + smtpdmn;
       end-proc;
 
       //---------------------------------------------------------
       // If object exists return *on;
       //---------------------------------------------------------
       dcl-proc f_IsValidObj export;
        dcl-pi *n ind;
         p_ObjNam char(10) const;
         p_ObjLib char(10) const;
         p_ObjTyp char(10) const;
        end-pi;
 
        f_QUSROBJD(p_ObjNam + p_ObjLib: p_ObjTyp: 'OBJD0100');
        return (ApiErrDS.BytesReturned = 0);
       end-proc;
 
       //---------------------------------------------------------
       // return name of data base utility installed.
       // thanks to Peter Lee for adding Thomas Raddaz PEEK command
       //---------------------------------------------------------
       dcl-proc f_GetFileUtil export;
        dcl-pi *n char(6) end-pi;
 
 1b     if f_IsValidObj('DBU': '*LIBL': '*CMD');
           return 'DBU';
 1x     elseif f_IsValidObj('PEEK': '*LIBL': '*CMD');
           return 'PEEK';
 1x     elseif f_IsValidObj('WRKDBF': '*LIBL': '*CMD');
           return 'WRKDBF';
 1x     else;
           return 'STRDFU';
 1e     endif;
 
       end-proc;
 
       //---------------------------------------------------------
       // return *on if compile array is found at source line
       //---------------------------------------------------------
       dcl-proc f_IsCompileTimeArray export;
        dcl-pi *n ind;
         SrcPos13 char(3);
        end-pi;
 
 1b     if SrcPos13 = '** '
           or SrcPos13 = '**C'
           or SrcPos13 = '**c';
           return *on;
 1e     endif;
        return *off;
       end-proc;
 
       //---------------------------------------------------------
       // return *on if comment line in source
       //---------------------------------------------------------
       dcl-proc f_IsIgnoreLine export;
        dcl-pi *n ind;
         string varchar(94);
        end-pi;
        dcl-s FirstChar uns(3);
        dcl-s SlashSlash uns(3);
 
 1b     if %len(string) = 0;  // blank line
           return *on;
 
 1x     elseif %subst(string:1:1) = '*' or %subst(string:1:1) = '/';
           return *on;
 
 1x     else;
           SlashSlash = %scan('//': string);
           FirstChar = %check (' ': string);
 2b        if SlashSlash = FirstChar;
              return *on;
 2e        endif;
 1e     endif;
 
        return *off;
       end-proc;
 
       //---------------------------------------------------------
       // return list of procedures local to the source member
       //---------------------------------------------------------
       dcl-proc f_GetInternalProcNames export;
        dcl-pi *n like(ProcNamesDS);
         p_SrcMbr char(10);
         p_SrcFilQual char(20);
        end-pi;
 
        dcl-f InputSrc disk(112) extfile(extIfile) extmbr(p_SrcMbr) usropn;
        dcl-s extIfile char(21);
        dcl-s xx uns(3);
        dcl-s Dots uns(3);
        dcl-s string varchar(94);
        dcl-s IsExtract ind;
        dcl-s prname char(74);
 
        dcl-ds ProcNamesDS qualified;
         Cnt uns(5);
         Names char(74) dim(500);
        end-ds;
 
        dcl-ds InputDS len(112) qualified;
         CompileArry char(3) pos(13);
         SpecType char(1) pos(18);
         Src74 char(74) pos(19);
        end-ds;
 
        ProcNamesDS.Cnt = 0;
        ProcNamesDS.Names(*) = *blanks;
        extIfile = f_GetQual(p_SrcFilQual);
 
        open InputSrc;
        read InputSrc InputDS;
 1b     dow not %eof;
 
 2b        if not f_IsCompileTimeArray(InputDS.CompileArry);
              string = %trimr(InputDS.Src74);
 3b           if not f_IsIgnoreLine(string);
 
                 IsExtract = *off;
                 xx = %scan('DCL-PROC':%xlate(lo: up: string));
 4b              if (xx > 0 and
                    f_ReturnZeroIfBetweenQuotes(xx:String) > 0 and
                    f_ReturnZeroIfAfterComments(xx:String) > 0);
                    IsExtract = *on;
                    %subst(InputDS.Src74: xx: 8) = *blanks;
 4e              endif;
 
 4b              if InputDS.SpecType = 'P'
                    or InputDS.SpecType = 'p';
                    IsExtract = *on;
 4e              endif;
 
 4b              if IsExtract;
                    Dots = f_EllipsisLoc(InputDS.Src74);
 5b                 if Dots = 0;
                       prname = %triml(InputDS.Src74);
 
                       prname = %scanrpl(';':'': prname);
 
                      // drop any keywords after space in name
                       xx = %scan(' ':prname);
 6b                    if xx > 0;
                          %subst(prname:xx) = *blanks;
 6e                    endif;
 
 6b                    if prname = 'b'
                          or prname = 'B'
                          or prname = 'e'
                          or prname ='E';
                          prname = *blanks;
 6e                    endif;
 
 5x                 else;
                       prname = %trim(%subst(InputDS.Src74:1:Dots-1));
 5e                 endif;
 
 5b                 if prname > *blanks;
 6b                    if ProcNamesDS.Cnt = 0
                          or %lookup(prname:
                          ProcNamesDS.Names: 1: ProcNamesDS.Cnt) = 0;
 
                          ProcNamesDS.Cnt += 1;
                          ProcNamesDS.Names(ProcNamesDS.Cnt) = prname;
 
 6e                    endif;
 5e                 endif;
 4e              endif;
 3e           endif;
 2e        endif;
           read InputSrc InputDS;
 1e     enddo;
 
        close InputSrc;
        return ProcNamesDS;
       end-proc;
 
       //---------------------------------------------------------
       // extract parameter name, lookup in global fieldname array, return index
       // look for four possible scenarios
       //   C    PARM  fieldname
       //   D fieldname
       //     dcl-parm fieldname
       //     fieldname
       //---------------------------------------------------------
       dcl-proc f_GetParmFieldsArryIndex export;
        dcl-pi *n uns(5);
         spec char(1);
         string varchar(94);
        end-pi;
 
        dcl-s xx uns(3);
        dcl-s slen uns(3);
        dcl-s Index uns(5);
        dcl-s ParmField char(100);
 
        slen = %len(string); // keep the scans valid with varying field
       //----------------------------------------------------
       // C SPECS
       // either want 14 characters or to end of string
       //    parm   a           1 0
       //    parm   abc
       //----------------------------------------------------
 1b     if spec = 'C';
 2b        if slen >= 44 and %subst(string:20:5) = 'PARM ';
 3b           if slen >= 57;
                 ParmField = %subst(string:44:14);
 3x           else;
                 ParmField = %subst(string:44);
 3e           endif;
              exsr srGetIndex;
 2e        endif;
 
          //----------------------------------------------------
          // D SPECS slam to left and strip any ...
          // Dfieldname
          // D  fieldname
          // Dfieldname...
          // D fieldname...
          // D                      2a              // check for this
          //----------------------------------------------------
 1x     elseif spec = 'D';
 2b        if slen > 15 and %subst(string:1:15) = *blanks;
              return 0;
 2e        endif;
 
           ParmField = %triml(string);
           ParmField = %scanrpl('...':' ':ParmField);
           xx = %scan(' ':ParmField);
           %subst(ParmField:xx) = *blanks;
           exsr srGetIndex;
 
 1x     else;
          //----------------------------------------------------
          // dcl-parm fieldname;
          // dcl-parm fieldname char(10);
          //---------------------------------------------------------
           string = %scanrpl('DCL-PARM':' ':string);
           ParmField = %triml(string);
           xx = %scan(' ':ParmField);
           %subst(ParmField:xx) = *blanks;
           exsr srGetIndex;
 1e     endif;
 
        return 0;
 
        begsr srGetIndex;
        index = %lookup(ParmField: FieldsArry(*).Name: 1:
        FieldsArryCnt);
        return Index;
        endsr;
       end-proc;
 
       //---------------------------------------------------------
       // Determine PEP or Procedure Entry Point.
       //  Check for first procedure interface or *ENTRY .
       //---------------------------------------------------------
       dcl-proc f_GetProcedureEntryPoint export;
        dcl-pi *n char(6);
         spec char(1);
         string varchar(94);
        end-pi;
 
        dcl-s xx uns(3);
        dcl-s slen uns(3);
        dcl-s pOpCode char(10);
 
       //----------------------------------------------------
       // no *entry or procedure interface if an
       //  O or P spec or a DCL-PROC is found first
       //---------------------------------------------------------
 1b     if spec = 'O'
           or spec = 'P';
           return 'NO-PEP';
 1e     endif;
 
        xx = %scan('DCL-PROC':string);
 1b     if xx > 0 and
           f_ReturnZeroIfBetweenQuotes(xx:String) > 0 and
           f_ReturnZeroIfAfterComments(xx:String) > 0;
           return 'NO-PEP';
 1e     endif;
 
       //----------------------------------------------------
        slen = %len(string); // keep the scans valid with varying field
 
 1b     if spec = 'D'
           and slen >= 19
           and %subst(string:17:3) = ' PI';
           return 'DCL-PI';
 1e     endif;
 
 1b     if spec = 'C'
           and slen >= 14
           and %subst(string:6:8) = '*ENTRY';
           return '*ENTRY';
 1e     endif;
 
        xx = %scan('DCL-PI ':string);
 1b     if xx > 0 and
           f_ReturnZeroIfBetweenQuotes(xx:String) > 0 and
           f_ReturnZeroIfAfterComments(xx:String) > 0;
 
           pOpcode = 'DCL-PI';
 2b        if f_CheckSameLineEnd(pOpcode: string) = *blanks;
              return 'NO-PEP';
 2x        else;
              return 'DCL-PI';
 2e        endif;
 1e     endif;
 
        return ' ';
       end-proc;
 
       //---------------------------------------------------------
       // return value is random number between 1 and upper range
       // Api CEERAN0 was returning the same sequence on different days.
       //  instead use C rand function with seed Lilian date + millisecoonds
       //   no repeated sequences so far
       //---------------------------------------------------------
       dcl-proc f_GetRandom export;
        dcl-pi *n uns(3);
         p_UpperLimit uns(3) const;
        end-pi;
 
        dcl-pr rand int(10) extproc(*dclcase) end-pr;
 
        dcl-pr srand extproc(*dclcase);
         *n uns(10) value; // Seed
        end-pr;
 
        dcl-s onetime ind static inz(*on);
 
 1b     if onetime;
           callp CEEDAYS(%char(%date(): *iso0): pic :Lilian: *OMIT);
 
           SRand((Lilian * 1000) + (%subdt(%timestamp():*MS) / 1000));
           onetime = *off;
 1e     endif;
 
        return  %rem(Rand(): p_UpperLimit) + 1;
       end-proc;
 
       //---------------------------------------------------------
       // Create user space, change attributes to allow automatic extendibility,
       // returning pointer to user space.
       //---------------------------------------------------------
       dcl-proc f_Quscrtus export;
        dcl-pi *n pointer;
         p_UserSpace char(20);
        end-pi;
 
        dcl-s uPtr pointer;
        dcl-s ReturnLib char(10);
 
        dcl-pr Quscrtus extpgm('QUSCRTUS');  // create user space
         *n char(20);  // user space
         *n char(10) const;  // extended attribute
         *n int(10) const;  // length of space
         *n char(1) const;  // hex0 initialize
         *n char(10) const;  // use authority
         *n char(50) const;  // text
         *n char(10) const;  // replace object
         *n like(ApiErrDS);
         *n char(10) const;  // domain
         *n int(10) const;  // transfer size
         *n char(1) const;  // optimum space
        end-pr;
 
        dcl-pr Quscusat extpgm('QUSCUSAT');  // change space attribute
         *n char(10);  // return library
         *n char(20);  // user space
         *n like(QuscusatDS);  // key to change
         *n like(ApiErrDS);
        end-pr;
 
        dcl-ds QuscusatDS qualified;
         *n int(10) pos(1) inz(2); // number of records
         *n int(10) pos(5) inz(2); // key to set initial value
         *n int(10) pos(9) inz(1); // key length
         *n char(1) pos(13) inz(x'00'); // key data
         *n int(10) pos(14) inz(3); // key to set auto extend
         *n int(10) pos(18) inz(1); // key length
         *n char(1) pos(22) inz('1'); // key data
        end-ds;
 
        callp QUSCRTUS(
              p_UserSpace:
              'JCRCMDS':
              8192:
              x'00':
              '*ALL':
              'User Space JCRCMDS':
              '*NO':
              ApiErrDS:
              '*DEFAULT':
              32:
              '1');
 
        callp QUSCUSAT(
              ReturnLib:
              p_UserSpace:
              QuscusatDS:
              ApiErrDS);
 
        callp QUSPTRUS(
              p_UserSpace:
              uPtr:
              ApiErrDS);
 
        return uPtr;
       end-proc;
 
       //---------------------------------------------------------
       // Return DSPF field names row and columns
       //---------------------------------------------------------
       dcl-proc f_GetRowColumn export;
        dcl-pi *n char(6);
         p_FieldName char(10) const;
         p_File char(10);
         p_Lib char(10);
         p_RcdFmt char(10);
        end-pi;
 
        dcl-s UserSpaceName char(20) inz('JCRCMDSSRVQTEMP     ');
        dcl-s PreviousFile char(10) static;
        dcl-s PreviousLib char(10) static;
        dcl-s PreviousRcdFmt char(10) static;
 
        dcl-ds CsrRowColDS;
         CsrRow zoned(3);
         CsrCol zoned(3);
        end-ds;
 
 1b     if not(p_File = PreviousFile
           and p_Lib = PreviousLib
           and p_RcdFmt = PreviousRcdFmt);
           PreviousFile = p_File;
           PreviousLib = p_Lib;
           PreviousRcdFmt = p_RcdFmt;
 
           ApiHeadPtr = f_Quscrtus(UserSpaceName);
           callp QUSLFLD(
                 UserSpaceName:
                 'FLDL0100':
                 p_File + p_Lib:
                 p_RcdFmt:
                 '0':
                 ApiErrDS);
 1e     endif;
 
        QuslfldPtr = ApiHeadPtr + ApiHead.OffSetToList;
 
 1b     for ForCount = 1 to ApiHead.ListEntryCount;
 2b        if p_FieldName = QuslfldDS.FieldName;
              csrrow = QuslfldDS.ScreenFieldRow;
              csrcol = QuslfldDS.ScreenFieldCol;
 1v           leave;
 2e        endif;
           QuslfldPtr += ApiHead.ListEntrySize;
 1e     endfor;
 
        return CsrRowColDS;
       end-proc;
 
       //---------------------------------------------------------
       // return *on input file/lib/mbr same as output file/lib/mbr
       //---------------------------------------------------------
       dcl-proc f_IsSameMbr export;
        dcl-pi *n ind;
         p_InFileQual char(20);
         p_InMbr char(10);
         p_OutFileQual char(20);
         p_OutMbr char(10);
        end-pi;
 
        dcl-s InLib char(10);
 
 1b     if p_OutMbr = p_InMbr
           and %subst(p_OutFileQual: 1: 10) = %subst(p_InFileQual: 1: 10)
           and f_IsValidMbr(p_OutFileQual: p_OutMbr);
 
           QusrmbrdDS = f_Qusrmbrd(p_InFileQual: p_InMbr: 'MBRD0100');
           InLib = QusrmbrdDS.Lib;
 
           QusrmbrdDS = f_Qusrmbrd(p_OutFileQual: p_OutMbr: 'MBRD0100');
 2b        if QusrmbrdDS.Lib = InLib;
              return *on;
 2e        endif;
 1e     endif;
 
        return *off;
       end-proc;
 
       //---------------------------------------------------------
       // Validate extracted member type against (up to) 4 types passed in as parms. Must pass
       // in at least one type. Usually do not change function parameters, but in this
       // case all programs using this function benefit from having actual library
       // returned if library is '*LIBL'.
       //---------------------------------------------------------
       dcl-proc f_IsValidSrcType export;
        dcl-pi *n ind;
         p_FileQual char(20);
         p_Mbr char(10) const;
         p_Type1 char(10) const;
         p_Type2 char(10) const options(*nopass);
         p_Type3 char(10) const options(*nopass);
         p_Type4 char(10) const options(*nopass);
        end-pi;
 
        QusrmbrdDS.MbrType = *blanks;
        QusrmbrdDS = f_Qusrmbrd(p_FileQual: p_Mbr: 'MBRD0100');
 
 1b     if ApiErrDS.BytesReturned > 0;
           f_SndEscapeMsg(ApiErrDS.ErrMsgId + ': ' +
           %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal)));
 1e     endif;
 
 1b     if %subst(p_FileQual: 11: 10) = '*LIBL';
           %subst(p_FileQual: 11: 10) = QusrmbrdDS.Lib;
 1e     endif;
 
 1b     if QusrmbrdDS.MbrType = p_Type1
           or %parms >= %parmnum(p_Type2) and QusrmbrdDS.MbrType = p_Type2
           or %parms >= %parmnum(p_Type3) and QusrmbrdDS.MbrType = p_Type3
           or %parms  = %parmnum(p_Type4) and QusrmbrdDS.MbrType = p_Type4;
           return *on;
 1x     else;
           return *off;
 1e     endif;
       end-proc;
 
       //---------------------------------------------------------
       // Add member to existing file
       //---------------------------------------------------------
       dcl-proc f_SrcFileAddPfm export;
        dcl-pi *n;
         p_NewFileQual char(20) const;
         p_NewMbr char(10) const;
         p_MbrType char(8) const;
         p_MbrText char(50) const options(*nopass);
         p_OrgFileQual char(20) const options(*nopass);
         p_OrgMbr char(10) const options(*nopass);
        end-pi;
 
       // get original member text
 1b     if %parms = %parmnum(p_OrgMbr);
           QusrmbrdDS = f_Qusrmbrd(p_OrgFileQual: p_OrgMbr: 'MBRD0100');
           QusrmbrdDS.Text = %xlate(qd + qs + '<&%':'     ': QusrmbrdDS.Text);
 1x     else;
           QusrmbrdDS.Text = %xlate(qd + qs + '<&%':'     ': p_MbrText);
           QusrmbrdDS.MbrType = p_MbrType;
 1e     endif;
 
       // If out member does not exists, create one
 1b     if not f_IsValidMbr(p_NewFileQual: p_NewMbr);
 
           f_RunCmd(f_BuildString('ADDPFM FILE(&) MBR(&) +
           SRCTYPE(&) TEXT(&q&&q)':
           f_GetQual(p_NewFileQual):
           p_NewMbr:
           QusrmbrdDS.MbrType:
           QusrmbrdDS.Text));
 1x     else;
 
           f_RunCmd(f_BuildString(
           'CHGPFM FILE(&) MBR(&) SRCTYPE(&) TEXT(&q&&q)':
           f_GetQual(p_NewFileQual):
           p_NewMbr:
           QusrmbrdDS.MbrType:
           QusrmbrdDS.Text));
           f_RunCmd(f_BuildString('CLRPFM  FILE(&) MBR(&)':
           f_GetQual(p_NewFileQual):p_NewMbr));
 1e     endif;
        return;
       end-proc;
 
       //---------------------------------------------------------
       //---------------------------------------------------------
       dcl-proc f_GetFileLevelID export;
        dcl-pi *n char(13);
         p_FileQual char(20) const;
         p_RcdFmt char(10) const options(*nopass);
        end-pi;
 
        dcl-s RcdFmt char(10);
 
 1b     if %parms = %parmnum(p_RcdFmt);
           RcdFmt = p_RcdFmt;
 1x     else;
           RcdFmt = '*FIRST';
 1e     endif;
 
        callp QDBRTVFD(
              fild0200DS:
              %len(fild0200DS):
              ReturnFileQual:
              'FILD0200':
              p_FileQual:
              RcdFmt:
              '0':
              '*FILETYPE':
              '*EXT':
              ApiErrDS);
 
 1b     if ApiErrDS.BytesReturned > 0;
           f_SndEscapeMsg(ApiErrDS.ErrMsgId + ': ' +
           %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal)));
 1e     endif;
 
        return fild0200DS.LevelID;
       end-proc;
 
       //---------------------------------------------------------
       // Validity check / create OutFile
       //---------------------------------------------------------
       dcl-proc f_OutFileCrtDupObj export;
        dcl-pi *n;
         p_FileQual char(20) const;
         p_MbrOpt char(22) const;
         p_FromObj char(10) const;
        end-pi;
 
        dcl-s RealMbr char(10);
 
        dcl-ds OutFileDS;
         OutFile char(10);
         OutLib char(10);
        end-ds;
 
        dcl-ds MbrOptDS;
         NumEntries int(5);
         OutMbr char(10);
         OutMbrOpt char(10);
        end-ds;
 
        OutFileDS = p_FileQual;
        MbrOptDS = p_MbrOpt;
        RealMbr = OutMbr;
 1b     if OutFile = *blanks;
           f_SndEscapeMsg('Must select OutFile name');
 1e     endif;
 
       // cannot use JCRCMDS from-object as OutFile
       // changed because JCRHFD needs to use jcrsmltf name
 1b     if OutFile = p_FromObj;
          // f_SndEscapeMsg('Select OutFile name other than ' +
          // %trimr(p_FromObj) + '.');
 1e     endif;
 
       //---------------------------------------------------------
 1b     if not(OutLib = '*LIBL'
           or OutLib = '*CURLIB'
           or f_IsValidObj(OutLib: 'QSYS': '*LIB'));
 
           f_SndEscapeMsg(ApiErrDS.ErrMsgId + ': ' +
           %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal)));
 
 1e     endif;
 
       //---------------------------------------------------------
        ApiErrDS.ErrMsgId = *blanks;
        f_IsValidMbr(p_FileQual: OutMbr);
 
 1b     if ApiErrDS.ErrMsgId = 'CPF9812';
 2b        if OutLib = '*LIBL';
              f_SndEscapeMsg(ApiErrDS.ErrMsgId + ': ' +
              %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal)));
 2x        else;
              f_RunCmd(
              f_BuildString('CRTDUPOBJ  OBJ(&) FROMLIB(*LIBL) +
              OBJTYPE(*FILE) TOLIB(&) NEWOBJ(&) +
              DATA(*NO) CST(*NO) TRG(*NO)':
              p_FromObj:
              OutLib:
              OutFile));
 
 3b           if ApiErrDS.BytesReturned > 0;
                 f_SndEscapeMsg(ApiErrDS.ErrMsgId +
                 ': Error occurred on CRTPF');
 3e           endif;
 
 
             // note ddl created files can not have all members removed
 3b           if OutMbr = '*FIRST';
                 RealMbr = OutFile;
 3e           endif;
 
              f_RunCmd(
              f_BuildString('RNMM  FILE(&/&) MBR(&) NEWMBR(&)':
              OutLib:
              OutFile:
              p_FromObj:
              RealMbr));
 2e        endif;
 
          // if File exists but member does not,
          // make sure member can be added to File.
 1x     elseif ApiErrDS.ErrMsgId = 'CPF9815';
           exsr srAddPfm;
 
 1x     elseif ApiErrDS.ErrMsgId > *blanks;
           f_SndEscapeMsg(ApiErrDS.ErrMsgId + ': ' +
           %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal)));
 1e     endif;
 
 1b     if OutMbrOpt = '*REPLACE';
           f_RunCmd(
           f_BuildString('CLRPFM  FILE(&/&) MBR(&)':
           OutLib:
           OutFile:
           RealMbr));
 1e     endif;
 
       // compare record format ID for level check issues
 1b     if not(f_GetFileLevelID(p_FromObj + '*LIBL')
               = f_GetFileLevelID(OutFile + OutLib));
 
           f_SndEscapeMsg(
           f_BuildString('CPF4131: Level check on file & in library &.':
           OutFile:
           OutLib));
 
 1e     endif;
        return;
 
       //---------------------------------------------------------
        begsr srAddPfm;
        ApiErrDS.ErrMsgId = *blanks;
        RealMbr = OutMbr;
 1b     if OutMbr = '*FIRST';
           RealMbr = OutFile;
 1e     endif;
        f_RunCmd(f_BuildString('ADDPFM &/& &':
        OutLib: OutFile: realMbr));
 1b     if (ApiErrDS.ErrMsgId = 'CPF7306');
           f_SndEscapeMsg('Members for OutFile more than MAX allowed.');
 1e     endif;
        endsr;
       end-proc;
 
       //---------------------------------------------------------
       // Override prtf with outq and/or user data
       //---------------------------------------------------------
       dcl-proc f_OvrPrtf export;
        dcl-pi *n;
         p_SplfName char(10) const;
         p_Outq char(20) const;
         p_UsrDta char(10) const;
        end-pi;
 
        dcl-s soutq char(21);
 
        f_DltOvr(p_SplfName);
 
 1b     if %subst(p_Outq:11:10) = *blanks;
           soutq = p_outq;  // *job
 1x     else;
           soutq = f_GetQual(p_outq);
 1e     endif;
 
        f_RunCmd('OVRPRTF FILE(' + %trimr(p_SplfName) +
        ') OUTQ(' + %trimr(soutq) +
        ') USRDTA(' + p_UsrDta + ') OVRSCOPE(*JOB)');
 
        return;
       end-proc;
 
       //---------------------------------------------------------
       // return command prompt override string for program source lib/file/mbr
       //---------------------------------------------------------
       dcl-proc f_PromptOverrideGetSource export;
        dcl-pi *n char(5700);
         p_PgmQual char(20);
        end-pi;
 
        dcl-ds AlphaBin qualified;
         *n uns(5) inz(5700);
        end-ds;
 
       // retrieve program information API to get attribute
        callp QCLRPGMI(
              QclrpgmiDS:
              %len(QclrpgmiDS):
              'PGMI0100':
              p_PgmQual:
              ApiErrDS);
 
 1b     if ApiErrDS.BytesReturned > 0;
           QclrpgmiDS.SrcFil = 'OBJECTxxxx';
           QclrpgmiDS.SrcLib = 'NOTxxxxxxx';
           QclrpgmiDS.SrcMbr = 'FOUNDxxxxx';
           QclrpgmiDS.SrcAttrb = 'xxxxxxxxxx';
 
          // If ILE, get pointer ILE user space
 1x     elseif QclrpgmiDS.PgmType = 'B';
           ApiHeadPtr = f_Quscrtus(UserSpaceName);
           callp QBNLPGMI(
                 UserSpaceName:
                 'PGML0100':
                 p_PgmQual:
                 ApiErrDS);
 
 2b        if ApiErrDS.BytesReturned > 0;  //Src not available
              QclrpgmiDS.SrcFil = 'SOURCExxxx';
              QclrpgmiDS.SrcLib = 'NOTxxxxxxx';
              QclrpgmiDS.SrcMbr = 'FOUNDxxxxx';
              QclrpgmiDS.SrcAttrb = 'xxxxxxxxxx';
 2x        else;
              QbnlpgmiPTR = ApiHeadPtr + ApiHead.OffsetToList;
              QclrpgmiDS.SrcFil = QbnlpgmiDS.SrcFil;
              QclrpgmiDS.SrcLib = QbnlpgmiDS.SrcLib;
              QclrpgmiDS.SrcMbr = QbnlpgmiDS.SrcMbr;
              QclrpgmiDS.SrcAttrb = QbnlpgmiDS.SrcAttrb;
 2e        endif;
 1e     endif;
 
       // build prompt string to return to command
        return
        f_BuildString('&??SRCFIL(&) ??SRCLIB(&) ??SRCMBR(&) ??PGMATR(&)':
        AlphaBin:
        QclrpgmiDS.SrcFil:
        QclrpgmiDS.SrcLib:
        QclrpgmiDS.SrcMbr:
        QclrpgmiDS.SrcAttrb);
       end-proc;
 
       //---------------------------------------------------------
       // Receive program messages
       //---------------------------------------------------------
       dcl-proc f_qmhrcvpm export;
        dcl-pi *n char(75);
         p_CallStack int(10) const;
        end-pi;
 
        dcl-pr Qmhrcvpm ExtPgm('QMHRCVPM');  // receive pgm messages
         *n like(rcvm0100DS);
         *n int(10) const;
         *n char(8) const;
         *n char(10) const;
         *n int(10) const;
         *n char(10) const;
         *n char(4) const;
         *n int(10) const;
         *n char(10) const;
         *n like(ApiErrDS);
        end-pr;
 
        dcl-ds rcvm0100DS qualified;
         BytesReturned int(10) pos(1);
         BytesAvail int(10) pos(5);
         LenOfMsg int(10) pos(41);
         MessageText char(100) pos(49);
        end-ds;
 
        callp QMHRCVPM(
              rcvm0100DS:
              %len(rcvm0100DS):
              'RCVM0100':
              '*':
              p_CallStack:
              '*LAST':
              ' ':
              10:
              '*REMOVE':
              ApiErrDS);
        return rcvm0100DS.MessageText;
       end-proc;
 
       //---------------------------------------------------------
       // Remove all messages from error message subfile
       //---------------------------------------------------------
       dcl-proc f_RmvSflMsg export;
        dcl-pi *n;
         p_ProgName char(10) const;
        end-pi;
 
        dcl-pr Qmhrmvpm ExtPgm('QMHRMVPM');
         *n char(10) const;
         *n int(10) const;
         *n char(4) const;
         *n char(10) const;
         *n like(ApiErrDS);
        end-pr;
 
        callp Qmhrmvpm(
              p_ProgName:
              0:
              ' ':
              '*ALL':
              ApiErrDs);
        return;
       end-proc;
 
       //---------------------------------------------------------
       // Send message to error message subfile
       // use local apierrds so as not to overlay global error reporting when message sent
       //---------------------------------------------------------
       dcl-proc f_SndSflMsg export;
        dcl-pi *n;
         p_ProgName char(10) const;
         p_MsgTxt char(75) const;
         p_MsgID char(7) const options(*nopass);
         p_MsgFile char(10) const options(*nopass);
         p_MsgLib char(10) const options(*nopass);
        end-pi;
 
        dcl-ds ApiErrDS qualified;
         BytesProvided int(10) pos(1) inz(%size(ApiErrDS));
         BytesReturned int(10) pos(5) inz(0);
         ErrMsgId char(7) pos(9);
         MsgReplaceVal char(112) pos(17);
        end-ds;
 
        dcl-s MsgID char(7);
        dcl-s MsgFileQual char(20);
 
 1b     if %parms = %parmnum(p_MsgTxt);
           msgid = *blanks;
           MsgFileQual = *blanks;
 1x     else;
           msgid = p_MsgID;
 
 2b        if %parms = %parmnum(p_MsgFile);
              msgFileQual = p_MsgFile + '*LIBL';
 2x        else;
              msgFileQual = p_MsgFile + p_MsgLib;
 2e        endif;
 1e     endif;
 
        callp QMHSNDPM(
              msgid:
              msgFileQual:
              p_MsgTxt:
              %len(p_MsgTxt):
              '*INFO':
              p_ProgName:
              0:
              ' ':
              ApiErrDs);
        return;
       end-proc;
 
       //---------------------------------------------------------
       // Execute selected command for Files
       //---------------------------------------------------------
       dcl-proc f_RunOptionFile export;
        dcl-pi *n;
         p_Option packed(1) const;
         p_File char(10) const;
         p_Lib char(10) const;
         p_RcdFmt char(10) const;
         p_Mbr char(10) const;
         p_ProgId char(10);
        end-pi;
 
        dcl-s p_FileQual char(21);
        dcl-s Msg char(75);
        dcl-ds anymbrs likeds(Fild0100ds);
        dcl-s futil char(6); // data file utility name
 
        p_FileQual = f_GetQual(p_File + p_Lib);
 
 1b     if p_Option = 1;
           f_RunCmd(f_BuildString('JCRFFD FILE(&) RCDFMT(&) OUTPUT(*)':
           p_FileQual: p_RcdFmt));
           msg = 'Field Descriptions for ' +
           %trimr(p_FileQual) + ' - completed';
 
 1x     elseif p_Option = 2;
 
           callp QDBRTVFD(
                 anymbrs:
                 500:
                 ReturnFileQual:
                 'FILD0100':
                 p_File + p_Lib:
                 '*FIRST':
                 '0':
                 '*FILETYPE':
                 '*EXT':
                 ApiErrDS);
 
 2b        if ApiErrDS.BytesReturned = 0 and anymbrs.NumMbrs = 0;
              msg = 'File ' + %trimr(p_FileQual) + ' has no members.';
 2x        else;
 
             //------------------------------------------------------
             // execute (if installed) DBU, PEEK, WRKDBF, or default STRDFU
             //------------------------------------------------------
              futil = f_GetFileUtil();
 3b           if futil = 'DBU';
                 f_RunCmd('DBU FILE('+p_FileQual+') MBR('+p_Mbr+')');
 3x           elseif futil = 'PEEK';
                 f_RunCmd('PEEK ' + p_FileQual);
 3x           elseif futil = 'WRKDBF';
                 f_RunCmd('WRKDBF ' + p_FileQual);
 3x           else;
                 f_RunCmd('STRDFU OPTION(5) FILE(' +
                 p_FileQual + ') MBR(' + p_Mbr + ')');
 3e           endif;
 
              msg=%trimr(futil)+' for '+%trimr(p_FileQual)+' - completed';
 2e        endif;
 
 1x     elseif p_Option = 3;
           f_RunCmd('JCRFD ' + p_FileQual);
           msg = 'File Description for ' +
           %trimr(p_FileQual) + ' - completed';
 
 1x     elseif p_Option = 4;
           f_RunCmd(f_BuildString('RMVM FILE(&) MBR(&)':
           p_FileQual: p_Mbr));
           msg = 'Member ' + %trimr(p_mbr) + ' has been removed';
 2b        if ApiErrDS.BytesReturned > 0;
              msg = ApiErrDS.ErrMsgId + ': ' +
              %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal));
 2e        endif;
 
 1x     elseif p_Option = 5;
           f_RunCmd(f_BuildString('WRKMBRPDM FILE(&) MBR(&)':
           p_FileQual: p_Mbr));
           msg = 'Work with member ' + %trimr(p_mbr) + ' - completed';
 
 1x     elseif p_Option = 7;
           f_RunCmd('WRKOBJ *ALL/' + p_File + 'OBJTYPE(*FILE)');
           msg = 'Wrkobj *all/' + %trimr(p_file) + ' - completed';
 
 1x     elseif p_Option = 9;
           f_RunCmd(f_BuildString('CLRPFM FILE(&) MBR(&)':
           p_FileQual: p_Mbr));
           msg = 'Member ' + %trimr(p_mbr) + ' has been cleared';
 
 1x     else;
           msg = 'Option ' + %char(p_Option) + ' is not available';
 1e     endif;
 
        f_SndSflMsg(p_ProgId: msg);
        return;
       end-proc;
 
       //---------------------------------------------------------
       // Execute selected command for Jobs
       //---------------------------------------------------------
       dcl-proc f_RunOptionJob export;
        dcl-pi *n;
         p_Option packed(2);
         p_JobName char(10);
         p_JobUser char(10);
         p_JobNum char(6);
         p_ProgId char(10);
        end-pi;
 
        dcl-s JobString varchar(33);
        dcl-s Msg char(75);
 
        dcl-pr p_JCRJOBSIOR extpgm('JCRJOBSIOR');
         *n char(10);
         *n char(10);
         *n char(6);
        end-pr;
 
        JobString =
        %trimr(f_BuildString('JOB(&/&/&)':
               p_JobNum:
               p_JobUser:
               p_JobName));
 
 1b     if p_Option = 2;
           f_RunCmd('?CHGJOB ' + JobString);
           msg = 'Chgjob for ' + %trimr(p_JobName) + ' - completed';
 
 1x     elseif p_Option = 3;
           f_RunCmd('STRSRVJOB ' + JobString);
           msg = 'Strsrvjob for ' + %trimr(p_JobName) + ' - completed';
 
 1x     elseif p_Option = 4;
           f_RunCmd('ENDJOB ' + JobString + ' OPTION(*IMMED)');
           msg = 'Endjob for ' + %trimr(p_JobName) + ' - completed';
 
 1x     elseif p_Option = 5;
           f_RunCmd('DSPJOB ' + JobString);
           msg = 'Dspjob for ' + %trimr(p_JobName) + ' - completed';
 
 1x     elseif p_Option = 8;
           f_RunCmd('DSPJOB ' + JobString + ' OPTION(*SPLF)');
           msg = 'Wrksplf for ' + %trimr(p_JobName) + ' - completed';
 
 1x     elseif p_Option = 9;
           callp(e) p_JCRJOBSIOR(p_JobName: p_JobUser: p_JobNum);
           msg = 'Job File I/O for ' + %trimr(p_JobName) + ' - completed';
 
 1x     elseif p_Option = 10;
           f_RunCmd('?STRDBG');
           msg = 'STRDBG for ' + %trimr(p_JobName) + ' - started';
 
 1x     elseif p_Option = 15;
           f_RunCmd('ENDSRVJOB');
           msg = 'ENDSRVJOB for ' + %trimr(p_JobName) + ' - completed';
 
 1x     elseif p_Option = 20;
           f_RunCmd('ENDDBG');
           msg = 'ENDDBG ' + %trimr(p_JobName) + ' - completed';
 
 1x     else;
           msg = 'Option ' + %char(p_Option) + ' is not available.';
 1e     endif;
 
        f_SndSflMsg(p_ProgId: msg);
        return;
       end-proc;
 
       //---------------------------------------------------------
       // Execute selected command for Spooled Files
       //---------------------------------------------------------
       dcl-proc f_RunOptionSplf export;
        dcl-pi *n;
         p_Option char(1);
         p_SplfName char(10);
         p_SplfNum char(6);
         p_JobName char(10);
         p_JobUser char(10);
         p_JobNum char(6);
         p_ProgId char(10);
        end-pi;
 
        dcl-s Msg char(75);
        dcl-s SpoolString varchar(120);
 
        dcl-s Email char(150);
 
        SpoolString = %trimr(f_BuildString
        ('FILE(&) JOB(&/&/&) SPLNBR(&)':
        p_SplfName: p_JobNum: p_JobUser: p_JobName: p_SplfNum));
 
       //-------------------------------
 1b     if p_Option = '1';
           f_RunCmd('?SNDNETSPLF ' + SpoolString + ' ??TOUSRID(( ))');
 2b        if ApiErrDS.BytesReturned = 0;
              msg = 'Sndnetsplf ' + %trimr(p_SplfName) + ' - completed';
 2x        else;
 3b           if ApiErrDS.ErrMsgId = 'CPF6801';  // no replace value returned
                 ApiErrDS.MsgReplaceVal = 'F3 ';
 3e           endif;
 
              msg = %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId:
                           ApiErrDS.MsgReplaceVal));
 2e        endif;
 
 1x     elseif p_Option = 'S';
           email = f_GetEmail();
 
           SpoolString = %trimr(f_BuildString
           ('SPLF(&) JOB(&/&/&) SPLFN(&)':
           p_SplfName: p_JobNum: p_JobUser: p_JobName: p_SplfNum));
 
           f_RunCmd('?SNDSPLF ' + SpoolString +
           ' ??TOLIST(' + %trimr(Email) + ') ' +
           ' ??FRADR(' + %trimr(Email) + ') ' +
           ' ??SUBJECT(' + %trimr(p_SplfName) + ') ' +
           ' ??MSGTXT(' + %trimr(p_SplfName) + ') ' +
           ' ??TOFMT(*PDF) ??TITLE(' + %trimr(p_SplfName) + ')');
 2b        if ApiErrDS.BytesReturned = 0;
              msg = 'Sndsplf ' + %trimr(p_SplfName) + ' - completed';
 2x        else;
              msg = 'Sndsplf ' + %trimr(p_SplfName) + ' - Canceled';
 2e        endif;
 
 1x     elseif p_Option = 'E';
           email = f_GetEmail();
 
           SpoolString = %trimr(f_BuildString
           ('RECIPIENT(&) ATTLIST((* *PDF *N & &/&/& &))':
           Email: p_SplfName: p_JobNum:
           p_JobUser: p_JobName: p_SplfNum));
 
           f_RunCmd('?ESEND/ESNDMAIL ' + SpoolString);
 2b        if ApiErrDS.BytesReturned = 0;
              msg = 'Esend ' + %trimr(p_SplfName) + ' - completed';
 2x        else;
              msg = 'Esend ' + %trimr(p_SplfName) + ' - Canceled';
 2e        endif;
 
 1x     elseif p_Option = '2';
           f_RunCmd('?CHGSPLFA ' + SpoolString);
 2b        if ApiErrDS.BytesReturned = 0;
              msg = 'Change ' + %trimr(p_SplfName) + ' - completed';
 2x        else;
              msg = 'Change ' + %trimr(p_SplfName) + ' - Canceled';
 2e        endif;
 
 1x     elseif p_Option = '3';
           f_RunCmd('HLDSPLF ' + SpoolString);
           msg = 'Hold Spooled File '
           + %trimr(p_SplfName) + ' - completed';
 
 1x     elseif p_Option = '4';
           f_RunCmd('DLTSPLF ' + SpoolString);
           msg = 'Delete Spooled File '
           + %trimr(p_SplfName) + ' - completed';
 
 1x     elseif p_Option = '5';
           f_RunCmd('DSPSPLF ' + SpoolString);
           msg = 'Display Spooled File '
           + %trimr(p_SplfName) + ' - completed';
 
 1x     elseif p_Option = '6';
           f_RunCmd('RLSSPLF ' + SpoolString);
           msg = 'Release Spooled File '
           + %trimr(p_SplfName) + ' - completed';
 
 1x     elseif p_Option = '8';
           f_RunCmd('WRKSPLFA ' + SpoolString);
           msg = 'Work Spooled File Attributes '
           + %trimr(p_SplfName) + ' - completed';
 
 1x     elseif p_Option = '9';
           f_RunCmd('?CPYSPLF ' + SpoolString + ' ??TOFILE(  )');
 2b        if ApiErrDS.BytesReturned = 0;
              msg = 'Copy ' + %trimr(p_SplfName) + ' - completed';
 2x        else;
              msg = 'Copy ' + %trimr(p_SplfName) + ' - Canceled';
 2e        endif;
 
 1x     elseif p_Option = 'H';
           f_RunCmd('?SPLF2HTML ' + SpoolString +
           ' ??TODOC(' + qs + '/kpiReports/' + qs +
           ') STMFOPT(*REPLACE) FONTSIZE(2)');
 2b        if ApiErrDS.BytesReturned = 0;
              msg = 'SPLF2HTML ' + %trimr(p_SplfName) + ' - completed';
 2x        else;
              msg = 'SPLF2HTML ' + %trimr(p_SplfName) + ' - Canceled';
 2e        endif;
 1x     else;
           msg = 'Invalid Option Selected.';
 1e     endif;
 
        f_SndSflMsg(p_ProgId: msg);
        return;
       end-proc;
 
       //---------------------------------------------------------
       // return shuffled deck of 52 cards (numeric values and suite info)
       //---------------------------------------------------------
       dcl-proc f_ShuffleDeck export;
        dcl-pi *n char(2) dim(52);
        end-pi;
        dcl-s aa uns(3);
        dcl-s bb uns(3);
        dcl-s cc uns(3) inz(0);
        dcl-s ShuffledDeck char(2) dim(52);
 
        dcl-ds NewDeck len(2) dim(52) inz qualified;
         NewCard uns(3);
         NewSuite char(1);
        end-ds;
 
       // load fresh deck
 1b     for aa = 1 to 4;
 2b        for bb = 1 to 13;
              cc += 1;
              NewDeck(cc).NewSuite = %subst('HSCD': aa: 1);
              NewDeck(cc).NewCard = bb;
 2e        endfor;
 1e     endfor;
 
       // Use random function to pull cards from NewDeck.
 1b     for aa = 52 downto 1;
           bb = f_GetRandom(aa);
           ShuffledDeck(aa) = NewDeck(bb);
 
          // replace just dealt card with current last card
           NewDeck(bb) = NewDeck(aa);
 1e     endfor;
 
        return ShuffledDeck;
       end-proc;
 
       //---------------------------------------------------------
       // Send Status messages
       //---------------------------------------------------------
       dcl-proc f_SndStatMsg export;
        dcl-pi *n;
         p_MsgTxt char(75) const;
        end-pi;
 
        callp QMHSNDPM(
              'CPF9898':
              'QCPFMSG   *LIBL':
              p_MsgTxt:
              75:
              '*STATUS':
              '*EXT':
              1:
              ' ':
              ApiErrDS);
        return;
       end-proc;
 
       //---------------------------------------------------------
       // uses new v7r1 qzipzip api to zip on IFS drive
       //  jcrcompost added this entry cause IBM forgot.
       //    ADDBNDDIRE BNDDIR(QUSAPIBD) OBJ((QZIPUTIL))
       //---------------------------------------------------------
       dcl-proc f_ZipIFS export;
        dcl-pi *n;
         p_SrcMbr char(10);
         p_SrcAttr char(10);
         p_IfsDir char(50);
        end-pi;
 
        dcl-pr QzipZip extproc(*cwiden:*dclcase);
         *n likeds(FileToZip);
         *n likeds(ZipFile);
         *n char(8) const;
         *n like(zipoptions);
         *n like(ApiErrds);
        end-pr;
 
        dcl-ds ZipOptions qualified align;
         *n char(10) pos(1) inz('*NONE'); // verbose
         *n char(6) pos(11) inz('*ALL'); // subtree
         *n char(512) pos(17) inz(*blanks); // comment
         *n uns(10) pos(529) inz(0); // comment length
        end-ds;
 
        dcl-ds FileToZip qualified;
         *n int(10) inz(0) pos(1); // ccsid
         *n char(2) inz(*allx'00') pos(5); // country
         *n char(3) inz(*allx'00') pos(7); // language
         *n char(3) inz(*allx'00') pos(10); // reserved
         *n int(10) inz(0) pos(13); // type
         pathlength int(10) inz(0) pos(17);
         *n char(2) inz('/ ') pos(21); // delimiter
         *n char(10) inz(*allx'00') pos(23); // reserved
         pathname char(128) inz(*blanks) pos(33);
        end-ds;
        dcl-ds ZipFile likeds(FileToZip);
 
        ZipFile = FileToZip; // load original ds inz values to likeds
 
        FileToZip.pathname =
        %trimr(p_IfsDir) + %trimr(p_SrcMbr) + '.' + p_SrcAttr;
 
        ZipFile.pathname =
        %trimr(p_IfsDir) + '/' + %trimr(p_SrcMbr) + '.zip';
 
        FileToZip.pathlength = %len(%trimr(FileToZip.pathname));
        ZipFile.pathlength = %len(%trimr(ZipFile.pathname));
 
        QzipZip(FileToZip: ZipFile: 'ZIP00100': ZipOptions: ApiErrds);
        return;
       end-proc;
