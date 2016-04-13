{
*****************************************************************************
    This file is part of Renegade BBS

    Foobar is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

*****************************************************************************

           _______                                  __
          |   _   .-----.-----.-----.-----.---.-.--|  .-----.
          |.  l   |  -__|     |  -__|  _  |  _  |  _  |  -__|
          |.  _   |_____|__|__|_____|___  |___._|_____|_____|
          |:  |   |                 |_____|
          |::.|:. |
          `--- ---'
}
{$A+,B-,D+,E-,F+,I-,L+,N-,O+,R-,S-,V-}

unit Common1;

interface

function CheckPW: boolean;
procedure NewCompTables;
procedure Wait(b: boolean);
procedure InitTrapFile;
procedure Local_Input1(var S: string; MaxLen: byte; Lower: boolean);
procedure Local_Input(var S: string; MaxLen: byte);
procedure Local_InputL(var S: string; MaxLen: byte);
procedure Local_OneK(var C: char; S: string);
procedure SysOpShell;
procedure ReDrawForANSI;

implementation

uses
  Crt,
  Common,
  File0,
  Mail0,
  TimeFunc,
  SysUtils;

function CheckPW: boolean;
var
  Password: AnsiString;
begin
  SetLength(Password, 20);
  if (not General.SysOpPWord) or (InWFCMenu) then
  begin
    CheckPW := True;
    Exit;
  end;
  CheckPW := False;
  { Prompt(FString.SysOpPrompt); }
  lRGLngStr(33, False);
  GetPassword(Password, 20);
  if (Password = General.SysOpPW) then
    CheckPW := True
  else if (InCom) and (Password <> '') then
    SysOpLog('--> SysOp Password Failure = ' + Password + ' ***');
end;

procedure NewCompTables;
var
  FileCompArrayFile: file of CompArrayType;
  MsgCompArrayFile: file of CompArrayType;
  CompFileArray: CompArrayType;
  CompMsgArray: CompArrayType;
  Counter, Counter1, Counter2, SaveReadMsgArea, SaveReadFileArea: integer;
begin
  SaveReadMsgArea := ReadMsgArea;
  SaveReadFileArea := ReadFileArea;
  Reset(FileAreaFile);
  if (IOResult <> 0) then
  begin
    SysOpLog('Error opening FBASES.DAT (Procedure: NewCompTables)');
    Exit;
  end;
  NumFileAreas := FileSize(FileAreaFile);
  Assign(FileCompArrayFile, TempDir + 'FACT' + IntToStr(ThisNode) + '.DAT');
  ReWrite(FileCompArrayFile);
  CompFileArray[0] := 0;
  CompFileArray[1] := 0;
  for Counter := 1 to FileSize(FileAreaFile) do
    Write(FileCompArrayFile, CompFileArray);
  Reset(FileCompArrayFile);
  if (not General.CompressBases) then
  begin
    for Counter := 1 to FileSize(FileAreaFile) do
    begin
      Seek(FileAreaFile, (Counter - 1));
      Read(FileAreaFile, MemFileArea);
      if (not AACS(MemFileArea.ACS)) then
      begin
        CompFileArray[0] := 0;
        CompFileArray[1] := 0;
      end
      else
      begin
        CompFileArray[0] := Counter;
        CompFileArray[1] := Counter;
      end;
      Seek(FileCompArrayFile, (Counter - 1));
      Write(FileCompArrayFile, CompFileArray);
    end;
  end
  else
  begin
    Counter2 := 0;
    Counter1 := 0;
    for Counter := 1 to FileSize(FileAreaFile) do
    begin
      Seek(FileAreaFile, (Counter - 1));
      Read(FileAreaFile, MemFileArea);
      Inc(Counter1);
      if (not AACS(MemFileArea.ACS)) then
      begin
        Dec(Counter1);
        CompFileArray[0] := 0;
      end
      else
      begin
        CompFileArray[0] := Counter1;
        Seek(FileCompArrayFile, (Counter - 1));
        Write(FileCompArrayFile, CompFileArray);
        Inc(Counter2);
        Seek(FileCompArrayFile, (Counter2 - 1));
        Read(FileCompArrayFile, CompFileArray);
        CompFileArray[1] := Counter;
        Seek(FileCompArrayFile, (Counter2 - 1));
        Write(FileCompArrayFile, CompFileArray);
      end;
    end;
  end;
  Close(FileAreaFile);
  LastError := IOResult;
  LowFileArea := 0;
  Counter1 := 0;
  Counter := 1;
  while (Counter <= FileSize(FileCompArrayFile)) and (Counter1 = 0) do
  begin
    Seek(FileCompArrayFile, (Counter - 1));
    Read(FileCompArrayFile, CompFileArray);
    if (CompFileArray[0] <> 0) then
      Counter1 := CompFileArray[0];
    Inc(Counter);
  end;
  LowFileArea := Counter1;
  HighFileArea := 0;
  Counter1 := 0;
  Counter := 1;
  while (Counter <= FileSize(FileCompArrayFile)) do
  begin
    Seek(FileCompArrayFile, (Counter - 1));
    Read(FileCompArrayFile, CompFileArray);
    if (CompFileArray[0] <> 0) then
      Counter1 := CompFileArray[0];
    Inc(Counter);
  end;
  HighFileArea := Counter1;
  Close(FileCompArrayFile);
  LastError := IOResult;
  Reset(MsgAreaFile);
  if (IOResult <> 0) then
  begin
    SysOpLog('Error opening MBASES.DAT (Procedure: NewCompTables)');
    Exit;
  end;
  NumMsgAreas := FileSize(MsgAreaFile);
  Assign(MsgCompArrayFile, TempDir + 'MACT' + IntToStr(ThisNode) + '.DAT');
  ReWrite(MsgCompArrayFile);
  CompMsgArray[0] := 0;
  CompMsgArray[1] := 0;
  for Counter := 1 to FileSize(MsgAreaFile) do
    Write(MsgCompArrayFile, CompMsgArray);
  Reset(MsgCompArrayFile);
  if (not General.CompressBases) then
  begin
    for Counter := 1 to FileSize(MsgAreaFile) do
    begin
      Seek(MsgAreaFile, (Counter - 1));
      Read(MsgAreaFile, MemMsgArea);
      if (not AACS(MemMsgArea.ACS)) then
      begin
        CompMsgArray[0] := 0;
        CompMsgArray[1] := 0;
      end
      else
      begin
        CompMsgArray[0] := Counter;
        CompMsgArray[1] := Counter;
      end;
      Seek(MsgCompArrayFile, (Counter - 1));
      Write(MsgCompArrayFile, CompMsgArray);
    end;
  end
  else
  begin
    Counter2 := 0;
    Counter1 := 0;
    for Counter := 1 to FileSize(MsgAreaFile) do
    begin
      Seek(MsgAreaFile, (Counter - 1));
      Read(MsgAreaFile, MemMsgArea);
      Inc(Counter1);
      if (not AACS(MemMsgArea.ACS)) then
      begin
        Dec(Counter1);
        CompMsgArray[0] := 0;
      end
      else
      begin
        CompMsgArray[0] := Counter1;
        Seek(MsgCompArrayFile, (Counter - 1));
        Write(MsgCompArrayFile, CompMsgArray);
        Inc(Counter2);
        Seek(MsgCompArrayFile, (Counter2 - 1));
        Read(MsgCompArrayFile, CompMsgArray);
        CompMsgArray[1] := Counter;
        Seek(MsgCompArrayFile, (Counter2 - 1));
        Write(MsgCompArrayFile, CompMsgArray);
      end;
    end;
  end;
  Close(MsgAreaFile);
  LastError := IOResult;
  LowMsgArea := 0;
  Counter1 := 0;
  Counter := 1;
  while (Counter <= FileSize(MsgCompArrayFile)) and (Counter1 = 0) do
  begin
    Seek(MsgCompArrayFile, (Counter - 1));
    Read(MsgCompArrayFile, CompMsgArray);
    if (CompMsgArray[0] <> 0) then
      Counter1 := CompMsgArray[0];
    Inc(Counter);
  end;
  LowMsgArea := Counter1;
  HighMsgArea := 0;
  Counter1 := 0;
  Counter := 1;
  while (Counter <= FileSize(MsgCompArrayFile)) do
  begin
    Seek(MsgCompArrayFile, (Counter - 1));
    Read(MsgCompArrayFile, CompMsgArray);
    if (CompMsgArray[0] <> 0) then
      Counter1 := CompMsgArray[0];
    Inc(Counter);
  end;
  HighMsgArea := Counter1;
  Close(MsgCompArrayFile);
  LastError := IOResult;
  ReadMsgArea := -1;
  ReadFileArea := -1;
  if (not FileAreaAC(FileArea)) then
    ChangeFileArea(CompFileArea(1, 1));
  if (not MsgAreaAC(MsgArea)) then
    ChangeMsgArea(CompMsgArea(1, 1));
  LoadMsgArea(SaveReadMsgArea);
  LoadFileArea(SaveReadFileArea);
end;

procedure Wait(b: boolean);
const
  SaveCurrentColor: byte = 0;
begin
  if (B) then
  begin
    SaveCurrentColor := CurrentColor;
    { Prompt(FString.lWait); }
    lRGLngStr(4, False);
  end
  else
  begin
    BackErase(LennMCI(lRGLngStr(4, True){FString.lWait}));
    SetC(SaveCurrentColor);
  end;
end;

procedure InitTrapFile;
begin
  Trapping := False;
  if (General.GlobalTrap) or (TrapActivity in ThisUser.SFlags) then
    Trapping := True;
  if (Trapping) then
  begin
    if (TrapSeparate in ThisUser.SFlags) then
      Assign(TrapFile, General.LogsPath + 'TRAP' + IntToStr(UserNum) + '.LOG')
    else
      Assign(TrapFile, General.LogsPath + 'TRAP.LOG');
    Append(TrapFile);
    if (IOResult = 2) then
    begin
      ReWrite(TrapFile);
      WriteLn(TrapFile);
    end;
    WriteLn(TrapFile, '***** Renegade User Audit - ' + Caps(ThisUser.Name) +
      ' on at ' + DateStr + ' ' + TimeStr + ' *****');
  end;
end;

procedure Local_Input1(var S: string; MaxLen: byte; Lower: boolean);
var
  C: char;
  B: byte;
begin
  B := 1;
  repeat
    C := ReadKey;
    if (not LowerCase) then
      C := AnsiUpperCase(C);
    if (C in [#32..#255]) then
      if (B <= MaxLen) then
      begin
        S[B] := C;
        Inc(B);
        Write(C);
      end
      else
    else
      case C of
        ^H: if (B > 1) then
          begin
            Write(^H' '^H);
            C := ^H;
            Dec(B);
          end;
        ^U, ^X: while (B <> 1) do
          begin
            Write(^H' '^H);
            Dec(B);
          end;
      end;
  until (C in [^M, ^N]);
  S[0] := Chr(B - 1);
  if (WhereY <= Hi(WindMax) - Hi(WindMin)) then
    WriteLn;
end;

{ Wrapper for Local_Input1 to specify uppercase }
procedure Local_Input(var S: string; MaxLen: byte);
begin
  Local_Input1(S, MaxLen, False);
end;

{ Wrapper for Local_Input1 to specify lowercase }
procedure Local_InputL(var S: string; MaxLen: byte);
begin
  Local_Input1(S, MaxLen, True);
end;

procedure Local_OneK(var C: char; S: string);
begin
  repeat
    C := AnsiUpperCase(ReadKey)
  until (Pos(C, S) > 0);
  WriteLn(C);
end;

{ Creates a waiting prompt for user
  while sysop shells to dos/bash }
procedure SysOpShell;
var
  SavePath: string;
  SaveWhereX, SaveWhereY, SaveCurrentColor: byte;
  ReturnCode: integer;
  SaveTimer: longint;
begin
  SaveCurrentColor := CurrentColor;
  GetDir(0, SavePath);
  SaveTimer := Timer;
  if (UserOn) then
  begin
    { Prompt(FString.ShellDOS1); }
    lRGLngStr(12, False);
    Com_Flush_Send;
    Delay(100);
  end; { UserOn }
  SaveWhereX := WhereX;
  SaveWhereY := WhereY;
  Window(1, 1, 80, 25);
  TextBackGround(Black);
  TextColor(LightGray);
  ClrScr;
  TextColor(LightCyan);
  WriteLn('Type "EXIT" to return to Renegade.');
  WriteLn;
  TimeLock := True;
  ShellDOS(False, '', ReturnCode);
  TimeLock := False;
  if (UserOn) then
  begin
    Com_Flush_Recv;
  end; { UserOn }
  ChDir(SavePath);
  TextBackGround(Black);
  TextColor(LightGray);
  ClrScr;
  TextAttr := SaveCurrentColor;
  GoToXY(SaveWhereX, SaveWhereY);
  if (UserOn) then
  begin
    if (not InChat) then
    begin
      FreeTime := ((FreeTime + Timer) - SaveTimer);
    end; { Not InChat }
    Update_Screen;
    for SaveCurrentColor := 1 to LennMCI(lRGLngStr(12, True){FString.ShellDOS1}) do
    begin
      BackSpace;
    end; { For SaveCurrentColor }
  end; { UserOn }
end; { SysOpShell; }

procedure ReDrawForANSI;
begin
  if (DOSANSIOn) then
  begin
    DOSANSIOn := False;
    Update_Screen;
  end; { DOSANSIOn }
  TextAttr := 7;
  CurrentColor := 7;
  if (OutCom) then
  begin
    if (OKAvatar) then
    begin
      SerialOut(^V^A^G);
    end { OKAvatar }
    else if (OkANSI) then
    begin
      SerialOut(#27 + '[0m');
    end; { OkANSI }
  end; { OutCom }
end; { ReDrawForAnsi }

end. { Unit Common1 }



