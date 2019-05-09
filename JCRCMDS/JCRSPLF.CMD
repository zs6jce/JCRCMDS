/*--------------------------------------------------------------------------*/
/* JCRSPLF - List spool files with Options - CMD                            */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('List Spool Files with Options')
 
             PARM       KWD(SELECT) TYPE(SELECTDS) CHOICE(*NONE) +
                          PROMPT('Select files for')
 
 SELECTDS:   ELEM       TYPE(*GENERIC) LEN(10) DFT(*CURRENT) +
                          SPCVAL((*CURRENT) (*ALL)) CHOICE('Name, +
                          generic*, *CURRENT, *ALL') PROMPT('User')
 
             ELEM       TYPE(*CHAR) LEN(10) DFT(*ALL) CHOICE('Name, +
                          *ALL') PROMPT('User data')
 
             ELEM       TYPE(OUTQ) PROMPT('Outq')
 
             ELEM       TYPE(*GENERIC) LEN(10) DFT(*ALL) +
                          SPCVAL((*ALL)) PROMPT('Spooled File')
 
             ELEM       TYPE(*NAME) LEN(10) DFT(*ALL) SPCVAL((*STD) +
                          (*ALL)) PROMPT('Form type')
 
 OUTQ:       QUAL       TYPE(*NAME) LEN(10) DFT(*ALL) SPCVAL((*ALL))
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
