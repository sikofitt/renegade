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

Unit File0;

Interface

Uses 
Common;

Function CompFileArea(FArea,ArrayNum: Integer): Integer;
Function GetCPS(TotalBytes,TransferTime: LongInt): LongInt;
Procedure CountDown;
Function Align(Const FName: Str12): Str12;
Function BadDownloadPath: Boolean;
Function BadUploadPath: Boolean;
Procedure DisplayFileInfo(Var F: FileInfoRecordType; Editing: Boolean);
Function FileAreaAC(FArea: Integer): Boolean;
Procedure ChangeFileArea(FArea: Integer);
Procedure LoadFileArea(FArea: Integer);
Function GetDirPath(MemFileArea: FileAreaRecordType): ASTR;
Procedure LoadNewScanFile(Var NewScanFile: Boolean);
Procedure SaveNewScanFile(NewScanFile: Boolean);
Procedure InitFileArea(FArea: Integer);
Function Fit(Const FileName1,FileName2: Str12): Boolean;
Procedure GetFileName(Var FileName: Str12);
Function ISUL(Const s: AStr): Boolean;
Function IsWildCard(Const s: AStr): Boolean;
Procedure NRecNo(FileInfo: FileInfoRecordType; Var RN: Integer);
Procedure LRecNo(Fileinfo: FileInfoRecordType; Var RN: Integer);
Procedure RecNo(FileInfo: FileInfoRecordType; FileName: Str12; Var RN: Integer);
Procedure LoadVerbArray(F: FileInfoRecordType; Var ExtArray:
                        ExtendedDescriptionArray; Var NumExtDesc: Byte);
Procedure SaveVerbArray(Var F: FileInfoRecordType; ExtArray:
                        ExtendedDescriptionArray; NumExtDesc: Byte);


Implementation

Uses 
Dos,
File1,
ShortMsg,
TimeFunc
{$IFDEF WIN32}
,Windows
{$ENDIF}
;

Function CompFileArea(FArea,ArrayNum: Integer): Integer;

Var 
  FileCompArrayFile: FILE Of CompArrayType;
  CompFileArray: CompArrayType;
Begin
  Assign(FileCompArrayFile,TempDir+'FACT'+IntToStr(ThisNode)+'.DAT');
  Reset(FileCompArrayFile);
  Seek(FileCompArrayFile,(FArea - 1));
  Read(FileCompArrayFile,CompFileArray);
  Close(FileCompArrayFile);
  CompFileArea := CompFileArray[ArrayNum];
End;

Function GetCPS(TotalBytes,TransferTime: LongInt): LongInt;
Begin
  If (TransferTime > 0) Then
    GetCPS := (TotalBytes Div TransferTime)
  Else
    GetCPS := 0;
End;

(* Done - 01/01/07 Lee Palmer *)
Function Align(Const FName: Str12): Str12;

Var 
  F: Str8;
  E: Str3;
  Counter,
  Counter1: Byte;
Begin
  Counter := Pos('.',FName);
  If (Counter = 0) Then
    Begin
      F := FName;
      E := '   ';
    End
  Else
    Begin
      F := Copy(FName,1,(Counter - 1));
      E := Copy(FName,(Counter + 1),3);
    End;
  F := PadLeftStr(F,8);
  E := PadLeftStr(E,3);
  Counter := Pos('*',F);
  If (Counter <> 0) Then
    For Counter1 := Counter To 8 Do
      F[Counter1] := '?';
  Counter := Pos('*',E);
  If (Counter <> 0) Then
    For Counter1 := Counter To 3 Do
      E[Counter1] := '?';
  Counter := Pos(' ',F);
  If (Counter <> 0) Then
    For Counter1 := Counter To 8 Do
      F[Counter1] := ' ';
  Counter := Pos(' ',E);
  If (Counter <> 0) Then
    For Counter1 := Counter To 3 Do
      E[Counter1] := ' ';
  Align := F+'.'+E;
End;

Function BadDownloadPath: Boolean;
Begin
  If (BadDLPath) Then
    Begin
      NL;
      Print('^7File area #'+IntToStr(FileArea)+': Unable to perform command.');
      SysOpLog('^5Bad DL file path: "'+MemFileArea.DLPath+'".');
      Print('^5Please inform the SysOp.');
      SysOpLog('Invalid DL path (File Area #'+IntToStr(FileArea)+'): "'+
      MemFileArea.DLPath+'"');
    End;
  BadDownloadPath := BadDLPath;
End;

