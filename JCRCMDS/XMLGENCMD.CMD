/*--------------------------------------------------------------------------*/
/* XMLGENCMD - PROMPT IN SCRIPT MEMBER FOR COMMANDS TO EXECUTE              */
/* COPYRIGHT (C)       MARTIN ROWE  <MARTIN@DBG400.NET> - CMD               */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Script - Command Prompt')
             PARM       KWD(XCMD) TYPE(*CMDSTR) LEN(500) MIN(1) PROMPT('Command to execute')
