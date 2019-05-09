       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRMIKER - show programs procedure location / source code
       //   use call and outfile from JCRLSRC to get source code location
       //---------------------------------------------------------
       // 11/7/2016 D.Donohue - Added Column Headings to report
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define Qbnlspgm
       /define Qbnlpgmi
       /define f_BuildString
       /define f_GetQual
       /define f_SndEscapeMsg
       /define f_Quscrtus
       /define f_Qusrobjd
       /define f_RunCmd
       /define f_GetDayName
       /define f_GetInternalProcNames
       /define f_Qusrmbrd
       /define f_RtvMsgAPI
       /define f_OvrPrtf
       /define f_DltOvr
       /define f_DisplayLastSplf
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRLSRCF usropn extfile('QTEMP/JCRLSRCF');
       dcl-f JCRMIKEP printer oflind(IsOverFlow) usropn;
 
       //---------------------------------------------
       // Prototypes internal to the program source
       //----------------------------------------------
       dcl-ds InternalPR qualified;
        Cnt uns(5);
        Arry char(74) dim(500);
       end-ds;
 
       //---------------------------------------------------------
       dcl-s extOmbr char(10);
       dcl-s LibObjQual char(21);
       dcl-s PgmSpace char(20) inz('JCRPGM    QTEMP');
       dcl-s SrvPgmSpace char(20) inz('JCRSRVPGM QTEMP');
       dcl-s jcrProc char(74);
       dcl-s jcrSrvPgm char(10);
       dcl-s jcrSrvPgmL char(10);
       dcl-s xx uns(5);
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_ObjQual char(20);
        p_ObjTyp char(10);
        p_Output char(8);
       end-pi;
       //---------------------------------------------------------
 
       f_OvrPrtf('JCRMIKEP': '*JOB': %subst(p_ObjQual: 1: 10));
       open JCRMIKEP;
       scDow = f_GetDayName();
 
       QusrObjDS = f_QUSROBJD(p_ObjQual: p_ObjTyp);
       %subst(p_ObjQual: 11: 10) = QusrObjDS.ReturnLib;
 
       scObjHead =
       f_BuildString('&      Program: &   &   &':
       'JCRMIKE': QusrObjDS.ObjNam: QusrObjDS.ReturnLib: QusrObjDS.Text);
 
       write PrtHead;
       IsOverFlow = *off;
       LibObjQual = f_GetQual(p_ObjQual);
 
       // UPREHS MODIFICATION - Print Column headings
       jcrProc = 'Procedure name';
       lsrcfil = 'Src File';
       lsrclib = 'SrcF Lib';
       jcrSrvPgm = 'SvcPgm';
       jcrSrvPgmL = 'SvcPgmLib';
       write prtLine;
 
       f_RunCmd('JCRLSRC PGM(' + %trimr(LibObjQual) +
       ') OUTPUT(*OUTFILE) OUTFILE(QTEMP/JCRLSRCF)');
 
       open JCRLSRCF;
       read JCRLSRCFR;
 1b    if %eof; // throw expection here later as source not found;
          // how big an error? warning? decide later
 1e    endif;
       close JCRLSRCF;
 
       QusrmbrdDS = f_Qusrmbrd(lSrcFil + lSrcLib: lSrcMbr: 'MBRD0100');
 1b    if ApiErrDS.BytesReturned > 0;
          f_SndEscapeMsg(ApiErrDS.ErrMsgId + ': ' +
          %trimr(f_RtvMsgApi(ApiErrDS.ErrMsgId: ApiErrDS.MsgReplaceVal)));
 1e    endif;
 
       InternalPR = f_GetInternalProcNames(lSrcMbr: lSrcFil + lSrcLib);
 
 1b    for xx = 1 to InternalPr.Cnt;
          jcrProc = InternalPr.Arry(xx);
          jcrSrvPgm = %subst(p_ObjQual: 1: 10);
          jcrSrvPgmL = %subst(p_ObjQual: 11: 10);
          write prtline;
 2b       if IsOverFlow;
             write prthead;
             IsOverFlow = *off;
 2e       endif;
 1e    endfor;
 
       ApiHeadPtr = f_Quscrtus(PgmSpace);
       ApiHeadPtr2 = f_Quscrtus(SrvPgmSpace);
       f_GetProceduresinPgm(QusrObjDS.ObjNam: QusrObjDS.ReturnLib);
 
       close JCRMIKEP;
       f_DltOvr('JCRMIKEP');
       f_DisplayLastSplf('JCRMIKER': p_Output);
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       // Execute a API to get all service program names used in a program.
       //  Then execute the f_GetSrvPgm to print them out.
       //---------------------------------------------------------
       dcl-proc f_GetProceduresinPgm;
        dcl-pi *n;
         p_ObjName char(10);
         p_ObjLib char(10);
        end-pi;
 
        dcl-ds Pgml0200DS qualified based(Pgml0200PTR);
         Name char(10) pos(21);
         Lib char(10) pos(31);
        end-ds;
 
        callp QBNLPGMI(
              PgmSpace:
              'PGML0200':
              p_ObjName + p_ObjLib:
              ApiErrDS);
 
        Pgml0200Ptr = ApiHeadPtr +  ApiHead.OffSetToList;
 
 1b     for ForCount = 1 to ApiHead.ListEntryCount;
 2b        if Pgml0200DS.Lib <> 'QSYS';
 3b           if Pgml0200DS.Lib <> *blanks;
                 Pgml0200DS.Lib = '*LIBL';
 3e           endif;
              f_GetSrvPgm(Pgml0200DS.Name:Pgml0200DS.Lib);
 2e        endif;
 
           Pgml0200Ptr += ApiHead.ListEntrySize;
 1e     endfor;
        return;
       end-proc;
 
       //---------------------------------------------------------
       dcl-proc f_GetSrvPgm;
        dcl-pi *n;
         p_ObjName char(10);
         p_ObjLib char(10);
        end-pi;
 
        jcrSrvPgm = p_ObjName;
        jcrSrvPgmL = p_ObjLib;
 
        callp QBNLSPGM(
              SrvPgmSpace:
              'SPGL0600':
              p_ObjName + p_ObjLib:
              ApiErrDS);
 
        SrvPgmPtr = ApiHeadPtr2 + ApiHead2.OffSetToList;
 
 1b     for ForCount2 = 1 to ApiHead2.ListEntryCount;
           JCRProc =
           %subst(SrvPgmDS.BigProcName: 1: SrvPgmDS.LengthOfName);
 
           f_RunCmd('+
           JCRLSRC PGM(' + %trim(jcrSrvPgmL) + '/' + %trim(jcrSrvPgm)+
           ') OUTPUT(*OUTFILE) OUTFILE(QTEMP/JCRLSRCF)');
 
           open JCRLSRCF;
           read JCRLSRCFR;
 2b        if %eof; // throw expection here later as source not found;
             // how big an error? warnig? decide later
 2e        endif;
           close JCRLSRCF;
 
           write prtline;
 2b        if IsOverFlow;
              write prthead;
              IsOverFlow = *off;
 2e        endif;
 
           SrvPgmPtr += ApiHead2.ListEntrySize;
 1e     endfor;
 
        return;
       end-proc;
