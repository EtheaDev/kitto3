unit Kitto.InstantObjects.Utils;

interface

uses
  InstantPersistence,
  CBInstantPersistence,
  InstantFireDAC,
  Kitto.Store;

type
  TInstantKittoConnector = Class
  private
    FInstantFireDACConnector: TInstantFireDACConnector;
    function GetInstantFireDACConnector: TInstantFireDACConnector;
  public
    constructor Create;
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

constructor TInstantKittoConnector.Create;
var
  LFDConnection: TFDConnection;
begin
  if TKConfig.Database is TEFDBFDConnection then
  begin
    LFDConnection := TKConfig.Database.GetConnection as TFDConnection;
    if Assigned(LFDConnection) then
    begin
      FInstantFireDACConnector := TInstantFireDACConnector.Create(nil);
      try
        FInstantFireDACConnector.BlobStreamFormat := sfXML;
        FInstantFireDACConnector.Connection := LFDConnection;
        FInstantFireDACConnector.loginPrompt := False;

      except
        LFDConnection.Free;
        FInstantFireDACConnector.Free;
        raise;
      end;

    end
    else
      raise Exception.Create('Connection not found');
  end
  else
    raise Exception.Create('FireDAC Connection not found');
end;

function TInstantKittoConnector.GetInstantFireDACConnector: TInstantFireDACConnector;
begin
  Result := FInstantFireDACConnector;
end;

end.
