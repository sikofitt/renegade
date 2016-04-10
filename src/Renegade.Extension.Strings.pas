{
   Renegade.Extension.Strings.pas
   
   Copyright 2016 R. Eric Wheeler <eric@rewiv.com>
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA.
   
   
}

Unit Renegade.Extension.Strings;

{$mode objfpc}{$H+}
{$modeswitch typehelpers}
  
Interface

Uses 
  SysUtils,
  StrUtils, 
  Base64;

type
  RTStringHelper = type helper for AnsiString
    function getLength :  LongInt;
    function base64Encode : AnsiString;
    function base64Decode : AnsiString;
    function RTCopy(Index, Count : LongInt) : AnsiString;
    function del(Index, Count : LongInt) : AnsiString;
    function has(const SearchString : AnsiString) : Boolean;
    function starts(const SearchString : AnsiString ) : Boolean;
    function ends(const SearchString : AnsiString) : Boolean;
    function caseHas(const SearchString : AnsiString) : Boolean;
    function caseStarts(const SearchString : AnsiString ) : Boolean;
    function caseEnds(const SearchString : AnsiString) : Boolean;
    function equals(const CompareString : AnsiString) : Boolean;
    function caseEquals(const CompareString : AnsiString) : Boolean;
    function toLowerCase : AnsiString;
    function toUpperCase : AnsiString;
  end;

Implementation

function RTStringHelper.toLowerCase : AnsiString;
begin
 toLowerCase := LowerCase(self);
end;
function RTStringHelper.toUpperCase : AnsiString;
begin
 toUpperCase := UpperCase(self);
end;
function RTStringHelper.caseEquals(const CompareString : AnsiString) : Boolean;
begin
 caseEquals := LowerCase(CompareString) = LowerCase(self);
end;
function RTStringHelper.equals(const CompareString : AnsiString) : Boolean;
begin
 equals := CompareString = self;
end;
function RTStringHelper.caseHas(const SearchString : AnsiString) : Boolean;
begin
 caseHas := AnsiContainsStr(self, SearchString);
end;

function RTStringHelper.caseEnds(const SearchString : AnsiString) : Boolean;
begin
 caseEnds := AnsiEndsStr(SearchString, self);
end;

function RTStringHelper.caseStarts(const SearchString : AnsiString) : Boolean;
begin
 caseStarts := AnsiStartsStr(SearchString, self);
end;


function RTStringHelper.starts(const SearchString : AnsiString) : Boolean;
begin
 starts := AnsiStartsText(SearchString, self);
end;

function RTStringHelper.ends(const SearchString : AnsiString) : Boolean;
begin
  ends := AnsiEndsText(SearchString, self);
end;

function RTStringHelper.has(const SearchString : AnsiString) : Boolean;
begin
 has := AnsiContainsText(self, SearchString);
end;
function RTStringHelper.del(Index, Count : LongInt) : AnsiString;
var
  DeletedString : AnsiString;
begin
 SetLength(DeletedString, Length(self));
 DeletedString := self;
 Delete(DeletedString, Index, Count);
 del := DeletedString;
end;
function RTStringHelper.RTCopy(Index, Count : LongInt) : AnsiString;
begin
 RTCopy := Copy(self, Index, Count);
end;

function RTStringHelper.getLength : LongInt;
begin
 getLength := Length(self);
end;

function RTStringHelper.base64Encode : AnsiString;
begin
  base64Encode := EncodeStringBase64(self);	
end;

function RTStringHelper.base64Decode : AnsiString;
begin
  base64Decode := DecodeStringBase64(self);
end;

End.