Function BadUploadPath: Boolean;
Begin
  If (BadULPath) Then
    Begin
      NL;
      Print('^7File area #'+IntToStr(FileArea)+': Unable to perform command.');
      SysOpLog('^5Bad UL file path: "'+MemFileArea.Ulpath+'".');
      Print('^5Please inform the SysOp.');
      SysOpLog('Invalid UL path (File Area #'+IntToStr(FileArea)+'): "'+
      MemFileArea.Ulpath+'"');
    End;
  BadUploadPath := BadULPath;
End;

Function FileAreaAC(FArea: Integer): Boolean;
Begin
  FileAreaAC := FALSE;
  If (FArea < 1) Or (FArea > NumFileAreas) Then
    Exit;
  LoadFileArea(FArea);
  FileAreaAC := AACS(MemFileArea.ACS);
End;

Procedure ChangeFileArea(FArea: Integer);

Var 
  PW: Str20;
Begin
  If (FArea < 1) Or (FArea > NumFileAreas) Or (Not FileAreaAC(FArea)) Then
    Exit;
  If (MemFileArea.Password <> '') And (Not SortFilesOnly) Then
    Begin
      NL;
      Print('File area: ^5'+MemFileArea.AreaName+' #'+IntToStr(CompFileArea(
            FArea,0))+'^1');
      NL;
      Prt('Password: ');
      GetPassword(PW,20);
      If (PW <> MemFileArea.Password) Then
        Begin
          NL;
          Print('^7Incorrect password!^1');
          Exit;
        End;
    End;
  FileArea := FArea;
  ThisUser.LastFileArea := FileArea;
End;

Procedure LoadFileArea(FArea: Integer);

Var 
  FO: Boolean;
Begin
  If (ReadFileArea = FArea) Then
    Exit;
  If (FArea < 1) Then
    Exit;
  If (FArea > NumFileAreas) Then
    Begin
      MemFileArea := TempMemFileArea;
      ReadFileArea := FArea;
      Exit;
    End;
  FO := (FileRec(FileAreaFile).Mode <> FMClosed);
  If (Not FO) Then
    Begin
      Reset(FileAreaFile);
      LastError := IOResult;
      If (LastError > 0) Then
        Begin
          SysOpLog('FBASES.DAT/Open Error - '+IntToStr(LastError)+
          ' (Procedure: LoadFileArea - '+IntToStr(FArea)+')');
          Exit;
        End;
    End;
  Seek(FileAreaFile,(FArea - 1));
  LastError := IOResult;
  If (LastError > 0) Then
    Begin
      SysOpLog('FBASES.DAT/Seek Error - '+IntToStr(LastError)+
      ' (Procedure: LoadFileArea - '+IntToStr(FArea)+')');
      Exit;
    End;
  Read(FileAreaFile,MemFileArea);
  LastError := IOResult;
  If (LastError > 0) Then
    Begin
      SysOpLog('FBASES.DAT/Read Error - '+IntToStr(LastError)+
      ' (Procedure: LoadFileArea - '+IntToStr(FArea)+')');
      Exit;
    End
  Else
    ReadFileArea := FArea;
  If (Not FO) Then
    Begin
      Close(FileAreaFile);
      LastError := IOResult;
      If (LastError > 0) Then
        Begin
          SysOpLog('FBASES.DAT/Close Error - '+IntToStr(LastError)+
          ' (Procedure: LoadFileArea - '+IntToStr(FArea)+')');
          Exit;
        End;
    End;
  LastError := IOResult;
End;

Function GetDirPath(MemFileArea: FileAreaRecordType): AStr;
Begin
  If (FADirDLPath In MemFileArea.FAFlags) Then
    GetDirPath := MemFileArea.DLPath+MemFileArea.FileName
  Else
    GetDirPath := General.DataPath+MemFileArea.FileName;
End;

Procedure LoadNewScanFile(Var NewScanFile: Boolean);

Var 
  FileAreaScanFile: FILE Of Boolean;
  Counter: Integer;
Begin
  Assign(FileAreaScanFile,GetDirPath(MemFileArea)+'.SCN');
  Reset(FileAreaScanFile);
  If (IOResult = 2) Then
    ReWrite(FileAreaScanFile);
  If (UserNum > FileSize(FileAreaScanFile)) Then
    Begin
      NewScanFile := TRUE;
      Seek(FileAreaScanFile,FileSize(FileAreaScanFile));
      For Counter := FileSize(FileAreaScanFile) To (UserNum - 1) Do
        Write(FileAreaScanFile,NewScanFile);
    End
  Else
    Begin
      Seek(FileAreaScanFile,(UserNum - 1));
      Read(FileAreaScanFile,NewScanFile);
    End;
  Close(FileAreaScanFile);
  LastError := IOResult;
