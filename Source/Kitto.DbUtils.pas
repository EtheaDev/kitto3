unit Kitto.DbUtils;

interface

uses
  DB
  , KItto.Store
  , Kitto.Metadata.Models
  , EF.Tree;

const
  PROGRESS_STR = 'Progressivo per';

function CalcNewProgress(const IdProgress: string; CharSize: integer): string;
function GetSQLCountValue(const ATableName, AFieldName, AFieldValue: string;
  const AIdToExclude: string = ''): string;
function GetSQLFieldValue(const ATableName, AFieldName, AKeyFieldName, AKeyFieldValue: string): string;
function GetTableName(const AField: TKField): string;
function GetPhisicalName(const AField: TKField): string;
function ModelByField(const AField: TKField): TKModel;
function ModelByRecord(const ARecord: TKRecord): TKModel;
function ModelFieldByField(const AField: TKField): TKModelField;
function ModelFindField(const AField: TKField): boolean;
function GetSQLDeleteStatement(const ATableName, AKeyFieldName, AFieldValue: string): string;
procedure DeleteRecord(const ATableName, AKeyFieldName, AFieldValue: string);
procedure UpdateParamValue(AParams: TParams; const AParamName: string; AValue: Variant);
procedure CheckPasswordStrenght(const APassword: string);

//funzioni di recupero dati da Codice Fiscale
function RecuperaNazioneNascDaCF(const ACodiceFiscale : string) : string;
function RecuperaProvinciaNascDaCF(const ACodiceFiscale : string) : string;

implementation

uses
  UAppUtils
  ,RegularExpressions
  ,EF.Localization
  ,Kitto.Metadata.DataView
  ,EF.DB
  ,Kitto.Config
  ,Kitto.Auth.DB
  ,Kitto.Rules
  ,System.SysUtils
  ,EF.StrUtils
  ,System.Variants
  ,EF.VariantUtils
  ,FireDAC.Comp.Client
  ,EF.DB.FD
  ,InstantClasses;

