       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRLKEYR - Find desired access path
       //---------------------------------------------------------
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) datfmt(*iso) timfmt(*iso)
       option(*nounref: *nodebugio) expropts(*resdecpos) bnddir('JCRCMDSDIR')
       stgmdl(*teraspace) alloc(*stgmdl);
 
       dcl-f JCRLKEYD workstn sfile(sbfdta1: rrn) infds(infds) indds(ind);
 
       /define ApiErrDS
       /define Constants
       /define Infds
       /define f_BuildString
       /define FunctionKeys
       /define Ind
       /define Qdbldbr
       /define Qdbrtvfd
       /define Quslfld
       /define Dspatr
       /define BitMask
       /define f_GetQual
       /define f_GetDayName
       /define f_Quscrtus
       /define f_GetDataTypeKeyWords
       /define f_CamelCase
       /define f_SndCompMsg
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s KeyField char(10);
       dcl-s WorkFileQual char(20);
       dcl-s ForCount3 uns(5);
       dcl-s IsKeysLoaded ind;
       dcl-s SaveMessage like(footermsg);
       dcl-s unsignedlength uns(10);
       dcl-s DecimalPos char(2);
 
       // File description display driver
       dcl-pr p_JCRFDR extpgm('JCRFDR');
        *n char(10) const;
        *n char(20);
        *n char(10) const;
        *n char(10) const;
        *n char(4) const;
        *n char(101);
        *n char(10) const;
       end-pr;
 
       dcl-ds *n;
        KeysArry char(19) dim(1000) inz;
        FldsArry char(10) overlay(keysarry:1);
        Pos1Arry char(1) overlay(keysarry:11);
        Pos2Arry char(1) overlay(keysarry:12);
        Pos3Arry char(1) overlay(keysarry:13);
        Pos4Arry char(1) overlay(keysarry:14);
        Pos5Arry char(1) overlay(keysarry:15);
        Pos6Arry char(1) overlay(keysarry:16);
        Pos7Arry char(1) overlay(keysarry:17);
        Pos8Arry char(1) overlay(keysarry:18);
        Pos9Arry char(1) overlay(keysarry:19);
       end-ds;
 
       // map screen fields
       dcl-ds *n;
        scPos1;
        scPos2;
        scPos3;
        scPos4;
        scPos5;
        scPos6;
        scPos7;
        scPos8;
        scPos9;
        scPosArry char(1) dim(9) pos(1); // key positions
       end-ds;
 
       dcl-ds *n;
        scPos1a;
        scPos2a;
        scPos3a;
        scPos4a;
        scPos5a;
        scPos6a;
        scPos7a;
        scPos8a;
        scPos9a;
        scPosArryA char(1) dim(9) pos(1); // position attributes
       end-ds;
 
       //---------------------------------------------------------
       // Load keys selected from subfile into single field so it can be easily
       // passed as parameter to data base relations display program p_JCRFDR.
       //---------------------------------------------------------
       dcl-ds ParmDS qualified;
        KeyFields char(10) dim(9);
        KeyPosition zoned(1) dim(9);
        SelectOmit ind;
        IsFoundKey ind;
       end-ds;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_Mbr char(10);
        p_FileQual char(20);
        p_IncludeSO char(4);
       end-pi;
       //---------------------------------------------------------
 
       aFooterMsg = Blue;
 1b    if p_IncludeSO = '*YES';
          ParmDS.SelectOmit = '1';
          FooterMsg = 'F7=Exclude Select/Omit logicals';
 1x    else;
          ParmDS.SelectOmit = '0';
          FooterMsg = 'F7=Include Select/Omit logicals';
 1e    endif;
       SaveMessage = FooterMsg;
       scDow = f_GetDayName();
 
       //---------------------------------------------------------
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
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
 
       // if selected file is a logical, extract based-on-physical name.
       fscopePtr = Fild0100ptr + Fild0100ds.OffsFileScope;
 1b    if %bitand(bit2: Fild0100ds.TypeBits) = bit2;
          p_FileQual = FileScopeArry.BasedOnPf +
          FileScopeArry.BasedOnPfLib;
 1e    endif;
 
       scObjHead =
       f_BuildString('&  &  &': %subst(p_FileQual: 1: 10):
       %subst(ReturnFileQual: 11: 10): Fild0100ds.FileText);
 
       exsr srGetDataBaseRelations;
       exsr srKeyFieldAttributes;
 
       //---------------------------------------------------------
       // process subfile requests
       //---------------------------------------------------------
       SflRcdNbr = 1;
 1b    dou 1 = 2;
          Ind.sfldsp = (rrn > 0);
          Ind.sfldspctl = *on;
          write sfooter1;
          exfmt sbfctl1;
 
 2b       if InfdsFkey = f03 or InfdsFkey = f12;
             dealloc(n) Fild0100ptr;
             f_SndCompMsg('JCRLKEY for ' +
             f_GetQual(p_FileQual) + ' - completed');
             *inlr = *on;
             return;
 2e       endif;
 
 2b       if (not Ind.sfldsp);
 1i          iter;
 2e       endif;
 
          //---------------------------------------------------------
          // find record in subfile user has selected
          // Load keys selected from subfile into arrays so it can be
          // passed as parm to data base relations display program p_JCRFDR.
          //---------------------------------------------------------
          ParmDS.KeyFields(*) = *blanks;
          ParmDS.KeyPosition(*) = 0;
 
          // Toggle Include/Exclude select/omit logicals
          aFooterMsg = Blue;
 2b       if InfdsFkey = f07;
             ParmDS.SelectOmit = (not ParmDS.SelectOmit);
 3b          if ParmDS.SelectOmit;
                FooterMsg = 'F7=Exclude Select/Omit logicals';
 3x          else;
                FooterMsg = 'F7=Include Select/Omit logicals';
 3e          endif;
             SaveMessage = FooterMsg;
             exsr srGetDataBaseRelations;
             exsr srKeyFieldAttributes;
 2e       endif;
          aa = 0;
          IsKeysLoaded = *off;
 
          readc sbfdta1;
 2b       dow not %eof;
 3b          if scSelect > *blanks;
                IsKeysLoaded = *on;
                aa += 1;
 4b             if aa > 9;
 2v                leave;
 4e             endif;
 
                ParmDS.KeyFields(aa) = scKeyNam;
 
                // load zero if do not care about position
 4b             if scSelect >= '1' and scSelect <= '9';
                   ParmDS.KeyPosition(aa) = %uns(scSelect);
 4x             else;
                   ParmDS.KeyPosition(aa) = 0;
 4e             endif;
 
                scSelect = *blanks;
                update sbfdta1;
 3e          endif;
             SflRcdNbr = rrn;
             readc sbfdta1;
 2e       enddo;
 
          // call data base relations display program
 2b       if IsKeysLoaded;
             callp p_JCRFDR(
                   '*FIRST':
                   p_FileQual:
                   '*FILE':
                   'JCRLKEY':
                   '*DBR':
                   ParmDS:
                   ' ');
 
 3b          if not ParmDS.IsFoundKey;
                aFooterMsg = White;
                FooterMsg = 'No Logicals found with selected key';
 3x          else;
                FooterMsg = SaveMessage;
                aFooterMsg = Blue;
 3e          endif;
 2e       endif;
 1e    enddo;
 
       //---------------------------------------------------------
       begsr srGetDataBaseRelations;
       FldsArry(*) = *blanks;
       KeysArry(*) = *blanks;
       aa = 0;
       bb = 0;
       rrn = 0;
       SflRcdNbr = 1;
       Ind.sfldspctl = *off;
       write sbfctl1;
 
       // retrieve data base relation names
       callp QDBLDBR(
             UserSpaceName:
             'DBRL0100':
             p_FileQual:
             '*ALL':
             '*ALL':
             ApiErrDS);
 
       // Process list entries in user space
       QdbldbrPtr = ApiHeadPtr + ApiHead.OffSetToList;
 
 1b    for ForCount = 0 to ApiHead.ListEntryCount;
          // put PF first in output
 2b       if ForCount > 0;
             WorkFileQual = QdbldbrDS.DependentFile;
 2x       else;
             WorkFileQual = p_FileQual;
 2e       endif;
 
 2b       if not(WorkFileQual = *blanks or WorkFileQual = '*NONE');
             AllocatedSize = f_GetAllocatedSize(WorkFileQual: '*FIRST');
 
 3b          if ApiErrDS.BytesReturned = 0;
                Fild0100ptr = %realloc(Fild0100ptr: AllocatedSize);
                callp QDBRTVFD(
                      Fild0100ds:
                      AllocatedSize:
                      ReturnFileQual:
                      'FILD0100':
                      WorkFileQual:
                      '*ALL':
                      '0':
                      '*FILETYPE':
                      '*EXT':
                      ApiErrDS);
 
                // get offset to Keys
                fscopePtr = Fild0100ptr + Fild0100ds.OffsFileScope;
 
                // include select/omits or only files with no select/omits
 4b             if ParmDS.SelectOmit
                   or
                   (not ParmDS.SelectOmit and
                   FileScopeArry.NumSelectOmit = 0);
 
                   // Load array of field names and
                   // numeric position of field in the
                   // key, only care about 9 levels down list.
 5b                if %bitand(bit6: Fild0100ds.TypeBits) = bit6;   // keyed access path
                      KeySpecsPtr =
                      Fild0100ptr + FileScopeArry.OffsKeySpecs;
 6b                   for ForCount2 = 1 to FileScopeArry.NumOfKeys;
                         KeyField = KeySpecsDS.KeyFieldName;
 
 7b                      if aa > 0;
                            bb = %lookup(KeyField: FldsArry: 1: aa);
 7e                      endif;
 7b                      if bb = 0;
                            aa += 1;
                            bb = aa;
                            FldsArry(aa) = KeyField;
 7e                      endif;
 
 7b                      if ForCount2 = 1;
                            Pos1Arry(bb) = '1';
 7x                      elseif ForCount2 = 2;
                            Pos2Arry(bb) = '2';
 7x                      elseif ForCount2 = 3;
                            Pos3Arry(bb) = '3';
 7x                      elseif ForCount2 = 4;
                            Pos4Arry(bb) = '4';
 7x                      elseif ForCount2 = 5;
                            Pos5Arry(bb) = '5';
 7x                      elseif ForCount2 = 6;
                            Pos6Arry(bb) = '6';
 7x                      elseif ForCount2 = 7;
                            Pos7Arry(bb) = '7';
 7x                      elseif ForCount2 = 8;
                            Pos8Arry(bb) = '8';
 7x                      elseif ForCount2 = 9;
                            Pos9Arry(bb) = '9';
 7e                      endif;
                         KeySpecsPtr += 32;
 6e                   endfor;
 5e                endif;
 4e             endif;
 3e          endif;
 2e       endif;
 
 2b       if ForCount > 0;
             QdbldbrPtr += ApiHead.ListEntrySize;
 2e       endif;
 1e    endfor;
 1b    if aa > 1;
          sorta %subarr(KeysArry:1:aa);
 1e    endif;
       endsr;
 
       //---------------------------------------------------------
       // Now load text and attributes of file fields to user space
       //---------------------------------------------------------
       begsr srKeyFieldAttributes;
       callp QUSLFLD(
             UserSpaceName:
             'FLDL0100':
             p_FileQual:
             '*FIRST':
             '0':
             ApiErrDS);
 
       //---------------------------------------------------------
       // Process from array so subfile is sorted.
       // Spin through user space comparing field names,
       // when one is found, write subfile record.
       //---------------------------------------------------------
 1b    for ForCount3 = 1 to aa;
          QuslfldPtr = ApiHeadPtr + ApiHead.OffSetToList;
 
 2b       for ForCount = 1 to ApiHead.ListEntryCount;
             KeyField = QuslfldDS.FieldName;
 
 3b          if KeyField = FldsArry(ForCount3);
                scSelect = *blanks;
                scKeyNam = KeyField;
                scKeyTxt = f_camelcase(QuslfldDS.FieldText);
                scPos1 = Pos1Arry(ForCount3);
                scPos2 = Pos2Arry(ForCount3);
                scPos3 = Pos3Arry(ForCount3);
                scPos4 = Pos4Arry(ForCount3);
                scPos5 = Pos5Arry(ForCount3);
                scPos6 = Pos6Arry(ForCount3);
                scPos7 = Pos7Arry(ForCount3);
                scPos8 = Pos8Arry(ForCount3);
                scPos9 = Pos9Arry(ForCount3);
 
 4b             for cc = 1 to 9;
 5b                if scPosArry(cc) = ' ';
                      scPosArryA(cc) = Blue;
                      scPosArry(cc) = '.';
 5x                else;
                      scPosArryA(cc) = Green;
 5e                endif;
 4e             endfor;
 
                //---------------------------------------------------------
                // load data type
                //---------------------------------------------------------
 4b             if QuslfldDS.Digits > 0; // numeric
                   unsignedlength = QuslfldDS.Digits;
                   DecimalPos = %triml(%editc(QuslfldDS.DecimalPos:'3'));
 4x             else;
                   unsignedlength = QuslfldDS.FieldLengthA;
                   DecimalPos = *blanks;
 4e             endif;
 
                scDataType = %scanrpl(';':' ':
                f_GetDataTypeKeyWords(
                QuslfldDS.FieldType:
                unsignedlength:
                DecimalPos));
 
                rrn += 1;
                write sbfdta1;
 2v             leave;
 3e          endif;
             QuslfldPtr += ApiHead.ListEntrySize;
 2e       endfor;
 1e    endfor;
       endsr;
