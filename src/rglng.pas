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

Program RGLNG;

Uses 
Crt,
Dos;

Type 
  StrPointerRec = Record
    Pointer,
    TextSize: LongInt;
  End;

Var 
  RGStrFile: FILE;
  StrPointerFile: FILE Of StrPointerRec;
  StrPointer: StrPointerRec;
  F: Text;
  S: STRING;
  RGStrNum: LongInt;
  Done,
  Found: Boolean;

Function AllCaps(S: String): STRING;

Var 
  I: Integer;
Begin
  For I := 1 To Length(S) Do
    If (S[I] In ['a'..'z']) Then
      S[I] := Chr(Ord(S[I]) - Ord('a')+Ord('A'));
  AllCaps := S;
End;

Function SQOutSp(S: String): STRING;
Begin
  While (Pos(' ',S) > 0) Do
    Delete(s,Pos(' ',S),1);
  SQOutSp := S;
End;

Function Exist(FN: String): Boolean;

Var 
  DirInfo: SearchRec;
Begin
  FindFirst(SQOutSp(FN),AnyFile,DirInfo);
  Exist := (DOSError = 0);
End;

Procedure CompileLanguageStrings;
Begin
  WriteLn;
  Write('Compiling language strings ... ');
  Found := TRUE;
  Assign(StrPointerFile,'RGLNGPR.DAT');
  ReWrite(StrPointerFile);
  Assign(RGStrFile,'RGLNGTX.DAT');
  ReWrite(RGStrFile,1);
  Assign(F,'RGLNG.TXT');
  Reset(F);
  While Not EOF(F) And (Found) Do
    Begin
      ReadLn(F,S);
      If (S <> '') And (S[1] = '$') Then
        Begin
          Delete(S,1,1);
          S := AllCaps(S);
          RGStrNum := -1;
          If (S = 'ANONYMOUS_STRING') Then
            RGStrNum := 0
          Else If (S = 'ECHO_CHAR_FOR_PASSWORDS') Then
                 RGStrNum := 1
          Else If (S = 'ENGAGE_CHAT') Then
                 RGStrNum := 2
          Else If (S = 'END_CHAT') Then
                 RGStrNum := 3
          Else If (S = 'SYSOP_WORKING') Then
                 RGStrNum := 4
          Else If (S = 'PAUSE') Then
                 RGStrNum := 5
          Else If (S = 'ENTER_MESSAGE_LINE_ONE') Then
                 RGStrNum := 6
          Else If (S = 'ENTER_MESSAGE_LINE_TWO') Then
                 RGStrNum := 7
          Else If (S = 'NEWSCAN_BEGIN') Then
                 RGStrNum := 8
          Else If (S = 'NEWSCAN_DONE') Then
                 RGStrNum := 9
          Else If (S = 'AUTO_MESSAGE_TITLE') Then
                 RGStrNum := 10
          Else If (S = 'AUTO_MESSAGE_BORDER_CHARACTERS') Then
                 RGStrNum := 11
          Else If (S = 'SYSOP_SHELLING_TO_DOS') Then
                 RGStrNum := 12
          Else If (S = 'READ_MAIL') Then
                 RGStrNum := 13
          Else If (S = 'PAGING_SYSOP') Then
                 RGStrNum := 14
          Else If (S = 'CHAT_CALL') Then
                 RGStrNum := 15
          Else If (S = 'BULLETIN_PROMPT') Then
                 RGstrNum := 16
          Else If (S = 'PROTOCOL_PROMPT') Then
                 RGStrNum := 17
          Else If (S = 'LIST_FILES') Then
                 RGStrNum := 18
          Else If (S = 'SEARCH_FOR_NEW_FILES') Then
                 RGStrNum := 19
          Else If (S = 'SEARCH_ALL_DIRS_FOR_FILE_MASK') Then
                 RGStrNum := 20
          Else If (S = 'SEARCH_FOR_DESCRIPTIONS') Then
                 RGStrNum := 21
          Else If (S = 'ENTER_THE_STRING_TO_SEARCH_FOR') Then
                 RGStrNum := 22
          Else If (S = 'DOWNLOAD') Then
                 RGStrNum := 23
          Else If (S = 'UPLOAD') Then
                 RGStrNum := 24
          Else If (S = 'VIEW_INTERIOR_FILES') Then
                 RGStrNum := 25
          Else If (S = 'INSUFFICIENT_FILE_CREDITS') Then
                 RGStrNum := 26
          Else If (S = 'RATIO_IS_UNBALANCED') Then
                 RGStrNum := 27
          Else If (S = 'ALL_FILES') Then
                 RGStrNum := 28
          Else If (S = 'FILE_MASK') Then
                 RGStrNum := 29
          Else If (S = 'FILE_ADDED_TO_BATCH_QUEUE') Then
                 RGStrNum := 30
          Else If (S = 'BATCH_DOWNLOAD_FLAGGING') Then
                 RGStrNum := 31
          Else If (S = 'READ_QUESTION_PROMPT') Then
                 RGStrNum := 32
          Else If (S = 'SYSTEM_PASSWORD_PROMPT') Then
                 RGStrNum := 33
          Else If (S = 'DEFAULT_MESSAGE_TO') Then
                 RGStrNum := 34
          Else If (S = 'NEWSCAN_ALL') Then
                 RGStrNum := 35
          Else If (S = 'NEWSCAN_DONE') Then
                 RGStrNum := 36
          Else If (S = 'CHAT_REASON') Then
                 RGStrNum := 37
          Else If (S = 'USER_DEFINED_QUESTION_ONE') Then
                 RGStrNum := 38
          Else If (S = 'USER_DEFINED_QUESTION_TWO') Then
                 RGStrNum := 39
          Else If (S = 'USER_DEFINED_QUESTION_THREE') Then
                 RGStrNum := 40
          Else If (S = 'USER_DEFINED_QUESTION_EDITOR_ONE') Then
                 RGStrNum := 41
          Else If (S = 'USER_DEFINED_QUESTION_EDITOR_TWO') Then
                 RGStrNum := 42
          Else If (S = 'USER_DEFINED_QUESTION_EDITOR_THREE') Then
                 RGStrNum := 43
          Else If (S = 'CONTINUE_PROMPT') Then
                 RGStrNum := 44
          Else If (S = 'INVISIBLE_LOGIN') Then
                 RGStrNum := 45
          Else If (S = 'CANT_EMAIL') Then
                 RGStrNum := 46
          Else If (S = 'SEND_EMAIL') Then
                 RGStrNum := 47
          Else If (S = 'SENDING_MASS_MAIL_TO') Then
                 RGStrNum := 48
          Else If (S = 'SENDING_MASS_MAIL_TO_ALL_USERS') Then
                 RGStrNum := 49
          Else If (S = 'NO_NETMAIL') Then
                 RGStrNum := 50
          Else If (S = 'NETMAIL_PROMPT') Then
                 RGStrNum := 51
          Else If (S = 'NO_MAIL_WAITING') Then
                 RGStrNum := 52
          Else If (S = 'MUST_READ_MESSAGE') Then
                 RGStrNum := 53
          Else If (S = 'SCAN_FOR_NEW_FILES') Then
                 RGStrNum := 54
          Else If (S = 'NEW_SCAN_CHAR_FILE') Then
                 RGStrNum := 55
          Else If (S = 'BULLETINS_PROMPT') Then
                 RGStrNum := 56
          Else If (S = 'QUICK_LOGON') Then
                 RGStrNum := 57
          Else If (S = 'MESSAGE_AREA_SELECT_HEADER') Then
                 RGStrNum := 58
          Else If (S = 'FILE_AREA_SELECT_HEADER') Then
                 RGStrNum := 59
          Else If (S = 'RECEIVE_EMAIL_HEADER') Then
                 RGStrNum := 60
          Else If (S = 'VOTE_LIST_TOPICS_HEADER') Then
                 RGStrNum := 61
          Else If (S = 'VOTE_TOPIC_RESULT_HEADER') Then
                 RGStrNum := 62
          Else If (S = 'FILE_AREA_NAME_HEADER_NO_RATIO') Then
                 RGStrNum := 63
          Else If (S = 'FILE_AREA_NAME_HEADER_RATIO') Then
                 RGStrNum := 64
          Else If (S = 'SYSOP_CHAT_HELP') Then
                 RGStrNum := 65
          Else If (S = 'NEW_SCAN_CHAR_MESSAGE') Then
                 RGStrNum := 66
          Else If (S = 'FILE_AREA_SELECT_NO_FILES') Then
                 RGStrNum := 67
          Else If (S = 'MESSAGE_AREA_SELECT_NO_FILES') Then
                 RGStrNum := 68
          Else If (S = 'MESSAGE_AREA_LIST_PROMPT') Then
                 RGStrNum := 69
          Else If (S = 'FILE_AREA_LIST_PROMPT') Then
                 RGStrNum := 70
          Else If (S = 'FILE_MESSAGE_AREA_LIST_HELP') Then
                 RGStrNum := 71
          Else If (S = 'FILE_AREA_CHANGE_PROMPT') Then
                 RGStrNum := 72
          Else If (S = 'MESSAGE_AREA_CHANGE_PROMPT') Then
                 RGStrNum := 73
          Else If (S = 'FILE_AREA_NEW_SCAN_TOGGLE_PROMPT') Then
                 RGStrNum := 74
          Else If (S = 'MESSAGE_AREA_NEW_SCAN_TOGGLE_PROMPT') Then
                 RGStrNum := 75
          Else If (S = 'FILE_AREA_MOVE_FILE_PROMPT') Then
                 RGStrNum := 76
          Else If (S = 'MESSAGE_AREA_MOVE_MESSAGE_PROMPT') Then
                 RGStrNum := 77
          Else If (S = 'FILE_AREA_CHANGE_MIN_MAX_ERROR') Then
                 RGStrNum := 78
          Else If (S = 'MESSAGE_AREA_CHANGE_MIN_MAX_ERROR') Then
                 RGStrNum := 79
          Else If (S = 'FILE_AREA_CHANGE_NO_AREA_ACCESS') Then
                 RGStrNum := 80
          Else If (S = 'MESSAGE_AREA_CHANGE_NO_AREA_ACCESS') Then
                 RGStrNum := 81
          Else If (S = 'FILE_AREA_CHANGE_LOWEST_AREA') Then
                 RGStrNum := 82
          Else If (S = 'FILE_AREA_CHANGE_HIGHEST_AREA') Then
                 RGStrNum := 83
          Else If (S = 'MESSAGE_AREA_CHANGE_LOWEST_AREA') Then
                 RGStrNum := 84
          Else If (S = 'MESSAGE_AREA_CHANGE_HIGHEST_AREA') Then
                 RGStrNum := 85
          Else If (S = 'FILE_AREA_NEW_SCAN_SCANNING_ALL_AREAS') Then
                 RGStrNum := 86
          Else If (S = 'MESSAGE_AREA_NEW_SCAN_SCANNING_ALL_AREAS') Then
                 RGStrNum := 87
          Else If (S = 'FILE_AREA_NEW_SCAN_NOT_SCANNING_ALL_AREAS') Then
                 RGStrNum := 88
          Else If (S = 'MESSAGE_AREA_NEW_SCAN_NOT_SCANNING_ALL_AREAS') Then
                 RGStrNum := 89
          Else If (S = 'FILE_AREA_NEW_SCAN_MIN_MAX_ERROR') Then
                 RGStrNum := 90
          Else If (S = 'MESSAGE_AREA_NEW_SCAN_MIN_MAX_ERROR') Then
                 RGStrNum := 91
          Else If (S = 'FILE_AREA_NEW_SCAN_AREA_ON_OFF') Then
                 RGStrNum := 92
          Else If (S = 'MESSAGE_AREA_NEW_SCAN_AREA_ON_OFF') Then
                 RGStrNum := 93
          Else If (S = 'MESSAGE_AREA_NEW_SCAN_AREA_NOT_REMOVED') Then
                 RGStrNum := 94;

          If (RGStrNum = -1) Then
            Begin
              WriteLn('Error!');
              WriteLn;
              WriteLn(^G^G^G'The following string definition is invalid:');
              WriteLn;
              WriteLn('   '+S);
              Found := FALSE;
            End
          Else
            Begin
              Done := FALSE;
              With StrPointer Do
                Begin
                  Pointer := (FileSize(RGStrFile) + 1);
                  TextSize := 0;
                End;
              Seek(RGStrFile,FileSize(RGStrFile));
              While Not EOF(F) And (Not Done) Do
                Begin
                  ReadLn(F,S);
                  If (S[1] = '$') Then
                    Done := TRUE
                  Else
                    Begin
                      Inc(StrPointer.TextSize,(Length(S) + 1));
                      BlockWrite(RGStrFile,S,(Length(S) + 1));
                    End;
                End;
              Seek(StrPointerFile,RGStrNum);
              Write(StrPointerFile,StrPointer);
            End;
        End;
    End;
  Close(F);
  Close(RGStrFile);
  Close(StrPointerFile);
  If (Found) Then
    WriteLn('Done!')
  Else
    Begin
      Erase(StrPointerFile);
      Erase(RGStrFile);
    End;
