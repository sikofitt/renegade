Program Renegade.Hash.Password.Test;
{$mode objfpc}
{$assertions on}{$M+}
Uses
  Classes,
  SysUtils,
  Renegade.Hash.Password,
  Renegade.Hash.BCrypt;

Const
  passwordHash = '$2y$12$fhkiJD4Cs8GEw/QhEJaJmOvNwgN76KcPY8PYCgAri6/Zzbsl8rz4C';
  testingPassword = 'password';
Var
  TPasswordHash : PRTPasswordHash;
  PasswordHashFromTPasswordHash : AnsiString;
Begin
  New(TPasswordHash);
  TPasswordHash^ := expandPasswordHash(passwordHash);
  with TPasswordHash^ do
    begin
      try
        WriteLn(Format('Length : %02d, Value : %s', [Length(Algo), Algo]));
        WriteLn(Format('Length : %02d, Value : %d', [Length(IntToStr(Cost)), Cost]));
        WriteLn(Format('Length : %02d, Value : %s', [Length(Salt), Salt]));
        WriteLn(Format('Length : %02d, Value : %s', [Length(Hash), Hash]));
        try
          Assert(Length(Hash) = 32, 'Fail');
          Assert(Length(Hash) = 31, 'Success');
          Assert(passwordVerify(testingPassword, passwordHash) = True, 'Success');
        except
          on AE: EAssertionFailed do
            WriteLn(AE.Message);
        end;
      except
        on E: EConvertError do
        WriteLn('Convert Error : ', E.Message);
      end;
    end;

  PasswordHashFromTPasswordHash := implodePasswordHash(TPasswordHash^);
  WriteLn('Length : ', Length(PasswordHash), ', Value : ', PasswordHashFromTPasswordHash);

  Freemem(TPasswordHash);
end.
