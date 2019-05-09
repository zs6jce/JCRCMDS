/*--------------------------------------------------------------------------*/
/* JCRIFSCPY - Copy from IFS directory - CMD                                */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Copy from IFS directory')
             PARM       KWD(PATHNAME) TYPE(*CHAR) LEN(50) +
                          DFT('/rutledgec/') PGM(*YES) PROMPT('IFS Path')
