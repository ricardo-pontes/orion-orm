unit Infra.DTO.Produtos;

interface

uses
  System.Generics.Collections;

type
  TGrupoProdutos = class
  private
    FID: integer;
    FDescricao: string;
    FAtivo: Boolean;

  public
    property ID: integer read FID write FID;
    property Descricao: string read FDescricao write FDescricao;
    property Ativo: Boolean read FAtivo write FAtivo;
  end;

  TProdutoComposicaoDTO = class;

  TProdutoDTO = class
  private
    FVisivelCardapio: boolean;
    FVisivelComposicao: boolean;
    FPrecoCusto: Extended;
    FDescricao: string;
    FPrecoVenda: Extended;
    FID: integer;
    FAtivo: boolean;
    FDescricaoDetalhada: string;
    FEmbalagem: string;
    FTipoProduto: string;
    FComposicao: TObjectList<TProdutoComposicaoDTO>;
    FGrupoProdutos: TGrupoProdutos;
  public
    constructor Create;
    destructor Destroy; override;

    property ID : integer read FID write FID;
    property Descricao : string read FDescricao write FDescricao;
    property DescricaoDetalhada : string read FDescricaoDetalhada write FDescricaoDetalhada;
    property Embalagem : string read FEmbalagem write FEmbalagem;
    property PrecoCusto : Extended read FPrecoCusto write FPrecoCusto;
    property PrecoVenda : Extended read FPrecoVenda write FPrecoVenda;
    property Ativo : boolean read FAtivo write FAtivo;
    property TipoProduto : string read FTipoProduto write FTipoProduto;
    property VisivelComposicao : boolean read FVisivelComposicao write FVisivelComposicao;
    property VisivelCardapio : boolean read FVisivelCardapio write FVisivelCardapio;
    property Composicao: TObjectList<TProdutoComposicaoDTO> read FComposicao write FComposicao;
    property GrupoProdutos: TGrupoProdutos read FGrupoProdutos write FGrupoProdutos;
  end;

  TProdutoComposicaoDTO = class
  private
    FDescricao: string;
    FEmbalagem: string;
    FQuantidade: Extended;
    FID: integer;
    FIDProduto: integer;
  public
    property ID: integer read FID write FID;
    property IDProduto: integer read FIDProduto write FIDProduto;
    property Descricao: string read FDescricao write FDescricao;
    property Embalagem: string read FEmbalagem write FEmbalagem;
    property Quantidade: Extended read FQuantidade write FQuantidade;
  end;

  TProdutoComposicaoDTO2 = class;
  TProdutoDTO2 = class
  private
    FVisivelCardapio: boolean;
    FVisivelComposicao: boolean;
    FPrecoCusto: Extended;
    FDescricao: string;
    FPrecoVenda: Extended;
    FID: string;
    FAtivo: boolean;
    FDescricaoDetalhada: string;
    FEmbalagem: string;
    FTipoProduto: string;
    FComposicao: TObjectList<TProdutoComposicaoDTO2>;
    FGrupoProdutos: TGrupoProdutos;
  public
    constructor Create;
    destructor Destroy; override;

    property ID : string read FID write FID;
    property Descricao : string read FDescricao write FDescricao;
    property DescricaoDetalhada : string read FDescricaoDetalhada write FDescricaoDetalhada;
    property Embalagem : string read FEmbalagem write FEmbalagem;
    property PrecoCusto : Extended read FPrecoCusto write FPrecoCusto;
    property PrecoVenda : Extended read FPrecoVenda write FPrecoVenda;
    property Ativo : boolean read FAtivo write FAtivo;
    property TipoProduto : string read FTipoProduto write FTipoProduto;
    property VisivelComposicao : boolean read FVisivelComposicao write FVisivelComposicao;
    property VisivelCardapio : boolean read FVisivelCardapio write FVisivelCardapio;
    property Composicao: TObjectList<TProdutoComposicaoDTO2> read FComposicao write FComposicao;
    property GrupoProdutos: TGrupoProdutos read FGrupoProdutos write FGrupoProdutos;
  end;

  TProdutoComposicaoDTO2 = class
  private
    FDescricao: string;
    FEmbalagem: string;
    FQuantidade: Extended;
    FID: integer;
    FIDProduto: string;
  public
    property ID: integer read FID write FID;
    property IDProduto: string read FIDProduto write FIDProduto;
    property Descricao: string read FDescricao write FDescricao;
    property Embalagem: string read FEmbalagem write FEmbalagem;
    property Quantidade: Extended read FQuantidade write FQuantidade;
  end;

implementation

{ TProdutoDTO }

constructor TProdutoDTO.Create;
begin
  FComposicao := TObjectList<TProdutoComposicaoDTO>.Create;
  FGrupoProdutos := TGrupoProdutos.Create;
end;

destructor TProdutoDTO.Destroy;
begin
  FComposicao.DisposeOf;
  FGrupoProdutos.DisposeOf;
  inherited;
end;

{ TProdutoDTO2 }

constructor TProdutoDTO2.Create;
begin
  FComposicao := TObjectList<TProdutoComposicaoDTO2>.Create;
  FGrupoProdutos := TGrupoProdutos.Create;
end;

destructor TProdutoDTO2.Destroy;
begin
  FComposicao.DisposeOf;
  FGrupoProdutos.DisposeOf;
  inherited;
end;

end.
