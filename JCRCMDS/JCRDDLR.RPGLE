       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRDDLR - Generate data definition language member
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define f_SndCompMsg
       /define f_GetQual
       // *ENTRY
       /define p_JCRDDLR
       /COPY JCRCMDS,JCRCMDSCPY
 
       // Generate Data Definition Language
       dcl-pr QSQGNDDL extpgm('QSQGNDDL');
        *n like(sqlr0100DS);
        *n int(10) const;
        *n char(8) const;
        *n like(apierrds);
       end-pr;
 
       dcl-ds sqlr0100DS qualified inz;
        ObjNam char(258) pos(1);
        ObjLib char(258) pos(259);
        ObjTyp char(10) pos(517);
        SrcFil char(10) pos(527);
        SrcLib char(10) pos(537);
        SrcMbr char(10) pos(547);
        SecLvl int(10) pos(557) inz(10);
        Replace char(1) pos(561) inz('1');  // clear source member
        Formatting char(1) pos(562) inz('0'); // no additonal formatting
        DateFormat char(3) pos(563) inz('ISO');
        DateSeparator char(1) pos(566) inz('-');
        TimeFormat char(3) pos(567) inz('ISO');
        TimeSeparator char(1) pos(570) inz(':');
        NamingOption char(3) pos(571) inz('SYS');  // lib/file
        DecimalPoint char(1) pos(574) inz('.');
        StandardsOption char(1) pos(575) inz('0'); // db2 standards
        DropOption char(1) pos(576) inz('1'); // do not generate
        MessageLevel int(10) pos(577) inz(0);
        CommentOption char(1) pos(581) inz('0'); // no comments
        LabelOption char(1) pos(582) inz('1');  // generate label on
        HeaderOption char(1) pos(583) inz('1'); // generate header
        Reserved char(1) pos(584) inz(x'00');
       end-ds;
 
       sqlr0100DS.ObjNam = %subst(p_InFileQual: 1: 10);
       sqlr0100DS.ObjLib = %subst(p_InFileQual: 11: 10);
       sqlr0100DS.ObjTyp = p_ObjTyp;
       sqlr0100DS.SrcFil = %subst(p_OutFileQual: 1: 10);
       sqlr0100DS.SrcLib = %subst(p_OutFileQual: 11: 10);
       sqlr0100DS.SrcMbr = p_OutMbr;
 
       callp QSQGNDDL(
             sqlr0100DS:
             %len(sqlr0100DS):
             'SQLR0100':
             ApiErrDS);
 
       f_SndCompMsg('Data Definition Generation member ' +
       %trimr(p_OutMbr) + ' in ' +
       %trimr(f_GetQual(p_OutFileQual)) + ' - completed.');
 
       *inlr = *on;
       return;
