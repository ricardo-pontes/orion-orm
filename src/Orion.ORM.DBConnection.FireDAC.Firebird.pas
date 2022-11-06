unit Orion.ORM.DBConnection.FireDAC.Firebird;

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
  FireDAC.Phys.FBDef,
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
  FireDAC.Phys.FB,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  System.Classes;
type
  TOrionORMDBConnectionFiredacFirebird = class(TInterfacedObject, iDBConnection, iDBConnectionConfigurations)
  private
    FDBConnection : TFDConnection;
    FDriverLink : TFDPhysFBDriverLink;
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
    function Component : TComponent; overload;
    procedure Component(aValue : TComponent); overload;
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

{ TOrionORMDBConnectionFiredacFirebird }
procedure TOrionORMDBConnectionFiredacFirebird.Commit;
begin
  FDBConnection.Commit;
end;

function TOrionORMDBConnectionFiredacFirebird.Component: TComponent;
begin
  Result := FDBConnection;
end;

procedure TOrionORMDBConnectionFiredacFirebird.Configurations(aPath, aUsername, aPassword, aServer: string; aPort: integer);
begin
  FDBConnection.Params.Database := aPath;
  FDBConnection.Params.UserName := aUserName;
  FDBConnection.Params.Password := aPassword;
  if aPort > 0 then
    FDBConnection.Params.AddPair('Port', aPort.ToString);
end;

procedure TOrionORMDBConnectionFiredacFirebird.Component(aValue: TComponent);
begin
  FDBConnection.Assign(aValue);
end;

function TOrionORMDBConnectionFiredacFirebird.Configurations: iDBConnectionConfigurations;
begin
  Result := Self;
end;

procedure TOrionORMDBConnectionFiredacFirebird.Connected(aValue: boolean);
begin
  FDBConnection.Connected := aValue;
end;

constructor TOrionORMDBConnectionFiredacFirebird.Create;
begin
  FDBConnection := TFDConnection.Create(nil);
  FDBConnection.UpdateOptions.AutoCommitUpdates := False;
  FDBConnection.Params.DriverID := 'FB';
  FDriverLink := TFDPhysFBDriverLink.Create(nil);
end;

destructor TOrionORMDBConnectionFiredacFirebird.Destroy;
begin
  if FDBConnection.InTransaction then
    FDBConnection.Rollback;
  FDBConnection.Connected := False;
  FDBConnection.DisposeOf;
  FDriverLink.DisposeOf;
  inherited;
end;

function TOrionORMDBConnectionFiredacFirebird.IsConnected: boolean;
begin
  Result := FDBConnection.COnnected;
end;

function TOrionORMDBConnectionFiredacFirebird.InTransaction: boolean;
begin
  Result := FDBConnection.InTransaction;
end;

class function TOrionORMDBConnectionFiredacFirebird.New: iDBConnection;
begin
  Result := Self.Create;
end;

function TOrionORMDBConnectionFiredacFirebird.NewDataset: iDataset;
begin
  Result := TFiredacQuery.New(Self);
end;

function TOrionORMDBConnectionFiredacFirebird.Password: string;
begin
  Result := FDBConnection.Params.Password;
end;

procedure TOrionORMDBConnectionFiredacFirebird.Password(aValue: string);
begin
  FDBConnection.Params.Password := aValue;
end;

procedure TOrionORMDBConnectionFiredacFirebird.Path(aValue: string);
begin
  FDBConnection.Params.Database := aValue;
end;

function TOrionORMDBConnectionFiredacFirebird.Path: string;
begin
  Result := FDBConnection.Params.Database;
end;

procedure TOrionORMDBConnectionFiredacFirebird.Port(aValue: integer);
begin
  if FDBConnection.Params.IndexOf('Port') > 0 then
    FDBConnection.Params.Values['Port'] := aValue.ToString
  else
    FDBConnection.Params.AddPair('Port', aValue.ToString);
end;

function TOrionORMDBConnectionFiredacFirebird.Port: integer;
begin
  Result := 0;
  if FDBConnection.Params.IndexOf('Port') > 0 then
    Result := FDBConnection.Params.Values['Port'].ToInteger;
end;

procedure TOrionORMDBConnectionFiredacFirebird.RollBack;
begin
  FDBConnection.Rollback;
end;

procedure TOrionORMDBConnectionFiredacFirebird.Server(aValue: string);
begin
  if FDBConnection.Params.IndexOf('Server') > 0 then
    FDBConnection.Params.Values['Server'] := aValue
  else
    FDBConnection.Params.AddPair('Server', aValue);
end;

function TOrionORMDBConnectionFiredacFirebird.Server: string;
begin
  if FDBConnection.Params.IndexOf('Server') > 0 then
    Result := FDBConnection.Params.Values['Server'];
end;

procedure TOrionORMDBConnectionFiredacFirebird.StartTransaction;
begin
  FDBConnection.StartTransaction;
end;

function TOrionORMDBConnectionFiredacFirebird.Username: string;
begin
  Result := FDBConnection.Params.UserName;
end;

procedure TOrionORMDBConnectionFiredacFirebird.Username(aValue: string);
begin
  FDBConnection.Params.UserName := aValue;
end;

end.
