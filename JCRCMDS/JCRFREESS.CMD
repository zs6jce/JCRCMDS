/*--------------------------------------------------------------------------*/
/* JCRFREESS - Free/fixed side-by-side source view - CMD                    */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Free/Fixed Side-by-Side View')
             PARM       KWD(SRCMBR) TYPE(*NAME) LEN(10) MIN(1) +
                          PGM(*YES) PROMPT('RPG member')
 
             PARM       KWD(SRCFILE) TYPE(SRCFILE) PROMPT('Source file')
 SRCFILE:    QUAL       TYPE(*NAME) LEN(10) DFT(QRPGLESRC) +
                          SPCVAL((QRPGLESRC))
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*) VALUES(* *PRINT) PROMPT('Output')
