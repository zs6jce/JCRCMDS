/*--------------------------------------------------------------------------*/
/* JCRUFIND - Find string in user spaces - CMD                              */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Find String in User Spaces')
             PARM       KWD(USERSPACE) TYPE(USERSPACE) MIN(1) +
                          PROMPT('User Space')
 USERSPACE:  QUAL       TYPE(*GENERIC) LEN(10) SPCVAL((*ALL))
             QUAL       TYPE(*NAME) LEN(10) PROMPT('Library')
 
             PARM       KWD(STRING1) TYPE(*CHAR) LEN(25) MIN(1) +
                          PROMPT('Scan string 1')
 
             PARM       KWD(RELATION) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          VALUES(*AND *OR ' ') PROMPT('Scan +
                          Relationship')
 
             PARM       KWD(STRING2) TYPE(*CHAR) LEN(25) +
                          PROMPT('Scan string 2')
 
             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*) VALUES(* *OUTFILE) PROMPT('Output')
 
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
 
 PMTCTL1:    PMTCTL     CTL(OUTPUT) COND((*EQ '*OUTFILE')) NBRTRUE(*EQ 1)
