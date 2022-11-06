unit Orion.ORM.Core;

interface

uses
  System.Generics.Collections,
  System.SysUtils,
  System.Rtti,
  System.Variants,
  Data.DB,

  Orion.ORM.Mapper,
  Orion.ORM.Types,
  Orion.ORM.Criteria,
  Orion.ORM.Interfaces,
  Orion.ORM.Rtti;

type
  TOrionORMCore<T:class, constructor> = class
  strict private
    FMapper: TOrionORMMapper;
    FDBConnection: iDBConnection;
    FChildRttiProperties : TDictionary<TRttiProperty, TOrionORMMapper>;
    FAutoCommit : boolean;
    FOrionCriteria : TOrionORMCriteria<T>;
//    function InternalFindOne(aID : integer; aMapper  : TOrionORMMapper) : T; overload;
    function InternalFindOne(aID : string; aMapper  : TOrionORMMapper) : T; overload;
    function InternalFindOne(aFilter : TOrionORMFilter; aMapper : TOrionORMMapper) : T; overload;
    function InternalFindMany(aFilter : TOrionORMFilter; aMapper  : TOrionORMMapper; aObjectList : TObjectList<TObject> = nil) : TObjectList<TObject>;
    procedure InternalSave(aDataObject: T; aMapper : TOrionORMMapper);
    procedure InternalSaveMany(aObjectList : TObjectList<TObject>; aMapper : TOrionORMMapper; aFKValue : string);
    procedure InternalDelete(aID: string);
    function isValidForSave (aMapperValue : TOrionORMMapperValue; aDataset : iDataset; aRttiProperty : TRttiProperty; aMapper : TOrionORMMapper): boolean;
    function GetObjectInstance(aList: TObjectList<TObject>): TObject;
    procedure ExecuteStatement(Statement: TStringBuilder; aDataset : iDataset);
    procedure DatasetToObject(Dataset: iDataset; var Result: T; aMapper : TOrionORMMapper);
    procedure ObjectToDataset(aDataObject: T; aDataset: iDataset; aMapper : TOrionORMMapper);
    function FormatFilter(aForeignKey : string; aDatasetField : TField; aIsAND : boolean) : string;
    procedure RttiPropertyToDatasetField(RttiProperty: TRttiProperty; aDataObject: T; aDataset : iDataset; aDatasetFieldName : string; aMapper : TOrionORMMapper);
    procedure FillUpdatedRecordLists(Dataset: iDataset; UpdatedRecords: System.Generics.Collections.TDictionary<string, Boolean>);
  private
    function GetDatasetFieldName(MapperValue: TOrionORMMapperValue) : string;

  public
    constructor Create(aDBConnection : iDBConnection);
    destructor Destroy; override;

    property Mapper: TOrionORMMapper read FMapper write FMapper;
    property DBConnection: iDBConnection read FDBConnection write FDBConnection;

    procedure Save(aDataObject : T);
//    function FindOne(aID : integer) : T; overload;
    function FindOne(aID : string) : T; overload;
    function FindOne(aFilter : TOrionORMFilter) : T; overload;
    function FindMany(aFilter : TOrionORMFilter) : TObjectList<T>;
    procedure Delete(aID : string);
  end;

implementation

{ TOrionORMCore }

constructor TOrionORMCore<T>.Create(aDBConnection : iDBConnection);
begin
  FDBConnection := aDBConnection;
  FChildRttiProperties := TDictionary<TRttiProperty, TOrionORMMapper>.Create;
  FOrionCriteria := TOrionORMCriteria<T>.Create;
end;

procedure TOrionORMCore<T>.Delete(aID : string);
begin
  try
    FAutoCommit := False;
    if not FDBConnection.InTransaction then begin
      FDBConnection.StartTransaction;
      FAutoCommit := True;
    end;

    InternalDelete(aID);

    if FDBConnection.InTransaction and FAutoCommit then
      FDBConnection.Commit;
  except on E: Exception do
    begin
      if FDBConnection.InTransaction and FAutoCommit then
        FDBConnection.RollBack;
      raise;
    end;
  end;
end;

function TOrionORMCore<T>.GetDatasetFieldName(MapperValue: TOrionORMMapperValue) : string;
var
  Strings: TArray<string>;
