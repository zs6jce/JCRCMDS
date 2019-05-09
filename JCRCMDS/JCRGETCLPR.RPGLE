       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRGETCLPR - load EXPORT array with field name and attributes
       //  Generate diagnostic source listing
       //   Read spooled file
       //    Load JCRCMDSSRV clipboard array with field names and attributes
       //---------------------------------------------------------
       /define ControlStatements
       /define FieldsArry
       /define FieldsAttrDS
       /define f_IsValidMbr
       /define Constants
       /define f_GetQual
       /define f_RunCmd
       /define f_Qusrmbrd
       /define f_BlankCommentsCL
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRGETCLPF disk(132) usropn;
       dcl-ds inputDS len(132);
        iAmp char(1) pos(2);
        iFieldName char(11) pos(2);
        iDeclaredVar char(18) pos(2);
        iSourceCode char(100) pos(10);
        iEndOfXref char(43) pos(34);
        iDataType char(1) pos(43);
        iEndOfSource char(25) pos(44);
        iFieldLength char(5) pos(58);
        iFieldDecimals char(1) pos(64);
       end-ds;
 
       dcl-s xx uns(10);
       dcl-s CountClParms uns(10);
       dcl-s ArryOfClParms char(11) dim(500);
       dcl-s IsLookForSeverity ind;
       dcl-s IsFoundVar ind;
       dcl-s IsPGM ind;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_SrcFilQual char(20);
        p_SrcMbr char(10);
        p_DiagSeverity char(2);
       end-pi;
       //---------------------------------------------------------
 
       // generate diagnostic listing and copy to data file
       p_DiagSeverity = '00';
       FieldsArryCnt = 0;
 
 1b    if f_IsValidMbr('JCRGETCLPF' + 'QTEMP');
          f_RunCmd('CLRPFM QTEMP/JCRGETCLPF');
 1x    else;
          f_RunCmd('CRTPF FILE(QTEMP/JCRGETCLPF) RCDLEN(132)');
 1e    endif;
       f_RunCmd('OVRPRTF FILE(' + p_SrcMbr + ') HOLD(*YES)');
 
       QusrmbrdDS = f_Qusrmbrd(p_SrcFilQual: p_SrcMbr: 'MBRD0100');
 1b    if QusrmbrdDS.MbrType = 'CLP';
          f_RunCmd('CRTCLPGM  PGM(QTEMP/' + p_SrcMbr +
          ') SRCFILE(' + f_GetQual(p_SrcFilQual) +
          ') OPTION(*SOURCE *XREF *NOGEN)');
 1x    else;
          f_RunCmd('CRTBNDCL PGM(QTEMP/' + p_SrcMbr +
          ') SRCFILE(' + f_GetQual(p_SrcFilQual) +
          ') OPTION(*XREF) OUTPUT(*PRINT)');
          f_RunCmd('DLTPGM PGM(QTEMP/' + p_SrcMbr + ')');
 1e    endif;
 
       f_RunCmd('CPYSPLF FILE(' + p_SrcMbr +
       ') TOFILE(QTEMP/JCRGETCLPF) SPLNBR(*LAST)');
       f_RunCmd('DLTOVR FILE(' + p_SrcMbr + ')');
 
       //---------------------------------------------------------
       // read listing
       aa = 0;
       cc = 0;
       CountClParms = 0;
       open JCRGETCLPF;
       read JCRGETCLPF inputDS;
 1b    dow not %eof;
 
          %subst(iSourceCode:95) = *blanks;
          iSourceCode = f_BlankCommentsCL(iSourceCode);
          iSourceCode = %xlate(lo: up: iSourceCode);
 
          // get to the PGM command
 2b       if (not IsPgm) and
             (%subst(iSourceCode: 1: 4) = 'PGM ' or
             %scan(' PGM ': iSourceCode) > 0);
             IsPgm = *on;
 2e       endif;
 
          // Now extract anything with a & in front up to a space or )
 2b       if IsPgm;
 3b          if %scan(' DCL ': iSourceCode) > 0
                or %scan(' DCLF ': iSourceCode) > 0
                or %subst(iSourceCode: 1: 4) = 'DCL '
                or %subst(iSourceCode: 1: 4) = 'DCLF'
                or iEndOfSource = 'E N D   O F   S O U R C E';
 1v             leave;
 3e          endif;
             IsFoundVar = *off;
 
 3b          for aa = 1 to %len(iSourceCode);
 4b             if %subst(iSourceCode:aa:1) = '&';
                   IsFoundVar = *on;
                   CountClParms += 1;
                   cc = 0;
 4e             endif;
 
 4b             if IsFoundVar;
 5b                if %subst(iSourceCode:aa:1) = ' '
                      or %subst(iSourceCode:aa:1) = ')';
                      IsFoundVar = *off;
 5x                else;
                      cc += 1;
                      %subst(ArryOfClParms(CountClParms) :cc :1) =
                      %subst(iSourceCode: aa: 1);
 5e                endif;
 4e             endif;
 3e          endfor;
 2e       endif;
 
          read JCRGETCLPF inputDS;
 1e    enddo;
 
 1b    if CountClParms = 0;
          *inlr = *on;
          return;
 1e    endif;
 
 1b    dou iDeclaredVar = 'Declared Variables';
          read JCRGETCLPF inputDS;
 1e    enddo;
 
 1b    dou iEndOfXref = 'E N D   O F   C R O S S   R E F E R E N C E';
          read JCRGETCLPF inputDS;
 2b       if iAmp = '&';
             // only extract parm fields
             xx = %lookup(iFieldName: ArryOfClParms: 1: CountClParms);
 3b          if xx > 0;
                FieldsArryCnt += 1;
                FieldsArry(xx).Name = iFieldName;
 
                clear FieldsAttrDS;
                FieldsAttrDS.DataType = iDataType;
                FieldsAttrDS.Length = %uns(iFieldLength);
                evalr FieldsAttrDS.DecimalPos = '  ' + iFieldDecimals;
                FieldsArry(xx).Attr = FieldsAttrDS;
 3e          endif;
 2e       endif;
 1e    enddo;
       close JCRGETCLPF;
       *inlr = *on;
       return;
