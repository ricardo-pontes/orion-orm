unit Core.Entidades.Produtos;

interface

uses
  Infra.DTO.Produtos,
  Core.Entidades.Types,
  System.SysUtils,
  System.Generics.Collections;

type
  TProdutoComposicao = class;
  {$SCOPEDENUMS ON}
  TTipoProduto  = (Nenhum, Simples, Composto);
  {$SCOPEDENUMS OFF}

  TProduto = class
  strict private
    FID: integer;
    FDescricao: string;
    FDescricaoDetalhada: string;
    FEmbalagem: string;
    FPrecoCusto : TExtended;
    FPrecoVenda : TExtended;
    FAtivo : TAtivo;
    FTipoProduto : TTipoProduto;
    FVisivelComposicao : boolean;
    FVisivelCardapio : boolean;
    FComposicao : TObjectList<TProdutoComposicao>;
  public
    constructor Create(aData : TProdutoDTO);
    destructor Destroy; override;

    function IsIDVazio : boolean;
    function IsDescricaoValida : boolean;
    function isEmbalagemValida : boolean;
    function IsPrecoVendaValido : boolean;
    function IsStatusValido : boolean;
    function IsTipoProdutoValido : boolean;
    function isComposicao : boolean;
    function OutPutRepository : TProdutoDTO; virtual;
  end;

  TProdutoComposicao = class
  strict private
    FID : integer;
    FDescricao : string;
    FEmbalagem : string;
    FQuantidade : TExtended;
  public
    constructor Create(aDados : TProdutoComposicaoDTO);
    destructor Destroy; override;

    function isDescricaoValida : boolean;
    function isEmbalagemValida : boolean;
    function isQuantidadeValida : boolean;
    function OutPutRepository : TProdutoComposicaoDTO;
  end;

  TProdutoInserir = class(TProduto)
    constructor Create(aData : TProdutoDTO);

  end;

  TProdutoAlterar = class(TProduto)
    constructor Create(aData : TProdutoDTO);
  end;

implementation

uses
  Infra.Exceptions;

function TipoProdutoToTTipoProduto(aValue : string) : TTipoProduto;
begin
  if aValue = 'Simples' then
    Result := TTIpoProduto.Simples
  else if aValue = 'Composto' then
    Result := TTIpoProduto.Composto
  else
    Result := TTipoProduto.Nenhum;
end;

function TTipoProdutoToTipoProduto(aValue : TTipoProduto) : string;
begin
  case aValue of
    TTipoProduto.Nenhum: Result := '';
    TTipoProduto.Simples: Result := 'Simples';
    TTipoProduto.Composto: Result := 'Composto';
  end;
end;

{ TProduto }

constructor TProduto.Create(aData: TProdutoDTO);
var
  lComposicaoDTO : TProdutoComposicaoDTO;
  lComposicao : TProdutoComposicao;
begin
  if not Assigned(aData) then
    raise ExceptionDTONaoInformado.Create(Self.ClassName + '.Create: DTO não informado.');

  FPrecoCusto := TExtended.Create;
  FPrecoVenda := TExtended.Create;
  FComposicao := TObjectList<TProdutoComposicao>.Create;

  FID := aData.ID;
  FDescricao := aData.Descricao;
  FDescricaoDetalhada := aData.DescricaoDetalhada;
  FEmbalagem := aData.Embalagem;
  FPrecoCusto.Value := aData.PrecoCusto;
  FPrecoVenda.Value := aData.PrecoVenda;
  FAtivo := AtivoToTAtivo(aData.Ativo);
  FTipoProduto := TipoProdutoToTTipoProduto(aData.TipoProduto);
  FVisivelComposicao := aData.VisivelComposicao;
  FVisivelCardapio := aData.VisivelCardapio;

  for lComposicaoDTO in aData.Composicao do begin
    lComposicao := TProdutoComposicao.Create(lComposicaoDTO);
    FComposicao.Add(lComposicao);
  end;
end;

destructor TProduto.Destroy;
begin
  FPrecoCusto.DisposeOf;
  FPrecoVenda.DisposeOf;
  FComposicao.DisposeOf;
  inherited;
end;

function TProduto.isComposicao: boolean;
begin
  Result := FTipoProduto = TTipoProduto.Composto;
end;

function TProduto.IsDescricaoValida: boolean;
begin
  Result := not FDescricao.IsEmpty;
end;

function TProduto.isEmbalagemValida: boolean;
begin
  Result := not FDescricao.IsEmpty;
end;

function TProduto.IsIDVazio: boolean;
begin
  Result := FID = 0;
end;

function TProduto.IsPrecoVendaValido: boolean;
begin
  Result := FPrecoVenda.Value > 0;
end;

function TProduto.IsStatusValido: boolean;
begin
  Result := FAtivo <> TAtivo.Nenhum;
end;

function TProduto.IsTipoProdutoValido: boolean;
begin
  Result := FTipoProduto <> TTipoProduto.Nenhum;
end;

function TProduto.OutPutRepository : TProdutoDTO;
var
  lComposicao : TProdutoComposicao;
  lComposicaoDTO : TProdutoComposicaoDTO;
begin
  Result := TProdutoDTO.Create;
  Result.ID := FID;
  Result.Descricao := FDescricao;
  Result.DescricaoDetalhada := FDescricaoDetalhada;
  Result.Embalagem := FEmbalagem;
  Result.PrecoCusto := FPrecoCusto.Value;
  Result.PrecoVenda := FPrecoVenda.Value;
  Result.Ativo := TAtivoToAtivo(FAtivo);
  Result.TipoProduto := TTipoProdutoToTipoProduto(FTipoProduto);
  Result.VisivelComposicao := FVisivelComposicao;
  Result.VisivelCardapio := FVisivelCardapio;

  for lComposicao in FComposicao do begin
    lComposicaoDTO := lComposicao.OutPutRepository;
    Result.Composicao.Add(lComposicaoDTO);
  end;
end;

{ TProdutoInserir }

constructor TProdutoInserir.Create(aData: TProdutoDTO);
begin
  inherited Create(aData);
end;

{ TProdutoAlterar }

constructor TProdutoAlterar.Create(aData: TProdutoDTO);
begin
  inherited Create(aData);
end;

{ TProdutoComposicao }

constructor TProdutoComposicao.Create(aDados : TProdutoComposicaoDTO);
begin
  if not Assigned(aDados) then
    raise ExceptionDTONaoInformado.Create(Self.ClassName + '.Create: DTO não informado.');

  FQuantidade := TExtended.Create;
  FID := aDados.ID;
  FDescricao := aDados.Descricao;
  FEmbalagem := aDados.Embalagem;
  FQuantidade.Value := aDados.Quantidade;
end;

destructor TProdutoComposicao.Destroy;
begin
  FQuantidade.DisposeOf;
  inherited;
end;

function TProdutoComposicao.isDescricaoValida: boolean;
begin
  Result := not FDescricao.IsEmpty;
end;

function TProdutoComposicao.isEmbalagemValida: boolean;
begin
  Result := not FEmbalagem.IsEmpty;
end;

function TProdutoComposicao.isQuantidadeValida: boolean;
begin
  Result := not FQuantidade.IsEmpty;
end;

function TProdutoComposicao.OutPutRepository: TProdutoComposicaoDTO;
begin
  Result := TProdutoComposicaoDTO.Create;
  Result.ID := FID;
  Result.Descricao := FDescricao;
  Result.Embalagem := FEmbalagem;
  Result.Quantidade := FQuantidade.Value;
end;

end.
