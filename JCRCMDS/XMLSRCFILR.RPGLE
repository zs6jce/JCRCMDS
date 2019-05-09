       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // XMLSRCFILR - Generate XML for all members in source file
       //    call XMLGENR to generate XML text.
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /define Quslmbr
       /define f_BuildString
       /define f_Quscrtus
       /define SourceOutDS
       // *ENTRY
       /define p_XMLSRCFILR
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-f SCRIPT disk(112) usage(*output) extfile('QTEMP/XMLSRCFIL')
       extmbr(infile) usropn;
 
       dcl-s InFile char(10);
       dcl-s InLib char(10);
 
       // Generate XML source member
       dcl-pr p_XMLGENR extpgm('XMLGENR');
        *n char(10); // Script source member
        *n char(20) const; // Script Src fil lib
        *n char(20); // Output XML fil lib
       end-pr;
 
       //---------------------------------------------------------
       InFile = %subst(p_InFileQual: 1: 10);
       InLib = %subst(p_InFileQual:11: 10);
 
       // load user space with mbr name list for selected files
       ApiHeadPtr = f_Quscrtus(UserSpaceName);
 
       callp QUSLMBR(
             UserSpaceName:
             'MBRL0200':
             p_InFileQual:
             '*ALL':
             '0':
             ApiErrDS);
 
       // Process members in user space, write record to driver file
       open script;
       f_Write(' XMLGENINC  XINCLUDE(*YES)');
 
       QuslmbrPtr = ApiHeadPtr + ApiHead.OffSetToList;
 
 1b    for ForCount = 1 to ApiHead.ListEntryCount;
          f_Write(
          f_BuildString(' XMLGENMBR  XMBR(&) XMBRATR(&) XFROMSRCF(&) + ':
          QuslmbrDS.MbrName: QuslmbrDS.MbrType: InFile));
 
          f_Write(
          f_BuildString(' XFROMSRCL(&) XTOSRCF(&) XOBJTYPE(*N) XGENCRT(*NO)':
          InLib: InFile));
 
          QuslmbrPtr += ApiHead.ListEntrySize;
 1e    endfor;
 
       //---------------------------------------------------------
       // generate outfile
       close script;
       callp p_XMLGENR(InFile: 'XMLSRCFIL QTEMP': p_OutFileQual);
 
       *inlr = *on;
       return;
 
       //---------------------------------------------------------
       // Write generated code to outfile
       //---------------------------------------------------------
       dcl-proc f_Write;
        dcl-pi *n;
         pSrcCod char(100) const;
        end-pi;
 
        OutDS.Src100 = pSrcCod;
        OutDS.SrcSeq += .01;
        write SCRIPT OutDS;
        return;
       end-proc;
