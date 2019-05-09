/*--------------------------------------------------------------------------*/
/* JCRUSPACE - User space data display - CMD                                */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('User Space Data Display')
             PARM       KWD(USERSPACE) TYPE(USERSPACE) MIN(1) +
                          PROMPT('User Space')
 USERSPACE:  QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
