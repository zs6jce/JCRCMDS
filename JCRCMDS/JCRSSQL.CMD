/*--------------------------------------------------------------------------*/
/* JCRSSQL - Scan strsql sessions for sql statements - CMD                  */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Scan Interactive SQL sessions')
             PARM       KWD(USERID) TYPE(*CHAR) LEN(10) +
                          DFT(*CURRENT) PROMPT('User ID')
