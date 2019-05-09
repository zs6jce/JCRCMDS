/*--------------------------------------------------------------------------*/
/* JCRRECRT - Recreate *CMD using existing values - CMD                     */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Recreate Command')
             PARM       KWD(CMD) TYPE(CMD) MIN(1) PROMPT('Command')
 CMD:        QUAL       TYPE(*SNAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(OBJTYP) TYPE(*CHAR) LEN(10) CONSTANT('*CMD')