End;

Procedure SaveNewScanFile(NewScanFile: Boolean);

Var 
  FileAreaScanFile: FILE Of Boolean;
Begin
  Assign(FileAreaScanFile,GetDirPath(MemFileArea)+'.SCN');
  Reset(FileAreaScanFile);
  Seek(FileAreaScanFile,(UserNum - 1));
  Write(FileAreaScanFile,NewScanFile);
  Close(FileAreaScanFile);
  LastError := IOResult;
End;

Procedure InitFileArea(FArea: Integer);
Begin
  LoadFileArea(FArea);

  If ((Length(MemFileArea.DLPath) = 3) And (MemFileArea.DLPath[2] = ':') And (
     MemFileArea.DLPath[3] = '\')) Then
    BadDLPath := Not ExistDrive(MemFileArea.DLPath[1])
  Else If Not (FACDRom In MemFileArea.FAFlags) Then
         BadDLPath := Not ExistDir(MemFileArea.DLPath)
  Else
    BadDLPath := FALSE;

  If ((Length(MemFileArea.ULPath) = 3) And (MemFileArea.ULPath[2] = ':') And (
     MemFileArea.DLPath[3] = '\')) Then
    BadULPath := Not ExistDrive(MemFileArea.ULPath[1])
  Else If Not (FACDRom In MemFileArea.FAFlags) Then
         BadULPath := Not ExistDir(MemFileArea.ULPath)
  Else
    BadULPath := FALSE;

  If (Not DirFileOpen1) Then
    If (FileRec(FileInfoFile).Mode <> FMClosed) Then
      Close(FileInfoFile);
  DirFileOpen1 := FALSE;

  Assign(FileInfoFile,GetDirPath(MemFileArea)+'.DIR');
  Reset(FileInfoFile);
  If (IOResult = 2) Then
    ReWrite(FileInfoFile);
  If (IOResult <> 0) Then
    Begin
      SysOpLog('Error opening file: '+GetDirPath(MemFileArea)+'.DIR');
      Exit;
    End;

  If (Not ExtFileOpen1) Then
    If (FileRec(ExtInfoFile).Mode <> FMClosed) Then
      Close(ExtInfoFile);
  ExtFileOpen1 := FALSE;

  Assign(ExtInfoFile,GetDirPath(MemFileArea)+'.EXT');
  Reset(ExtInfoFile,1);
  If (IOResult = 2) Then
    ReWrite(ExtInfoFile,1);
  If (IOResult <> 0) Then
    Begin
      SysOpLog('Error opening file: '+GetDirPath(MemFileArea)+'.EXT');
      Exit;
    End;

  LoadNewScanFile(NewScanFileArea);

  FileAreaNameDisplayed := FALSE;
End;

Procedure DisplayFileInfo(Var F: FileInfoRecordType; Editing: Boolean);

Var 
  TempStr: AStr;
  Counter,
  NumLine,
  NumExtDesc: Byte;

Function DisplayFIStr(FIFlags: FIFlagSet): AStr;

Var 
  TempStr1: AStr;
Begin
  TempStr1 := '';
  If (FINotVal In FIFlags) Then
    TempStr1 := TempStr1 + ' ^8'+'<NV>';
  If (FIIsRequest In FIFlags) Then
    TempStr1 := TempStr1 + ' ^9'+'Ask (Request File)';
  If (FIResumeLater In FIFlags) Then
    TempStr1 := TempStr1 + ' ^7'+'Resume later';
  If (FIHatched In FIFlags) Then
    TempStr1 := TempStr1 + ' ^7'+'Hatched';
  DisplayFIStr := TempStr1;
End;

Begin
  Counter := 1;
  While (Counter <= 7) And (Not Abort) And (Not HangUp) Do
    Begin
      With F Do
        Begin
          If (Editing) Then
            TempStr := IntToStr(Counter)+'. '
          Else
            TempStr := '';
          Case Counter Of 
            1 : TempStr := TempStr + 'Filename         : ^0'+SQOutSp(FileName);
            2 : If (Not General.FileCreditRatio) Then
                  TempStr := TempStr + 'File size        : ^2'+ConvertBytes(
                             FileSize,FALSE)
                Else
                  TempStr := TempStr + 'File size        : ^2'+ConvertKB(
                             FileSize Div 1024,FALSE);
            3 :
                Begin
                  TempStr := TempStr + 'Description      : ^9'+Description;
                  PrintACR('^1'+TempStr);
                  If (F.VPointer <> -1) Then
                    Begin
                      LoadVerbArray(F,ExtendedArray,NumExtDesc);
                      NumLine := 1;
                      While (NumLine <= NumExtDesc) And (Not Abort) And (Not
                            HangUp) Do
                        Begin
                          PrintACR('^1'+AOnOff(Editing,PadLeftStr('',3),'')
                          +AOnOff(Editing And (NumLine = 1),PadLeftStr(
                                                                      'Extended'
                                                                       ,13),
                          PadLeftStr('',13))
                          +AOnOff(Editing,PadRightInt(NumLine,3),PadRightStr('',
                                                                             3))
                          +' : ^9'+ExtendedArray[NumLine]);
                          Inc(NumLine);
                        End;
                    End;
                  If (Editing) Then
                    If (F.VPointer = -1) Then
                      PrintACR('^5   No extended description.');
                End;
            4 : TempStr := TempStr + 'Uploaded by      : ^4'+Caps(OwnerName);
            5 : TempStr := TempStr + 'Uploaded on      : ^5'+PD2Date(FileDate);
            6 :
                Begin
                  TempStr := TempStr + 'Times downloaded : ^5'+FormatNumber(
                             Downloaded);
                  PrintACR('^1'+TempStr);
                  If (Not Editing) Then
                    Begin
                      TempStr := 'Block size       : 128-"^5'+IntToStr(FileSize
                                 Div 128)+
                                 '^1" / 1024-"^5'+IntToStr(FileSize Div 1024)+
                                 '^1"';
                      PrintACR('^1'+TempStr);
                      TempStr := 'Time to download : ^5'+CTim(FileSize Div Rate)
                      ;
                      PrintACR('^1'+TempStr);
                    End;
                End;
            7 : TempStr := TempStr + 'File point cost  : ^4'+AOnOff((FilePoints
                           > 0),FormatNumber(FilePoints),'FREE')+
                           DisplayFIStr(FIFlags);
          End;
          If (Not (Counter In [3,6])) Then
            PrintACR('^1'+TempStr+'^1');
        End;
      Inc(Counter);
    End;
End;

Function Fit(Const FileName1,FileName2: Str12): Boolean;

Var 
  Counter: Byte;
  Match: Boolean;
Begin
  Match := TRUE;
  For Counter := 1 To 12 Do
    If (FileName1[Counter] <> FileName2[Counter]) And (FileName1[Counter] <> '?'
       ) Then
      Match := FALSE;
  If (FileName2 = '') Then
    Match := FALSE;
  Fit := Match;
End;

Procedure GetFileName(Var FileName: Str12);
Begin
  MPL(12);
  InputMain(FileName,12,[NoLineFeed,UpperOnly]);
  If (FileName <> '') Then
    NL
  Else
    Begin
      MPL(12);
      FileName := '*.*';
      Print(FileName);
    End;
  FileName := Align(FileName);
End;

Function ISUL(Const s: AStr): Boolean;
Begin
  ISUL := ((Pos('/',s) <> 0) Or (Pos('\',s) <> 0) Or (Pos(':',s) <> 0) Or (Pos(
          '|',s) <> 0));
End;

Function IsWildCard(Const S: AStr): Boolean;
Begin
  IsWildCard := ((Pos('*',S) <> 0) Or (Pos('?',S) <> 0));
End;

Procedure LRecNo(FileInfo: FileInfoRecordType; Var RN: Integer);

Var 
  DirFileRecNum: Integer;
Begin
  RN := 0;
  If (LastDIRRecNum <= FileSize(FileInfoFile)) And (LastDIRRecNum >= 0) Then
    Begin
      DirFileRecNum := (LastDIRRecNum - 1);
      While (DirFileRecNum >= 0) And (RN = 0) Do
        Begin
          Seek(FileInfoFile,DirFileRecNum);
          Read(FileInfoFile,FileInfo);
          If Fit(LastDIRFileName,FileInfo.FileName) Then
            RN := DirFileRecNum;
          Dec(DirFileRecNum);
        End;
      LastDIRRecNum := RN;
    End
  Else
    RN := -1;
  LastError := IOResult;
End;

Procedure NRecNo(FileInfo: FileInfoRecordType; Var RN: Integer);

Var 
  DirFileRecNum: Integer;
Begin
  RN := 0;
  If (LastDIRRecNum < FileSize(FileInfoFile)) And (LastDIRRecNum >= -1) Then
    Begin
      DirFileRecNum := (LastDIRRecNum + 1);
      While (DirFileRecNum < FileSize(FileInfoFile)) And (RN = 0) Do
        Begin
          Seek(FileInfoFile,DirFileRecNum);
          Read(FileInfoFile,FileInfo);
          If Fit(LastDIRFileName,FileInfo.FileName) Then
            RN := (DirFileRecNum + 1);
          Inc(DirFileRecNum);
        End;
      Dec(RN);
      LastDIRRecNum := RN;
    End
  Else
    RN := -1;
  LastError := IOResult;
End;

Procedure RecNo(FileInfo: FileInfoRecordType; FileName: Str12; Var RN: Integer);

Var 
  DirFileRecNum: Integer;
Begin
  InitFileArea(FileArea);
  FileName := Align(FileName);
  RN := 0;
  DirFileRecNum := 0;
  While (DirFileRecNum < FileSize(FileInfoFile)) And (RN = 0) Do
    Begin
      Seek(FileInfoFile,DirFileRecNum);
      Read(FileInfoFile,FileInfo);
      If Fit(FileName,FileInfo.FileName) Then
        RN := (DirFileRecNum + 1);
      Inc(DirFileRecNum);
    End;
  Dec(RN);
  LastDIRRecNum := RN;
  LastDIRFileName := FileName;
  LastError := IOResult;
End;

Procedure LoadVerbArray(F: FileInfoRecordType; Var ExtArray:
                        ExtendedDescriptionArray; Var NumExtDesc: Byte);

Var 
  VerbStr: AStr;
  TotLoad: Integer;
  VFO: Boolean;
Begin
  FillChar(ExtArray,SizeOf(ExtArray),0);
  NumExtDesc := 1;
  VFO := (FileRec(ExtInfoFile).Mode <> FMClosed);
  If (Not VFO) Then
    Reset(ExtInfoFile,1);
  If (IOResult = 0) Then
    Begin
      TotLoad := 0;
      Seek(ExtInfoFile,(F.VPointer - 1));
      Repeat
        BlockRead(ExtInfoFile,VerbStr[0],1);
        BlockRead(ExtInfoFile,VerbStr[1],Ord(VerbStr[0]));
        Inc(TotLoad,(Length(VerbStr) + 1));
        ExtArray[NumExtDesc] := VerbStr;
        Inc(NumExtDesc);
      Until (TotLoad >= F.VTextSize);
      If (Not VFO) Then
        Close(ExtInfoFile);
    End;
  Dec(NumExtDesc);
  LastError := IOResult;
End;

Procedure SaveVerbArray(Var F: FileInfoRecordType; ExtArray:
                        ExtendedDescriptionArray; NumExtDesc: Byte);

Var 
  LineNum: Byte;
  VFO: Boolean;
Begin
  VFO := (FileRec(ExtInfoFile).Mode <> FMClosed);
  If (Not VFO) Then
    Reset(ExtInfoFile,1);
  If (IOResult = 0) Then
    Begin
      F.VPointer := (FileSize(ExtInfoFile) + 1);
      F.VTextSize := 0;
      Seek(ExtInfoFile,FileSize(ExtInfoFile));
      For LineNum := 1 To NumExtDesc Do
        If (ExtArray[LineNum] <> '') Then
          Begin
            Inc(F.VTextSize,(Length(ExtArray[LineNum]) + 1));
            BlockWrite(ExtInfoFile,ExtArray[LineNum],(Length(ExtArray[LineNum])
            + 1));
          End;
      If (Not VFO) Then
        Close(ExtInfoFile);
    End;
  LastError := IOResult;
End;

Procedure CountDown;

Var 
  Cmd: Char;
  Counter: Byte;
  SaveTimer: LongInt;
Begin
  NL;
  Print('Press <^5CR^1> to logoff now.');
  Print('Press <^5Esc^1> to abort logoff.');
  NL;
  Prompt('|12Hanging up in: ^99');
  SaveTimer := Timer;
  Cmd := #0;
  Counter := 9;
  While (Counter > 0) And Not (Cmd In [#13,#27]) And (Not HangUp) Do
    Begin
      If (Not Empty) Then
        Cmd := Char(InKey);
      If (Timer <> SaveTimer) Then
        Begin
          Dec(Counter);
          Prompt(^H+IntToStr(Counter));
          SaveTimer := Timer;
        End
      Else
{$IFDEF MSDOS}
        ASM
        Int 28h
    End;
{$ENDIF}
{$IFDEF WIN32}
  Sleep(1);
{$ENDIF}
End;
If (Cmd <> #27) Then
  Begin
    HangUp := TRUE;
    OutCom := FALSE;
  End;
UserColor(1);
End;

End.