begin
  if MapperValue.FieldName.Contains('.') then begin
    Strings := MapperValue.FieldName.Split(['.']);
    Result := Strings[Pred(Length(Strings))];
  end
  else
    Result := MapperValue.FieldName;
end;

procedure TOrionORMCore<T>.FillUpdatedRecordLists(Dataset: iDataset; UpdatedRecords: System.Generics.Collections.TDictionary<string, Boolean>);
var
  isPKFounded: Boolean;
  DatasetField: TField;
  ProviderFlag: TProviderFlag;
begin
  Dataset.First;
  while not Dataset.Eof do begin
    isPKFounded := False;
    for DatasetField in Dataset.Fields do begin
      for ProviderFlag in DatasetField.ProviderFlags do begin
        if ProviderFlag = pfInKey then begin
          UpdatedRecords.Add(DatasetField.Value, False);
          isPKFounded := True;
          Break;
        end;
      end;
      if isPKFounded then
        Break;
    end;
    Dataset.Next;
  end;
end;

procedure TOrionORMCore<T>.RttiPropertyToDatasetField(RttiProperty: TRttiProperty; aDataObject: T; aDataset : iDataset; aDatasetFieldName : string; aMapper : TOrionORMMapper);
begin
  case RttiProperty.PropertyType.TypeKind of
    tkInteger:aDataset.FieldByName(aDatasetFieldName).AsInteger := RttiProperty.GetValue(Pointer(aDataObject)).AsInteger;
    tkChar:aDataset.FieldByName(aDatasetFieldName).AsString := RttiProperty.GetValue(Pointer(aDataObject)).AsString;
    tkEnumeration:aDataset.FieldByName(aDatasetFieldName).AsBoolean := RttiProperty.GetValue(Pointer(aDataObject)).AsBoolean;
    tkString:aDataset.FieldByName(aDatasetFieldName).AsString := RttiProperty.GetValue(Pointer(aDataObject)).AsString;
    tkWChar:aDataset.FieldByName(aDatasetFieldName).AsString := RttiProperty.GetValue(Pointer(aDataObject)).AsString;
    tkLString:aDataset.FieldByName(aDatasetFieldName).AsString := RttiProperty.GetValue(Pointer(aDataObject)).AsString;
    tkWString:aDataset.FieldByName(aDatasetFieldName).AsWideString := RttiProperty.GetValue(Pointer(aDataObject)).AsString;
    tkInt64:aDataset.FieldByName(aDatasetFieldName).AsLargeInt := RttiProperty.GetValue(Pointer(aDataObject)).AsInt64;
    tkUString:aDataset.FieldByName(aDatasetFieldName).AsString := RttiProperty.GetValue(Pointer(aDataObject)).AsString;
    tkFloat:
      begin
        if RttiProperty.PropertyType.Name.Contains('TDate') then
          aDataset.FieldByName(aDatasetFieldName).AsDateTime := RttiProperty.GetValue(Pointer(aDataObject)).AsExtended
        else
          aDataset.FieldByName(aDatasetFieldName).AsExtended := RttiProperty.GetValue(Pointer(aDataObject)).AsExtended;
      end;
    tkUnknown: ;
    tkSet: ;
    tkClass: begin
      if RttiProperty.GetValue(Pointer(aDataObject)).AsObject.ClassName.Contains('TObjectList<') then begin
        FChildRttiProperties.Add(RttiProperty, aMapper);
      end;
    end;
    tkMethod: ;
    tkDynArray: ;
    tkVariant: ;
    tkArray: ;
    tkRecord: ;
    tkInterface: ;
    tkClassRef: ;
    tkPointer: ;
    tkProcedure: ;
    tkMRecord: ;
  end;
end;

procedure TOrionORMCore<T>.DatasetToObject(Dataset: iDataset; var Result: T; aMapper : TOrionORMMapper);
var
  RttiContext: TRttiContext;
  RttiContextSplit : TRttiContext;
  RttiType: TRttiType;
  RttiTypeSplit : TRttiType;
  MapperValue: TOrionORMMapperValue;
  RttiProperty: TRttiProperty;
  RttiPropertySplit : TRttiProperty;
  Filter : string;
  PrimaryKey : string;
  ForeignKey : string;
  I : integer;
  ObjectList : TObjectList<TObject>;
  Constraint : TOrionORMMapperCOnstraint;
  lObject: TObject;
  lResultEntityPropertyByName : ResultEntityPropertyByName;
  DatasetFieldName : string;
  lString: TObject;