End;

Procedure CompileMainStrings;
Begin
  WriteLn;
  Write('Compiling main strings ... ');
  Found := TRUE;
  Assign(StrPointerFile,'RGMAINPR.DAT');
  ReWrite(StrPointerFile);
  Assign(RGStrFile,'RGMAINTX.DAT');
  ReWrite(RGStrFile,1);
  Assign(F,'RGMAIN.TXT');
  Reset(F);
  While Not EOF(F) And (Found) Do
    Begin
      ReadLn(F,S);
      If (S <> '') And (S[1] = '$') Then
        Begin
          Delete(S,1,1);
          S := AllCaps(S);
          RGStrNum := -1;
          If (S = 'BAUD_OVERRIDE_PW') Then
            RGStrNum := 0
          Else If (S = 'CALLER_LOGON') Then
                 RGStrNum := 1
          Else If (S = 'LOGON_AS_NEW') Then
                 RGStrNum := 2
          Else If (S = 'USER_LOGON_PASSWORD') Then
                 RGStrNum := 3
          Else If (S = 'USER_LOGON_PHONE_NUMBER') Then
                 RGStrNum := 4
          Else If (S = 'SYSOP_LOGON_PASSWORD') Then
                 RGStrNum := 5
          Else If (S = 'FORGOT_PW_QUESTION') Then
                 RGStrNum := 6
          Else If (S = 'VERIFY_BIRTH_DATE') Then
                 RGStrNum := 7
          Else If (S = 'LOGON_WITHDRAW_BANK') Then
                 RGStrNum := 8
          Else If (S = 'SHUTTLE_LOGON') Then
                 RGStrNum := 9
          Else If (S = 'NEW_USER_PASSWORD') Then
                 RGStrNum := 10;
          If (RGStrNum = -1) Then
            Begin
              WriteLn('Error!');
              WriteLn;
              WriteLn(^G^G^G'The following string definition is invalid:');
              WriteLn;
              WriteLn('   '+S);
              Found := FALSE;
            End
          Else
            Begin
              Done := FALSE;
              With StrPointer Do
                Begin
                  Pointer := (FileSize(RGStrFile) + 1);
                  TextSize := 0;
                End;
              Seek(RGStrFile,FileSize(RGStrFile));
              While Not EOF(F) And (Not Done) Do
                Begin
                  ReadLn(F,S);
                  If (S[1] = '$') Then
                    Done := TRUE
                  Else
                    Begin
                      Inc(StrPointer.TextSize,(Length(S) + 1));
                      BlockWrite(RGStrFile,S,(Length(S) + 1));
                    End;
                End;
              Seek(StrPointerFile,RGStrNum);
              Write(StrPointerFile,StrPointer);
            End;
        End;
    End;
  Close(F);
  Close(RGStrFile);
  Close(StrPointerFile);
  If (Found) Then
    WriteLn('Done!')
  Else
    Begin
      Erase(StrPointerFile);
      Erase(RGStrFile);
    End;
