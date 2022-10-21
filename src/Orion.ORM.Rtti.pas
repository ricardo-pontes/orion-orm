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
  IsCompound : boolean;
begin
  IsCompound := False;
  lContext := TRttiContext.Create;
  lType := lContext.GetType(aEntity.ClassInfo);
  try
    if aEntityPropertyName.Contains('.') then begin
      IsCompound := True;
      lStrings := SplitString(aEntityPropertyName, '.');
      for I := 0 to Pred(Length(lStrings)) do begin
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

end.
