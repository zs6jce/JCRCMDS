/*--------------------------------------------------------------------------*/
/* JCRFSET - Scan File Set Where Used - CMD                                 */
/*  added special values to SRCFILE parm so groups of                       */
/*  files can be searched if value is selected.  Add records to             */
/*  file JCRSMLTCHF to select many source files with single keyword.        */
/*  NOTE: CHOICEKEY MUST START WITH * .                                     */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Scan File Set Where Used')
             PARM       KWD(FILE) TYPE(FILE) MIN(1) PROMPT('File')
 FILE:       QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(SRCFILE) TYPE(SRCFILE) MIN(1) MAX(9) +
                          PROMPT('Source File(s)')
 SRCFILE:    ELEM       TYPE(*CHAR) LEN(10) CHOICE(*PGM) +
                          CHOICEPGM(*LIBL/JCRSMLTRC) PROMPT('File')
             ELEM       TYPE(*NAME) LEN(10) PROMPT('  Library')
             ELEM       TYPE(*CHAR) LEN(10) DFT(*ALL) SPCVAL((*ALL)) +
                          CHOICE('*ALL, name, generic*') +
                          PROMPT('    Mbr')
             ELEM       TYPE(*CHAR) LEN(10) DFT(*ALL) SPCVAL((*ALL)) +
                          CHOICE('*ALL,RPGLE,CLP,DSPF,etc.') +
                          PROMPT('    Mbr Type')
 
             PARM       KWD(LFSAMELIB) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*YES *NO) PROMPT('Only +
                          LFs in samelib as PF')
 
             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*PRINT) VALUES(* *PRINT *OUTFILE) +
                          PROMPT('Output')
 
             PARM       KWD(OUTFILE) TYPE(OUTFILE) PMTCTL(PMTCTL1) +
                          PROMPT('Outfile')
 OUTFILE:    QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL) (*CURLIB)) PROMPT('Library')
 
             PARM       KWD(OUTMBR) TYPE(OUTMBR) PMTCTL(PMTCTL1) +
                          PROMPT('Output mbr options')
 OUTMBR:     ELEM       TYPE(*NAME) LEN(10) DFT(*FIRST) +
                          SPCVAL((*FIRST)) PROMPT('Mbr to receive output')
             ELEM       TYPE(*CHAR) LEN(10) RSTD(*YES) DFT(*REPLACE) +
                          VALUES(*REPLACE *ADD) PROMPT('Replace or +
                          add records')
 
 PMTCTL1:    PMTCTL     CTL(OUTPUT) COND((*EQ '*OUTFILE')) NBRTRUE(*EQ 1)
