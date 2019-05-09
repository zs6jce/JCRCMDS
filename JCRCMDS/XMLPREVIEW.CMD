/*--------------------------------------------------------------------------*/
/* XMLPREVIEW - Preview uploaded XML install members - CMD                  */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Preview XML Upload Members')
             PARM       KWD(UPLOADMBR) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Uploaded member')
 
             PARM       KWD(UPLOADSRCF) TYPE(UPLOADSRCF) MIN(1) +
                          PROMPT('Upload source file')
 UPLOADSRCF: QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(OUTPUTSRCF) TYPE(*NAME) LEN(10) +
                          DFT(*DEFAULTS) SPCVAL((*DEFAULTS +
                          '*DEFAULTS')) PROMPT('Output to this +
                          source file')
