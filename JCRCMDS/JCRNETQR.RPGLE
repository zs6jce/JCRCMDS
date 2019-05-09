       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRNETQR - Send network file entire outq
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define Quslspl
       /define f_BuildString
       /define f_GetQual
       /define f_Quscrtus
       /define f_SndCompMsg
       /define f_SndStatMsg
       /define f_RunCmd
       /COPY JCRCMDS,JCRCMDSCPY
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_OutqQual char(20);
        p_ObjType char(10);
        p_ToUserid char(8);
        p_ToAddress char(8);
       end-pi;
       //---------------------------------------------------------
 
       f_SndStatMsg(f_BuildString('Sending from outq & to & - in progress':
       f_GetQual(p_OutqQual): p_ToAddress));
 
       // load user space with spooled file info
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
 
       callp QUSLSPL(
             UserSpaceName:
             'SPLF0300':
             '*ALL':
             p_OutqQual:
             '*ALL':
             '*ALL':
             ApiErrDS);
 
       // Process list entries in user space
       splf0300Ptr = ApiHeadPtr + ApiHead.OffSetToList;
 
 1b    for ForCount = 1 to ApiHead.ListEntryCount;
          f_RunCmd(f_BuildString('SNDNETSPLF FILE(&) TOUSRID((& &)) +
          JOB(&/&/&) SPLNBR(&)':
          splf0300DS.SplfName:
          p_ToUserid:
          p_ToAddress:
          splf0300DS.JobNo:
          splf0300DS.UserID:
          splf0300DS.JobName:
          %editc(%dec(splf0300DS.SplfNum:6:0):'X')));
          splf0300Ptr += ApiHead.ListEntrySize;
 1e    endfor;
 
       f_SndCompMsg(f_BuildString('& files were sent from & to &.':
       %char(ApiHead.ListEntryCount):
       f_GetQual(p_OutqQual):
       p_ToAddress));
       *inlr = *on;
       return;
