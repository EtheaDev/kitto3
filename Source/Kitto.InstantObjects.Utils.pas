{-------------------------------------------------------------------------------
   Copyright 2019-2023 Ethea S.r.l.

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
unit Kitto.InstantObjects.Utils;

interface

uses
  InstantPersistence
  , CBInstantPersistence
  , InstantFireDAC
  , EF.DB
  , Kitto.Store
  ;

type
  TInstantKittoConnector = class
  private
    FConnection: TEFDBConnection;
    FInstantFireDACConnector: TInstantFireDACConnector;
    function GetInstantFireDACConnector: TInstantFireDACConnector;
    procedure EnsureConnection;
  public
    destructor Destroy; override;

    property Connector: TInstantFireDACConnector read GetInstantFireDACConnector;
  End;

function RetrieveOrCreateInstantObject(const AClassName, AId: string;
      const AConnector: TInstantConnector = nil) : TCBInstantObject;

function TKRecordToInstantObject(ARecord : TKRecord ) : TCBInstantObject;

procedure InstantObjectToTKRecord(AInstantObject : TCBInstantObject; const ARecord: TKRecord) ;

procedure InstantObjectBeforeStore(AInstantObject : TCBInstantObject) ;

const
  FIELD_CLASS = 'Class';
  FIELD_ID = 'Id';

implementation

uses
  System.Classes,
  System.SysUtils,
  System.Variants,
  System.StrUtils,
  RTTI,
  Data.DB,
  FireDAC.Comp.Client,
  EF.DB.FD,
  Kitto.Config,
  Kitto.Metadata.Models,
  Kitto.DbUtils,
  InstantClasses;

function RetrieveOrCreateInstantObject(const AClassName, AId: string;
      const AConnector: TInstantConnector = nil) : TCBInstantObject;
var
  LClass: TPersistentClass;
  LInstantClass: TCBInstantObjectClass;
begin
  if AClassName = '' then
    Exit(nil);

  LClass := GetClass(AClassName);
  If Assigned(LClass) and LClass.InheritsFrom(TCBInstantObject) then
  begin
    LInstantClass := TCBInstantObjectClass(LClass);
    if AId <> '' then
      Result := LInstantClass.Retrieve(AId, False, False, AConnector)
    else
      Result := nil;

    //if not found, crete the object
    if not Assigned(Result) then
    begin
      Result := LInstantClass.Create(AConnector);

      if AId <> '' then
        Result.Id := AId;
    end;
  end
  else
    raise Exception.CreateFmt('Class not found. (ClassName=%s ) ', [AClassName]);
end;


function TKRecordToInstantObject(ARecord : TKRecord ) : TCBInstantObject;
var
  LInstantConnector: TInstantKittoConnector;
  I: integer;
  C: TRttiContext;
  LType : TRttiInstanceType;
  LProperty : TRttiProperty;
  LRefName: string;
  LModel: TKModel;
  LInstantAttribute: TInstantAttribute;
begin
  LInstantConnector:= TInstantKittoConnector.Create;
  try
    LModel := ModelByRecord(ARecord);
    Result := RetrieveOrCreateInstantObject( VarToStr(LModel.FieldByName(FIELD_CLASS).DefaultValue),
                                             ARecord.FieldByName(FIELD_ID).AsString,
                                             LInstantConnector.Connector);

    LType :=  c.GetType(Result.ClassInfo) as TRttiInstanceType;
    if Assigned(Result) then
    begin
      for I := 0 to ARecord.FieldCount-1 do
      begin
        LInstantAttribute := Result.FindAttribute(ARecord.Fields[I].FieldName);

        if (not ARecord.Fields[I].IsCompositeField) and
           ARecord.Fields[I].IsModified then
        begin
          //Se è stato modificato da ISF e
          //il campo del record è null tengo il valore modificato
          if Assigned(LInstantAttribute) and
             LInstantAttribute.IsChanged and
             ARecord.Fields[I].IsNull then
            Continue;

          if Assigned(LModel.FindField(ARecord.Fields[I].FieldName)) and
             LModel.FieldByName(ARecord.Fields[I].FieldName).IsReference then
          begin
            LRefName := ARecord.Fields[I].FieldName;
            LProperty := LType.GetProperty(ARecord.Fields[I].FieldName );
            if Assigned(LProperty) and LProperty.IsWritable then
            begin
              LProperty.SetValue(Result, RetrieveOrCreateInstantObject(
                                              ARecord.FieldByName(LRefName+FIELD_CLASS).AsString,
                                              ARecord.FieldByName(LRefName+FIELD_ID).AsString,
                                              LInstantConnector.Connector));
            end;
          end
          else
          begin
            LProperty := LType.GetProperty(ARecord.Fields[I].FieldName);
            if Assigned(LProperty) and LProperty.IsWritable then
              LProperty.SetValue(Result, TValue.FromVariant(ARecord.Fields[I].Value));
          end;
        end;
      end;
    end;

  finally
    FreeAndNil(LInstantConnector)
  end;
end;

procedure InstantObjectToTKRecord(AInstantObject : TCBInstantObject; const ARecord: TKRecord) ;
var
  C: TRttiContext;
  I: Integer;
  LType : TRttiInstanceType;
  LRefType : TRttiInstanceType;
  LProperty : TRttiProperty;
  LPropertyRefClass : TRttiProperty;
  LPropertyRefId : TRttiProperty;
  LValue: TValue;
  LModel: TKModel;
  LRefName: string;
  LObject: TObject;
begin
  Assert(Assigned(AInstantObject));

  LType :=  c.GetType(AInstantObject.ClassInfo) as TRttiInstanceType;
  LModel := ModelByRecord(ARecord);
  for I := 0 to ARecord.FieldCount-1 do
  begin
    if (not ARecord.Fields[I].IsCompositeField) then
    begin
      LProperty := LType.GetProperty(ARecord.Fields[I].FieldName);
      if Assigned(LProperty) then
      begin
        if LModel.FieldByName(ARecord.Fields[I].FieldName).IsReference then
        begin
          LObject:= LProperty.GetValue(AInstantObject).AsObject;
          if Assigned(LObject) then
          begin
            LRefType := c.GetType(LObject.ClassInfo) as TRttiInstanceType;
            LRefName := ARecord.Fields[I].FieldName;

            LPropertyRefClass := LRefType.GetProperty(FIELD_CLASS+FIELD_ID);
            LPropertyRefId := LRefType.GetProperty(FIELD_ID);
            if Assigned(LPropertyRefClass) then
              ARecord.FieldByName(LRefName+FIELD_CLASS).AsString := LPropertyRefClass.GetValue(LObject).AsString;
            if Assigned(LPropertyRefId) then
              ARecord.FieldByName(LRefName+FIELD_ID).AsString := LPropertyRefId.GetValue(LObject).AsString;
          end;
        end
        else
        begin
          LValue:= LProperty.GetValue(AInstantObject);
          case ARecord.Fields[I].DataType.GetFieldType of
            ftString, ftWideString, ftFixedChar, ftFixedWideChar: if LValue.AsString = '' then  ARecord.Fields[I].SetToNull
                                                                   else ARecord.Fields[I].AsString := LValue.AsString;
            ftSmallint, ftInteger, ftWord, ftLongWord, ftShortint, ftByte, ftSingle: ARecord.Fields[I].AsInteger := LValue.AsInteger;
            ftBoolean:  ARecord.Fields[I].AsBoolean := LValue.AsBoolean;
            ftDate, ftDateTime, ftTime, ftTimeStamp: 
               if (LValue.AsType<TDateTime> = 0) then ARecord.Fields[I].SetToNull
                else ARecord.Fields[I].Value := LValue.AsVariant;
            ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftExtended: ARecord.Fields[I].Value := LValue.AsVariant;
            ftMemo, ftWideMemo, ftFmtMemo: ARecord.Fields[I].Value := LValue.AsVariant;
            ftLargeint: ARecord.Fields[I].Value := LValue.AsVariant;
            ftVariant: ARecord.Fields[I].Value := LValue.AsVariant;

            //ftUnknown, ftBytes, ftVarBytes, ftAutoInc, ftBlob. ftGraphic
            //ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor
            //ftADT, ftArray, ftReference, ftDataSet, ftOraBlob, ftOraClob
            //ftInterface, ftIDispatch, ftGuid, ftOraTimeStamp, ftOraInterval
            //ftConnection, ftParams, ftStream, ftTimeStampOffset, ftObject
          end;
        end;
      end;
    end;
  end;

end;

procedure InstantObjectBeforeStore(AInstantObject : TCBInstantObject) ;
var
  C: TRttiContext;
  LBeforeStore: TRTTIMethod;
begin
  LBeforeStore := C.GetType(AInstantObject.ClassInfo).GetMethod('BeforeStore');

  LBeforeStore.Invoke(AInstantObject, []);
end;

{ TInstantKittoConnector }

destructor TInstantKittoConnector.Destroy;
begin
  FreeAndNil(FInstantFireDACConnector);
  FreeAndNil(FConnection);
  inherited;
end;

function TInstantKittoConnector.GetInstantFireDACConnector: TInstantFireDACConnector;
begin
  EnsureConnection;
  Result := FInstantFireDACConnector;
end;

procedure TInstantKittoConnector.EnsureConnection;
begin
  if not Assigned(FConnection) then
  begin
    FConnection := TKConfig.Database; // Crea un'istanza nuova.
    try
      if not (FConnection is TEFDBFDConnection) then
        raise Exception.Create('TKConfig.Database is not a TEFDBFDConnection');

      if not FConnection.IsOpen then
        // Necessario per configurare la connection interna.
        FConnection.Open;

      var LFDConnection := FConnection.GetConnection as TFDConnection;
      FInstantFireDACConnector := TInstantFireDACConnector.Create(nil);
      try
        FInstantFireDACConnector.BlobStreamFormat := sfXML;
        FInstantFireDACConnector.Connection := LFDConnection;
        FInstantFireDACConnector.LoginPrompt := False;
      except
        FreeAndNil(FInstantFireDACConnector);
        raise;
      end;
    except
      FreeAndNil(FConnection);
      raise;
    end;
  end;
end;

end.
