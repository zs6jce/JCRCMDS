       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRSMLTRS - Scan mult source file/mbrs - job submitter
       //  Save existing *LDA
       //   Load long list variables to *LDA
       //    sbmjob for print, run interactive for display
       //     Reset *LDA to previous value.
 
       // Normally, I DEPRECATE *LDA!!  (that would make a good bumper sticker). But
       // given the limitations of long parms on SBMJOB, this is the best choice.
       //---------------------------------------------------------
       /define ControlStatements
       /define f_RunCmd
       /define f_SndCompMsg
       /define f_DisplayLastSplf
       /define f_GetQual
       // *ENTRY
       /define p_JCRSMLTRS
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s SavLda like(LdaDS);
       dcl-s submitOutq char(21);
 
       dcl-ds LdaDS DTAARA(*LDA) qualified;
        SrcFiles char(398);
        ScanStrings char(272);
        Case char(4);
        IfContains char(7);
        Listlvl char(6);
        ScanComment char(5);
        From uns(3);
        To uns(3);
        Output char(8);
        OutqQual char(20);
        OutFileQual char(20);
        OutMbrOpt char(22);
       end-ds;
 
       dcl-pr p_JCRSMLTR extpgm('JCRSMLTR') end-pr;
 
       //---------------------------------------------------------
       SavLda = LdaDs;
       LdaDs.srcFiles = p_SrcFiles;
       LdaDS.Case = p_Case;
       LdaDS.IfContains = p_IfContains;
       LdaDS.SrcFiles = p_SrcFiles;
       LdaDS.Listlvl = p_Listlvl;
       LdaDS.ScanComment = p_ScanComment;
       LdaDS.From = p_From;
       LdaDS.To = p_To;
       LdaDS.Output = p_Output;
       LdaDS.OutqQual = p_OutqQual;
       LdaDS.OutFileQual = p_OutFileQual;
       LdaDS.OutMbrOpt = p_OutMbrOpt;
       LdaDS.ScanStrings = p_ScanStrings;
       out LdaDS;
 
       //-----------------------------------------------------------
 1b    if p_Output = '*';
          callp p_JCRSMLTR();  // interactive show spooled file
          f_DisplayLastSplf('JCRSMLTP': '*');
 
 1x    else;
 2b       if %subst(p_OutqQual:11:10) > *blanks;
             submitOutq = f_GetQual(p_OutqQual);
 2x       else;
 3b          if p_OutqQual = '*JOB';
                submitOutq = '*JOBD';
 3x          else;
                submitOutq = p_OutqQual;
 3e          endif;
 2e       endif;
 
          f_RunCmd('SBMJOB CMD(CALL JCRSMLTR) JOB(JCRSMLT) JOBQ(QTXTSRCH) +
          OUTQ(' + %trimr(submitOutq) + ')');
          f_SndCompMsg('Job JCRSMLT submitted to job queue QTXTSRCH.');
 1e    endif;
 
       // replace overlaid LDA
       LdaDs = SavLda;
       out LdaDS;
       *inlr = *on;
       return;
