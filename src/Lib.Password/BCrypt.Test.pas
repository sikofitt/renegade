Program BCrypt.Test.pas;

Uses
  SysUtils, Renegade.Hash.BCrypt;
Const BCRYPT_DEFAULT_COST = 14;
Var
  HashToCompare : PAnsiString;
  PasswordInformation : RTPasswordInformation;
Begin
  HashToCompare := NewStr('$2y$12$gGgJvTCj2L4klTKG.5cWeeC1UM2CUIV1e3UusdkwKlOi3lye5/ezW');
  WriteLn(verifyPassword('password', HashToCompare^));
  DisposeStr(HashToCompare);
  PasswordInformation := passwordGetInfo(HashToCompare^);
  with PasswordInformation do
    begin
      WriteLn(Algo);
      WriteLn(AlgoName);
      WriteLn(Cost);
    end;

 End.
