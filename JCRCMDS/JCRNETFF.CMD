/*--------------------------------------------------------------------------*/
/* JCRNETFF - Send multiple network files to multiple users - CMD           */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Send Multiple Network Files')
             PARM       KWD(LIBRARY) TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(FILES) TYPE(*CHAR) LEN(10) +
                          SPCVAL((' ')) MIN(1) MAX(10) +
                          CHOICE('NAME,GENERIC*') PROMPT('Files')
 
             PARM       KWD(TOUSRID) TYPE(USRLIST) MAX(5) +
                          PROMPT('User ID')
 USRLIST:    ELEM       TYPE(*CHAR) LEN(8) MIN(1) PROMPT('User ID')
             ELEM       TYPE(*CHAR) LEN(8) PROMPT('Address')