const
  IS_NOT_AND = False;
  IS_AND = True;
begin
  RttiContext := TRttiContext.Create;
  RttiType := RttiContext.GetType(Result.ClassInfo);
  try
    for MapperValue in aMapper.Values do
    begin
      lResultEntityPropertyByName := GetEntityPropertyByName(MapperValue.PropertyName, Result);
      RttiProperty := lResultEntityPropertyByName.&Property;
      if not Assigned(RttiProperty) then
        raise Exception.Create(Format('Property %s not found.', [RttiProperty.Name]));

      DatasetFieldName := GetDatasetFieldName(MapperValue);
      case RttiProperty.PropertyType.TypeKind of
        tkInteger:     RttiProperty.SetValue(Pointer(lResultEntityPropertyByName.Entity), Dataset.FieldByName(DatasetFieldName).AsInteger);
        tkChar:        RttiProperty.SetValue(Pointer(lResultEntityPropertyByName.Entity), Dataset.FieldByName(DatasetFieldName).AsString);
        tkEnumeration: RttiProperty.SetValue(Pointer(lResultEntityPropertyByName.Entity), Dataset.FieldByName(DatasetFieldName).AsBoolean);
        tkFloat:       RttiProperty.SetValue(Pointer(lResultEntityPropertyByName.Entity), Dataset.FieldByName(DatasetFieldName).AsFloat);
        tkString:      RttiProperty.SetValue(Pointer(lResultEntityPropertyByName.Entity), Dataset.FieldByName(DatasetFieldName).AsString);
        tkWChar:       RttiProperty.SetValue(Pointer(lResultEntityPropertyByName.Entity), Dataset.FieldByName(DatasetFieldName).AsString);
        tkLString:     RttiProperty.SetValue(Pointer(lResultEntityPropertyByName.Entity), Dataset.FieldByName(DatasetFieldName).AsString);
        tkWString:     RttiProperty.SetValue(Pointer(lResultEntityPropertyByName.Entity), Dataset.FieldByName(DatasetFieldName).AsString);
        tkInt64:       RttiProperty.SetValue(Pointer(lResultEntityPropertyByName.Entity), Dataset.FieldByName(DatasetFieldName).AsLargeInt);
        tkUString:     RttiProperty.SetValue(Pointer(lResultEntityPropertyByName.Entity), Dataset.FieldByName(DatasetFieldName).AsString);
        tkUnknown: ;
        tkSet: ;
        tkClass: begin
          if RttiProperty.GetValue(Pointer(lResultEntityPropertyByName.Entity)).AsObject.ClassName.Contains('TObjectList<') then begin
            ForeignKey := MapperValue.Mapper.GetDatasetFieldName(MapperValue.Mapper.GetFKPropertyName);
            PrimaryKey := aMapper.GetDatasetFieldName(aMapper.GetPKPropertyName);
            Filter := FormatFilter(ForeignKey, Dataset.FieldByName(PrimaryKey), IS_NOT_AND);

            if Assigned(ObjectList) then
              ObjectList := nil;

            ObjectList := InternalFindMany(Filter, MapperValue.Mapper, TObjectList<TObject>(RttiProperty.GetValue(Pointer(lResultEntityPropertyByName.Entity)).AsObject));
            if not Assigned(ObjectList) then
              Continue;

            ObjectList.OwnsObjects := False;
            TObjectList<TObject>(RttiProperty.GetValue(Pointer(lResultEntityPropertyByName.Entity)).AsObject).Clear;
            for lObject in ObjectList do begin
              TObjectList<TObject>(RttiProperty.GetValue(Pointer(lResultEntityPropertyByName.Entity)).AsObject).Add(lObject);
            end;
          end
        end;
        tkMethod: ;
        tkVariant: ;
        tkArray: ;
        tkRecord: ;
        tkInterface: ;
        tkDynArray: ;
        tkClassRef: ;
        tkPointer: ;
        tkProcedure: ;
        tkMRecord: ;
      end;
    end;
  finally
    if Assigned(ObjectList) then
      ObjectList.DisposeOf;
  end;
