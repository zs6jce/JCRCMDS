       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRCALLV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define f_CheckObj
       /define f_SndEscapeMsg
       // *ENTRY
       /define p_JCRCALLR
       /COPY JCRCMDS,JCRCMDSCPY
 
       //---------------------------------------------------------
       f_CheckObj(p_PgmQual: '*PGM');
 
 1b    if not(p_Pgmatr = 'RPGLE' or
          p_Pgmatr = 'SQLRPGLE' or
          p_Pgmatr = 'CLP' or
          p_Pgmatr = 'CLLE');
          f_SndEscapeMsg('Program type ' + %trimr(p_Pgmatr) +
          ' is not type RPGLE, SQLRPGLE, CLP, or CLLE.');
 1e    endif;
 
       *inlr = *on;
       return;
