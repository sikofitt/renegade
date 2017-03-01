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

UNIT MiscUser;

INTERFACE

USES
  Common;

PROCEDURE lFindUserWS(VAR UserNum: LongInt);
PROCEDURE ChangeARFlags(MenuOption: Str50);
PROCEDURE ChangeACFlags(MenuOption: Str50);
PROCEDURE FindUser(VAR UserNum: LongInt);
PROCEDURE InsertIndex(uname: AStr; UserNum: Integer; IsReal,IsDeleted: Boolean);

IMPLEMENTATION

USES
  Dos;

PROCEDURE lFindUserWS(VAR UserNum: LongInt);
VAR
  User: UserRecordType;
  UserIDX: UserIDXRec;
  UserName: ShortString;
  Cmd: Char;
  Counter,
  NumIDX: Integer;
  Done,
  Asked: Boolean;
BEGIN
  SetLength(UserName, 36);
  MPL(36);
  Input(UserName,36);
  IF (UserName = 'SYSOP') THEN
    UserName := '1';
  UserNum := StrToInt(UserName);
  IF (UserNum > 0) THEN
  BEGIN
    IF (UserNum > (MaxUsers - 1)) THEN
    BEGIN
      NL;
      Print('Unknown user.');
      UserNum := 0
    END
    ELSE
      LoadURec(User,UserNum);
  END
  ELSE IF (UserName = '') THEN
  BEGIN
    NL;
    Print('Aborted.');
  END
  ELSE
  BEGIN
    Done := FALSE;
    Asked := FALSE;
    UserNum := SearchUser(UserName,CoSysOp);
    IF (UserNum > 0) THEN
      Exit;
    Reset(UserIDXFile);
    Counter := 0;
    NumIDX := FileSize(UserIDXFile);
    WHILE (Counter < NumIDX) AND (NOT Done) DO
    BEGIN
      Read(UserIDXFile,UserIDX);
      Inc(Counter);
      IF NOT (UserIDX.Deleted) AND (Pos(UserName,UserIDX.Name) <> 0) AND ((NOT UserIDX.RealName) OR (CoSysOp)) THEN
        IF ((UserIDX.Name = UserName) OR (CoSysOp AND (UserIDX.Name = UserName))) AND (UserIDX.number <= (MaxUsers - 1)) THEN
          UserNum := UserIDX.Number
        ELSE
        BEGIN
          IF (NOT Asked) THEN
          BEGIN
            NL;
            Asked := TRUE;
          END;
          Prompt('^1Did you mean ^3'+Caps(UserIDX.Name)+'^1? ');
          OneK(Cmd,'QYN'^M,TRUE,TRUE);
          Done := TRUE;
          CASE Cmd OF
            'Q' : UserNum := -1;
            'Y' : UserNum := UserIDX.Number;
          ELSE
            Done := FALSE;
          END;
        END;
    END;
    Close(UserIDXFile);
    IF (UserNum = 0) THEN
    BEGIN
      NL;
      Print('User not found.');
    END;
    IF (UserNum = -1) THEN
      UserNum := 0;
  END;
  LastError := IOResult;
END;

PROCEDURE ChangeARFlags(MenuOption: Str50);
VAR
  Counter: Byte;
  Changed: Boolean;
BEGIN
  MenuOption := AllCaps(MenuOption);
  FOR Counter := 1 TO (Length(MenuOption) - 1) DO
    CASE MenuOption[Counter] OF
      '+' : IF (MenuOption[Counter + 1] IN ['A'..'Z']) THEN
              Include(ThisUser.AR,MenuOption[Counter + 1]);
      '-' : IF (MenuOption[Counter + 1] IN ['A'..'Z']) THEN
              Exclude(ThisUser.AR,MenuOption[Counter + 1]);
      '!' : IF (MenuOption[Counter + 1] IN ['A'..'Z']) THEN
              ToggleARFlag((MenuOption[Counter + 1]),ThisUser.AR,Changed);
    END;
  NewCompTables;
  Update_Screen;
END;

PROCEDURE ChangeACFlags(MenuOption: Str50);
VAR
  Counter: Byte;
  Changed: Boolean;
BEGIN
  MenuOption := AllCaps(MenuOption);
  FOR Counter := 1 TO (Length(MenuOption) - 1) DO
    CASE MenuOption[Counter] OF
      '+' : Include(ThisUser.Flags,TACCH(MenuOption[Counter + 1]));
      '-' : Exclude(ThisUser.Flags,TACCH(MenuOption[Counter + 1]));
      '!' : ToggleACFlags(MenuOption[Counter + 1],ThisUser.Flags,Changed);
    END;
  NewCompTables;
  Update_Screen;
