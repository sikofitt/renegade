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

{$A+,B-,D+,E-,F+,I-,L+,N-,O+,R-,S+,V-}

Unit Archive1;

Interface

Uses
  Common;

Procedure ArcDeComp(VAR Ok: Boolean; AType: Byte;
  Const FileName, FileSpec: AnsiString);
Procedure ArcComp(Var Ok: Boolean; AType: Byte;
  Const FileName, FileSpec: AnsiString);
Procedure ArcComment(Var Ok: Boolean; AType: Byte;
  CommentNumber: Byte; Const FileName: AnsiString);
Procedure ArcIntegrityTest(Var Ok: Boolean; AType: Byte;
  Const FileName: AnsiString);
Procedure ConvA(Var Ok: Boolean; OldArchiveType, NewArchiveType: Byte;
  Const OldFileName, NewFileName: Ansistring);
Function  ArcType(FileName: AnsiString): Byte;
Procedure ListArcTypes;
Procedure InvArc;
Procedure ExtractToTemp;
Procedure UserArchive;

Implementation

Uses
  Dos,
  ArcView,
  ExecBat,
  File0,
  File1,
  File2,
  File9,
  SysUtils,
  TimeFunc;

{ De-compresses an Archive }
Procedure ArcDeComp(Var Ok: Boolean; AType: Byte; Const FileName, FileSpec: AnsiString);
Var
  ResultCode: Byte;

