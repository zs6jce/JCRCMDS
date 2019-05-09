/*--------------------------------------------------------------------------*/
/* JCRCALL - Command prompt entry parms - CMD                               */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Command Prompt Entry Parms')
             PARM       KWD(PGM) TYPE(PGM) MIN(1) KEYPARM(*YES) +
                          PROMPT('Program to call')
 PGM:        QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(SRCFIL) TYPE(*CHAR) LEN(10) KEYPARM(*NO) +
                          PROMPT('Source File')
 
             PARM       KWD(SRCLIB) TYPE(*CHAR) LEN(10) KEYPARM(*NO) +
                          PROMPT('Source Lib')
 
             PARM       KWD(SRCMBR) TYPE(*CHAR) LEN(10) KEYPARM(*NO) +
                          PROMPT('Source Mbr')
 
             PARM       KWD(PGMATR) TYPE(*CHAR) LEN(10) KEYPARM(*NO) +
                          PROMPT('Program Attribute')
