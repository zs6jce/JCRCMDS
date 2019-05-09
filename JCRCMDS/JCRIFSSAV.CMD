/*--------------------------------------------------------------------------*/
/* JCRIFSSAV - Copy savf to to IFS - CMD                                    */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Copy SAVF to IFS Path')
             PARM       KWD(SAVF) TYPE(*NAME) LEN(10) MIN(1) +
                          PGM(*YES) PROMPT('Save file')
 
             PARM       KWD(LIBRARY) TYPE(*NAME) LEN(10) MIN(1) +
                          PGM(*YES) PROMPT('Library')
 
             PARM       KWD(DIRECTORY) TYPE(*CHAR) LEN(50) +
                          DFT('/jcr/') PROMPT('IFS Directory path')
 
             PARM       KWD(ZIPFILE) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*YES *NO) PROMPT('Create +
                          .ZIP file')