end;

procedure TOrionORMCore<T>.ExecuteStatement(Statement: TStringBuilder; aDataset : iDataset);
begin
  aDataset.Statement(Statement.ToString);
  aDataset.Open;
end;

destructor TOrionORMCore<T>.Destroy;
begin
  FChildRttiProperties.DisposeOf;
  FOrionCriteria.DisposeOf;
  if Assigned(FMapper) then
    FMapper.DisposeOf;
  inherited;
end;

function TOrionORMCore<T>.FindMany(aFilter: TOrionORMFilter): TObjectList<T>;
begin
  Result := TObjectList<T>(InternalFindMany(aFilter, FMapper));
end;

function TOrionORMCore<T>.FindOne(aID: string): T;
begin
  Result := InternalFindOne(aID, FMapper);
end;

function TOrionORMCore<T>.FindOne(aFilter: TOrionORMFilter): T;
begin
  Result := InternalFindOne(aFilter, FMapper);
end;

//function TOrionORMCore<T>.FindOne(aID : integer) : T;
//begin
//  Result := InternalFindOne(aID.ToString, FMapper);
//end;

function TOrionORMCore<T>.FormatFilter(aForeignKey : string; aDatasetField : TField; aIsAND : boolean) : string;
begin
  Result := Format(' %s = %s ', [aForeignKey, VarToStr(aDatasetField.AsVariant).QuotedString]);
//  case aDatasetField.FieldKind of
//    ftString, ftWideString, ftFixedChar, ftFixedWideChar: Result := Format(' %s = %s ', [aForeignKey, aDatasetField.AsString.QuotedString]);
//    ftSmallint, ftInteger : Result := Format(' %s = %n ', [aForeignKey, aDatasetField.AsInteger]);
//    ftLargeint: Result := Format(' %s = %n ', [aForeignKey, aDatasetField.AsLargeInt]);
//  end;
end;

function TOrionORMCore<T>.GetObjectInstance(aList: TObjectList<TObject>): TObject;
var
  lContext : TRttiContext;
  lType : TRttiType;
  lTypeName : string;
  lMethodType : TRttiMethod;
  lMetaClass : TClass;
begin
  lContext := TRttiContext.Create;
  lTypeName := Copy(aList.QualifiedClassName, 41, aList.QualifiedClassName.Length-41);
  lType := lContext.FindType(lTypeName);
  lMetaClass := nil;
  lMethodType := nil;
  if Assigned(lType) then begin
    for lMethodType in lType.GetMethods do begin
      if lMethodType.HasExtendedInfo and lMethodType.IsConstructor and (Length(lMethodType.GetParameters) = 0) then begin
        lMetaClass := lType.AsInstance.MetaclassType;
        Break;
      end;
    end;
  end;

  Result := lMethodType.Invoke(lMetaClass, []).AsObject;
end;

procedure TOrionORMCore<T>.InternalDelete(aID: string);
var
  Statement : TStringBuilder;
  Dataset : iDataset;
  Mapper : TOrionORMMapper;
begin
  Statement := TStringBuilder.Create;
  Dataset := FDBConnection.NewDataset;
  try
    FOrionCriteria.BuildDeleteStatement(Statement, aID, FMapper, FMapper.GetPKPropertyName);
    Dataset.Statement(Statement.ToString);
    Dataset.ExecSQL;

    for Mapper in FMapper.Mappers do begin
      Statement.Clear;
      FOrionCriteria.BuildDeleteStatement(Statement, aID, Mapper, Mapper.GetFKPropertyName);
      Dataset.Statement(Statement.ToString);
      Dataset.ExecSQL;
    end;
  finally
    Statement.DisposeOf;
  end;
end;

function TOrionORMCore<T>.InternalFindMany(aFilter : TOrionORMFilter; aMapper  : TOrionORMMapper; aObjectList : TObjectList<TObject>) : TObjectList<TObject>;
var
  Statement : TStringBuilder;
  Dataset : iDataset;
  lObject : T;
  lChildObject : TObject;
