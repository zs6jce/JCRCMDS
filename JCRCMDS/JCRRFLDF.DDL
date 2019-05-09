--  ----------------------------------------------------------------
--   JCRRFLDF - Fields in RPG source - DDL
--     Craig Rutledge  < www.jcrcmds.com >
--  ----------------------------------------------------------------
-- DROP TABLE JCRRFLDF;
 
CREATE TABLE JCRRFLDF (
  JPGM CHAR(10) NOT NULL DEFAULT '' ,
  JSRCLIB CHAR(10) NOT NULL DEFAULT '' ,
  JSRCFIL CHAR(10) NOT NULL DEFAULT '' ,
  JFLDNAM CHAR(27) NOT NULL DEFAULT '' ,
  JDTATYP CHAR(16) NOT NULL DEFAULT '' ,
  JFLDTXT CHAR(24) NOT NULL DEFAULT '' ,
  JFLDSRC CHAR(10) NOT NULL DEFAULT '' ,
  JDIAGSEV CHAR(2) NOT NULL DEFAULT '' )
 
  RCDFMT JCRRFLDFR  ;
 
LABEL ON TABLE JCRRFLDF
  IS 'Fields in RPG source - outfile                jcr' ;
 
LABEL ON COLUMN JCRRFLDF
( JPGM TEXT IS 'Pgm Name' ,
  JSRCLIB TEXT IS 'Source Lib' ,
  JSRCFIL TEXT IS 'Source File' ,
  JFLDNAM TEXT IS 'Field Name' ,
  JDTATYP TEXT IS 'Data Type' ,
  JFLDTXT TEXT IS 'Text' ,
  JFLDSRC TEXT IS 'Defined' ,
  JDIAGSEV TEXT IS 'Severity' ) ;
 
 GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
 ON JCRRFLDF TO PUBLIC WITH GRANT OPTION ;
