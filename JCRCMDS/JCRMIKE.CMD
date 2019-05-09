/*--------------------------------------------------------------------------*/
/* JCRMIKE - show programs procedure location / source - CMD                */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Show Procedure Locations')
             PARM       KWD(PGMNAM) TYPE(PGNNAM) MIN(1) PGM(*YES) +
                          PROMPT('Program Object')
 PGNNAM:     QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(OBJTYP) TYPE(*CHAR) LEN(10) CONSTANT('*PGM')
 
             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*) VALUES(* *PRINT) PROMPT('Output')
