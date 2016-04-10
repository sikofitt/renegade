Unit Renegade.Random;
{$CODEPAGE UTF8}

Interface

Function RandomBytes(NumberOfBytes : LongInt) : UTF8String;  

Implementation

Uses
  SysUtils;

type 
  AcceptableChars = array ['a'..'z', 'A'..'Z', 0..9] of PChar; 

Function RandomBytes(NumberOfBytes : LongInt) : UTF8String;

  
Var
  i, RandomNumber : LongInt;
  RandomString : ^UTF8String;
  
Begin
  New(RandomString);
  SetLength(RandomString^, NumberOfBytes);
  Randomize;
    i := 1;
    repeat;
        RandomNumber := Random(255);
       if Chr(RandomNumber) in ['.','/', 'a'..'z', 'A'..'Z', '0'..'9'] then
          begin
            RandomString^[i] := Chr(RandomNumber);
            Inc(i);
          end
      until  i = NumberOfBytes +1 ;
      
    RandomBytes := RandomString^;
  
End;

End.
