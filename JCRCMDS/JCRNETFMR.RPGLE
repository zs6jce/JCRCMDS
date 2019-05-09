       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRNETFMR - send multiple network file members - command processing program
       //  Spin through number of files to send and number user/systems.
       //   Build/execute command string to send file members(s).
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define Quslmbr
       /define f_BuildString
       /define f_GetQual
       /define f_Quscrtus
       /define f_RunCmd
       /define f_SndCompMsg
       // *ENTRY
       /define p_JCRNETFMR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s BldToUsr varchar(100);
       dcl-s OffsetToNext int(5) based(DisplacePtr);
       dcl-s OffsetToNext2 int(5) based(DisplacePtr2);
       dcl-s NumofMbrs int(5) based(p_MbrListPtr);
       dcl-s NumOfSndTo int(5) based(p_UsrListPtr);
       dcl-s SendCount uns(10);
 
       // Get number of user/system IDs and build DS to move though command list
       dcl-ds InnerList based(InnerListPtr) qualified;
        ToUser char(8) pos(3);
        ToSys char(8) pos(11);
       end-ds;
 
       // DS to move through command list
       dcl-ds InnerList2 based(InnerListPtr2) qualified;
        MbrName char(10) pos(3);
        MbrType char(10) pos(13);
       end-ds;
 
       //---------------------------------------------------------
       // overlay entry parms with DS definitions
       p_UsrListPtr = %addr(p_UsrList);
       p_MbrListPtr = %addr(p_MbrList);
 
       // Load users into single string
       // (touser tosys) (touser tosys)
       DisplacePtr = p_UsrListPtr + 2;
 
 1b    for ForCount2 = 1 to NumOfSndTo;
          InnerListPtr = p_UsrListPtr + OffsetToNext;
          BldToUsr += %trimr(f_BuildString(' (& &)':
          InnerList.ToUser: InnerList.ToSys));
          DisplacePtr += 2;
 1e    endfor;
 
       //---------------------------------------------------------
       // Spin though members, if any are generic*
       // create user space and retrieve pointer to user space.
       //---------------------------------------------------------
       DisplacePtr2 = p_MbrListPtr + 2;
 1b    for ForCount2 = 1 to NumofMbrs;
          InnerListPtr2 = p_MbrListPtr + OffsetToNext2;
 2b       if %scan('*': InnerList2.MbrName) > 0
             and InnerList2.MbrName <> '*FIRST';
             ApiHeadPtr = f_Quscrtus(UserSpaceName);
 1v          leave;
 2e       endif;
          DisplacePtr2 += 2;
 1e    endfor;
 
       //---------------------------------------------------------
       // If single member or *first
       //---------------------------------------------------------
       DisplacePtr2 = p_MbrListPtr + 2;
 1b    for ForCount2 = 1 to NumofMbrs;
          InnerListPtr2 = p_MbrListPtr + OffsetToNext2;
 
 2b       if %scan('*': InnerList2.MbrName) = 0
             or InnerList2.MbrName = '*FIRST';
             SendCount += 1;
             f_RunCmd(f_BuildString('SNDNETF FILE(&) TOUSRID(&) MBR(&)':
             f_GetQual(p_FileQual):
             BldToUsr: InnerList2.MbrName));
 
             //---------------------------------------------------------
             // If generic, execute member list API
             //---------------------------------------------------------
 2x       else;
             callp QUSLMBR(
                   UserSpaceName:
                   'MBRL0200':
                   p_FileQual:
                   InnerList2.MbrName:
                   '0':
                   ApiErrDS);
 
             QuslmbrPtr = ApiHeadPtr + ApiHead.OffSetToList;
 
 3b          for ForCount = 1 to ApiHead.ListEntryCount;
                // member type filter
 4b             if InnerList2.MbrType = '*ALL'
                   or InnerList2.MbrType = QuslmbrDS.MbrType;
                   SendCount += 1;
                   f_RunCmd(
                   f_BuildString('SNDNETF FILE(&) TOUSRID(&) MBR(&)':
                   f_GetQual(p_FileQual):
                   BldToUsr:
                   QuslmbrDS.MbrName));
 4e             endif;
                QuslmbrPtr += ApiHead.ListEntrySize;
 3e          endfor;
 2e       endif;
          DisplacePtr2 += 2;
 1e    endfor;
 
       f_SndCompMsg('JCRNETFMR sent ' + %char(SendCount) + ' members.');
       *inlr = *on;
       return;
