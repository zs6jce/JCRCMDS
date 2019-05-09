/*--------------------------------------------------------------------------*/
/* JCRANZP - PRTF layout with field names print - CMD                       */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('PRTF Layout Print')
             PARM       KWD(PRTF) TYPE(*NAME) LEN(10) MIN(1) +
                          PGM(*YES) PROMPT('PRTF source member')
 
             PARM       KWD(SRCFILE) TYPE(SRCFILE) PROMPT('Source file')
 SRCFILE:    QUAL       TYPE(*NAME) LEN(10) DFT(QDDSSRC) SPCVAL((QDDSSRC))
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(SHOWNAMES) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*YES *NO) PROMPT('Show +
                          rcdfmts and field names')
 
             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*) VALUES(* *PRINT) PROMPT('Output')
