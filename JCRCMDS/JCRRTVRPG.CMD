/*--------------------------------------------------------------------------*/
/* JCRRTVRPG - Retrieve RPGLE source from compiled object - CMD             */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Retrieve RPGLE Source')
             PARM       KWD(RPGOBJECT) TYPE(RPGOBJECT) MIN(1) +
                          PROMPT('Object compiled *LIST or *ALL')
 RPGOBJECT:  QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(SRCMBR) TYPE(*NAME) LEN(10) +
                          PROMPT('RPGLE member to generate')
 
             PARM       KWD(SRCFILE) TYPE(SRCFILE) PROMPT('Source file')
 SRCFILE:    QUAL       TYPE(*NAME) LEN(10) DFT(QRPGLESRC) +
                          SPCVAL((QRPGLESRC))
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
