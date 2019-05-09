/*--------------------------------------------------------------------------*/
/* JCRHFD - Rpg H,F,D to free - CMD                                         */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Rpg H,F,D to free')
             PARM       KWD(RPG4MBR) TYPE(*NAME) MIN(1) +
                          PROMPT('Input source member')
 
             PARM       KWD(INFILE) TYPE(INFILE) PROMPT('Source file')
 INFILE:     QUAL       TYPE(*NAME) DFT(QRPGLESRC)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL)) +
                          PROMPT('Library')
 
             PARM       KWD(FREEMBR) TYPE(*NAME) MIN(1) PROMPT('New +
                          source member to generate')
 
             PARM       KWD(FREEFIL) TYPE(INFILE) PROMPT('Source file')