function EsisteNominativoByCodiceFiscale(const ACodiceFiscale, AIdDaEscludere: string): boolean;
begin
  Result := EFVarToInt(TKConfig.Database.GetSingletonValue(
    'SELECT COUNT(*) FROM NOMINATIVI WHERE ID <> ''' + AIdDaEscludere + ''' AND CODFISC  = ''' + ACodiceFiscale + '''')) > 0;
end;

function EsisteUtenteAttivo(const ACodiceFiscale: string): boolean;
begin
  Result := EFVarToInt(TKConfig.Database.GetSingletonValue(
    'SELECT COUNT(*) FROM APPUSER WHERE ID = ''' + ACodiceFiscale + ''' AND NOT (MUST_CHANGE_PASSWORD = 1 AND ACCESS_DENIED = 1)')) > 0;
end;

function EsisteLuogoNascita(const AComuneId: string): boolean;
begin
  Result := EFVarToInt(TKConfig.Database.GetSingletonValue(
    'SELECT COUNT(*) FROM COMUNI WHERE ID = ''' + AComuneId+'''')) > 0;
end;

function EsisteUtenteDaAttivare(const ACodiceFiscale: string): boolean;
begin
  Result := EFVarToInt(TKConfig.Database.GetSingletonValue(
    'SELECT COUNT(*) FROM APPUSER WHERE ID = ''' + ACodiceFiscale + ''' AND MUST_CHANGE_PASSWORD = 1 AND ACCESS_DENIED = 1')) > 0;
end;

function CalcNazioneIdByCodiceIstat(const aCodiceIstat: string): string;
begin
  Result := EFVarToStr(TKConfig.Database.GetSingletonValue(
    'SELECT ID FROM NAZIONI WHERE CODICEISTAT  = ''' + aCodiceIstat + ''''));
end;

procedure UpdateParamValue(AParams: TParams; const AParamName: string; AValue: Variant);
var
  LParam: TParam;
begin
  LParam := AParams.FindParam(AParamName);
  if Assigned(LParam) then
  begin
    if VarIsStr(AValue) and (AValue = '') then
    begin
      LParam.DataType := ftWideString;
      LParam.Value := Null;
    end
    else
      LParam.Value := AValue;
  end;
end;

function ModelByField(const AField: TKField): TKModel;
begin
  Result := (AField.ParentRecord as TKViewTableRecord).ViewTable.Model;
end;

function ModelByRecord(const ARecord: TKRecord): TKModel;
begin
  Result := (ARecord as TKViewTableRecord).ViewTable.Model;
end;

function ModelFieldByField(const AField: TKField): TKModelField;
begin
  Result := (AField.ParentRecord as TKViewTableRecord).ViewTable.Model.FindField(AField.FieldName);
end;

function ModelFindField(const AField: TKField): boolean;
begin
  Result := (AField.ParentRecord as TKViewTableRecord).ViewTable.Model.FindField(AField.FieldName) <> nil;
end;

function GetTableName(const AField: TKField): string;
begin
  Result := ModelByField(AField).PhysicalName;
end;

function GetPhisicalName(const AField: TKField): string;
var
  LModelField: TKModelField;
begin
  LModelField := ModelByField(AField).FindField(AField.FieldName);
  if Assigned(LModelField) then
    Result := LModelField.PhysicalName
  else
    Result := '';
end;

function GetSQLCountValue(const ATableName, AFieldName, AFieldValue: string;
  const AIdToExclude: string = ''): string;
begin
  if AIdToExclude <> '' then
    Result := Format('SELECT COUNT(*) TOT FROM %s WHERE Id <> ''%s'' and %s = ''%s''',
      [ATableName, AIdToExclude, AFieldName, AFieldValue])
  else
    Result := Format('SELECT COUNT(*) TOT FROM %s WHERE %s = ''%s''',
      [ATableName, AFieldName, AFieldValue]);
end;

function GetSQLDeleteStatement(const ATableName, AKeyFieldName, AFieldValue: string): string;
begin
  Result := Format('DELETE FROM %s WHERE %s = ''%s''',
    [ATableName, AKeyFieldName, AFieldValue]);
end;

function GetSQLFieldValue(const ATableName, AFieldName, AKeyFieldName, AKeyFieldValue: string): string;
begin
    Result := Format('SELECT %s TOT FROM %s WHERE %s = ''%s''',
      [AFieldName, ATableName, AKeyFieldName, AKeyFieldValue]);
end;

function CalcNewProgress(const IdProgress: string;
      CharSize: integer): string;
var
  LQueryText: string;
  LQuery: TEFDBQuery;
  LCommandText: string;
  LCommand: TEFDBCommand;
  GeneratedId : integer;
  LNumRec: integer;
  LWasInTransaction: Boolean;
begin

  LQueryText := 'SELECT COUNT(*) REC_NUMBER FROM IDGENERATOR WHERE ID = :Id';
  LQuery := TKConfig.Database.CreateDBQuery;
  Try
    LQuery.CommandText := LQueryText;
    LQuery.Params.ParamByName('Id').AsString := UpperCase(IdProgress);
    LQuery.Open;
    LNumRec := LQuery.DataSet.Fields[0].AsInteger;
    LQuery.Close;

    LCommand := TKConfig.Database.CreateDBCommand;
    Try
      LWasInTransaction := LCommand.Connection.IsInTransaction;

      if not LWasInTransaction then
        LCommand.Connection.StartTransaction;
      try
        if LNumRec = 0 then
        begin
          LCommandText := 'INSERT INTO IDGENERATOR '+
                          '(CLASS, ID, UPDATECOUNT, DX, UPDTIMESTAMP, GENERATEDID, CHARSNUM) '+
                          'VALUES '+
                          '(''TISIdGenerator'', :Id, 1, :DX, CURRENT_TIMESTAMP, :GENERATEDID, :CHARSNUM)';

          LCommand.CommandText := LCommandText;
          GeneratedId := 1;
          UpdateParamValue(LCommand.Params,'DX', PROGRESS_STR+' '+UpperCase(IdProgress));
          UpdateParamValue(LCommand.Params,'CHARSNUM', CharSize);
        end
        else
        begin
          LQueryText := 'SELECT GENERATEDID FROM IDGENERATOR WHERE ID = :Id';
          LCommandText := 'UPDATE IDGENERATOR SET GENERATEDID = :GENERATEDID WHERE ID = :Id';
          LCommand.CommandText := LCommandText;
          LQuery.Close;
          LQuery.CommandText := LQueryText;

          LQuery.Params.ParamByName('Id').AsString := UpperCase(IdProgress);

          LQuery.Open;
          GeneratedId := LQuery.DataSet.Fields[0].AsInteger;
        end;

        LQuery.Close;
        UpdateParamValue(LCommand.Params,'Id', UpperCase(IdProgress));
        UpdateParamValue(LCommand.Params,'GENERATEDID', GeneratedId+1);
        LCommand.Execute;

        if CharSize <> 0 then
          Result := PadLeft(IntToStr(GeneratedId),CharSize,'0')
        else
          Result := IntToStr(GeneratedId);

        if not LWasInTransaction then
          LCommand.Connection.CommitTransaction;
      except
        if not LWasInTransaction then
          LCommand.Connection.RollbackTransaction;

        raise;
      end;


    Finally
      FreeAndNil(LCommand);
    End;

  Finally
    FreeAndNil(LQuery);
  End;
end;

procedure DeleteRecord(const ATableName, AKeyFieldName, AFieldValue: string);
var
  LCommand: TEFDbCommand;
begin
  LCommand := TKConfig.Database.CreateDBCommand;
  try
    LCommand.Connection.StartTransaction;
    try
      LCommand.CommandText := GetSQLDeleteStatement(ATableName, AKeyFieldName, AFieldValue);
      LCommand.Execute;
      LCommand.Connection.CommitTransaction;
    except
      LCommand.Connection.RollbackTransaction;
    end;
  finally
    FreeAndNil(LCommand);
  end;
end;

procedure CheckPasswordStrenght(const APassword: string);
var
  LValidatePasswordNode: TEFNode;
  LErrorMsg, LRegEx: string;
  LRegularExpression : TRegEx;
  LMatch: TMatch;
begin
  // Example of enforcement of password strength rules.
  LValidatePasswordNode := TKConfig.Instance.Config.FindNode('Auth/ValidatePassword');
  Assert(Assigned(LValidatePasswordNode));
  LErrorMsg := LValidatePasswordNode.GetExpandedString('Message','Min.8 caratteri con lettere e numeri');
  LRegEx := LValidatePasswordNode.GetExpandedString('RegEx','^[ -~]{8,63}$');
  LRegularExpression.Create(LRegEx);
  LMatch := LRegularExpression.Match(APassword);
  if not LMatch.Success then
    raise EKValidationError.CreateWithAdditionalInfo(LErrorMsg, 'Validazione password');
end;

//TODO: da rivedere
function RecuperaNazioneNascDaCF(const ACodiceFiscale : string) : string;
var
  LQueryText: string;
  LQuery: TEFDBQuery;
  LIdNazione : string;
begin
  Result := '';
  if Length(ACodiceFiscale) = 16 then
    LIdNazione := EncodeLuogoNascitaId(ACodiceFiscale)
  else
    exit;

  LQueryText := 'SELECT ID FROM NAZIONI WHERE CODICEAT = :Id';
  LQuery := TKConfig.Database.CreateDBQuery;
  Try
    LQuery.CommandText := LQueryText;
    LQuery.Params.ParamByName('Id').AsString := UpperCase(LIdNazione);
    LQuery.Open;
    if LQuery.DataSet.IsEmpty then //se non lo trovo la nazione è italia
      Result := 'IT'
    else
      Result := LQuery.DataSet.Fields[0].AsString;
    LQuery.Close;
  Finally
    FreeAndNil(LQuery);
  End;
End;

//TODO: da rivedere
function RecuperaProvinciaNascDaCF(const ACodiceFiscale : string) : string;
var
  LQueryText: string;
  LQuery: TEFDBQuery;
  LIdComune : string;
begin
  Result := '';
  if Length(ACodiceFiscale) = 16 then
    LIdComune := EncodeLuogoNascitaId(ACodiceFiscale)
  else
    exit;

  LQueryText := 'SELECT PROVID FROM COMUNI WHERE ID = :Id';
  LQuery := TKConfig.Database.CreateDBQuery;
  Try
    LQuery.CommandText := LQueryText;
    LQuery.Params.ParamByName('Id').AsString := UpperCase(LIdComune);
    LQuery.Open;
    if not LQuery.DataSet.IsEmpty then
      Result := LQuery.DataSet.Fields[0].AsString;
    LQuery.Close;
  Finally
    FreeAndNil(LQuery);
  End;
End;

end.
