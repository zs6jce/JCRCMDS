       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRSSQLE - execute selected SQL statements
       // uses *SYS naming convention of LIBRARY/FILE.
       //
       // Execute QSQCHKS sql API to verify sql statement syntax.
       //  If error return message with substitution values to caller.
       //  Execute non-select SQL statements via SQL CLI direct interface.
       //
       // MJR  Martin Rowe - srSELECT subroutine to execute
       // user utility EXCSQL for SELECT statements.
       // Get the EXCSQL utility from www.dbg400.net .
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define Constants
       /define f_Runcmd
       /define f_RtvMsgAPI
       /define f_IsValidObj
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s Select6 char(6);
       dcl-s Sql_Request varchar(2500) inz;
 
       // Verify Sql Statement Syntax
       dcl-pr qsQchks extpgm('QSQCHKS');
        *n char(32767) const options(*varsize);  // i_SqlStmt
        *n int(10) const;  // i_SqlStmtLen
        *n int(10) const;  // i_NumRcds
        *n char(10) const;  // i_Language
        *n char(32767) const options(*varsize);  // i_Options
        *n char(32767) options(*varsize);  // o_stmtInf
        *n int(10) const;  // i_StmtInfLen
        *n int(10); // o_numRcdsPrc
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds SqlOptionDS qualified;
        *n int(10) inz(1); // number of keys
        *n int(10) inz(1); // key value
        *n int(10) inz(10); // length of data
        *n char(10) inz('*SYS'); // data
       end-ds;
 
       dcl-ds SqlStmtInfoDS qualified inz;
        MsgFile char(10);
        MsgFileLib char(10);
        NumberOfStmt int(10);
        BytesReturned int(10);
        FirstByteRecNum int(10);
        FirstByteColNum int(10);
        LastByteRecNum int(10);
        LastByteColNum int(10);
        ErrorRecNum int(10);
        ErrorColNum int(10);
        MessageID char(7);
        SqlState char(5);
        LenMsgRplTxt int(10);
        MsgReplaceText char(128);
       end-ds;
 
       //---------------------------------------------------------
       // SQL Column types
       dcl-c SqlCHAR const(1);
       dcl-c SqlNUMERIC const(2);
       dcl-c SqlDECIMAL const(3);
       dcl-c SqlLONG const(4);
       dcl-c SqlSHORT const(5);
       dcl-c SqlFLOAT const(6);
       dcl-c SqlREAL const(7);
       dcl-c SqlDOUBLE const(8);
       dcl-c SqlDATE const(91);
       dcl-c SqlTIME const(92);
       dcl-c SqlTIMESTAMP const(93);
 
       // Sql constants
       dcl-c SqlNts const(-3);
       dcl-c SqlTrue const(1);
       dcl-c SqlDrop const(1);
       dcl-c CommitNone const(1);
       dcl-c SysNaming const(10002);
       dcl-c AttrCommit const(0);
       dcl-s SqlNumRcd int(10);
       dcl-s retCode int(10);
       dcl-s henv int(10);
       dcl-s hdbc int(10);
       dcl-s server char(10) inz('*LOCAL');
       dcl-s hstmt int(10);
       dcl-s cOptVal int(10);
 
       // Retrieve Error Information
       dcl-s sqlState char(5);
       dcl-s pfNativeErr int(10);
       dcl-s szErrMsg char(256);
       dcl-s cbErrMsg int(5);
 
       // Set environment attribute
       dcl-s envAttr int(10);
 
       //---------------------------------------------------------
       // Allocate Environment Handle
       dcl-pr SQLAllocEnv int(10) extproc(*dclcase);
        *n pointer value;  // enviroment handle
       end-pr;
 
       dcl-pr SQLBindCol int(10) extproc(*dclcase);
        *n int(10) value;  // statement handle
        *n int(5) value;  // column number
        *n int(5) value;  // data type
        *n pointer value;  // rgb value
        *n int(10) value;  // cb max value
        *n pointer value;  // pcb value
       end-pr;
 
       dcl-pr SQLSetEnvAttr int(10) extproc(*dclcase);
        *n int(10) value;  // enviroment handle
        *n int(10) value;  // attr
        *n pointer value;  // p value
        *n int(10) value;  // strlen
       end-pr;
 
       dcl-pr SQLAllocConnect int(10) extproc(*dclcase);
        *n int(10) value;  // enviroment handle
        *n pointer value;  // ptr to connection
       end-pr;
 
       dcl-pr SQLConnect int(10) extproc(*dclcase);
        *n int(10) value;  // connection handle
        *n pointer value options(*string);  // szdsn
        *n int(5) value;  // cbdsn
        *n pointer value options(*string);  // szuid
        *n int(5) value;  // cbuid
        *n pointer value options(*string);  // szauthstr
        *n int(5) value;  // cbauthstr
       end-pr;
 
       dcl-pr SQLSetConnectOption int(10) extproc(*dclcase);
        *n int(10) value;  // connection handle
        *n int(5) value;  // foption
        *n pointer value;  // vparam
       end-pr;
 
       dcl-pr SQLAllocStmt int(10) extproc(*dclcase);
        *n int(10) value;  // connection handle
        *n pointer value;  // phstmt
       end-pr;
 
       dcl-pr SQLExecDirect int(10) extproc(*dclcase);
        *n int(10) value;  // statement handle
        *n pointer value options(*string);  // szSqlStr
        *n int(10) value;  // cbSqlStr
       end-pr;
 
       dcl-pr SQLFreeStmt int(10) extproc(*dclcase);
        *n int(10) value;  // statement handle
        *n int(5) value;  // foption
       end-pr;
 
       dcl-pr SQLDisconnect int(10) extproc(*dclcase);
        *n int(10) value;  // connection handle
       end-pr;
 
       dcl-pr SQLFreeConnect int(10) extproc(*dclcase);
        *n int(10) value;  // connection handle
       end-pr;
 
       dcl-pr SQLFreeEnv int(10) extproc(*dclcase);
        *n int(10) value;  // rnvironment handle
       end-pr;
 
       dcl-pr SQLError int(10) extproc(*dclcase);
        *n int(10) value;  // environment handle
        *n int(10) value;  // hdbc
        *n int(10) value;  // hstmt
        *n pointer value;  // szSqlState
        *n pointer value;  // pfNativeErr
        *n pointer value;  // szErrMsg
        *n int(5) value;  // cbErrMsgMax
        *n pointer value;  // pcbErrMsg
       end-pr;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        i_ParmSql char(2500);
        i_ParmRtnMsg char(75);
       end-pi;
       //---------------------------------------------------------
 
       clear i_ParmRtnMsg;
       Select6 = %subst(i_ParmSql: 1: 6);
       Select6 = %xlate(lo: up: Select6);
 1b    if Select6 = 'SELECT';
          exsr srSELECT;
 1x    else;
 
          //---------------------------------------------------------
          // Check for valid sql statement
          //---------------------------------------------------------
          callp Qsqchks(
                i_ParmSql:
                %size(i_ParmSql):
                1:
                '*NONE':
                SqlOptionDS:
                SqlStmtInfoDS:
                %size(SqlStmtInfoDS):
                sqlNumRcd:
                ApiErrDS);
 
          // load return error message, exit program
 2b       if SqlStmtInfoDS.MessageID > *blanks;
             i_ParmRtnMsg =
             SqlStmtInfoDS.MessageID + ': ' +
             f_RtvMsgApi(
             SqlStmtInfoDS.MessageID:
             ApiErrDS.MsgReplaceVal:
             SqlStmtInfoDS.MsgFile + SqlStmtInfoDS.MsgFileLib);
             *inlr = *on;
             return;
 2e       endif;
 
          exsr srAllocateSql;
 
          // Execute SQL Statement
          retCode = SQLExecDirect(hstmt: i_ParmSql: SQLNTS);
 
 2b       If not(retCode = 0);
             retCode = SQLError(henv:
             hdbc:
             hstmt:
             %addr(sqlState):
             %addr(pfNativeErr):
             %addr(szErrMsg):
             %size(szErrMsg):
             %addr(cbErrMsg));
             i_ParmRtnMsg =
             %subst(szErrMsg: 1: cbErrMsg);
 2e       Endif;
 
          // disconnect and free sql handle -----
          retCode = SQLFreeStmt(hstmt: SQLDROP);
          retCode = SQLDisconnect(hdbc);
          retCode = SQLFreeConnect(hdbc);
          retCode = SQLFreeEnv(henv);
 
 2b       if i_ParmRtnMsg = *blanks;
             i_ParmRtnMsg = 'SQL completed normally.';
 2e       endif;
 1e    endif;
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       // Allocate SQL Environment Handle
       //---------------------------------------------------------
       begsr srAllocateSql;
       retCode = SQLAllocEnv(%addr(henv));
 
       // Set Environment Attribute
       envAttr = SQLTRUE;
       retCOde = SQLSetEnvAttr(
       henv:
       SysNaming:
       %addr(envAttr):
       0);
 
       // Allocate SQL Connection Handle
       retCode = SQLAllocConnect(henv: %addr(hdbc));
 
       retCode = SQLConnect(hdbc:
       server:
       SQLNTS:
       *null:
       SQLNTS:
       *null:
       SQLNTS);
 
       // Set Connection Attribute
       cOptVal = CommitNone;
       retCode = SQLSetConnectOption(hdbc: AttrCommit: %addr(cOptVal));
 
       // Allocate Statement Handle
       retCode = SQLAllocStmt(hdbc: %addr(hstmt));
       endsr;
 
       //---------------------------------------------------------
       // Check if the EXCSQL command is on board,
       // if so use it to run the SELECT statement
       // If EXCSQL not installed, select statements cannot be run.
       // This utility can be downloaded at www.dbg400.net
       // Subroutine code by Martin Rowe.
       //---------------------------------------------------------
       begsr srSELECT;
 1b    if f_IsValidObj('EXCSQL': '*LIBL': '*CMD');
 
          // format statement for EXCSQL.  double up single quotes inside string
          Sql_Request = qs + %trimr(i_ParmSql) + '  ';
          aa = %scan(qs: Sql_Request: 2);
 2b       dow aa > 0;
             Sql_Request = %replace(qs + qs: Sql_Request: aa: 1);
             aa = %scan(qs: Sql_Request: aa + 2);
 2e       enddo;
          Sql_Request = Sql_Request + qs;
 
          // Allow prompt if small enough to be prompted
 2b       if %len(Sql_Request) < 513;
             f_RunCmd('?excsql sql(' + %trim(Sql_Request) + ')');
 3b          if ApiErrDS.BytesReturned > 0;
                i_ParmRtnMsg = 'Error occurred on EXCSQL +
                command.  Please see joblog.';
 3e          endif;
 
 2x       else;
             i_ParmRtnMsg = 'SELECT statement too long +
             to prompt with EXCSQL. 512 char max.';
 2e       endif;
 1x    else;
          i_ParmRtnMsg = 'SELECT cannot be processed +
          without EXCSQL.';
 1e    endif;
       endsr;