End;

Procedure CompileNoteStrings;
Begin
  WriteLn;
  Write('Compiling Note strings ... ');
  Found := TRUE;
  Assign(StrPointerFile,'RGNOTEPR.DAT');
  ReWrite(StrPointerFile);
  Assign(RGStrFile,'RGNOTETX.DAT');
  ReWrite(RGStrFile,1);
  Assign(F,'RGNOTE.TXT');
  Reset(F);
  While Not EOF(F) And (Found) Do
    Begin
      ReadLn(F,S);
      If (S <> '') And (S[1] = '$') Then
        Begin
          Delete(S,1,1);
          S := AllCaps(S);
          RGStrNum := -1;
          If (S = 'INTERNAL_USE_ONLY') Then
            RGStrNum := 0
          Else If (S = 'ONLY_CHANGE_LOCALLY') Then
                 RGStrNum := 1
          Else If (S = 'INVALID_MENU_NUMBER') Then
                 RGStrNum := 2
          Else If (S = 'MINIMUM_BAUD_LOGON_PW') Then
                 RGStrNum := 3
          Else If (S = 'MINIMUM_BAUD_LOGON_HIGH_LOW_TIME_PW') Then
                 RGStrNum := 4
          Else If (S = 'MINIMUM_BAUD_LOGON_HIGH_LOW_TIME_NO_PW') Then
                 RGStrNum := 5
          Else If (S = 'LOGON_EVENT_RESTRICTED_1') Then
                 RGStrNum := 6
          Else If (S = 'LOGON_EVENT_RESTRICTED_2') Then
                 RGStrNum := 7
          Else If (S = 'NAME_NOT_FOUND') Then
                 RGStrNum := 8
          Else If (S = 'ILLEGAL_LOGON') Then
                 RGStrNum := 9
          Else If (S = 'LOGON_NODE_ACS') Then
                 RGStrNum := 10
          Else If (S = 'LOCKED_OUT') Then
                 RGStrNum := 11
          Else If (S = 'LOGGED_ON_ANOTHER_NODE') Then
                 RGStrNum := 12
          Else If (S = 'INCORRECT_BIRTH_DATE') Then
                 RGStrNum := 13
          Else If (S = 'INSUFFICIENT_LOGON_CREDITS') Then
                 RGStrNum := 14
          Else If (S = 'LOGON_ONCE_PER_DAY') Then
                 RGStrNum := 15
          Else If (S = 'LOGON_CALLS_ALLOWED_PER_DAY') Then
                 RGStrNum := 16
          Else If (S = 'LOGON_TIME_ALLOWED_PER_DAY_OR_CALL') Then
                 RGStrNum := 17
          Else If (S = 'LOGON_MINUTES_LEFT_IN_BANK') Then
                 RGStrNum := 18
          Else If (S = 'LOGON_MINUTES_LEFT_IN_BANK_TIME_LEFT') Then
                 RGStrNum := 19
          Else If (S = 'LOGON_BANK_HANGUP') Then
                 RGStrNum := 20
          Else If (S = 'LOGON_ATTEMPT_IEMSI_NEGOTIATION') Then
                 RGStrNum := 21
          Else If (S = 'LOGON_IEMSI_NEGOTIATION_SUCCESS') Then
                 RGStrNum := 22
          Else If (S = 'LOGON_IEMSI_NEGOTIATION_FAILED') Then
                 RGStrNum := 23
          Else If (S = 'LOGON_ATTEMPT_DETECT_EMULATION') Then
                 RGStrNum := 24
          Else If (S = 'LOGON_RIP_DETECTED') Then
                 RGStrNum := 25
          Else If (S = 'LOGON_ANSI_DETECT_OTHER') Then
                 RGStrNum := 26
          Else If (S = 'LOGON_ANSI_DETECT') Then
                 RGStrNum := 27
          Else If (S = 'LOGON_AVATAR_DETECT_OTHER') Then
                 RGStrNum := 28
          Else If (S = 'LOGON_AVATAR_DETECT') Then
                 RGStrNum := 29
          Else If (S = 'LOGON_EMULATION_DETECTED') Then
                 RGStrNum := 30
          Else If (S = 'SHUTTLE_LOGON_VALIDATION_STATUS') Then
                 RGStrNum := 31
          Else If (S = 'LOGON_CLOSED_BBS') Then
                 RGStrNum := 32
          Else If (S = 'NODE_ACTIVITY_WAITING_ONE') Then
                 RGStrNum := 33
          Else If (S = 'NODE_ACTIVITY_WAITING_TWO') Then
                 RGStrNum := 34
          Else If (S = 'NODE_ACTIVITY_LOGGING_ON') Then
                 RGStrNum := 35
          Else If (S = 'NODE_ACTIVITY_NEW_USER_LOGGING_ON') Then
                 RGStrNum := 36
          Else If (S = 'NODE_ACTIVITY_MISCELLANEOUS') Then
                 RGStrNum := 37
          Else If (S = 'NEW_USER_PASSWORD_INVALID') Then
                 RGStrNum := 38
          Else If (S = 'NEW_USER_PASSWORD_ATTEMPT_EXCEEDED') Then
                 RGStrNum := 39
          Else If (S = 'NEW_USER_RECORD_SAVING') Then
                 RGStrNum := 40
          Else If (S = 'NEW_USER_RECORD_SAVED') Then
                 RGStrNum := 41
          Else If (S = 'NEW_USER_APPLICATION_LETTER') Then
                 RGStrNum := 42
          Else If (S = 'NEW_USER_IN_RESPONSE_TO_SUBJ') Then
                 RGStrNum := 43;
          If (RGStrNum = -1) Then
            Begin
              WriteLn('Error!');
              WriteLn;
              WriteLn(^G^G^G'The following string definition is invalid:');
              WriteLn;
              WriteLn('   '+S);
              Found := FALSE;
            End
          Else
            Begin
              Done := FALSE;
              With StrPointer Do
                Begin
                  Pointer := (FileSize(RGStrFile) + 1);
                  TextSize := 0;
                End;
              Seek(RGStrFile,FileSize(RGStrFile));
              While Not EOF(F) And (Not Done) Do
                Begin
                  ReadLn(F,S);
                  If (S[1] = '$') Then
                    Done := TRUE
                  Else
                    Begin
                      Inc(StrPointer.TextSize,(Length(S) + 1));
                      BlockWrite(RGStrFile,S,(Length(S) + 1));
                    End;
                End;
              Seek(StrPointerFile,RGStrNum);
              Write(StrPointerFile,StrPointer);
            End;
        End;
    End;
  Close(F);
  Close(RGStrFile);
  Close(StrPointerFile);
  If (Found) Then
    WriteLn('Done!')
  Else
    Begin
      Erase(StrPointerFile);
      Erase(RGStrFile);
    End;
