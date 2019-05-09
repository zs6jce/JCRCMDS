       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRANZOV - Validity checking program
       //---------------------------------------------------------
       /define ControlStatements
       /define Constants
       /define f_IsValidSrcType
       /define f_SndEscapeMsg
       /define p_JCRGETFILR
       // *ENTRY
       /define p_JCRANZOR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s string varchar(512);
       dcl-s IsPrinter ind inz(*off);
 
       //---------------------------------------------------------
 1b    if not f_IsValidSrcType(p_SrcFilQual: p_SrcMbr:'RPGLE': 'SQLRPGLE');
          f_SndEscapeMsg('Member ' + %trimr(p_SrcMbr) +
          ' is not type RPGLE or SQLRPGLE.');
 1e    endif;
 
       // retrieve the f specs then check for printer specs in the array
       callp p_JCRGETFILR(
             p_SrcMbr:
             p_SrcFilQual:
             FileCount:
             OnePerRcdFmt:
             FspecArry:
             CommentArry:
             PrNameArry:
             DeleteArry);
 
       //---------------------------------------------------------
 1b    for aa = FileCount downto 1;  // printer spec usually last
          string = %trimr(FspecArry(aa));
          string = %xlate(lo: up: string);
 
 2b       if %subst(string:16:1)= 'F' and %subst(string:30:4) = 'PRIN';
             IsPrinter = *on;
 1v          leave;
 2e       endif;
 
          bb = %scan('PRINTER(': string);
 2b       if bb>0 and %subst(string: bb+8: 1) <> '*';  //skip (*EXT)
             IsPrinter = *on;
 1v          leave;
 2e       endif;
 1e    endfor;
 
       //---------------------------------------------------------
 1b    if (not IsPrinter);
          f_SndEscapeMsg('Member ' + %trimr(p_SrcMbr) +
          ' does not have internal PRINTER specification.');
 1e    endif;
 
       *inlr = *on;
       return;
