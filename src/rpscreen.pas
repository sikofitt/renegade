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

unit RPScreen;

interface


uses
  {$IFDEF WINDOWS}
  Windows;
  {$ELSE}
  Unix, SysUtils, Crt;
  {$ENDIF}
type
  {$IFDEF FPC}
   TCharInfo = packed record
      Ch:   char;
      Attr: byte;
    end;
   {$ENDIF}
  TScreenBuf = Array[1..25, 1..80] of TCharInfo; // REETODO Don't hardcode to 80x25


procedure RPBlockCursor;
procedure RPGotoXY(xy: Word);
procedure RPHideCursor;
procedure RPInsertCursor;
procedure RPRestoreScreen(var screenBuf: TScreenBuf);
procedure RPSaveScreen(var screenBuf: TScreenBuf);
function  RPScreenSizeX: Word;
function  RPScreenSizeY: Word;
procedure RPSetAttrAt(x, y, attr: Word);
procedure RPShowCursor;
function  RPWhereXY: Word;

implementation

{$IFDEF WIN32}
var
  StdOut: THandle;
{$ENDIF}

{$IFNDEF MSDOS}
procedure RPBlockCursor;
{$IFDEF WINDOWS}
var
  CCI: TConsoleCursorInfo;
begin
  CCI.bVisible := true;
  CCI.dwSize := 15;
  SetConsoleCursorInfo(StdOut, CCI);
end;
{$ELSE}
begin
cursorbig;
end;

{$ENDIF}

procedure RPGotoXY(xy: Word);
var
  Coord: TCoord;
begin
  Coord.x := xy AND $00FF;
  Coord.y := xy AND $FF00 SHR 8;
  SetConsoleCursorPosition(StdOut, Coord);
end;

procedure RPHideCursor;
var
  CCI: TConsoleCursorInfo;
begin
  GetConsoleCursorInfo(StdOut, CCI);
  CCI.bVisible := false;
  SetConsoleCursorInfo(StdOut, CCI);
end;

procedure RPInsertCursor;
var
  CCI: TConsoleCursorInfo;
begin
  CCI.bVisible := true;
  CCI.dwSize := 99;
  SetConsoleCursorInfo(StdOut, CCI);
end;

{ REETODO Should detect screen size }
procedure RPRestoreScreen(var screenBuf: TScreenBuf);
var
  BufSize    : TCoord;
  WritePos   : TCoord;
  DestRect   : TSmallRect;
begin
  BufSize.X       := 80;
  BufSize.Y       := 25;
  WritePos.X      := 0;
  WritePos.Y      := 0;
  DestRect.Left   := 0;
  DestRect.Top    := 0;
  DestRect.Right  := 79;
  DestRect.Bottom := 24;
  WriteConsoleOutput(StdOut, @screenBuf[1][1], BufSize, WritePos, DestRect);
end;

{ REETODO Should detect screen size }
procedure RPSaveScreen(var screenBuf: TScreenBuf);
var
  BufSize    : TCoord;
  ReadPos    : TCoord;
  SourceRect : TSmallRect;
begin
  BufSize.X         := 80;
  BufSize.Y         := 25;
  ReadPos.X         := 0;
  ReadPos.Y         := 0;
  SourceRect.Left   := 0;
  SourceRect.Top    := 0;
  SourceRect.Right  := 79;
  SourceRect.Bottom := 24;
  ReadConsoleOutput(StdOut, @screenBuf[1][1], BufSize, ReadPos, SourceRect);
end;

function  RPScreenSizeX: Word;
var
  CSBI: TConsoleScreenBufferInfo;
begin
  GetConsoleScreenBufferInfo(StdOut, CSBI);
  RPScreenSizeX := CSBI.srWindow.Right - CSBI.srWindow.Left + 1;
end;

function  RPScreenSizeY: Word;
var
  CSBI: TConsoleScreenBufferInfo;
begin
  GetConsoleScreenBufferInfo(StdOut, CSBI);
  RPScreenSizeY := CSBI.srWindow.Bottom - CSBI.srWindow.Top + 1;
end;

procedure RPSetAttrAt(x, y, attr: Word);
var
  NumWritten: LongWord;
  WriteCoord: TCoord;
begin
  WriteCoord.X := x;
  WriteCoord.Y := y;
  WriteConsoleOutputAttribute(StdOut, @attr, 1, WriteCoord, NumWritten);
end;

procedure RPShowCursor;
var
  CCI: TConsoleCursorInfo;
begin
  GetConsoleCursorInfo(StdOut, CCI);
  CCI.bVisible := true;
  SetConsoleCursorInfo(StdOut, CCI);
end;

function RPWhereXY: Word;
var
  CSBI: TConsoleScreenBufferInfo;
begin
  GetConsoleScreenBufferInfo(StdOut, CSBI);
  RPWhereXY := CSBI.dwCursorPosition.x + (CSBI.dwCursorPosition.y SHL 8);
end;
{$ENDIF}


{$IFDEF WIN32}
BEGIN
  StdOut := GetStdHandle(STD_OUTPUT_HANDLE);
{$ENDIF}
END.