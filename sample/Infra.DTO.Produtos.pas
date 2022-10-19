unit Infra.DTO.Produtos;

interface

uses
  System.Generics.Collections;

type
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

implementation

{ TProdutoDTO }

constructor TProdutoDTO.Create;
begin
  FComposicao := TObjectList<TProdutoComposicaoDTO>.Create;
end;

destructor TProdutoDTO.Destroy;
begin
  FComposicao.DisposeOf;
  inherited;
end;

end.
