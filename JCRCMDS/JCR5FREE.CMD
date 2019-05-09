/*--------------------------------------------------------------------------*/
/* JCR5FREE - Convert V4 into V5 free format - CMD                         */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Generate v5 free from v4 RPGLE')
             PARM       KWD(RPG4MBR) TYPE(*NAME) MIN(1) PROMPT('RPG4 +
                          source member')
 
             PARM       KWD(RPG4SFL) TYPE(SRCFILE) PROMPT('Source file')
 
             PARM       KWD(RPG5MBR) TYPE(*NAME) MIN(1) PROMPT('Free +
                          member to generate')
 
             PARM       KWD(RPG5SFL) TYPE(SRCFILE) PROMPT('Source file')
 SRCFILE:    QUAL       TYPE(*NAME) DFT(QRPGLESRC)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL)) +
                          PROMPT('Library')
