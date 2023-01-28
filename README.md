# Orion-ORM
ORM simples para realizar operações de leitura/escrita através de linhas de comandos. 

<b>Pouco invasivo</b> Projetado para ser o menos invasível possível em sua arquitetura, o mapeamento é feito através de escrita de comandos, ao invés de mapeamento via Custom Attributes, diminuindo assim o acomplamento entre as units do seu projeto.

<b>Mestre-Detalhe</b> Suporte a mapeamentos de objetos que contenham mestre-detalhe.

<b>Paginação dos dados</b> Suporte a paginação dos dados.

<b>Drivers de conexão interfaceados</b> A conexão com o banco é configurada através da interface IDBConnection, tornando possível a utilização de qualquer driver que você esteja familiarizado (atualmente, apenas o driver FireDAC tem classes implementadas, podendo trabalhar com os bancos de dados SQLite e Firebird).

## Instalação

Para instalar basta registrar no library patch do delphi o caminho da pasta src da biblioteca ou utilizar o Boss (https://github.com/HashLoad/boss) para facilitar ainda mais, executando o comando

```
boss install https://github.com/ricardo-pontes/orion-orm
```

## Como utilizar

É necessário adicionar ao uses do seu formulário as units:

```
Orion.ORM.Interfaces,
Orion.ORM,
Orion.ORM.Types,
Orion.ORM.Mapper;
```

Em seguinda, instanciar uma variável do tipo iOrionORM<T> passando como parâmetro uma conexão configurada com o banco de dados.
```
FConexao := TOrionORMDBConnectionFiredacSQLite.New;
ConfigurarConexao;
FOrionORM := TOrionORM<TPessoa>.New(FConexao);
```

Após isso, basta fazer o mapeamento das properties da classe, utilizando a classe de mapeamento TOrionORMMapper;
```
Mapper := TOrionORMMapper.Create;
//O primeiro parâmetro é o nome da property, o segundo é o nome do campo, e o terceiro são constraints definindo que o campo é Primary Key e Auto-incremento
Mapper.Add('ID', 'PES_ID', [PK, AutoInc]);
Mapper.Add('Nome', 'PES_NOME');
Mapper.Add('SobreNome', 'PES_SOBRENOME');
FOrionORM.Mapper(Mapper);
```
Agora o ORM está apto para fazer as leituras/escritas no banco de dados.

### Busca dos dados
Para buscar apenas um registro no banco de dados, basta usar o comando FindOne
```
Pessoa := FOrionORM.FindOne(1);
```
O método FindOne por padrão recebe valores do tipo inteiro, mas também tem a opção de receber filtros personalizados de acordo com a sua necessidade, caso o atributo chave seja de um tipo diferente bastando apenas utilizar o record TOrionORMFilter
```
  var Filter : TOrionORMFilter;
  Filter := Format('NCONTROLE = %s', [aNControle.QuotedString]);
  Pessoa := FOrionORM.FindOne(Filter);
```
 Para buscar uma coleção de registros no banco de dados, basta utilizar o comando FindMany
```
  Pessoas := FOrionORM.FindMany(Format('PES_NOME LIKE ', ['ric']));
```  
### Salvar os dados
Para salvar no banco de dados, basta apenas utilizar o método Save
```
FOrionORM.Save(Pessoa);
```
### Deletar dados
Para deletar dados, basta utilizar o método Delete
```
FOrionORM.Delete(1);
``` 
Também é possível passar filtro personalizado para deletar
```
var Filter : TOrionORMFilter;
Filter := Format('NCONTROLE = %s', [aNControle.QuotedString]);
FOrionORM.Delete(Filter);
```