End;

Procedure CompileSysOpStrings;
Begin
  WriteLn;
  Write('Compiling sysop strings ... ');
  Found := TRUE;
  Assign(StrPointerFile,'RGSCFGPR.DAT');
  ReWrite(StrPointerFile);
  Assign(RGStrFile,'RGSCFGTX.DAT');
  ReWrite(RGStrFile,1);
  Assign(F,'RGSCFG.TXT');
  Reset(F);
  While Not EOF(F) And (Found) Do
    Begin
      ReadLn(F,S);
      If (S <> '') And (S[1] = '$') Then
        Begin
          Delete(S,1,1);
          S := AllCaps(S);
          RGStrNum := -1;
          If (S = 'SYSTEM_CONFIGURATION_MENU') Then
            RGStrNum := 0
          Else If (S = 'MAIN_BBS_CONFIGURATION') Then
                 RGStrNum := 1
          Else If (S = 'MAIN_BBS_CONFIGURATION_BBS_NAME') Then
                 RGStrNum := 2
          Else If (S = 'MAIN_BBS_CONFIGURATION_BBS_PHONE') Then
                 RGStrNum := 3
          Else If (S = 'MAIN_BBS_CONFIGURATION_TELNET_URL') Then
                 RGStrNum := 4
          Else If (S = 'MAIN_BBS_CONFIGURATION_SYSOP_NAME') Then
                 RGStrNum := 5
          Else If (S = 'MAIN_BBS_CONFIGURATION_SYSOP_CHAT_HOURS') Then
                 RGStrNum := 6
          Else If (S = 'MAIN_BBS_CONFIGURATION_MINIMUM_BAUD_HOURS') Then
                 RGStrNum := 7
          Else If (S = 'MAIN_BBS_CONFIGURATION_DOWNLOAD_HOURS') Then
                 RGStrNum := 8
          Else If (S = 'MAIN_BBS_CONFIGURATION_MINIMUM_BAUD_DOWNLOAD_HOURS')
                 Then
                 RGStrNum := 9
          Else If (S = 'MAIN_BBS_CONFIGURATION_SYSOP_PASSWORD_MENU') Then
                 RGStrNum := 10
          Else If (S = 'MAIN_BBS_CONFIGURATION_SYSOP_PASSWORD') Then
                 RGStrNum := 11
          Else If (S = 'MAIN_BBS_CONFIGURATION_NEW_USER_PASSWORD') Then
                 RGStrNum := 12
          Else If (S = 'MAIN_BBS_CONFIGURATION_BAUD_OVERRIDE_PASSWORD') Then
                 RGStrNum := 13
          Else If (S = 'MAIN_BBS_CONFIGURATION_PRE_EVENT_TIME') Then
                 RGStrNum := 14
          Else If (S = 'MAIN_BBS_CONFIGURATION_SYSTEM_MENUS') Then
                 RGStrNum := 15
          Else If (S = 'MAIN_BBS_CONFIGURATION_SYSTEM_MENUS_GLOBAL') Then
                 RGStrNum := 16
          Else If (S = 'MAIN_BBS_CONFIGURATION_SYSTEM_MENUS_START') Then
                 RGStrNum := 17
          Else If (S = 'MAIN_BBS_CONFIGURATION_SYSTEM_MENUS_SHUTTLE') Then
                 RGStrNum := 18
          Else If (S = 'MAIN_BBS_CONFIGURATION_SYSTEM_MENUS_NEW_USER') Then
                 RGStrNum := 19
          Else If (S = 'MAIN_BBS_CONFIGURATION_SYSTEM_MENUS_MESSAGE_READ') Then
                 RGStrNum := 20
          Else If (S = 'MAIN_BBS_CONFIGURATION_SYSTEM_MENUS_FILE_LISTING') Then
                 RGStrNum := 21
          Else If (S = 'MAIN_BBS_CONFIGURATION_BULLETIN_PREFIX') Then
                 RGStrNum := 22
          Else If (S = 'MAIN_BBS_CONFIGURATION_LOCAL_SECURITY') Then
                 RGStrNum := 23
          Else If (S = 'MAIN_BBS_CONFIGURATION_DATA_PATH') Then
                 RGStrNum := 24
          Else If (S = 'MAIN_BBS_CONFIGURATION_MISC_PATH') Then
                 RGStrNum := 25
          Else If (S = 'MAIN_BBS_CONFIGURATION_MSG_PATH') Then
                 RGStrNum := 26
          Else If (S = 'MAIN_BBS_CONFIGURATION_NODELIST_PATH') Then
                 RGStrNum := 27
          Else If (S = 'MAIN_BBS_CONFIGURATION_LOG_PATH') Then
                 RGStrNum := 28
          Else If (S = 'MAIN_BBS_CONFIGURATION_TEMP_PATH') Then
                 RGStrNum := 29
          Else If (S = 'MAIN_BBS_CONFIGURATION_PROTOCOL_PATH') Then
                 RGStrNum := 30
          Else If (S = 'MAIN_BBS_CONFIGURATION_ARCHIVE_PATH') Then
                 RGStrNum := 31
          Else If (S = 'MAIN_BBS_CONFIGURATION_ATTACH_PATH') Then
                 RGStrNum := 32
          Else If (S = 'MAIN_BBS_CONFIGURATION_STRING_PATH') Then
                 RGStrNum := 33;
          If (RGStrNum = -1) Then
            Begin
              WriteLn('Error!');
              WriteLn;
              WriteLn(^G^G^G'The following string definition is invalid:');
              WriteLn;
              WriteLn('   '+S);
              Found := FALSE;
            End
          Else
            Begin
              Done := FALSE;
              With StrPointer Do
                Begin
                  Pointer := (FileSize(RGStrFile) + 1);
                  TextSize := 0;
                End;
              Seek(RGStrFile,FileSize(RGStrFile));
              While Not EOF(F) And (Not Done) Do
                Begin
                  ReadLn(F,S);
                  If (S[1] = '$') Then
                    Done := TRUE
                  Else
                    Begin
                      Inc(StrPointer.TextSize,(Length(S) + 1));
                      BlockWrite(RGStrFile,S,(Length(S) + 1));
                    End;
                End;
              Seek(StrPointerFile,RGStrNum);
              Write(StrPointerFile,StrPointer);
            End;
        End;
    End;
  Close(F);
  Close(RGStrFile);
  Close(StrPointerFile);
  If (Found) Then
    WriteLn('Done!')
  Else
    Begin
      Erase(StrPointerFile);
      Erase(RGStrFile);
    End;