begin
  Result := nil;
  if not Assigned(aMapper) then
    raise Exception.Create('No mapper found.');

  Statement := TStringBuilder.Create;
  Dataset := FDBConnection.NewDataset;
  try
    FOrionCriteria.BuildFindStatement(Statement, aFilter, aMapper);
    ExecuteStatement(Statement, Dataset);

    if Dataset.RecordCount = 0 then
      Exit;

    Result := TObjectList<TObject>.Create;
    if not Assigned(aObjectList) then begin
      Dataset.First;
      while not Dataset.Eof do begin
        lObject := T.Create;
        DatasetToObject(Dataset, lObject, aMapper);
        Result.Add(lObject);
        Dataset.Next;
      end;
    end
    else begin
      Dataset.First;
      while not Dataset.Eof do begin
        lChildObject := GetObjectInstance(aObjectList);
        DatasetToObject(Dataset, lChildObject, aMapper);
        Result.Add(lChildObject);
        Dataset.Next;
      end;
    end;

  finally
    Statement.DisposeOf;
  end;
end;

function TOrionORMCore<T>.InternalFindOne(aID: string; aMapper: TOrionORMMapper): T;
var
  Statement : TStringBuilder;
  Dataset : iDataset;
  Filter : string;
begin
  if not Assigned(FMapper) then
    raise Exception.Create('No mapper found.');

  Statement := TStringBuilder.Create;
  Dataset := FDBConnection.NewDataset;
  try
    Filter := aMapper.GetDatasetFieldName(aMapper.GetPKPropertyName) + ' = ' + aID.QuotedString;
    FOrionCriteria.BuildFindStatement(Statement, Filter, aMapper);
    ExecuteStatement(Statement, Dataset);

    if Dataset.RecordCount = 0 then
      Exit;

    Result := T.Create;
    DatasetToObject(Dataset, Result, aMapper);
  finally
    Statement.DisposeOf;
  end;
end;

function TOrionORMCore<T>.InternalFindOne(aFilter: TOrionORMFilter; aMapper: TOrionORMMapper): T;
var
  Statement : TStringBuilder;
  Dataset : iDataset;
begin
  Result := nil;
  if not Assigned(FMapper) then
    raise Exception.Create('No mapper found.');

  Statement := TStringBuilder.Create;
  Dataset := FDBConnection.NewDataset;
  try
    FOrionCriteria.BuildFindStatement(Statement, aFilter, aMapper);
    ExecuteStatement(Statement, Dataset);

    if Dataset.RecordCount = 0 then
      Exit;

    Result := T.Create;
    DatasetToObject(Dataset, Result, aMapper);
  finally
    Statement.DisposeOf;
  end;
end;

//function TOrionORMCore<T>.InternalFindOne(aID : integer; aMapper  : TOrionORMMapper) : T;
//var
//  Statement : TStringBuilder;
//  Dataset : iDataset;
//  Filter : string;
//begin
//  if not Assigned(FMapper) then
//    raise Exception.Create('No mapper found.');
//
//  Statement := TStringBuilder.Create;
//  Dataset := FDBConnection.NewDataset;
//  try
//    Filter := aMapper.GetDatasetFieldName(aMapper.GetPKPropertyName) + ' = ' + aID.ToString;
//    FOrionCriteria.BuildFindStatement(Statement, Filter, aMapper);
//    ExecuteStatement(Statement, Dataset);
//
//    if Dataset.RecordCount = 0 then
//      Exit;
//
//    Result := T.Create;
//    DatasetToObject(Dataset, Result, aMapper);
//  finally
//    Statement.DisposeOf;
//  end;
//end;

procedure TOrionORMCore<T>.InternalSave(aDataObject: T; aMapper : TOrionORMMapper);
var
  Statement : TStringBuilder;
  Dataset : iDataset;
begin
  FChildRttiProperties.Clear;
  if not Assigned(aDataObject) then
    raise Exception.Create('DataObject not Found.');

  if not Assigned(FMapper) then
    raise Exception.Create('Mapper not Found.');

  if not Assigned(FDBConnection) then
    raise Exception.Create('Connection not found.');

  Dataset := FDBConnection.NewDataset;
  Statement := TStringBuilder.Create;
  try
    FOrionCriteria.BuildSaveStatement(Statement, aDataObject, aMapper);
    ExecuteStatement(Statement, Dataset);
    ObjectToDataset(aDataObject, Dataset, aMapper);
  finally
    Statement.DisposeOf;
  end;
