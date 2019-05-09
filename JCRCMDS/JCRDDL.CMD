/*--------------------------------------------------------------------------*/
/* JCRDDL - Generate data definition language member - CMD                  */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Generate Data Definition Mbr')
             PARM       KWD(FILE) TYPE(FILE) MIN(1) PROMPT('File')
 FILE:       QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 
             PARM       KWD(OBJTYPE) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(TABLE) VALUES(TABLE VIEW CONSTRAINT +
                          FUNCTION INDEX PROCEDURE SCHEMA ALIAS +
                          TRIGGER TYPE VIEW) PROMPT('Database +
                          Object Type')
 
             PARM       KWD(DDLMBR) TYPE(*NAME) MIN(1) PROMPT('New +
                          source member to generate')
 
             PARM       KWD(DDLFIL) TYPE(SRCFILE) PROMPT('Source file')
 SRCFILE:    QUAL       TYPE(*NAME) DFT(QDDSSRC)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL)) +
                          PROMPT('Library')