End;

Procedure CompileFileAreaEditorStrings;
Begin
  WriteLn;
  Write('Compiling file area editor strings ... ');
  Found := TRUE;
  Assign(StrPointerFile,'FAEPR.DAT');
  ReWrite(StrPointerFile);
  Assign(RGStrFile,'FAETX.DAT');
  ReWrite(RGStrFile,1);
  Assign(F,'FAELNG.TXT');
  Reset(F);
  While Not EOF(F) And (Found) Do
    Begin
      ReadLn(F,S);
      If (S <> '') And (S[1] = '$') Then
        Begin
          Delete(S,1,1);
          S := AllCaps(S);
          RGStrNum := -1;
          If (S = 'FILE_AREA_HEADER_TOGGLE_ONE') Then
            RGStrNum := 0
          Else If (S = 'FILE_AREA_HEADER_TOGGLE_TWO') Then
                 RGStrNum := 1
          Else If (S = 'FILE_AREA_HEADER_NO_FILE_AREAS') Then
                 RGStrNum := 2
          Else If (S = 'FILE_AREA_EDITOR_PROMPT') Then
                 RGStrNum := 3
          Else If (S = 'FILE_AREA_EDITOR_HELP') Then
                 RGStrNum := 4
          Else If (S = 'NO_FILE_AREAS') Then
                 RGStrNum := 5
          Else If (S = 'FILE_CHANGE_DRIVE_START') Then
                 RGStrNum := 6
          Else If (S = 'FILE_CHANGE_DRIVE_END') Then
                 RGStrNum := 7
          Else If (S = 'FILE_CHANGE_DRIVE_DRIVE') Then
                 RGStrNum := 8
          Else If (S = 'FILE_CHANGE_INVALID_ORDER') Then
                 RGStrNum := 9
          Else If (S = 'FILE_CHANGE_INVALID_DRIVE') Then
                 RGStrNum := 10
          Else If (S = 'FILE_CHANGE_UPDATING_DRIVE') Then
                 RGStrNum := 11
          Else If (S = 'FILE_CHANGE_UPDATING_DRIVE_DONE') Then
                 RGStrNum := 12
          Else If (S = 'FILE_CHANGE_UPDATING_SYSOPLOG') Then
                 RGStrNum := 13
          Else If (S = 'FILE_DELETE_PROMPT') Then
                 RGStrNum := 14
          Else If (S = 'FILE_DELETE_DISPLAY_AREA') Then
                 RGStrNum := 15
          Else If (S = 'FILE_DELETE_VERIFY_DELETE') Then
                 RGStrNum := 16
          Else If (S = 'FILE_DELETE_NOTICE') Then
                 RGStrNum := 17
          Else If (S = 'FILE_DELETE_SYSOPLOG') Then
                 RGStrNum := 18
          Else If (S = 'FILE_DELETE_DATA_FILES') Then
                 RGStrNum := 19
          Else If (S = 'FILE_DELETE_REMOVE_DL_DIRECTORY') Then
                 RGStrNum := 20
          Else If (S = 'FILE_DELETE_REMOVE_UL_DIRECTORY') Then
                 RGStrNum := 21
          Else If (S = 'FILE_INSERT_MAX_FILE_AREAS') Then
                 RGStrNum := 22
          Else If (S = 'FILE_INSERT_PROMPT') Then
                 RGStrNum := 23
          Else If (S = 'FILE_INSERT_AFTER_ERROR_PROMPT') Then
                 RGStrNum := 24
          Else If (S = 'FILE_INSERT_CONFIRM_INSERT') Then
                 RGStrNum := 25
          Else If (S = 'FILE_INSERT_NOTICE') Then
                 RGStrNum := 26
          Else If (S = 'FILE_INSERT_SYSOPLOG') Then
                 RGStrNum := 27
          Else If (S = 'FILE_MODIFY_PROMPT') Then
                 RGStrNum := 28
          Else If (S = 'FILE_MODIFY_SYSOPLOG') Then
                 RGStrNum := 29
          Else If (S = 'FILE_POSITION_NO_AREAS') Then
                 RGStrNum := 30
          Else If (S = 'FILE_POSITION_PROMPT') Then
                 RGStrNum := 31
          Else If (S = 'FILE_POSITION_NUMBERING') Then
                 RGStrNum := 32
          Else If (S = 'FILE_POSITION_BEFORE_WHICH') Then
                 RGStrNum := 33
          Else If (S = 'FILE_POSITION_NOTICE') Then
                 RGStrNum := 34
          Else If (S = 'FILE_EDITING_AREA_HEADER') Then
                 RGStrNum := 35
          Else If (S = 'FILE_INSERTING_AREA_HEADER') Then
                 RGStrNum := 36
          Else If (S = 'FILE_EDITING_INSERTING_SCREEN') Then
                 RGStrNum := 37
          Else If (S = 'FILE_EDITING_INSERTING_PROMPT') Then
                 RGStrNum := 38
          Else If (S = 'FILE_AREA_NAME_CHANGE') Then
                 RGStrNum := 39
          Else If (S = 'FILE_FILE_NAME_CHANGE') Then
                 RGStrNum := 40
          Else If (S = 'FILE_DUPLICATE_FILE_NAME_ERROR') Then
                 RGStrNum := 41
          Else If (S = 'FILE_USE_DUPLICATE_FILE_NAME') Then
                 RGStrNum := 42
          Else If (S = 'FILE_OLD_DATA_FILES_PATH') Then
                 RGStrNum := 43
          Else If (S = 'FILE_NEW_DATA_FILES_PATH') Then
                 RGStrNum := 44
          Else If (S = 'FILE_RENAME_DATA_FILES') Then
                 RGStrNum := 45
          Else If (S = 'FILE_DL_PATH') Then
                 RGStrNum := 46
          Else If (S = 'FILE_SET_DL_PATH_TO_UL_PATH') Then
                 RGStrNum := 47
          Else If (S = 'FILE_UL_PATH') Then
                 RGStrNum := 48
          Else If (S = 'FILE_ACS') Then
                 RGStrNum := 49
          Else If (S = 'FILE_DL_ACCESS') Then
                 RGStrNum := 50
          Else If (S = 'FILE_UL_ACCESS') Then
                 RGStrNum := 51
          Else If (S = 'FILE_MAX_FILES') Then
                 RGStrNum := 52
          Else If (S = 'FILE_PASSWORD') Then
                 RGStrNum := 53
          Else If (S = 'FILE_ARCHIVE_TYPE') Then
                 RGStrNum := 54
          Else If (S = 'FILE_COMMENT_TYPE') Then
                 RGStrNum := 55
          Else If (S = 'FILE_TOGGLE_FLAGS') Then
                 RGStrNum := 56
          Else If (S = 'FILE_MOVE_DATA_FILES') Then
                 RGStrNum := 57
          Else If (S = 'FILE_TOGGLE_HELP') Then
                 RGStrNum := 58
          Else If (S = 'FILE_JUMP_TO') Then
                 RGStrNum := 59
          Else If (S = 'FILE_FIRST_VALID_RECORD') Then
                 RGStrNum := 60
          Else If (S = 'FILE_LAST_VALID_RECORD') Then
                 RGStrNum := 61
          Else If (S = 'FILE_INSERT_EDIT_HELP') Then
                 RGStrNum := 62
          Else If (S = 'FILE_INSERT_HELP') Then
                 RGStrNum := 63
          Else If (S = 'FILE_EDIT_HELP') Then
                 RGStrNum := 64
          Else If (S = 'CHECK_AREA_NAME_ERROR') Then
                 RGStrNum := 65
          Else If (S = 'CHECK_FILE_NAME_ERROR') Then
                 RGStrNum := 66
          Else If (S = 'CHECK_DL_PATH_ERROR') Then
                 RGStrNum := 67
          Else If (S = 'CHECK_UL_PATH_ERROR') Then
                 RGStrNum := 68
          Else If (S = 'CHECK_ARCHIVE_TYPE_ERROR') Then
                 RGStrNum := 69
          Else If (S = 'CHECK_COMMENT_TYPE_ERROR') Then
                 RGStrNum := 70;
          If (RGStrNum = -1) Then
            Begin
              WriteLn('Error!');
              WriteLn;
              WriteLn('The following string definition is invalid:');
              WriteLn;
              WriteLn('   '+S);
              Found := FALSE;
            End
          Else
            Begin
              Done := FALSE;
              With StrPointer Do
                Begin
                  Pointer := (FileSize(RGStrFile) + 1);
                  TextSize := 0;
                End;
              Seek(RGStrFile,FileSize(RGStrFile));
              While Not EOF(F) And (Not Done) Do
                Begin
                  ReadLn(F,S);
                  If (S[1] = '$') Then
                    Done := TRUE
                  Else
                    Begin
                      Inc(StrPointer.TextSize,(Length(S) + 1));
                      BlockWrite(RGStrFile,S,(Length(S) + 1));
                    End;
                End;
              Seek(StrPointerFile,RGStrNum);
              Write(StrPointerFile,StrPointer);
            End;
        End;
    End;
  Close(F);
  Close(RGStrFile);
  Close(StrPointerFile);
  If (Found) Then
    WriteLn('Done!')
  Else
    Begin
      Erase(StrPointerFile);
      Erase(RGStrFile);
    End;
