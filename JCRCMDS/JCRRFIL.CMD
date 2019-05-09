/*--------------------------------------------------------------------------*/
/* JCRRFIL - File Record Format xref for RPG source - CMD                   */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('File Record Format Xref')
             PARM       KWD(PGM) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('RPG program')
 
             PARM       KWD(SRCFILE) TYPE(SRCFILE) PROMPT('Source file')
 SRCFILE:    QUAL       TYPE(*NAME) LEN(10) DFT(QRPGLESRC) +
                          SPCVAL((QRPGLESRC))
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(CALLING) TYPE(*CHAR) LEN(10) CONSTANT('JCRRFIL')
