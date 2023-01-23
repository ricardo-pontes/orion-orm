unit Orion.ORM.Pagination.Firebird;

interface

uses
  Orion.ORM.Interfaces;

type
  TOrionORMPaginationFirebird = class(TInterfacedObject, iOrionORMPagination)
  private
    FPageCount : integer;
    FPageIndex : integer;
    FPageSize : integer;
  public
    constructor Create;
    destructor Destroy; override;
    class function New : iOrionORMPagination;

    procedure PageCount(aValue : integer);
    procedure PageIndex(aValue : integer);
    procedure PageSize(aValue : integer);
    function CriteriaResult : string;
  end;

implementation

uses
  System.SysUtils;

{ TOrionORMPaginationFirebird }

constructor TOrionORMPaginationFirebird.Create;
begin

end;

function TOrionORMPaginationFirebird.CriteriaResult: string;
var
  Rows : integer;
  lTo : integer;
begin
  if FPageIndex = 0 then begin
    Rows := 1;
    lTo := FPageSize;
  end
  else if FPageIndex > 0 then begin
    Rows := (FPageIndex * FPageSize) + 1;
    lTo := (Rows + FPageSize) -1;
  end;

  Result := Format(' ROWS %d TO %d', [Rows, lTo]);
end;

destructor TOrionORMPaginationFirebird.Destroy;
begin

  inherited;
end;

class function TOrionORMPaginationFirebird.New: iOrionORMPagination;
begin
  Result := Self.Create;
end;

procedure TOrionORMPaginationFirebird.PageCount(aValue: integer);
begin
  FPageCount := aValue;
end;

procedure TOrionORMPaginationFirebird.PageIndex(aValue: integer);
begin
  FPageIndex := aValue;
end;

procedure TOrionORMPaginationFirebird.PageSize(aValue: integer);
begin
  FPageSize := aValue;
end;

end.
