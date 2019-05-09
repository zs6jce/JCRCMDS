/*--------------------------------------------------------------------------*/
/* XMLGENINC - PROMPT IN SCRIPT MEMBER TO INCLUDE INSTALLER PROGRAM IN XML  */
/* COPYRIGHT (C)       MARTIN ROWE  <MARTIN@DBG400.NET>  - CMD              */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Load Installer Program in XML')
             PARM       KWD(XINCLUDE) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          VALUES(*YES *NO) MIN(1) PROMPT('Load Installer Program in XML')
