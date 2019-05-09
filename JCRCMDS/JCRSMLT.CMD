/*--------------------------------------------------------------------------*/
/* JCRSMLT - Scan mult source file/mbrs for mult strings - CMD              */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Scan Multiple Files / Strings')
             PARM       KWD(SCANSTRING) TYPE(*CHAR) LEN(25) MIN(1) +
                          MAX(10) VARY(*YES *INT2) CASE(*MIXED) +
                          PROMPT('Scan ''string''')
 
             PARM       KWD(CASENSITVE) TYPE(*CHAR) LEN(4) +
                          RSTD(*YES) DFT(*NO) VALUES(*YES *NO) +
                          PROMPT('Case Sensitive Search')
 
             PARM       KWD(IFCONTAINS) TYPE(*CHAR) LEN(7) +
                          RSTD(*YES) DFT(*ANY) VALUES(*ANY *ALL +
                          *NONE *NOTALL) PROMPT('If member contains +
                          string')
 
             PARM       KWD(SRCFILE) TYPE(SRCFILE) MIN(1) MAX(9) +
                          PROMPT('Source File(s)')
 SRCFILE:    ELEM       TYPE(*CHAR) LEN(10) CHOICE(*PGM) +
                          CHOICEPGM(*LIBL/JCRSMLTRC) PROMPT('File')
             ELEM       TYPE(*NAME) LEN(10) PROMPT('  Library')
             ELEM       TYPE(*CHAR) LEN(10) DFT(*ALL) SPCVAL((*ALL)) +
                          CHOICE('*ALL, name, generic*') +
                          PROMPT('    Member')
             ELEM       TYPE(*CHAR) LEN(10) DFT(*ALL) SPCVAL((*ALL)) +
                          CHOICE('*ALL,RPGLE,RPG,CL,DSPF,etc.') +
                          PROMPT('    Member Type')
 
             PARM       KWD(LISTLEVEL) TYPE(*CHAR) LEN(6) RSTD(*YES) +
                          DFT(*FIRST) VALUES(*FIRST *ALL) SPCVAL((* +
                          *ALL)) PROMPT('List occurrences in each mbr')
 
             PARM       KWD(SCANCMNT) TYPE(*CHAR) LEN(5) RSTD(*YES) +
                          DFT(*NO) VALUES(*NO *YES *ONLY) +
                          PROMPT('Scan Comment Lines')
 
             PARM       KWD(FROMPOS) TYPE(*DEC) LEN(3) DFT(1) +
                          PROMPT('Start Search FROM position')
             PARM       KWD(TOPOS) TYPE(*DEC) LEN(3) DFT(100) +
                          PROMPT('End Search TO position')
 
             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*PRINT) VALUES(* *PRINT *OUTFILE) +
                          PROMPT('Output')
 
             PARM       KWD(OUTQ) TYPE(OUTQ) PMTCTL(PMTCTL2) +
                          PROMPT('Outq')
 OUTQ:       QUAL       TYPE(*NAME) LEN(10) DFT(*JOB) SPCVAL((*JOB +
                          *JOB))
             QUAL       TYPE(*NAME) LEN(10) SPCVAL((*LIBL)) +
                          PROMPT('Library')
 
             PARM       KWD(OUTFILE) TYPE(OUTFILE) PMTCTL(PMTCTL1) +
                          PROMPT('Outfile')
 OUTFILE:    QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL) (*CURLIB)) PROMPT('Library')
 
             PARM       KWD(OUTMBR) TYPE(OUTMBR) PMTCTL(PMTCTL1) +
                          PROMPT('Output member options')
 OUTMBR:     ELEM       TYPE(*NAME) LEN(10) DFT(*FIRST) +
                          SPCVAL((*FIRST)) PROMPT('Member to +
                          receive output')
             ELEM       TYPE(*CHAR) LEN(10) RSTD(*YES) DFT(*REPLACE) +
                          VALUES(*REPLACE *ADD) PROMPT('Replace or +
                          add records')
 
 PMTCTL1:    PMTCTL     CTL(OUTPUT) COND((*EQ '*OUTFILE')) +
                          NBRTRUE(*EQ 1)
 PMTCTL2:    PMTCTL     CTL(OUTPUT) COND((*EQ '*PRINT')) NBRTRUE(*EQ 1)
