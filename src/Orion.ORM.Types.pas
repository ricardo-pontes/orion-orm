unit Orion.ORM.Types;

interface

uses
  System.SysUtils,
  System.Generics.Collections;

type

  TOrionORMMapperConstraint = (PK, FK, AutoInc, ReadOnly);
  TOrionORMMapperConstraints = set of TOrionORMMapperConstraint;

  TOrionORMMiddleware = procedure of object;


  TOrionORMFilter = record
  strict private
    class var FFilter : string;
  public
    class operator Implicit (aFilter : string) : TOrionORMFilter;
    class function Eq(aFieldName : string; aFieldValue : string) : TOrionORMFilter; static;
    class function Like(aFieldName : string; aFieldValue : string) : TOrionORMFilter; static;
    class function Ne(aFieldName : string; aFieldValue : string) : TOrionORMFilter; static;
    class function Lte(aFieldName : string; aFieldValue : string) : TOrionORMFilter; static;
    class function Lt(aFieldName : string; aFieldValue : string) : TOrionORMFilter; static;
    function Filter : string;
  end;

implementation

{ TOrionORMFilter }

class function TOrionORMFilter.Eq(aFieldName, aFieldValue: string): TOrionORMFilter;
begin
  if FFilter.IsEmpty then
    FFilter := Format('%s = %s', [aFieldName, aFieldValue])
  else
    FFilter := FFilter + Format(' and %s = %s', [aFieldName, aFieldValue]);
end;

function TOrionORMFilter.Filter: string;
begin
  Result := FFilter;
end;

class operator TOrionORMFilter.Implicit(aFilter: string): TOrionORMFilter;
begin
  FFilter := aFilter;
end;

class function TOrionORMFilter.Like(aFieldName, aFieldValue: string): TOrionORMFilter;
begin
  if FFilter.IsEmpty then
    FFilter := Format('%s like %s', [aFieldName, aFieldValue])
  else
    FFilter := FFilter + Format(' and %s like %s', [aFieldName, aFieldValue]);
end;

class function TOrionORMFilter.Lt(aFieldName, aFieldValue: string): TOrionORMFilter;
begin
  if FFilter.IsEmpty then
    FFilter := Format('%s < %s', [aFieldName, aFieldValue])
  else
    FFilter := FFilter + Format(' and %s < %s', [aFieldName, aFieldValue]);
end;

class function TOrionORMFilter.Lte(aFieldName, aFieldValue: string): TOrionORMFilter;
begin
  if FFilter.IsEmpty then
    FFilter := Format('%s <= %s', [aFieldName, aFieldValue])
  else
    FFilter := FFilter + Format(' and %s <= %s', [aFieldName, aFieldValue]);
end;

class function TOrionORMFilter.Ne(aFieldName, aFieldValue: string): TOrionORMFilter;
begin
  if FFilter.IsEmpty then
    FFilter := Format('%s <> %s', [aFieldName, aFieldValue])
  else
    FFilter := FFilter + Format(' and %s <> %s', [aFieldName, aFieldValue]);
end;

end.
