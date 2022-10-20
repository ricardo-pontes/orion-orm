unit MainForm.View;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  Infra.DTO.Produtos,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo,
  FireDAC.UI.Intf,
  FireDAC.FMXUI.Wait,
  FireDAC.Stan.Intf,
  FireDAC.Comp.UI,
  FMX.Edit,
  Orion.ORM.Interfaces,
  Orion.ORM,
  Orion.ORM.DBConnection.FireDAC.SQLite,
  Orion.ORM.Mapper,
  Orion.ORM.Types,
  Orion.Json.Helper,
  Orion.Bindings.Interfaces,
  Orion.Bindings,
  Orion.Bindings.VisualFrameworks.FMX.Native,
  FMX.TabControl, FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.Layouts;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Button3: TButton;
    Button5: TButton;
    TabControl1: TTabControl;
    TabItem2: TTabItem;
    EditID: TEdit;
    Label1: TLabel;
    EditDescricao: TEdit;
    Label2: TLabel;
    EditDescricaoDetalhada: TEdit;
    Label3: TLabel;
    EditEmbalagem: TEdit;
    Label4: TLabel;
    EditPrecoCusto: TEdit;
    Label5: TLabel;
    EditPrecoVenda: TEdit;
    Label6: TLabel;
    ListView1: TListView;
    Memo1: TMemo;
    GroupBox1: TGroupBox;
    Layout1: TLayout;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Button6: TButton;
    Button4: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure ListView1ItemClickEx(const Sender: TObject; ItemIndex: Integer; const LocalClickPos: TPointF;
      const ItemObject: TListItemDrawable);
    procedure Button4Click(Sender: TObject);
  private
    FOrionORM : iOrionORM<TProdutoDTO>;
    FOrionBindings : iOrionBindings;
    FProduto : TProdutoDTO;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  System.Generics.Collections;

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
begin
  if Assigned(FProduto) then
    FProduto.DisposeOf;

  FProduto := FOrionORM.FindOne(Edit1.Text.ToInteger);
  FOrionBindings.Entity(FProduto);
  FOrionBindings.BindToView;
  Memo1.Text := FProduto.ToJSONString(True);
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  Produtos : TObjectList<TProdutoDTO>;
begin
  Produtos := FOrionORM.FindMany('');
  try
    Memo1.Text := Produtos.ToJSONString(True);
  finally
    if Assigned(Produtos) then
      Produtos.DisposeOf;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Memo1.Lines.Clear;
  Memo1.Lines.Add(FProduto.ToJSONString(True));
  FOrionBindings.Entity(FProduto);
  FOrionBindings.BindToEntity;
  FOrionORM.Save(FProduto);
  Memo1.Lines.Add('=====================================');
  Memo1.Lines.Add(FProduto.ToJSONString(True))
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  if Assigned(FProduto) then
    FProduto.DisposeOf;

  FProduto := FOrionORM.FindOne(Edit1.Text);
  if not Assigned(FProduto) then
    Exit;
  FOrionBindings.Entity(FProduto);
  FOrionBindings.BindToView;
  Memo1.Text := FProduto.ToJSONString(True);
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  FOrionORM.Delete(Edit1.Text.ToInteger);
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  ListViewItem : TListViewItem;
begin
  ListViewItem := ListView1.Items.Add;
  TListItemText(ListViewItem.Objects.FindDrawable('Descricao')).Text := Edit2.Text;
  TListItemText(ListViewItem.Objects.FindDrawable('Embalagem')).Text := Edit3.Text;
  TListItemText(ListViewItem.Objects.FindDrawable('Quantidade')).Text := Edit4.Text;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  DBConnection : iDBConnection;
  MapperProdutos : TOrionORMMapper;
  MapperProdutosComposicao : TOrionORMMapper;
  MapperTeste : TOrionORMMapper;
