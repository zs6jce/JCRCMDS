--  ----------------------------------------------------------------
--   JCRLSRCF - List Pgm/Mod/Srvpgm Source information - DDL
--     Craig Rutledge  < www.jcrcmds.com >
--  ----------------------------------------------------------------
-- DROP TABLE JCRLSRCF;
 
CREATE TABLE JCRLSRCF (
  LPGM CHAR(10) NOT NULL DEFAULT '' ,
  LSRCLIB CHAR(10) NOT NULL DEFAULT '' ,
  LSRCFIL CHAR(10) NOT NULL DEFAULT '' ,
  LSRCMBR CHAR(10) NOT NULL DEFAULT '' ,
  LSRCATTR CHAR(8) NOT NULL DEFAULT '' ,
  LCREATEDT CHAR(10) NOT NULL DEFAULT '' ,
  LLASTUSED CHAR(10) NOT NULL DEFAULT '' ,
  LDAYSUSED DECIMAL(4, 0) NOT NULL DEFAULT 0 ,
  LOBJTEXT CHAR(41) NOT NULL DEFAULT '' )
 
  RCDFMT JCRLSRCFR  ;
 
LABEL ON TABLE JCRLSRCF
  IS 'Source location - Pgm/Mod/Srvpgm info         jcr' ;
 
LABEL ON COLUMN JCRLSRCF
( LPGM TEXT IS 'Pgm Name' ,
  LSRCLIB TEXT IS 'Source Lib' ,
  LSRCFIL TEXT IS 'Source File' ,
  LSRCMBR TEXT IS 'Source Mbr' ,
  LSRCATTR TEXT IS 'Source Attr' ,
  LCREATEDT TEXT IS 'Create Date' ,
  LLASTUSED TEXT IS 'Last Used' ,
  LDAYSUSED TEXT IS 'Days Used' ,
  LOBJTEXT TEXT IS 'Text' ) ;
 
 GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
 ON JCRLSRCF TO PUBLIC WITH GRANT OPTION ;
