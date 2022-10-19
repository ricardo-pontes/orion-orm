unit Orion.ORM.DBConnection.FireDAC.Query;

interface

uses
  Orion.ORM.Interfaces,
  System.SysUtils,
  System.DateUtils,
  Data.DB,
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
  {$IFDEF FMX}
    FireDAC.FMXUI.Wait,
  {$ELSEIFDEF VCL}
    FireDAC.VCLUI.Wait,
  {$ELSE}
    FireDAC.ConsoleUI.Wait,
  {$ENDIF}
  FireDAC.Comp.UI,
  FireDAC.Phys.IBBase,
  FireDAC.Phys.FB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  System.Classes;
type
  TFiredacQuery = class(TInterfacedObject, iDataset)
  private
    [weak]
    FConexao : iDBConnection;
    FDBQuery : TFDQuery;
  public
    constructor Create(aValue : iDBConnection);
    destructor Destroy; override;
    class function New(aValue : iDBConnection) : iDataset;

    procedure Conexao(aValue : iDBConnection);
    function RecordCount : integer;
    function FieldByName(aValue : string) : TField;
    function FieldExist(aFieldName : string) : boolean;
    function Fields : TFields;
    procedure Statement(aValue : string);
    procedure Open;
    procedure Append;
    procedure Edit;
    procedure Post;
    procedure Delete;
    procedure ExecSQL;
    procedure Next;
    procedure First;
    function Locate(const AKeyFields: string; const AKeyValues: Variant; AOptions: TLocateOptions = []): Boolean;
    function Dataset : TDataset;
    function Eof : boolean;
  end;

implementation

{ TFiredacQuery }
procedure TFiredacQuery.Append;
begin
  FDBQuery.Append;
end;

procedure TFiredacQuery.Conexao(aValue: iDBConnection);
begin
  FDBQuery.Connection := aValue.Component as TFDCustomConnection;
end;

constructor TFiredacQuery.Create(aValue : iDBConnection);
begin
  FDBQuery := TFDQuery.Create(nil);
  FConexao := aValue;
  FDBQuery.Connection := FConexao.Component as TFDCustomConnection;
end;

function TFiredacQuery.Dataset: TDataset;
begin
  Result := FDBQuery;
end;

procedure TFiredacQuery.Delete;
begin
  FDBQuery.Delete;
end;

destructor TFiredacQuery.Destroy;
begin
  FDBQuery.DisposeOf;
  inherited;
end;

procedure TFiredacQuery.Edit;
begin
  FDBQuery.Edit;
end;

function TFiredacQuery.Eof: boolean;
begin
  Result := FDBQuery.Eof;
end;

procedure TFiredacQuery.ExecSQL;
begin
  FDBQuery.ExecSQL;
end;

function TFiredacQuery.FieldByName(aValue: string): TField;
begin
  Result := FDBQuery.FieldByName(aValue);
end;

function TFiredacQuery.FieldExist(aFieldName: string): boolean;
var
  lField : TField;
begin
  lField := FDBQuery.FindField(aFieldName);
  Result := Assigned(lField);
end;

function TFiredacQuery.Fields: TFields;
begin
  Result := FDBQuery.Fields;
end;

procedure TFiredacQuery.First;
begin
  FDBQuery.First;
end;

function TFiredacQuery.Locate(const AKeyFields: string; const AKeyValues: Variant; AOptions: TLocateOptions): Boolean;
begin
  Result := FDBQuery.Locate(aKeyFields, aKeyValues, aOptions);
end;

class function TFiredacQuery.New(aValue : iDBConnection) : iDataset;
begin
  Result := Self.Create(aValue);
end;

procedure TFiredacQuery.Next;
begin
  FDBQuery.Next;
end;

procedure TFiredacQuery.Open;
begin
  FDBQuery.Open();
end;

procedure TFiredacQuery.Post;
begin
  FDBQuery.Post;
end;

function TFiredacQuery.RecordCount: integer;
begin
  Result := FDBQuery.RecordCount;
end;

procedure TFiredacQuery.Statement(aValue: string);
begin
  FDBQuery.SQL.Text := aValue;
end;

end.
