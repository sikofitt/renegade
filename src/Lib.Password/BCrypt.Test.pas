Program BCrypt.Test.pas;

Uses base64, SysUtils, blowfish, classes;

Const BFRounds = 12;

Var
  Base64String : AnsiString;
  InputString  : AnsiString;
  OutputString : AnsiString;
  BlowFishCrypt: TBlowFishEncryptStream;
  StringStream : TStringStream;  
Begin
  StringStream := TStringStream.Create('');
  BlowFishCrypt := TBlowFishEncryptStream.Create('760b35c6ad6034cee18bb7d26d37075501783918378e', StringStream);
  SetLength(OutputString, 32);
  BlowFishCrypt.Write('Testing this out', 32);
  InputString := 'String to encode';
  WriteLn(StringStream.DataString);
  Base64String := EncodeStringBase64(StringStream.DataString);
  WriteLn(Base64String); 
  BlowFishCrypt.Free;
  StringStream.Free;
End.