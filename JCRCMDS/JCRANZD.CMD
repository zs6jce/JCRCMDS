/*--------------------------------------------------------------------------*/
/* JCRANZD - DSPF screen layout with field names - CMD                      */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('DSPF Screen Layout')
             PARM       KWD(DSPF) TYPE(DSPF) MIN(1) PGM(*YES) PROMPT('DSPF Object')
 DSPF:       QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(OBJTYP) TYPE(*CHAR) LEN(10) CONSTANT('*FILE')
 
             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*) VALUES(* *PRINT) PROMPT('Output')
