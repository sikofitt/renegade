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

UNIT ShortMsg;

INTERFACE

USES
  Common;

PROCEDURE ReadShortMessage;
PROCEDURE SendShortMessage(CONST UNum: Integer; CONST Message: AStr);

IMPLEMENTATION

PROCEDURE ReadShortMessage;
VAR
  ShortMsgFile: FILE OF ShortMessageRecordType;
  ShortMsg: ShortMessageRecordType;
  RecNum: LongInt;
BEGIN
  Assign(ShortMsgFile,General.DataPath+'SHORTMSG.DAT');
  Reset(ShortMsgFile);
  IF (IOResult = 0) THEN
  BEGIN
    UserColor(1);
    RecNum := 0;
    WHILE (RecNum <= (FileSize(ShortMsgFile) - 1)) AND (NOT HangUp) DO
    BEGIN
      Seek(ShortMsgFile,RecNum);
      Read(ShortMsgFile,ShortMsg);
      IF (ShortMsg.Destin = UserNum) THEN
      BEGIN
        Print(ShortMsg.Msg);
        ShortMsg.Destin := -1;
        Seek(ShortMsgFile,RecNum);
        Write(ShortMsgFile,ShortMsg);
      END;
      Inc(RecNum);
    END;
    Close(ShortMsgFile);
    UserColor(1);
  END;
  Exclude(ThisUser.Flags,SMW);
  SaveURec(ThisUser,UserNum);
  LastError := IOResult;
END;

PROCEDURE SendShortMessage(CONST UNum: Integer; CONST Message: AStr);
VAR
  ShortMsgFile: FILE OF ShortMessageRecordType;
  ShortMsg: ShortMessageRecordType;
  User: UserRecordType;
BEGIN
  IF (UNum >= 1) AND (UNum <= (MaxUsers - 1)) THEN
  BEGIN
    Assign(ShortMsgFile,General.DataPath+'SHORTMSG.DAT');
    Reset(ShortMsgFile);
    IF (IOResult = 2) THEN
      ReWrite(ShortMsgFile);
    Seek(ShortMsgFile,FileSize(ShortMsgFile));
    WITH ShortMsg DO
    BEGIN
      Msg := Message;
      Destin := UNum;
    END;
    Write(ShortMsgFile,ShortMsg);
    Close(ShortMsgFile);
    LoadURec(User,UNum);
    Include(User.Flags,SMW);
    SaveURec(User,UNum);
    LastError := IOResult;
  END;
END;

END.
