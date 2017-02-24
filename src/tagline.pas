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

PROGRAM TAGLINE;

USES
  Crt,
  Dos;

TYPE
  StrPointerRec = RECORD
    Pointer,
    TextSize: LongInt;
  END;

VAR
  RGStrFile: FILE;
  StrPointerFile: FILE OF StrPointerRec;
  F: Text;
  StrPointer: StrPointerRec;
  S: STRING;
  RGStrNum,
  Counter: Word;

FUNCTION Exist(FN: STRING): Boolean;
VAR
  DirInfo: SearchRec;
BEGIN
  FindFirst(FN,AnyFile,DirInfo);
  Exist := (DosError = 0);
END;

BEGIN
  CLrScr;
  WriteLn('Renegade Tagline Compiler Version 1.1');
  Writeln('Copyright 2006-2009 - The Renegade Developement Team');
  WriteLn;
  IF (NOT Exist('TAGLINE.TXT')) THEN
    WriteLn(^G^G^G'TAGLINE.TXT file was not found!')
  ELSE
  BEGIN
    Counter := 0;
    Write('Checking maximum string length of 74 characters ... ');
    Assign(F,'TAGLINE.TXT');
    Reset(F);
    WHILE NOT EOF(F) DO
    BEGIN
      ReadLn(F,S);
      IF (Length(S) > 74) THEN
      BEGIN
        WriteLn;
        WriteLn;
        WriteLn('This string is longer then 74 characters:');
        WriteLn;
        Writeln(^G^G^G'-> '+S);
        WriteLn;
        WriteLn('Please reduce it''s length or delete from TAGLINE.TXT!');
        Halt;
      END;
      Inc(Counter);
    END;
    WriteLn('Done!');
    IF (Counter > 65535) THEN
    BEGIN
      WriteLn;
      WriteLn;
      WriteLn(^G^G^G'This file contains more then 65,535 lines');
      WriteLn;
      Writeln('Please reduce the number of lines in TAGLINE.TXT!');
      WriteLn;
      WriteLn('NOTE: Blank lines between Taglines are not required.');
      Writeln;
      Halt;
    END;
    WriteLn;
    Write('Compiling taglines ... ');
    Assign(StrPointerFile,'TAGLINE.PTR');
    ReWrite(StrPointerFile);
    Assign(RGStrFile,'TAGLINE.DAT');
    ReWrite(RGStrFile,1);
    Reset(F);
    WHILE NOT EOF(F) DO
    BEGIN
      ReadLn(F,S);
      IF (S <> '') THEN
      BEGIN
        WITH StrPointer DO
        BEGIN
          Pointer := (FileSize(RGStrFile) + 1);
          TextSize := 0;
        END;
        Seek(RGStrFile,FileSize(RGStrFile));
        Inc(StrPointer.TextSize,(Length(S) + 1));
        BlockWrite(RGStrFile,S,(Length(S) + 1));
        Seek(StrPointerFile,FileSize(StrPointerFile));
        Write(StrPointerFile,StrPointer);
      END;
    END;
    Close(F);
    Close(RGStrFile);
    Close(StrPointerFile);
    WriteLn('Done!')
  END;
END.
