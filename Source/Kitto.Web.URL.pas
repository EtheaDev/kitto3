{-------------------------------------------------------------------------------
   Copyright 2012-2023 Ethea S.r.l.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
-------------------------------------------------------------------------------}

/// <summary>
///  Class TKWebURL
/// </summary>
unit Kitto.Web.URL;

interface

uses
  Classes
  , IdURI
  ;

type
  TKWebURL = class(TIdURI)
  public
    function GetURI: string;

    /// <summary>
    ///  Adds a trailing / if not present already.
    /// </summary>
    class function IncludeTrailingPathDelimiter(const APath: string): string;
  end;

implementation

uses
  SysUtils
  , StrUtils
  ;

{ TWebKURL }

function TKWebURL.GetURI: string;
begin
  Result := Path + Document;
end;

class function TKWebURL.IncludeTrailingPathDelimiter(const APath: string): string;
const
  PATH_DELIMITER = '/';

  function IsPathDelimiter(const AString: string; AIndex: Integer): Boolean;
  begin
    Result := (AIndex >= Low(string)) and (AIndex <= High(AString)) and (AString[AIndex] = PATH_DELIMITER)
      and (ByteType(AString, AIndex) = mbSingleByte);
  end;

begin
  Result := APath;
  if not IsPathDelimiter(Result, High(Result)) then
    Result := Result + PATH_DELIMITER;
end;

end.
