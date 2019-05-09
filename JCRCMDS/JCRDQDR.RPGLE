       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRDQDR - Data queue description display
       //---------------------------------------------------------
       /define ControlStatements
       /define FunctionKeys
       /define Dspatr
       /define Qmhqrdqd
       /define f_GetQual
       /define f_GetDayName
       /define f_BuildString
       /define f_SndCompMsg
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f JCRDQDD workstn infds(infds);
       dcl-ds Infds;
        InfdsFkey char(1) pos(369);
       end-ds;
 
       //-----Data queue entries display--------------
       dcl-pr  p_JCRDQER  extpgm('JCRDQER');
        *n char(20);  // p_dtaqnamequal
        *n char(10);  // p_dtaqobjtype
       end-pr;
 
       //--*ENTRY-------------------------------------------------
       dcl-pi *n;
        p_NameQual char(20);
        p_ObjType char(10);  // used by validity checker program
       end-pi;
       //---------------------------------------------------------
       scDow = f_GetDayName();
 
 1b    dou 1 = 2;
          callp QMHQRDQD(
                QmhqrdqdDS:
                %size(QmhqrdqdDS):
                'RDQD0100':
                p_NameQual);
 
          scQlen = QmhqrdqdDS.MsgLength;
          scEntries = QmhqrdqdDS.EntryCount;
          scCurAlc = QmhqrdqdDS.CurrAllocated;
          aShowKey = ND;
 
 2b       if QmhqrdqdDS.Sequence = 'F';
             scQsequen = '*FIFO';
 2x       elseif QmhqrdqdDS.Sequence = 'L';
             scQsequen = '*LIFO';
 2x       elseif QmhqrdqdDS.Sequence = 'K';
             scQsequen = '*KEYED';
             aShowKey = Green;
             scQkeylen = QmhqrdqdDS.KeyLength;
 2e       endif;
 
          scObjHead =
          f_BuildString('&  &  &':
          QmhqrdqdDS.DtaqName: QmhqrdqdDS.DtaqLib: QmhqrdqdDS.Text);
 
 2b       if QmhqrdqdDS.LocalOrDDM = '0';
             scDDM = 'Local';
 2x       else;
             scDDM = 'DDM';
 2e       endif;
 
          scMaxAllow = QmhqrdqdDS.MaxAllowed;
 
 2b       if QmhqrdqdDS.CreateSize = -1;
             scCrtSize = '*MAX16MB';
 2x       else;
             scCrtSize = '*MAX2GB';
 2e       endif;
 
          exfmt screen;
 2b       if InfdsFkey = f03 or InfdsFkey = f12;
             f_SndCompMsg('JCRDQD for ' +
             f_GetQual(p_NameQual) + ' - completed');
             *inlr = *on;
             return;
 2e       endif;
 
 2b       If InfdsFkey = f07;
             callp p_JCRDQER(p_NameQual: p_ObjType);
 2e       endif;
 
 1e    enddo;
