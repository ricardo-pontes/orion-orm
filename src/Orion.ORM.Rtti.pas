unit Orion.ORM.Rtti;

interface

uses
  System.Rtti,
  System.SysUtils,
  System.StrUtils;

type
  ResultEntityPropertyByName = record
    &Property : TRttiProperty;
    Entity : TObject;
  end;

  function GetEntityPropertyByName(aEntityPropertyName: string; aEntity : TObject): ResultEntityPropertyByName;
  function isEmptyProperty(aRttiProperty : TRttiProperty; aEntity : Pointer) : boolean;

implementation

function GetEntityPropertyByName(aEntityPropertyName: string; aEntity : TObject): ResultEntityPropertyByName;
var
  lContext : TRttiContext;
  lType : TRttiType;
  lProperty : TrttiProperty;
  lResult : ResultEntityPropertyByName;
  lStrings : TArray<string>;
  I : integer;
  lObject : TObject;
begin
  lContext := TRttiContext.Create;
  lType := lContext.GetType(aEntity.ClassInfo);
  lResult.Entity := nil;
  lResult.&Property := nil;
  try
    if aEntityPropertyName.Contains('.') then begin
      lStrings := SplitString(aEntityPropertyName, '.');
      for I := 0 to Pred(Length(lStrings)) do begin
        if Assigned(lResult.Entity) then
          lResult := GetEntityPropertyByName(lStrings[i+1], lResult.Entity)
        else
          lResult := GetEntityPropertyByName(lStrings[i], aEntity);
        if lResult.&Property.PropertyType.TypeKind = tkClass then begin
          lObject := lResult.Entity;
          lResult := GetEntityPropertyByName(lStrings[I+1], lObject);
        end;
        if lResult.&Property.Name = lStrings[Pred(Length(lStrings))] then begin
          Result.&Property := lResult.&Property;
          Result.Entity := lResult.Entity;
          Break;
        end;
      end;
    end
    else begin
      lProperty := lType.GetProperty(aEntityPropertyName);
      Result.&Property := lProperty;
      if (lProperty.PropertyType.TypeKind = tkClass) and not (lProperty.GetValue(Pointer(aEntity)).AsObject.ClassName.Contains('TObjectList<')) then
        Result.Entity := lProperty.GetValue(Pointer(aEntity)).AsObject
      else
        Result.Entity := aEntity;
    end;
  finally
//    if not IsCompound then
//      lType.DisposeOf;
  end;
end;

function isEmptyProperty(aRttiProperty : TRttiProperty; aEntity : Pointer) : boolean;
begin
  case aRttiProperty.PropertyType.TypeKind of
    tkUnknown: ;
    tkInteger: Result := aRttiProperty.GetValue(aEntity).AsInteger <= 0;
    tkChar, tkString, tkWChar, tkLString, tkWString, tkUString: begin
      Result := aRttiProperty.GetValue(aEntity).AsString.Trim.IsEmpty;
    end;
    tkInt64: Result := aRttiProperty.GetValue(aEntity).AsInt64 <= 0;
    tkFloat: Result := aRttiProperty.GetValue(aEntity).AsExtended <= 0;
    tkEnumeration: ;
    tkSet: ;
    tkClass: ;
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
end.