end;

procedure TOrionORMCore<T>.InternalSaveMany(aObjectList : TObjectList<TObject>; aMapper : TOrionORMMapper; aFKValue : string);
var
  Dataset : iDataset;
  Statement : TStringBuilder;
  UpdatedRecords : TDictionary<string, boolean>;
  lObject: TObject;
  MapperValue : TOrionORMMapperValue;
  RttiContext : TRttiContext;
  RttiType : TRttiType;
  RttiProperty : TRttiProperty;
  DatasetFieldName : string;
  UpdatedRecordsKey: string;
  UpdateRecordPair : TPair<string, boolean>;
begin
  Dataset := FDBConnection.NewDataset;
  Statement := TStringBuilder.Create;
  UpdatedRecords := TDictionary<string, boolean>.Create;
  try
    FOrionCriteria.BuildSaveManyStatement(Statement, aMapper, nil, aFKValue);
    ExecuteStatement(Statement, Dataset);
    FillUpdatedRecordLists(Dataset, UpdatedRecords);
    for lObject in aObjectList do begin
      RttiContext := TRttiContext.Create;
      RttiType := RttiContext.GetType(lObject.ClassInfo);
      try
        RttiProperty := RttiType.GetProperty(aMapper.GetPKPropertyName);
        if isEmptyProperty(RttiProperty, Pointer(lObject)) then
          Dataset.Append
        else begin
          Dataset.Locate(aMapper.GetDatasetFieldName(aMapper.GetPKPropertyName), RttiProperty.GetValue(Pointer(lObject)).AsVariant, []);
          Dataset.Edit;
        end;

        for RttiProperty in RttiType.GetProperties do begin
          DatasetFieldName := aMapper.GetDatasetFieldName(RttiProperty.Name);
          if DatasetFieldName.IsEmpty then
            Continue;

          if aMapper.IsPK(RttiProperty.Name) and UpdatedRecords.ContainsKey(Dataset.FieldByName(DatasetFieldName).Value) then begin
            UpdateRecordPair := UpdatedRecords.ExtractPair(Dataset.FieldByName(DatasetFieldName).Value);
            UpdateRecordPair.Value := True;
            UpdatedRecords.AddOrSetValue(Dataset.FieldByName(DatasetFieldName).Value, True);
          end;

          if not isValidForSave(MapperValue, Dataset, RttiProperty, aMapper) then
            Continue;

          if aMapper.IsFK(RttiProperty.Name) then begin
            case RttiProperty.PropertyType.TypeKind of
              tkInteger: RttiProperty.SetValue(Pointer(lObject), aFKValue.ToInteger);
              tkInt64 : RttiProperty.SetValue(Pointer(lObject), aFKValue.ToInt64);
              tkChar, tkString, tkWChar, tkLString, tkWString, tkUString: begin
                RttiProperty.SetValue(Pointer(lObject), aFKValue)
              end;
            end;
          end;

          RttiPropertyToDatasetField(RttiProperty, lObject, Dataset, DatasetFieldName, aMapper);
        end;
        Dataset.Post;
        RttiProperty := RttiType.GetProperty(aMapper.GetPKPropertyName);
        RttiProperty.SetValue(Pointer(lObject), TValue.FromVariant(Dataset.FieldByName(aMapper.GetDatasetFieldName(RttiProperty.Name)).AsVariant));
      finally
        RttiType.DisposeOf;
      end;
    end;

    for UpdatedRecordsKey in UpdatedRecords.Keys do begin
      if not UpdatedRecords.Items[UpdatedRecordsKey] then begin
        Dataset.Locate(aMapper.GetDatasetFieldName(aMapper.GetPKPropertyName), UpdatedRecordsKey, []);
        Dataset.Delete;
      end;
    end;
  finally
    Statement.DisposeOf;
    UpdatedRecords.DisposeOf;
  end;
end;

