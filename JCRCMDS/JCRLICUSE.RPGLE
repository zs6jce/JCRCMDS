       //---------------------------------------------------------
       ctl-opt copyright('This program is free software, you can redistribute +
       it and/or modify it under the terms of the GNU General Public License +
       as published by the Free Software Foundation. See GNU General Public +
       License for detail.    Craig Rutledge      < www.jcrcmds.com > ');
       //---------------------------------------------------------
       // JCRLICUSE - List users with license lock
       // Change product id and feature subfield to monitor whatever product.
       //  Execute WRKLICINF command to get these values
       //   Currently set to monitor license usage for ASC Sequel
       //---------------------------------------------------------
       /define ControlStatements
       /define ApiErrDS
       /COPY JCRCMDS,JCRCMDSCPY
 
       dcl-s TextString char(6800);
       dcl-s TextStringLen int(10) inz(6800);
       dcl-s LineOfText char(68) dim(100) based(ptr);
       dcl-s ptr pointer inz(%addr(TextString));
       dcl-s MessageID char(7);
       dcl-s MessageFile char(20);
       dcl-s OutputFormat char(8) inz('LICR0200');
       dcl-s ReceiverLen int(10) inz(%len(ReceiverDS));
       dcl-s ProductFormat char(8) inz('LICP0100');
       dcl-s xx uns(3);
       dcl-s yy uns(3);
       dcl-s TotLicAlpha char(13);
 
       // Retrieve License Information
       dcl-pr QLZARTV extpgm('QLZARTV');
        *n char(2065);  // Receiver
        *n int(10);  // Length of Receiver
        *n char(8);  // Structure Format
        *n char(8);  // Product ID
        *n char(8);  // Product ID Format
        *n like(ApiErrDS);
       end-pr;
 
       dcl-ds JobDS len(26) qualified;
        JobName char(10) pos(1);
        UserName char(10) pos(11);
        Number char(6) pos(21);
       end-ds;
 
       // Similar to WRKLICINF command values
       dcl-ds ProductIDDS qualified;
        ProductID char(7) inz('0ASCSEQ');
        ReleaseLevel char(6) inz('*ONLY');
        Feature char(4) inz('5001');
       end-ds;
 
       dcl-ds ReceiverDS len(2065) qualified inz;
        UsageLimit int(10) pos(9);
        UsageCount int(10) pos(13);
        UsersOffset int(10) pos(97);
        UsersCount int(10) pos(101);
        UserLength int(10) pos(105);
       end-ds;
 
       // Display Long Text
       dcl-pr QUILNGTX  extpgm('QUILNGTX');
        *n char(6800) options(*varsize); // Text
        *n int(10); // Text Length
        *n char(7); // Message ID
        *n char(20); // Message File Name
        *n like(ApiErrDS);
       end-pr;
 
       //---------------------------------------------------------
       callp QLZARTV(
             ReceiverDS:
             ReceiverLen:
             OutputFormat:
             ProductIDds:
             ProductFormat:
             ApiErrDS);
 
       //---------------------------------------------------------
       // Load number of licenses available
 1b    if ReceiverDS.UsageLimit = -1;
          TotLicAlpha = '*NOMAX';
 1x    else;
          TotLicAlpha = %editc(ReceiverDS.UsageLimit:'1');
 1e    endif;
 
       LineOfText(1) = 'Licenses Available: ' +
       %trim(TotLicAlpha) +
       '   Licenses in Use: ' +
       %triml(%editc(ReceiverDS.UsageCount:'1'));
 
       //---------------------------------------------------------
       // spacer
       JobDS.JobName = '________';
       JobDS.UserName = '_________';
       JobDS.Number = '______';
       LineOfText(2) =
       JobDS.UserName + '    ' + JobDS.JobName + '    ' + JobDS.Number;
 
       //---------------------------------------------------------
       // generate headings
       JobDS.JobName = 'Job Name';
       JobDS.UserName = 'User Name';
       JobDS.Number = 'Number';
       LineOfText(3) =
       JobDS.UserName + '    ' + JobDS.JobName + '    ' + JobDS.Number;
 
       //---------------------------------------------------------
       // load license users
       yy = 3;
       ReceiverDS.UsersOffset += 1;
 1b    for xx = 1 to ReceiverDS.UsersCount;
          jobDS =
          %subst(ReceiverDs: ReceiverDS.UsersOffset: ReceiverDS.UserLength);
          ReceiverDS.UsersOffset += ReceiverDS.UserLength;
          yy += 1;
          LineOfText(yy) =
          JobDS.UserName + '    ' + JobDS.JobName + '    ' + JobDS.Number;
 1e    endfor;
 
       //---------------------------------------------------------
       // execute long text API
       callp QUILNGTX(
             TextString:
             TextStringLen:
             MessageID:
             MessageFile:
             ApiErrDS);
       *inlr = *on;
       return;
