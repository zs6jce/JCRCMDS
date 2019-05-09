/*--------------------------------------------------------------------------*/
/* JCRDUPKEY - Duplicate keyed logicals list - CMD                          */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Duplicate Keyed Logicals List')
             PARM       KWD(MBR) TYPE(*CHAR) LEN(10) CONSTANT('*FIRST')
 
             PARM       KWD(FILE) TYPE(FILE) MIN(1) PROMPT('File')
 FILE:       QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*) VALUES(* *PRINT) PROMPT('Output')
