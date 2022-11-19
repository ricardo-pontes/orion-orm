unit Orion.ORM.Criteria;

interface

uses
  System.SysUtils,
  Orion.ORM.Types,
  Orion.ORM.Mapper,
  System.Rtti;

type
  TOrionORMCriteria<T : class, constructor> = class
  private

  public
    procedure BuildFindStatement(Statement: TStringBuilder; aFilter: TOrionORMFilter; aMapper : TOrionORMMapper);
    procedure BuildSaveStatement(aStatement: TStringBuilder; aDataObject : T; aMapper: TOrionORMMapper);
    procedure BuildSaveManyStatement(aStatement: TStringBuilder; aMapper : TOrionORMMapper; aRttiProperty: TRttiProperty; aFKValue : string);
    procedure BuildDeleteStatement(Statement: TStringBuilder; aID: string; aMapper : TOrionORMMapper; aPropertyName : string);
  end;

implementation

uses
  Orion.ORM.Rtti;

{ TOrionORMCriteria }

procedure TOrionORMCriteria<T>.BuildDeleteStatement(Statement: TStringBuilder; aID: string; aMapper: TOrionORMMapper;
  aPropertyName: string);
begin
  Statement.AppendFormat('delete from %s ', [aMapper.TableName]);
  Statement.AppendFormat(' where %s = %s', [aMapper.GetDatasetFieldName(aPropertyName), aID.QuotedString]);
end;

procedure TOrionORMCriteria<T>.BuildFindStatement(Statement: TStringBuilder; aFilter: TOrionORMFilter;
  aMapper: TOrionORMMapper);
var
  isNotFirstFieldName: Boolean;
  I: Integer;
  lJoin: string;
begin
  isNotFirstFieldName := False;
  Statement.Append('select ');
  for I := 0 to Pred(aMapper.Values.Count) do
  begin
    if not Assigned(aMapper.Values[I].Mapper) then
      Statement.Append(aMapper.Values[I].FieldName + ', ');
  end;
  Statement.Remove(Pred(Statement.Length)-1, 1);
  Statement.Append(' from ' + aMapper.TableName);
  for lJoin in aMapper.Joins do
  begin
    Statement.Append(lJoin);
  end;

  if not aFilter.Filter.IsEmpty then
    Statement.Append(' where ' + aFilter.Filter);

  if not aMapper.OrderBy.IsEmpty then
    Statement.Append(' order by ' + aMapper.OrderBy);
end;

procedure TOrionORMCriteria<T>.BuildSaveManyStatement(aStatement: TStringBuilder;aMapper : TOrionORMMapper; aRttiProperty: TRttiProperty;
  aFKValue: string);
var
  Where : string;
begin
  Where := '';
  aStatement.Append('select * ');
  aStatement.AppendFormat(' from %s',  [aMapper.TableName]);
//  case aRttiProperty.PropertyType.TypeKind of
//    tkInteger, tkInt64: begin
//      Where := Format(' where %s = %s', [aMapper.GetDatasetFieldName(aMapper.GetFKPropertyName), aFKValue])
//    end;
//    tkChar, tkString, tkWChar, tkLString, tkWString, tkUString: begin
//      Where := Format(' where %s = %s', [aMapper.GetDatasetFieldName(aMapper.GetFKPropertyName), aFKValue.QuotedString]);
//    end;
//  end;
  Where := Format(' where %s = %s', [aMapper.GetDatasetFieldName(aMapper.GetFKPropertyName), aFKValue.QuotedString]);
  if not Where.IsEmpty then
    aStatement.Append(Where);
end;

procedure TOrionORMCriteria<T>.BuildSaveStatement(aStatement: TStringBuilder; aDataObject: T; aMapper: TOrionORMMapper);
var
  MapperValue : TOrionORMMapperValue;
  Constraint : TOrionORMMapperConstraint;
  RttiContext : TRttiContext;
  RttiType : TRttiType;
  RttiProperty : TRttiProperty;
  Where : string;
begin
  RttiContext := TRttiContext.Create;
  RttiType := RttiContext.GetType(aDataObject.ClassInfo);

  try
    aStatement.Append('select * ');
    aStatement.AppendFormat(' from %s', [aMapper.TableName]);
    RttiProperty := RttiType.GetProperty(aMapper.GetPKPropertyName);
    if isEmptyProperty(RttiProperty, Pointer(aDataObject)) then
      Where := ' where 1 <> 1'
    else begin
      case RttiProperty.PropertyType.TypeKind of
        tkInteger: Where := ' where ' + aMapper.GetDatasetFieldName(RttiProperty.Name) + ' = ' + RttiProperty.GetValue(Pointer(aDataObject)).ToString;

        tkChar, tkString, tkWChar, tkLString, tkWString, tkUString: begin
          Where := ' where ' + aMapper.GetDatasetFieldName(RttiProperty.Name) + ' = ' + RttiProperty.GetValue(Pointer(aDataObject)).ToString.QuotedString;
        end;

        tkInt64: Where := ' where ' + aMapper.GetDatasetFieldName(RttiProperty.Name) + ' = ' + RttiProperty.GetValue(Pointer(aDataObject)).ToString;
      end;
    end;


    aStatement.Append(Where);
  finally
    RttiType.DisposeOf;
  end;
end;

end.
