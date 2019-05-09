/*--------------------------------------------------------------------------*/
/* JCRFFD - File Field Descriptions - CMD                                   */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('File Field Descriptions')
             PARM       KWD(FILE) TYPE(FILE) MIN(1) PROMPT('File')
 FILE:       QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(RCDFMT) TYPE(*NAME) LEN(10) DFT(*FIRST) +
                          SPCVAL((*FIRST)) PROMPT('Record Format')
 
             PARM       KWD(UNPACK) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*NO *YES) PROMPT('Show +
                          unpacked format')
 
             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*) VALUES(* *PRINT *OUTFILE *SRC) +
                          PROMPT('Output')
 
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
             ELEM       TYPE(*CHAR) LEN(10) RSTD(*YES) DFT(*ADD) +
                          VALUES(*REPLACE *ADD) PROMPT('Replace or +
                          add records')
 
 PMTCTL1:    PMTCTL     CTL(OUTPUT) COND((*EQ '*OUTFILE') (*EQ +
                          '*SRC')) NBRTRUE(*EQ 1)