End;

Begin
  CLrScr;
  WriteLn('Renegade Language String Compiler Version 3.1');
  Writeln('Copyright 2009 - The Renegade Developement Team');
  If (Not Exist('RGLNG.TXT')) Then
    Begin
      WriteLn;
      WriteLn(^G^G^G'RGLNG.TXT does not exist!');
      Exit;
    End;
  If (Not Exist('RGMAIN.TXT')) Then
    Begin
      WriteLn;
      WriteLn(^G^G^G'RGMAIN.TXT does not exists!');
      Exit;
    End;
  If (Not Exist('RGNOTE.TXT')) Then
    Begin
      WriteLn;
      WriteLn(^G^G^G'RGNOTE.TXT does not exists!');
      Exit;
    End;
  If (Not Exist('RGSCFG.TXT')) Then
    Begin
      WriteLn;
      WriteLn(^G^G^G'RGSCFG.TXT does not exists!');
      Exit;
    End;
  If (Not Exist('FAELNG.TXT')) Then
    Begin
      WriteLn;
      WriteLn(^G^G^G'FAELNG.TXT does not exists!');
      Exit;
    End;
  CompileLanguageStrings;
  CompileMainStrings;
  CompileNoteStrings;
  CompileSysOpStrings;
  CompileFileAreaEditorStrings;
End.