END;

PROCEDURE FindUser(VAR UserNum: LongInt);
VAR
  User: UserRecordType;
  TempUserName: ShortString; //Str36;
  TempUserNum: Integer;
BEGIN
  SetLength(TempUserName, 36);
  UserNum := 0;
  TempUserName := '';
  Input(TempUserName,36);
  IF (TempUserName = 'NEW') THEN
  BEGIN
    UserNum := -1;
    Exit;
  END;
  IF (TempUserName = '?') THEN
    Exit;
  WHILE (Pos('  ',TempUserName) <> 0) DO
    Delete(TempUserName,Pos('  ',TempUserName),1);
  WHILE (TempUserName[1] = ' ') AND (Length(TempUserName) > 0) DO
    Delete(TempUserName,1,1);
  IF (TempUserName = '') OR (HangUp) THEN
    Exit;
  UserNum := StrToInt(TempUserName);
  IF (UserNum <> 0) THEN
  BEGIN
    IF (UserNum < 0) OR (UserNum > (MaxUsers - 1)) THEN
      UserNum := 0
    ELSE
    BEGIN
      LoadURec(User,UserNum);
      IF (Deleted IN User.SFlags) THEN
        UserNum := 0;
    END;
  END
  ELSE IF (TempUserName <> '') THEN
  BEGIN
    TempUserNum := SearchUser(TempUserName,TRUE);
    IF (TempUserNum <> 0) THEN
    BEGIN
      LoadURec(User,TempUserNum);
      IF (NOT (Deleted IN User.SFlags)) THEN
        UserNum := TempUserNum
      ELSE
        UserNum := 0;
    END;
  END;
END;

PROCEDURE InsertIndex(Uname: AStr; UserNum: Integer; IsReal,IsDeleted: Boolean);
VAR
  UserIDX: UserIDXRec;
  Current,
  InsertAt: Integer;
  SFO,
  Done: Boolean;

  PROCEDURE WriteIndex;
  BEGIN
    WITH UserIDX DO
    BEGIN
      FillChar(UserIDX,SizeOf(UserIDX),0);
      Name := Uname;
      Number := UserNum;
      RealName := IsReal;
      Deleted := IsDeleted;
      Left := -1;
      Right := -1;
      Write(UserIDXFile,UserIDX);
    END
  END;

BEGIN
  Done := FALSE;
  Uname := AllCaps(Uname);
  Current := 0;
  SFO := (FileRec(UserIDXFile).Mode <> FMClosed);
  IF (NOT SFO) THEN
    Reset(UserIDXFile);
  IF (FileSize(UserIDXFile) = 0) THEN
    WriteIndex
  ELSE
    REPEAT
      Seek(UserIDXFile,Current);
      InsertAt := Current;
      Read(UserIDXFile,UserIDX);
      IF (Uname < UserIDX.Name) THEN
        Current := UserIDX.Left
      ELSE IF (Uname > UserIDX.Name) THEN
        Current := UserIDX.Right
      ELSE IF (UserIDX.Deleted <> IsDeleted) THEN
      BEGIN
        Done := TRUE;
        UserIDX.Deleted := IsDeleted;
        UserIDX.RealName := IsReal;
        UserIDX.Number := UserNum;
        Seek(UserIDXFile,Current);
        Write(UserIDXFile,UserIDX);
      END
      ELSE
      BEGIN
        IF (UserNum <> UserIDX.Number) THEN
          SysOpLog('Note: Duplicate user '+UName+' #'+IntToStr(UserIDX.Number)+' and '+UName+' #'+IntToStr(UserNum))
        ELSE
        BEGIN
          UserIDX.RealName := FALSE;
          Seek(UserIDXFile,Current);         { Make it be his handle IF it's BOTH }
          Write(UserIDXFile,UserIDX);
        END;
        Done := TRUE;
      END;
    UNTIL (Current = -1) OR (Done);
    IF (Current = -1) THEN
    BEGIN
      IF (Uname < UserIDX.Name) THEN
        UserIDX.Left := FileSize(UserIDXFile)
      ELSE
        UserIDX.Right := FileSize(UserIDXFile);
      Seek(UserIDXFile,InsertAt);
      Write(UserIDXFile,UserIDX);
      Seek(UserIDXFile,FileSize(UserIDXFile));
      WriteIndex;
    END;
  IF (NOT SFO) THEN
    Close(UserIDXFile);
  LastError := IOResult;
END;

END.
