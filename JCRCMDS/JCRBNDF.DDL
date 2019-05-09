--  ----------------------------------------------------------------
--   JCRBNDF - Procedure names list - DDL
--     Craig Rutledge  < www.jcrcmds.com >
--  ----------------------------------------------------------------
-- DROP TABLE JCRBNDF;
 
CREATE TABLE JCRBNDF (
  JCRBNDDIR CHAR(10) NOT NULL DEFAULT '' ,
  JCRBNDDIRL CHAR(10) NOT NULL DEFAULT '' ,
  JCRSRVPGM CHAR(10) NOT NULL DEFAULT '' ,
  JCRSRVPGML CHAR(10) NOT NULL DEFAULT '' ,
  JCRMODULE CHAR(10) NOT NULL DEFAULT '' ,
  JCRMODULEL CHAR(10) NOT NULL DEFAULT '' ,
  JCRPROC CHAR(256) NOT NULL DEFAULT '' )
 
  RCDFMT JCRBNDFR   ;
 
LABEL ON TABLE JCRBNDF
  IS 'Procedure names list - outfile                jcr' ;
 
LABEL ON COLUMN JCRBNDF
( JCRBNDDIR TEXT IS 'Binding Object' ,
  JCRBNDDIRL TEXT IS 'Binding Lib' ,
  JCRSRVPGM TEXT IS 'Service Pgm' ,
  JCRSRVPGML TEXT IS 'Service Lib' ,
  JCRMODULE TEXT IS 'Module' ,
  JCRMODULEL TEXT IS 'Module lib' ,
  JCRPROC TEXT IS 'Procedure Name' ) ;
 
 GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
 ON JCRBNDF TO PUBLIC WITH GRANT OPTION ;
