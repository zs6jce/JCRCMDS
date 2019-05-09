/*--------------------------------------------------------------------------*/
/* JCRIFSMBR - Copy source member to IFS - CMD                              */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Copy member to IFS Path')
             PARM       KWD(MBR) TYPE(*NAME) LEN(10) MIN(1) +
                          PGM(*YES) PROMPT('Member')
 
             PARM       KWD(FILE) TYPE(*NAME) LEN(10) MIN(1) +
                          PGM(*YES) PROMPT('File')
 
             PARM       KWD(LIBRARY) TYPE(*NAME) LEN(10) MIN(1) +
                          PGM(*YES) PROMPT('Library')
 
             PARM       KWD(ATTRIBUTE) TYPE(*CHAR) LEN(10) MIN(1) +
                          PGM(*YES) CHOICE('RPGLE, CLP, DSPF, PRTF, +
                          etc..') PROMPT('Member Attribute')
 
             PARM       KWD(DIRECTORY) TYPE(*CHAR) LEN(50) MIN(1) +
                          PROMPT('IFS Directory path')
 
             PARM       KWD(ZIPFILE) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*YES *NO) PROMPT('Create +
                          .ZIP file')
