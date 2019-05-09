/*--------------------------------------------------------------------------*/
/* JCRDQE - Data queue entries display  - CMD                               */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Data Queue Entries Display')
             PARM       KWD(DTAQ) TYPE(DTAQ) MIN(1) PROMPT('Data Queue')
 DTAQ:       QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(OBJTYP) TYPE(*CHAR) LEN(10) CONSTANT('*DTAQ')
