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
{   Foobar is distributed in the hope that it will be   }
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
{      Contains random functions for Renegade BBS       }
{*******************************************************}

{$mode objfpc}{$H+}

Unit Renegade.Random;

Interface


function RandomBytes(NumberOfBytes : LongInt) : AnsiString;
function RandomInt(min, max : SizeInt) : SizeInt;

Implementation

Uses
  SysUtils,
  Math;

const
  { BSD Base64 Characters }
  BCryptAcceptableChars = ['.','/','a'..'z', 'A'..'Z', '0'..'9'];

{
  Creates a random string of NumberOfBytes
  ???: Change this to use /dev/urandom where applicable.
}
function RandomBytes(NumberOfBytes : LongInt) : AnsiString;

Var
  i            : LongInt;
  RandomString : ^AnsiString;
  RandomChar   : Char;
Begin
  New(RandomString);
  SetLength(RandomString^, NumberOfBytes);
  Randomize;
  i := 1;
  repeat;
    RandomChar := Chr(Random(255));
    if RandomChar in BCryptAcceptableChars then
      begin
        RandomString^[i] := RandomChar;
        Inc(i);
      end;
  until  i = NumberOfBytes +1 ;
  RandomBytes := RandomString^;
  Dispose(RandomString);
End; { RandomBytes }

{ Returns a random number based between min and max }
function RandomInt(min, max : SizeInt) : SizeInt;
Begin
  if (min > max) then
    begin
       raise EInvalidArgument.create('Max cannot be less than min in function RandomInt(SizeInt,SizeInt):SizeInt.') at
         get_caller_addr(get_frame),
         get_caller_frame(get_frame);
    end;
  RandomIze;
  RandomInt := Math.RandomRange(min, max);
End;


End. { unit }
