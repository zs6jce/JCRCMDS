/*--------------------------------------------------------------------------*/
/* JCRIND - Indicator List - CMD                                            */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Indicator List')
             PARM       KWD(SRCMBR) TYPE(SRCMBR) MIN(1) MAX(3) PROMPT('Source')
 SRCMBR:     ELEM       TYPE(*NAME) LEN(10) PROMPT('Mbr')
             ELEM       TYPE(MBR) PROMPT(' File')
 
 MBR:        QUAL       TYPE(*NAME) LEN(10) DFT(QRPGLESRC) SPCVAL((QRPGLESRC))
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
