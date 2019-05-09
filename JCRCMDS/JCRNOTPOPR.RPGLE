       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRNOTPOPR- List fields not populated
       //  call API to retrieve file field descriptions.
       //   use entries to generate rpgle code to read PF and print report.
       //
       //  Added rename record format to generated source code if same name as file
       //   and to read keyed if LF file type.
       //
       //  Add monitor for deleted records in journal files
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define Constants
       /define Qdbrtvfd
       /define BitMask
       /define Quslfld
       /define f_GetQual
       /define f_Quscrtus
       /define f_SndStatMsg
       /define f_RunCmd
       /define f_OvrPrtf
       /define f_SrcFileAddPfm
       /define f_DisplayLastSplf
       /define f_GetDayName
       /define f_GetDataTypeKeyWords
       /define f_CamelCase
       /define SourceOutDS
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f RPGSRC disk(112) usage(*output) extfile('QTEMP/JCRSRC')
       extmbr('JCRNOTR') usropn;
 
       dcl-s scDow char(9);
       dcl-s Alpha14 char(14);
       dcl-s FldTxt char(42);
       dcl-s RcdFmtRename char(30);
       dcl-s RecordAddressType char(5);
       dcl-s pFile char(10);
       dcl-s pLib char(10);
       dcl-s unsignedlength uns(10);
       dcl-s DecimalPos char(2);
 
       // Break Implicit Call Link
       dcl-pr p_JCRNOTPOPC extpgm('JCRNOTPOPC') end-pr;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_FileQual char(20);
        p_Mbr char(10);
        p_Output char(8);
       end-pi;
       //---------------------------------------------------------
       scDow = f_GetDayName();
 
       // create source file/member for generated program
       f_RunCmd('DLTF FILE(QTEMP/JCRSRC)');
       f_RunCmd('DLTPGM QTEMP/JCRNOTR');
       f_RunCmd('CRTSRCPF FILE(QTEMP/JCRSRC) RCDLEN(112)');
       f_SrcFileAddPfm('JCRSRC    QTEMP': 'JCRNOTR': 'RPGLE': ' ');
       open RPGSRC;
 
       AllocatedSize = f_GetAllocatedSize(p_FileQual: '*FIRST');
       Fild0100ptr = %alloc(AllocatedSize);
       callp QDBRTVFD(
             Fild0100ds:
             AllocatedSize:
             ReturnFileQual:
             'FILD0100':
             p_FileQual:
             '*FIRST':
             '0':
             '*FILETYPE':
             '*EXT':
             ApiErrDS);
 
       // load actual library name
       %subst(p_FileQual: 11: 10) = %subst(ReturnFileQual: 11: 10);
       pFile = %subst(p_FileQual: 1: 10);
       pLib = %subst(p_FileQual: 11: 10);
 
       //------------------------------------------------------------------
       // If LF, then must use keyed access.  If PF, check record format name
       // same as file name (like created by SQl).  Must rename this record format.
       RcdFmtRename = *blanks;
       RecordAddressType = *blanks;
 
 1b    if %bitand(bit2: Fild0100ds.TypeBits) = bit2;  // is LF
          RecordAddressType = 'keyed';
 1x    else;
          fscopePtr = Fild0100ptr + Fild0100ds.OffsFileScope;
 2b       if pFile = FileScopeArry.RcdFmt;
             RcdFmtRename = 'rename(' + %trimr(pFile) + ':jcrnotxxxr)';
 2e       endif;
 1e    endif;
 
       //------------------------------------------------------------------
       // Write file specs
       clear Outds;
       f_Write('dcl-f ' + %trimr(pFile) + ' ' +
       %trimr(RecordAddressType) + ' ' +
       %trimr(RcdFmtRename) + ' prefix(x);');
 
       f_Write('dcl-f JCRNOTPOPP printer oflind(IsOverFlow);');
       f_Write('dcl-s jxxxxxxcnt uns(5);');
       f_Write('dcl-s jxxxxxxflg ind dim(6000);');
       f_Write('dcl-s jxxxxxxnam char(10) dim(%elem(jxxxxxxflg));');
       f_Write('dcl-s jxxxxxxtyp char(16)  dim(%elem(jxxxxxxflg));');
       f_Write('dcl-s jxxxxxxtxt char(42) dim(%elem(jxxxxxxflg));');
 
       bb = 0;
       ApiHeadPtr = f_Quscrtus(UserSpaceName2);
 
       callp QUSLFLD(
             UserSpaceName2:
             'FLDL0100':
             p_FileQual:
             '*FIRST':
             '0':
             ApiErrDS);
 
       QuslfldPTR = ApiHeadPtr + ApiHead.OffSetToList;
 
 1b    for ForCount = 1 to ApiHead.ListEntryCount;
 2b       if QuslfldDS.FieldType = 'A'
             or QuslfldDS.FieldType = 'S'
             or QuslfldDS.FieldType = 'P'
             or QuslfldDS.FieldType = 'U'
             or QuslfldDS.FieldType = 'I'
             or QuslfldDS.FieldType = 'B';
             bb += 1;
             f_Write('jxxxxxxnam(' + %char(bb) + ')='
             + qs + %trimr(QuslfldDS.FieldName) + qs + ';');
 
 3b          if QuslfldDS.Digits > 0; // numeric
                unsignedlength = QuslfldDS.Digits;
                DecimalPos = %triml(%editc(QuslfldDS.DecimalPos:'3'));
 3x          else;
                unsignedlength = QuslfldDS.FieldLengthA;
                DecimalPos = *blanks;
 3e          endif;
 
             f_Write('jxxxxxxtyp(' + %char(bb) + ') ='
             + qs +
 
             %trimr(%scanrpl(';':' ':
             f_GetDataTypeKeyWords(
             QuslfldDS.FieldType:
             unsignedlength:
             DecimalPos)))
 
             + qs + ';');
 
             // Remove Quotes before generation
             FldTxt = %xlate(qd+qs:'  ': f_CamelCase(QuslfldDS.FieldText));
             f_Write('jxxxxxxtxt(' + %char(bb) + ')='+qs+
             %trimr(FldTxt) + qs + ';');
 2e       endif;
 
          QuslfldPTR += ApiHead.ListEntrySize;
 1e    endfor;
 
       // start file read code
       f_Write('read ' + %trimr(pFile) + ';');
       f_Write('dow not %eof;');
       f_Write('monitor;');
 
       // override print file for later
       f_OvrPrtf('JCRNOTPOPP': '*JOB': pFile);
 
       //---------------------------------------------------------
       // generate calc specs
       bb = 0;
 
       QuslfldPTR = ApiHeadPtr + ApiHead.OffSetToList;
 
 1b    for ForCount = 1 to ApiHead.ListEntryCount;
 2b       if QuslfldDS.FieldType = 'A'
             or QuslfldDS.FieldType = 'S'
             or QuslfldDS.FieldType = 'P'
             or QuslfldDS.FieldType = 'U'
             or QuslfldDS.FieldType = 'I'
             or QuslfldDS.FieldType = 'B';
             bb += 1;
 
             // put prefix on field name to avoid reserved word field names
             Alpha14 = 'X' + QuslfldDS.FieldName;
 
             //---------------------------------------------------------
 3b          if QuslfldDS.FieldType = 'A';
                f_Write('if ' +%trimr(Alpha14)+ ' > *blanks;');
 3x          else;
                f_Write('if ' +%trimr(Alpha14)+ ' > *zeros;');
 3e          endif;
 
             //---------------------------------------------------------
             f_Write(' jxxxxxxflg(' + %char(bb) + ') = *on;');
             f_Write('endif;');
 2e       endif;
 
          QuslfldPTR += ApiHead.ListEntrySize;
 1e    endfor;
       f_Write('on-error;');
       f_Write('endmon;');
 
       // bottom file read
       f_Write('read ' + %trimr(pFile) + ';');
       f_Write('enddo;');
 
       //---------------------------------------------------------
       // Load heading fields and heading print line
       //---------------------------------------------------------
       f_Write('// Print report ----------------------------');
       f_Write('FileActual =' + qs + %trimr(pFile) + qs + ';');
       f_Write('LibActual =' + qs + %trimr(pLib) + qs + ';');
       f_Write('FileMbr =' + qs + %trimr(p_Mbr) + qs + ';');
       f_Write('scdow =' + qs + scdow + qs + ';');
       f_Write('FileText =');
       f_Write(qs + %subst(Fild0100ds.FileText: 1: 42) +  qs + ';');
       f_Write('write PrtHead;');
       f_Write('for jxxxxxxcnt = 1 to ' + %char(bb) + ';');
       f_Write('if jxxxxxxflg(jxxxxxxcnt) = *off;');
       f_Write('FldName=jxxxxxxnam(jxxxxxxcnt);');
       f_Write('FldType=jxxxxxxtyp(jxxxxxxcnt);');
       f_Write('FldText=jxxxxxxtxt(jxxxxxxcnt);');
       f_Write('write PrtDetail;');
       f_Write('if IsOverFlow;');
       f_Write('write PrtHead;');
       f_Write('IsOverFlow = *off;');
       f_Write('endif;');
       f_Write('endif;');
       f_Write('endfor;');
       f_Write('*inlr = *on;');
       f_Write('return;');
       f_Write('// --------------------------');
 
       //---------------------------------------------------------
       close RPGSRC;
       f_RunCmd('OVRDBF  FILE(' + pFile + ') TOFILE(' +
       f_GetQual(p_FileQual) + ') MBR(' + p_Mbr + ') OVRSCOPE(*JOB)');
 
       f_RunCmd('CRTBNDRPG PGM(QTEMP/JCRNOTR) ' +
       'SRCFILE(QTEMP/JCRSRC) SRCMBR(JCRNOTR) ' +
       'DBGVIEW(*NONE) OUTPUT(*NONE) TGTRLS(*CURRENT)');
 
       f_SndStatMsg('Reading data file ' +
       f_GetQual(p_FileQual) + ' - in progress');
       callp p_JCRNOTPOPC();
       f_RunCmd('DLTOVR FILE(JCRNOTPOPP) LVL(*JOB)');
       f_RunCmd('DLTOVR FILE(' + pFile + ') LVL(*JOB)');
 
       f_DisplayLastSplf('JCRNOTPOPR': p_Output);
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       // Write generated code to outfile
       //---------------------------------------------------------
       dcl-proc f_Write;
        dcl-pi *n;
         pSrcCod char(74) const;
        end-pi;
 
        OutDS.SrcCod = ' ' + pSrcCod;
        OutDS.SrcSeq += .01;
        write RPGSRC OutDS;
        return;
       end-proc;
