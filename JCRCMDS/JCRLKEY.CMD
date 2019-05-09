/*--------------------------------------------------------------------------*/
/* JCRLKEY - Find desired access path - CMD                                 */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Find Desired Access Path')
             PARM       KWD(MBR) TYPE(*CHAR) LEN(10) CONSTANT('*FIRST')
 
             PARM       KWD(FILE) TYPE(FILE) MIN(1) PROMPT('File')
 FILE:       QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(INCLUDESO) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*YES *NO) +
                          PROMPT('Include logicals with S/O')
