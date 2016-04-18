Unit Renegade.Hash.Password;

Interface

type
  RTPasswordHash = packed record
    Cost : Byte;
    Algo,
    Salt,
    Hash : AnsiString;
  end;
  PRTPasswordHash = ^RTPasswordHash;

function expandPasswordHash(PasswordHash : AnsiString) : RTPasswordHash;
function implodePasswordHash(TPasswordHash : RTPasswordHash) : AnsiString;

Implementation

Uses
  Objects,
  StrUtils,
  SysUtils;

Const
 LENGTH_OF_ALGO = 4;
 LENGTH_OF_COST = 2;
 LENGTH_OF_SALT = 22;
 LENGTH_OF_HASH = 31;


function expandPasswordHash(PasswordHash : AnsiString) : RTPasswordHash;
Var
  TPasswordHash : PRTPasswordHash;
Begin
  New(TPasswordHash);
  TPasswordHash^.Algo := Copy(passwordHash, 1, LENGTH_OF_ALGO);
  TPasswordHash^.Cost := StrToInt(Copy(passwordHash, 5, LENGTH_OF_COST));
  TPasswordHash^.Salt := Copy(passwordHash, 8, LENGTH_OF_SALT);
  TPasswordHash^.Hash := Copy(passwordHash,
    Length(TPasswordHash^.Algo + TPasswordHash^.Salt) + LENGTH_OF_COST + 2,
    Length(passwordHash)
  );
  expandPasswordHash := TPasswordHash^;
  Freemem(TPasswordHash);
End;

function implodePasswordHash(TPasswordHash : RTPasswordHash) : AnsiString;
Var
  PasswordHash : AnsiString;
Begin
  SetLength(PasswordHash, 60);
  with TPasswordHash do
    begin
      PasswordHash := Algo + IntToStr(Cost) + '$' + Salt + Hash;
    end;
    implodePasswordHash := PasswordHash;
End;

end.
