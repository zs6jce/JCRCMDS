/*--------------------------------------------------------------------------*/
/* XMLGEN - Generate XML source member - CMD                                */
/* Martin Rowe  <Martin@dbg400.net> scripting cmd prompts                   */
/* David George intellectual input                                          */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Generate XML download mbrs')
             PARM       KWD(XMLSCRIPT) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Script member')
 
             PARM       KWD(SCRIPTSRCF) TYPE(SCRIPTSRCF) +
                          PROMPT('Script source file')
 SCRIPTSRCF: QUAL       TYPE(*NAME) LEN(10) DFT(QXMLGENS)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(SRCTOFILE) TYPE(SRCTOFILE) +
                          PROMPT('Source file to put XML member')
 SRCTOFILE:  QUAL       TYPE(*NAME) LEN(10) DFT(QXML)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
