/*--------------------------------------------------------------------------*/
/* JCRSDENT- Show Source Indentation - CMD                                  */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Print Indented Source Listing')
             PARM       KWD(SRCMBR) TYPE(*NAME) LEN(10) MIN(1) +
                          PGM(*YES) PROMPT('Source member')
 
             PARM       KWD(SRCFILE) TYPE(SRCFILE) PROMPT('Source file')
 SRCFILE:    QUAL       TYPE(*NAME) LEN(10) DFT(QRPGLESRC) +
                          SPCVAL((QRPGLESRC) (QCLSRC))
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*) VALUES(* *PRINT) PROMPT('Output')
