/*--------------------------------------------------------------------------*/
/* JCRDUMP - Dump count by program - CMD                                    */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Dump Count by Program')
             PARM       KWD(OUTQ) TYPE(OUTQ) PROMPT('Outq')
 OUTQ:       QUAL       TYPE(*NAME) LEN(10) DFT(QEZDEBUG)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(OBJTYP) TYPE(*CHAR) LEN(10) CONSTANT('*OUTQ')
 
             PARM       KWD(DUMPDATE) TYPE(*DATE) DFT(*AVAIL) +
                          SPCVAL((*AVAIL 222222) (*CURRENT 333333) +
                          (*PRVDAY 444444)) PROMPT('Date (MMDDYYYY)' 1)
 
             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*) VALUES(* *PRINT) PROMPT('Output')
 
/* prompt for program name if DISPLAY selected. */
 PMTCTL1:    PMTCTL     CTL(OUTPUT) COND((*EQ *))
             PARM       KWD(PROGRAM) TYPE(PROGRAM) PGM(*YES) +
                          PMTCTL(PMTCTL1) PROMPT('Program')
 
 PROGRAM:    QUAL       TYPE(*NAME) LEN(10) DFT(*ALL) SPCVAL((*ALL *ALL))
             QUAL       TYPE(*NAME) LEN(10) PROMPT('Library')
