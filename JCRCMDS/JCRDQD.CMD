/*--------------------------------------------------------------------------*/
/* JCRDQD - Data queue description display - CMD                            */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Data Queue Description Display')
             PARM       KWD(DTAQ) TYPE(DATAQ) MIN(1) PROMPT('Data Queue')
 DATAQ:      QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(OBJTYP) TYPE(*CHAR) LEN(10) CONSTANT('*DTAQ')
