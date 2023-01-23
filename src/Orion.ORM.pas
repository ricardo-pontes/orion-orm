unit Orion.ORM;

interface

uses
  System.Generics.Collections,
  System.SysUtils,
  Orion.ORM.Interfaces,
  Orion.ORM.Types,
  Orion.ORM.Mapper,
  Orion.ORM.Core;

type
  TOrionORM<T:class, constructor> = class(TInterfacedObject, iOrionORM<T>)
  private
    FCore : TOrionORMCore<T>;
    FDBConnection : iDBConnection;
    FPagination : iOrionORMPagination;
  public
    constructor Create(aDBConnection : iDBConnection); overload;
    constructor Create(aDBConnection : iDBConnection; aPagination : iOrionORMPagination); overload;
    destructor Destroy; override;
    class function New(aDBConnection : iDBConnection) : iOrionORM<T>; overload;
    class function New(aDBConnection : iDBConnection; aPagination : iOrionORMPagination) : iOrionORM<T>; overload;

    procedure Mapper(aValue : TOrionORMMapper);
    procedure Save(aDataObject : T);
    function FindOne(aID : integer) : T; overload;
    function FindOne(aID : string) : T; overload;
    function FindOne(aFilter : TOrionORMFilter) : T; overload;
    function FindMany(aFilter : TOrionORMFilter) : TObjectList<T>;
    procedure Delete(aID : integer); overload;
    procedure Delete(aID : string); overload;
    function Pagination : iOrionORMPagination;
  end;

implementation

{ TOrionORM<T> }

constructor TOrionORM<T>.Create(aDBConnection : iDBConnection);
begin
  FDBConnection := aDBConnection;
  FCore := TOrionORMCore<T>.Create(aDBConnection);
end;

procedure TOrionORM<T>.Delete(aID : integer);
begin
  FCore.Delete(aID.ToString);
end;

constructor TOrionORM<T>.Create(aDBConnection: iDBConnection; aPagination: iOrionORMPagination);
begin
  FDBConnection := aDBConnection;
  FCore := TOrionORMCore<T>.Create(aDBConnection, aPagination);
end;

procedure TOrionORM<T>.Delete(aID: string);
begin
  FCore.Delete(aID);
end;

destructor TOrionORM<T>.Destroy;
begin
  FCore.DisposeOf;
  inherited;
end;

function TOrionORM<T>.FindMany(aFilter: TOrionORMFilter): TObjectList<T>;
begin
  Result := FCore.FindMany(aFilter);
end;

function TOrionORM<T>.FindOne(aID: string): T;
begin
  Result := FCore.FindOne(aID);
end;

function TOrionORM<T>.FindOne(aFilter: TOrionORMFilter): T;
begin
  Result := FCore.FindOne(aFilter);
end;

function TOrionORM<T>.FindOne(aID : integer): T;
begin
  Result := FCore.FindOne(aID.ToString);
end;

procedure TOrionORM<T>.Mapper(aValue: TOrionORMMapper);
begin
  FCore.Mapper := aValue;
end;

class function TOrionORM<T>.New(aDBConnection: iDBConnection; aPagination: iOrionORMPagination): iOrionORM<T>;
begin
  Result := Self.Create(aDBConnection, aPagination);
end;

class function TOrionORM<T>.New(aDBConnection : iDBConnection): iOrionORM<T>;
begin
  Result := Self.Create(aDBConnection);
end;

function TOrionORM<T>.Pagination: iOrionORMPagination;
begin
  Result := FCore.Pagination;
end;

procedure TOrionORM<T>.Save(aDataObject: T);
begin
  FCore.Save(aDataObject);
end;

end.
