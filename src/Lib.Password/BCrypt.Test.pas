Program BCrypt.Test.pas;

Uses SysUtils, classes, BCrypt, Renegade.Random, Base64;
Const BFRounds = 14;
Var
  SaltString  : AnsiString;
  SaltBytes :  UTF8String;
  HashedPassword : AnsiString;
  ch : Char;
Begin  
  SaltBytes:= RandomBytes(32);
  SaltString := EncodeStringBase64(SaltBytes);
  SetLength(SaltString, Length(SaltBytes)+1);
  HashedPassword := HashPassword('password', SaltString);
  WriteLn(Length(HashedPassword));
 WriteLn(HashedPassword);
 for ch := 'a' to 'z' do
  begin
  write(ch);
  end;
 End.
