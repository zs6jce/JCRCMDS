--  ----------------------------------------------------------------
--   JCRUFINDF- Find string in user spaces outfile - DDL
--     Craig Rutledge  < www.jcrcmds.com >
--  ----------------------------------------------------------------
-- DROP TABLE JCRUFINDF;
 
CREATE TABLE JCRUFINDF (
  SBFNAME CHAR(10) NOT NULL DEFAULT '' ,
  SBFCRTUSR CHAR(10) NOT NULL DEFAULT '' ,
  SBFLASTUDT CHAR(10) NOT NULL DEFAULT '' ,
  SBFSTRING CHAR(61) NOT NULL DEFAULT '' )
 
  RCDFMT JCRUFINDFR ;
 
LABEL ON TABLE JCRUFINDF
  IS 'Find string in user spaces - outfile          jcr' ;
 
LABEL ON COLUMN JCRUFINDF
( SBFNAME TEXT IS 'Space Name' ,
  SBFCRTUSR TEXT IS 'Created By' ,
  SBFLASTUDT TEXT IS 'Last Used' ,
  SBFSTRING TEXT IS 'String Where Found' ) ;
 
 GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
 ON JCRUFINDF TO PUBLIC WITH GRANT OPTION ;
