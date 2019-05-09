/*--------------------------------------------------------------------------*/
/* JCROLCK - Object lock list-sndbrkmsg or endjob(*immed) - CMD             */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Jobs With Object Locks')
             PARM       KWD(OBJ) TYPE(OBJ) MIN(1) PROMPT('Object')
 OBJ:        QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(OBJTYPE) TYPE(*CHAR) LEN(10) DFT(*FILE) +
                          PROMPT('Object type')
