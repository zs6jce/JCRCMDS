/*--------------------------------------------------------------------------*/
/* JCRUSRAUT - List user profile class/special authorities - CMD            */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('List User Class/Authorities')
             PARM       KWD(USERCLASS) TYPE(*CHAR) LEN(7) RSTD(*YES) +
                          DFT(*ALL) VALUES(*SECOFR *SECADM *PGMR +
                          *SYSOPR *USER *ALL) PROMPT('User Class')
 
             PARM       KWD(SPECIALAUT) TYPE(*CHAR) LEN(9) +
                          RSTD(*YES) DFT(*ALL) VALUES(*ALLOBJ +
                          *SECADM *JOBCTL *SPLCTL *SAVSYS *SERVICE +
                          *AUDIT *IOSYSCFG *ALL) MAX(8) +
                          PROMPT('Special Authorities')
 
             PARM       KWD(STATUS) TYPE(*CHAR) LEN(9) RSTD(*YES) +
                          DFT(*ENABLED) VALUES(*ENABLED *DISABLED +
                          *ALL) PROMPT('Status')
 
             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*) VALUES(* *PRINT) PROMPT('Output')
