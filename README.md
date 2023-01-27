# Orion-ORM
ORM simples para realizar operações de leitura/escrita através de linhas de comandos. 

<b>Pouco invasivo</b> Projetado para ser o menos invasível possível em sua arquitetura, o mapeamento é feito através de escrita de comandos, ao invés de mapeamento via Custom Attributes, diminuindo assim o acomplamento entre as units do seu projeto.

<b>Mestre-Detalhe</b> Suporte a mapeamentos de objetos que contenham mestre-detalhe.

<b>Paginação dos dados</b> Suporte a paginação dos dados.

<b>Drivers de conexão interfaceados</b> A conexão com o banco é configurada através da interface IDBConnection, tornando possível a utilização de qualquer driver que você esteja familiarizado (atualmente, apenas o driver FireDAC tem uma classe implementada, utilizando o banco de dados SQLite).

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

###Busca dos dados
Para buscar apenas um registro no banco de dados, basta usar o comando FindOne
```
Pessoa := FOrionORM.FindOne(1);
```
