unit Orion.ORM.Mapper;

interface

uses
  Orion.ORM.Types,
  System.Generics.Collections;

type
  TOrionORMMapper = class;

  TOrionORMMapperValue = record
    PropertyName : string;
    FieldName : string;
    Constraints : TOrionORMMapperConstraints;
    Middlewares : array of TOrionORMMiddleware;
    Mapper : TOrionORMMapper;
  end;

  TOrionORMMapper = class
  private
    FMapperValues : TList<TOrionORMMapperValue>;
    FMappers : TObjectList<TOrionORMMapper>;
    FJoins : TList<string>;
    FPrimaryKey : TList<string>;
    FForeignKeys : TList<string>;
    FTableName: string;
    FIsChild: boolean;
    procedure AddMapper(aPropertyName, aFieldName : string; aConstraints : TOrionORMMapperConstraints; aMapper : TOrionORMMapper);
  public
    constructor Create;
    destructor Destroy; override;

    property TableName: string read FTableName write FTableName;
    property IsChild: boolean read FIsChild write FIsChild;
    procedure Add(aPropertyName : string; aFieldName : string); overload;
    procedure Add(aPropertyName : string; aFieldName : string; aConstraints : TOrionORMMapperConstraints); overload;
    procedure Add(aPropertyName : string; aOrionORMMapper : TOrionORMMapper); overload;
    procedure Add(aPropertyName : string; aOrionORMMapper : TOrionORMMapper; aConstraints : TOrionORMMapperConstraints); overload;
    procedure AddJoin(aValue : string);
    function Values : TList<TOrionORMMapperValue>;
    function PK : TList<string>;
    function FK(aPropertyName : string) : TList<string>;
    function Joins : TList<string>;
    function GetDatasetFieldName(aPropertyName : string) : string;
    function GetPKPropertyName : string;
    function GetFKPropertyName : string;
    function isPK(aPropertyName : string) : boolean;
    function isFK(aPropertyName : string) : boolean;
    function IsAutoInc(aPropertyName : string) : boolean;
    function Mappers : TObjectList<TOrionORMMapper>;
//    function Get
  end;

  TOrionORMMapperManager = class
  private
    class var FManagerList : TObjectDictionary<string, TOrionORMMapper>;
    class var FDefaultInstance : TOrionORMMapperManager;
    class function GetDefaultInstance : TOrionORMMapperManager;
  public
    class constructor Create;
    class destructor Destroy;

    class procedure Add(aMapperName : string; aMapperValue : TOrionORMMapper);
    class function Find(aMapperName : string) : TOrionORMMapper;
  end;

implementation

{ TOrionORMMapper }

procedure TOrionORMMapper.Add(aPropertyName, aFieldName: string);
begin
  AddMapper(aPropertyName, aFieldName, [], nil);
end;

procedure TOrionORMMapper.Add(aPropertyName, aFieldName: string; aConstraints: TOrionORMMapperConstraints);
begin
  AddMapper(aPropertyName, aFieldName, aConstraints, nil);
end;

procedure TOrionORMMapper.Add(aPropertyName: string; aOrionORMMapper: TOrionORMMapper;
  aConstraints: TOrionORMMapperConstraints);
begin
  AddMapper(aPropertyName, '', aConstraints, aOrionORMMapper);
end;

procedure TOrionORMMapper.AddJoin(aValue: string);
begin
  if not FJoins.Contains(aValue) then
    FJoins.Add(aValue);
end;

procedure TOrionORMMapper.Add(aPropertyName: string; aOrionORMMapper: TOrionORMMapper);
begin
  AddMapper(aPropertyName, '', [], aOrionORMMapper);
end;

procedure TOrionORMMapper.AddMapper(aPropertyName, aFieldName : string; aConstraints : TOrionORMMapperConstraints; aMapper : TOrionORMMapper);
var
  lValue : TOrionORMMapperValue;
begin
  lValue.PropertyName := aPropertyName;
  lValue.FieldName := aFieldName;
  lValue.Constraints := aConstraints;
  lValue.Mapper := aMapper;
  FMapperValues.Add(lValue);
  if Assigned(aMapper) then
    FMappers.Add(aMapper);
end;

function TOrionORMMapper.PK: TList<string>;
var
  lMapperValue: TOrionORMMapperValue;
  lConstraint: TOrionORMMapperConstraint;
begin
  FPrimaryKey.Clear;
  for lMapperValue in FMapperValues do begin
    for lConstraint in lMapperValue.Constraints do begin
      if (lConstraint = TOrionORMMapperConstraint.PK) and not (FPrimaryKey.Contains(lMapperValue.FieldName)) then
        FPrimaryKey.Add(lMapperValue.FieldName);
    end;
  end;
  Result := FPrimaryKey;
end;

constructor TOrionORMMapper.Create;
begin
  FMapperValues := TList<TOrionORMMapperValue>.Create;
  FMappers := TObjectList<TOrionORMMapper>.Create;
  FJoins := TList<string>.Create;
  FPrimaryKey := TList<string>.Create;
  FForeignKeys := TList<string>.Create;
