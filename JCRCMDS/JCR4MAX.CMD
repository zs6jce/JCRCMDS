/*--------------------------------------------------------------------------*/
/* JCR4MAX - Rpg4 source to full rpg4 syntax - CMD                          */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Maximize Conversion to RPG4')
             PARM       KWD(PGM) TYPE(*NAME) LEN(10) MIN(1) +
                          PGM(*YES) PROMPT('RPG program')
 
             PARM       KWD(SRCFILE) TYPE(SRCFILE) PROMPT('Source file')
 SRCFILE:    QUAL       TYPE(*NAME) LEN(10) DFT(QRPGLESRC) +
                          SPCVAL((QRPGLESRC))
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(STYLE) TYPE(*CHAR) LEN(6) RSTD(*YES) +
                          DFT(*LOWER) VALUES(*NONE *LOWER) +
                          PROMPT('Character Case')
