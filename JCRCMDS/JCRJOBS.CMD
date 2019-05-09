/*--------------------------------------------------------------------------*/
/* JCRJOBS - Work with selected jobs - CMD     (proxy cmd JCRJOB)           */
/*   Craig Rutledge  < www.jcrcmds.com >                                    */
/*--------------------------------------------------------------------------*/
             CMD        PROMPT('Work With Selected Jobs')
             PARM       KWD(JOB) TYPE(JOB) PROMPT('Job')
 JOB:        QUAL       TYPE(*GENERIC) LEN(10) DFT(*ALL) SPCVAL((*ALL))
             QUAL       TYPE(*GENERIC) LEN(10) DFT(*CURRENT) +
                          SPCVAL((*ALL) (*CURRENT)) PROMPT('User')
             QUAL       TYPE(*CHAR) LEN(6) DFT(*ALL) PROMPT('Number')
 
             PARM       KWD(STATUS) TYPE(*CHAR) LEN(7) RSTD(*YES) +
                          DFT(*ACTIVE) VALUES(*ALL *ACTIVE *JOBQ +
                          *OUTQ) PROMPT('Status of jobs')
 
             PARM       KWD(THREAD) TYPE(*CHAR) LEN(4) DFT(*ALL) +
                          SPCVAL((*ALL *ALL)) PROMPT('Thread State (MSGW)')
 
             PARM       KWD(CURRUSER) TYPE(*NAME) LEN(10) DFT(*ALL) +
                          SPCVAL((*ALL)) PROMPT('Filter Current User:')
 
             PARM       KWD(JOBQ) TYPE(*GENERIC) LEN(10) DFT(*ALL) +
                          SPCVAL((*ALL *ALL)) PMTCTL(PMTCTL1) PROMPT('Jobq')
 
 PMTCTL1:    PMTCTL     CTL(STATUS) COND((*EQ '*JOBQ')) NBRTRUE(*EQ 1)
