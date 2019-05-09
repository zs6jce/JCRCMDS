/*--------------------------------------------------------------------------*/
/* JCRLSRC - List Pgm/Mod/Srvpgm Source information - CMD                   */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('List Pgm/Mod/Srvpgm Source')
             PARM       KWD(PGM) TYPE(PGM) MIN(1) PROMPT('Programs')
 PGM:        QUAL       TYPE(*GENERIC) LEN(10) SPCVAL((*ALL))
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*) VALUES(* *PRINT *OUTFILE) +
                          PROMPT('Output')
 
             PARM       KWD(OUTFILE) TYPE(OUTFILE) PMTCTL(PMTCTL1) +
                          PROMPT('Outfile')
 OUTFILE:    QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL) (*CURLIB)) PROMPT('Library')
 
 PMTCTL1:    PMTCTL     CTL(OUTPUT) COND((*EQ '*OUTFILE')) +
                          NBRTRUE(*EQ 1)
             PARM       KWD(OUTMBR) TYPE(OUTMBR) PMTCTL(PMTCTL1) +
                          PROMPT('Output member options')
 
 OUTMBR:     ELEM       TYPE(*NAME) LEN(10) DFT(*FIRST) +
                          SPCVAL((*FIRST)) PROMPT('Member to +
                          receive output')
             ELEM       TYPE(*CHAR) LEN(10) RSTD(*YES) DFT(*REPLACE) +
                          VALUES(*REPLACE *ADD) PROMPT('Replace or +
                          add records')
