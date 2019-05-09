       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRPRGENV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckMbr
       /define f_CheckObj
       /define f_IsValidMbr
       /define f_SrcFileAddPfm
       /define ApiErrDS
       /define f_GetQual
       /define f_SndEscapeMsg
       /define f_RunCmd
       // *ENTRY
       /define p_JCRPRGENR
       /COPY JCRCMDS,JCRCMDSCPY
 
       //---------------------------------------------------------
       f_CheckObj(p_PgmQual: '*PGM');
       f_CheckObj(p_InsertFileQual: '*FILE');
       f_CheckMbr(p_SrcFil + p_SrcLib: p_SrcMbr);
 
 1b    if f_IsValidMbr(p_InsertFileQual: p_InsertInMbr);
 
          // see if source mbr can be allocated, if not send err msg
          f_RunCmd('ALCOBJ OBJ((' + f_GetQual(p_InsertFileQual) +
          ' *FILE *EXCLRD ' + %trimr(p_InsertInMbr) + ')) WAIT(1)');
 
 2b       if ApiErrDS.BytesReturned > 0;
             f_SndEscapeMsg('Cannot allocate member ' +
             %trimr(p_InsertInMbr) + ' in source file ' +
             f_GetQual(p_InsertFileQual));
 2e       endif;
 
          f_RunCmd('DLCOBJ OBJ((' + f_GetQual(p_InsertFileQual) +
          ' *FILE *EXCLRD ' + %trimr(p_InsertInMbr) + '))');
 1x    else;
 
          f_SrcFileAddPfm(p_InsertFileQual: p_InsertInMbr: ' ': ' ':
          p_SrcFil + p_SrcLib: p_SrcMbr);
 1e    endif;
 
       *inlr = *on;
       return;
