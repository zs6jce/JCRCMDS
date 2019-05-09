/*--------------------------------------------------------------------------*/
/* JCROBJD - Expanded work with object descriptions - CMD                   */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Expanded Object Descriptions')
             PARM       KWD(OBJ) TYPE(OBJ) MIN(1) PROMPT('Object')
 OBJ:        QUAL       TYPE(*GENERIC) LEN(10) SPCVAL((*ALL))
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) SPCVAL((*ALL) +
                          (*ALLUSR) (*LIBL)) PROMPT('Library')
 
             PARM       KWD(OBJTYPE) TYPE(*CHAR) LEN(10) DFT(*ALL) +
                          PROMPT('Object type')
 
             PARM       KWD(EXTOBJATR) TYPE(*CHAR) LEN(10) DFT(*ALL) +
                          PROMPT('Object ATR (PF LF etc.)')
 
             PARM       KWD(CREATEDBY) TYPE(*CHAR) LEN(10) DFT(*ALL) +
                          CHOICE('*ALL, User Profile') +
                          PROMPT('Created by User Profile')
 
             PARM       KWD(ALLOWOPT) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*YES *NO) PROMPT('Allow +
                          Options Selection')
