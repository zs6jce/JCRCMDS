/*--------------------------------------------------------------------------*/
/* JCRNETFM - Send network file multiple members - CMD                      */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Send Network File Members')
             PARM       KWD(FILE) TYPE(FILE) PROMPT('File')
 FILE:       QUAL       TYPE(*NAME) LEN(10) DFT(QRPGLESRC) +
                          SPCVAL((QRPGLESRC))
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(TOUSRID) TYPE(TOUSRID) MIN(1) MAX(5) +
                          PROMPT('To User ID(s)')
 TOUSRID:    ELEM       TYPE(*CHAR) LEN(8) PROMPT('User ID')
             ELEM       TYPE(*CHAR) LEN(8) PROMPT('Address')
 
             PARM       KWD(MBRS) TYPE(MBRS) MIN(1) MAX(10) +
                          PROMPT('Member(s)')
 MBRS:       ELEM       TYPE(*CHAR) LEN(10) SPCVAL((*FIRST)) +
                          CHOICE('*First,*All,Generic*,Name') +
                          PROMPT('    Member')
             ELEM       TYPE(*CHAR) LEN(10) DFT(*ALL) SPCVAL((*ALL)) +
                          CHOICE('*ALL,RPGLE,RPG,CLP,DSPF,etc.') +
                          PROMPT('    Member Type')
