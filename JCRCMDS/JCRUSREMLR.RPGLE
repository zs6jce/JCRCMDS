       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRUSREMLR - User profile retrieve email address list
       //   EmailAddress = f_GetEmail(UserProfile);
       //    List user profiles with directory entries and have smtp defined.
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define Quslobj
       /define f_Quscrtus
       /define f_GetDayName
       /define f_DisplayLastSplf
       /define f_SndStatMsg
       /define f_GetEmail
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRUSREMLP printer oflind(IsOverFlow) usropn;
 
       dcl-s EmailAddress char(150);
 
       f_SndStatMsg('List user email address - in progress');
       open JCRUSREMLP;
       scDow = f_GetDayName();
 
       write PrtHead;
       IsOverFlow = *off;
 
       // load list of user profile names into user space
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
 
       callp QUSLOBJ(
             UserSpaceName:
             'OBJL0200':
             '*ALL      QSYS':
             '*USRPRF':
             ApiErrDS);
 
       QuslobjPtr = ApiHeadPtr + ApiHead.OffSetToList;
 1b    for ForCount = 1 to ApiHead.ListEntryCount;
 
          //-------------------------------------------------
          EmailAddress = f_GetEmail(QuslobjDS.ObjNam);
          //-------------------------------------------------
 
          // *blanks = user not defined in WRKDIRE.  @ = email address not setup in WRKDIRE
 2b       if not(EmailAddress = *blanks or EmailAddress = '@');
             PrtUser = QuslobjDS.ObjNam;
             PrtTxt = QuslobjDS.ObjText;
             PrtEmail = EmailAddress;
             write PrtDetail;
 2e       endif;
 
          QuslobjPtr += ApiHead.ListEntrySize;
 1e    endfor;
 
       close JCRUSREMLP;
       f_DisplayLastSplf('JCRUSREMLP': '*');
       *inlr = *on;
       return;
