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

UNIT File13;

INTERFACE

PROCEDURE Sort;

IMPLEMENTATION

USES
  Common,
  File0;

PROCEDURE SortDir(NumFiles: Word);
VAR
  FileInfo1: FileInfoRecordType;
  NumSorted,
  RecNum,
  RecNum1,
  Gap: Word;
BEGIN
  Gap := NumFiles;
  REPEAT;
    Gap := (Gap DIV 2);
    IF (Gap = 0) THEN
      Gap := 1;
    NumSorted := 0;
    FOR RecNum := 1 TO (NumFiles - Gap) DO
    BEGIN
      RecNum1 := (RecNum + Gap);
      Seek(FileInfoFile,(RecNum - 1));
      Read(FileInfoFile,FileInfo);
      Seek(FileInfoFile,(RecNum1 - 1));
      Read(FileInfoFile,FileInfo1);
      IF (FileInfo.FileName > FileInfo1.FileName) THEN
      BEGIN
        Seek(FileInfoFile,(RecNum - 1));
        Write(FileInfoFile,FileInfo1);
        Seek(FileInfoFile,(RecNum1 - 1));
        Write(FileInfoFile,FileInfo);
        Inc(NumSorted);
      END;
    END;
  UNTIL (NumSorted = 0) AND (Gap = 1);
  IF (IOResult <> 0) THEN
    SysOpLog('Error sorting files!');
END;

PROCEDURE SortFiles(FArea: Integer; VAR TotFiles: LongInt; VAR TotAreas: Integer);
VAR
  NumFiles: Word;
BEGIN
  IF (FileArea <> FArea) THEN
    ChangeFileArea(FArea);
  IF (FileArea = FArea) THEN
  BEGIN
    InitFileArea(FileArea);
    NumFiles := FileSize(FileInfoFile);
    Prompt('^1Sorting ^5'+MemFileArea.AreaName+' #'+IntToStr(FileArea)+'^1 ('+FormatNumber(NumFiles)+
           ' '+Plural('file',NumFiles)+')');
    IF (NumFiles <> 0) THEN
      SortDir(NumFiles);
    Close(FileInfoFile);
    Close(ExtInfoFile);
    Inc(TotAreas);
    Inc(TotFiles,NumFiles);
    NL;
  END;
END;

PROCEDURE Sort;
VAR
  FArea,
  TotAreas,
  SaveFileArea: Integer;
  TotFiles: LongInt;
  Global,
  SaveConfSystem: Boolean;
BEGIN
  NL;
  IF (NOT SortFilesOnly) THEN
    Global := PYNQ('Sort all file areas? ',0,FALSE)
  ELSE
  BEGIN
    Global := TRUE;
    CLS;
   END;
  NL;
  TotFiles := 0;
  TotAreas := 0;
  IF (NOT Global) THEN
    SortFiles(FileArea,TotFiles,TotAreas)
  ELSE
  BEGIN
    SaveFileArea := FileArea;
    SaveConfSystem := ConfSystem;
    ConfSystem := FALSE;
    IF (SaveConfSystem) THEN
      NewCompTables;
    Abort := FALSE;
    Next := FALSE;
    TempPause := FALSE;
    FArea := 1;
    WHILE (FArea >= 1) AND (FArea <= NumFileAreas) AND (NOT Abort) AND (NOT HangUp) DO
    BEGIN
      IF FileAreaAC(FArea) OR (SortFilesOnly) THEN
        SortFiles(FArea,TotFiles,TotAreas);
      WKey;
      Inc(FArea);
    END;
    ConfSystem := SaveConfSystem;
    IF (SaveConfSystem) THEN
      NewCompTables;
    FileArea := SaveFileArea;
    LoadFileArea(FileArea);
  END;
  NL;
  Print('Sorted '+FormatNumber(TotFiles)+' '+Plural('file',TotFiles)+
        ' in '+FormatNumber(TotAreas)+' '+Plural('area',TotAreas));
  SysOpLog('Sorted file areas');
END;

END.
