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

Unit MyIO;

Interface

Type 
  AStr = STRING[160];
  WindowRec = ARRAY[0..8000] Of Byte;
  ScreenType = ARRAY [0..3999] Of Byte;
  Infield_Special_Function_Proc_Rec = Procedure (c: Char);
  {$IFDEF LINUX}
  PChar = ^Char;
  SmallWord = System.Word;
  {$ENDIF}

Const 
  Infield_Seperators: SET Of Char = [' ','\','.'];

  Infield_Only_Allow_On: BOOLEAN = FALSE;
  Infield_Arrow_Exit: BOOLEAN = FALSE;
  Infield_Arrow_Exited: BOOLEAN = FALSE;
  Infield_Arrow_Exited_Keep: BOOLEAN = FALSE;
  Infield_Special_Function_On: BOOLEAN = FALSE;
  Infield_Arrow_Exit_TypeDefs: BOOLEAN = FALSE;
  Infield_Normal_Exit_Keydefs: BOOLEAN = FALSE;
  Infield_Normal_Exited: BOOLEAN = FALSE;
  {$IFDEF LINUX}
  MonitorType: Byte = 3;
  // REENOTE 3=CO80, a safe assumption I think
  {ScreenAddr: ScreenType ABSOLUTE $B800:$0000;}
  ScreenAddr: Byte = 3;
   { Video modes }
  MON1          = $FE;          { Monochrome, ASCII chars only }
  MON2          = $FD;          { Monochrome, graphics chars   }
  COL1          = $FC;          { Color, ASCII chars only      }
  COL2          = $FB;          { Color, graphics chars        }
{$ENDIF}

Var 
  Wind: WindowRec;

{$IFDEF WIN32}
  MonitorType: Byte = 3;
  // REENOTE 3=CO80, a safe assumption I think
{$ENDIF}
  ScreenSize: Integer;
  MaxDisplayRows,
  MaxDisplayCols,
  Infield_Out_FGrd,
  Infield_Out_BkGd,
  Infield_Inp_FGrd,
  Infield_Inp_BkGd,
  Infield_Last_Arrow,
  Infield_Last_Normal: Byte;
  Infield_Special_Function_Proc: infield_special_function_proc_rec;
  Infield_Only_Allow,
  Infield_Special_Function_Keys,
  Infield_Arrow_Exit_Types,
  Infield_Normal_Exit_Keys: STRING;

{$IFDEF MSDOS}
Procedure Update_Logo(Data: Array Of Char; OriginX, OriginY, DataLength: integer
);
{$ENDIF}
{$IFNDEF MSDOS}
Procedure Update_Logo(Data: Array Of Char; OriginX, OriginY, DataLength: integer
);
{$ENDIF}
Procedure CursorOn(b: BOOLEAN) Overload;
Procedure infield1(x,y: Byte; Var s: AStr; Len: Byte);
Procedure Infielde(Var s: AStr; Len: Byte);
Procedure Infield(Var s: AStr; Len: Byte);
Function l_yn: BOOLEAN;
Function l_pynq(Const s: AStr): BOOLEAN;
Procedure CWrite(Const s: AStr);
Procedure CWriteAt(x,y: Integer; Const s: AStr);
Function CStringLength(Const s: AStr): Integer;
Procedure cwritecentered(y: Integer; Const s: AStr);
Procedure Box(LineType,TLX,TLY,BRX,BRY: Integer);
Procedure SaveScreen(Var Wind: WindowRec);
Procedure RemoveWindow(Var Wind: WindowRec);
Procedure SetWindow(Var Wind: WindowRec; TLX,TLY,BRX,BRY,TColr,BColr,BoxType:
                    Integer);

Implementation

Uses 
Crt,
RPPort
{$IFDEF WIN32}
,RPScreen
,VpSysLow
{$ENDIF}
  {$IFDEF LINUX}
,Unix
,SysUtils
  {$ENDIF}
;

{$IFNDEF MSDOS}

Var 
  SavedScreen: TConsoleBuf;
{$ENDIF}

{$IFDEF MSDOS}
Procedure CursorOn(b: BOOLEAN);
ASSEMBLER;
ASM
cmp b, 1
je @turnon
mov ch, 9
mov cl, 0
jmp @goforit
@turnon:
         mov ch, 6
         mov cl, 7
         @goforit:
                   mov ah,1
                   int 10h
End;
{$ENDIF}
{$IFNDEF MSDOS}
Procedure CursorOn(b: Boolean);
Begin

  If (b) Then
    Begin
      CursorOff;
    End
  Else
    Begin
      CursorOn;
    End;
End;
{$ENDIF}

Procedure infield1(x,y: Byte; Var s: AStr; Len: Byte);

Var 
  SaveS: AStr;
  c: Char;
  SaveTextAttr,
  SaveX,
  SaveY: Byte;
  i,
  p,
  z: Integer;
  Ins,
  Done,
  NoKeyYet: BOOLEAN;

Procedure gocpos;
Begin
  GoToXY(x + p - 1,y);
End;

Procedure Exit_W_Arrow;

Var 
  i: Integer;
  brk: Boolean = false;
Begin
  Infield_Arrow_Exited := TRUE;
  Infield_Last_Arrow := Ord(c);
  Done := TRUE;
  If (Infield_Arrow_Exited_Keep) Then
    Begin
      z := Len;
      For i := Len Downto 1 Do
        Repeat
          If (s[i] = ' ') Then
            Dec(z)
          Else
        {i := 1;}
            brk := true;
          s[1] := chr(z);
        Until brk = true;
    End
  Else
    s := SaveS;
End;

Procedure Exit_W_Normal;

Var 
  i: Integer;
  brk: Boolean = false;
Begin
  Infield_Normal_Exited := TRUE;
  Infield_Last_Normal := Ord(c);
  Done := TRUE;
  If (Infield_Arrow_Exited_Keep) Then
    Begin
      z := Len;
      Repeat
        For i := Len Downto 1 Do
          If (s[i] = ' ') Then
            Dec(z)
          Else
            brk := true;
        s[1] := chr(z);

      Until brk = true;
    End
  Else
    s := SaveS;
End;

Var 
  brk : Boolean = false;
Begin

  SaveTextAttr := TextAttr;
  SaveX := WhereX;
  SaveY := WhereY;
  SaveS := s;
  Ins := FALSE;
  Done := FALSE;
  Infield_Arrow_Exited := FALSE;
  GoToXY(x,y);
  TextAttr := (Infield_Inp_BkGd * 16) + Infield_Inp_FGrd;
  For i := 1 To Len Do
    Write(' ');
  For i := (Length(s) + 1) To Len Do
    s[i] := ' ';
  GoToXY(x,y);
  Write(s);
  p := 1;
  gocpos;
  NoKeyYet := TRUE;
  Repeat
    Repeat
      c := ReadKey
    Until ((Not Infield_Only_Allow_On) Or
          (Pos(c,Infield_Special_Function_Keys) <> 0) Or
          (Pos(c,Infield_Normal_Exit_Keys) <> 0) Or
          (Pos(c,Infield_Only_Allow) <> 0) Or (c = #0));

    If ((Infield_Normal_Exit_Keydefs) And
       (Pos(c,Infield_Normal_Exit_Keys) <> 0)) Then
      Exit_W_Normal;

    If ((Infield_Special_Function_On) And
       (Pos(c,Infield_Special_Function_Keys) <> 0)) Then
      Infield_Special_Function_Proc(c)
    Else
      Begin
        If (NoKeyYet) Then
          Begin
            NoKeyYet := FALSE;
            If (c In [#32..#255]) Then
              Begin
                GoToXY(x,y);
                For i := 1 To Len Do
                  Begin
                    Write(' ');
                    s[i] := ' ';
                  End;
                GoToXY(x,y);
              End;
          End;
        Case c Of 
          #0 :
               Begin
                 c := ReadKey;
                 If ((Infield_Arrow_Exit) And (Infield_Arrow_Exit_TypeDefs) And
                    (Pos(c,Infield_Arrow_Exit_Types) <> 0)) Then
                   Exit_W_Arrow
                 Else
                   Case c Of 
                     #72,#80 :
                               If (Infield_Arrow_Exit) Then
                                 Exit_W_Arrow;
                     #75 : If (p > 1) Then
                             Dec(p);
                     #77 : If (p < Len + 1) Then
                             Inc(p);
                     #71 : p := 1;
                     #79 :
                           Begin
                             z := 1;
                             For i := Len Downto 2 Do
                               If ((s[i - 1] <> ' ') And (z = 1)) Then
                                 z := i;
                             If (s[z] = ' ') Then
                               p := z
                             Else
                               p := Len + 1;
                           End;
                     #82 : Ins := Not Ins;
                     #83 : If (p <= Len) Then
                             Begin
                               For i := p To (Len - 1) Do
                                 Begin
                                   s[i] := s[i + 1];
                                   Write(s[i]);
                                 End;
                               s[Len] := ' ';
                               Write(' ');
                             End;
                     #115 : If (p > 1) Then
                              Begin
                                i := (p - 1);
                                While ((Not (s[i - 1] In Infield_Seperators)) Or
                                      (s[i] In Infield_Seperators)) And (i > 1) 
                                  Do
                                  Dec(i);
                                p := i;
                              End;
                     #116 : If (p <= Len) Then
                              Begin
                                i := p + 1;
                                While ((Not (s[i-1] In Infield_Seperators)) Or
                                      (s[i] In Infield_Seperators)) And (i <=
                                      Len) Do
                                  Inc(i);
                                p := i;
                              End;
                     #117 : If (p <= Len) Then
                              For i := p To Len Do
                                Begin
                                  s[i] := ' ';
                                  Write(' ');
                                End;
                   End;
                 gocpos;
               End;
          #27 :
                Begin
                  s := SaveS;
                  Done := TRUE;
                End;
          #13 :
                Begin
                  Done := TRUE;
                  z := Len;

                  For i := Len Downto 1 Do
                    Repeat
                      If (s[i] = ' ') Then
                        Dec(z)
                      Else
                        brk := true;
                      s[1] := chr(z);
                    Until brk = true;
                End;
          #8 : If (p <> 1) Then
                 Begin
                   Dec(p);
                   s[p] := ' ';
                   gocpos;
                   Write(' ');
                   gocpos;
                 End;
          Else
            If ((c In [#32..#255]) And (p <= Len)) Then
              Begin
                If ((Ins) And (p <> Len)) Then
                  Begin
                    Write(' ');
                    For i := Len Downto (p + 1) Do
                      s[i] := s[i - 1];
                    For i := (p + 1) To Len Do
                      Write(s[i]);
                    gocpos;
                  End;
                Write(c);
                s[p] := c;
                Inc(p);
              End;
        End;
      End;
  Until (Done);
  GoToXY(x,y);
  TextAttr := (Infield_Out_BkGd * 16) + Infield_Out_FGrd;
  For i := 1 To Len Do
    Write(' ');
  GoToXY(x,y);
  Write(s);
  GoToXY(SaveX,SaveY);
  TextAttr := SaveTextAttr;
  Infield_Only_Allow_On := FALSE;
  Infield_Special_Function_On := FALSE;
  Infield_Normal_Exit_Keydefs := FALSE;
End;

Procedure Infielde(Var s: AStr; Len: Byte);
Begin
  infield1(WhereX,WhereY,s,Len);
End;

Procedure Infield(Var S: AStr; Len: Byte);
Begin
  S := '';
  Infielde(S,Len);
End;

Function l_yn: BOOLEAN;

Var 
  C: Char;
Begin
  Repeat
    C := UpCase(ReadKey)
  Until (C In ['Y','N',#13,#27]);
  If (C = 'Y') Then
    Begin
      l_yn := TRUE;
      WriteLn('Yes');
    End
  Else
    Begin
      l_yn := FALSE;
      WriteLn('No');
    End;
End;

Function l_pynq(Const S: AStr): BOOLEAN;
Begin
  TextColor(4);
  Write(S);
  TextColor(11);
  l_pynq := l_yn;
End;

Procedure CWrite(Const S: AStr);

Var 
  C: Char;
  Counter: Byte;
  LastB,
  LastC: BOOLEAN;
Begin
  LastB := FALSE;
  LastC := FALSE;
  For Counter := 1 To Length(S) Do
    Begin
      C := S[Counter];
      If ((LastB) Or (LastC)) Then
        Begin
          If (LastB) Then
            TextBackGround(Ord(C))
          Else If (LastC) Then
                 TextColor(Ord(C));
          LastB := FALSE;
          LastC := FALSE;
        End
      Else
        Case C Of 
          #2 : LastB := TRUE;
          #3 : LastC := TRUE;
          Else
            Write(C);
        End;
    End;
End;

Procedure CWriteAt(x,y: Integer; Const s: AStr);
Begin
  GoToXY(x,y);
  CWrite(s);
End;

Function CStringLength(Const s: AStr): Integer;

Var 
  Len,
  i: Integer;
Begin
  Len := Length(s);
  i := 1;
  While (i <= Length(s)) Do
    Begin
      If ((s[i] = #2) Or (s[i] = #3)) Then
        Begin
          Dec(Len,2);
          Inc(i);
        End;
      Inc(i);
    End;
  CStringLength := Len;
End;

Procedure cwritecentered(y: Integer; Const s: AStr);
Begin
  CWriteAt(40 - (CStringLength(s) DIV 2),y,s);
End;


{*
 *  ���Ŀ   ���ͻ   �����   �����   �����   �����   ���ķ  ���͸
 *  � 1 �   � 2 �   � 3 �   � 4 �   � 5 �   � 6 �   � 7 �  � 8 �
 *  �����   ���ͼ   �����   �����   �����   �����   ���Ľ  ���;
 *}
Procedure Box(LineType,TLX,TLY,BRX,BRY: Integer);

Var 
  TL,TR,BL,BR,HLine,VLine: Char;
  i: Integer;
Begin
  Window(1,1,MaxDisplayCols,MaxDisplayRows);
  Case LineType Of 
    1 :
        Begin
          TL := #218;
          TR := #191;
          BL := #192;
          BR := #217;
          VLine := #179;
          HLine := #196;
        End;
    2 :
        Begin
          TL := #201;
          TR := #187;
          BL := #200;
          BR := #188;
          VLine := #186;
          HLine := #205;
        End;
    3 :
        Begin
          TL := #176;
          TR := #176;
          BL := #176;
          BR := #176;
          VLine := #176;
          HLine := #176;
        End;
    4 :
        Begin
          TL := #177;
          TR := #177;
          BL := #177;
          BR := #177;
          VLine := #177;
          HLine := #177;
        End;
    5 :
        Begin
          TL := #178;
          TR := #178;
          BL := #178;
          BR := #178;
          VLine := #178;
          HLine := #178;
        End;
    6 :
        Begin
          TL := #219;
          TR := #219;
          BL := #219;
          BR := #219;
          VLine := #219;
          HLine := #219;
        End;
    7 :
        Begin
          TL := #214;
          TR := #183;
          BL := #211;
          BR := #189;
          VLine := #186;
          HLine := #196;
        End;
    8 :
        Begin
          TL := #213;
          TR := #184;
          BL := #212;
          BR := #190;
          VLine := #179;
          HLine := #205;
        End;
    Else
      Begin
        TL := #32;
        TR := #32;
        BL := #32;
        BR := #32;
        VLine := #32;
        HLine := #32;
      End;
  End;
  GoToXY(TLX,TLY);
  Write(TL);
  GoToXY(BRX,TLY);
  Write(TR);
  GoToXY(TLX,BRY);
  Write(BL);
  GoToXY(BRX,BRY);
  Write(BR);
  For i := (TLX + 1) To (BRX - 1) Do
    Begin
      GoToXY(i,TLY);
      Write(HLine);
    End;
  For i := (TLX + 1) To (BRX - 1) Do
    Begin
      GoToXY(i,BRY);
      Write(HLine);
    End;
  For i := (TLY + 1) To (BRY - 1) Do
    Begin
      GoToXY(TLX,i);
      Write(VLine);
    End;
  For i := (TLY + 1) To (BRY - 1) Do
    Begin
      GoToXY(BRX,I);
      Write(VLine);
    End;
  If (LineType > 0) Then
    Window((TLX + 1),(TLY + 1),(BRX - 1),(BRY - 1))
  Else
    Window(TLX,TLY,BRX,BRY);
End;

Procedure SaveScreen(Var Wind: WindowRec);
Begin
{$IFDEF MSDOS}
  Move(ScreenAddr[0],Wind[0],ScreenSize);
{$ENDIF}
{$IFDEF UNIX}
  Move(ScreenAddr, SavedScreen, ScreenSize);
{$ENDIF}
{$IFDEF WIN32}
  RPSaveScreen(SavedScreen);
{$ENDIF}
End;

Procedure RemoveWindow(Var Wind: WindowRec);
Begin
{$IFDEF MSDOS}
  Move(Wind[0],ScreenAddr[0],ScreenSize);
{$ENDIF}
{$IFDEF UNIX}
  Move(SavedScreen, ScreenAddr, ScreenSize);
{$ENDIF}
{$IFDEF WIN32}
  RPRestoreScreen(SavedScreen);
{$ENDIF}
End;

Procedure SetWindow(Var Wind: WindowRec; TLX,TLY,BRX,BRY,TColr,BColr,BoxType:
                    Integer);
Begin
  SaveScreen(Wind);                        { save under Window }
  Window(TLX,TLY,BRX,BRY);                 { SET Window size }
  TextColor(TColr);
  TextBackGround(BColr);
  ClrScr;                                  { clear window for action }
  Box(BoxType,TLX,TLY,BRX,BRY);            { Set the border }
End;

{$IFDEF MSDOS}

Procedure Update_Logo(Var Addr1,Addr2; BlkLen: Integer);
Begin
  INLINE (
          $1E/
          $C5/$B6/ADDR1/
          $C4/$BE/ADDR2/
          $8B/$8E/BLKLEN/
          $E3/$5B/
          $8B/$D7/
          $33/$C0/
          $FC/
          $AC/
          $3C/$20/
          $72/$05/
          $AB/
          $E2/$F8/
          $EB/$4C/
          $3C/$10/
          $73/$07/
          $80/$E4/$F0/
          $0A/$E0/
          $EB/$F1/
          $3C/$18/
          $74/$13/
          $73/$19/
          $2C/$10/
          $02/$C0/
          $02/$C0/
          $02/$C0/
          $02/$C0/
          $80/$E4/$8F/
          $0A/$E0/
          $EB/$DA/
          $81/$C2/$A0/$00/
          $8B/$FA/
          $EB/$D2/
          $3C/$1B/
          $72/$07/
          $75/$CC/
          $80/$F4/$80/
          $EB/$C7/
          $3C/$19/
          $8B/$D9/
          $AC/
          $8A/$C8/
          $B0/$20/
          $74/$02/
          $AC/
          $4B/
          $32/$ED/
          $41/
          $F3/$AB/
          $8B/$CB/
          $49/
          $E0/$AA/
          $1F);
End;
{$ENDIF}
{$IFNDEF MSDOS}
Procedure Update_Logo(Data: Array Of Char; OriginX, OriginY, DataLength: integer
);

Var 
  i, x, y, count, counter: Integer;
  character: Char;
  spaces: String;
Begin
  i := 0;
  x := OriginX;
  y := OriginY;
  spaces := space(80);  // 80 spaces

  While (i < DataLength) Do
    Begin
      Case Data[i] Of 
        #0..#15:
                 Begin
                   TextColor(Ord(Data[i]));
                 End;
        #16..#23:
                  Begin
                    TextBackground(Ord(Data[i]) - 16);
                  End;
        #24:
             Begin
               x := OriginX;
               Inc(y);
             End;
        #25:
             Begin
               Inc(i);
               count := Ord(Data[i])+1;
   { SysWrtCharStrAtt(@spaces[1], count, x-1, y-1, TextAttr); }
               RPFastWrite(spaces, x-1, y-1, TextAttr);
               Inc(x, count);
             End;
        #26:
             Begin
               Inc(i);
               count := Ord(Data[i])+1;
               Inc(i);
               character := Data[i];
               For counter := 1 To count Do
                 Begin
      {SysWrtCharStrAtt(@Data[i], 1, x-1, y-1, TextAttr);}
                   RPFastWrite(character, x-1, y-1, TextAttr);
                   Inc(x);
                 End;
             End;
        #27:
             Begin
               TextAttr := TextAttr XOR $80;
               // Invert blink flag
             End;
        #32..#255:
                   Begin
                     character := Data[i];
{	               SysWrtCharStrAtt(@Data[i], 1, x-1, y-1, TextAttr); }
                     RPFastWrite(character, x-1, y-1, TextAttr);
                     Inc(x);
                   End;
      End;
      Inc(i);
    End;
End;
{$ENDIF}
End.
