/*--------------------------------------------------------------------------*/
/* JCRFD - File descriptions driver - CMD                                   */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('File Descriptions')
             PARM       KWD(MBR) TYPE(*CHAR) LEN(10) CONSTANT('*FIRST')
 
             PARM       KWD(FILE) TYPE(FILE) MIN(1) PROMPT('File')
 FILE:       QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(OBJTYP) TYPE(*CHAR) LEN(10) CONSTANT('*FILE')
             PARM       KWD(CALLING) TYPE(*CHAR) LEN(10) CONSTANT('JCRFD')
 
             PARM       KWD(VIEW) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*) VALUES(* *MBR *DBR) PROMPT('Initial View')
 
/* jcrlkey passes this parm      */
             PARM       KWD(KEYSTRING) TYPE(*CHAR) LEN(101) CONSTANT(' ')
 
/* prompt for member type if *MBR selected      */
 PMTCTL1:    PMTCTL     CTL(VIEW) COND((*EQ '*MBR'))
             PARM       KWD(MBRTYPE) TYPE(*CHAR) LEN(10) DFT(*ALL) +
                          PGM(*YES) PMTCTL(PMTCTL1) PROMPT('Member +
                          Type')
