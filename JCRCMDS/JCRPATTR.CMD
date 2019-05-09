/*--------------------------------------------------------------------------*/
/* JCRPATTR - Crtprtf with attributes from existing PRTF - CMD              */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Create from PRTF Attributes')
             PARM       KWD(PRTFMBR) TYPE(*NAME) MIN(1) PROMPT('PRTF +
                          source member')
 
             PARM       KWD(SRCFILE) TYPE(SRCFILE) PROMPT('Source file')
 SRCFILE:    QUAL       TYPE(*NAME) LEN(10) DFT(QDDSSRC) +
                          SPCVAL((QDDSSRC))
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(CRTLIB) TYPE(*NAME) DFT(*SRCLIB) +
                          SPCVAL((*SRCLIB)) PROMPT('Create PRTF in +
                          library')
 
             PARM       KWD(USEPRTF) TYPE(USEPRTF) MIN(1) +
                          PROMPT('Use Attributes from this Prtf')
 USEPRTF:    QUAL       TYPE(*SNAME) LEN(10) DFT(*SRCMBR) +
                          SPCVAL((*SRCMBR))
             QUAL       TYPE(*NAME) LEN(10) DFT(*SRCLIB) +
                          SPCVAL((*SRCLIB)) PROMPT('Library')
