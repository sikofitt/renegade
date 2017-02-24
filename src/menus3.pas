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

UNIT Menus3;

INTERFACE

USES
  Common;

PROCEDURE DoChangeMenu(VAR Done: BOOLEAN; VAR NewMenuCmd: ASTR; Cmd: CHAR; CONST MenuOption: Str50);

IMPLEMENTATION

Uses
  SysUtils;

PROCEDURE DoChangeMenu(VAR Done: BOOLEAN; VAR NewMenuCmd: ASTR; Cmd: CHAR; CONST MenuOption: Str50);
VAR
  TempStr,
  TempStr1: ASTR;
BEGIN
  CASE Cmd OF
    '^' : BEGIN
            TempStr1 := MenuOption;
            IF (Pos(';',TempStr1) <> 0) THEN
              TempStr1 := Copy(TempStr1,1,(Pos(';',TempStr1) - 1));
            IF (MenuOption <> '') THEN
            BEGIN
              TempStr := MenuOption;
              IF (Pos(';',TempStr) <> 0) THEN
                TempStr := Copy(TempStr,(Pos(';',TempStr) + 1),Length(TempStr));
              IF (AnsiUpperCase(TempStr[1]) = 'C') THEN
                MenuStackPtr := 0;
              IF (Pos(';',TempStr) = 0) OR (Length(TempStr) = 1) THEN
                TempStr := ''
              ELSE
                TempStr := Copy(TempStr,(Pos(';',TempStr) + 1),Length(TempStr));
            END;
            IF (TempStr1 <> '') THEN
            BEGIN
              CurMenu := StrToInt(TempStr1);
              IF (TempStr <> '') THEN
                NewMenuCmd := AllCaps(TempStr);
              Done := TRUE;
              NewMenuToLoad := TRUE;
            END;
          END;
    '/' : BEGIN
            TempStr1 := MenuOption;
            IF (Pos(';',TempStr1) <> 0) THEN
              TempStr1 := Copy(TempStr1,1,Pos(';',TempStr1) - 1);
            IF ((MenuOption <> '') AND (MenuStackPtr <> MaxMenus)) THEN
            BEGIN
              TempStr := MenuOption;
              IF (Pos(';',TempStr) <> 0) THEN
                TempStr := Copy(TempStr,(Pos(';',TempStr) + 1),Length(TempStr));
              IF (AnsiUpperCase(TempStr[1]) = 'C') THEN
                MenuStackPtr := 0;
              IF (Pos(';',TempStr) = 0) OR (Length(TempStr) = 1) THEN
                TempStr := ''
              ELSE
                TempStr := Copy(TempStr,(Pos(';',TempStr) + 1),Length(TempStr));
              IF (CurMenu <> StrToInt(TempStr1)) THEN
              BEGIN
                Inc(MenuStackPtr);
                MenuStack[MenuStackPtr] := CurMenu;
              END
              ELSE
                TempStr1 := '';
            END;
            IF (TempStr1 <> '') THEN
            BEGIN
              CurMenu := StrToInt(TempStr1);
              IF (TempStr <> '') THEN
                NewMenuCmd := AllCaps(TempStr);
              Done := TRUE;
              NewMenuToLoad := TRUE;
            END;
          END;
    '\' : BEGIN
            IF (MenuStackPtr <> 0) THEN
            BEGIN
              CurMenu := MenuStack[MenuStackPtr];
              Dec(MenuStackPtr);
            END;
            IF (AnsiUpperCase(MenuOption[1]) = 'C') THEN
              MenuStackPtr := 0;
            IF (Pos(';',MenuOption) <> 0) THEN
              NewMenuCmd := AllCaps(Copy(MenuOption,(Pos(';',MenuOption) + 1),Length(MenuOption)));
            Done := TRUE;
            NewMenuToLoad := TRUE;
          END;
  END;
END;

END.
