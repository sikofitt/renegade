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

{$mode objfpc}{$H+}
{$modeswitch typehelpers}

Unit Renegade.Extension.Strings;

Interface

Uses
  SysUtils,
  StrUtils,
  Base64;

type
  RTStringHelper = type helper for AnsiString
    function Length : LongInt;
    function base64Encode : AnsiString;
    function base64Decode : AnsiString;
    function Copy(Index, Count : LongInt) : AnsiString;
    function Delete(Index, Count : LongInt) : AnsiString;
    function Has(const SearchString : AnsiString) : Boolean;
    function Starts(const SearchString : AnsiString ) : Boolean;
    function Ends(const SearchString : AnsiString) : Boolean;
    function caseHas(const SearchString : AnsiString) : Boolean;
    function caseStarts(const SearchString : AnsiString ) : Boolean;
    function caseEnds(const SearchString : AnsiString) : Boolean;
    function Equals(const CompareString : AnsiString) : Boolean;
    function caseEquals(const CompareString : AnsiString) : Boolean;
    function toLowerCase : AnsiString;
    function toUpperCase : AnsiString;
  end;

Implementation

{ Returns a lowercase version of the AnsiString }
function RTStringHelper.toLowerCase : AnsiString;
begin
 toLowerCase := AnsiLowerCase(self);
end; { RTStringHelper.toLowerCase }

{ Returns an uppercase version of the AnsiString }
function RTStringHelper.toUpperCase : AnsiString;
begin
 toUpperCase := AnsiUpperCase(self);
end; { RTStringHelper.toUpperCase }

{ Case insensitive comparision of the AnsiString and CompareString }
function RTStringHelper.caseEquals(const CompareString : AnsiString) : Boolean;
begin
 caseEquals := AnsiLowerCase(CompareString) = AnsiLowerCase(self);
end; { RTStringHelper.caseEquals }

{ Case sensitive comparision of the AnsiString and CompareString }
function RTStringHelper.Equals(const CompareString : AnsiString) : Boolean;
begin
 Equals := CompareString = self;
end; { RTStringHelper.Equals }

{ Case insensitive check to see if the AnsiString contains the SearchString. }
function RTStringHelper.caseHas(const SearchString : AnsiString) : Boolean;
begin
 caseHas := AnsiContainsStr(self, SearchString);
end; { RTStringHelper.caseHas }

{ Case insensitive check to see if the AnsiString ends with the SearchString. }
function RTStringHelper.caseEnds(const SearchString : AnsiString) : Boolean;
begin
 caseEnds := AnsiEndsStr(SearchString, self);
end; { RTStringHelper.caseEnds }

{ Case insensitive check to see if the AnsiString starts with the SearchString. }
function RTStringHelper.caseStarts(const SearchString : AnsiString) : Boolean;
begin
 caseStarts := AnsiStartsStr(SearchString, self);
end; { RTStringHelper.caseStarts }

{ Case sensitive check to see if the AnsiString starts with the SearchString. }
function RTStringHelper.Starts(const SearchString : AnsiString) : Boolean;
begin
 Starts := AnsiStartsText(SearchString, self);
end; { RTStringHelper.Starts }

{ Case sensitive check to see if the AnsiString ends with the SearchString. }
function RTStringHelper.Ends(const SearchString : AnsiString) : Boolean;
begin
  Ends := AnsiEndsText(SearchString, self);
end;
{ Case sensitive check to see if the AnsiString contains the SearchString. }
function RTStringHelper.Has(const SearchString : AnsiString) : Boolean;
begin
 Has := AnsiContainsText(self, SearchString);
end; { RTStringHelper.Has }

{
  Deletes text starting with Index up to Count.
  Unlike System.Delete, this will return the modified AnsiString
  preserving the original AnsiString.
}
function RTStringHelper.Delete(Index, Count : LongInt) : AnsiString;
var
  DeletedString : AnsiString;
begin
 SetLength(DeletedString, System.Length(self));
 DeletedString := self;
 System.Delete(DeletedString, Index, Count);
 Delete := DeletedString;
end; { RTStringHelper.Delete }

{ Copies text starting with Index up to Count and returns the copied text. }
function RTStringHelper.Copy(Index, Count : LongInt) : AnsiString;
begin
 Copy := System.Copy(self, Index, Count);
end; { RTStringHelper.Copy }

{ Returns the length of the AnsiString. }
function RTStringHelper.Length : LongInt;
begin
  Length := System.Length(self);
end; { RTStringHelper.Length }

{ Base 64 Encodes the AnsiString and returns the result.}
function RTStringHelper.base64Encode : AnsiString;
begin
  base64Encode := EncodeStringBase64(self);
end; { RTStringHelper.base64Encode }

{ Base 64 decodes the AnsiString and returns the result.
  Note : If the string is not base 64 encoded this function will
         return garbage.
}
function RTStringHelper.base64Decode : AnsiString;
begin
  base64Decode := DecodeStringBase64(self);
end; { RTStringHelper.base64Decode }

End. { End Unit }

