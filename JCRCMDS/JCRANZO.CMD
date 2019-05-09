/*--------------------------------------------------------------------------*/
/* JCRANZO - O spec layout with field names print - CMD                     */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('O SPEC Layout Print')
             PARM       KWD(PGM) TYPE(*NAME) LEN(10) MIN(1) +
                          PGM(*YES) PROMPT('RPG source member')
 
             PARM       KWD(SRCFILE) TYPE(SRCFILE) PROMPT('Source file')
 SRCFILE:    QUAL       TYPE(*NAME) LEN(10) DFT(QRPGLESRC) SPCVAL((QRPGLESRC))
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(SHOWNAMES) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*YES *NO) PROMPT('Show +
                          except and field names')
 
             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*) VALUES(* *PRINT) PROMPT('Output')
