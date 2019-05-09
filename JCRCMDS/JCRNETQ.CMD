/*--------------------------------------------------------------------------*/
/* JCRNETQ - Send network file entire outq - CMD                            */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Send Network Outq')
             PARM       KWD(OUTQ) TYPE(OUTQ) MIN(1) PROMPT('Outq')
 OUTQ:       QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(OBJTYP) TYPE(*CHAR) LEN(10) CONSTANT('*OUTQ')
 
             PARM       KWD(TOUSRID) TYPE(*CHAR) LEN(8) MIN(1) +
                          PROMPT('User ID')
 
             PARM       KWD(SYSTEM) TYPE(*CHAR) LEN(8) MIN(1) +
                          PROMPT('Address')
