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

{$I Renegade.Common.Defines.inc}

UNIT File2;

INTERFACE

USES
  Common;

FUNCTION CopyMoveFile(CopyFile: Boolean; DisplayStr: AStr;
  Const SrcName, DestName: AStr; CONST ShowProg: Boolean): Boolean;

IMPLEMENTATION

USES
  Dos;

FUNCTION CopyMoveFile(CopyFile: Boolean; DisplayStr: AStr;
  Const SrcName, DestName: AStr; Const ShowProg: Boolean): Boolean;
VAR
  Buffer: Array [1..8192] Of Byte;
  FromF,
  ToF: FILE;
  CurDir: AnsiString;
  ProgressStr: Str3;
  NumRead: Word;
  TotalNumRead,
  FileDate: LongInt;
  OK,
  Nospace: Boolean;
BEGIN
  OK := TRUE;
  NoSpace := FALSE;
  GetDir(0,CurDir);
  IF (ShowProg) THEN
    Prompt(DisplayStr);
  IF (NOT CopyFile) THEN
  BEGIN
    Assign(FromF,SrcName);
    ReName(FromF,DestName);
    LastError := IOResult;
    IF (LastError <> 0) THEN
      OK := FALSE
    ELSE IF (ShowProg) THEN
        Print('^5100%^1')
  END;
  IF (NOT OK) OR (CopyFile) THEN
  BEGIN
    OK := TRUE;
    IF (SrcName = DestName) THEN
      OK := FALSE
    ELSE
    BEGIN
      Assign(FromF,SrcName);
      Reset(FromF,1);
      LastError := IOResult;
      IF (LastError <> 0) THEN
        OK := FALSE
      ELSE
      BEGIN
        GetFTime(FromF,FileDate);
        IF ((FileSize(FromF) DIV 1024) >= DiskKBFree(DestName)) THEN
        BEGIN
          Close(FromF);
          NoSpace := TRUE;
          OK := FALSE;
        END
        ELSE
        BEGIN
          Assign(ToF,DestName);
          ReWrite(ToF,1);
          LastError := IOResult;
          IF (LastError <> 0) THEN
            OK := FALSE
          ELSE
          BEGIN
            SetFTime(ToF,FileDate);
            IF (ShowProg) THEN
              Prompt('^5  0%^1');
            TotalNumRead := 0;
            REPEAT
              BlockRead(FromF,Buffer,SizeOf(Buffer),NumRead);
              BlockWrite(ToF,Buffer,NumRead);
              Inc(TotalNumRead,NumRead);
              IF (ShowProg) AND (FileSize(FromF) > 0) THEN
              BEGIN
                Str(Trunc(TotalNumRead / FileSize(FromF) * 100):3,ProgressStr);
                Prompt(^H^H^H^H+'^5'+ProgressStr+'%^1');
              END;
            UNTIL (NumRead < SizeOf(Buffer));
            IF (ShowProg) THEN
            BEGIN
              UserColor(1);
              NL;
            END;
            Close(ToF);
            Close(FromF);
            IF (NOT CopyFile) AND (OK) AND (NOT NoSpace) THEN
              Kill(SrcName);
          END;
        END;
      END;
    END;
  END;
  ChDir(CurDir);
  IF (NoSpace) THEN
  BEGIN
    IF (ShowProg) THEN
      Print('^7destination drive full!^1');
    SysOpLog('^7Error '+AOnOff(CopyFile,'copying','moving')+' (No-Space): "'+SrcName+'" to "'+DestName+'"!');
  END
  ELSE IF (NOT Ok) THEN
  BEGIN
    IF (ShowProg) THEN
      Print('^7failed!^1');
    SysOpLog('^7Error '+AOnOff(CopyFile,'copying','moving')+' (I/O): "'+SrcName+'" to "'+DestName+'"!');
  END
  ELSE
    SysOpLog('^1'+AOnOff(CopyFile,'Copied','Moved')+' file: "^5'+SrcName+'^1" to "^5'+DestName+'^1".');
  CopyMoveFile := (OK) AND (NOT NoSpace);
END;

END.
