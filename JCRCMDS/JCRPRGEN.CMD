/*--------------------------------------------------------------------------*/
/* JCRPRGEN - Generate callp prototype - CMD                                */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Generate Call Prototype')
             PARM       KWD(INSERTINTO) TYPE(*NAME) LEN(10) MIN(1) +
                          KEYPARM(*YES) PROMPT('Insert Prototype +
                          into SrcMbr')
 
             PARM       KWD(INSERTSRCF) TYPE(SRCFILE) KEYPARM(*YES) +
                          PROMPT('Insert Source File')
 SRCFILE:    QUAL       TYPE(*NAME) LEN(10) DFT(QRPGLESRC) +
                          SPCVAL((QRPGLESRC))
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(TOCALLPGM) TYPE(PGM) MIN(1) +
                          KEYPARM(*YES) PROMPT('Create Prototype to +
                          call Obj')
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
