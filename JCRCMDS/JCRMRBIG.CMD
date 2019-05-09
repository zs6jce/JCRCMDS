/*--------------------------------------------------------------------------*/
/* JCRMRBIG  - Print big 12 row by 13 column characters - CMD               */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Print Big Characters')
             PARM       KWD(CHARACTERS) TYPE(*CHAR) LEN(10) MIN(1) +
                          ALWUNPRT(*NO) PGM(*NO) PROMPT('String of +
                          Characters')
