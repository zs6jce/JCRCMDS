/*--------------------------------------------------------------------------*/
/* JCRNUMB - Number logic structures in RPGLE source - CMD                  */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Number Source - Reformat Free')
             PARM       KWD(PGM) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('RPG program')
 
             PARM       KWD(SRCFILE) TYPE(SRCFILE) PROMPT('Source file')
 SRCFILE:    QUAL       TYPE(*NAME) LEN(10) DFT(QRPGLESRC) +
                          SPCVAL((QRPGLESRC))
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(HIGH_LITE) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*YES *NO) +
                          PROMPT('Highlight comment lines')
 
             PARM       KWD(MATCHEND) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*YES *NO) PROMPT('Match +
                          ENDxx statements')
 
             PARM       KWD(INDENTFREE) TYPE(*CHAR) LEN(4) +
                          RSTD(*YES) DFT(*YES) VALUES(*YES *NO) +
                          PROMPT('Reformat RPG/free indentation')
 
             PARM       KWD(INDENTAMT) TYPE(*DEC) LEN(1) DFT(3) +
                          PROMPT('Spaces for indent level')
 
             PARM       KWD(RMV_EJECTS) TYPE(*CHAR) LEN(4) +
                          RSTD(*YES) DFT(*YES) VALUES(*YES *NO) +
                          PROMPT('Blank /eject and /space')
 
             PARM       KWD(CALLING) TYPE(*CHAR) LEN(10) CONSTANT('JCRNUMB')
