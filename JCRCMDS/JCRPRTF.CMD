/*--------------------------------------------------------------------------*/
/* JCRPRTF - Generate external print file from RPGLE Ospecs - CMD           */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Generate External Print File')
             PARM       KWD(RPGMBR) TYPE(*NAME) MIN(1) PROMPT('RPGLE4 +
                          source member')
 
             PARM       KWD(RPGSRCFIL) TYPE(RPGSRCFIL) +
                          PROMPT('Source file')
 RPGSRCFIL:  QUAL       TYPE(*NAME) DFT(QRPGLESRC)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL)) +
                          PROMPT('Library')
 
             PARM       KWD(PRTFMBR) TYPE(*NAME) MIN(1) PROMPT('DDS +
                          member to generate')
 
             PARM       KWD(PRTFSRCFIL) TYPE(PRTFSRCFIL) +
                          PROMPT('Source file')
 PRTFSRCFIL: QUAL       TYPE(*NAME) DFT(QDDSSRC) SPCVAL((QDDSSRC))
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL)) +
                          PROMPT('Library')
 
             PARM       KWD(USEREFFLD) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*YES *NO) PROMPT('Use +
                          REFFLD field references')
