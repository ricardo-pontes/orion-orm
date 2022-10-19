unit Orion.ORM.DBConnection.FireDAC.SQLite;

interface

uses
  Orion.ORM.Interfaces,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Phys,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Phys.SQLiteDef,
//  {$IFDEF FMX}
    FireDAC.FMXUI.Wait,
//  {$ENDIF}

//  {$IFDEF VCL}
    FireDAC.VCLUI.Wait,
//  {$ENDIF}

//  {$IFDEF CONSOLE}
    FireDAC.ConsoleUI.Wait,
//  {$ENDIF}
  FireDAC.Comp.UI,
  FireDAC.Phys.IBBase,
  FireDAC.Phys.SQLite,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  System.Classes;
type
  TOrionORMDBConnectionFiredacSQLite = class(TInterfacedObject, iDBConnection, iDBConnectionConfigurations)
  private
    FDBConnection : TFDConnection;
    FDriverLink : TFDPhysSQLiteDriverLink;
  public
    constructor Create;
    destructor Destroy; override;
    class function New : iDBConnection;
    procedure Configurations(aPath, aUsername, aPassword, aServer : string; aPort : integer); overload;
    function Configurations : iDBConnectionConfigurations; overload;
    procedure StartTransaction;
    procedure Commit;
    procedure RollBack;
    function IsConnected : boolean; overload;
    function InTransaction : boolean;
    procedure Connected(aValue : boolean); overload;
    function Component : TComponent;
    function NewDataset : iDataset;

    function Path : string; overload;
    procedure Path(aValue : string); overload;
    function Username : string; overload;
    procedure Username(aValue : string); overload;
    function Password : string; overload;
    procedure Password(aValue : string); overload;
    function Server : string; overload;
    procedure Server(aValue : string); overload;
    function Port : integer; overload;
    procedure Port(aValue : integer); overload;
  end;

implementation

uses
  System.SysUtils,
  Orion.ORM.DBConnection.FireDAC.Query;

{ TOrionORMDBConnectionFiredacSQLite }
procedure TOrionORMDBConnectionFiredacSQLite.Commit;
begin
  FDBConnection.Commit;
end;

function TOrionORMDBConnectionFiredacSQLite.Component: TComponent;
begin
  Result := FDBConnection;
end;

procedure TOrionORMDBConnectionFiredacSQLite.Configurations(aPath, aUsername, aPassword, aServer: string; aPort: integer);
begin
  FDBConnection.Params.Database := aPath;
  FDBConnection.Params.UserName := aUserName;
  FDBConnection.Params.Password := aPassword;
  if aPort > 0 then
    FDBConnection.Params.AddPair('Port', aPort.ToString);
end;

function TOrionORMDBConnectionFiredacSQLite.Configurations: iDBConnectionConfigurations;
begin
  Result := Self;
end;

procedure TOrionORMDBConnectionFiredacSQLite.Connected(aValue: boolean);
begin
  FDBConnection.Connected := aValue;
end;

constructor TOrionORMDBConnectionFiredacSQLite.Create;
begin
  FDBConnection := TFDConnection.Create(nil);
  FDBConnection.UpdateOptions.AutoCommitUpdates := False;
  FDBConnection.Params.DriverID := 'SQLite';
  FDBConnection.Params.AddPair('LockingMode', 'Normal');
  FDriverLink := TFDPhysSQLiteDriverLink.Create(nil);
end;

destructor TOrionORMDBConnectionFiredacSQLite.Destroy;
begin
  if FDBConnection.InTransaction then
    FDBConnection.Rollback;
  FDBConnection.Connected := False;
  FDBConnection.DisposeOf;
  FDriverLink.DisposeOf;
  inherited;
end;

function TOrionORMDBConnectionFiredacSQLite.IsConnected: boolean;
begin
  Result := FDBConnection.COnnected;
end;

function TOrionORMDBConnectionFiredacSQLite.InTransaction: boolean;
begin
  Result := FDBConnection.InTransaction;
end;

class function TOrionORMDBConnectionFiredacSQLite.New: iDBConnection;
begin
  Result := Self.Create;
end;

function TOrionORMDBConnectionFiredacSQLite.NewDataset: iDataset;
begin
  Result := TFiredacQuery.New(Self);
end;

function TOrionORMDBConnectionFiredacSQLite.Password: string;
begin
  Result := FDBConnection.Params.Password;
end;

procedure TOrionORMDBConnectionFiredacSQLite.Password(aValue: string);
begin
  FDBConnection.Params.Password := aValue;
end;

procedure TOrionORMDBConnectionFiredacSQLite.Path(aValue: string);
begin
  FDBConnection.Params.Database := aValue;
end;

function TOrionORMDBConnectionFiredacSQLite.Path: string;
begin
  Result := FDBConnection.Params.Database;
end;

procedure TOrionORMDBConnectionFiredacSQLite.Port(aValue: integer);
begin
  if FDBConnection.Params.IndexOf('Port') > 0 then
    FDBConnection.Params.Values['Port'] := aValue.ToString
  else
    FDBConnection.Params.AddPair('Port', aValue.ToString);
end;

function TOrionORMDBConnectionFiredacSQLite.Port: integer;
begin
  Result := 0;
  if FDBConnection.Params.IndexOf('Port') > 0 then
    Result := FDBConnection.Params.Values['Port'].ToInteger;
end;

procedure TOrionORMDBConnectionFiredacSQLite.RollBack;
begin
  FDBConnection.Rollback;
end;

procedure TOrionORMDBConnectionFiredacSQLite.Server(aValue: string);
begin
  if FDBConnection.Params.IndexOf('Server') > 0 then
    FDBConnection.Params.Values['Server'] := aValue
  else
    FDBConnection.Params.AddPair('Server', aValue);
end;

function TOrionORMDBConnectionFiredacSQLite.Server: string;
begin
  if FDBConnection.Params.IndexOf('Server') > 0 then
    Result := FDBConnection.Params.Values['Server'];
end;

procedure TOrionORMDBConnectionFiredacSQLite.StartTransaction;
begin
  FDBConnection.StartTransaction;
end;

function TOrionORMDBConnectionFiredacSQLite.Username: string;
begin
  Result := FDBConnection.Params.UserName;
end;

procedure TOrionORMDBConnectionFiredacSQLite.Username(aValue: string);
begin
  FDBConnection.Params.UserName := aValue;
end;

end.
