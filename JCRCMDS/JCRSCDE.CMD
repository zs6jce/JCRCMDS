/*--------------------------------------------------------------------------*/
/* JCRSCDE - Search/Copy Job Schedule Entries - CMD                         */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Search/Copy Job Schedule Entry')
             PARM       KWD(JOB) TYPE(*GENERIC) LEN(10) +
                          SPCVAL((*ALL)) PROMPT('Job Name')
             PARM       KWD(CMD) TYPE(*CHAR) LEN(20) SPCVAL((*ALL)) +
                          CHOICE(CONTAINS) PROMPT('Cmd Contains:')
