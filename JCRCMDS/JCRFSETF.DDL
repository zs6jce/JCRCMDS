--  ----------------------------------------------------------------
--   JCRFSETF - Scan File Set Where Used outfile support - DDL
--     Craig Rutledge  < www.jcrcmds.com >
--  ----------------------------------------------------------------
-- DROP TABLE JCRFSETF;
 
CREATE TABLE JCRFSETF (
  SRCLIB CHAR(10) NOT NULL DEFAULT '' ,
  SRCFIL CHAR(10) NOT NULL DEFAULT '' ,
  LISTMBR CHAR(10) NOT NULL DEFAULT '' ,
  MBRTYPE CHAR(10) NOT NULL DEFAULT '' ,
  SRCTXT CHAR(40) NOT NULL DEFAULT '' ,
  SRCDTA CHAR(100) NOT NULL DEFAULT '' ,
  SCANFILE CHAR(10) NOT NULL DEFAULT '' ,
  SRELATEF CHAR(10) NOT NULL DEFAULT '' )
 
  RCDFMT JCRFSETFR  ;
 
LABEL ON TABLE JCRFSETF
  IS 'Scan file set where used - outfile            jcr' ;
 
LABEL ON COLUMN JCRFSETF
( SRCLIB TEXT IS 'Source library' ,
  SRCFIL TEXT IS 'Source file' ,
  LISTMBR TEXT IS 'Source mbr' ,
  MBRTYPE TEXT IS 'Mbr Type' ,
  SRCTXT TEXT IS 'Text' ,
  SRCDTA TEXT IS 'Source' ,
  SCANFILE TEXT IS 'Original File' ,
  SRELATEF TEXT IS 'Relation File' ) ;
 
 GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
 ON JCRFSETF TO PUBLIC WITH GRANT OPTION ;
