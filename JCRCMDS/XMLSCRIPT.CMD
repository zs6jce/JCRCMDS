/*--------------------------------------------------------------------------*/
/* XMLSCRIPT- XML Script Member Viewer - CMD                                */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('XML Script Member Viewer')
             PARM       KWD(XMLSCRIPT) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Script member')
 
             PARM       KWD(SCRIPTSRCF) TYPE(SCRIPTSRCF) +
                          PROMPT('Script source file')
 SCRIPTSRCF: QUAL       TYPE(*NAME) LEN(10) DFT(QXMLGENS)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
