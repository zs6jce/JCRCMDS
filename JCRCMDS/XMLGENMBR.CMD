/*--------------------------------------------------------------------------*/
/* XMLGENMBR - PROMPT IN SCRIPT MEMBER FOR SOURCE MEMBER INFORMATION        */
/*             TO LOAD MEMBERS INTO OUTPUT FILE.                            */
/* COPYRIGHT (C)       MARTIN ROWE  <MARTIN@DBG400.NET> - CMD               */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Script - Source member info')
             PARM       KWD(XMBR) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Member')
 
             PARM       KWD(XMBRATR) TYPE(*NAME) LEN(10) MIN(1) +
                          CHOICE('RPGLE CLP DSPF CMD etc') +
                          PROMPT('Source member attribute')
 
             PARM       KWD(XFROMSRCF) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Copy from source file')
 
             PARM       KWD(XFROMSRCL) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Copy from source lib')
 
             PARM       KWD(XTOSRCF) TYPE(*NAME) LEN(10) MIN(1) +
                          CHOICE('QRPGLESRC QCLSRC QDDSSRC etc') +
                          PROMPT('Target source file')
 
             PARM       KWD(XOBJTYPE) TYPE(*CHAR) LEN(7) RSTD(*YES) +
                          VALUES(*CMD *FILE *MENU *MODULE *PGM +
                          *PNLGRP *QMQRY *SQLPKG *SRVPGM *TBL +
                          *BNDSRC *CPYSRC) MIN(1) PROMPT('Object type')
 
             PARM       KWD(XGENCRT) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          VALUES(*YES *NO) MIN(1) PROMPT('Generate +
                          compile code for mbr')
