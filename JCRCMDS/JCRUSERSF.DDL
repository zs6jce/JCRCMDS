--  ----------------------------------------------------------------
--   JCRUSERSF - Search User Profiles - DDL
--     Craig Rutledge  < www.jcrcmds.com >
--  ----------------------------------------------------------------
-- DROP TABLE JCRUSERSF;
 
CREATE TABLE JCRUSERSF (
  SFINITLIB     CHAR(10),
  SFOPT         char(1),
  SFUSRPRF      CHAR(10),
  SFTEXT        char(39),
  SFSTATUS      CHAR(10),
  SFINITPGM     CHAR(10),
  SFJOBD        CHAR(10),
  SFJOBDLIB     CHAR(10),
  SFOUTQ        CHAR(10),
  SFOUTQLIB     CHAR(10),
  SFLASTUSED    CHAR(10),
  WCADDRESS     CHAR(100))
  RCDFMT JCRUSERSFR  ;
 
LABEL ON TABLE JCRUSERSF
  IS 'Search User Profiles - outfile               jcr' ;
 
LABEL ON COLUMN JCRUSERSF
( SFUSRPRF   TEXT IS 'User Id' ,
  SFTEXT     TEXT IS 'Text' ,
  SFSTATUS   TEXT IS 'Status' ,
  SFINITPGM  TEXT IS 'Initial Pgm',
  SFINITLIB  TEXT IS 'Initial Lib',
  SFJOBD     TEXT IS 'Jobd' ,
  SFJOBDLIB  TEXT IS 'Jobd Lib',
  SFOUTQ     TEXT IS 'Outq',
  SFOUTQLIB  TEXT IS 'Outq Lib',
  SFLASTUSED TEXT IS 'Last Used',
  WCADDRESS  TEXT IS 'Email' ) ;
 
 GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
 ON JCRUSERSF TO PUBLIC WITH GRANT OPTION ;
