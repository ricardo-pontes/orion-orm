unit AllDelivery.Utilitarios;

interface

uses
  DBXJSON,
  DBXJSONReflect,
  Rest.Json,
  System.JSON;

type
  iUtilitariosValidacoes = interface
    ['{86CBAFFB-C2B4-400E-8870-48720C4DD0AD}']
    function IsEmailValido(aEmail : string) : boolean;
    function IsTelefoneValido(aTelefone : string) : boolean;
    function IsCelularValido(aCelular : string) : boolean;
    function IsSenhaValida(aValue : string) : boolean;
    function isCNPJValido(aValue : string) : boolean;
    function isCPFValido(aValue : string) : boolean;
    function ClonarObjeto(aSource : TObject) : TObject;
  end;

  TUtilitarios = class
    function ClonarObjeto<T : class, constructor>(aSource : TObject) : T; overload;
    function ClonarObject(aSource : TObject) : TObject; overload;
  end;
  TUtilitariosValidacoes = class(TInterfacedObject, iUtilitariosValidacoes)
  private

  public
    constructor Create;
    destructor Destroy; override;
    class function New : iUtilitariosValidacoes;

    function IsEmailValido(aEmail : string) : boolean;
    function IsTelefoneValido(aTelefone : string) : boolean;
    function IsCelularValido(aCelular : string) : boolean;
    function IsSenhaValida(aValue : string) : boolean;
    function isCNPJValido(aValue : string) : boolean;
    function isCPFValido(aValue : string) : boolean;
    function ClonarObjeto(aSource : TObject) : TObject;
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  System.Math,
  System.RegularExpressions;

{ TUtilitariosValidacoes }

function TUtilitariosValidacoes.ClonarObjeto(aSource: TObject): TObject;
begin
  Result := nil;
  var lJSON := tjson.ObjectToJsonObject(aSource);
  try
  if Assigned(lJSON) then
    Result := TJson.JsonToObject<TObject>(lJSON);

  finally
    if Assigned(lJSON) then
      lJSON.DisposeOf;
  end;
//var
//  MarshalObj: TJSONMarshal;
//  UnMarshalObj: TJSONUnMarshal;
//  JSONValue: TJSONValue;
//begin
//  Result:= nil;
//  MarshalObj := TJSONMarshal.Create;
//  UnMarshalObj := TJSONUnMarshal.Create;
//  try
//    JSONValue := MarshalObj.Marshal(aSource);
//    try
//      if Assigned(JSONValue) then
//      begin
//        var lObject := UnMarshalObj.Unmarshal(JSONValue);
//        Result:= lObject;
//      end;
//    finally
//      JSONValue.Free;
//    end;
//  finally
//    MarshalObj.Free;
//    UnMarshalObj.Free;
//  end;
end;

constructor TUtilitariosValidacoes.Create;
begin

end;

destructor TUtilitariosValidacoes.Destroy;
begin

  inherited;
end;

function TUtilitariosValidacoes.IsCelularValido(aCelular : string) : boolean;
begin
  Result := TRegEx.IsMatch(aCelular, '^[0-9]{11}');
end;

function TUtilitariosValidacoes.isCNPJValido(aValue: string): boolean;
var
  v: array[1..2] of Word;
  cnpj: array[1..14] of Byte;
  I: Byte;
begin
  Result := False;
  { Conferindo se todos dígitos são iguais }
  if aValue = StringOfChar('0', 14) then
    Exit;

  if aValue = StringOfChar('1', 14) then
    Exit;

  if aValue = StringOfChar('2', 14) then
    Exit;

  if aValue = StringOfChar('3', 14) then
    Exit;

  if aValue = StringOfChar('4', 14) then
    Exit;

  if aValue = StringOfChar('5', 14) then
    Exit;

  if aValue = StringOfChar('6', 14) then
    Exit;

  if aValue = StringOfChar('7', 14) then
    Exit;

  if aValue = StringOfChar('8', 14) then
    Exit;

  if aValue = StringOfChar('9', 14) then
    Exit;

  try
    for I := 1 to 14 do
      cnpj[i] := StrToInt(aValue[i]);

    //Nota: Calcula o primeiro dígito de verificação.
    v[1] := 5*cnpj[1] + 4*cnpj[2]  + 3*cnpj[3]  + 2*cnpj[4];
    v[1] := v[1] + 9*cnpj[5] + 8*cnpj[6]  + 7*cnpj[7]  + 6*cnpj[8];
    v[1] := v[1] + 5*cnpj[9] + 4*cnpj[10] + 3*cnpj[11] + 2*cnpj[12];
    v[1] := 11 - v[1] mod 11;
    v[1] := IfThen(v[1] >= 10, 0, v[1]);

    //Nota: Calcula o segundo dígito de verificação.
    v[2] := 6*cnpj[1] + 5*cnpj[2]  + 4*cnpj[3]  + 3*cnpj[4];
    v[2] := v[2] + 2*cnpj[5] + 9*cnpj[6]  + 8*cnpj[7]  + 7*cnpj[8];
    v[2] := v[2] + 6*cnpj[9] + 5*cnpj[10] + 4*cnpj[11] + 3*cnpj[12];
    v[2] := v[2] + 2*v[1];
    v[2] := 11 - v[2] mod 11;
    v[2] := IfThen(v[2] >= 10, 0, v[2]);

    //Nota: Verdadeiro se os dígitos de verificação são os esperados.
    Result := ((v[1] = cnpj[13]) and (v[2] = cnpj[14]));
  except on E: Exception do
    Result := False;
  end;
