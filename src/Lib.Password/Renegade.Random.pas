Unit Renegade.Random;
{$CODEPAGE UTF8}

Interface

Function RandomBytes(NumberOfBytes : PtrUint) : UTF8String;  

Implementation

Uses
  SysUtils;
  
Function RandomBytes(NumberOfBytes : PtrUInt) : UTF8String;
Var
  i, RandomNumber : PtrUInt;
  Result : AnsiString;
Begin
  SetLength(Result, NumberOfBytes);
  Randomize;
    i := 0;
    repeat;
        RandomNumber := Random(255);
        if RandomNumber > 27 then
          begin
            Result[i] := Chr(RandomNumber);
            Inc(i);
          end
        else begin
         Dec(i);
         end;
    until i = NumberOfBytes;
    RandomBytes := Result;
End;

End.