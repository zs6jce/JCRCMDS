/*--------------------------------------------------------------------------*/
/* JCR4PROTO - Convert *entry/call parms to prototypes - CMD                */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Generate Prototyped V4 RPGLE')
             PARM       KWD(RPG4MBR) TYPE(*NAME) MIN(1) PROMPT('RPG4 +
                          source member')
 
             PARM       KWD(RPG4SFL) TYPE(RPG4SFL) PROMPT('Source file')
 RPG4SFL:    QUAL       TYPE(*NAME) DFT(QRPGLESRC)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL)) +
                          PROMPT('Library')
 
             PARM       KWD(PROTMBR) TYPE(*NAME) MIN(1) PROMPT('New +
                          source member to generate')
 
             PARM       KWD(PROTSFL) TYPE(RPG4SFL) PROMPT('Source file')