function TOrionORMCore<T>.isValidForSave(aMapperValue : TOrionORMMapperValue; aDataset : iDataset; aRttiProperty : TRttiProperty; aMapper : TOrionORMMapper): boolean;
begin
  Result := True;
  if not (aMapperValue.FieldName.IsEmpty) and not aDataset.FieldExist(aMapperValue.FieldName) then begin
    Result := False;
    Exit;
  end;

  if not Assigned(aRttiProperty) then
    raise Exception.Create(Format('Property %s not found.', [aMapperValue.PropertyName]));

  if not (aMapperValue.FieldName.IsEmpty) and aDataset.FieldByName(aMapperValue.FieldName).ReadOnly then begin
    Result := False;
    Exit;
  end;

  if aMapper.isAutoInc(aRttiProperty.Name) then begin
    Result := False;
    Exit;
  end;
end;

procedure TOrionORMCore<T>.ObjectToDataset(aDataObject: T; aDataset: iDataset; aMapper : TOrionORMMapper);
var
  MapperValue: TOrionORMMapperValue;
  RttiContext : TRttiContext;
  RttiType : TRttiType;
  RttiProperty : TRttiProperty;
  ProviderFlag : TProviderFlag;
  FKValue : string;
  Constraint: TOrionORMMapperConstraint;
  lResultEntityPropertyByName : ResultEntityPropertyByName;
  DatasetFieldName : string;
begin
  FChildRttiProperties.Clear;
  RttiContext := TRttiContext.Create;
  RttiType := RttiContext.GetType(aDataObject.ClassInfo);
  try
    if aDataset.RecordCount = 0 then
      aDataset.Append
    else
      aDataset.Edit;

    RttiProperty := RttiType.GetProperty(aMapper.GetPKPropertyName);
    FKValue := RttiProperty.GetValue(Pointer(aDataObject)).ToString;

    for MapperValue in aMapper.Values do begin
      lResultEntityPropertyByName := GetEntityPropertyByName(MapperValue.PropertyName, aDataObject);
      RttiProperty := lResultEntityPropertyByName.&Property;
      if not isValidForSave(MapperValue, aDataset, RttiProperty, aMapper) then
        Continue;

      DatasetFieldName := GetDatasetFieldName(MapperValue);
      RttiPropertyToDatasetField(RttiProperty, aDataObject, aDataset, DatasetFieldName, MapperValue.Mapper);
    end;
    aDataset.Post;

    RttiProperty := RttiType.GetProperty(aMapper.GetPKPropertyName);
    case RttiProperty.PropertyType.TypeKind of
        tkInteger: RttiProperty.SetValue(Pointer(aDataObject), aDataset.FieldByName(aMapper.GetDatasetFieldName(RttiProperty.Name)).AsInteger);

        tkChar, tkString, tkWChar, tkLString, tkWString, tkUString: begin
          RttiProperty.SetValue(Pointer(aDataObject), aDataset.FieldByName(aMapper.GetDatasetFieldName(RttiProperty.Name)).AsString);
        end;

        tkInt64: RttiProperty.SetValue(Pointer(aDataObject), aDataset.FieldByName(aMapper.GetDatasetFieldName(RttiProperty.Name)).AsLargeInt);
    end;
//    RttiProperty.SetValue(Pointer(aDataObject), aDataset.FieldByName(aMapper.GetDatasetFieldName(RttiProperty.Name)).AsInteger);
    FKValue := RttiProperty.GetValue(Pointer(aDataObject)).ToString;

    if FChildRttiProperties.Count > 0 then begin
      for RttiProperty in FChildRttiProperties.Keys do begin
        InternalSaveMany(TObjectList<TObject>(RttiProperty.GetValue(Pointer(aDataObject)).AsObject), FChildRttiProperties.Items[RttiProperty], FKValue);
      end;
    end;
  finally
    RttiType.DisposeOf;
  end;
end;

procedure TOrionORMCore<T>.Save(aDataObject: T);
begin
  try
    FAutoCommit := False;
    if not FDBConnection.InTransaction then begin
      FDBConnection.StartTransaction;
      FAutoCommit := True;
    end;

    InternalSave(aDataObject, FMapper);

    if FDBConnection.InTransaction and FAutoCommit then
      FDBConnection.Commit;
  except on E: Exception do
    begin
      if FDBConnection.InTransaction and FAutoCommit then
        FDBConnection.RollBack;
      raise;
    end;
  end;
end;

end.
