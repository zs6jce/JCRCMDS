/*--------------------------------------------------------------------------*/
/* JCRDBR - Data base relations done quicker - CMD                          */
/*  Front-ends the JCRFDR program going straight to DBR                     */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Expanded Data Base Relations')
             PARM       KWD(MBR) TYPE(*CHAR) LEN(10) CONSTANT('*FIRST')
 
             PARM       KWD(FILE) TYPE(FILE) MIN(1) PROMPT('File')
 FILE:       QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(OBJTYP) TYPE(*CHAR) LEN(10) CONSTANT('*FILE')
             PARM       KWD(CALLING) TYPE(*CHAR) LEN(10) CONSTANT('JCRDBR')
             PARM       KWD(VIEW) TYPE(*CHAR) LEN(4) CONSTANT('*DBR')
             PARM       KWD(KEYSTRING) TYPE(*CHAR) LEN(101) CONSTANT(' ')
             PARM       KWD(MBRTYPE) TYPE(*CHAR) LEN(10) CONSTANT('*ALL')
