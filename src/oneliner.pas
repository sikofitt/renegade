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

Unit OneLiner;

Interface

Uses 
Common,
Timefunc,
Mail1,
SysUtils; //Needed for FileExists

Type 
  OneLinerRecordType = Record
    RecordNum  : LongInt;
    OneLiner   : String[55];
    UserID     : LongInt;
    UserName   : String[36];
    DateAdded,
    DateEdited : UnixTime;
    Anonymous  : Boolean;
  End;

Procedure DoOneLiners;
Procedure OneLiner_Add;
Procedure OneLiner_View;
Function OneLiner_Random : STRING;
Function ToLower( S : String ) : STRING;

Implementation

Var 
  OneLinerListFile : FILE Of OneLinerRecordType;
  OneLineRec  : OneLinerRecordType;

Function ToLower( S : String ) : STRING;

Var 
  i : BYTE;
Begin
  For i := 1 To Length(S) Do
    Begin
      If S[i] In ['A'..'Z'] Then
        S[i] := Chr(Ord(S[i]) + 32);
    End;
  ToLower := S;
End;

Function OneLinerListMCI(Const S: ASTR; Data1,Data2: Pointer): STRING;

Var 
  OneLinerListPtr: ^OneLinerRecordType;
  User: UserRecordType;
  TmpStr : String;
