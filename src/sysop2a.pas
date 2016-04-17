{*******************************************************}
{                                                       }
{   Renegade BBS                                        }
{                                                       }
{   Copyright (c) 1990-2013 The Renegade Dev Team       }
{   Copyleft  (ↄ) 2016 Renegade BBS                     }
{                                                       }
{   This file is part of Renegade BBS                   }
{                                                       }
{   Renegade is free software: you can redistribute it  }
{   and/or modify it under the terms of the GNU General }
{   Public License as published by the Free Software    }
{   Foundation, either version 3 of the License, or     }
{   (at your option) any later version.                 }
{                                                       }
{   Renegade is distributed in the hope that it will be }
{   useful, but WITHOUT ANY WARRANTY; without even the  }
{   implied warranty of MERCHANTABILITY or FITNESS FOR  }
{   A PARTICULAR PURPOSE.  See the GNU General Public   }
{   License for more details.                           }
{                                                       }
{   You should have received a copy of the GNU General  }
{   Public License along with Renegade.  If not, see    }
{   <http://www.gnu.org/licenses/>.                     }
{                                                       }
{*******************************************************}
{   _______                                  __         }
{  |   _   .-----.-----.-----.-----.---.-.--|  .-----.  }
{  |.  l   |  -__|     |  -__|  _  |  _  |  _  |  -__|  }
{  |.  _   |_____|__|__|_____|___  |___._|_____|_____|  }
{  |:  |   |                 |_____|                    }
{  |::.|:. |                                            }
{  `--- ---'                                            }
{*******************************************************}

{$i Renegade.Common.Defines.inc}

UNIT SysOp2A;

INTERFACE

PROCEDURE MainBBSConfiguration;

IMPLEMENTATION

USES
  Crt,
  Common,
  SysOp7,
  TimeFunc;

  PROCEDURE GetTimeRange(CONST RGStrNum: LongInt; VAR LoTime,HiTime: SmallInt);
  VAR
    TempStr: Str5;
    LowTime,
    HighTime: Integer;
  BEGIN
    IF (NOT (PYNQ(RGSysCfgStr(RGStrNum,TRUE),0,FALSE))) THEN
    BEGIN
      LowTime := 0;
      HighTime := 0;
    END
    ELSE
    BEGIN
      NL;
      Print('All entries in 24 hour time.  Hour: (0-23), Minute: (0-59)');
      NL;
      Prt('Starting time: ');
      MPL(5);
      InputFormatted('',TempStr,'##:##',TRUE);
      IF (StrToInt(Copy(TempStr,1,2)) IN [0..23]) AND (StrToInt(Copy(TempStr,4,2)) IN [0..59]) THEN
        LowTime := ((StrToInt(Copy(TempStr,1,2)) * 60) + StrToInt(Copy(TempStr,4,2)))
      ELSE
        LowTime := 0;
      NL;
      Prt('Ending time: ');
      MPL(5);
      InputFormatted('',TempStr,'##:##',TRUE);
      IF (StrToInt(Copy(TempStr,1,2)) IN [0..23]) AND (StrToInt(Copy(TempStr,4,2)) IN [0..59]) THEN
        HighTime := ((StrToInt(Copy(TempStr,1,2)) * 60) + StrToInt(Copy(TempStr,4,2)))
      ELSE
        HighTime := 0;
    END;
    NL;
    Print('Hours: '+PHours('Always allowed',LowTime,HighTime));
    NL;
    IF PYNQ('Are you sure this is what you want? ',0,FALSE) THEN
    BEGIN
      LoTime := LowTime;
      HiTime := HighTime;
    END;
  END;

PROCEDURE MainBBSConfiguration;
VAR
  LineFile: FILE OF LineRec;
  Cmd: Char;
  Changed: Boolean;
BEGIN
  Assign(LineFile,General.DataPath+'NODE'+IntToStr(ThisNode)+'.DAT');
  Reset(LineFile);
  Seek(LineFile,0);
  Read(LineFile,Liner);
  REPEAT
    WITH General DO
    BEGIN
      Abort := FALSE;
      Next := FALSE;
      RGSysCfgStr(1,FALSE);
      OneK(Cmd,'QABCDEFGHIJKLMN0123456789'^M,TRUE,TRUE);
      CASE Cmd OF
        'A' : BEGIN
                InputWNWC(RGSysCfgStr(2,TRUE),BBSName,(SizeOf(BBSName) - 1),Changed);
                InputFormatted(RGSysCfgStr(3,TRUE),BBSPhone,'###-###-####',FALSE);
              END;
        'B' : InputWN1(RGSysCfgStr(4,TRUE),Liner.NodeTelnetURL,(SizeOf(Liner.NodeTelnetURL) - 1),[InteractiveEdit],Changed);
        'C' : InputWN1(RGSysCfgStr(5,TRUE),SysOpName,(SizeOf(SysOpName) - 1),[InterActiveEdit],Changed);
        'D' : RGNoteStr(0,FALSE);
        'E' : IF (InCom) THEN
                RGNoteStr(1,FALSE)
              ELSE
                GetTimeRange(6,lLowTime,HiTime);
        'F' : GetTimeRange(7,MinBaudLowTime,MinBaudHiTime);
        'G' : GetTimeRange(8,DLLowTime,DLHiTime);
        'H' : GetTimeRange(9,MinBaudDLLowTime,MinBaudDLHiTime);
        'I' : BEGIN
                REPEAT
                  RGSysCfgStr(10,FALSE);
                  OneK(Cmd,^M'ABC',TRUE,TRUE);
                  CASE Cmd OF
                    'A' : InputWN1(RGSysCfgStr(11,TRUE),SysOpPw,(SizeOf(SysOpPW) - 1),[InterActiveEdit,UpperOnly],Changed);
                    'B' : InputWN1(RGSysCfgStr(12,TRUE),NewUserPW,(SizeOf(SysOpPW) - 1),[InterActiveEdit,UpperOnly],Changed);
                    'C' : InputWN1(RGSysCfgStr(13,TRUE),MinBaudOverride,(SizeOf(SysOpPW) - 1),
                                   [InterActiveEdit,UpperOnly],Changed);
                  END;
                UNTIL (Cmd = ^M) OR (HangUp);
                Cmd := #0;
              END;
        'J' : InputByteWOC(RGSysCfgStr(14,TRUE),EventWarningTime,[DisplayValue,NumbersOnly],0,255);
        'K' : BEGIN
                REPEAT
                  RGSysCfgStr(15,FALSE);
                  OneK(Cmd,^M'123456Q',TRUE,TRUE);
                  CASE Cmd OF
                    '1' : FindMenu(RGSysCfgStr(16,TRUE),GlobalMenu,0,NumMenus,Changed);
                    '2' : FindMenu(RGSysCfgStr(17,TRUE),AllStartMenu,1,NumMenus,Changed);
                    '3' : FindMenu(RGSysCfgStr(18,TRUE),ShuttleLogonMenu,0,NumMenus,Changed);
                    '4' : FindMenu(RGSysCfgStr(19,TRUE),NewUserInformationMenu,1,NumMenus,Changed);
                    '5' : FindMenu(RGSysCfgStr(20,TRUE),MessageReadMenu,1,NumMenus,Changed);
                    '6' : FindMenu(RGSysCfgStr(21,TRUE),FileListingMenu,1,NumMenus,Changed);
                  END;
                UNTIL (Cmd IN [^M,'Q']) OR (HangUp);
                Cmd := #0;
              END;
        'L' : InputWN1(RGSysCfgStr(22,TRUE),BulletPrefix,(SizeOf(BulletPrefix) - 1),[InterActiveEdit,UpperOnly],Changed);
        'M' : IF (InCom) THEN
                RGNoteStr(1,FALSE)
              ELSE
              BEGIN
                MultiNode := (NOT MultiNode);
                SaveGeneral(FALSE);
                ClrScr;
                Writeln('Please restart Renegade.');
                Halt;
              END;
        'N' : BEGIN
                NetworkMode := (NOT NetworkMode);
                IF (NetworkMode) THEN
                  LocalSec := TRUE
                ELSE
                  LocalSec := PYNQ(RGSysCfgStr(23,TRUE),0,FALSE);
              END;
        '0' : InputPath(RGSysCfgStr(24,TRUE),DataPath,TRUE,FALSE,Changed);
        '1' : InputPath(RGSysCfgStr(25,TRUE),MiscPath,TRUE,FALSE,Changed);
        '2' : InputPath(RGSysCfgStr(26,TRUE),MsgPath,TRUE,FALSE,Changed);
        '3' : InputPath(RGSysCfgStr(27,TRUE),NodePath,TRUE,FALSE,Changed);
        '4' : InputPath(RGSysCfgStr(28,TRUE),LogsPath,TRUE,FALSE,Changed);
        '5' : InputPath(RGSysCfgStr(29,TRUE),TempPath,FALSE,FALSE,Changed);
        '6' : InputPath(RGSysCfgStr(30,TRUE),ProtPath,TRUE,FALSE,Changed);
        '7' : InputPath(RGSysCfgStr(31,TRUE),ArcsPath,TRUE,FALSE,Changed);
        '8' : InputPath(RGSysCfgStr(32,TRUE),FileAttachPath,TRUE,FALSE,Changed);
        '9' : InputPath(RGSysCfgStr(33,TRUE),MultPath,TRUE,FALSE,Changed);
      END;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
  Seek(LineFile,0);
  Write(LineFile,Liner);
  Close(LineFile);
  LastError := IOResult;
END;

END.
