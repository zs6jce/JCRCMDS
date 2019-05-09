/*--------------------------------------------------------------------------*/
/* XMLSRCFIL - Generate XML for all members in source file - CMD            */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('All mbrs to single XML mbr')
             PARM       KWD(INSRCFIL) TYPE(SOURCE) MIN(1) +
                          PROMPT('Input Source File')
 
             PARM       KWD(OUTSRCFIL) TYPE(SOURCE) MIN(1) +
                          PROMPT('Source file for XML out member')
 SOURCE:     QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
