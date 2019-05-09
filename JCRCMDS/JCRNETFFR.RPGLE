       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRNETFFR - Send multiple network files to multiple users
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define f_Quscrtus
       /define Quslobj
       /define f_GetQual
       /define f_RunCmd
       // *ENTRY
       /define p_JCRNETFFR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s BldSpace char(1);
       dcl-s BldToUsr varchar(100);
       dcl-s OffsetToNext int(5) based(DisplacePtr);
       dcl-s NumOfFiles uns(3);
       dcl-s xx uns(3);
       dcl-s p_UsrListPtr pointer;
 
       // Get number of user/system IDs and build DS to move though command list
       dcl-ds InnerList based(InnerListPtr) qualified;
        ToUser char(8) pos(3);
        ToSys char(8) pos(11);
       end-ds;
 
       //---------------------------------------------------------
       //* overlay entry parms with DS definitions
       p_UsrListPtr = %addr(p_UsrList);
 
       // Load users into single string (touser tosys) (touser tosys)
       DisplacePtr = p_UsrListPtr;
 1b    for ForCount = 1 to p_UsrList.Count;
          DisplacePtr += 2;
          InnerListPtr = p_UsrListPtr + OffsetToNext;
          BldToUsr = BldToUsr + BldSpace + '(' +
          %trimr(InnerList.ToUser) + ' ' +
          %trimr(InnerList.ToSys) + ')';
          BldSpace = ' ';
 1e    endfor;
 
       // process files in list
 
 1b    for xx = 1 to p_FileList.Count;
 2b       if %scan('*':p_FileList.Arry(xx)) > 0;
 
             // Create user space/retrieve pointer to user space
             ApiHeadPtr = f_Quscrtus(UserSpaceName);
 
             callp QUSLOBJ(
                   UserSpaceName:
                   'OBJL0200':
                   p_FileList.Arry(xx) + p_Lib:
                   '*FILE':
                   ApiErrDS);
 
             QuslobjPtr = ApiHeadPtr + ApiHead.OffSetToList;
 
 3b          for ForCount = 1 to ApiHead.ListEntryCount;
 4b             if  QuslobjDS.ExtendedAttr = 'PF';
                   f_RunCmd('SNDNETF FILE(' +
                   f_GetQual(QuslobjDS.ObjNam + QuslobjDS.ObjLib) +
                   ') TOUSRID(' + BldToUsr + ')');
 4e             endif;
                QuslobjPtr += ApiHead.ListEntrySize;
 3e          endfor;
 
 2x       else;
             f_RunCmd('SNDNETF FILE(' +
             f_GetQual(p_FileList.Arry(xx) + p_Lib) +
             ') TOUSRID(' + BldToUsr + ')');
 2e       endif;
 1e    endfor;
       *inlr = *on;
       return;