end;

function TUtilitariosValidacoes.isCPFValido(aValue: string): boolean;
var
  v: array [0 .. 1] of Word;
  cpf: array [0 .. 10] of Byte;
  I: Byte;
begin
  Result := False;

  { Conferindo se todos dígitos são iguais }
  if aValue = StringOfChar('0', 11) then
    Exit;

  if aValue = StringOfChar('1', 11) then
    Exit;

  if aValue = StringOfChar('2', 11) then
    Exit;

  if aValue = StringOfChar('3', 11) then
    Exit;

  if aValue = StringOfChar('4', 11) then
    Exit;

  if aValue = StringOfChar('5', 11) then
    Exit;

  if aValue = StringOfChar('6', 11) then
    Exit;

  if aValue = StringOfChar('7', 11) then
    Exit;

  if aValue = StringOfChar('8', 11) then
    Exit;

  if aValue = StringOfChar('9', 11) then
    Exit;

  try
    for I := 1 to 11 do
      cpf[I - 1] := StrToInt(aValue[I]);
    // Nota: Calcula o primeiro dígito de verificação.
    v[0] := 10 * cpf[0] + 9 * cpf[1] + 8 * cpf[2];
    v[0] := v[0] + 7 * cpf[3] + 6 * cpf[4] + 5 * cpf[5];
    v[0] := v[0] + 4 * cpf[6] + 3 * cpf[7] + 2 * cpf[8];
    v[0] := 11 - v[0] mod 11;
    v[0] := IfThen(v[0] >= 10, 0, v[0]);
    // Nota: Calcula o segundo dígito de verificação.
    v[1] := 11 * cpf[0] + 10 * cpf[1] + 9 * cpf[2];
    v[1] := v[1] + 8 * cpf[3] + 7 * cpf[4] + 6 * cpf[5];
    v[1] := v[1] + 5 * cpf[6] + 4 * cpf[7] + 3 * cpf[8];
    v[1] := v[1] + 2 * v[0];
    v[1] := 11 - v[1] mod 11;
    v[1] := IfThen(v[1] >= 10, 0, v[1]);
    // Nota: Verdadeiro se os dígitos de verificação são os esperados.
    Result := ((v[0] = cpf[9]) and (v[1] = cpf[10]));
  except
    on E: Exception do
      Result := False;
  end;

end;

function TUtilitariosValidacoes.IsEmailValido(aEmail : string) : boolean;
begin
  Result := not aEmail.IsEmpty;
end;

function TUtilitariosValidacoes.IsSenhaValida(aValue : string) : boolean;
begin
  Result := TRegEx.IsMatch(aValue, '^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[$*&@#])(?:([0-9a-zA-Z$*&@#])(?!\1)){8,}$');
end;

function TUtilitariosValidacoes.IsTelefoneValido(aTelefone : string) : boolean;
begin
  Result := TRegEx.IsMatch(aTelefone, '^[1-9]{10}');
end;

class function TUtilitariosValidacoes.New: iUtilitariosValidacoes;
begin
  Result := Self.Create;
end;

{ TUtilitarios }

function TUtilitarios.ClonarObject(aSource: TObject): TObject;
var
  MarshalObj: TJSONMarshal;
  UnMarshalObj: TJSONUnMarshal;
  JSONValue: TJSONValue;
begin
  Result:= nil;
  MarshalObj := TJSONMarshal.Create;
  UnMarshalObj := TJSONUnMarshal.Create;
  try
    JSONValue := MarshalObj.Marshal(aSource);
    try
      if Assigned(JSONValue) then
      begin
        var lObject := UnMarshalObj.Unmarshal(JSONValue);
        Result:= lObject;
      end;
    finally
      JSONValue.Free;
    end;
  finally
    MarshalObj.Free;
    UnMarshalObj.Free;
  end;
end;

function TUtilitarios.ClonarObjeto<T>(aSource: TObject): T;
begin
  Result := nil;
  var lJSON := tjson.ObjectToJsonObject(aSource);
  try
  if Assigned(lJSON) then
    Result := TJson.JsonToObject<T>(lJSON);

  finally
    if Assigned(lJSON) then
      lJSON.DisposeOf;
  end;
end;

end.