begin
  FOrionBindings := TOrionBindings.New;
  FOrionBindings.Use(TOrionBindingsMiddlewaresFMXNative.New);
  FOrionBindings.View(Self);
  FOrionBindings.AddBind('EditID', 'ID');
  FOrionBindings.AddBind('EditDescricao', 'Descricao');
  FOrionBindings.AddBind('EditDescricaoDetalhada', 'DescricaoDetalhada');
  FOrionBindings.AddBind('EditEmbalagem', 'Embalagem');
  FOrionBindings.AddBind('EditPrecoCusto', 'PrecoCusto');
  FOrionBindings.AddBind('EditPrecoVenda', 'PrecoVenda');

  FOrionBindings.ListBinds.Init();
  FOrionBindings.ListBinds.ComponentName('ListView1');
  FOrionBindings.ListBinds.ObjectListPropertyName('Composicao');
  FOrionBindings.ListBinds.Primarykey('ID');
  FOrionBindings.ListBinds.ClassType(TProdutoComposicaoDTO);
  FOrionBindings.ListBinds.AddListBind('ID', 'ID');
  FOrionBindings.ListBinds.AddListBind('Descricao', 'Descricao');
  FOrionBindings.ListBinds.AddListBind('Embalagem', 'Embalagem');
  FOrionBindings.ListBinds.AddListBind('Quantidade', 'Quantidade');
  FOrionBindings.ListBinds.Finish;

  MapperProdutosComposicao := TOrionORMMapper.Create;
  MapperProdutosComposicao.TableName := 'PRODUTOS_COMPOSICAO';
  MapperProdutosComposicao.Add('ID', 'PROD_COMP_ID', [PK, AutoInc]);
  MapperProdutosComposicao.Add('IDProduto', 'PROD_COMP_ID_PRODUTO', [FK]);
  MapperProdutosComposicao.Add('Descricao', 'PROD_COMP_DESCRICAO');
  MapperProdutosComposicao.Add('Embalagem', 'PROD_COMP_EMBALAGEM');
  MapperProdutosComposicao.Add('Quantidade', 'PROD_COMP_QUANTIDADE');

  MapperProdutos := TOrionORMMapper.Create;
  MapperProdutos.TableName := 'PRODUTOS';
  MapperProdutos.Add('ID', 'ID', [PK, AutoInc]);
  MapperProdutos.Add('Descricao', 'DESCRICAO');
  MapperProdutos.Add('DescricaoDetalhada', 'DESCRICAO_DETALHADA');
  MapperProdutos.Add('Embalagem', 'EMBALAGEM');
  MapperProdutos.Add('PrecoCusto', 'PRECO_CUSTO');
  MapperProdutos.Add('PrecoVenda', 'PRECO_VENDA');
  MapperProdutos.Add('TipoProduto', 'TIPO_PRODUTO');
  MapperProdutos.Add('Ativo', 'ATIVO');
  MapperProdutos.Add('VisivelCardapio', 'VISIVEL_CARDAPIO');
  MapperProdutos.Add('VisivelComposicao', 'VISIVEL_COMPOSICAO');
  MapperProdutos.Add('Composicao', MapperProdutosComposicao);

  TOrionORMMapperManager.Add('Produtos', MapperProdutos);
  TOrionORMMapperManager.Add('ProdutosComposicao', MapperProdutos);

  DBConnection := TOrionORMDBConnectionFiredacSQLite.New;
  DBConnection.Configurations('E:\Projetos\Orion-ORM\sample\OrionEats.sqlite3', '', '', '', 0);
  DBConnection.Connected(True);

  FOrionORM := TOrionORM<TProdutoDTO>.Create(DBConnection);
  FOrionORM.Mapper(MapperProdutos);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(FProduto) then
    FProduto.DisposeOf;
end;

procedure TForm1.ListView1ItemClickEx(const Sender: TObject; ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
  if not Assigned(ItemObject) then
    Exit;

  if ItemObject.Name = 'Deletar' then begin
    ListView1.Items.Delete(ItemIndex);
  end;
end;

end.
