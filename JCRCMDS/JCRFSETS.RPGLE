       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRFSETS - Scan File Set Where Used - submitter
       //  Save existing *LDA
       //   Load long list variables to *LDA
       //    sbmjob for print, run interactive for display
       //     Reset *LDA to previous value.
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define f_RunCmd
       /define f_SndCompMsg
       /define f_DisplayLastSplf
       // *ENTRY
       /define p_JCRFSETS
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s SavLda like(LdaDS);
 
       dcl-ds LdaDS DTAARA(*LDA) qualified;
        SrcFiles char(398);
        DataFileQual char(20);
        LfSameLib char(4);
        Output char(8);
        OutFileQual char(20);
        OutMbrOpt char(22);
       end-ds;
 
       dcl-pr p_JCRFSETR extpgm('JCRFSETR') end-pr;
 
       //---------------------------------------------------------
       SavLda = LdaDs;
       LdaDs.srcFiles = p_SrcFiles;
       LdaDS.DataFileQual = p_DtaFileQual;
       LdaDS.Output = p_Output;
       LdaDS.OutFileQual = p_OutFileQual;
       LdaDS.OutMbrOpt = p_OutMbrOpt;
       LdaDS.LfSameLib = p_LfSameLib;
       out LdaDS;
 
 1b    if p_Output = '*';
          callp p_JCRFSETR();  // interactive show spooled file
          f_DisplayLastSplf('JCRFSETR': p_Output);
 1x    else;
          f_RunCmd('SBMJOB CMD(CALL JCRFSETR) JOB(JCRFSET) JOBQ(QTXTSRCH)');
          f_SndCompMsg('Job JCRFSET submitted to job queue QTXTSRCH.');
 1e    endif;
 
       // replace original LDA
       LdaDs = SavLda;
       out LdaDS;
       *inlr = *on;
       return;
