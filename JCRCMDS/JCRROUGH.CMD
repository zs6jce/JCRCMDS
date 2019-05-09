/*--------------------------------------------------------------------------*/
/* JCRROUGH - Create a rough DDS source from spooled file - CMD             */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Generate PRTF DDS from SPLF')
             PARM       KWD(INSERTINTO) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Insert DDS into SrcMbr')
 
             PARM       KWD(INSERTSRCF) TYPE(SRCFILE) PROMPT('Insert +
                          Source File')
 SRCFILE:    QUAL       TYPE(*NAME) LEN(10) DFT(QDDSSRC) +
                          SPCVAL((QDDSSRC))
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(CPYSPLFPF) TYPE(FTAG) MIN(1) +
                          PROMPT('Cpysplf PF File')
 FTAG:       QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
