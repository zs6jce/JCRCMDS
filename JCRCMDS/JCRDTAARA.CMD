/*--------------------------------------------------------------------------*/
/* JCRDTAARA - Dtaara values and rollover distance list - CMD               */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('List Dtaara *DEC Values')
             PARM       KWD(DTAARA) TYPE(DTAARA) MIN(1) PROMPT('Data Area')
 DTAARA:     QUAL       TYPE(*GENERIC) LEN(10) SPCVAL((*ALL))
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) SPCVAL((*ALL) +
                          (*ALLUSR) (*LIBL)) PROMPT('LIBRARY')
 
             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*PRINT) VALUES(* *PRINT) PROMPT('Output')