Begin
  OneLinerListPtr := Data1;
  OneLinerListMCI := S;
  Case S[1] Of 
    'A' : Case S[2] Of 
            'N' : OneLinerListMCI := ShowYesNo(OneLinerListPtr^.Anonymous);
            { Anon - Yes/No }
            'T' : OneLinerListMCI := AonOff(OneLinerListPtr^.Anonymous, 'True',
                                     'False'); { Anon - True/False }
          End;
    'D' : Case S[2] Of 
            'A' : OneLinerListMCI := Pd2Date(OneLinerListPtr^.DateAdded);
            { Date Added }
            'E' : OneLinerListMCI := Pd2Date(OneLinerListPtr^.DateEdited);
            { Date Edited - Not Used }
          End;
    'O' : Case S[2] Of 
            'L' : OneLinerListMCI := OneLinerListPtr^.OneLiner; { The Oneliner }
          End;
    'R' : Case S[2] Of 
            'N' : OneLinerListMCI := IntToStr(OneLinerListPtr^.RecordNum);
            { Oneliner Record Number }
          End;
    'U' : Case S[2] Of 
            '#' :
                  Begin { User ID }
                    If (OneLinerListPtr^.Anonymous) Then
                      OneLinerListMCI := '';
                    If (OneLinerListPtr^.Anonymous) And (SysOp) Then
                      OneLinerListMCI := '#' + IntToStr(OneLinerListPtr^.UserID)
                    ;
                    If (Not OneLinerListPtr^.Anonymous) Then
                      OneLinerListMCI := '#' + IntToStr(OneLinerListPtr^.UserID)
                    ;
                  End;
            '1' :
                  Begin { User ID Without # }
                    If (OneLinerListPtr^.Anonymous) Then
                      OneLinerListMCI := '';
                    If (OneLinerListPtr^.Anonymous) And (SysOp) Then
                      OneLinerListMCI := IntToStr(OneLinerListPtr^.UserID);
                    If (Not OneLinerListPtr^.Anonymous) Then
                      OneLinerListMCI := IntToStr(OneLinerListPtr^.UserID);
                  End;
            'N' :
                  Begin { User Name }
                    LoadURec(User,OneLinerListPtr^.UserID);
                    If (OneLinerListPtr^.Anonymous) Then
                      OneLinerListMCI := 'Anon';
                    If (OneLinerListPtr^.Anonymous) And (SysOp) Then
                      OneLinerListMCI := Caps(User.Name) + ' ^4(^5A^4)';
                    If (Not OneLinerListPtr^.Anonymous) Then
                      OneLinerListMCI := Caps(User.Name);
                  End;
            'L' :
                  Begin { User Name Lower }
                    LoadURec(User,OneLinerListPtr^.UserID);
                    If (OneLinerListPtr^.Anonymous) Then
                      OneLinerListMCI := 'anon';
                    If (OneLinerListPtr^.Anonymous) And (SysOp) Then
                      OneLinerListMCI := ToLower(User.Name) + ' ^4(^5a^4)';
                    If (Not OneLinerListPtr^.Anonymous) Then
                      OneLinerListMCI := ToLower(User.Name);
                  End;
            'S' :
                  Begin { User Name Short }
                    LoadURec(User,OneLinerListPtr^.UserID);
                    If (OneLinerListPtr^.Anonymous) Then
                      OneLinerListMCI := 'Anon';
                    If (OneLinerListPtr^.Anonymous) And (SysOp) Then
                      OneLinerListMCI := Copy(User.Name,1,2) + ' ^4(^5A^4)';
                    If (Not OneLinerListPtr^.Anonymous) Then
                      OneLinerListMCI := Copy(User.Name,1,2);
                  End;
            'U' :
                  Begin { User Name Short Lower }
                    LoadURec(User,OneLinerListPtr^.UserID);
                    If (OneLinerListPtr^.Anonymous) Then
                      OneLinerListMCI := 'anon';
                    If (OneLinerListPtr^.Anonymous) And (SysOp) Then
                      OneLinerListMCI := ToLower(Copy(User.Name,1,2)) +
                                         ' ^4(^5a^4)';
                    If (Not OneLinerListPtr^.Anonymous) Then
                      OneLinerListMCI := ToLower(Copy(User.Name,1,2));
                  End;
          End;
  End;
End;

Function OneLinerList_Exists: Boolean;

Var 
  OneLinerListFile: FILE Of OneLinerRecordType;
  FSize: Longint;
  FExist: Boolean;
Begin
  FSize := 0;
  FExist := FileExists(General.DataPath+'ONELINER.DAT');
  If (FExist) Then
    Begin
      Assign(OneLinerListFile,General.DataPath+'ONELINER.DAT');
      Reset(OneLinerListFile);
      FSize := FileSize(OneLinerListFile);
      Close(OneLinerListFile);
    End;
  If (Not FExist) Or (FSize = 0) Then
    Begin
      NL;
      PrintF('ONELH');
      If (NoFile) Then
        Begin
          CLS;
          NL;
          Print(Centre('^4' + General.BBSName + ' One Liners'));
          Print(Centre(
'^5������������������������������������������������������������������������������'
          ));
        End;
      Print(' ^4There are currently no One Liners.');
      NL;
      PrintF('ONELE');
      If (NoFile) Then
        Print(Centre(
'^5������������������������������������������������������������������������������'
        ));

      SysOpLog('^5* The ONELINER.DAT file is missing.');
    End;
  OneLinerList_Exists := (FExist) And (FSize <> 0);
End;

Procedure DisplayError(FName: ASTR; Var FExists: Boolean);
Begin
  NL;
  PrintACR('|12� |09The '+FName+'.*  File is missing.');
  PrintACR('|12� |09Please, inform the Sysop!');
  SysOpLog('The '+FName+'.* file is missing.');
  FExists := FALSE;
End;

Function OneLinerAddScreens_Exists: Boolean;

Var 
  FExistsH,
  FExistsM,
  FExistsE: Boolean;
Begin
  FExistsH := TRUE;
  FExistsM := TRUE;
  FExistsE := TRUE;
  (*IF (NOT ReadBuffer('ONELH')) THEN
    DisplayError('ONELH',FExistsH); *)
  If (Not ReadBuffer('ONELM')) Then
    DisplayError('ONELM',FExistsM);
  (*IF (NOT ReadBuffer('ONELE')) THEN
    DisplayError('ONELE',FExistsE); *)
  OneLinerAddScreens_Exists := (*(FExistsH) AND *)(FExistsM) (*AND (FExistsE)*);
End;

Procedure AskOneLinerQuestions(Var OneLinerList: OneLinerRecordType);
{Var MHeader : MHeaderRec; }
Begin

  While (Not Abort) And (Not Hangup) Do
    Begin
      NL;
      Print('^4 Enter your one liner');
      Prt(' ^5:');
      MPL(76);
      InputMain(OneLinerList.OneLiner,(SizeOf(OneLinerList.OneLiner) - 1),[
      InterActiveEdit,ColorsAllowed]);
      NL;
      Abort := (OneLinerList.OneLiner = '');
      If (Abort) Then
        Exit
      Else
        OneLinerList.Anonymous := PYNQ('^4 Post Anonymous? ^5',0,FALSE);
      Exit;
    End;
End;

Procedure OneLiner_Add;

Var 
  Data2: Pointer;
  OneLinerList: OneLinerRecordType;
Begin
  If (OneLinerAddScreens_Exists) Then
    Begin
      NL;
      OneLiner_View;
      If PYNQ('^4 Add a one liner? ^5',0, FALSE) Then
        Begin
          FillChar(OneLinerList,SizeOf(OneLinerList),0);
          AskOneLinerQuestions(OneLinerList);
          If (Not Abort) Then
            Begin
              PrintF('ONELH');
              If (NoFile) Then
                Begin
                  CLS;
                  NL;
                  Print(Centre('^4' + General.BBSName + ' One Liners'));
                  Print(Centre(
'^5������������������������������������������������������������������������������'
                  ));
                End;
              Print(' ^4'+OneLinerList.OneLiner);
              PrintF('ONELE');
              If (NoFile) Then
                Print(Centre(
'^5������������������������������������������������������������������������������'
                ));
              NL;
              If (PYNQ('^4 Add this oneliner? ^5',0,TRUE)) Then
                Begin
                  Assign(OneLinerListFile,General.DataPath+'ONELINER.DAT');
                  If (Exist(General.DataPath+'ONELINER.DAT')) Then
                    Reset(OneLinerListFile)
                  Else
                    Rewrite(OneLinerListFile);
                  Seek(OneLinerListFile,FileSize(OneLinerListFile));
                  OneLinerList.UserID := UserNum;
                  OneLinerList.DateAdded := GetPackDateTime;
                  OneLinerList.DateEdited := OneLinerList.DateAdded;
                  OneLinerList.RecordNum := (FileSize(OneLinerListFile) + 1);
                  Write(OneLinerListFile,OneLinerList);
                  Close(OneLinerListFile);
                  LastError := IOResult;

                  SysOpLog('Added Oneliner : '+OneLinerList.OneLiner+'.');
                End;
            End;
        End;
    End;
End;

Procedure OneLiner_View;

Var 
  Data2: Pointer;
  OneLinerList: OneLinerRecordType;
  OnRec: Longint;
  Cnt : Byte;
Begin

  If (OneLinerList_Exists) And (OneLinerAddScreens_Exists) Then
    Begin
      Assign(OneLinerListFile,General.DataPath+'ONELINER.DAT');
      Reset(OneLinerListFile);
      ReadBuffer('ONELM');
      AllowContinue := TRUE;
      Abort := FALSE;
      PrintF('ONELH');
      If (NoFile) Then
        Begin
          CLS;
          NL;
          Print(Centre('^4' + General.BBSName + ' One Liners'));
          Print(Centre(
'^5������������������������������������������������������������������������������'
          ));
          NL;
        End;
      OnRec := 1;
      Cnt := (FileSize(OneLinerListFile));

{WHILE (OnRec <= FileSize(OneLinerListFile)) AND (NOT Abort) AND (NOT HangUp) DO}

      For Cnt := (FileSize(OneLinerListFile)) Downto 1 Do
        Begin
          Seek(OneLinerListFile,(Cnt-1));
          Read(OneLinerListFile,OneLinerList);
          DisplayBuffer(OneLinerListMCI,@OneLinerList,Data2);
          Inc(OnRec);
          If ((OnRec-1) = 10) Then
            Break
          Else
            OnRec := OnRec;
        End;
      Close(OneLinerListFile);
      LastError := IOResult;
      If (Not Abort) Then
        PrintF('ONELE');
      If (NoFile) Then
        Print(Centre(
'^5������������������������������������������������������������������������������'
        ));

      AllowContinue := FALSE;
      SysOpLog('^5* ^4'+ ThisUser.Name + '^5 Viewed the OneLiners.');
    End;
End;

Function OneLiner_Random : String;
Begin

End;

Procedure DoOneLiners; { To-Do : Variable Number of One Liners To Display }
Begin
  OneLiner_Add;
End;

End.
