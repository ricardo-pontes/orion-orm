unit Orion.ORM.Interfaces;

interface

uses
  SYstem.Generics.Collections,
  System.Classes,
  Data.DB,
  Orion.ORM.Types,
  Orion.ORM.Mapper;

type
  iOrionORMPagination = interface;

  iOrionORM<T:class, constructor> = interface
    ['{3ADA655C-AF28-4E2A-9127-A533F80D05E4}']
    procedure Mapper(aValue : TOrionORMMapper);
    procedure Save(aDataObject : T);
    function FindOne(aID : integer) : T; overload;
    function FindOne(aFilter : TOrionORMFilter) : T; overload;
    function FindMany(aFilter : TOrionORMFilter) : TObjectList<T>;
    procedure Delete(aID : integer);
  end;

  iOrionORMPagination = interface
    ['{C02957C4-3DC2-444F-BEB7-FBC3F8BBF014}']
    procedure PageCount(aValue : integer);
    procedure PageIndex(aValue : integer);
    procedure PageSize(aValue : integer);
    function CriteriaResult : string;
  end;

  iDataset = interface;

  iDBConnectionConfigurations = interface;
  iDBConnection = interface
    ['{FDF6B898-A497-410F-B4D9-35EDDD329583}']
    procedure Configurations(aPath, aUsername, aPassword, aServer : string; aPort : integer); overload;
    function Configurations : iDBConnectionConfigurations; overload;
    procedure StartTransaction;
    procedure Commit;
    procedure RollBack;
    function Component : TComponent;
    function NewDataset : iDataset;
    function IsConnected : boolean; overload;
    function InTransaction : boolean;
    procedure Connected(aValue : boolean); overload;
  end;

  iDBConnectionConfigurations = interface
    ['{6CF32947-ED49-40C7-8706-0644027B8B93}']
    function Path : string; overload;
    procedure Path(aValue : string); overload;
    function Username : string; overload;
    procedure Username(aValue : string); overload;
    function Password : string; overload;
    procedure Password(aValue : string); overload;
    function Server : string; overload;
    procedure Server(aValue : string); overload;
    function Port : integer; overload;
    procedure Port(aValue : integer); overload;
  end;

  iConexaoFactory = interface
    function Conexao : iDBConnection;
    procedure Commit;
    procedure Rollback;
  end;

  iDataset = interface
    ['{AAA85BEC-5C3B-48F5-8D95-140622DA0E0B}']
    function RecordCount : integer;
    function FieldByName(aValue : string) : TField;
    function FieldExist(aFieldName : string) : boolean;
    function Fields : TFields;
    procedure Statement(aValue : string);
    procedure Open;
    procedure Append;
    procedure Edit;
    procedure Post;
    procedure Delete;
    procedure ExecSQL;
    procedure Next;
    procedure First;
    function Locate(const AKeyFields: string; const AKeyValues: Variant; AOptions: TLocateOptions = []): Boolean;
    function Eof : boolean;
  end;

implementation

end.