Begin
  PurgeDir(TempDir+'ARC\',FALSE);
  ExecBatch(Ok, TempDir+'ARC\', General.ArcsPath +
            FunctionalMCI(General.FileArcInfo[AType].UnArcLine, FileName, FileSpec),
            General.FileArcInfo[AType].SuccLevel, ResultCode, False);
  If (Not Ok) And (Pos('.diz', AnsiLowerCase(FileSpec)) = 0) Then
    Begin
      SysOpLog(FileName+': errors during de-compression');
    End;
End;

{ Compresses an Archive }
Procedure ArcComp(Var Ok: Boolean; AType: Byte; Const FileName, FileSpec: AnsiString);
Var
  ResultCode: Byte;

Begin
  If (General.FileArcInfo[AType].ArcLine = '') Then
    Begin
      Ok := True
    End;
  Else Begin
    ExecBatch(Ok,TempDir+'ARC\',General.ArcsPath+
              FunctionalMCI(General.FileArcInfo[AType].ArcLine, FileName, FileSpec),
              General.FileArcInfo[AType].SuccLevel, ResultCode, False);
  If (Not Ok) Then
    Begin
    SysOpLog(FileName+': errors during compression');
    End;
  End;
End;

{ Adds a comment to an archive }
Procedure ArcComment(Var Ok: Boolean; AType: Byte; CommentNumber: Byte; Const FileName: AnsiString);
VAR
  TempStr: AnsiString;
  ResultCode: Byte;
  SaveSwapShell: Boolean;

Begin
  If (CommentNumber > 0) And (General.FileArcComment[CommentNumber] <> '') Then
  Begin
    SaveSwapShell := General.SwapShell;
    General.SwapShell := FALSE;
    TempStr := Substitute(General.FileArcInfo[AType].CmtLine,
      '%C', General.FileArcComment[CommentNumber]);
    TempStr := Substitute(TempStr, '%C', General.FileArcComment[CommentNumber]);
    ExecBatch(Ok, TempDir+'ARC\',
      General.ArcsPath+FunctionalMCI(TempStr, FileName, ''),
      General.FileArcInfo[AType].SuccLevel, ResultCode, False);
    General.SwapShell := SaveSwapShell;
  End;
End;

Procedure ArcIntegrityTest(Var Ok: Boolean; AType: Byte; Const FileName: AnsiString);
Var
  ResultCode: Byte;

Begin
  If (General.FileArcInfo[AType].TestLine <> '') Then
    Begin
      ExecBatch(Ok, TempDir+'ARC\', General.ArcsPath+
              FunctionalMCI(General.FileArcInfo[AType].TestLine, FileName,''),
              General.FileArcInfo[AType].SuccLevel, ResultCode, False);
    End;
END;

Procedure ConvA(Var Ok: Boolean; OldArchiveType, NewArchiveType: Byte; Const OldFileName, NewFileName: AnsiString);
Var
  TempFileName: AnsiString;
  Path: PathStr;
  Name: NameStr;
  Extension: ExtStr;
  FileTime: LongInt;
  Match: Boolean;

Begin
  Star('Converting archive - stage one.');

  Match := (OldArchiveType = NewArchiveType);
  If (Match) Then
  Begin
    FSplit(OldFileName, Path, Name, Extension);
    TempFileName := Path+Name+'.#$%';
  End;

{  GetFileDateTime(OldFileName, FileTime);}
   FileAge(OldFileName, FileTime);

  ArcDeComp(Ok, OldArchiveType, OldFileName, '*.*');
  If (Not Ok) Then
  Begin
    Star('Errors in decompression!')
  End
  Else Begin
    Star('Converting archive - stage two.');

    If (Match) Then
    Begin
      RenameFile('', OldFileName, TempFileName, Ok);
    End
    ArcComp(Ok,NewArchiveType, NewFileName, '*.*');
    If (Not Ok) Then
    Begin
      Star('Errors in compression!');
      If (Match) Then
        Begin
          RenameFile('', TempFileName, OldFileName, Ok);
        End;
    End
    Else Begin
{      SetFileDateTime(NewFileName, FileTime);}
       FileSetDate(NewFileName, FileTime);
    End;
    If (Not Exist(SQOutSp(NewFileName))) Then
      Begin
      Ok := FALSE;
      End;
  End;
  If (Exist(TempFileName)) Then
    Begin
     Kill(TempFileName);
    End;
End;

Function ArcType(FileName: AnsiString): Byte;
Var
  AType,
  Counter: Byte;

Begin
  AType := 0;
  Counter := 1;
  While (Counter <= MaxArcs) And (AType = 0) Do
  Begin
    If (General.FileArcInfo[Counter].Active) Then
      Begin
        If (General.FileArcInfo[Counter].Ext <> '') Then
          Begin
            If (General.FileArcInfo[Counter].Ext
              = Copy(FileName,(Length(FileName) - 2),3)) Then
              Begin
                AType := Counter;
              End;
          End;
      End;
    Inc(Counter);
  End;
  ArcType := AType;
End;

Procedure ListArcTypes;
Var
  RecordNumber1,
  RecordNumber2: Byte;

Begin
  RecordNumber2 := 0;
  RecordNumber1 := 1;
  While (RecordNumber1 <= MaxArcs) And (General.FileArcInfo[RecordNumber1].Ext <> '') Do
  Begin
    If (General.FileArcInfo[RecordNumber1].Active) Then
    Begin
      Inc(RecordNumber2);
      If (RecordNumber2 = 1) Then
        Begin
          Prompt('^1Available archive formats: ')
        End
      Else Begin
        Prompt('^1,');
      End;
      Prompt('^5'+General.FileArcInfo[RecordNumber1].Ext+'^1');
    End;
    Inc(RecordNumber1);
  End;
  If (RecordNumber2 = 0) Then
    Begin
      Prompt('No archive formats available.');
    End;
  NL;
End;

Procedure InvArc;
Begin
  NL;
  Print('Unsupported archive format.');
  NL;
  ListArcTypes;
End;

Procedure ExtractToTemp;
Type
  TotalsRecordType = Record
    TotalFiles: SmallInt;
    TotalSize: LongInt;
  End;
Var
  Totals: TotalsRecordType;
  FileName,
  ArchiveFileName: AnsiString;
  (*
  DirInfo: SearchRec;
  *)
  Directory: DirStr;
  Name: NameStr;
  Extension: ExtStr;
  Command: Char;
  ArchiveType,
  ReturnCode: Byte;
  DirectoryFileRecordNumber: LongInt;
  DidSomething,
  Ok: Boolean;
Begin
  NL;
  Print('Extract to temporary directory -');
  NL;
  Prompt('^1Already in TEMP: ');

  FillChar(Totals, SizeOf(Totals), 0);
  FindFirst(TempDir+'ARC\*.*', AnyFile - Directory - VolumeID - Hidden - SysFile, DirInfo);
  While (DOSError = 0) Do
  Begin
    Inc(Totals.TotalFiles);
    Inc(Totals.TotalSize, DirInfo.Size);
    FindNext(DirInfo);
  End;

  If (Totals.TotalFiles = 0) Then
    Begin
      Print('^5Nothing.^1')
    End;
  Else Begin
    Print('^5'+FormatNumber(Totals.TotalFiles)+
          ' '+Plural('file',Totals.TotalFiles)+
          ', '+ConvertBytes(Totals.TotalSize, False)+'.^1');
  End;
  If (Not FileSysOp) Then
  Begin
    NL;
    Print('The limit is '+FormatNumber(General.MaxInTemp)+'k bytes.');
    If (Totals.TotalSize > (General.MaxInTemp * 1024)) Then
    Begin
      NL;
      Print('You have exceeded this limit.');
      NL;
      Print('Please remove some files with the user-archive command.');
      Exit;
    End;
  End;

  NL;
  Prt('File name: ');
  If (FileSysOp) Then
  Begin
    SetLength(FileName, 52);
    MPL(52);
    Input(FileName,52);
  End
  Else Begin
    SetLength(FileName, 12);
    MPL(12);
    Input(FileName,12);
  End;

  FileName := SQOutSp(FileName);

  If (FileName = '') Then
  Begin
    NL;
    Print('Aborted!');
    Exit;
  End;

  If (IsUL(FileName)) And (Not FileSysOp) Then
  Begin
    NL;
    Print('^7Invalid file name!^1');
    Exit;
  End;

  If (Pos('.', FileName) = 0) Then
    Begin
      SetLength(FileName, SizeOf(FileName) + 2);
      FileName := FileName + '*.*';
    End;
  Ok := True;

  If (Not IsUL(FileName)) Then
  Begin
    RecNo(FileInfo,FileName,DirectoryFileRecordNumber);
    If (BadDownloadPath) Then
      Exit;
    If (Not AACS(MemFileArea.DLACS)) Then
    Begin
      NL;
      Print('^7You do not have access to manipulate that file!^1');
      Exit;
    End
    Else If (DirectoryFileRecordNumber = -1) Then
    Begin
      NL;
      Print('^7File not found!^1');
      Exit;
    End
    Else Begin
      Seek(FileInfoFile,DirectoryFileRecordNumber);
      Read(FileInfoFile,FileInfo);
      If Exist(MemFileArea.DLPath+FileInfo.FileName) Then
        ArcFileName := MemFileArea.DLPath+SQOutSp(FileInfo.FileName)
      Else
        ArcFileName := MemFileArea.ULPath+SQOutSp(FileInfo.FileName);
    End;

  End
  Else Begin
    ArchiveFileName := FExpand(FileName);
    If (Not Exist(ArchiveFileName)) Then
    Begin
      NL;
      Print('^7File not found!^1');
      Exit;
    End
    Else Begin
      FillChar(FileInfo,SizeOf(FileInfo),0);
      With FileInfo Do
      Begin
        FileName := Align(StripName(ArchiveFileName));
        Description := 'Unlisted file';
        FilePoints := 0;
        Downloaded := 0;
        FileSize := GetFileSize(ArchiveFileName);
        OwnerNum := UserNum;
        OwnerName := ThisUser.Name;
        FileDate := Date2PD(DateStr);
        VPointer := -1;
        VTextSize := 0;
        FIFlags := [];
      End;
    End;
  End;
  If (Ok) Then
  Begin
    DidSomething := False;
    Abort := False;
    Next := False;
    AType := ArcType(ArchiveFileName);
    If (AType = 0) Then
      InvArc;
    NL;
    Print('You can (^5C^1)opy this file into the TEMP Directory,'); { @ConvertToString }
    If (AType <> 0) Then
      Print('or (^5E^1)xtract files from it into the TEMP Directory.') { @ConvertToString }
    Else
      Print('but you can''t extract files from it.'); { @ConvertToString }
    NL;
    Prt('Which? (^5C^4=^5Copy'+AOnOff((AType <> 0),'^4,^5E^4=^5Extract','')
      +'^4,^5Q^4=^5Quit^4): '); { @ConvertToString }
    OneK(Command,'QC'+AOnOff((AType <> 0),'E',''), True, True);
    Case Command Of
      'C' : Begin
              FSplit(ArchiveFileName, Directory, Name, Extension);
              NL;
              If CopyMoveFile(TRUE,'^5Progress: ',ArcFileName,TempDir+'ARC\'+NS+ES,TRUE) Then
                DidSomething := True;
            End;
      'E' : Begin
              NL;
              DisplayFileInfo(FileInfo,True);
              Repeat
                NL;
                Prt('Extract files (^5E^4=^5Extract^4,^5V^4=^5View^4,^5Q^4=^5Quit^4): '); { @ConvertToString }
                OneK(Command,'QEV',TRUE,TRUE);
                CASE Command OF
                  'E' : Begin
                          NL;
                          If PYNQ('Extract all files? ',0, False) Then { @ConvertToString }
                            FileName := '*.*'
                          Else
                          Begin
                            NL;
                            Prt('File name: ');                { @ConvertToString }
                            MPL(12);
                            SetLength(FileName, 12);
                            Input(FileName,12);
                            FileName := SQOutSp(FileName);
                            IF (FileName = '') THEN
                            Begin
                              NL;
                              Print('Aborted!');
                            End
                            Else If IsUL(FileName) Then
                            Begin
                              NL;
                              Print('^7Illegal filespec!^1');
                              FileName := '';
                            End;
                          End;
                          If (FileName <> '') Then
                          Begin
                            Ok := FALSE;
                            ExecBatch(Ok,TempDir+'ARC\',
                              General.ArcsPath+
                              FunctionalMCI(General.FileArcInfo[AType].UnArcLine,
                              ArcFileName,FileName),
                              General.FileArcInfo[AType].SuccLevel,ReturnCode,
                              FALSE);
                            If (Ok) Then
                            Begin
                              NL;
                              Star('Decompressed '+FileName+' into TEMP from '+StripName(ArcFileName));
                              SysOpLog('Decompressed '+FileName+' into '+TempDir+'ARC\ from '+StripName(ArcFileName));
                              DidSomething := TRUE;
                            End
                            Else Begin
                              NL;
                              Star('Error decompressing '+FileName+' into TEMP from '+StripName(ArcFileName));
                              SysOpLog('Error decompressing '+FileName+' into '+TempDir+'ARC\ from '+StripName(ArcFileName));
                            End;
                          End;
                        End;
                  'V' : If (IsUL(ArchiveFileName)) Then
                          ViewInternalArchive(ArchiveFileName)
                        Else Begin
                          If FileExists(MemFileArea.DLPath+FileInfo.FileName) Then
                            ViewInternalArchive(MemFileArea.DLPath+FileInfo.FileName)
                          Else
                            ViewInternalArchive(MemFileArea.ULPath+FileInfo.FileName);
                        End;
                End;
              Until (Command = 'Q') Or (HangUp);
           End;
    End;
    If (DidSomething) Then
    Begin
      NL;
      Print('^5NOTE: ^1Use the user archive menu command to access');
      Print('        files in the TEMP directory.^1');
    End;
  End;
  LastError := IOResult;
End;

Procedure UserArchive;
Var
  User: UserRecordType;
  (*
  DirInfo: SearchRec;
  *)
  TransferFlags: TransferFlagSet;
  ArchiveFileName,
  FileName: AnsiString; // Str12;
  Command: Char;
  AType,
  SaveNumBatchDLFiles: Byte;
  ReturnCode: LongInt;
  GotPts,
  SaveFileArea: LongInt;
  Ok,
  SaveFileCreditRatio: Boolean;
{@Pickup}
  Function OkName(FileName1: AStr): Boolean;
  Begin
    OkName := TRUE;
    OkName := NOT IsWildCard(FileName1);
    IF (IsUL(FileName1)) THEN
      OkName := FALSE;
  END;

BEGIN
  REPEAT
    NL;
    Prt('Temp archive menu [^5?^4=^5Help^4]: ');
    OneK(Cmd,'QADLRVT?',TRUE,TRUE);
    CASE Cmd OF
      'A' : BEGIN
              NL;
              Prt('Archive name: ');
              MPL(12);
              Input(ArcFileName,12);
              IF (ArcFileName = '') THEN
              BEGIN
                NL;
                Print('Aborted!');
              END
              ELSE
              BEGIN

                LoadFileArea(FileArea);

                IF (Pos('.',ArcFileName) = 0) AND (MemFileArea.ArcType <> 0) THEN
                  ArcFileName := ArcFileName+'.'+General.FileArcInfo[MemFileArea.ArcType].Ext;

                AType := ArcType(ArcFileName);
                IF (AType = 0) THEN
                  InvArc
                ELSE
                BEGIN
                  NL;
                  Prt('File name: ');
                  MPL(12);
                  Input(FName,12);
                  IF (FName = '') THEN
                  BEGIN
                    NL;
                    Print('Aborted!');
                  END
                  ELSE IF (IsUL(FName)) OR (Pos('@',FName) > 0) THEN
                  BEGIN
                    NL;
                    Print('^7Illegal file name!^1');
                  END
                  ELSE IF (NOT Exist(TempDir+'ARC\'+FName)) THEN
                  BEGIN
                    NL;
                    Print('^7File not found!^1');
                  END
                  ELSE
                  BEGIN
                    Ok := FALSE;
                    ExecBatch(Ok,TempDir+'ARC\',General.ArcsPath+
                              FunctionalMCI(General.FileArcInfo[AType].ArcLine,TempDir+'ARC\'+ArcFileName,FName),
                              General.FileArcInfo[AType].SuccLevel,ReturnCode,FALSE);
                    IF (Ok) THEN
                    BEGIN
                      NL;
                      Star('Compressed "^5'+FName+'^3" into "^5'+ArcFileName+'^3"');
                      SysOpLog('Compressed "^5'+FName+'^1" into "^5'+TempDir+'ARC\'+ArcFileName+'^1"')
                    END
                    ELSE
                    BEGIN
                      NL;
                      Star('Error compressing "^5'+FName+'^3" into "^5'+ArcFileName+'^3"');
                      SysOpLog('Error compressing "^5'+FName+'^1" into "^5'+TempDir+'ARC\'+ArcFileName+'^1"');
                    END;
                  END;
                END;
              END;
            END;
      'D' : BEGIN
              NL;
              Prt('File name: ');
              MPL(12);
              Input(FName,12);
              IF (FName = '') THEN
              BEGIN
                NL;
                Print('Aborted!');
              END
              ELSE IF (NOT OkName(FName)) THEN
              BEGIN
                NL;
                Print('^7Illegal file name!^1');
              END
              ELSE
              BEGIN
                FindFirst(TempDir+'ARC\'+FName,AnyFile - Directory - VolumeID - Hidden - SysFile,DirInfo);
                IF (DOSError <> 0) THEN
                BEGIN
                  NL;
                  Print('^7File not found!^1');
                END
                ELSE
                BEGIN
                  SaveFileArea := FileArea;
                  FileArea := -1;
                  WITH MemFileArea DO
                  BEGIN
                    AreaName := 'Temp Archive';
                    DLPath := TempDir+'ARC\';
                    ULPath := TempDir+'ARC\';
                    FAFlags := [];
                  END;
                  (* Consider charging points, ext. *)
                  LoadURec(User,1);
                  WITH FileInfo DO
                  BEGIN
                    FileName := Align(FName);
                    Description := 'Temporary Archive';
                    FilePoints := 0;
                    Downloaded := 0;
                    FileSize := GetFileSize(TempDir+'ARC\'+FileName);;
                    OwnerNum := 1;
                    OwnerName := Caps(User.Name);
                    FileDate := Date2PD(DateStr);
                    VPointer := -1;
                    VTextSize := 0;
                    FIFlags := [];
                  END;
                  TransferFlags := [IsTempArc,IsCheckRatio];
                  SaveNumBatchDLFiles := NumBatchDLFiles;
                  DLX(FileInfo,-1,TransferFlags);
                  FileArea := SaveFileArea;
                  LoadFileArea(FileArea);
                  IF (NumBatchDLFiles <> SaveNumBatchDLFiles) THEN
                  BEGIN
                    NL;
                    Print('^5REMEMBER: ^1If you delete this file from the temporary directory,');
                    Print('            you will not be able to download it in your batch queue.');
                  END;
                END;
              END;
            END;
      'L' : BEGIN
              AllowContinue := TRUE;
              NL;
              DosDir(TempDir+'ARC\','*.*',TRUE);
              AllowContinue := FALSE;
              SysOpLog('Listed temporary directory: "^5'+TempDir+'ARC\*.*^1"');
            END;
      'R' : BEGIN
              NL;
              Prt('File mask: ');
              MPL(12);
              Input(FName,12);
              IF (FName = '') THEN
              BEGIN
                NL;
                Print('Aborted!');
              END
              ELSE IF (IsUL(FName)) THEN
              BEGIN
                NL;
                Print('^7Illegal file name!^1');
              END
              ELSE
              BEGIN
                FindFirst(TempDir+'ARC\'+FName,AnyFile - Directory - VolumeID - Hidden - SysFile,DirInfo);
                IF (DOSError <> 0) THEN
                BEGIN
                  NL;
                  Print('^7File not found!^1');
                END
                ELSE
                BEGIN
                  NL;
                  REPEAT
                    Kill(TempDir+'ARC\'+DirInfo.Name);
                    Star('Removed temporary archive file: "^5'+DirInfo.Name+'^3"');
                    SysOpLog('^1Removed temp arc file: "^5'+TempDir+'ARC\'+DirInfo.Name+'^1"');
                    FindNext(DirInfo);
                  UNTIL (DOSError <> 0) OR (HangUp);
                END;
              END;
            END;
      'T' : BEGIN
              NL;
              Prt('File name: ');
              MPL(12);
              Input(FName,12);
              IF (FName = '') THEN
              BEGIN
                NL;
                Print('Aborted!');
              END
              ELSE IF (NOT OkName(FName)) THEN
              BEGIN
                NL;
                Print('^7Illegal file name!^1');
              END
              ELSE
              BEGIN
                FindFirst(TempDir+'ARC\'+FName,AnyFile - Directory - VolumeID - Hidden - SysFile,DirInfo);
                IF (DOSError <> 0) THEN
                BEGIN
                  NL;
                  Print('^7File not found!^1');
                END
                ELSE
                BEGIN
                  NL;
                  PrintF(TempDir+'ARC\'+DirInfo.Name);
                  SysOpLog('Displayed temp arc file: "^5'+TempDir+'ARC\'+DirInfo.Name+'^1"');
                END;
              END;
            END;
      'V' : BEGIN
              NL;
              Prt('File mask: ');
              MPL(12);
              Input(FName,12);
              IF (FName = '') THEN
              BEGIN
                NL;
                Print('Aborted!');
              END
              ELSE IF (NOT ValidIntArcType(FName)) THEN
              BEGIN
                NL;
                Print('^7Not a valid archive type or not supported!^1')
              END
              ELSE
              BEGIN
                FindFirst(TempDir+'ARC\'+FName,AnyFile - Directory - VolumeID - Hidden - SysFile,DirInfo);
                IF (DOSError <> 0) THEN
                BEGIN
                  NL;
                  Print('^7File not found!^1');
                END
                ELSE
                BEGIN
                  Abort := FALSE;
                  Next := FALSE;
                  REPEAT
                    ViewInternalArchive(TempDir+'ARC\'+DirInfo.Name);
                    SysOpLog('Viewed temp arc file: "^5'+TempDir+'ARC\'+DirInfo.Name+'^1"');
                    FindNext(DirInfo);
                  UNTIL (DOSError <> 0) OR (Abort) OR (HangUp);
                END;
              END;
            END;
      '?' : BEGIN
              NL;
              ListArcTypes;
              NL;
              LCmds(30,3,'Add to archive','');
              LCmds(30,3,'Download files','');
              LCmds(30,3,'List files in directory','');
              LCmds(30,3,'Remove files','');
              LCmds(30,3,'Text view file','');
              LCmds(30,3,'View archive','');
              LCmds(30,3,'Quit','');
            END;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
  LastCommandOvr := TRUE;
  LastError := IOResult;
END;

END.