end;

destructor TOrionORMMapper.Destroy;
begin
  FMapperValues.DisposeOf;
  FMappers.DisposeOf;
  FJoins.DisposeOf;
  FPrimaryKey.DisposeOf;
  FForeignKeys.DisposeOf;
  inherited;
end;

function TOrionORMMapper.GetDatasetFieldName(aPropertyName: string): string;
var
  MapperValue: TOrionORMMapperValue;
begin
  Result := '';
  for MapperValue in FMapperValues do begin
    if not (MapperValue.PropertyName = aPropertyName) then
      Continue;

    Result := MapperValue.FieldName;
    Break;
  end;
end;

function TOrionORMMapper.GetFKPropertyName: string;
var
  MapperValue: TOrionORMMapperValue;
  Constraint: TOrionORMMapperConstraint;
begin
  for MapperValue in FMapperValues do begin
    for Constraint in MapperValue.Constraints do begin
      if Constraint = TOrionORMMapperConstraint.FK then begin
        Result := MapperValue.PropertyName;
        Exit;
      end;
    end;
  end;
end;

function TOrionORMMapper.GetPKPropertyName: string;
var
  MapperValue: TOrionORMMapperValue;
  Constraint: TOrionORMMapperConstraint;
begin
  for MapperValue in FMapperValues do begin
    for Constraint in MapperValue.Constraints do begin
      if Constraint = TOrionORMMapperConstraint.PK then begin
        Result := MapperValue.PropertyName;
        Exit;
      end;
    end;
  end;
end;

function TOrionORMMapper.IsAutoInc(aPropertyName: string): boolean;
var
  MapperValue: TOrionORMMapperValue;
  Constraint: TOrionORMMapperConstraint;
begin
  Result := False;
  for MapperValue in FMapperValues do begin
    if not (MapperValue.PropertyName = aPropertyName) then
      Continue;

    for Constraint in MapperValue.Constraints do begin
      if Constraint = TOrionORMMapperConstraint.AutoInc then begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

function TOrionORMMapper.isFK(aPropertyName: string): boolean;
var
  MapperValue: TOrionORMMapperValue;
  Constraint: TOrionORMMapperConstraint;
begin
  Result := False;
  for MapperValue in FMapperValues do begin
    if not (MapperValue.PropertyName = aPropertyName) then
      Continue;

    for Constraint in MapperValue.Constraints do begin
      if Constraint = TOrionORMMapperConstraint.FK then begin
        Result := True;
        Exit;
      end;
    end;
  end;

end;

function TOrionORMMapper.isPK(aPropertyName: string): boolean;
var
  MapperValue: TOrionORMMapperValue;
  Constraint: TOrionORMMapperConstraint;
begin
  Result := False;
  for MapperValue in FMapperValues do begin
    if not (MapperValue.PropertyName = aPropertyName) then
      Continue;

    for Constraint in MapperValue.Constraints do begin
      if Constraint = TOrionORMMapperConstraint.PK then begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

function TOrionORMMapper.FK(aPropertyName : string) : TList<string>;
var
  lMapperValue: TOrionORMMapperValue;
  lConstraint: TOrionORMMapperConstraint;
begin
  FForeignKeys.Clear;
  for lMapperValue in FMapperValues do begin
    for lConstraint in lMapperValue.Constraints do begin
      if (lConstraint = TOrionORMMapperConstraint.FK) and not (FPrimaryKey.Contains(lMapperValue.FieldName)) then
        FForeignKeys.Add(lMapperValue.FieldName);
    end;
  end;
  Result := FForeignKeys;
end;

function TOrionORMMapper.Joins: TList<string>;
begin
  Result := FJoins;
end;

function TOrionORMMapper.Mappers: TObjectList<TOrionORMMapper>;
begin
  Result := FMappers;
end;

function TOrionORMMapper.Values: TList<TOrionORMMapperValue>;
begin
  Result := FMapperValues;
end;

{ TOrionORMMapperManager }

class procedure TOrionORMMapperManager.Add(aMapperName: string; aMapperValue: TOrionORMMapper);
begin
  GetDefaultInstance;
  if not FManagerList.ContainsKey(aMapperName) then
    FManagerList.Add(aMapperName, aMapperValue);
end;

class constructor TOrionORMMapperManager.Create;
begin
  FManagerList := TObjectDictionary<string, TOrionORMMapper>.Create;
end;

class destructor TOrionORMMapperManager.Destroy;
begin
  FManagerList.DisposeOf;
  if Assigned(FDefaultInstance) then
    FDefaultInstance.DisposeOf;

end;

class function TOrionORMMapperManager.Find(aMapperName: string): TOrionORMMapper;
begin
  GetDefaultInstance;
  Result := nil;
  FManagerList.TryGetValue(aMapperName, Result);
end;

class function TOrionORMMapperManager.GetDefaultInstance: TOrionORMMapperManager;
begin
  if not Assigned(FDefaultInstance) then
    FDefaultInstance := TOrionORMMapperManager.Create;

  Result := FDefaultInstance;
end;

end.
