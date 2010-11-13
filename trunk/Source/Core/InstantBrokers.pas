  (*
 *   InstantObjects
 *   Broker and Connector Classes
 *)

(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is: Seleqt InstantObjects
 *
 * The Initial Developer of the Original Code is: Seleqt
 *
 * Portions created by the Initial Developer are Copyright (C) 2001-2003
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * Carlo Barazzetta, Andrea Petrelli, Nando Dessena, Steven Mitchell,
 * Joao Morais, Cesar Coll, Uberto Barbini, David Taylor, Hanedi Salas,
 * Riceball Lee, David Moorhouse, Andrea Magni
 *
 * ***** END LICENSE BLOCK ***** *)

unit InstantBrokers;

{$IFDEF LINUX}
{$I '../InstantDefines.inc'}
{$ELSE}
{$I '..\InstantDefines.inc'}
{$ENDIF}

interface

uses
  SysUtils, Classes, Db, InstantPersistence, InstantTypes, InstantMetadata,
  InstantConsts, InstantClasses, Contnrs, InstantCommand;

type
  TInstantBrokerCatalog = class;
  TInstantConnectionBasedConnector = class;
  TInstantCustomRelationalBroker = class;
  TInstantCustomRelationalQuery = class;
  TInstantCustomRelationalQueryClass = class of TInstantCustomRelationalQuery;
  TInstantCustomResolver = class;
  TInstantLinkResolver = class;
  TInstantNavigationalBroker = class;
  TInstantNavigationalLinkResolver = class;
  TInstantNavigationalResolver = class;
  TInstantNavigationalResolverClass = class of TInstantNavigationalResolver;
  TInstantRelationalConnector = class;
  TInstantRelationalTranslator = class;
  TInstantRelationalTranslatorClass = class of TInstantRelationalTranslator;
  TInstantSQLBroker = class;
  TInstantSQLBrokerCatalog = class;
  TInstantSQLGenerator = class;
  TInstantSQLGeneratorClass = class of TInstantSQLGenerator;
  TInstantSQLLinkResolver = class;
  TInstantSQLResolver = class;
  TInstantStatementCache = class;

  PObjectRow = ^TObjectRow;
  TObjectRow = record
    Row: Integer;
    Instance: TObject;
  end;

  PInstantOperationInfo = ^TInstantOperationInfo;
  TInstantOperationInfo = record
    Success: Boolean;
    Conflict: Boolean;
  end;

  TInstantBrokerOperation = procedure(AObject: TInstantObject;
    const AObjectId: string; Map: TInstantAttributeMap;
    ConflictAction: TInstantConflictAction = caFail;
    Info: PInstantOperationInfo = nil) of object;
  TInstantGetDataSetEvent = procedure(Sender: TObject;
    const CommandText: string; var DataSet: TDataset) of object;
  TInstantInitDataSetEvent = procedure(Sender: TObject;
    const CommandText: string; DataSet: TDataSet) of object;
  TInstantNavigationalResolverOperation = procedure(AObject: TInstantObject;
    AttributeMetadata: TInstantAttributeMetadata) of object;

  TInstantCustomRelationalBroker = class(TInstantBroker)
  private
    FStatementCache: TInstantStatementCache;
    FStatementCacheCapacity: Integer;
    FObjectData: TInstantAbstractObjectData;
    procedure DisposeMap(AObject: TInstantObject; const AObjectId: string;
      Map: TInstantAttributeMap; ConflictAction: TInstantConflictAction;
      Info: PInstantOperationInfo);
    function GetConnector: TInstantRelationalConnector;
    function PerformOperation(AObject: TInstantObject; const AObjectId: string;
      OperationType: TInstantOperationType; Operation: TInstantBrokerOperation;
      ConflictAction: TInstantConflictAction): Boolean;
    procedure RetrieveMap(AObject: TInstantObject; const AObjectId: string;
      Map: TInstantAttributeMap; ConflictAction: TInstantConflictAction;
      Info: PInstantOperationInfo);
    procedure StoreMap(AObject: TInstantObject; const AObjectId: string;
      Map: TInstantAttributeMap; ConflictAction: TInstantConflictAction;
      Info: PInstantOperationInfo);
    function GetStatementCache: TInstantStatementCache;
    procedure SetStatementCacheCapacity(const AValue: Integer);
  protected
    property StatementCache: TInstantStatementCache read GetStatementCache;
    function EnsureResolver(Map: TInstantAttributeMap): TInstantCustomResolver;
      virtual; abstract;
    function GetDBMSName: string; virtual;
    function GetSQLDelimiters: string; virtual;
    function GetSQLQuote: Char; virtual;
    function GetSQLWildcard: string; virtual;
    function InternalDisposeObject(AObject: TInstantObject;
      ConflictAction: TInstantConflictAction): Boolean; override;
    function InternalRetrieveObject(AObject: TInstantObject;
      const AObjectId: string; ConflictAction: TInstantConflictAction;
      const AObjectData: TInstantAbstractObjectData = nil): Boolean; override;
    function InternalStoreObject(AObject: TInstantObject;
      ConflictAction: TInstantConflictAction): Boolean; override;
  public
    constructor Create(AConnector: TInstantConnector); override;
    destructor Destroy; override;
    function Execute(const AStatement: string; AParams: TParams = nil): Integer;
      virtual;
    property Connector: TInstantRelationalConnector read GetConnector;
    property DBMSName: string read GetDBMSName;
    property SQLDelimiters: string read GetSQLDelimiters;
    property SQLQuote: Char read GetSQLQuote;
    property SQLWildcard: string read GetSQLWildCard;
    property StatementCacheCapacity: Integer read FStatementCacheCapacity
      write SetStatementCacheCapacity;
  end;

  TInstantNavigationalBroker = class(TInstantCustomRelationalBroker)
  private
    FResolverList: TObjectList;
    function GetResolverCount: Integer;
    function GetResolverList: TObjectList;
    function GetResolvers(Index: Integer): TInstantnavigationalResolver;
    property ResolverList: TObjectList read GetResolverList;
  protected
    function CreateResolver(const TableName: string):
      TInstantNavigationalResolver; virtual; abstract;
    function EnsureResolver(Map: TInstantAttributeMap): TInstantCustomResolver;
      override;
    function FindResolver(const TableName: string):
      TInstantNavigationalResolver;
    property ResolverCount: Integer read GetResolverCount;
    property Resolvers[Index: Integer]: TInstantNavigationalResolver
      read GetResolvers;
  public
    destructor Destroy; override;
  end;

  //Backwards compatibility
  TInstantRelationalBroker = TInstantNavigationalBroker;

  TInstantSQLBroker = class(TInstantCustomRelationalBroker)
  private
    FGenerator: TInstantSQLGenerator;
    FResolverList: TObjectList;
    function GetResolverList: TObjectList;
    function GetResolverCount: Integer;
    function GetResolvers(Index: Integer): TInstantSQLResolver;
    function GetGenerator: TInstantSQLGenerator;
  protected
    function CreateResolver(Map: TInstantAttributeMap): TInstantSQLResolver;
      virtual; abstract;
    function EnsureResolver(AMap: TInstantAttributeMap): TInstantCustomResolver;
      override;
    procedure InternalBuildDatabase(Scheme: TInstantScheme); override;
    property ResolverList: TObjectList read GetResolverList;
    procedure AssignDataSetParams(DataSet : TDataSet; AParams: TParams);
      virtual;
    function CreateDataSet(const AStatement: string; AParams: TParams = nil):
      TDataSet; virtual; abstract;
  public
    destructor Destroy; override;
    function AcquireDataSet(const AStatement: string; AParams: TParams = nil):
      TDataSet; virtual;
    procedure ReleaseDataSet(const ADataSet: TDataSet); virtual;
    function DataTypeToColumnType(DataType: TInstantDataType;
      Size: Integer): string; virtual; abstract;
    function FindResolver(AMap: TInstantAttributeMap): TInstantSQLResolver;
    class function GeneratorClass: TInstantSQLGeneratorClass; virtual;
    property Generator: TInstantSQLGenerator read GetGenerator;
    property ResolverCount: Integer read GetResolverCount;
    property Resolvers[Index: Integer]: TInstantSQLResolver read GetResolvers;
  end;

  TInstantRelationalConnector = class(TInstantConnector)
  private
    FOnGetDataSet: TInstantGetDataSetEvent;
    FOnInitDataSet: TInstantInitDataSetEvent;
  protected
    procedure DoGetDataSet(const CommandText: string; var DataSet: TDataSet);
    procedure DoInitDataSet(const CommandText: string; DataSet: TDataSet);
    function GetBroker: TInstantCustomRelationalBroker;
    procedure GetDataSet(const CommandText: string; var DataSet: TDataSet);
      virtual;
    function GetDBMSName: string; virtual;
    procedure InitDataSet(const CommandText: string; DataSet: TDataSet);
      virtual;
    function InternalCreateScheme(Model: TInstantModel): TInstantScheme;
      override;
  public
    property Broker: TInstantCustomRelationalBroker read GetBroker;
    property DBMSName: string read GetDBMSName;
  published
    property OnGetDataSet: TInstantGetDataSetEvent read FOnGetDataSet
      write FOnGetDataSet;
    property OnInitDataSet: TInstantInitDataSetEvent read FOnInitDataSet
      write FOnInitDataSet;
  end;

  TInstantConnectionBasedConnector = class(TInstantRelationalConnector)
  private
    FConnection: TCustomConnection;
    FLoginPrompt: Boolean;
    procedure DoAfterConnectionChange;
    procedure DoBeforeConnectionChange;
    function GetConnection: TCustomConnection;
    function GetLoginPrompt: Boolean;
    procedure SetConnection(Value: TCustomConnection);
    procedure SetLoginPrompt(const Value: Boolean);
  protected
    procedure AssignLoginOptions; virtual;
    procedure AfterConnectionChange; virtual;
    procedure BeforeConnectionChange; virtual;
    procedure CheckConnection;
    function GetConnected: Boolean; override;
    procedure InternalConnect; override;
    procedure InternalDisconnect; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
  public
    property Connection: TCustomConnection read GetConnection
      write SetConnection;
    function HasConnection: Boolean;
    constructor Create(AOwner: TComponent); override;
  published
    property LoginPrompt: Boolean read GetLoginPrompt write SetLoginPrompt
      default True;
  end;

  TInstantCustomResolver = class(TInstantStreamable)
  private
    FBroker: TInstantCustomRelationalBroker;
  protected
    function KeyViolation(AObject: TInstantObject; const AObjectId: string;
      E: Exception): EInstantKeyViolation;
    procedure InternalDisposeMap(AObject: TInstantObject;
      Map: TInstantAttributeMap; ConflictAction: TInstantConflictAction;
      Info: PInstantOperationInfo); virtual;
    procedure InternalRetrieveMap(AObject: TInstantObject;
      const AObjectId: string; Map: TInstantAttributeMap;
      ConflictAction: TInstantConflictAction; AInfo: PInstantOperationInfo;
      const AObjectData: TInstantAbstractObjectData = nil); virtual;
    procedure InternalStoreMap(AObject: TInstantObject;
      Map: TInstantAttributeMap; ConflictAction: TInstantConflictAction;
      Info: PInstantOperationInfo); virtual;
    function CreateEmbeddedObjectInputStream(const AConnector: TInstantConnector;
      const AField: TField): TStream;
    function CreateEmbeddedObjectOutputStream(const AConnector: TInstantConnector): TStream;
    procedure AssignEmbeddedObjectStreamToField(const AConnector: TInstantConnector;
      const AStream: TStream; const AField: TField);
  public
    constructor Create(ABroker: TInstantCustomRelationalBroker);
    procedure DisposeMap(AObject: TInstantObject; Map: TInstantAttributeMap;
      ConflictAction: TInstantConflictAction; Info: PInstantOperationInfo);
    procedure DisposeObject(AObject: TInstantObject; Conflict:
        TInstantConflictAction);
    procedure RetrieveMap(AObject: TInstantObject; const AObjectId: string;
      Map: TInstantAttributeMap; ConflictAction: TInstantConflictAction;
      Info: PInstantOperationInfo;
      const AObjectData: TInstantAbstractObjectData = nil);
    procedure StoreMap(AObject: TInstantObject; Map: TInstantAttributeMap;
      ConflictAction: TInstantConflictAction; Info: PInstantOperationInfo);
    procedure StoreObject(AObject: TInstantObject; Conflict:
        TInstantConflictAction);
    property Broker: TInstantCustomRelationalBroker read FBroker;
  end;

  TInstantNavigationalResolver = class(TInstantCustomResolver)
  private
    FDataSet: TDataSet;
    FFreeDataSet: Boolean;
    FNavigationalLinkResolvers: TObjectList;
    FTableName: string;
    function CheckConflict(AObject: TInstantObject; const AObjectId: string;
      ConflictAction: TInstantConflictAction): Boolean;
    procedure ClearAttribute(AObject: TInstantObject;
      AttributeMetadata: TInstantAttributeMetadata);
    function FieldByName(const FieldName: string): TField;
    procedure FreeDataSet;
    function GetBroker: TInstantNavigationalBroker;
    function GetDataSet: TDataSet;
    function GetNavigationalLinkResolvers: TObjectList;
    function GetObjectClassName: string;
    function GetObjectId: string;
    procedure PerformOperation(AObject: TInstantObject;
      Map: TInstantAttributeMap; Operation:
      TInstantNavigationalResolverOperation);
    procedure ReadAttribute(AObject: TInstantObject;
      AttributeMetadata: TInstantAttributeMetadata);
    procedure ResetAttribute(AObject: TInstantObject;
      AttributeMetadata: TInstantAttributeMetadata);
    procedure SetDataSet(Value: TDataset);
    procedure WriteAttribute(AObject: TInstantObject;
      AttributeMetadata: TInstantAttributeMetadata);
  protected
    procedure Append; virtual;
    procedure Cancel; virtual;
    procedure ClearBlob(Attribute: TInstantBlob); virtual;
    procedure ClearBoolean(Attribute: TInstantBoolean); virtual;
    procedure ClearDateTime(Attribute: TInstantDateTime); virtual;
    procedure ClearDate(Attribute: TInstantDate); virtual;
    procedure ClearTime(Attribute: TInstantTime); virtual;
    procedure ClearInteger(Attribute: TInstantInteger); virtual;
    procedure ClearFloat(Attribute: TInstantFloat); virtual;
    procedure ClearCurrency(Attribute: TInstantCurrency); virtual;
    procedure ClearMemo(Attribute: TInstantMemo); virtual;
    procedure ClearPart(Attribute: TInstantPart); virtual;
    procedure ClearParts(Attribute: TInstantParts); virtual;
    procedure ClearReference(Attribute: TInstantReference); virtual;
    procedure ClearReferences(Attribute: TInstantReferences); virtual;
    procedure ClearString(Attribute: TInstantString); virtual;
    procedure Close; virtual;
    function CreateDataSet: TDataSet; virtual; abstract;
    function CreateNavigationalLinkResolver(const ATableName: string):
        TInstantNavigationalLinkResolver; virtual; abstract;
    function CreateLocateVarArray(const AObjectClassName, AObjectId: string):
      Variant;
    procedure Delete; virtual;
    procedure Edit; virtual;
    function GetLinkDatasetResolver(const ATableName: string):
        TInstantNavigationalLinkResolver;
    function FieldHasObjects(Field: TField): Boolean; virtual;
    function FindLinkDatasetResolver(const ATableName: string):
        TInstantNavigationalLinkResolver;
    procedure InternalDisposeMap(AObject: TInstantObject;
      Map: TInstantAttributeMap; ConflictAction: TInstantConflictAction;
      Info: PInstantOperationInfo); override;
    procedure InternalRetrieveMap(AObject: TInstantObject;
      const AObjectId: string; Map: TInstantAttributeMap;
      ConflictAction: TInstantConflictAction; Info: PInstantOperationInfo;
      const AObjectData: TInstantAbstractObjectData = nil); override;
    procedure InternalStoreMap(AObject: TInstantObject;
      Map: TInstantAttributeMap;
      ConflictAction: TInstantConflictAction; Info: PInstantOperationInfo);
      override;
    function Locate(const AObjectClassName, AObjectId: string): Boolean;
      virtual; abstract;
    procedure Open; virtual;
    procedure Post; virtual;
    procedure ReadBlob(Attribute: TInstantBlob); virtual;
    procedure ReadBoolean(Attribute: TInstantBoolean); virtual;
    procedure ReadDateTime(Attribute: TInstantDateTime); virtual;
    procedure ReadDate(Attribute: TInstantDate); virtual;
    procedure ReadTime(Attribute: TInstantTime); virtual;
    procedure ReadInteger(Attribute: TInstantInteger); virtual;
    procedure ReadFloat(Attribute: TInstantFloat); virtual;
    procedure ReadCurrency(Attribute: TInstantCurrency); virtual;
    procedure ReadMemo(Attribute: TInstantMemo); virtual;
    procedure ReadPart(Attribute: TInstantPart); virtual;
    procedure ReadParts(Attribute: TInstantParts); virtual;
    procedure ReadReference(Attribute: TInstantReference); virtual;
    procedure ReadReferences(Attribute: TInstantReferences); virtual;
    procedure ReadString(Attribute: TInstantString); virtual;
    procedure ResetAttributes(const AObject: TInstantObject;
      const AMap: TInstantAttributeMap);
    procedure SetObjectUpdateCount(AObject: TInstantObject; Value: Integer);
    function TranslateError(AObject: TInstantObject; E: Exception): Exception;
      virtual;
    procedure WriteBlob(Attribute: TInstantBlob); virtual;
    procedure WriteBoolean(Attribute: TInstantBoolean); virtual;
    procedure WriteDateTime(Attribute: TInstantDateTime); virtual;
    procedure WriteDate(Attribute: TInstantDate); virtual;
    procedure WriteTime(Attribute: TInstantTime); virtual;
    procedure WriteFloat(Attribute: TInstantFloat); virtual;
    procedure WriteCurrency(Attribute: TInstantCurrency); virtual;
    procedure WriteInteger(Attribute: TInstantInteger); virtual;
    procedure WriteMemo(Attribute: TInstantMemo); virtual;
    procedure WritePart(Attribute: TInstantPart); virtual;
    procedure WriteParts(Attribute: TInstantParts); virtual;
    procedure WriteReference(Attribute: TInstantReference); virtual;
    procedure WriteReferences(Attribute: TInstantReferences); virtual;
    procedure WriteString(Attribute: TInstantString); virtual;
    property DataSet: TDataset read GetDataSet write SetDataSet;
    property NavigationalLinkResolvers: TObjectList
      read GetNavigationalLinkResolvers;
  public
    constructor Create(ABroker: TInstantNavigationalBroker;
      const ATableName: string);
    destructor Destroy; override;
    property Broker: TInstantNavigationalBroker read GetBroker;
    property ObjectClassName: string read GetObjectClassName;
    property ObjectId: string read GetObjectId;
    property TableName: string read FTableName;
  end;

  // Backward compatibility
  TInstantResolver = TInstantNavigationalResolver;

  TInstantSQLResolver = class(TInstantCustomResolver)
  private
    FMap: TInstantAttributeMap;
    FDeleteSQL: string;
    FDeleteConcurrentSQL: string;
    FInsertSQL: string;
    FSelectSQL: string;
    FUpdateSQL: string;
    FUpdateConcurrentSQL: string;
    FSelectExternalSQL: string;
    FSelectExternalPartSQL: string;
    FDeleteExternalSQL: string;
    FInsertExternalSQL: string;
    function AddIntegerParam(Params: TParams; const ParamName: string;
      Value: Integer): TParam;
    function AddStringParam(Params: TParams; const ParamName, Value: string): TParam;
    // Adds an "Id" param, whose data type and size depends on connector
    // settings.
    procedure AddIdParam(Params: TParams; const ParamName, Value: string);
    procedure CheckConflict(Info: PInstantOperationInfo;
      AObject: TInstantObject);
    function ExecuteStatement(const AStatement: string; AParams: TParams;
      Info: PInstantOperationInfo; ConflictAction: TInstantConflictAction;
      AObject: TInstantObject): Integer;
    function GetDeleteConcurrentSQL: string;
    function GetDeleteSQL: string;
    function GetInsertSQL: string;
    function GetSelectSQL: string;
    function GetUpdateConcurrentSQL: string;
    function GetUpdateSQL: string;
    function GetBroker: TInstantSQLBroker;
    function GetSelectExternalSQL: string;
    function GetSelectExternalPartSQL: string;
    function GetDeleteExternalSQL: string;
    function GetInsertExternalSQL: string;
    procedure ResetAttributes(const AObject: TInstantObject;
      const AMap: TInstantAttributeMap);
    procedure RetrieveMapFromDataSet(const AObject: TInstantObject;
      const AObjectId: string; const AMap: TInstantAttributeMap;
      ConflictAction: TInstantConflictAction; AInfo: PInstantOperationInfo;
      const ADataSet: TDataSet);
  protected
    procedure AddAttributeParam(Attribute: TInstantAttribute;
      Params: TParams); virtual;
    procedure AddAttributeParams(Params: TParams; AObject: TInstantObject;
      Map: TInstantAttributeMap);
    procedure AddBaseParams(Params: TParams; AClassName, AObjectId: string;
      AUpdateCount: Integer = -1);
    procedure AddConcurrencyParam(Params: TParams; AUpdateCount: Integer);
    function AddParam(Params: TParams; const ParamName: string;
      ADataType: TFieldType): TParam;
    procedure AddPersistentIdParam(Params: TParams; APersistentId: string);
    procedure InternalDisposeMap(AObject: TInstantObject;
      Map: TInstantAttributeMap; ConflictAction: TInstantConflictAction;
      Info: PInstantOperationInfo); override;
    procedure InternalRetrieveMap(AObject: TInstantObject;
      const AObjectId: string; Map: TInstantAttributeMap;
      ConflictAction: TInstantConflictAction; AInfo: PInstantOperationInfo;
      const AObjectData: TInstantAbstractObjectData = nil); override;
    procedure InternalStoreMap(AObject: TInstantObject;
      Map: TInstantAttributeMap; ConflictAction: TInstantConflictAction;
      Info: PInstantOperationInfo); override;
    procedure ReadAttribute(AObject: TInstantObject; const AObjectId: string;
      AttributeMetadata: TInstantAttributeMetadata; DataSet: TDataSet); virtual;
    procedure ReadAttributes(AObject: TInstantObject; const AObjectId: string;
      Map: TInstantAttributeMap; DataSet: TDataSet);
    function ReadBlobField(DataSet: TDataSet; const FieldName: string): string;
      virtual;
    function ReadBooleanField(DataSet: TDataSet; const FieldName: string):
      Boolean; virtual;
    function ReadDateTimeField(DataSet: TDataSet; const FieldName: string):
      TDateTime; virtual;
    function ReadDateField(DataSet: TDataSet; const FieldName: string):
      TDateTime; virtual;
    function ReadTimeField(DataSet: TDataSet; const FieldName: string):
      TDateTime; virtual;
    function ReadFloatField(DataSet: TDataSet; const FieldName: string): Double;
      virtual;
    function ReadCurrencyField(DataSet: TDataSet; const FieldName: string):
      Currency; virtual;
    function ReadIntegerField(DataSet: TDataSet; const FieldName: string):
      Integer; virtual;
    function ReadMemoField(DataSet: TDataSet; const FieldName: string): string;
      virtual;
    function ReadStringField(DataSet: TDataSet; const FieldName: string):
      string; virtual;
    procedure RemoveConcurrencyParam(Params: TParams);
    procedure RemovePersistentIdParam(Params: TParams);
    function TranslateError(AObject: TInstantObject;
      E: Exception): Exception; virtual;
    procedure AddEmbeddedObjectOutputParam(const AConnector: TInstantConnector;
      const AParams: TParams; const AParamName: string; const AStream: TStream);
  public
    constructor Create(ABroker: TInstantSQLBroker; AMap: TInstantAttributeMap);
    property Broker: TInstantSQLBroker read GetBroker;
    property DeleteConcurrentSQL: string read GetDeleteConcurrentSQL write FDeleteConcurrentSQL;
    property DeleteSQL: string read GetDeleteSQL write FDeleteSQL;
    property DeleteExternalSQL: string read GetDeleteExternalSQL write FDeleteExternalSQL;
    property InsertSQL: string read GetInsertSQL write FInsertSQL;
    property InsertExternalSQL: string read GetInsertExternalSQL
      write FInsertExternalSQL;
    property Map: TInstantAttributeMap read FMap;
    property SelectSQL: string read GetSelectSQL write FSelectSQL;
    property SelectExternalSQL: string read GetSelectExternalSQL
      write FSelectExternalSQL;
    property SelectExternalPartSQL: string read GetSelectExternalPartSQL
      write FSelectExternalPartSQL;
    property UpdateConcurrentSQL: string read GetUpdateConcurrentSQL
      write FUpdateConcurrentSQL;
    property UpdateSQL: string read GetUpdateSQL write FUpdateSQL;
  end;

  // TInstantLinkResolver class defines common interface for handling
  // access to container attributes with external storage
  TInstantLinkResolver = class(TInstantStreamable)
  private
    FResolver: TInstantCustomResolver;
    function GetBroker: TInstantCustomRelationalBroker;
    function GetResolver: TInstantCustomResolver;
  protected
    procedure InternalStoreAttributeObjects(Attribute: TInstantContainer);
      virtual;
    procedure InternalClearAttributeLinkRecords; virtual;
    procedure InternalDisposeDeletedAttributeObjects(
      Attribute: TInstantContainer); virtual;
    procedure InternalReadAttributeObjects(Attribute: TInstantContainer;
      const AObjectId: string); virtual;
  public
    constructor Create(AResolver: TInstantCustomResolver);
    procedure StoreAttributeObjects(Attribute: TInstantContainer);
    procedure ClearAttributeLinkRecords;
    procedure DisposeDeletedAttributeObjects(Attribute: TInstantContainer);
    procedure ReadAttributeObjects(Attribute: TInstantContainer;
      const AObjectId: string);
    property Broker: TInstantCustomRelationalBroker read GetBroker;
    property Resolver: TInstantCustomResolver read GetResolver;
  end;

  // TInstantNavigationalLinkResolver is an abstract class that
  // defines the interface for handling access to container attributes
  // with external storage for navigational brokers.
  // Each navigational broker needs to provide a concrete class descendent.
  // See the BDE broker as an example.
  TInstantNavigationalLinkResolver = class(TInstantLinkResolver)
  private
    FDataSet: TDataSet;
    FFreeDataSet: Boolean;
    FTableName: string;
    function FieldByName(const FieldName: string): TField;
    procedure FreeDataSet;
    function GetBroker: TInstantNavigationalBroker;
    function GetDataSet: TDataSet;
    function GetResolver: TInstantNavigationalResolver;
    procedure SetDataSet(Value: TDataset);
  protected
    procedure Append; virtual;
    procedure Cancel; virtual;
    procedure Close; virtual;
    function CreateDataSet: TDataSet; virtual; abstract;
    procedure Delete; virtual;
    procedure Edit; virtual;
    function Eof: Boolean; virtual;
    procedure First; virtual;
    procedure InternalStoreAttributeObjects(Attribute: TInstantContainer); override;
    procedure InternalClearAttributeLinkRecords; override;
    procedure InternalDisposeDeletedAttributeObjects(
      Attribute: TInstantContainer); override;
    procedure InternalReadAttributeObjects(Attribute: TInstantContainer; 
      const AObjectId: string); override;
    procedure Next; virtual;
    procedure Open; virtual;
    procedure Post; virtual;
    procedure SetDatasetParentRange(const AParentClass, AParentId: string);
      virtual; abstract;
    property DataSet: TDataset read GetDataSet write SetDataSet;
  public
    constructor Create(AResolver: TInstantNavigationalResolver;
      const ATableName: string);
    destructor Destroy; override;
    property Broker: TInstantNavigationalBroker read GetBroker;
    property Resolver: TInstantNavigationalResolver read GetResolver;
    property TableName: string read FTableName;
  end;

  // TInstantSQLLinkResolver class defines interface for handling
  // access to container attributes with external storage for
  // SQL brokers. Due to the generic nature of SQL this class is used
  // directly and no descendant classes are needed for SQL brokers.
  TInstantSQLLinkResolver = class(TInstantLinkResolver)
  private
    FAttributeOwner: TInstantObject;
    FTableName: string;
    function GetBroker: TInstantSQLBroker;
    function GetResolver: TInstantSQLResolver;
    property TableName: string read FTableName;
  protected
    procedure InternalStoreAttributeObjects(Attribute: TInstantContainer);
      override;
    procedure InternalClearAttributeLinkRecords; override;
    procedure InternalDisposeDeletedAttributeObjects(
      Attribute: TInstantContainer);  override;
    procedure InternalReadAttributeObjects(Attribute: TInstantContainer; const
      AObjectId: string); override;
  public
    constructor Create(AResolver: TInstantSQLResolver; const ATableName: string;
      AObject: TInstantObject);
    property AttributeOwner: TInstantObject read FAttributeOwner;
    property Broker: TInstantSQLBroker read GetBroker;
    property Resolver: TInstantSQLResolver read GetResolver;
  end;

  // An item in the statement cache.
  TInstantStatement = class
  private
    FStatementDataSet: TDataSet;
    FDataSetRefCount: Integer;
  public
    constructor Create(const AStatementDataSet: TDataSet);
    destructor Destroy; override;
    property StatementDataSet: TDataSet read FStatementDataSet;
    function AddDataSetRef: Integer;
    function ReleaseDataSetRef: Integer;
  end;

  // Caches objects that implement command statements in releational brokers.
  // Most commonly, they are TDataSet descendants that implement SQL queries.
  // brokers cache them to save on prepare/compilation time.
  TInstantStatementCache = class(TComponent)
  private
    FStatements: TStringList;
    FCapacity: Integer;
    procedure DeleteStatement(const Index: Integer);
    procedure DeleteAllStatements;
    procedure Shrink;
    procedure SetCapacity(const Value: Integer);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
  public
    constructor Create(AOwner: TComponent); override;
    property Capacity: Integer read FCapacity write SetCapacity;
    destructor Destroy; override;
    function GetStatement(const StatementText: string): TInstantStatement;
    function IndexOfStatementDataSet(const StatementDataSet: TDataSet): Integer;
    function GetStatementByIndex(const AIndex: Integer): TInstantStatement;
    function AddStatement(const StatementText: string;
      const StatementDataSet: TDataSet): Integer;
    function RemoveStatement(const StatementText: string): Boolean;
  end;

  // A TInstantCatalog that gathers its info from an existing database (through
  // a TInstantBroker). The broker knows how to read the metadata information
  // depending on which particular database is used as back-end. This is an
  // abstract class. A concrete derived class for each supported back-end
  // must be developed.
  TInstantBrokerCatalog = class(TInstantCatalog)
  private
    FBroker: TInstantBroker;
    function GetBroker: TInstantBroker;
  public
    // Creates an instance and binds it to the specified TInstantScheme object.
    // ABroker is written to the Broker property.
    constructor Create(const AScheme: TInstantScheme;
      const ABroker: TInstantBroker); virtual;
    // A reference to the broker through which the metadata info is read.
    property Broker: TInstantBroker read GetBroker;
  end;

  // A TInstantBrokerCatalog that works with a SQL broker only.
  TInstantSQLBrokerCatalog = class(TInstantBrokerCatalog)
  private
    function GetBroker: TInstantSQLBroker;
  public
    property Broker: TInstantSQLBroker read GetBroker;
  end;

  TInstantSQLGenerator = class(TObject)
  private
    FBroker: TInstantSQLBroker;
  protected
    function BuildList(Map: TInstantAttributeMap; Additional: array of string;
      StringFunc: TInstantStringFunc = nil; const Delimiter: string = ','):
      string;
    function BuildAssignment(const AName: string): string;
    function BuildAssignmentList(Map: TInstantAttributeMap;
      Additional: array of string): string;
    function BuildConcurrencyCriteria: string;
    function BuildPersistentIdCriteria: string;
    function BuildFieldList(Map: TInstantAttributeMap;
      Additional: array of string): string; overload;
    function BuildFieldList(const S: string): string; overload;
    function BuildParam(const AName: string): string; virtual;
    function BuildParamList(Map: TInstantAttributeMap;
      Additional: array of string): string;
    function BuildWhereStr(Fields: array of string): string;
    function EmbraceField(const FieldName: string): string; virtual;
    function EmbraceTable(const TableName: string): string; virtual;
    function GetDelimiters: string; virtual;
    function InternalGenerateAddFieldSQL(Metadata: TInstantFieldMetadata):
      string; virtual;
    function InternalGenerateAlterFieldSQL(OldMetadata,
      NewMetadata: TInstantFieldMetadata): string; virtual;
    function InternalGenerateCreateIndexSQL(Metadata: TInstantIndexMetadata):
      string; virtual;
    function InternalGenerateCreateTableSQL(Metadata: TInstantTableMetadata):
      string; virtual;
    function InternalGenerateDeleteConcurrentSQL(Map: TInstantAttributeMap):
      string; virtual;
    function InternalGenerateDeleteSQL(Map: TInstantAttributeMap): string;
      virtual;
    function InternalGenerateDeleteExternalSQL(Map: TInstantAttributeMap):
      string; virtual;
    function InternalGenerateDropFieldSQL(Metadata: TInstantFieldMetadata):
      string; virtual;
    function InternalGenerateDropIndexSQL(Metadata: TInstantIndexMetadata):
      string; virtual;
    function InternalGenerateDropTableSQL(Metadata: TInstantTableMetadata):
      string; virtual;
    function InternalGenerateInsertSQL(Map: TInstantAttributeMap): string;
      virtual;
    function InternalGenerateInsertExternalSQL(Map: TInstantAttributeMap):
      string; virtual;
    function InternalGenerateSelectSQL(Map: TInstantAttributeMap): string;
      virtual;
    function InternalGenerateSelectExternalSQL(Map: TInstantAttributeMap):
      string; virtual;
    function InternalGenerateSelectExternalPartSQL(Map: TInstantAttributeMap):
      string; virtual;
    function InternalGenerateSelectTablesSQL: string; virtual;
    function InternalGenerateUpdateConcurrentSQL(Map: TInstantAttributeMap):
      string; virtual;
    function InternalGenerateUpdateFieldCopySQL(OldMetadata, NewMetadata:
        TInstantFieldMetadata): string; virtual;
    function InternalGenerateUpdateSQL(Map: TInstantAttributeMap): string;
      virtual;
    property Delimiters: string read GetDelimiters;
    property Broker: TInstantSQLBroker read FBroker;
  public
    constructor Create(ABroker: TInstantSQLBroker);
    function GenerateAddFieldSQL(Metadata: TInstantFieldMetadata): string;
    function GenerateAlterFieldSQL(OldMetadata,
      NewMetadata: TInstantFieldMetadata): string;
    function GenerateCreateIndexSQL(Metadata: TInstantIndexMetadata): string;
    function GenerateCreateTableSQL(Metadata: TInstantTableMetadata): string;
    function GenerateDeleteConcurrentSQL(Map: TInstantAttributeMap): string;
    function GenerateDeleteSQL(Map: TInstantAttributeMap): string;
    function GenerateDeleteExternalSQL(Map: TInstantAttributeMap): string;
    function GenerateDropFieldSQL(Metadata: TInstantFieldMetadata): string;
    function GenerateDropIndexSQL(Metadata: TInstantIndexMetadata): string;
    function GenerateDropTableSQL(Metadata: TInstantTableMetadata): string;
    function GenerateInsertSQL(Map: TInstantAttributeMap): string;
    function GenerateInsertExternalSQL(Map: TInstantAttributeMap): string;
    function GenerateSelectSQL(Map: TInstantAttributeMap): string;
    function GenerateSelectExternalSQL(Map: TInstantAttributeMap): string;
    function GenerateSelectExternalPartSQL(Map: TInstantAttributeMap): string;
    function GenerateSelectTablesSQL: string;
    function GenerateUpdateConcurrentSQL(Map: TInstantAttributeMap): string;
    function GenerateUpdateFieldCopySQL(OldMetadata, NewMetadata:
        TInstantFieldMetadata): string;
    function GenerateUpdateSQL(Map: TInstantAttributeMap): string;
  end;

  TInstantCustomRelationalQuery = class(TInstantQuery)
  private
    function GetConnector: TInstantRelationalConnector;
  protected
    function GetStatement: string; virtual;
    procedure InternalGetInstantObjectRefs(List: TInstantObjectReferenceList);
      virtual;
    procedure InternalRefreshObjects; override;
    procedure SetStatement(const Value: string); virtual;
    procedure TranslateCommand; override;
    class function TranslatorClass: TInstantRelationalTranslatorClass; virtual;
  public
    property Statement: string read GetStatement write SetStatement;
    property Connector: TInstantRelationalConnector read GetConnector;
  end;

  TInstantQueryTranslator = class(TInstantIQLTranslator)
  private
    FQuery: TInstantQuery;
    function GetQuery: TInstantQuery;
  protected
    function CreateCommand: TInstantIQLCommand; override;
    function GetResultClassName: string; override;
  public
    constructor Create(AQuery: TInstantQuery);
    property Query: TInstantQuery read GetQuery;
  end;

  // Holds all information pertaining to a class used in a command. A command
  // may use several classes (because of subqueries), and a relational translator
  // has a tree of class context objects.
  TInstantTranslationContext = class
  private
    FChildContexts: TObjectList;
    FClassRef: TInstantIQLClassRef;
    FCriteriaList: TStringList;
    FDelimiters: string;
    FObjectClassName: string;
    FObjectClassMetadata: TInstantClassMetadata;
    FQuote: Char;
    FSpecifier: TInstantIQLSpecifier;
    FStatement: TInstantIQLObject;
    FTablePathList: TStringList;
    FParentContext: TInstantTranslationContext;
    FIdDataType: TInstantDataType;
    FRequestedLoadMode: TInstantLoadMode;
    FActualLoadMode: TInstantLoadMode;
    procedure AddJoin(const FromPath, FromField, ToPath, ToField: string);
    function GetClassTablePath: string;
    function GetChildContext(const AIndex: Integer): TInstantTranslationContext;
    function GetChildContextCount: Integer;
    function GetCriteriaCount: Integer;
    function GetCriteriaList: TStringList;
    function GetCriterias(Index: Integer): string;
    function GetObjectClassMetadata: TInstantClassMetadata;
    function GetTableAlias: string;
    function GetTableName: string;
    function GetTablePathAliases(Index: Integer): string;
    function GetTablePathCount: Integer;
    function GetTablePathList: TStringList;
    function GetTablePaths(Index: Integer): string;
    function PathToTablePath(const PathText: string): string;
    function PathToTarget(const PathText: string;
      out TablePath, FieldName: string; const AClassMetadata: TInstantClassMetadata = nil): TInstantAttributeMetadata;
    procedure SetClassRef(const Value: TInstantIQLClassRef);
    procedure SetObjectClassName(const Value: string);
    procedure SetSpecifier(const Value: TInstantIQLSpecifier);
    function TablePathToAlias(const TablePath: string): string;
    function GetChildContextIndex: Integer;
    function GetChildContextLevel: Integer;
    function RootAttribToFieldName(const AttribName: string): string;
  protected
    function AddCriteria(const Criteria: string): Integer;
    function AddTablePath(const TablePath: string): Integer;
    procedure CollectPaths(AObject: TInstantIQLObject; APathList: TList);
    function IndexOfCriteria(const Criteria: string): Integer;
    function IndexOfTablePath(const TablePath: string): Integer;
    procedure Initialize;
    procedure MakeJoins(Path: TInstantIQLPath);
    procedure MakeTablePaths(Path: TInstantIQLPath);
    property CriteriaList: TStringList read GetCriteriaList;
    property TablePathList: TStringList read GetTablePathList;
  public
    constructor Create(const AStatement: TInstantIQLObject; const AQuote: Char;
      const ADelimiters: string; const AIdDataType: TInstantDataType;
      const ARequestedLoadMode: TInstantLoadMode;
      const AParentContext: TInstantTranslationContext = nil);
    destructor Destroy; override;
    procedure AfterConstruction; override;
    procedure Clear;
    function AddChildContext(const AContext: TInstantTranslationContext): Integer;
    function CreateChildContext(const AStatement: TInstantIQLObject): TInstantTranslationContext;
    function FindAttributeMetadata(const PathText: string): TInstantAttributeMetadata;
    function GetTablePathAlias(const ATablePath: string): string;
    function GetSubqueryContext(const ASubQuery: TInstantIQLSubquery): TInstantTranslationContext;
    function HasParentContext: Boolean;
    function IndexOfChildContext(const AChildContext: TInstantTranslationContext): Integer;
    function Qualify(const TablePath, FieldName: string): string;
    function QualifyPath(const PathText: string): string;
    function WriteCriterias(Writer: TInstantIQLWriter; IncludeWhere: Boolean): Boolean;
    procedure WriteTables(Writer: TInstantIQLWriter);

    property ChildContext[const AIndex: Integer]: TInstantTranslationContext read GetChildContext;
    property ChildContextCount: Integer read GetChildContextCount;
    property ChildContextIndex: Integer read GetChildContextIndex;
    property ChildContextLevel: Integer read GetChildContextLevel;
    property ClassRef: TInstantIQLClassRef read FClassRef write SetClassRef;
    property ClassTablePath: string read GetClassTablePath;
    property CriteriaCount: Integer read GetCriteriaCount;
    property Criterias[Index: Integer]: string read GetCriterias;
    property Delimiters: string read FDelimiters;
    property IdDataType: TInstantDataType read FIdDataType;
    property ObjectClassName: string read FObjectClassName write SetObjectClassName;
    property ObjectClassMetadata: TInstantClassMetadata read GetObjectClassMetadata;
    property ParentContext: TInstantTranslationContext read FParentContext;
    property Quote: Char read FQuote;
    property Specifier: TInstantIQLSpecifier read FSpecifier write SetSpecifier;
    property Statement: TInstantIQLObject read FStatement;
    property TableName: string read GetTableName;
    property TableAlias: string read GetTableAlias;
    property TablePathAliases[Index: Integer]: string read GetTablePathAliases;
    property TablePathCount: Integer read GetTablePathCount;
    property TablePaths[Index: Integer]: string read GetTablePaths;
    function QuoteString(const Str: string): string;
    // Use this property to ask for a particular load mode, such as a burst mode
    // in which objects are retrieved in batches saving roundtrips to the
    // database. Load modes require specific command translation, that's why
    // this class is involved. This property is set at creation time. The
    // requested mode might not be supported: read ActualLoadMode to know which
    // load mode will actually be used for the statement.
    property RequestedBurstLoadMode: TInstantLoadMode read FRequestedLoadMode;
    // Equals the value of RequestedLoadMode if the mode is supported for the
    // particular IQL query. Otherwise it will contain the fallback mode.
    property ActualLoadMode: TInstantLoadMode read FActualLoadMode;
  end;

  TInstantRelationalTranslator = class(TInstantQueryTranslator)
  private
    FContext: TInstantTranslationContext;
    function GetQuery: TInstantCustomRelationalQuery;
    function ReplaceWildcard(const Str: string): string;
    function GetConnector: TInstantRelationalConnector;
  protected
    procedure BeforeTranslate; override;
    procedure Clear; override;
    function GetDelimiters: string; virtual;
    function GetQuote: Char; virtual;
    function GetWildcard: string; virtual;
    function HasConnector: Boolean;
    function IncludeOrderFields: Boolean; virtual;
    function InternalGetObjectClassMetadata: TInstantClassMetadata; virtual;
    function InSubquery(const AObject: TInstantIQLObject; out ASubQuery: TInstantIQLSubquery): Boolean;
    // Returns True if the given attribute is a "root" attribute. Root
    // attributes are Class and Id.
    function IsPrimary(AObject: TInstantIQLObject): Boolean;
    function TranslateObject(AObject: TInstantIQLObject;
      Writer: TInstantIQLWriter): Boolean; override;
    function TranslateClassRef(ClassRef: TInstantIQLClassRef;
      Writer: TInstantIQLWriter): Boolean; virtual;
    function TranslateClause(Clause: TInstantIQLClause;
      Writer: TInstantIQLWriter): Boolean; virtual;
    function TranslateConstant(Constant: TInstantIQLConstant;
      Writer: TInstantIQLWriter): Boolean; virtual;
    function TranslateFunction(AFunction: TInstantIQLFunction;
      Writer: TInstantIQLWriter): Boolean; virtual;
    function TranslateSubqueryFunction(ASubqueryFunction: TInstantIQLSubqueryFunction;
      Writer: TInstantIQLWriter): Boolean; virtual;
    function TranslateFunctionName(const FunctionName: string;
      Writer: TInstantIQLWriter): Boolean; virtual;
    function TranslateSubqueryFunctionName(const ASubqueryFunctionName: string;
      Writer: TInstantIQLWriter): Boolean; virtual;
    function TranslateKeyword(const Keyword: string; Writer: TInstantIQLWriter):
      Boolean; override;
    function TranslatePath(Path: TInstantIQLPath; Writer: TInstantIQLWriter):
      Boolean; virtual;
    function TranslateSpecifier(Specifier: TInstantIQLSpecifier;
      Writer: TInstantIQLWriter): Boolean; virtual;
    property Connector: TInstantRelationalConnector read GetConnector;
    property Delimiters: string read GetDelimiters;
    property Quote: Char read GetQuote;
    property Wildcard: string read GetWildcard;
  public
    property Context: TInstantTranslationContext read FContext;
    destructor Destroy; override;
    property Query: TInstantCustomRelationalQuery read GetQuery;
  end;

  TInstantNavigationalQuery = class(TInstantCustomRelationalQuery)
  private
    FObjectRowList: TList;
    function CreateObject(Row: Integer): TObject;
    procedure DestroyObjectRowList;
    function GetObjectRowList: TList;
    function GetObjectRowCount: Integer;
    function GetObjectRows(Index: Integer): PObjectRow;
    procedure InitObjectRows(List: TList; FromIndex, ToIndex: Integer);
    property ObjectRowList: TList read GetObjectRowList;
  protected
    function GetActive: Boolean; override;
    function GetDataSet: TDataSet; virtual;
    function GetRowCount: Integer; virtual;
    function GetRowNumber: Integer; virtual;
    function InternalAddObject(AObject: TObject): Integer; override;
    procedure InternalClose; override;
    procedure InternalGetInstantObjectRefs(List: TInstantObjectReferenceList);
      override;
    function InternalGetObjectCount: Integer; override;
    function InternalGetObjects(Index: Integer): TObject; override;
    function InternalIndexOfObject(AObject: TObject): Integer; override;
    procedure InternalInsertObject(Index: Integer; AObject: TObject); override;
    procedure InternalOpen; override;
    procedure InternalRefreshObjects; override;
    procedure InternalReleaseObject(AObject: TObject); override;
    function InternalRemoveObject(AObject: TObject): Integer; override;
    function IsSequenced: Boolean; virtual;
    function ObjectFetched(Index: Integer): Boolean; override;
    function RecNoOfObject(AObject: TInstantObject): Integer; virtual;
    procedure SetRowNumber(Value: Integer); virtual;
    property DataSet: TDataSet read GetDataSet;
    property ObjectRowCount: Integer read GetObjectRowCount;
    property ObjectRows[Index: Integer]: PObjectRow read GetObjectRows;
  public
    destructor Destroy; override;
    property RowCount: Integer read GetRowCount;
    property RowNumber: Integer read GetRowNumber write SetRowNumber;
  end;

  // Backward compatibility
  TInstantRelationalQuery = TInstantNavigationalQuery;

  // Holds object data in the current record of a dataset specified upon
  // creation. May hold data for several objects, locating the correct
  // record each time it copies data to an object.
  TInstantDataSetObjectData = class(TInstantAbstractObjectData)
  private
    FDataSet: TDataSet;
    FRecNo: Integer;
    FIdField: TField;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
  public
    constructor CreateAndInit(const ADataSet: TDataSet);
    property DataSet: TDataSet read FDataSet;
    function Locate(const AObjectId: string): Boolean;
  end;

  TInstantSQLQuery = class(TInstantCustomRelationalQuery)
  private
    FObjectReferenceList: TInstantObjectReferenceList;
    FParamsObject: TParams;
    FStatement: string;
    FDataSet: TDataSet;
    procedure DestroyObjectReferenceList;
    function GetObjectReferenceCount: Integer;
    function GetObjectReferenceList: TInstantObjectReferenceList;
    function GetParamsObject: TParams;
    procedure InitObjectReferences;
  protected
    function GetActive: Boolean; override;
    function AcquireDataSet(const AStatement: string; AParams: TParams):
      TDataSet; virtual;
    procedure ReleaseDataSet;
    function GetParams: TParams; override;
    function GetStatement: string; override;
    function InternalAddObject(AObject: TObject): Integer; override;
    procedure InternalClose; override;
    procedure InternalGetInstantObjectRefs(List: TInstantObjectReferenceList);
      override;
    function InternalGetObjectCount: Integer; override;
    function InternalGetObjects(Index: Integer): TObject; override;
    function InternalIndexOfObject(AObject: TObject): Integer; override;
    procedure InternalInsertObject(Index: Integer; AObject: TObject); override;
    procedure InternalOpen; override;
    procedure InternalReleaseObject(AObject: TObject); override;
    function InternalRemoveObject(AObject: TObject): Integer; override;
    procedure SetParams(Value: TParams); override;
    function ObjectFetched(Index: Integer): Boolean; override;
    procedure SetStatement(const Value: string); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
    property ObjectReferenceCount: Integer read GetObjectReferenceCount;
    property ObjectReferenceList: TInstantObjectReferenceList read
        GetObjectReferenceList;
    property ParamsObject: TParams read GetParamsObject;
  public
    destructor Destroy; override;
  end;

  TInstantRelationalConnectionDef = class(TInstantConnectionDef)
  end;

  TInstantConnectionBasedConnectionDef = class(TInstantRelationalConnectionDef)
  private
    FLoginPrompt: Boolean;
  protected
    function CreateConnection(AOwner: TComponent): TCustomConnection; virtual;
      abstract;
    procedure InitConnector(Connector: TInstantConnector); override;
  public
    constructor Create(Collection: TCollection); override;
  published
    property LoginPrompt: Boolean read FLoginPrompt write FLoginPrompt
      default True;
  end;

var
  InstantLogProc: procedure (const AString: string) of object;

implementation

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
{$IFDEF LINUX}
  Types,
{$ENDIF}
{$IFDEF D6+}
  Variants,
  DateUtils,
{$ENDIF}
  TypInfo, InstantUtils, InstantRtti;

const
  ConcurrencyParamName = 'IO_Concur';
  PersistentIdParamName = 'IO_PersId';

{$IFDEF IO_STATEMENT_LOGGING}
procedure InstantLogStatement(const Caption, AStatement: string;
  AParams: TParams = nil);
var
  S: string;
  g: Integer;
begin
  S := Caption + AStatement;
  if Assigned(AParams) then
  begin
    for g := 0 to AParams.Count - 1 do begin
      S := S + sLineBreak + '  ' +
        AParams[g].Name + ': ' + GetEnumName(TypeInfo(TFieldType),
        Ord(AParams[g].DataType)) +
        ' = ' + AParams[g].AsString;
    end;
  end;
{$IFDEF MSWINDOWS}
  OutputDebugString(PChar(S));
{$ENDIF}
  if Assigned(InstantLogProc) then
    InstantLogProc(S);
end;
{$ENDIF}

function ConcatPath(const APathText, AttribName: string): string;
begin
  Result := Format('%s%s%s', [APathText, InstantDot, AttribName]);
end;

function ExtractTarget(const PathStr: string): string;
var
  I: Integer;
begin
  I := InstantRightPos(InstantDot, PathStr);
  Result := Copy(PathStr, I + 1, Length(PathStr) - I)
end;

function IsRootAttribute(const AttributeName: string): Boolean;
begin
  Result := SameText(AttributeName, InstantClassFieldName) or
    SameText(AttributeName, InstantIdFieldName);
end;

procedure CollectObjects(AObject: TInstantIQLObject;
  AClassType: TInstantIQLObjectClass; AList: TList;
  const AStopClassTypes: array of TInstantIQLObjectClass);
var
  I: Integer;
  LObject: TInstantIQLObject;

  function IsStopClassType(const AClassType: TClass): Boolean;
  var
    LClassTypeIndex: Integer;
  begin
    Result := True;
    for LClassTypeIndex := Low(AStopClassTypes) to High(AStopClassTypes) do
      if AClassType = AStopClassTypes[LClassTypeIndex] then
        Exit;
    Result := False;
  end;

begin
  if not (Assigned(AObject) and Assigned(AList)) then
    Exit;
  for I := 0 to Pred(AObject.ObjectCount) do
  begin
    LObject := AObject[I];
    if IsStopClassType(LObject.ClassType) then
      Continue;
    if LObject is AClassType then
      AList.Add(LObject);
    CollectObjects(LObject, AClassType, AList, AStopClassTypes)
  end;
end;

procedure WriteAnd(Writer: TInstantIQLWriter);
begin
  Writer.WriteString(' AND ');
end;

{ TInstantCustomRelationalBroker }

constructor TInstantCustomRelationalBroker.Create(AConnector: TInstantConnector);
begin
  inherited;
  FStatementCacheCapacity := 0;
end;

destructor TInstantCustomRelationalBroker.Destroy;
begin
  FreeAndNil(FStatementCache);
  inherited;
end;

procedure TInstantCustomRelationalBroker.DisposeMap(AObject: TInstantObject;
  const AObjectId: string; Map: TInstantAttributeMap;
  ConflictAction: TInstantConflictAction; Info: PInstantOperationInfo);
begin
  EnsureResolver(Map).DisposeMap(AObject, Map, ConflictAction, Info);
end;

function TInstantCustomRelationalBroker.Execute(const AStatement: string;
  AParams: TParams): Integer;
begin
  Result := 0;
end;

function TInstantCustomRelationalBroker.GetConnector: TInstantRelationalConnector;
begin
  Result := inherited Connector as TInstantRelationalConnector;
end;

function TInstantCustomRelationalBroker.GetDBMSName: string;
begin
  Result := '';
end;

function TInstantCustomRelationalBroker.GetSQLDelimiters: string;
begin
  Result := '';
end;

function TInstantCustomRelationalBroker.GetSQLQuote: Char;
begin
  Result := '"';
end;

function TInstantCustomRelationalBroker.GetSQLWildcard: string;
begin
  Result := '%';
end;

function TInstantCustomRelationalBroker.GetStatementCache: TInstantStatementCache;
begin
  if not Assigned(FStatementCache) then
  begin
    FStatementCache := TInstantStatementCache.Create(nil);
    FStatementCache.Capacity := FStatementCacheCapacity;
  end;
  Result := FStatementCache;
end;

function TInstantCustomRelationalBroker.InternalDisposeObject(
  AObject: TInstantObject; ConflictAction: TInstantConflictAction): Boolean;
begin
  Result := PerformOperation(AObject, AObject.Id, otDispose, DisposeMap,
    ConflictAction);
end;

function TInstantCustomRelationalBroker.InternalRetrieveObject(
  AObject: TInstantObject; const AObjectId: string;
  ConflictAction: TInstantConflictAction;
  const AObjectData: TInstantAbstractObjectData = nil): Boolean;
begin
  // RetrieveMap will use this as an implicit argument.
  // Making it explicit is too cumbersome since no other TInstantBrokerOperation
  // needs it.
  FObjectData := AObjectData;
  try
    Result := PerformOperation(AObject, AObjectId, otRetrieve, RetrieveMap,
      ConflictAction);
  finally
    FObjectData := nil;
  end;
end;

function TInstantCustomRelationalBroker.InternalStoreObject(
  AObject: TInstantObject; ConflictAction: TInstantConflictAction): Boolean;
begin
  Result := PerformOperation(AObject, AObject.Id, otStore, StoreMap,
    ConflictAction);
end;

function TInstantCustomRelationalBroker.PerformOperation(
  AObject: TInstantObject; const AObjectId: string;
  OperationType: TInstantOperationType; Operation: TInstantBrokerOperation;
  ConflictAction: TInstantConflictAction): Boolean;

  function OperationRequired(Map: TInstantAttributeMap): Boolean;
  var
    I: Integer;
    Attrib: TInstantAttribute;
  begin
    case OperationType of
      otStore:
        begin
          Result := not AObject.IsPersistent;
          if not Result then
            for I := 0 to Pred(Map.Count) do
            begin
              Attrib := AObject.AttributeByName(Map[I].Name);
              Result := Attrib.IsMandatory or Attrib.IsChanged;
              if Result then
                Exit;
            end;
        end;
      otRetrieve, otDispose:
        Result := True;
    else
      Result := False;
    end;
  end;

var
  I: Integer;
  RootMap, Map: TInstantAttributeMap;
  Info: TInstantOperationInfo;
begin
  with Info do
  begin
    Success := False;
    Conflict := False;
  end;
  with AObject.Metadata do
  begin
    RootMap := StorageMaps.RootMap;
    Operation(AObject, AObjectId, RootMap, ConflictAction, @Info);
    Result := Info.Success;
    if Result then
      for I := 0 to Pred(StorageMaps.Count) do
      begin
        Map := StorageMaps[I];
        if (Map <> RootMap) and (Info.Conflict or OperationRequired(Map)) then
          Operation(AObject, AObjectId, Map);
      end;
  end;
end;

procedure TInstantCustomRelationalBroker.RetrieveMap(AObject: TInstantObject;
  const AObjectId: string; Map: TInstantAttributeMap;
  ConflictAction: TInstantConflictAction; Info: PInstantOperationInfo);
begin
  EnsureResolver(Map).RetrieveMap(AObject, AObjectId, Map, ConflictAction, Info, FObjectData);
end;

procedure TInstantCustomRelationalBroker.SetStatementCacheCapacity(const AValue: Integer);
begin
  if FStatementCacheCapacity <> AValue then
  begin
    FStatementCacheCapacity := AValue;
    if FStatementCacheCapacity = 0 then
      FreeAndNil(FStatementCache)
    else if Assigned(FStatementCache) then
      FStatementCache.Capacity := FStatementCacheCapacity;
  end;
end;

procedure TInstantCustomRelationalBroker.StoreMap(AObject: TInstantObject;
  const AObjectId: string; Map: TInstantAttributeMap;
  ConflictAction: TInstantConflictAction; Info: PInstantOperationInfo);

  // Always storing fixes #880713
  {function MustStoreMap: Boolean;
  var
    I: Integer;
    Attrib: TInstantAttribute;
  begin
    Result := Map.IsRootMap;
    if Result then
      Exit;
    for I := 0 to Pred(Map.Count) do
    begin
      Attrib := AObject.AttributeByName(Map[I].Name);
      Result := Attrib.IsMandatory or not Attrib.IsDefault;
      if Result then
        Exit;
    end;
    Result := False;
  end;}

var
  Resolver: TInstantCustomResolver;
  {MustStore: Boolean;}
begin
  {MustStore := MustStoreMap;}
  {if MustStore or AObject.IsPersistent then
  begin}
    Resolver := EnsureResolver(Map);
    {if MustStore then}
      Resolver.StoreMap(AObject, Map, ConflictAction, Info)
    {else if AObject.IsPersistent then
      Resolver.DisposeMap(AObject, Map, ConflictAction, Info);
  end;}
end;

{ TInstantNavigationalBroker }

destructor TInstantNavigationalBroker.Destroy;
begin
  FResolverList.Free;
  inherited;
end;

function TInstantNavigationalBroker.EnsureResolver(
  Map: TInstantAttributeMap): TInstantCustomResolver;
var
  TableName: string;
begin
  TableName := Map.Name;
  Result := FindResolver(TableName);
  if not Assigned(Result) then
  begin
    Result := CreateResolver(TableName);
    ResolverList.Add(Result);
  end;
end;

function TInstantNavigationalBroker.FindResolver(
  const TableName: string): TInstantNavigationalResolver;
var
  I: Integer;
begin
  for I := 0 to Pred(ResolverCount) do
  begin
    Result := Resolvers[I];
    if SameText(TableName, Result.TableName) then
      Exit;
  end;
  Result := nil;
end;

function TInstantNavigationalBroker.GetResolverCount: Integer;
begin
 Result := ResolverList.Count;
end;

function TInstantNavigationalBroker.GetResolverList: TObjectList;
begin
  if not Assigned(FResolverList) then
    FResolverList := TObjectList.Create;
  Result := FResolverList;
end;

function TInstantNavigationalBroker.GetResolvers(
  Index: Integer): TInstantNavigationalResolver;
begin
  Result := ResolverList[Index] as TInstantNavigationalResolver;
end;

destructor TInstantSQLBroker.Destroy;
begin
  FGenerator.Free;
  FResolverList.Free;
  inherited;
end;

{ TInstantSQLBroker }

function TInstantSQLBroker.AcquireDataSet(const AStatement: string;
  AParams: TParams): TDataSet;
var
  CachedStatement: TInstantStatement;
begin
  {$IFDEF IO_STATEMENT_LOGGING}
  InstantLogStatement(InstantLogStatementSelect, AStatement, AParams);
  {$ENDIF}
  Result := nil;
  if FStatementCacheCapacity <> 0 then
  begin
    CachedStatement := StatementCache.GetStatement(AStatement);
    if Assigned(CachedStatement) then
    begin
      Result := TDataSet(CachedStatement.StatementDataSet);
      // The dataset might be already open to serve a burst mode retrieval,
      // in which case we can reuse it unless it's parametric.
      if Result.Active then
      begin
        if AParams.Count = 0 then
          Result.First
        else
        begin
          Result.Close;
          AssignDataSetParams(Result, AParams);
          Result.Open;
        end;
      end
      else
      begin
        AssignDataSetParams(Result, AParams);
        Result.Open;
      end;
    end;
  end;
  if not Assigned(Result) then
  begin
    Result := CreateDataSet(AStatement, AParams);
    try
      if Assigned(AParams) and (FStatementCacheCapacity <> 0) then
        StatementCache.AddStatement(AStatement, Result);
    except
      if FStatementCacheCapacity <> 0 then
        StatementCache.RemoveStatement(AStatement);
      Result.Free;
      raise;
    end;
  end;
end;

procedure TInstantSQLBroker.AssignDataSetParams(DataSet: TDataSet; AParams: TParams);
begin
  raise EInstantError.CreateFmt(SMissingImplementation, ['AssignDataSetParams', ClassName]);
end;

function TInstantSQLBroker.EnsureResolver(
  AMap: TInstantAttributeMap): TInstantCustomResolver;
begin
  Result := FindResolver(AMap);
  if not Assigned(Result) then
  begin
    Result := CreateResolver(AMap);
    ResolverList.Add(Result)
  end;
end;

function TInstantSQLBroker.FindResolver(
  AMap: TInstantAttributeMap): TInstantSQLResolver;
var
  I: Integer;
begin
  for I := 0 to Pred(ResolverCount) do
  begin
    Result := Resolvers[I];
    if Result.Map = AMap then
      Exit;
  end;
  Result := nil;
end;

class function TInstantSQLBroker.GeneratorClass: TInstantSQLGeneratorClass;
begin
  Result := TInstantSQLGenerator;
end;

function TInstantSQLBroker.GetGenerator: TInstantSQLGenerator;
begin
  if not Assigned(FGenerator) then
    FGenerator := GeneratorClass.Create(Self);
  Result := FGenerator;
end;

function TInstantSQLBroker.GetResolverCount: Integer;
begin
  Result := ResolverList.Count;
end;

function TInstantSQLBroker.GetResolverList: TObjectList;
begin
  if not Assigned(FResolverList) then
    FResolverList := TObjectList.Create;
  Result := FResolverList;
end;

function TInstantSQLBroker.GetResolvers(
  Index: Integer): TInstantSQLResolver;
begin
  Result := ResolverList[Index] as TInstantSQLResolver;
end;

procedure TInstantSQLBroker.InternalBuildDatabase(Scheme: TInstantScheme);
var
  I, J: Integer;
  TableMetadata: TInstantTableMetadata;
  IndexMetadata: TInstantIndexMetadata;
begin
  if not Assigned(Scheme) then
    Exit;
  with Scheme do
  begin
    for I := 0 to Pred(TableMetadataCount) do
    begin
      TableMetadata := TableMetadatas[I];
      try
        Execute(Generator.GenerateDropTableSQL(TableMetadata));
      except
      end;
      Execute(Generator.GenerateCreateTableSQL(TableMetadata));
      with TableMetadata do
      begin
        for J := 0 to Pred(IndexMetadatas.Count) do
        begin
          IndexMetadata := IndexMetadatas[J];
          if not (ixPrimary in IndexMetadata.Options) then
            Execute(Generator.GenerateCreateIndexSQL(IndexMetadata));
        end;
      end;
    end;
  end;
end;

procedure TInstantSQLBroker.ReleaseDataSet(const ADataSet: TDataSet);
var
  I: Integer;
  LStatement: TInstantStatement;
begin
  if Assigned(FStatementCache) then
  begin
    I := FStatementCache.IndexOfStatementDataSet(ADataSet);
    if I >= 0 then
    begin
      LStatement := FStatementCache.GetStatementByIndex(I);
      if LStatement.ReleaseDataSetRef <= 0 then
        ADataSet.Close;
      Exit;
    end;
  end;
  ADataSet.Free;
end;

{ TInstantRelationalConnector }

procedure TInstantRelationalConnector.DoGetDataSet(const CommandText: string;
  var DataSet: TDataSet);
begin
  if Assigned(FOnGetDataSet) then
    FOnGetDataSet(Self, CommandText, DataSet)
  else
    GetDataSet(CommandText, DataSet);
end;

procedure TInstantRelationalConnector.DoInitDataSet(
  const CommandText: string; DataSet: TDataSet);
begin
  if Assigned(FOnInitDataSet) then
    FOnInitDataSet(Self, CommandText, DataSet)
  else
    InitDataSet(CommandText, DataSet);
end;

function TInstantRelationalConnector.GetBroker: TInstantCustomRelationalBroker;
begin
  Result := inherited Broker as TInstantCustomRelationalBroker;
end;

procedure TInstantRelationalConnector.GetDataSet(const CommandText: string;
  var DataSet: TDataSet);
begin
end;

function TInstantRelationalConnector.GetDBMSName: string;
begin
  Result := Broker.DBMSName;
end;

procedure TInstantRelationalConnector.InitDataSet(const CommandText: string;
  DataSet: TDataSet);
begin
end;

function TInstantRelationalConnector.InternalCreateScheme(
  Model: TInstantModel): TInstantScheme;
begin
  Result := TInstantScheme.Create;
  try
    Result.IdDataType := IdDataType;
    Result.IdSize := IdSize;
    Result.BlobStreamFormat := BlobStreamFormat;
    Result.Catalog := TInstantModelCatalog.Create(Result, Model);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

constructor TInstantConnectionBasedConnector.Create(AOwner: TComponent);
begin
  inherited;
  FLoginPrompt := True;
end;

{ TInstantConnectionBasedConnector }

procedure TInstantConnectionBasedConnector.AfterConnectionChange;
begin
end;

procedure TInstantConnectionBasedConnector.AssignLoginOptions;
begin
  if HasConnection then
  begin
    FConnection.LoginPrompt := FLoginPrompt;
  end;
end;

procedure TInstantConnectionBasedConnector.BeforeConnectionChange;
begin
end;

procedure TInstantConnectionBasedConnector.CheckConnection;
begin
  InstantCheckConnection(FConnection);
end;

procedure TInstantConnectionBasedConnector.DoAfterConnectionChange;
begin
  if Assigned(FConnection) then
    FConnection.FreeNotification(Self);
  AfterConnectionChange;
end;

procedure TInstantConnectionBasedConnector.DoBeforeConnectionChange;
begin
  try
    BeforeConnectionChange;
  finally
    if Assigned(FConnection) then
      FConnection.RemoveFreeNotification(Self);
  end;
end;

function TInstantConnectionBasedConnector.GetConnected: Boolean;
begin
  if HasConnection then
    Result := Connection.Connected
  else
    Result := inherited GetConnected;
end;

function TInstantConnectionBasedConnector.GetConnection: TCustomConnection;
begin
  if not (csDesigning in ComponentState) then
    CheckConnection;
  AssignLoginOptions;
  Result := FConnection;
end;

function TInstantConnectionBasedConnector.GetLoginPrompt: Boolean;
begin
  if HasConnection then
    FLoginPrompt := FConnection.LoginPrompt;
  Result := FLoginPrompt;
end;

function TInstantConnectionBasedConnector.HasConnection: Boolean;
begin
  Result := Assigned(FConnection);
end;

procedure TInstantConnectionBasedConnector.InternalConnect;
begin
  CheckConnection;
  Connection.Open;
end;

procedure TInstantConnectionBasedConnector.InternalDisconnect;
begin
  if HasConnection then
    Connection.Close;
end;

procedure TInstantConnectionBasedConnector.Notification(
  AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (AComponent = FConnection) and (Operation = opRemove) then
  begin
    Disconnect;
    FConnection := nil;
  end;
end;

procedure TInstantConnectionBasedConnector.SetConnection(
  Value: TCustomConnection);
begin
  if Value <> FConnection then
  begin
    Disconnect;
    DoBeforeConnectionChange;
    FConnection := Value;
    AssignLoginOptions;
    DoAfterConnectionChange;
  end;
end;

procedure TInstantConnectionBasedConnector.SetLoginPrompt(
  const Value: Boolean);
begin
  FLoginPrompt := Value;
  AssignLoginOptions;
end;

{ TInstantCustomResolver }

constructor TInstantCustomResolver.Create(
  ABroker: TInstantCustomRelationalBroker);
begin
  if not Assigned(ABroker) then
    raise EInstantError.Create(SUnassignedBroker);
  inherited Create;
  FBroker := ABroker;
end;

function TInstantCustomResolver.CreateEmbeddedObjectInputStream(
  const AConnector: TInstantConnector; const AField: TField): TStream;
begin
  Assert(Assigned(AConnector));
  Assert(Assigned(AField));

  {$IFDEF D12+}
  if AConnector.BlobStreamFormat = sfBinary then
    Result := TBytesStream.Create(AField.AsBytes)
  else
  {$ENDIF}
  Result := TInstantStringStream.Create(AField.AsString);
end;

function TInstantCustomResolver.CreateEmbeddedObjectOutputStream(
  const AConnector: TInstantConnector): TStream;
begin
  Assert(Assigned(AConnector));

  {$IFDEF D12+}
  if AConnector.BlobStreamFormat = sfBinary then
    Result := TBytesStream.Create
  else
    Result := TStringStream.Create('', TEncoding.UTF8);
  {$ELSE}
  Result := TStringStream.Create('');
  {$ENDIF}
end;

procedure TInstantCustomResolver.AssignEmbeddedObjectStreamToField(
  const AConnector: TInstantConnector; const AStream: TStream; const AField: TField);
begin
  Assert(Assigned(AConnector));
  Assert(Assigned(AStream));
  Assert(Assigned(AField));
  Assert(AField is TBlobField);

  if AConnector.BlobStreamFormat = sfBinary then
    TBlobField(AField).LoadFromStream(AStream)
  else
    AField.AsString := (AStream as TStringStream).DataString;
end;

procedure TInstantCustomResolver.DisposeMap(AObject: TInstantObject;
  Map: TInstantAttributeMap; ConflictAction: TInstantConflictAction;
  Info: PInstantOperationInfo);
begin
  InternalDisposeMap(AObject, Map, ConflictAction, Info);
end;

procedure TInstantCustomResolver.DisposeObject(AObject: TInstantObject;
    Conflict: TInstantConflictAction);
var
  ObjStore: TInstantObjectStore;
begin
  ObjStore := AObject.Connector.EnsureObjectStore(AObject.ClassType);
  ObjStore.DisposeObject(AObject, caIgnore);
end;

procedure TInstantCustomResolver.InternalDisposeMap(
  AObject: TInstantObject; Map: TInstantAttributeMap;
  ConflictAction: TInstantConflictAction; Info: PInstantOperationInfo);
begin
end;

procedure TInstantCustomResolver.InternalRetrieveMap(
  AObject: TInstantObject; const AObjectId: string;
  Map: TInstantAttributeMap; ConflictAction: TInstantConflictAction;
  AInfo: PInstantOperationInfo;
  const AObjectData: TInstantAbstractObjectData = nil);
begin
end;

procedure TInstantCustomResolver.InternalStoreMap(AObject: TInstantObject;
  Map: TInstantAttributeMap; ConflictAction: TInstantConflictAction;
  Info: PInstantOperationInfo);
begin
end;

function TInstantCustomResolver.KeyViolation(AObject: TInstantObject;
  const AObjectId: string; E: Exception): EInstantKeyViolation;
var
  ObjectClassName: string;
begin
  if Assigned(AObject) then
    ObjectClassName := AObject.ClassName
  else
    ObjectClassName := '';
  Result := EInstantKeyViolation.CreateFmt(SKeyViolation,
    [ObjectClassName, AObjectId], E);
end;

procedure TInstantCustomResolver.RetrieveMap(AObject: TInstantObject;
  const AObjectId: string; Map: TInstantAttributeMap;
  ConflictAction: TInstantConflictAction; Info: PInstantOperationInfo;
  const AObjectData: TInstantAbstractObjectData = nil);
begin
  InternalRetrieveMap(AObject, AObjectId, Map, ConflictAction, Info, AObjectData);
end;

procedure TInstantCustomResolver.StoreMap(AObject: TInstantObject;
  Map: TInstantAttributeMap; ConflictAction: TInstantConflictAction;
  Info: PInstantOperationInfo);
begin
  InternalStoreMap(AObject, Map, ConflictAction, Info);
end;

procedure TInstantCustomResolver.StoreObject(AObject: TInstantObject; Conflict:
    TInstantConflictAction);
var
  Conn: TInstantConnector;
  ObjStore: TInstantObjectStore;
begin
  Conn := AObject.Connector;
  ObjStore := Conn.EnsureObjectStore(AObject.ClassType);
  ObjStore.StoreObject(AObject, caIgnore);
end;

constructor TInstantNavigationalResolver.Create(
  ABroker: TInstantNavigationalBroker; const ATableName: string);
begin
  inherited Create(ABroker);
  FTableName := ATableName;
end;

destructor TInstantNavigationalResolver.Destroy;
begin
  FreeAndNil(FNavigationalLinkResolvers);
  FreeDataSet;
  inherited;
end;

{ TInstantNavigationalResolver }

procedure TInstantNavigationalResolver.Append;
begin
  DataSet.Append;
end;

procedure TInstantNavigationalResolver.Cancel;
begin
  DataSet.Cancel;
end;

function TInstantNavigationalResolver.CheckConflict(AObject: TInstantObject;
  const AObjectId: string; ConflictAction: TInstantConflictAction): Boolean;
var
  Field: TField;
begin
  Field := FieldByName(InstantUpdateCountFieldName);
  Result := Field.AsInteger <> AObject.UpdateCount;
  if Result and (ConflictAction = caFail) then
    raise EInstantConflict.CreateFmt(SUpdateConflict,
      [AObject.ClassName, AObjectId]);
end;

procedure TInstantNavigationalResolver.ClearAttribute(AObject: TInstantObject;
  AttributeMetadata: TInstantAttributeMetadata);
var
  Attribute: TInstantAttribute;
begin
  with AttributeMetadata do
  begin
    Attribute := AObject.AttributeByName(Name);
    case AttributeType of
      atInteger:
        ClearInteger(Attribute as TInstantInteger);
      atFloat:
        ClearFloat(Attribute as TInstantFloat);
      atCurrency:
        ClearCurrency(Attribute as TInstantCurrency);
      atBoolean:
        ClearBoolean(Attribute as TInstantBoolean);
      atString:
        ClearString(Attribute as TInstantString);
      atDateTime:
        ClearDateTime(Attribute as TInstantDateTime);
      atDate:
        ClearDate(Attribute as TInstantDate);
      atTime:
        ClearTime(Attribute as TInstantTime);
      atBlob:
        ClearBlob(Attribute as TInstantBlob);
      atGraphic:
        ClearBlob(Attribute as TInstantGraphic);
      atMemo:
        ClearMemo(Attribute as TInstantMemo);
      atPart:
        ClearPart(Attribute as TInstantPart);
      atReference:
        ClearReference(Attribute as TInstantReference);
      atParts:
        ClearParts(Attribute as TInstantParts);
      atReferences:
        ClearReferences(Attribute as TInstantReferences);
    end;
  end;
end;

procedure TInstantNavigationalResolver.ClearBlob(Attribute: TInstantBlob);
begin
end;

procedure TInstantNavigationalResolver.ClearBoolean(Attribute: TInstantBoolean);
begin
end;

procedure TInstantNavigationalResolver.ClearCurrency(Attribute: TInstantCurrency);
begin
end;

procedure TInstantNavigationalResolver.ClearDateTime(Attribute: TInstantDateTime);
begin
end;

procedure TInstantNavigationalResolver.ClearDate(Attribute: TInstantDate);
begin
end;

procedure TInstantNavigationalResolver.ClearTime(Attribute: TInstantTime);
begin
end;

procedure TInstantNavigationalResolver.ClearFloat(Attribute: TInstantFloat);
begin
end;

procedure TInstantNavigationalResolver.ClearInteger(Attribute: TInstantInteger);
begin
end;

procedure TInstantNavigationalResolver.ClearMemo(Attribute: TInstantMemo);
begin
end;

procedure TInstantNavigationalResolver.ClearPart(Attribute: TInstantPart);
begin
  if Attribute.Metadata.StorageKind = skExternal then
    DisposeObject(Attribute.Value, caIgnore);
end;

procedure TInstantNavigationalResolver.ClearParts(Attribute: TInstantParts);
var
  I: Integer;
  LinkDatasetResolver: TInstantNavigationalLinkResolver;
begin
  if Attribute.Metadata.StorageKind = skExternal then
  begin
    for I := 0 to Pred(Attribute.Count) do
      DisposeObject(Attribute.Items[I], caIgnore);
    LinkDatasetResolver :=
        GetLinkDatasetResolver(Attribute.Metadata.ExternalStorageName);
    LinkDatasetResolver.ClearAttributeLinkRecords;
  end;
end;

procedure TInstantNavigationalResolver.ClearReference(
  Attribute: TInstantReference);
begin
end;

procedure TInstantNavigationalResolver.ClearReferences(
  Attribute: TInstantReferences);
var
  LinkDatasetResolver: TInstantNavigationalLinkResolver;
begin
  if Attribute.Metadata.StorageKind = skExternal then
  begin
    LinkDatasetResolver :=
        GetLinkDatasetResolver(Attribute.Metadata.ExternalStorageName);
    LinkDatasetResolver.ClearAttributeLinkRecords;
  end;
end;

procedure TInstantNavigationalResolver.ClearString(Attribute: TInstantString);
begin
end;

procedure TInstantNavigationalResolver.Close;
begin
  DataSet.Close;
end;

function TInstantNavigationalResolver.CreateLocateVarArray(
  const AObjectClassName,
  AObjectId: string): Variant;
begin
  Result := VarArrayOf([AObjectClassName, AObjectId]);
end;

procedure TInstantNavigationalResolver.Delete;
begin
  DataSet.Delete;
end;

procedure TInstantNavigationalResolver.Edit;
begin
  DataSet.Edit;
end;

function TInstantNavigationalResolver.FieldByName(
  const FieldName: string): TField;
begin
  Result := DataSet.FieldByName(FieldName);
end;

function TInstantNavigationalResolver.FieldHasObjects(Field: TField): Boolean;
begin
  Result := Length(Field.AsString) > 1;
end;

function TInstantNavigationalResolver.FindLinkDatasetResolver(const ATableName:
    string): TInstantNavigationalLinkResolver;
var
  I: Integer;
begin
  for I := 0 to Pred(NavigationalLinkResolvers.Count) do
  begin
    Result := NavigationalLinkResolvers[I] as TInstantNavigationalLinkResolver;
    if SameText(ATableName, Result.TableName) then
      Exit;
  end;
  Result := nil;
end;

procedure TInstantNavigationalResolver.FreeDataSet;
begin
  if FFreeDataSet then
    FreeAndNil(FDataSet);
end;

function TInstantNavigationalResolver.GetBroker: TInstantNavigationalBroker;
begin
  Result := inherited Broker as TInstantNavigationalBroker;
end;

function TInstantNavigationalResolver.GetDataSet: TDataSet;
begin
  if not Assigned(FDataSet) then
  begin
    Broker.Connector.DoGetDataSet(TableName, FDataSet);
    if not Assigned(FDataSet) then
    begin
      FDataSet := CreateDataSet;
      FFreeDataSet := True;
    end;
    Broker.Connector.DoInitDataSet(TableName, FDataSet);
  end;
  Result := FDataSet;
end;

function TInstantNavigationalResolver.GetLinkDatasetResolver(const ATableName:
    string): TInstantNavigationalLinkResolver;
begin
  Result := FindLinkDatasetResolver(ATableName);
  if not Assigned(Result) then
  begin
    Result := CreateNavigationalLinkResolver(ATableName);
    NavigationalLinkResolvers.Add(Result);
  end;
end;

function TInstantNavigationalResolver.GetNavigationalLinkResolvers: TObjectList;
begin
  if not Assigned(FNavigationalLinkResolvers) then
    FNavigationalLinkResolvers := TObjectList.Create;
  Result := FNavigationalLinkResolvers;
end;

function TInstantNavigationalResolver.GetObjectClassName: string;
begin
  Result := FieldByName(InstantClassFieldName).AsString;
end;

function TInstantNavigationalResolver.GetObjectId: string;
begin
  Result := FieldByName(InstantIdFieldName).AsString;
end;

procedure TInstantNavigationalResolver.InternalDisposeMap(
  AObject: TInstantObject; Map: TInstantAttributeMap;
  ConflictAction: TInstantConflictAction; Info: PInstantOperationInfo);
var
  TransError: Exception;
  AInfo: TInstantOperationInfo;
begin
  if not Assigned(Info) then
    Info := @AInfo;
  Open;
  if Locate(AObject.ClassName, AObject.PersistentId) then
  begin
    if Map.IsRootMap then
      Info.Conflict := CheckConflict(AObject, AObject.PersistentId,
        ConflictAction);
    PerformOperation(AObject, Map, ClearAttribute);
    try
      Delete;
      Info.Success := True;
    except
      on EAbort do
        raise;
      on E: Exception do
      begin
        TransError := TranslateError(AObject, E);
        if Assigned(TransError) then
          raise TransError
        else
          raise;
      end;
    end;
  end else if Map.IsRootMap and (ConflictAction = caFail) then
    raise EInstantConflict.CreateFmt(SDisposeConflict,
      [AObject.ClassName, AObject.PersistentId])
end;

procedure TInstantNavigationalResolver.InternalRetrieveMap(
  AObject: TInstantObject; const AObjectId: string; Map: TInstantAttributeMap;
  ConflictAction: TInstantConflictAction; Info: PInstantOperationInfo;
  const AObjectData: TInstantAbstractObjectData = nil);
var
  AInfo: TInstantOperationInfo;
begin
  // This resolver doesn't support retrieving from any kind of TInstantAbstractObjectData.
  if not Assigned(Info) then
    Info := @AInfo;
  Open;
  Info.Success := Locate(AObject.ClassName, AObjectId);
  if Info.Success then
  begin
    if Map.IsRootMap then
    begin
      Info.Conflict := CheckConflict(AObject, AObjectId, caIgnore);
      SetObjectUpdateCount(AObject,
        FieldByName(InstantUpdateCountFieldName).AsInteger);
    end;
    PerformOperation(AObject, Map, ReadAttribute);
  end
  else
    ResetAttributes(AObject, Map);
end;

procedure TInstantNavigationalResolver.InternalStoreMap(
  AObject: TInstantObject; Map: TInstantAttributeMap;
  ConflictAction: TInstantConflictAction; Info: PInstantOperationInfo);

  procedure AppendMap;
  begin
    Append;
  end;

  procedure EditMap;
  begin
    if Locate(AObject.ClassName, AObject.PersistentId) then
    begin
      if Map.IsRootMap then
        Info.Conflict := CheckConflict(AObject, AObject.Id, ConflictAction);
      Edit;
    end else
      AppendMap;
  end;

var
  NewId: string;
  AInfo: TInstantOperationInfo;
  TransError: Exception;
begin
  { Avoid any interference with storage when performing store operation }
  NewId := AObject.Id;

  if not Assigned(Info) then
    Info := @AInfo;
  Open;
  if AObject.IsPersistent then
    EditMap
  else
    AppendMap;
  try
    FieldByName(InstantClassFieldName).AsString := AObject.ClassName;
    FieldByName(InstantIdFieldName).AsString := NewId;
    with FieldByName(InstantUpdateCountFieldName) do
    begin
      if AsInteger = High(Integer) then
        AsInteger := 1
      else
        AsInteger := AsInteger + 1;
      if Map.IsRootMap then
        SetObjectUpdateCount(AObject, AsInteger);
    end;
    PerformOperation(AObject, Map, WriteAttribute);
    Post;
    Info.Success := True;
  except
    on E: Exception do
    begin
      Cancel;
      if E is EAbort then
        raise
      else begin
        TransError := TranslateError(AObject, E);
        if Assigned(TransError) then
          raise TransError
        else
          raise;
      end;
    end;
  end;
end;

procedure TInstantNavigationalResolver.Open;
begin
  DataSet.Open;
end;

procedure TInstantNavigationalResolver.PerformOperation(AObject: TInstantObject;
  Map: TInstantAttributeMap; Operation: TInstantNavigationalResolverOperation);
var
  I: Integer;
  AttribMeta: TInstantAttributeMetadata;
begin
  if not Assigned(Operation) then
    Exit;
  for I := 0 to Pred(Map.Count) do
  begin
    AttribMeta := Map.Items[I];
    Operation(AObject, AttribMeta);
  end;
end;

procedure TInstantNavigationalResolver.Post;
begin
  DataSet.Post;
end;

procedure TInstantNavigationalResolver.ReadAttribute(AObject: TInstantObject;
  AttributeMetadata: TInstantAttributeMetadata);
var
  Attribute: TInstantAttribute;
begin
  with AttributeMetadata do
  begin
    Attribute := AObject.AttributeByName(Name);
    case AttributeType of
      atInteger:
        ReadInteger(Attribute as TInstantInteger);
      atFloat:
        ReadFloat(Attribute as TInstantFloat);
      atCurrency:
        ReadCurrency(Attribute as TInstantCurrency);
      atBoolean:
        ReadBoolean(Attribute as TInstantBoolean);
      atString:
        ReadString(Attribute as TInstantString);
      atDateTime:
        ReadDateTime(Attribute as TInstantDateTime);
      atDate:
        ReadDate(Attribute as TInstantDate);
      atTime:
        ReadTime(Attribute as TInstantTime);
      atBlob:
        ReadBlob(Attribute as TInstantBlob);
      atGraphic:
        ReadBlob(Attribute as TInstantGraphic);
      atMemo:
        ReadMemo(Attribute as TInstantMemo);
      atPart:
        ReadPart(Attribute as TInstantPart);
      atReference:
        ReadReference(Attribute as TInstantReference);
      atParts:
        ReadParts(Attribute as TInstantParts);
      atReferences:
        ReadReferences(Attribute as TInstantReferences);
    end;
  end;
end;

procedure TInstantNavigationalResolver.ReadBlob(Attribute: TInstantBlob);
begin
  with Attribute do
    Value := FieldByName(Metadata.FieldName).AsString;
end;

procedure TInstantNavigationalResolver.ReadBoolean(Attribute: TInstantBoolean);
begin
  with Attribute do
    Value := FieldByName(Metadata.FieldName).AsBoolean;
end;

procedure TInstantNavigationalResolver.ReadCurrency(Attribute: TInstantCurrency);
begin
  with Attribute do
    Value := FieldByName(Metadata.FieldName).AsCurrency;
end;

procedure TInstantNavigationalResolver.ReadDateTime(
  Attribute: TInstantDateTime);
begin
  with Attribute do
    Value := FieldByName(Metadata.FieldName).AsDateTime;
end;

procedure TInstantNavigationalResolver.ReadDate(
  Attribute: TInstantDate);
begin
  with Attribute do
    Value := DateOf(FieldByName(Metadata.FieldName).AsDateTime);
end;

procedure TInstantNavigationalResolver.ReadTime(
  Attribute: TInstantTime);
begin
  with Attribute do
    Value := TimeOf(FieldByName(Metadata.FieldName).AsDateTime);
end;

procedure TInstantNavigationalResolver.ReadFloat(Attribute: TInstantFloat);
begin
  with Attribute do
    Value := FieldByName(Metadata.FieldName).AsFloat;
end;

procedure TInstantNavigationalResolver.ReadInteger(Attribute: TInstantInteger);
begin
  with Attribute do
    Value := FieldByName(Metadata.FieldName).AsInteger;
end;

procedure TInstantNavigationalResolver.ReadMemo(Attribute: TInstantMemo);
begin
  with Attribute do
    Value := TrimRight(FieldByName(Metadata.FieldName).AsString);
end;

procedure TInstantNavigationalResolver.ReadPart(Attribute: TInstantPart);
var
  Field: TField;
  Stream: TStream;
  PartClassName: string;
  ObjID: string;
begin
  with Attribute do
  begin
    if Metadata.StorageKind = skExternal then
    begin
      // Must clear Value first to avoid leak for Refresh operation
      // as OldValue = NewValue.
      Value := nil;
      PartClassName := FieldByName(Metadata.FieldName +
          InstantClassFieldName).AsString;
      ObjID := FieldByName(Metadata.FieldName + InstantIdFieldName).AsString;
      // PartClassName and ObjID will be empty if the attribute was
      // added to a class with existing instances in the database.
      if (PartClassName = '') and (ObjID = '') then
        Attribute.Reset
      else
        Value := InstantFindClass(PartClassName).Retrieve(
            ObjID, False, False, Connector);
    end
    else
    begin
      Field := FieldByName(Metadata.FieldName);
      if not FieldHasObjects(Field) then
        Exit;
      Stream := CreateEmbeddedObjectInputStream(Connector, Field);
      try
        LoadObjectFromStream(Stream);
      finally
        Stream.Free;
      end;
    end;
  end;
end;

procedure TInstantNavigationalResolver.ReadParts(Attribute: TInstantParts);
var
  Field: TField;
  Stream: TStream;
  LinkDatasetResolver: TInstantNavigationalLinkResolver;
begin
  with Attribute do
  begin
    if Metadata.StorageKind = skExternal then
    begin
      Clear;
      LinkDatasetResolver :=
          GetLinkDatasetResolver(Metadata.ExternalStorageName);
      LinkDatasetResolver.ReadAttributeObjects(Attribute, ObjectId);
    end
    else
    begin
      Field := FieldByName(Metadata.FieldName);
      if not FieldHasObjects(Field) then
        Exit;
      Stream := CreateEmbeddedObjectInputStream(Connector, Field);
      try
        LoadObjectsFromStream(Stream);
      finally
        Stream.Free;
      end;
    end;
  end;
end;

procedure TInstantNavigationalResolver.ReadReference(
  Attribute: TInstantReference);
begin
  with Attribute do
  begin
    ReferenceObject(
      TrimRight(
        FieldByName(Metadata.FieldName + InstantClassFieldName).AsString),
      TrimRight(
        FieldByName(Metadata.FieldName + InstantIdFieldName).AsString));
  end;
end;

procedure TInstantNavigationalResolver.ReadReferences(
  Attribute: TInstantReferences);
var
  Field: TField;
  Stream: TStream;
  LinkDatasetResolver: TInstantNavigationalLinkResolver;
begin
  with Attribute do
  begin
    if Metadata.StorageKind = skExternal then
    begin
      Clear;
      LinkDatasetResolver :=
          GetLinkDatasetResolver(Metadata.ExternalStorageName);
      LinkDatasetResolver.ReadAttributeObjects(Attribute, ObjectId);
    end
    else
    begin
      Field := FieldByName(Metadata.FieldName);
      if not FieldHasObjects(Field) then
        Exit;
      Stream := CreateEmbeddedObjectInputStream(Connector, Field);
      try
        LoadReferencesFromStream(Stream);
      finally
        Stream.Free;
      end;
    end;
  end;
end;

procedure TInstantNavigationalResolver.ReadString(Attribute: TInstantString);
begin
  with Attribute do
    Value := TrimRight(FieldByName(Metadata.FieldName).AsString);
end;

procedure TInstantNavigationalResolver.ResetAttribute(AObject: TInstantObject;
  AttributeMetadata: TInstantAttributeMetadata);
begin
  AObject.AttributeByName(AttributeMetadata.Name).Reset;
end;

procedure TInstantNavigationalResolver.ResetAttributes(
  const AObject: TInstantObject; const AMap: TInstantAttributeMap);
begin
  PerformOperation(AObject, AMap, ResetAttribute);
end;

procedure TInstantNavigationalResolver.SetDataSet(Value: TDataset);
begin
  if Value <> FDataSet then
  begin
    FreeDataSet;
    FDataSet := Value;
  end;
end;

procedure TInstantNavigationalResolver.SetObjectUpdateCount(
  AObject: TInstantObject; Value: Integer);
begin
  Broker.SetObjectUpdateCount(AObject, Value);
end;

function TInstantNavigationalResolver.TranslateError(AObject: TInstantObject;
  E: Exception): Exception;
begin
  Result := nil;
end;

procedure TInstantNavigationalResolver.WriteAttribute(AObject: TInstantObject;
  AttributeMetadata: TInstantAttributeMetadata);
var
  Attribute: TInstantAttribute;
begin
  with AttributeMetadata do
  begin
    Attribute := AObject.AttributeByName(Name);
    if not Attribute.IsChanged then
      Exit;
    case AttributeType of
      atInteger:
        WriteInteger(Attribute as TInstantInteger);
      atFloat:
        WriteFloat(Attribute as TInstantFloat);
      atCurrency:
        WriteCurrency(Attribute as TInstantCurrency);
      atBoolean:
        WriteBoolean(Attribute as TInstantBoolean);
      atString:
        WriteString(Attribute as TInstantString);
      atDateTime:
        WriteDateTime(Attribute as TInstantDateTime);
      atDate:
        WriteDate(Attribute as TInstantDate);
      atTime:
        WriteTime(Attribute as TInstantTime);
      atBlob:
        WriteBlob(Attribute as TInstantBlob);
      atGraphic:
        WriteBlob(Attribute as TInstantGraphic);
      atMemo:
        WriteMemo(Attribute as TInstantMemo);
      atPart:
        WritePart(Attribute as TInstantPart);
      atReference:
        WriteReference(Attribute as TInstantReference);
      atParts:
        WriteParts(Attribute as TInstantParts);
      atReferences:
        WriteReferences(Attribute as TInstantReferences);
    end;
  end;
end;

procedure TInstantNavigationalResolver.WriteBlob(Attribute: TInstantBlob);
begin
  with FieldByName(Attribute.Metadata.FieldName) do
    if Attribute.IsNull then
      Clear
    else
      AsString := Attribute.Value;
end;

procedure TInstantNavigationalResolver.WriteBoolean(Attribute: TInstantBoolean);
begin
  with FieldByName(Attribute.Metadata.FieldName) do
    if Attribute.IsNull then
      Clear
    else
      AsBoolean := Attribute.Value;
end;

procedure TInstantNavigationalResolver.WriteCurrency(Attribute: TInstantCurrency);
begin
  with FieldByName(Attribute.Metadata.FieldName) do
    if Attribute.IsNull then
      Clear
    else
{$IFDEF FPC}
      AsFloat := Attribute.Value;
{$ELSE}
      AsCurrency := Attribute.Value;
{$ENDIF}
end;

procedure TInstantNavigationalResolver.WriteDateTime(
  Attribute: TInstantDateTime);
begin
  with FieldByName(Attribute.Metadata.FieldName) do
    if Attribute.IsNull then
      Clear
    else
      AsDateTime := Attribute.Value;
end;

procedure TInstantNavigationalResolver.WriteDate(
  Attribute: TInstantDate);
begin
  with FieldByName(Attribute.Metadata.FieldName) do
    if Attribute.IsNull then
      Clear
    else
      AsDateTime := Attribute.Value;
end;

procedure TInstantNavigationalResolver.WriteTime(
  Attribute: TInstantTime);
begin
  with FieldByName(Attribute.Metadata.FieldName) do
    if Attribute.IsNull then
      Clear
    else
      AsDateTime := Attribute.Value;
end;

procedure TInstantNavigationalResolver.WriteFloat(Attribute: TInstantFloat);
begin
  with FieldByName(Attribute.Metadata.FieldName) do
    if Attribute.IsNull then
      Clear
    else
      AsFloat := Attribute.Value;
end;

procedure TInstantNavigationalResolver.WriteInteger(Attribute: TInstantInteger);
begin
  with FieldByName(Attribute.Metadata.FieldName) do
    if Attribute.IsNull then
      Clear
    else
      AsInteger := Attribute.Value;
end;

procedure TInstantNavigationalResolver.WriteMemo(Attribute: TInstantMemo);
begin
  WriteBlob(Attribute);
end;

procedure TInstantNavigationalResolver.WritePart(Attribute: TInstantPart);
var
  Field: TField;
  Stream: TStream;
begin
  with Attribute do
  begin
    if Metadata.StorageKind = skExternal then
    begin
      Value.CheckId;
      FieldByName(Metadata.FieldName + InstantClassFieldName).AsString :=
          Value.ClassName;
      FieldByName(Metadata.FieldName + InstantIdFieldName).AsString :=
          Value.Id;
      StoreObject(Value, caIgnore);
    end
    else
    begin
      Field := FieldByName(Metadata.FieldName);
      Stream := CreateEmbeddedObjectOutputStream(Attribute.Connector);
      try
        SaveObjectToStream(Stream);
        AssignEmbeddedObjectStreamToField(Attribute.Connector, Stream, Field);
      finally
        Stream.Free;
      end;
    end;
  end;
end;

procedure TInstantNavigationalResolver.WriteParts(Attribute: TInstantParts);
var
  Field: TField;
  Stream: TStream;
  LinkDatasetResolver: TInstantNavigationalLinkResolver;
begin
  with Attribute do
  begin
    if Metadata.StorageKind = skExternal then
    begin
      LinkDatasetResolver :=
          GetLinkDatasetResolver(Metadata.ExternalStorageName);
      LinkDatasetResolver.Open;
      try
        LinkDatasetResolver.DisposeDeletedAttributeObjects(Attribute);
        LinkDatasetResolver.ClearAttributeLinkRecords;
        LinkDatasetResolver.StoreAttributeObjects(Attribute);
      finally
        LinkDatasetResolver.Close;
      end;
    end
    else
    begin
      Field := FieldByName(Metadata.FieldName);
      Stream := CreateEmbeddedObjectOutputStream(Attribute.Connector);
      try
        SaveObjectsToStream(Stream);
        AssignEmbeddedObjectStreamToField(Attribute.Connector, Stream, Field);
      finally
        Stream.Free;
      end;
    end;
  end;
end;

procedure TInstantNavigationalResolver.WriteReference(
  Attribute: TInstantReference);
begin
  with Attribute do
  begin
    FieldByName(Metadata.FieldName + InstantClassFieldName).AsString :=
      ObjectClassName;
    FieldByName(Metadata.FieldName + InstantIdFieldName).AsString := ObjectId;
  end;
end;

procedure TInstantNavigationalResolver.WriteReferences(
  Attribute: TInstantReferences);
var
  Field: TField;
  Stream: TStream;
  LinkDatasetResolver: TInstantNavigationalLinkResolver;
begin
  with Attribute do
  begin
    if Metadata.StorageKind = skExternal then
    begin
      LinkDatasetResolver :=
          GetLinkDatasetResolver(Metadata.ExternalStorageName);
      LinkDatasetResolver.Open;
      try
        LinkDatasetResolver.ClearAttributeLinkRecords;
        LinkDatasetResolver.StoreAttributeObjects(Attribute);
      finally
        LinkDatasetResolver.Close;
      end;
    end
    else
    begin
      Field := FieldByName(Metadata.FieldName);
      Stream := CreateEmbeddedObjectOutputStream(Attribute.Connector);
      try
        SaveReferencesToStream(Stream);
        AssignEmbeddedObjectStreamToField(Attribute.Connector, Stream, Field);
      finally
        Stream.Free;
      end;
    end;
  end;
end;

procedure TInstantNavigationalResolver.WriteString(Attribute: TInstantString);
begin
  with FieldByName(Attribute.Metadata.FieldName) do
    if Attribute.IsNull then
      Clear
    else
      AsString := Attribute.Value;
end;

constructor TInstantSQLResolver.Create(ABroker: TInstantSQLBroker;
  AMap: TInstantAttributeMap);
begin
  if not Assigned(AMap) then
    raise EInstantError.Create(SUnassignedMap);
  inherited Create(ABroker);
  FMap := AMap;
end;

{ TInstantSQLResolver }

procedure TInstantSQLResolver.AddAttributeParam(Attribute: TInstantAttribute;
  Params: TParams);
var
  FieldName: string;

  procedure AddBlobAttributeParam;
  var
    LParam: TParam;
  begin
    LParam := AddParam(Params, FieldName, ftBlob);
    if Attribute.IsNull then
      LParam.Clear
    else
      {$IFDEF D12+}
      LParam.AsBlob := (Attribute as TInstantBlob).Bytes;
      {$ELSE}
      LParam.AsBlob := (Attribute as TInstantBlob).Value;
      {$ENDIF}
  end;

  procedure AddBooleanAttributeParam;
  var
    LParam: TParam;
  begin
    LParam := AddParam(Params, FieldName, ftBoolean);
    if Attribute.IsNull then
      LParam.Clear
    else
      LParam.AsBoolean := (Attribute as TInstantBoolean).Value;
  end;

  procedure AddDateTimeAttributeParam;
  var
    LParam: TParam;
  begin
    LParam := AddParam(Params, FieldName, ftDateTime);
    if Attribute.IsNull then
      LParam.Clear
    else
      LParam.AsDateTime := (Attribute as TInstantDateTime).Value;
  end;

  procedure AddDateAttributeParam;
  var
    LParam: TParam;
  begin
    LParam := AddParam(Params, FieldName, ftDate);
    if Attribute.IsNull then
      LParam.Clear
    else
      LParam.AsDateTime := (Attribute as TInstantDate).Value;
  end;

  procedure AddTimeAttributeParam;
  var
    LParam: TParam;
  begin
    LParam := AddParam(Params, FieldName, ftTime);
    if Attribute.IsNull then
      LParam.Clear
    else
      LParam.AsDateTime := (Attribute as TInstantTime).Value;
  end;

  procedure AddFloatAttributeParam;
  var
    LParam: TParam;
  begin
    LParam := AddParam(Params, FieldName, ftFloat);
    if Attribute.IsNull then
      LParam.Clear
    else
      LParam.AsFloat := (Attribute as TInstantFloat).Value;
  end;

  procedure AddCurrencyAttributeParam;
  var
    LParam: TParam;
  begin
    LParam := AddParam(Params, FieldName, ftBCD);
    if Attribute.IsNull then
      LParam.Clear
    else
      LParam.AsCurrency := (Attribute as TInstantCurrency).Value;
  end;

  procedure AddIntegerAttributeParam;
  var
    LParam: TParam;
  begin
    LParam := AddIntegerParam(Params, FieldName, (Attribute as TInstantInteger).Value);
    if Attribute.IsNull then
      LParam.Clear;
  end;

  procedure AddMemoAttributeParam;
  var
    LParam: TParam;
    MemoAttrib: TInstantMemo;
  begin
    LParam := AddParam(Params, FieldName, ftMemo);
    MemoAttrib := (Attribute as TInstantMemo);
    if (MemoAttrib.Size = 0) or Attribute.IsNull then
      LParam.Clear
    else
      LParam.AsMemo := MemoAttrib.Value;
  end;

  procedure AddWideMemoAttributeParam;
  var
    LParam: TParam;
    MemoAttrib: TInstantMemo;
  begin
    LParam := AddParam(Params, FieldName, ftWideMemo);
    MemoAttrib := (Attribute as TInstantMemo);
    if (MemoAttrib.Size = 0) or Attribute.IsNull then
      LParam.Clear
    else
      LParam.Value := MemoAttrib.AsString;
  end;

  procedure AddPartAttributeParam;
  var
    Stream: TStream;
    Part: TInstantPart;
  begin
    if Attribute.Metadata.StorageKind = skExternal then
    begin
      Part := Attribute as TInstantPart;
      AddStringParam(Params, FieldName + InstantClassFieldName, Part.Value.ClassName);
      Part.Value.CheckId;
      AddIdParam(Params, FieldName + InstantIdFieldName, Part.Value.Id);
    end
    else
    begin
      Stream := CreateEmbeddedObjectOutputStream(Broker.Connector);
      try
        (Attribute as TInstantPart).SaveObjectToStream(Stream);
        AddEmbeddedObjectOutputParam(Broker.Connector, Params, FieldName, Stream);
      finally
        Stream.Free;
      end;
    end;
  end;

  procedure AddPartsAttributeParam;
  var
    Stream: TStream;
  begin
    Stream := CreateEmbeddedObjectOutputStream(Broker.Connector);
    try
      (Attribute as TInstantParts).SaveObjectsToStream(Stream);
      AddEmbeddedObjectOutputParam(Broker.Connector, Params, FieldName, Stream);
    finally
      Stream.Free;
    end;
  end;

  procedure AddReferenceAttributeParams;
  var
    Reference: TInstantReference;
  begin
    Reference := Attribute as TInstantReference;
    AddStringParam(Params, FieldName + InstantClassFieldName,
      Reference.ObjectClassName);
    AddIdParam(Params, FieldName + InstantIdFieldName, Reference.ObjectId);
  end;

  procedure AddReferencesAttributeParam;
  var
    Stream: TStream;
  begin
    Stream := CreateEmbeddedObjectOutputStream(Broker.Connector);
    try
      (Attribute as TInstantReferences).SaveReferencesToStream(Stream);
      AddEmbeddedObjectOutputParam(Broker.Connector, Params, FieldName, Stream);
    finally
      Stream.Free;
    end;
  end;

  procedure AddStringAttributeParam;
  var
    LParam: TParam;
  begin
    LParam := AddStringParam(Params, FieldName, (Attribute as TInstantString).Value);
    if Attribute.IsNull then
      LParam.Clear;
  end;

begin
  FieldName := Attribute.Metadata.FieldName;
  case Attribute.Metadata.AttributeType of
    atBlob, atGraphic:
      AddBlobAttributeParam;
    atBoolean:
      AddBooleanAttributeParam;
    atDateTime:
      AddDateTimeAttributeParam;
    atDate:
      AddDateAttributeParam;
    atTime:
      AddTimeAttributeParam;
    atFloat:
      AddFloatAttributeParam;
    atCurrency:
      AddCurrencyAttributeParam;
    atInteger:
      AddIntegerAttributeParam;
    atMemo:
      if Broker.Connector.UseUnicode then
        AddWideMemoAttributeParam
      else
        AddMemoAttributeParam;
    atPart:
      AddPartAttributeParam;
    atParts:
      AddPartsAttributeParam;
    atReference:
      AddReferenceAttributeParams;
    atReferences:
      AddReferencesAttributeParam;
    atString:
      AddStringAttributeParam;
  end;
end;

procedure TInstantSQLResolver.AddAttributeParams(Params: TParams;
  AObject: TInstantObject; Map: TInstantAttributeMap);
var
  I: Integer;
  Attribute: TInstantAttribute;
begin
  if Assigned(Params) and Assigned(AObject) and Assigned(Map) then
    for I := 0 to Pred(Map.Count) do
    begin
      Attribute := AObject.AttributeByName(Map[I].Name); 
      if (Attribute.Metadata.StorageKind = skEmbedded) or
         ((Attribute.Metadata.StorageKind = skExternal) and (Attribute.Metadata.AttributeType = atPart)) then
        AddAttributeParam(Attribute, Params);
    end;
end;

procedure TInstantSQLResolver.AddBaseParams(Params: TParams; AClassName,
  AObjectId: string; AUpdateCount: Integer);
begin
  if Assigned(Params) then
  begin
    AddStringParam(Params, InstantClassFieldName, AClassName);
    AddIdParam(Params, InstantIdFieldName, AObjectId);
    if AUpdateCount <> -1 then
      AddIntegerParam(Params, InstantUpdateCountFieldName, AUpdateCount);
  end;
end;

procedure TInstantSQLResolver.AddConcurrencyParam(Params: TParams;
  AUpdateCount: Integer);
begin
  AddIntegerParam(Params, ConcurrencyParamName, AUpdateCount);
end;

procedure TInstantSQLResolver.AddEmbeddedObjectOutputParam(
  const AConnector: TInstantConnector; const AParams: TParams;
  const AParamName: string; const AStream: TStream);
var
  LParam: TParam;
begin
  Assert(Assigned(AConnector));
  Assert(Assigned(AParams));
  Assert(AParamName <> '');
  Assert(Assigned(AStream));

  // Look in TInstantCustomResolver.CreateEmbeddedObjectOutputStream
  // to see the stream type. Changes there need to be propagated here.
  if AConnector.BlobStreamFormat = sfBinary then
  begin
    LParam := AddParam(AParams, AParamName, ftBlob);
    if AStream.Size > 0 then
      {$IFDEF D12+}
      LParam.AsBytes := (AStream as TBytesStream).Bytes;
      {$ELSE}
      LParam.AsMemo := (AStream as TStringStream).DataString;
      {$ENDIF}
  end
  else
  begin
    LParam := AddParam(AParams, AParamName, ftMemo);
    if AStream.Size > 0 then
      LParam.AsMemo := (AStream as TStringStream).DataString;
  end;
end;

procedure TInstantSQLResolver.AddIdParam(Params: TParams;
  const ParamName, Value: string);
var
  Param: TParam;
begin
  Param := AddParam(Params, ParamName, InstantDataTypeToFieldType(Broker.Connector.IdDataType));
  if Value <> '' then
    Param.Value := Value;
end;

function TInstantSQLResolver.AddIntegerParam(Params: TParams;
  const ParamName: string; Value: Integer): TParam;
begin
  Result := AddParam(Params, ParamName, ftInteger);
  Result.AsInteger := Value;
end;

function TInstantSQLResolver.AddParam(Params: TParams;
  const ParamName: string; ADataType: TFieldType): TParam;
begin
  Result := TParam(Params.Add);
  Result.Name := ParamName;
  Result.DataType := ADataType;
end;

procedure TInstantSQLResolver.AddPersistentIdParam(Params: TParams;
  APersistentId: string);
begin
  AddIdParam(Params, PersistentIdParamName, APersistentId);
end;

function TInstantSQLResolver.AddStringParam(Params: TParams;
  const ParamName, Value: string): TParam;
begin
  Result := AddParam(Params, ParamName, ftString);
  if Value <> '' then
    Result.AsString := Value;
end;

procedure TInstantSQLResolver.CheckConflict(Info: PInstantOperationInfo;
 AObject: TInstantObject);
begin
  if Info.Conflict then
    raise EInstantConflict.CreateFmt(SUpdateConflict,
      [AObject.ClassName, AObject.Id]);
end;

function TInstantSQLResolver.ExecuteStatement(const AStatement: string;
  AParams: TParams; Info: PInstantOperationInfo;
  ConflictAction: TInstantConflictAction; AObject: TInstantObject): Integer;
var
  TransError: Exception;
begin
  try
    {$IFDEF IO_STATEMENT_LOGGING}
    InstantLogStatement(InstantLogStatementExecute, AStatement, AParams);
    {$ENDIF}
    Result := Broker.Execute(AStatement, AParams);
    Info.Success := Result >= 1;
    Info.Conflict := not (Info.Success or (ConflictAction = caIgnore));
  except
    on EAbort do
      raise;
    on E: Exception do
    begin
      TransError := TranslateError(AObject, E);
      if Assigned(TransError) then
        raise TransError
      else
        raise;
    end;
  end;
end;

function TInstantSQLResolver.GetBroker: TInstantSQLBroker;
begin
  Result := inherited Broker as TInstantSQLBroker;
end;

function TInstantSQLResolver.GetDeleteConcurrentSQL: string;
begin
  if FDeleteConcurrentSQL = '' then
    FDeleteConcurrentSQL := Broker.Generator.GenerateDeleteConcurrentSQL(Map);
  Result := FDeleteConcurrentSQL;
end;

function TInstantSQLResolver.GetDeleteExternalSQL: string;
begin
  if FDeleteExternalSQL = '' then
    FDeleteExternalSQL := Broker.Generator.GenerateDeleteExternalSQL(Map);
  Result := FDeleteExternalSQL;
end;

function TInstantSQLResolver.GetDeleteSQL: string;
begin
  if FDeleteSQL = '' then
    FDeleteSQL := Broker.Generator.GenerateDeleteSQL(Map);
  Result := FDeleteSQL;
end;

function TInstantSQLResolver.GetInsertExternalSQL: string;
begin
  if FInsertExternalSQL = '' then
    FInsertExternalSQL := Broker.Generator.GenerateInsertExternalSQL(Map);
  Result := FInsertExternalSQL;
end;

function TInstantSQLResolver.GetInsertSQL: string;
begin
  if FInsertSQL = '' then
    FInsertSQL := Broker.Generator.GenerateInsertSQL(Map);
  Result := FInsertSQL;
end;

function TInstantSQLResolver.GetSelectExternalPartSQL: string;
begin
  if FSelectExternalPartSQL = '' then
    FSelectExternalPartSQL := Broker.Generator.GenerateSelectExternalPartSQL(Map);
  Result := FSelectExternalPartSQL;
end;

function TInstantSQLResolver.GetSelectExternalSQL: string;
begin
  if FSelectExternalSQL = '' then
    FSelectExternalSQL := Broker.Generator.GenerateSelectExternalSQL(Map);
  Result := FSelectExternalSQL;
end;

function TInstantSQLResolver.GetSelectSQL: string;
begin
  if FSelectSQL = '' then
    FSelectSQL := Broker.Generator.GenerateSelectSQL(Map);
  Result := FSelectSQL;
end;

function TInstantSQLResolver.GetUpdateConcurrentSQL: string;
begin
  if FUpdateConcurrentSQL = '' then
    FUpdateConcurrentSQL := Broker.Generator.GenerateUpdateConcurrentSQL(Map);
  Result := FUpdateConcurrentSQL;
end;

function TInstantSQLResolver.GetUpdateSQL: string;
begin
  if FUpdateSQL = '' then
    FUpdateSQL := Broker.Generator.GenerateUpdateSQL(Map);
  Result := FUpdateSQL;
end;

procedure TInstantSQLResolver.InternalDisposeMap(AObject: TInstantObject;
  Map: TInstantAttributeMap; ConflictAction: TInstantConflictAction;
  Info: PInstantOperationInfo);
var
  Params: TParams;
  Statement: string;
  AInfo: TInstantOperationInfo;

  procedure DeleteExternalPartMap;
  var
    i: Integer;
    PartObject: TInstantObject;
    SelectParams: TParams;
    SelectStatement: string;
    AttributeMetadata: TInstantAttributeMetadata;
    DataSet: TDataSet;
  begin
    for i := 0 to Pred(Map.Count) do
    begin
      AttributeMetadata := Map[i];
      if (AttributeMetadata.AttributeType = atPart) and
          (AttributeMetadata.StorageKind = skExternal) then
      begin
        // Dispose object
        SelectParams := TParams.Create;
        try
          SelectStatement := Format(SelectExternalPartSQL,
            [AttributeMetadata.FieldName + InstantClassFieldName,
             AttributeMetadata.FieldName + InstantIdFieldName,
             AttributeMetadata.ClassMetadata.TableName]);
          AddStringParam(SelectParams, InstantClassFieldName, AObject.ClassName);
          AddIdParam(SelectParams, InstantIdFieldName, AObject.Id);
          DataSet := Broker.AcquireDataSet(SelectStatement, SelectParams);
          try
            DataSet.Open;
            try
              if not DataSet.IsEmpty then
              begin
                PartObject := AttributeMetadata.ObjectClass.Retrieve(
                  DataSet.Fields[1].AsString, False, False, AObject.Connector)
                  as TInstantObject;
                try
                  if Assigned(PartObject) then
                    DisposeObject(PartObject, caIgnore);
                finally
                  PartObject.Free;
                end;
              end;
            finally
              DataSet.Close;
            end;
          finally
            Broker.ReleaseDataSet(DataSet);
          end;
        finally
          SelectParams.Free;
        end;
      end;
    end;
  end;

  procedure DeleteAllExternalLinks(Index: Integer);
  var
    LinkResolver: TInstantSQLLinkResolver;
  begin
    LinkResolver := TInstantSQLLinkResolver.Create(Self,
        Map[Index].ExternalStorageName, AObject);
    try
      LinkResolver.ClearAttributeLinkRecords;
    finally
      LinkResolver.Free;
    end;
  end;

  procedure DeleteExternalContainerMaps;
  var
    i: Integer;
    j: Integer;
    AttributeMetadata: TInstantAttributeMetadata;
    Attribute: TInstantContainer;
  begin
    for i := 0 to Pred(Map.Count) do
    begin
      AttributeMetadata := Map[i];
      if (AttributeMetadata.AttributeType in [atParts, atReferences]) and
              (AttributeMetadata.StorageKind = skExternal) then
      begin
        if AttributeMetadata.AttributeType = atParts then
        begin
          // Dispose all contained objects
          Attribute := TInstantContainer(AObject.AttributeByName(
              AttributeMetadata.Name));
          for j := 0 to Pred(Attribute.Count) do
            DisposeObject(Attribute.Items[j], caIgnore);
        end;
        DeleteAllExternalLinks(i);
      end;
    end;
  end;

begin
  if not Assigned(Info) then
    Info := @AInfo;
  DeleteExternalPartMap;
  DeleteExternalContainerMaps;
  Params := TParams.Create;
  try
    AddBaseParams(Params, AObject.ClassName, AObject.PersistentId);
    if Map.IsRootMap and (ConflictAction = caFail) then
    begin
      Statement := DeleteConcurrentSQL;
      AddConcurrencyParam(Params, AObject.UpdateCount);
      ExecuteStatement(Statement, Params, Info, ConflictAction, AObject);
      CheckConflict(Info, AObject);
    end else
    begin
      Statement := DeleteSQL;
      ExecuteStatement(Statement, Params, Info, ConflictAction, AObject)
    end;
  finally
    Params.Free;
  end;
end;

procedure TInstantSQLResolver.ResetAttributes(const AObject: TInstantObject;
  const AMap: TInstantAttributeMap);
var
  I: Integer;
begin
  for I := 0 to Pred(AMap.Count) do
    AObject.AttributeByName(AMap[I].Name).Reset;
end;

procedure TInstantSQLResolver.InternalRetrieveMap(AObject: TInstantObject;
  const AObjectId: string; Map: TInstantAttributeMap;
  ConflictAction: TInstantConflictAction; AInfo: PInstantOperationInfo;
  const AObjectData: TInstantAbstractObjectData = nil);
var
  LDataSet: TDataSet;
  LParams: TParams;
begin
  // This resolver supports retrieving data from TInstantDataSetObjectData.
  if Assigned(AObjectData) and (AObjectData is TInstantDataSetObjectData)
    and TInstantDataSetObjectData(AObjectData).Locate(AObjectId) then
  begin
    RetrieveMapFromDataSet(AObject, AObjectId, Map, ConflictAction, AInfo,
      TInstantDataSetObjectData(AObjectData).DataSet);
  end
  else
  begin
    LParams := TParams.Create;
    try
      AddBaseParams(LParams, AObject.ClassName, AObjectId);
      LDataSet := Broker.AcquireDataSet(SelectSQL, LParams);
      try
        LDataSet.Open;
        RetrieveMapFromDataSet(AObject, AObjectId, Map, ConflictAction,
          AInfo, LDataSet);
      finally
        Broker.ReleaseDataSet(LDataSet);
      end;
    finally
      LParams.Free;
    end;
  end;
end;

procedure TInstantSQLResolver.InternalStoreMap(AObject: TInstantObject;
  Map: TInstantAttributeMap; ConflictAction: TInstantConflictAction;
  Info: PInstantOperationInfo);
var
  Params: TParams;
  AInfo: TInstantOperationInfo;
  NewUpdateCount, RowsAffected: Integer;

  procedure InsertMap;
  begin
    if AObject.IsPersistent then
    begin
      RemoveConcurrencyParam(Params);
      RemovePersistentIdParam(Params);
    end;
    RowsAffected := ExecuteStatement(InsertSQL, Params, Info, ConflictAction, AObject);
  end;

  procedure UpdateMap;
  var
    Statement: string;
  begin
    AddPersistentIdParam(Params, AObject.PersistentId);
    if Map.IsRootMap and (ConflictAction = caFail) then
    begin
      Statement := UpdateConcurrentSQL;
      AddConcurrencyParam(Params, AObject.UpdateCount);
      ExecuteStatement(Statement, Params, Info, ConflictAction, AObject);
      CheckConflict(Info, AObject);
    end else
    begin
      Statement := UpdateSQL;
      ExecuteStatement(Statement, Params, Info, ConflictAction, AObject);
    end;
    if not Info.Success then
      InsertMap;
  end;

  procedure UpdateExternalPartMap;
  var
    i: Integer;
    PartObject: TInstantObject;
    PartAttribute: TInstantPart;
    AttributeMetadata: TInstantAttributeMetadata;
    SelectParams: TParams;
    SelectStatement: string;
    DataSet: TDataSet;
  begin
    for i := 0 to Pred(Map.Count) do
    begin
      AttributeMetadata := Map[i];
      if AttributeMetadata.AttributeType = atPart then
      begin
        PartAttribute := TInstantPart(AObject.AttributeByName(AttributeMetadata.Name));
        if PartAttribute.IsChanged or not PartAttribute.Value.IsPersistent then
        begin
          if Map[i].StorageKind = skExternal then
          begin
            // Delete object
            SelectParams := TParams.Create;
            try
              SelectStatement := Format(SelectExternalPartSQL,
                [AttributeMetadata.FieldName + InstantClassFieldName,
                 AttributeMetadata.FieldName + InstantIdFieldName,
                 AttributeMetadata.ClassMetadata.TableName]);
              AddStringParam(SelectParams, InstantClassFieldName, AObject.ClassName);
              AddIdParam(SelectParams, InstantIdFieldName, AObject.Id);
              DataSet := Broker.AcquireDataSet(SelectStatement, SelectParams);
              try
                DataSet.Open;
                try
                  if not DataSet.IsEmpty then
                  begin
                    PartObject := AttributeMetadata.ObjectClass.Retrieve(
                      DataSet.Fields[1].AsString, False, False,
                      AObject.Connector) as TInstantObject;
                    try
                      if Assigned(PartObject) then
                        DisposeObject(PartObject, caIgnore);
                    finally
                      PartObject.Free;
                    end;
                  end;
                finally
                  DataSet.Close;
                end;
              finally
                Broker.ReleaseDataSet(DataSet);
              end;
            finally
              SelectParams.Free;
            end;

            // Store object
            PartObject := PartAttribute.Value;
            PartObject.CheckId;
            StoreObject(PartObject, caIgnore);
          end;
        end;
      end;
    end;
  end;

  procedure UpdateExternalContainerMaps;
  var
    I: Integer;
    AttributeMetadata: TInstantAttributeMetadata;
    LinkResolver: TInstantSQLLinkResolver;
    Attribute: TInstantContainer;
  begin
    for I := 0 to Pred(Map.Count) do
    begin
      AttributeMetadata := Map[I];
      if AttributeMetadata.AttributeType in [atParts, atReferences] then
      begin
        Attribute := TInstantContainer(AObject.AttributeByName(
            AttributeMetadata.Name));

        { TODO : Attribute.Owner.IsPersistent is used (below) because Dispose
          doesn't change the state of changed attributes to IsChanged.
          Perhaps ObjStore.DisposeObject is the right place to fix (JM) }
        if (Attribute.IsChanged or not Attribute.Owner.IsPersistent) and
            (AttributeMetadata.StorageKind = skExternal) then
        begin
          LinkResolver := TInstantSQLLinkResolver.Create(Self,
              AttributeMetadata.ExternalStorageName, AObject);
          try
            if AttributeMetadata.AttributeType = atParts then
              LinkResolver.DisposeDeletedAttributeObjects(Attribute);
            LinkResolver.ClearAttributeLinkRecords;
            LinkResolver.StoreAttributeObjects(Attribute);
          finally
            LinkResolver.Free;
          end;
        end;
      end;
    end;
  end;

begin
  if not Assigned(Info) then
    Info := @AInfo;
  Params := TParams.Create;
  try
    if Map.IsRootMap then
      if ConflictAction = caIgnore then
      begin
        Randomize;
        NewUpdateCount := Random(High(Integer)) + 1;
      end else if AObject.UpdateCount = High(Integer) then
        NewUpdateCount := 1
      else
        NewUpdateCount := AObject.UpdateCount + 1
    else
      NewUpdateCount := AObject.UpdateCount;
    AddBaseParams(Params, AObject.ClassName, AObject.Id, NewUpdateCount);
    AddAttributeParams(Params, AObject, Map);
    UpdateExternalPartMap;
    if AObject.IsPersistent then
      UpdateMap
    else
      InsertMap;
    if Map.IsRootMap then
      Broker.SetObjectUpdateCount(AObject, NewUpdateCount);

    UpdateExternalContainerMaps;
  finally
    Params.Free;
  end;
end;

procedure TInstantSQLResolver.ReadAttribute(AObject: TInstantObject;
  const AObjectId: string; AttributeMetadata: TInstantAttributeMetadata;
  DataSet: TDataSet);
var
  Attribute: TInstantAttribute;
  AFieldName: string;

  procedure ReadBlobAttribute;
  begin
    (Attribute as TInstantBlob).Value := ReadBlobField(DataSet, AFieldName);
  end;

  procedure ReadBooleanAttribute;
  begin
    (Attribute as TInstantBoolean).Value :=
      ReadBooleanField(DataSet, AFieldName);
  end;

  procedure ReadDateTimeAttribute;
  begin
    (Attribute as TInstantDateTime).Value :=
      ReadDateTimeField(DataSet, AFieldName);
  end;

  procedure ReadDateAttribute;
  begin
    (Attribute as TInstantDate).Value :=
      ReadDateField(DataSet, AFieldName);
  end;

  procedure ReadTimeAttribute;
  begin
    (Attribute as TInstantTime).Value :=
      ReadTimeField(DataSet, AFieldName);
  end;

  procedure ReadFloatAttribute;
  begin
    (Attribute as TInstantFloat).Value := ReadFloatField(DataSet, AFieldName);
  end;

  procedure ReadCurrencyAttribute;
  begin
    (Attribute as TInstantCurrency).Value :=
      ReadCurrencyField(DataSet, AFieldName);
  end;

  procedure ReadIntegerAttribute;
  begin
    (Attribute as TInstantInteger).Value :=
      ReadIntegerField(DataSet, AFieldName);
  end;

  procedure ReadMemoAttribute;
  begin
    (Attribute as TInstantMemo).Value := ReadMemoField(DataSet, AFieldName);
  end;

  procedure ReadPartAttribute;
  var
    Stream: TStream;
    LPartClassName: string;
    LPartId: string;
  begin
    if AttributeMetadata.StorageKind = skExternal then
    begin
      with (Attribute as TInstantPart) do
      begin
        // Must clear Value first to avoid leak for Refresh operation
        // as OldValue = NewValue.
        Value := nil;
        LPartClassName := ReadStringField(DataSet, AFieldName +
          InstantClassFieldName);
        LPartId := ReadStringField(DataSet, AFieldName +
          InstantIdFieldName);
        // LPartClassName and LPartId will be empty if the attribute was
        // added to a class with existing instances in the database.
        if (LPartClassName = '') and (LPartId = '') then
           (Attribute as TInstantPart).Reset
        else
          Value := InstantFindClass(LPartClassName).Retrieve(LPartId,
            False, False, AObject.Connector);
      end;
    end
    else
    begin
      Stream := CreateEmbeddedObjectInputStream(
        (Attribute as TInstantPart).Connector,
        DataSet.FieldByName(AFieldName));
      try
        if Stream.Size = 0 then
          (Attribute as TInstantPart).Reset
        else
          (Attribute as TInstantPart).LoadObjectFromStream(Stream);
      finally
        Stream.Free;
      end;
    end;
  end;

  procedure ReadPartsAttribute;
  var
    Stream: TStream;
    LinkResolver: TInstantSQLLinkResolver;
  begin
    if AttributeMetadata.StorageKind = skExternal then
    begin
      with (Attribute as TInstantParts) do
      begin
        Clear;
        LinkResolver := TInstantSQLLinkResolver.Create(Self,
            AttributeMetadata.ExternalStorageName, AObject);
        try
          LinkResolver.ReadAttributeObjects(TInstantParts(Attribute),
              AObjectId);
        finally
          LinkResolver.Free;
        end;
      end;
    end
    else
    begin
      Stream := CreateEmbeddedObjectInputStream(
        (Attribute as TInstantParts).Connector,
        DataSet.FieldByName(AFieldName));
      try
        if Stream.Size = 0 then
          (Attribute as TInstantParts).Reset
        else
          (Attribute as TInstantParts).LoadObjectsFromStream(Stream);
      finally
        Stream.Free;
      end;
    end;
  end;

  procedure ReadReferenceAttribute;
  begin
    (Attribute as TInstantReference).ReferenceObject(
      ReadStringField(DataSet, AFieldName + InstantClassFieldName),
      ReadStringField(DataSet, AFieldName + InstantIdFieldName));
  end;

  procedure ReadReferencesAttribute;
  var
    Stream: TStream;
    LinkResolver: TInstantSQLLinkResolver;
  begin
    if AttributeMetadata.StorageKind = skExternal then
    begin
      with (Attribute as TInstantReferences) do
      begin
        Clear;
        LinkResolver := TInstantSQLLinkResolver.Create(Self,
            AttributeMetadata.ExternalStorageName, AObject);
        try
          LinkResolver.ReadAttributeObjects(TInstantReferences(Attribute),
              AObjectId);
        finally
          LinkResolver.Free;
        end;
      end;
    end
    else
    begin
      Stream := CreateEmbeddedObjectInputStream(
        (Attribute as TInstantReferences).Connector,
        DataSet.FieldByName(AFieldName));
      try
        if Stream.Size = 0 then
          (Attribute as TInstantReferences).Reset
        else
          (Attribute as TInstantReferences).LoadReferencesFromStream(Stream);
      finally
        Stream.Free;
      end;
    end;
  end;

  procedure ReadStringAttribute;
  begin
    (Attribute as TInstantString).Value :=
      ReadStringField(DataSet, AFieldName);
  end;

begin
  with AttributeMetadata do
  begin
    Attribute := AObject.AttributeByName(Name);
    AFieldName := FieldName;
    case AttributeType of
      atInteger:
        ReadIntegerAttribute;
      atFloat:
        ReadFloatAttribute;
      atCurrency:
        ReadCurrencyAttribute;
      atBoolean:
        ReadBooleanAttribute;
      atString:
        ReadStringAttribute;
      atDateTime:
        ReadDateTimeAttribute;
      atDate:
        ReadDateAttribute;
      atTime:
        ReadTimeAttribute;
      atBlob, atGraphic:
        ReadBlobAttribute;
      atMemo:
        ReadMemoAttribute;
      atPart:
        ReadPartAttribute;
      atReference:
        ReadReferenceAttribute;
      atParts:
        ReadPartsAttribute;
      atReferences:
        ReadReferencesAttribute;
    end;
  end;
end;

procedure TInstantSQLResolver.ReadAttributes(AObject: TInstantObject;
  const AObjectId: string; Map: TInstantAttributeMap; DataSet: TDataSet);
var
  I: Integer;
begin
  if Assigned(AObject) and Assigned(Map) and Assigned(DataSet) then
    for I := 0 to Pred(Map.Count) do
      ReadAttribute(AObject, AObjectId, Map[I], DataSet);
end;

function TInstantSQLResolver.ReadBlobField(DataSet: TDataSet;
  const FieldName: string): string;
begin
  Result := DataSet.FieldByName(FieldName).AsString;
end;

function TInstantSQLResolver.ReadBooleanField(DataSet: TDataSet;
  const FieldName: string): Boolean;
begin
  Result := DataSet.FieldByName(FieldName).AsBoolean;
end;

function TInstantSQLResolver.ReadCurrencyField(DataSet: TDataSet;
  const FieldName: string): Currency;
begin
  Result := DataSet.FieldByName(FieldName).AsCurrency;
end;

function TInstantSQLResolver.ReadDateTimeField(DataSet: TDataSet;
  const FieldName: string): TDateTime;
begin
  Result := DataSet.FieldByName(FieldName).AsDateTime;
end;

function TInstantSQLResolver.ReadDateField(DataSet: TDataSet;
  const FieldName: string): TDateTime;
begin
  Result := DateOf(DataSet.FieldByName(FieldName).AsDateTime);
end;

function TInstantSQLResolver.ReadTimeField(DataSet: TDataSet;
  const FieldName: string): TDateTime;
begin
  Result := TimeOf(DataSet.FieldByName(FieldName).AsDateTime);
end;

function TInstantSQLResolver.ReadFloatField(DataSet: TDataSet;
  const FieldName: string): Double;
begin
  Result := DataSet.FieldByName(FieldName).AsFloat;
end;

function TInstantSQLResolver.ReadIntegerField(DataSet: TDataSet;
  const FieldName: string): Integer;
begin
  Result := DataSet.FieldByName(FieldName).AsInteger;
end;

function TInstantSQLResolver.ReadMemoField(DataSet: TDataSet;
  const FieldName: string): string;
begin
  Result := TrimRight(DataSet.FieldByName(FieldName).AsString);
end;

function TInstantSQLResolver.ReadStringField(DataSet: TDataSet;
  const FieldName: string): string;
begin
  Result := TrimRight(DataSet.FieldByName(FieldName).AsString);
end;

procedure TInstantSQLResolver.RemoveConcurrencyParam(Params: TParams);
var
  Param: TParam;
begin
  Param := Params.FindParam(ConcurrencyParamName);
  if Assigned(Param) then
    Params.Delete(Param.Index);
end;

procedure TInstantSQLResolver.RemovePersistentIdParam(Params: TParams);
var
  Param: TParam;
begin
  Param := Params.FindParam(PersistentIdParamName);
  if Assigned(Param) then
    Params.Delete(Param.Index);
end;

procedure TInstantSQLResolver.RetrieveMapFromDataSet(const AObject: TInstantObject;
  const AObjectId: string; const AMap: TInstantAttributeMap;
  ConflictAction: TInstantConflictAction; AInfo: PInstantOperationInfo;
  const ADataSet: TDataSet);
var
  LInfo: TInstantOperationInfo;
begin
  Assert(Assigned(AObject));
  Assert(Assigned(ADataSet));

  if not Assigned(AInfo) then
    AInfo := @LInfo;

  AInfo.Success := not ADataSet.Eof;
  AInfo.Conflict := not AInfo.Success;
  if AInfo.Success then
  begin
    if AMap.IsRootMap then
      Broker.SetObjectUpdateCount(AObject, ADataSet.FieldByName(InstantUpdateCountFieldName).AsInteger);
    ReadAttributes(AObject, AObjectId, AMap, ADataSet);
  end
  else
    ResetAttributes(AObject, AMap);
end;

function TInstantSQLResolver.TranslateError(AObject: TInstantObject;
  E: Exception): Exception;
begin
  Result := nil;
end;

constructor TInstantLinkResolver.Create(AResolver: TInstantCustomResolver);
begin
  inherited Create;
  FResolver := AResolver;
end;

procedure TInstantLinkResolver.ClearAttributeLinkRecords;
begin
  InternalClearAttributeLinkRecords;
end;

procedure TInstantLinkResolver.DisposeDeletedAttributeObjects(Attribute:
    TInstantContainer);
begin
  InternalDisposeDeletedAttributeObjects(Attribute);
end;

function TInstantLinkResolver.GetBroker: TInstantCustomRelationalBroker;
begin
  Result := Resolver.Broker;
end;

function TInstantLinkResolver.GetResolver: TInstantCustomResolver;
begin
  Result := FResolver;
end;

procedure TInstantLinkResolver.InternalClearAttributeLinkRecords;
begin
end;

procedure TInstantLinkResolver.InternalDisposeDeletedAttributeObjects(
    Attribute: TInstantContainer);
begin
end;

procedure TInstantLinkResolver.InternalReadAttributeObjects(Attribute:
    TInstantContainer; const AObjectId: string);
begin
end;

procedure TInstantLinkResolver.InternalStoreAttributeObjects(Attribute:
    TInstantContainer);
begin
end;

procedure TInstantLinkResolver.ReadAttributeObjects(Attribute:
    TInstantContainer; const AObjectId: string);
begin
  InternalReadAttributeObjects(Attribute, AObjectId);
end;

procedure TInstantLinkResolver.StoreAttributeObjects(Attribute:
    TInstantContainer);
begin
  InternalStoreAttributeObjects(Attribute);
end;

constructor TInstantNavigationalLinkResolver.Create(AResolver:
    TInstantNavigationalResolver; const ATableName: string);
begin
  inherited Create(AResolver);
  FTableName := ATableName;
end;

destructor TInstantNavigationalLinkResolver.Destroy;
begin
  FreeDataSet;
  inherited;
end;

procedure TInstantNavigationalLinkResolver.Append;
begin
  DataSet.Append;
end;

procedure TInstantNavigationalLinkResolver.Cancel;
begin
  DataSet.Cancel;
end;

procedure TInstantNavigationalLinkResolver.Close;
begin
  DataSet.Close;
end;

procedure TInstantNavigationalLinkResolver.Delete;
begin
  DataSet.Delete;
end;

procedure TInstantNavigationalLinkResolver.Edit;
begin
  DataSet.Edit;
end;

function TInstantNavigationalLinkResolver.Eof: Boolean;
begin
  Result := DataSet.Eof;
end;

function TInstantNavigationalLinkResolver.FieldByName(const FieldName: string):
    TField;
begin
  Result := DataSet.FieldByName(FieldName);
end;

procedure TInstantNavigationalLinkResolver.First;
begin
  Dataset.First;
end;

procedure TInstantNavigationalLinkResolver.FreeDataSet;
begin
  if FFreeDataSet then
    FreeAndNil(FDataSet);
end;

function TInstantNavigationalLinkResolver.GetBroker: TInstantNavigationalBroker;
begin
  Result := Resolver.Broker;
end;

function TInstantNavigationalLinkResolver.GetDataSet: TDataSet;
begin
  if not Assigned(FDataSet) then
  begin
    Broker.Connector.DoGetDataSet(TableName, FDataSet);
    if not Assigned(FDataSet) then
    begin
      FDataSet := CreateDataSet;
      FFreeDataSet := True;
    end;
    Broker.Connector.DoInitDataSet(TableName, FDataSet);
  end;
  Result := FDataSet;
end;

function TInstantNavigationalLinkResolver.GetResolver:
    TInstantNavigationalResolver;
begin
  Result := inherited Resolver as TInstantNavigationalResolver;
end;

procedure TInstantNavigationalLinkResolver.InternalClearAttributeLinkRecords;
var
  WasOpen: Boolean;
begin
  WasOpen := Dataset.Active;

  if not WasOpen then
    Open;
  try
    SetDatasetParentRange(Resolver.ObjectClassname, Resolver.ObjectId);
    First;
    while not Eof do
      Delete;
  finally
    if not WasOpen then
      Close;
  end;
end;

procedure TInstantNavigationalLinkResolver.InternalDisposeDeletedAttributeObjects(
    Attribute: TInstantContainer);
var
  Obj: TInstantObject;
  AttributeMetadata: TInstantAttributeMetadata;
  ObjDisposed: Boolean;
  WasOpen: Boolean;
begin
  WasOpen := Dataset.Active;

  if not WasOpen then
    Open;
  try
    SetDatasetParentRange(Attribute.Owner.ClassName, Attribute.Owner.Id);
    First;
    AttributeMetadata := Attribute.Metadata;
    while not Eof do
    begin
      ObjDisposed := False;
      Obj := AttributeMetadata.ObjectClass.Retrieve(
        FieldByName(InstantChildIdFieldName).AsString,
        False, False, Attribute.Connector) as TInstantObject;
      try
        if Assigned(Obj) and
          (Attribute.IndexOf(Obj) = -1) then
        begin
          Resolver.DisposeObject(Obj, caIgnore);
          Delete;
          ObjDisposed := True;
        end;
      finally
        Obj.Free;
      end;
      if not ObjDisposed then
        Next;
    end;
  finally
    if not WasOpen then
      Close;
  end;
end;

procedure TInstantNavigationalLinkResolver.InternalReadAttributeObjects(
    Attribute: TInstantContainer; const AObjectId: string);
var
  WasOpen: Boolean;
  LChildClassField, LChildIdField: TField;
begin
  WasOpen := Dataset.Active;

  if not WasOpen then
    Open;
  try
    // Attribute.Owner.Id can be '', so do not use here.
    SetDatasetParentRange(Attribute.Owner.Classname, AObjectId);
    First;
    LChildClassField := FieldByName(InstantChildClassFieldName);
    LChildIdField := FieldByName(InstantChildIdFieldName);
    while not Eof do
    begin
      Attribute.AddReference(LChildClassField.AsString, LChildIdField.AsString);
      Next;
    end;
  finally
    if not WasOpen then
      Close;
  end;
end;

procedure TInstantNavigationalLinkResolver.InternalStoreAttributeObjects(
    Attribute: TInstantContainer);
var
  I: Integer;
  Obj: TInstantObject;
  WasOpen: Boolean;
begin
  WasOpen := Dataset.Active;

  if not WasOpen then
    Open;
  try
    for I := 0 to Pred(Attribute.Count) do
    begin
      Obj := Attribute.Items[I];
      if Obj.InUpdate then     // prevent recursion
        Continue;
      Obj.CheckId;
      Append;
      try
        FieldByName(InstantIdFieldName).AsString :=
            Attribute.Connector.GenerateId;
        FieldByName(InstantParentClassFieldName).AsString :=
            Attribute.Owner.ClassName;
        FieldByName(InstantParentIdFieldName).AsString := Attribute.Owner.Id;
        FieldByName(InstantChildClassFieldName).AsString := Obj.ClassName;
        FieldByName(InstantChildIdFieldName).AsString := Obj.Id;
        FieldByName(InstantSequenceNoFieldName).AsInteger := Succ(I);
        Post;
      except
        Cancel;
      end;
      Resolver.StoreObject(Obj, caIgnore);
    end;
  finally
    if not WasOpen then
      Close;
  end;
end;

procedure TInstantNavigationalLinkResolver.Next;
begin
  DataSet.Next;
end;

procedure TInstantNavigationalLinkResolver.Open;
begin
  DataSet.Open;
end;

procedure TInstantNavigationalLinkResolver.Post;
begin
  DataSet.Post;
end;

procedure TInstantNavigationalLinkResolver.SetDataSet(Value: TDataset);
begin
  if Value <> FDataSet then
  begin
    FreeDataSet;
    FDataSet := Value;
  end;
end;

constructor TInstantSQLLinkResolver.Create(AResolver: TInstantSQLResolver;
    const ATableName: string; AObject: TInstantObject);
begin
  inherited Create(AResolver);
  FTableName := ATableName;
  FAttributeOwner := AObject;
end;

function TInstantSQLLinkResolver.GetBroker: TInstantSQLBroker;
begin
  Result := Resolver.Broker;
end;

function TInstantSQLLinkResolver.GetResolver: TInstantSQLResolver;
begin
  Result := FResolver as TInstantSQLResolver;
end;

procedure TInstantSQLLinkResolver.InternalClearAttributeLinkRecords;
var
  Params: TParams;
  Statement: string;
begin
  Params := TParams.Create;
  try
    Statement := Format(Resolver.DeleteExternalSQL,
      [TableName,
      InstantParentClassFieldName,
      InstantParentIdFieldName]);
    Resolver.AddStringParam(Params, InstantParentClassFieldName,
        AttributeOwner.ClassName);
    Resolver.AddIdParam(Params, InstantParentIdFieldName,
        AttributeOwner.Id);
    Broker.Execute(Statement, Params);
  finally
    Params.Free;
  end;
end;

procedure TInstantSQLLinkResolver.InternalDisposeDeletedAttributeObjects(
    Attribute: TInstantContainer);
var
  Statement: string;
  Params: TParams;
  Dataset: TDataset;
  Obj: TInstantObject;
begin
  // Delete all objects
  Params := TParams.Create;
  try
    Statement := Format(Resolver.SelectExternalSQL, [TableName]);
    Resolver.AddIdParam(Params, InstantParentIdFieldName, AttributeOwner.Id);
    Resolver.AddStringParam(Params, InstantParentClassFieldName,
        AttributeOwner.ClassName);
    DataSet := Broker.AcquireDataSet(Statement, Params);
    try
      DataSet.Open;
      try
        while not DataSet.Eof do
        begin
          Obj := InstantFindClass(DataSet.FieldByName(InstantChildClassFieldName).AsString).Retrieve(
              DataSet.FieldByName(InstantChildIdFieldName).AsString,
              False, False, Attribute.Connector) as TInstantObject;
          try
            if Assigned(Obj) and
                (Attribute.IndexOf(Obj) = -1) then
              Resolver.DisposeObject(Obj, caIgnore);
          finally
            Obj.Free;
          end;
          DataSet.Next;
        end;
      finally
        DataSet.Close;
      end;
    finally
      Broker.ReleaseDataSet(DataSet);
    end;
  finally
    Params.Free;
  end;
end;

procedure TInstantSQLLinkResolver.InternalReadAttributeObjects(
  Attribute: TInstantContainer; const AObjectId: string);
var
  Statement: string;
  Params: TParams;
  Dataset: TDataSet;
  LChildClassField, LChildIdField: TField;
begin
  Params := TParams.Create;
  try
    Statement := Format(Resolver.SelectExternalSQL, [TableName]);
    Resolver.AddIdParam(Params, InstantParentIdFieldName, AObjectId);
    Resolver.AddStringParam(Params, InstantParentClassFieldName,
      AttributeOwner.ClassName);
    DataSet := Broker.AcquireDataSet(Statement, Params);
    try
      DataSet.Open;
      try
        LChildClassField := DataSet.FieldByName(InstantChildClassFieldName);
        LChildIdField := DataSet.FieldByName(InstantChildIdFieldName);
        while not DataSet.Eof do
        begin
          Attribute.AddReference(LChildClassField.AsString, LChildIdField.AsString);
          DataSet.Next;
        end;
      finally
        DataSet.Close;
      end;
    finally
      Broker.ReleaseDataSet(DataSet);
    end;
  finally
    Params.Free;
  end;
end;

procedure TInstantSQLLinkResolver.InternalStoreAttributeObjects(Attribute:
    TInstantContainer);
var
  Params: TParams;
  Statement: string;
  Obj: TInstantObject;
  I: Integer;
begin
  // Store all objects and links
  for I := 0 to Pred(Attribute.Count) do
  begin
    // Store object
    Obj := Attribute.Items[I];
    Obj.CheckId;
    Resolver.StoreObject(Obj, caIgnore);

    // Insert link
    Params := TParams.Create;
    try
      Statement := Format(Resolver.InsertExternalSQL,
          [TableName]);
      Resolver.AddIdParam(Params, InstantIdFieldName,
          Attribute.Connector.GenerateId);
      Resolver.AddStringParam(Params, InstantParentClassFieldName,
          AttributeOwner.ClassName);
      Resolver.AddIdParam(Params, InstantParentIdFieldName,
          AttributeOwner.Id);
      Resolver.AddStringParam(Params, InstantChildClassFieldName,
          Obj.ClassName);
      Resolver.AddIdParam(Params, InstantChildIdFieldName,
          Obj.Id);
      Resolver.AddIntegerParam(Params, InstantSequenceNoFieldName, Succ(I));
      Broker.Execute(Statement, Params);
    finally
      Params.Free;
    end;
  end;
end;

{ TInstantStatement }

function TInstantStatement.AddDataSetRef: Integer;
begin
  Inc(FDataSetRefCount);
  Result := FDataSetRefCount;
end;

constructor TInstantStatement.Create(const AStatementDataSet: TDataSet);
begin
  inherited Create;
  FStatementDataSet := AStatementDataSet;
  FDataSetRefCount := 1;
end;

destructor TInstantStatement.Destroy;
begin
  FStatementDataSet.Free;
  inherited;
end;

function TInstantStatement.ReleaseDataSetRef: Integer;
begin
  Dec(FDataSetRefCount);
  Result := FDataSetRefCount;
end;

{ TInstantStatementCache }

constructor TInstantStatementCache.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FStatements := TStringList.Create;
  FStatements.Sorted := True;
  FStatements.Duplicates := dupError;
  FCapacity := 0;
end;

destructor TInstantStatementCache.Destroy;
begin
  DeleteAllStatements;
  FStatements.Free;
  inherited;
end;

function TInstantStatementCache.AddStatement(const StatementText: string;
  const StatementDataSet: TDataSet): Integer;
var
  StatementObject: TInstantStatement;
begin
  if Assigned(StatementDataSet) then
  begin
    Shrink;
    StatementObject := TInstantStatement.Create(StatementDataSet);
    Result := FStatements.AddObject(StatementText, StatementObject);
    StatementDataSet.FreeNotification(Self);
  end
  else
    Result := -1;
end;

procedure TInstantStatementCache.DeleteAllStatements;
var
  I: Integer;
begin
  for I := FStatements.Count - 1 downto 0 do
    DeleteStatement(I);
end;

procedure TInstantStatementCache.DeleteStatement(const Index: Integer);
var
  AObject: TObject;
begin
  // Avoid looping with Notification.
  AObject := FStatements.Objects[Index];
  FStatements.Delete(Index);
  AObject.Free;
end;

function TInstantStatementCache.GetStatement(const StatementText: string): TInstantStatement;
var
  Index: Integer;
begin
  Index := FStatements.IndexOf(StatementText);
  if Index >= 0 then
  begin
    Result := TInstantStatement(FStatements.Objects[Index]);
    Result.AddDataSetRef;
  end
  else
    Result := nil;
end;

function TInstantStatementCache.GetStatementByIndex(
  const AIndex: Integer): TInstantStatement;
begin
  Result := TinstantStatement(FStatements.Objects[AIndex]);
end;

function TInstantStatementCache.IndexOfStatementDataSet(
  const StatementDataSet: TDataSet): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FStatements.Count - 1 do
  begin
    if TinstantStatement(FStatements.Objects[I]).StatementDataSet = StatementDataSet then
    begin
      Result := I;
      Break;
    end;
  end;
end;

procedure TInstantStatementCache.Notification(AComponent: TComponent; Operation: TOperation);
var
  I: Integer;
begin
  inherited;
  if Operation = opRemove then
    for I := FStatements.Count - 1 downto 0 do
      if TInstantStatement(FStatements.Objects[I]).StatementDataSet = AComponent then
        DeleteStatement(I);
end;

function TInstantStatementCache.RemoveStatement(const StatementText: string): Boolean;
var
  Index: Integer;
begin
  Index := FStatements.IndexOf(StatementText);
  if Index >= 0 then
  begin
    DeleteStatement(Index);
    Result := True;
  end
  else
    Result := False;
end;

procedure TInstantStatementCache.SetCapacity(const Value: Integer);
begin
  FCapacity := Value;
  Shrink;
end;

procedure TInstantStatementCache.Shrink;
begin
  // TODO : implement a shrink policy here when the cache can be limited in size.
  // currently the cache is always unlimited if enabled (Capacity <> 0).
end;

{ TInstantBrokerCatalog }

constructor TInstantBrokerCatalog.Create(const AScheme: TInstantScheme;
  const ABroker: TInstantBroker);
begin
  inherited Create(AScheme);
  FBroker := ABroker;
end;

function TInstantBrokerCatalog.GetBroker: TInstantBroker;
begin
  if not Assigned(FBroker) then
    raise EInstantError.Create(SUnassignedBroker);
  Result := FBroker;
end;

{ TInstantSQLBrokerCatalog }

function TInstantSQLBrokerCatalog.GetBroker: TInstantSQLBroker;
begin
  Result := inherited Broker as TInstantSQLBroker;
end;

constructor TInstantSQLGenerator.Create(ABroker: TInstantSQLBroker);
begin
  inherited Create;
  FBroker := ABroker;
end;

{ TInstantSQLGenerator }

function TInstantSQLGenerator.BuildAssignment(const AName: string): string;
begin
  Result := EmbraceField(AName) + ' = ' + BuildParam(AName);
end;

function TInstantSQLGenerator.BuildAssignmentList(Map: TInstantAttributeMap;
  Additional: array of string): string;
begin
  Result := BuildList(Map, Additional, BuildAssignment);
end;

function TInstantSQLGenerator.BuildConcurrencyCriteria: string;
begin
  Result := Format(' AND %s = %s', [EmbraceField(InstantUpdateCountFieldName),
    BuildParam(ConcurrencyParamName)]);
end;

function TInstantSQLGenerator.BuildFieldList(const S: string): string;
var
  I: Integer;
  List: TStringList;
begin
  List := TStringList.Create;
  try
    InstantStrToList(S, List, [';']);
    Result := '';
    for I := 0 to Pred(List.Count) do
      Result := Result + InstantEmbrace(List[I], Broker.SQLDelimiters) + ', ';
    if Length(Result) > 0 then
      Delete(Result, Length(Result) - 1, 2);
  finally
    List.Free;
  end;
end;

function TInstantSQLGenerator.BuildFieldList(Map: TInstantAttributeMap;
  Additional: array of string): string;
begin
  Result := BuildList(Map, Additional, EmbraceField);
end;

function TInstantSQLGenerator.BuildList(Map: TInstantAttributeMap;
  Additional: array of string; StringFunc: TInstantStringFunc;
  const Delimiter: string): string;

  function SpaceDelimiter: string;
  begin
    Result := Format(' %s ', [Delimiter]);
  end;

var
  I: Integer;
  AttributeMetadata: TInstantAttributeMetadata;
  FieldName, RefClassFieldName, RefIdFieldName: string;
begin
  if not Assigned(StringFunc) then
    StringFunc := EmbraceField;
  Result := '';
  if Assigned(Map) then
    for I := 0 to Pred(Map.Count) do
    begin
      AttributeMetadata := Map[I];
      FieldName := AttributeMetadata.FieldName;
      if AttributeMetadata.AttributeType = atReference then
      begin
        RefClassFieldName := FieldName + InstantClassFieldName;
        RefIdFieldName := FieldName + InstantIdFieldName;
        Result := Result + StringFunc(RefClassFieldName) + ', ' +
          StringFunc(RefIdFieldName);
        Result := Result + SpaceDelimiter;
      end
      else if AttributeMetadata.AttributeType = atPart then
      begin
        if AttributeMetadata.StorageKind = skExternal then
        begin
          RefClassFieldName := FieldName + InstantClassFieldName;
          RefIdFieldName := FieldName + InstantIdFieldName;
          Result := Result + StringFunc(RefClassFieldName) + ', ' +
            StringFunc(RefIdFieldName);
          Result := Result + SpaceDelimiter;
        end
        else if AttributeMetadata.StorageKind = skEmbedded then
        begin
          Result := Result + StringFunc(FieldName);
          Result := Result + SpaceDelimiter;
        end;
      end
      else if AttributeMetadata.AttributeType in [atParts, atReferences] then
      begin
        if AttributeMetadata.StorageKind = skEmbedded then
        begin
          Result := Result + StringFunc(FieldName);
          Result := Result + SpaceDelimiter;
        end;
      end
      else
      begin
        Result := Result + StringFunc(FieldName);
        Result := Result + SpaceDelimiter;
      end;
    end;
  for I := Low(Additional) to High(Additional) do
    Result := Result + StringFunc(Additional[I]) + SpaceDelimiter;
  Delete(Result, Length(Result) - Length(Delimiter), Length(Delimiter) + 2);
end;

function TInstantSQLGenerator.BuildParam(const AName: string): string;
begin
  Result := ':' + AName;
end;

function TInstantSQLGenerator.BuildParamList(Map: TInstantAttributeMap;
  Additional: array of string): string;
begin
  Result := BuildList(Map, Additional, BuildParam);
end;

function TInstantSQLGenerator.BuildPersistentIdCriteria: string;
begin
  Result := Format(' AND %s = %s', [EmbraceField(InstantIdFieldName),
    BuildParam(PersistentIdParamName)]);
end;

function TInstantSQLGenerator.BuildWhereStr(Fields: array of string): string;
begin
  Result := BuildList(nil, Fields, BuildAssignment, 'AND');
end;

function TInstantSQLGenerator.EmbraceField(const FieldName: string): string;
begin
  Result := InstantEmbrace(FieldName, Delimiters);
end;

function TInstantSQLGenerator.EmbraceTable(const TableName: string): string;
begin
  Result := InstantEmbrace(TableName, Delimiters);
end;

function TInstantSQLGenerator.GenerateAddFieldSQL(
  Metadata: TInstantFieldMetadata): string;
begin
  Result := InternalGenerateAddFieldSQL(Metadata);
end;

function TInstantSQLGenerator.GenerateAlterFieldSQL(OldMetadata,
  NewMetadata: TInstantFieldMetadata): string;
begin
  Result := InternalGenerateAlterFieldSQL(OldMetadata, NewMetadata);
end;

function TInstantSQLGenerator.GenerateCreateIndexSQL(
  Metadata: TInstantIndexMetadata): string;
begin
  Result := InternalGenerateCreateIndexSQL(Metadata);
end;

function TInstantSQLGenerator.GenerateCreateTableSQL(
  Metadata: TInstantTableMetadata): string;
begin
  Result := InternalGenerateCreateTableSQL(Metadata);
end;

function TInstantSQLGenerator.GenerateDeleteConcurrentSQL
  (Map: TInstantAttributeMap): string;
begin
  Result := InternalGenerateDeleteConcurrentSQL(Map);
end;

function TInstantSQLGenerator.GenerateDeleteExternalSQL(
  Map: TInstantAttributeMap): string;
begin
  Result := InternalGenerateDeleteExternalSQL(Map);
end;

function TInstantSQLGenerator.GenerateDeleteSQL
  (Map: TInstantAttributeMap): string;
begin
  Result := InternalGenerateDeleteSQL(Map);
end;

function TInstantSQLGenerator.GenerateDropFieldSQL(
  Metadata: TInstantFieldMetadata): string;
begin
  Result := InternalGenerateDropFieldSQL(Metadata);
end;

function TInstantSQLGenerator.GenerateDropIndexSQL(
  Metadata: TInstantIndexMetadata): string;
begin
  Result := InternalGenerateDropIndexSQL(Metadata);
end;

function TInstantSQLGenerator.GenerateDropTableSQL(
  Metadata: TInstantTableMetadata): string;
begin
  Result := InternalGenerateDropTableSQL(Metadata);
end;

function TInstantSQLGenerator.GenerateInsertExternalSQL(
  Map: TInstantAttributeMap): string;
begin
  Result := InternalGenerateInsertExternalSQL(Map)
end;

function TInstantSQLGenerator.GenerateInsertSQL
  (Map: TInstantAttributeMap): string;
begin
  Result := InternalGenerateInsertSQL(Map);
end;

function TInstantSQLGenerator.GenerateSelectExternalPartSQL(
  Map: TInstantAttributeMap): string;
begin
  Result := InternalGenerateSelectExternalPartSQL(Map);
end;

function TInstantSQLGenerator.GenerateSelectExternalSQL(
  Map: TInstantAttributeMap): string;
begin
  Result := InternalGenerateSelectExternalSQL(Map);
end;

function TInstantSQLGenerator.GenerateSelectSQL
  (Map: TInstantAttributeMap): string;
begin
  Result := InternalGenerateSelectSQL(Map);
end;

function TInstantSQLGenerator.GenerateSelectTablesSQL: string;
begin
  Result := InternalGenerateSelectTablesSQL;
end;

function TInstantSQLGenerator.GenerateUpdateConcurrentSQL
  (Map: TInstantAttributeMap): string;
begin
  Result := InternalGenerateUpdateConcurrentSQL(Map);
end;

function TInstantSQLGenerator.GenerateUpdateFieldCopySQL(OldMetadata,
    NewMetadata: TInstantFieldMetadata): string;
begin
  Result := InternalGenerateUpdateFieldCopySQL(OldMetadata, NewMetadata);
end;

function TInstantSQLGenerator.GenerateUpdateSQL
  (Map: TInstantAttributeMap): string;
begin
  Result := InternalGenerateUpdateSQL(Map);
end;

function TInstantSQLGenerator.GetDelimiters: string;
begin
  Result := Broker.SQLDelimiters;
end;

function TInstantSQLGenerator.InternalGenerateAddFieldSQL(
  Metadata: TInstantFieldMetadata): string;
begin
  with Metadata do
    Result := Format('ALTER TABLE %s ADD %s %s',
      [EmbraceTable(TableMetadata.Name),
       EmbraceField(Name),
       Broker.DataTypeToColumnType(DataType, Size)]);
end;

function TInstantSQLGenerator.InternalGenerateAlterFieldSQL(OldMetadata,
  NewMetadata: TInstantFieldMetadata): string;
begin
  Result := Format('ALTER TABLE %s ALTER COLUMN %s TYPE %s',
    [EmbraceTable(OldMetadata.TableMetadata.Name),
     EmbraceField(OldMetadata.Name),
     Broker.DataTypeToColumnType(NewMetadata.DataType, NewMetadata.Size)]);
end;

function TInstantSQLGenerator.InternalGenerateCreateIndexSQL(
  Metadata: TInstantIndexMetadata): string;
var
  Modifier, Columns, TableName: string;
begin
  if ixUnique in Metadata.Options then
    Modifier := 'UNIQUE '
  else
    Modifier := '';
  if ixDescending in Metadata.Options then
    Modifier := Modifier + 'DESCENDING ';
  Columns := BuildFieldList(Metadata.Fields);
  TableName := Metadata.TableMetadata.Name;
  Result := Format('CREATE %sINDEX %s ON %s (%s)',
    [Modifier, Metadata.Name, EmbraceTable(TableName), Columns]);
end;

function TInstantSQLGenerator.InternalGenerateCreateTableSQL(
  Metadata: TInstantTableMetadata): string;
var
  I: Integer;
  FieldMetadata: TInstantFieldMetadata;
  Columns, PrimaryKey: string;
begin
  Columns := '';
  with Metadata do
    for I := 0 to Pred(FieldMetadatas.Count) do
    begin
      FieldMetadata := FieldMetadatas[I];
      with FieldMetadata do
      begin
        if I > 0 then
          Columns := Columns + ', ';
        Columns := Columns + EmbraceField(Name) + ' ' + Broker.DataTypeToColumnType(DataType, Size);
        if foRequired in Options then
          Columns := Columns + ' NOT NULL';
      end;
    end;
  PrimaryKey := '';
  with Metadata do
    for I := 0 to Pred(IndexMetadatas.Count) do
      with IndexMetadatas[I] do
        if ixPrimary in Options then
        begin
          PrimaryKey := BuildFieldList(Fields);
          Break;
        end;
  if PrimaryKey <> '' then
    Columns := Columns + ', PRIMARY KEY (' + PrimaryKey + ')';
  Result := Format('CREATE TABLE %s (%s)',
    [EmbraceTable(Metadata.Name), Columns]);
end;

function TInstantSQLGenerator.InternalGenerateDeleteConcurrentSQL
  (Map: TInstantAttributeMap): string;
begin
  Result := InternalGenerateDeleteSQL(Map) + BuildConcurrencyCriteria;
end;

function TInstantSQLGenerator.InternalGenerateDeleteExternalSQL(
  Map: TInstantAttributeMap): string;
var
  WhereStr: string;
begin
  WhereStr := BuildWhereStr([InstantParentClassFieldName,
    InstantParentIdFieldName]);
  Result := Format('DELETE FROM %s WHERE %s',
    [EmbraceTable('%s'), WhereStr]);
end;

function TInstantSQLGenerator.InternalGenerateDeleteSQL
  (Map: TInstantAttributeMap): string;
var
  WhereStr: string;
begin
  WhereStr := BuildWhereStr([InstantClassFieldName, InstantIdFieldName]);
  Result := Format('DELETE FROM %s WHERE %s',
    [EmbraceTable(Map.Name), WhereStr]);
end;

function TInstantSQLGenerator.InternalGenerateDropFieldSQL(
  Metadata: TInstantFieldMetadata): string;
begin
  with Metadata do
    Result := Format('ALTER TABLE %s DROP %s',
      [EmbraceTable(TableMetadata.Name),
       EmbraceField(Name)]);
end;

function TInstantSQLGenerator.InternalGenerateDropIndexSQL(
  Metadata: TInstantIndexMetadata): string;
begin
  Result := Format('DROP INDEX %s', [Metadata.Name]);
end;

function TInstantSQLGenerator.InternalGenerateDropTableSQL(
  Metadata: TInstantTableMetadata): string;
begin
  Result := Format('DROP TABLE %s', [EmbraceTable(Metadata.Name)]);
end;

function TInstantSQLGenerator.InternalGenerateInsertExternalSQL(
  Map: TInstantAttributeMap): string;
var
  FieldStr, ParamStr: string;
begin
  FieldStr := Format('%s, %s, %s, %s, %s, %s',
    [EmbraceField(InstantIdFieldName),
    EmbraceField(InstantParentClassFieldName),
    EmbraceField(InstantParentIdFieldName),
    EmbraceField(InstantChildClassFieldName),
    EmbraceField(InstantChildIdFieldName),
    EmbraceField(InstantSequenceNoFieldName)]);
  ParamStr := Format(':%s, :%s, :%s, :%s, :%s, :%s',
    [InstantIdFieldName,
    InstantParentClassFieldName, InstantParentIdFieldName,
    InstantChildClassFieldName, InstantChildIdFieldName,
    InstantSequenceNoFieldName]);
  Result := Format('INSERT INTO %s (%s) VALUES (%s)',
    [EmbraceTable('%s'), FieldStr, ParamStr]);
end;

function TInstantSQLGenerator.InternalGenerateInsertSQL
  (Map: TInstantAttributeMap): string;
var
  FieldStr, ParamStr: string;
begin
  FieldStr := BuildFieldList(Map,
    [InstantClassFieldName, InstantIdFieldName, InstantUpdateCountFieldName]);
  ParamStr := BuildParamList(Map,
    [InstantClassFieldName, InstantIdFieldName, InstantUpdateCountFieldName]);
  Result := Format('INSERT INTO %s (%s) VALUES (%s)',
    [EmbraceTable(Map.Name), FieldStr, ParamStr]);
  Result := Result + ' ';
end;

function TInstantSQLGenerator.InternalGenerateSelectExternalPartSQL(
  Map: TInstantAttributeMap): string;
var
  FieldStr, WhereStr: string;
begin
  FieldStr := Format('%s, %s', [EmbraceField('%s'), EmbraceField('%s')]);
  WhereStr := Format('%s = :%s AND %s = :%s',
    [EmbraceField(InstantClassFieldName), InstantClassFieldName,
     EmbraceField(InstantIdFieldName), InstantIdFieldName]);
  Result := Format('SELECT %s FROM %s WHERE %s',
    [FieldStr, EmbraceTable('%s'), WhereStr]);
end;

function TInstantSQLGenerator.InternalGenerateSelectExternalSQL(
  Map: TInstantAttributeMap): string;
var
  FieldStr, WhereStr: string;
begin
  FieldStr := Format('%s, %s, %s', [EmbraceField(InstantChildClassFieldName),
    EmbraceField(InstantChildIdFieldName), EmbraceField(InstantSequenceNoFieldName)]);
  WhereStr := Format('%s = :%s AND %s = :%s',
    [EmbraceField(InstantParentClassFieldName), InstantParentClassFieldName,
    EmbraceField(InstantParentIdFieldName), InstantParentIdFieldName]);
  Result := Format('SELECT %s FROM %s WHERE %s ORDER BY %s',
    [FieldStr, EmbraceTable('%s'), WhereStr, EmbraceField(InstantSequenceNoFieldName)]);
end;

function TInstantSQLGenerator.InternalGenerateSelectSQL
  (Map: TInstantAttributeMap): string;
var
  FieldStr, WhereStr: string;
begin
  FieldStr := BuildFieldList(Map, [InstantUpdateCountFieldName]);
  WhereStr := BuildWhereStr([InstantClassFieldName, InstantIdFieldName]);
  Result := Format('SELECT %s FROM %s WHERE %s',
    [FieldStr, EmbraceTable(Map.Name), WhereStr]);
end;

function TInstantSQLGenerator.InternalGenerateSelectTablesSQL: string;
begin
  raise EInstantError.CreateFmt(SUnsupportedOperation,
    ['InternalGenerateSelectTablesSQL']);
end;

function TInstantSQLGenerator.InternalGenerateUpdateConcurrentSQL
  (Map: TInstantAttributeMap): string;
begin
  Result := InternalGenerateUpdateSQL(Map) + BuildConcurrencyCriteria;
end;

function TInstantSQLGenerator.InternalGenerateUpdateFieldCopySQL(OldMetadata,
    NewMetadata: TInstantFieldMetadata): string;
begin
  Result := Format('UPDATE %s SET %s = %s',
                    [EmbraceTable(OldMetadata.TableMetadata.Name),
                     EmbraceField(NewMetadata.Name),
                     EmbraceField(OldMetadata.Name)]);
end;

function TInstantSQLGenerator.InternalGenerateUpdateSQL
  (Map: TInstantAttributeMap): string;
var
  AssignmentStr, WhereStr: string;
begin
  AssignmentStr := BuildAssignmentList(Map,
    [InstantIdFieldName, InstantUpdateCountFieldName]);
  WhereStr := BuildWhereStr([InstantClassFieldName]) +
    BuildPersistentIdCriteria;
  Result := Format('UPDATE %s SET %s WHERE %s',
    [EmbraceTable(Map.Name), AssignmentStr, WhereStr]);
end;

{ TInstantCustomRelationalQuery }

function TInstantCustomRelationalQuery.GetConnector: TInstantRelationalConnector;
begin
  Result := inherited Connector as TInstantRelationalConnector;
end;

function TInstantCustomRelationalQuery.GetStatement: string;
begin
  Result := '';
end;

procedure TInstantCustomRelationalQuery.InternalGetInstantObjectRefs(List:
    TInstantObjectReferenceList);
begin
end;

procedure TInstantCustomRelationalQuery.InternalRefreshObjects;
var
  BusyObjectRefs: TInstantObjectReferenceList;
  Obj: TInstantObject;
  ObjStore: TInstantObjectStore;

  procedure RemoveRefsOfDeletedObjectsFromList;
  var
    I: Integer;
  begin
    for I := Pred(BusyObjectRefs.Count) downto 0 do
      with BusyObjectRefs.RefItems[I] do
      begin
        ObjStore := Connector.ObjectStores.FindObjectStore(ObjectClass);
        if not (Assigned(ObjStore) and Assigned(ObjStore.Find(ObjectId))) then
          BusyObjectRefs.Delete(I);
      end;
  end;

  procedure RefreshObjectsInList;
  var
    I: Integer;
  begin
    for I := 0 to Pred(BusyObjectRefs.Count) do
    begin
      Obj := BusyObjectRefs[I];
      if Assigned(Obj) then
        Obj.Refresh;
    end;
  end;

begin
  BusyObjectRefs := TInstantObjectReferenceList.Create(False, Connector);
  try
    // Collect a reference to all InstantObjects in query.
    // Note: In this list of TInstantObjectReferences
    // OwnsInstance is false.
    InternalGetInstantObjectRefs(BusyObjectRefs);

    Close;

    // Remove references from the BusyList for objects destroyed
    // when the query was closed.
    RemoveRefsOfDeletedObjectsFromList;

    Open;

    // Refresh objects in the BusyList that were not destroyed
    // when the query was closed.
    RefreshObjectsInList;
  finally
    BusyObjectRefs.Free;
  end;
end;

procedure TInstantCustomRelationalQuery.SetStatement(const Value: string);
begin
end;

procedure TInstantCustomRelationalQuery.TranslateCommand;
var
  LTranslator: TInstantRelationalTranslator;
begin
  if TranslatorClass <> nil then
  begin
    LTranslator := TranslatorClass.Create(Self);
    try
      LTranslator.RequestedLoadMode := RequestedLoadMode;
      LTranslator.CommandText := Command;
      Statement := LTranslator.StatementText;
      SetActualLoadMode(LTranslator.ActualLoadMode);
    finally
      LTranslator.Free;
    end;
  end;
end;

class function TInstantCustomRelationalQuery.TranslatorClass: TInstantRelationalTranslatorClass;
begin
  Result := TInstantRelationalTranslator;
end;

{ TInstantQueryTranslator }

constructor TInstantQueryTranslator.Create(AQuery: TInstantQuery);
begin
  inherited Create;
  FQuery := AQuery;
end;

function TInstantQueryTranslator.CreateCommand: TInstantIQLCommand;
begin
  Result := TInstantQueryCommand.Create(nil);
end;

function TInstantQueryTranslator.GetQuery: TInstantQuery;
begin
  Result := FQuery;
  if not Assigned(Result) then
    raise EInstantError.Create(SUnassignedQuery);
end;

function TInstantQueryTranslator.GetResultClassName: string;
begin
  Result := (Command as TInstantQueryCommand).ResultClassName;
end;

destructor TInstantRelationalTranslator.Destroy;
begin
  FreeAndNil(FContext);
  inherited;
end;

{ TInstantRelationalTranslator }

procedure TInstantRelationalTranslator.BeforeTranslate;
begin
  if not Assigned(Command.ClassRef) then
    Exit;

  FContext := TInstantTranslationContext.Create(Command, Quote,
    Delimiters, Connector.IdDataType, RequestedLoadMode);
  SetActualLoadMode(FContext.ActualLoadMode);
end;

procedure TInstantRelationalTranslator.Clear;
begin
  inherited;
  if Assigned(Context) then
    Context.Clear;
end;

function TInstantRelationalTranslator.GetConnector: TInstantRelationalConnector;
begin
  if HasConnector then
    Result := Query.Connector
  else
    Result := nil;
end;

function TInstantRelationalTranslator.GetDelimiters: string;
begin
  if HasConnector then
    Result := Connector.Broker.SQLDelimiters
  else
    Result := '';
end;

function TInstantRelationalTranslator.GetQuery: TInstantCustomRelationalQuery;
begin
  Result := inherited Query as TInstantCustomRelationalQuery;
end;

function TInstantRelationalTranslator.GetQuote: Char;
begin
  if HasConnector then
    Result := Connector.Broker.SQLQuote
  else
    Result := '"';
end;

function TInstantRelationalTranslator.GetWildcard: string;
begin
  if HasConnector then
    Result := Connector.Broker.SQLWildcard
  else
    Result := '%';
end;

function TInstantRelationalTranslator.HasConnector: Boolean;
begin
  Result := Assigned(Query) and Assigned(Query.Connector);
end;

function TInstantRelationalTranslator.IncludeOrderFields: Boolean;
begin
  Result := False;
end;

function TInstantRelationalTranslator.InSubquery(
  const AObject: TInstantIQLObject;
  out ASubQuery: TInstantIQLSubquery): Boolean;
begin
  if AObject is TInstantIQLSubquery then
  begin
    Result := True;
    ASubQuery := TInstantIQLSubquery(AObject);
  end
  else
    Result := False;

  if not Result and Assigned(AObject.Owner) then
    Result := InSubquery(AObject.Owner, ASubQuery);
end;

function TInstantRelationalTranslator.InternalGetObjectClassMetadata: TInstantClassMetadata;
begin
  if Command is TInstantQueryCommand then
    Result := TInstantQueryCommand(Command).ObjectClassMetadata
  else
    Result := nil;
end;

function TInstantRelationalTranslator.IsPrimary(
  AObject: TInstantIQLObject): Boolean;
begin
  Result := Assigned(AObject) and Assigned(Command) and
    ((AObject = Command) or (AObject.Owner = Command));
end;

function TInstantRelationalTranslator.ReplaceWildcard(
  const Str: string): string;
var
  S: string;
begin
  if Wildcard <> '%' then
  begin
    S := StringReplace(Str, '%%', #1, [rfReplaceAll]);
    S := StringReplace(S, '%', WildCard, [rfReplaceAll]);
    Result := StringReplace(S, #1, '%', [rfReplaceAll]);
  end
  else
    Result := Str;
end;

function TInstantRelationalTranslator.TranslateClassRef(
  ClassRef: TInstantIQLClassRef; Writer: TInstantIQLWriter): Boolean;
var
  LSubContext: TInstantTranslationContext;
  LSubQuery: TInstantIQLSubquery;
begin
  Result := Assigned(ClassRef) and Assigned(Writer);
  if Result then
    if IsPrimary(ClassRef) then
    begin
      Context.WriteTables(Writer);
      if not Assigned(Command.Clause) then
        Context.WriteCriterias(Writer, True);
    end
    else if Assigned(ClassRef.Owner) and (ClassRef.Owner is TInstantIQLSubquery) then
    begin
      LSubQuery := TInstantIQLSubQuery(ClassRef.Owner);
      LSubContext := Context.GetSubqueryContext(LSubQuery);

      LSubContext.WriteTables(Writer);
      if not Assigned(LSubQuery.Clause) then
        LSubContext.WriteCriterias(Writer, True);
    end
    else
      Result := False;
end;

function TInstantRelationalTranslator.TranslateClause(
  Clause: TInstantIQLClause; Writer: TInstantIQLWriter): Boolean;
var
  LSubQuery: TInstantIQLSubquery;
  LSubContext: TInstantTranslationContext;
begin
  Result := Assigned(Clause) and Assigned(Writer);
  if Result then
  begin
    if IsPrimary(Clause) then begin
      if Context.WriteCriterias(Writer, False) then
        WriteAnd(Writer);
      Writer.WriteString('(');
      WriteObject(Clause, Writer);
      Writer.WriteString(')');
    end
    else if Assigned(Clause.Owner) and (Clause.Owner is TInstantIQLSubquery) then begin
      LSubQuery := TInstantIQLSubQuery(Clause.Owner);
      LSubContext := Context.GetSubqueryContext(LSubQuery);

      if LSubContext.WriteCriterias(Writer, False) then
        WriteAnd(Writer);
      Writer.WriteString('(');
      WriteObject(Clause, Writer);
      Writer.WriteString(')');
    end
    else
      Result := False;
  end;
end;

function TInstantRelationalTranslator.TranslateConstant(
  Constant: TInstantIQLConstant; Writer: TInstantIQLWriter): Boolean;
var
  S: string;
  LSubContext: TInstantTranslationContext;
  LSubQuery: TInstantIQLSubquery;
begin
  if Assigned(Constant) and Assigned(Writer) then
  begin
    S := Constant.Value;
    if SameText(S, 'NIL') then
    begin
      Writer.WriteString('NULL');
      Result := True;
    end else if SameText(S, 'SELF') then
    begin
      if InSubquery(Constant, LSubQuery) then
      begin
        LSubContext := Context.GetSubqueryContext(LSubQuery);
        Writer.WriteString(LSubContext.Qualify(LSubContext.ClassTablePath, InstantIdFieldName));
        Result := True;
      end
      else
      begin
        Writer.WriteString(Context.Qualify(Context.ClassTablePath, InstantIdFieldName));
        Result := True;
      end

    end else if (Length(S) > 0) and (S[1] = '"') then
    begin
      S := InstantUnquote(S, S[1]);
      S := ReplaceWildCard(S);
      Writer.WriteString(Context.QuoteString(S));
      Result := True;
    end else
      Result := False;
  end else
    Result := False;
end;

function TInstantRelationalTranslator.TranslateFunction(
  AFunction: TInstantIQLFunction; Writer: TInstantIQLWriter): Boolean;
begin
  Result := TranslateFunctionName(AFunction.FunctionName, Writer);
  if Result then
  begin
    Writer.WriteChar('(');
    AFunction.Parameters.Write(Writer);
    Writer.WriteChar(')');
  end;
end;

function TInstantRelationalTranslator.TranslateFunctionName(
  const FunctionName: string; Writer: TInstantIQLWriter): Boolean;
begin
  Result := False;
end;

function TInstantRelationalTranslator.TranslateKeyword(
  const Keyword: string; Writer: TInstantIQLWriter): Boolean;
begin
  if SameText(Keyword, 'ANY') then
    Result := True
  else
    Result := inherited TranslateKeyword(Keyword, Writer);
end;

function TInstantRelationalTranslator.TranslateObject(
  AObject: TInstantIQLObject; Writer: TInstantIQLWriter): Boolean;
begin
  if AObject is TInstantIQLSpecifier then
    Result := TranslateSpecifier(TInstantIQLSpecifier(AObject), Writer)
  else if AObject is TInstantIQLClassRef then
    Result := TranslateClassRef(TInstantIQLClassRef(AObject), Writer)
  else if AObject is TInstantIQLClause then
    Result := TranslateClause(TInstantIQLClause(AObject), Writer)
  else if AObject is TInstantIQLPath then
    Result := TranslatePath(TInstantIQLPath(AObject), Writer)
  else if AObject is TInstantIQLConstant then
    Result := TranslateConstant(TInstantIQLConstant(AObject), Writer)
{  else if AObject is TInstantIQLSubquery then
    Result := TranslateSubquery(TInstantIQLSubquery(AObject), Writer)}
  else if AObject is TInstantIQLSubqueryFunction then
    Result := TranslateSubqueryFunction(TInstantIQLSubqueryFunction(AObject), Writer)
  else if AObject is TInstantIQLFunction then
    Result := TranslateFunction(TInstantIQLFunction(AObject), Writer)
  else
    Result := inherited TranslateObject(AObject, Writer);
end;

function TInstantRelationalTranslator.TranslatePath(Path: TInstantIQLPath;
  Writer: TInstantIQLWriter): Boolean;
var
  PathText, TablePath, FieldName: string;
  AttribMeta: TInstantAttributeMetadata;
  LSubQuery: TInstantIQLSubquery;
  LContext: TInstantTranslationContext;
begin
  Result := Assigned(Path) and Assigned(Writer);
  if Result then
  begin
    PathText := Path.Text;
    if InSubquery(Path, LSubQuery) then
      LContext := Context.GetSubqueryContext(LSubQuery)
    else
      LContext := Context;

    AttribMeta := LContext.PathToTarget(PathText, TablePath, FieldName);

    if Assigned(AttribMeta) and (AttribMeta.Category = acElement) and
      not IsRootAttribute(ExtractTarget(PathText)) then
      FieldName := FieldName + InstantIdFieldName;
    Writer.WriteString(LContext.Qualify(TablePath, FieldName));
  end;
end;

function TInstantRelationalTranslator.TranslateSpecifier(
  Specifier: TInstantIQLSpecifier; Writer: TInstantIQLWriter): Boolean;

  function IncludeOperand(Operand: TInstantIQLOperand): Boolean;
  begin
    if Operand is TInstantIQLPath then
      if Specifier.IsPath then
        Result := not SameText(Specifier.Text, Operand.Text)
      else
        Result := not IsRootAttribute(Operand.Text)
    else if Operand is TInstantIQLConstant then
      Result := not TInstantIQLConstant(Operand).IsSelf and not
        Specifier.IsPath
    else
      Result := False;
  end;

  procedure WriteOrderFields(Writer: TInstantIQLWriter);
  var
    I: Integer;
    PathList: TList;
    Operand: TInstantIQLOperand;
  begin
    PathList := TList.Create;
    try
      CollectObjects(Command.Order, TInstantIQLOperand, PathList, [TInstantIQLSubquery]);
      for I := 0 to Pred(PathList.Count) do
      begin
        Operand := PathList[I];
        if IncludeOperand(Operand) then
        begin
          Writer.WriteString(', ');
          if Operand is TInstantIQLPath then
            TranslatePath(TInstantIQLPath(Operand), Writer)
          else if Operand is TInstantIQLConstant then
            TranslateConstant(TInstantIQLConstant(Operand), Writer);
        end;
      end;
    finally
      PathList.Free;
    end;
  end;

  procedure WriteAllFields(Writer: TInstantIQLWriter;
    const AContext: TInstantTranslationContext);
  var
    LMapIndex, LAttrIndex: Integer;
    LAttrMeta: TInstantAttributeMetadata;
    LTablePath, LFieldName: string;
  begin
    for LMapIndex := 0 to AContext.ObjectClassMetadata.StorageMaps.Count - 1 do
    begin
      for LAttrIndex := 0 to AContext.ObjectClassMetadata.StorageMaps[LMapIndex].Count - 1 do
      begin
        LAttrMeta := AContext.ObjectClassMetadata.StorageMaps[LMapIndex][LAttrIndex];
        if ((LAttrMeta.AttributeType = atPart) and (LAttrMeta.StorageKind = skExternal))
          or (LAttrMeta.AttributeType = atReference) then
        begin
          // External part and reference attribute are treated akin:
          // select Class and Id fields.
          if Assigned(AContext.PathToTarget(LAttrMeta.Name, LTablePath, LFieldName)) then
            Writer.WriteString(Format(', %s, %s', [
              AContext.Qualify(LTablePath, LFieldName + InstantClassFieldName),
              AContext.Qualify(LTablePath, LFieldName + InstantIdFieldName)]));
        end
        else if (LAttrMeta.AttributeType in [atParts, atReferences])
          and (LAttrMeta.StorageKind = skExternal) then
          // No fields needed for external containers.
        else
          // Select all other fields.
          Writer.WriteString(Format(', %s', [AContext.QualifyPath(LAttrMeta.Name)]));
      end;
    end;
  end;

var
  ClassQual, IdQual, PathText: string;
  LContext: TInstantTranslationContext;
  LSubQuery: TInstantIQLSubquery;
  LTablePath, LDummyFieldName: string;
begin
  Result := Assigned(Specifier) and Assigned(Writer);
  if Result then
  begin
    LContext := Context;
    if (not IsPrimary(Specifier)) and Assigned(Specifier.Owner) and (Specifier.Owner is TInstantIQLSubquery) then
    begin
      LSubQuery := TInstantIQLSubQuery(Specifier.Owner);
      LContext := Context.GetSubqueryContext(LSubQuery);
    end;

    if Specifier.Operand is TInstantIQLPath then
    begin
      // This branch handles SELECT * FROM
      PathText := TInstantIQLPath(Specifier.Operand).Text;
      ClassQual := LContext.QualifyPath(ConcatPath(PathText, InstantClassFieldName));
      IdQual := LContext.QualifyPath(ConcatPath(PathText, InstantIdFieldName));
    end else
    begin
      // This branch handles SELECT <attribute> FROM
      ClassQual := LContext.QualifyPath(InstantClassFieldName);
      IdQual := LContext.QualifyPath(InstantIdFieldName);
    end;
    Writer.WriteString(Format('%s AS %s, %s AS %s', [ClassQual,
      InstantClassFieldName, IdQual, InstantIdFieldName]));

    // Mind that LContext.ActualBurstLoadMode might be different than
    // Self.RequestedBurstLoadMode.
    if IsBurstLoadMode(LContext.ActualLoadMode) then
    begin
      // Use the Id just to get the table path needed to add the updatecount
      // field. We could use anything we know is in the main table.
      LContext.PathToTarget(InstantIdFieldName, LTablePath, LDummyFieldName);
      Writer.WriteString(Format(', %s', [LContext.Qualify(LTablePath, InstantUpdateCountFieldName)]));
      WriteAllFields(Writer, LContext);
    end
    else if IncludeOrderFields then
      WriteOrderFields(Writer);
  end;
end;

function TInstantRelationalTranslator.TranslateSubqueryFunction(
  ASubqueryFunction: TInstantIQLSubqueryFunction;
  Writer: TInstantIQLWriter): Boolean;
var
  LContext: TInstantTranslationContext;
  LSubQuery: TInstantIQLSubquery;
begin
  TranslateSubqueryFunctionName(ASubqueryFunction.FunctionName, Writer);
  Writer.WriteString(ASubqueryFunction.FunctionName + '(');

  LContext := Context;
  if InSubquery(ASubqueryFunction, LSubQuery) then
    LContext := Context.GetSubqueryContext(LSubQuery);

  LContext.CreateChildContext(ASubqueryFunction.Subquery);
  ASubqueryFunction.Subquery.Write(Writer);
  Writer.WriteChar(')');
  Result := True;
end;

function TInstantRelationalTranslator.TranslateSubqueryFunctionName(
  const ASubqueryFunctionName: string; Writer: TInstantIQLWriter): Boolean;
begin
  Result := False;
end;

destructor TInstantNavigationalQuery.Destroy;
begin
  DestroyObjectRowList;
  inherited;
end;

{ TInstantNavigationalQuery }

function TInstantNavigationalQuery.CreateObject(Row: Integer): TObject;
var
  ClassNameField, ObjectNameField: TField;
  AClass: TInstantObjectClass;

  function CreateObjectFromDataSet(AClass: TClass; DataSet: TDataSet): TObject;
  var
    I: Integer;
    FieldName: string;
  begin
    if AClass = nil then
      raise Exception.Create(SUnassignedClass)
    else if AClass.InheritsFrom(TInstantObject) then
      Result := TInstantObjectClass(AClass).Create
    else
      Result := AClass.Create;
    for I := 0 to Pred(DataSet.FieldCount) do
    begin
      FieldName := StringReplace(
        DataSet.Fields[I].FieldName, '_', '.', [rfReplaceAll]);
      InstantSetProperty(Result, FieldName, DataSet.Fields[I].Value);
    end;
  end;

begin
  RowNumber := Row;
  ObjectNameField := DataSet.FindField(InstantIdFieldName);
  if Assigned(ObjectNameField) and
    ObjectClass.InheritsFrom(TInstantObject) then
  begin
    ClassNameField := DataSet.FindField(InstantClassFieldName);
    if Assigned(ClassNameField) then
      AClass := InstantGetClass(ClassNameField.AsString)
    else
      AClass := TInstantObjectClass(ObjectClass);
    if Assigned(AClass) then
      Result := AClass.Retrieve(ObjectNameField.AsString, False, False,
        Connector)
    else
      Result := nil;
  end else
    Result := CreateObjectFromDataSet(ObjectClass, DataSet);
end;

procedure TInstantNavigationalQuery.DestroyObjectRowList;
var
  I: Integer;
  ObjectRow: PObjectRow;
begin
  if not Assigned(FObjectRowList) then
    Exit;
  for I := 0 to Pred(FObjectRowList.Count) do
  begin
    ObjectRow := FObjectRowList[I];
    FreeAndNil(ObjectRow.Instance);
    Dispose(ObjectRow);
  end;
  FreeAndNil(FObjectRowList);
end;

function TInstantNavigationalQuery.GetActive: Boolean;
begin
  Result := DataSet.Active;
end;

function TInstantNavigationalQuery.GetDataSet: TDataSet;
begin
  Result := nil;
end;

function TInstantNavigationalQuery.GetObjectRowCount: Integer;
begin
  Result := ObjectRowList.Count;
end;

function TInstantNavigationalQuery.GetObjectRowList: TList;
begin
  if not Assigned(FObjectRowList) then
  begin
    FObjectRowList := TList.Create;
    FObjectRowList.Count := RowCount;
    InitObjectRows(FObjectRowList, 0, Pred(FObjectRowList.Count));
  end;
  Result := FObjectRowList;
end;

function TInstantNavigationalQuery.GetObjectRows(Index: Integer): PObjectRow;
begin
  Result := ObjectRowList[Index];
end;

function TInstantNavigationalQuery.GetRowCount: Integer;
begin
  if Assigned(DataSet) then
    Result := DataSet.RecordCount
  else
    Result := 0;
end;

function TInstantNavigationalQuery.GetRowNumber: Integer;
begin
  Result := DataSet.RecNo;
end;

procedure TInstantNavigationalQuery.InitObjectRows(List: TList; FromIndex,
  ToIndex: Integer);
var
  I: Integer;
  ObjectRow: PObjectRow;
begin
  for I := FromIndex to ToIndex do
  begin
    ObjectRow := List[I];
    if not Assigned(ObjectRow) then
    begin
      New(ObjectRow);
      List[I] := ObjectRow;
    end;
    ObjectRow.Row := Succ(I);
    ObjectRow.Instance := nil;
  end;
end;

function TInstantNavigationalQuery.InternalAddObject(AObject: TObject): Integer;
var
  ObjectRow: PObjectRow;
begin
  New(ObjectRow);
  try
    ObjectRow.Row := -1;
    ObjectRow.Instance := AObject;
    if AObject is TInstantObject then
      TInstantObject(AObject).AddRef;
    Result := ObjectRowList.Add(ObjectRow);
  except
    Dispose(ObjectRow);
    raise;
  end;
end;

procedure TInstantNavigationalQuery.InternalClose;
begin
  inherited;
  if Assigned(DataSet) then
    DataSet.Close;
  DestroyObjectRowList;
end;

procedure TInstantNavigationalQuery.InternalGetInstantObjectRefs(List:
    TInstantObjectReferenceList);
var
  I: Integer;
begin
  for I := 0 to Pred(ObjectRowCount) do
    if ObjectFetched(I) and (ObjectRows[I]^.Instance is TInstantObject) then
      List.Add(TInstantObject(ObjectRows[I]^.Instance));
end;

function TInstantNavigationalQuery.InternalGetObjectCount: Integer;
begin
  if DataSet.Active then
    Result := ObjectRowList.Count
  else
    Result := 0;
end;

function TInstantNavigationalQuery.InternalGetObjects(Index: Integer): TObject;
var
  ObjectRow: PObjectRow;
begin
  ObjectRow := ObjectRows[Index];
  if not Assigned(ObjectRow.Instance) then
    ObjectRow.Instance := CreateObject(ObjectRow.Row);
  Result := ObjectRow.Instance;
end;

function TInstantNavigationalQuery.InternalIndexOfObject(
  AObject: TObject): Integer;
begin
  for Result := 0 to Pred(ObjectRowCount) do
    if ObjectRows[Result].Instance = AObject then
      Exit;
  if AObject is TInstantObject then
    Result := Pred(RecNoOfObject(TInstantObject(AObject)))
  else
    Result := -1;
end;

procedure TInstantNavigationalQuery.InternalInsertObject(Index: Integer;
  AObject: TObject);
var
  ObjectRow: PObjectRow;
begin
  New(ObjectRow);
  try
    ObjectRow.Row := -1;
    ObjectRow.Instance := AObject;
    if AObject is TInstantObject then
      TInstantObject(AObject).AddRef;
    ObjectRowList.Insert(Index, ObjectRow);
  except
    Dispose(ObjectRow);
    raise;
  end;
end;

procedure TInstantNavigationalQuery.InternalOpen;
begin
  inherited;
  if Assigned(DataSet) then
    DataSet.Open;
end;

procedure TInstantNavigationalQuery.InternalRefreshObjects;
begin
  if not DataSet.Active then
    Exit;

  inherited;
end;

procedure TInstantNavigationalQuery.InternalReleaseObject(AObject: TObject);
var
  I: Integer;
  ObjectRow: PObjectRow;
begin
  for I := 0 to Pred(ObjectRowCount) do
  begin
    ObjectRow := ObjectRows[I];
    if ObjectRow.Instance = AObject then
    begin
      AObject.Free;
      ObjectRow.Instance := nil;
      Exit;
    end;
  end;
end;

function TInstantNavigationalQuery.InternalRemoveObject(
  AObject: TObject): Integer;
var
  ObjectRow: PObjectRow;
begin
  Result := IndexOfObject(AObject);
  if Result <> -1 then
  begin
    ObjectRow := ObjectRows[Result];
    ObjectRowList.Delete(Result);
    FreeAndNil(ObjectRow.Instance);
    Dispose(ObjectRow);
  end;
end;

function TInstantNavigationalQuery.IsSequenced: Boolean;
begin
  Result := True;
end;

function TInstantNavigationalQuery.ObjectFetched(Index: Integer): Boolean;
begin
  Result := Assigned(ObjectRows[Index].Instance);
end;

function TInstantNavigationalQuery.RecNoOfObject(
  AObject: TInstantObject): Integer;
var
  ClassField, IdField: TField;
begin
  if DataSet.IsSequenced then
  begin
    if DataSet.Locate(InstantClassFieldName + ';' + InstantIdFieldName,
      VarArrayOf([AObject.ClassName, AObject.Id]), []) then
    begin
      Result := Pred(DataSet.RecNo);
      Exit;
    end;
  end else
  begin
    ClassField := DataSet.FieldByName(InstantClassFieldName);
    IdField := DataSet.FieldByName(InstantIdFieldName);
    if Assigned(ClassField) and Assigned(IdField) then
    begin
      DataSet.First;
      Result := 1;
      while not DataSet.Eof do
      begin
        if (ClassField.AsString = AObject.ClassName) and
          (IdField.AsString = AObject.Id) then
          Exit;
        DataSet.Next;
        Inc(Result);
      end;
    end;
  end;
  Result := 0;
end;

procedure TInstantNavigationalQuery.SetRowNumber(Value: Integer);
begin
  if IsSequenced then
    DataSet.RecNo := Value
  else begin
    DataSet.First;
    while (not Dataset.Eof) and (Value > 1) do
    begin
      DataSet.Next;
      Dec(Value);
    end;
  end;
end;

{ TInstantSQLQuery }

function TInstantSQLQuery.AcquireDataSet(const AStatement: string;
  AParams: TParams): TDataSet;
begin
  Result := (Connector.Broker as TInstantSQLBroker).AcquireDataSet(AStatement,
    AParams);
end;

destructor TInstantSQLQuery.Destroy;
begin
  DestroyObjectReferenceList;
  ReleaseDataSet;
  FParamsObject.Free;
  inherited;
end;

procedure TInstantSQLQuery.DestroyObjectReferenceList;
begin
  FreeAndNil(FObjectReferenceList);
end;

function TInstantSQLQuery.GetActive: Boolean;
begin
  Result := Assigned(FObjectReferenceList);
end;

function TInstantSQLQuery.GetObjectReferenceCount: Integer;
begin
  Result := ObjectReferenceList.Count;
end;

function TInstantSQLQuery.GetObjectReferenceList: TInstantObjectReferenceList;
begin
  if not Assigned(FObjectReferenceList) then
    FObjectReferenceList :=
        TInstantObjectReferenceList.Create(True, Connector);
  Result := FObjectReferenceList;
end;

function TInstantSQLQuery.GetParams: TParams;
begin
  Result := ParamsObject;
end;

function TInstantSQLQuery.GetParamsObject: TParams;
begin
  if not Assigned(FParamsObject) then
    FParamsObject := TParams.Create;
  Result := FParamsObject;
end;

function TInstantSQLQuery.GetStatement: string;
begin
  Result := FStatement;
end;

procedure TInstantSQLQuery.InitObjectReferences;
var
  LObjRef: TInstantObjectReference;
  LClassField, LIdField: TField;
begin
  Assert(Assigned(Connector));

  if Assigned(FDataSet) then
  begin
    try
      FDataSet.DisableControls;
      try
        LClassField := FDataSet.FieldByName(InstantClassFieldName);
        LIdField := FDataSet.FieldByName(InstantIdFieldName);
        while not FDataSet.Eof do
        begin
          LObjRef := ObjectReferenceList.Add;
          try
            if IsBurstLoadMode(ActualLoadMode) then
              LObjRef.ReferenceObject(LClassField.AsString, LIdField.AsString,
                TInstantDataSetObjectData.CreateAndInit(FDataSet))
            else
              LObjRef.ReferenceObject(LClassField.AsString, LIdField.AsString);
            if ActualLoadMode = lmFullBurst then
              LObjRef.RetrieveObjectFromObjectData;
          except
            LObjRef.Free;
            raise;
          end;
          if (MaxCount > 0) and (ObjectReferenceList.Count = MaxCount) then
            Break;
          FDataSet.Next;
        end;
      finally
        FDataSet.EnableControls;
      end;
    finally
      if ActualLoadMode = lmFullBurst then
        ReleaseDataSet;
    end;
  end;
end;

function TInstantSQLQuery.InternalAddObject(AObject: TObject): Integer;
begin
  Result := ObjectReferenceList.Add(AObject as TInstantObject);
end;

procedure TInstantSQLQuery.InternalClose;
begin
  DestroyObjectReferenceList;
  ReleaseDataSet;
  inherited;
end;

procedure TInstantSQLQuery.InternalGetInstantObjectRefs(List:
    TInstantObjectReferenceList);
var
  I: Integer;
begin
  for I := 0 to Pred(ObjectReferenceCount) do
    if ObjectReferenceList.RefItems[I].HasInstance then
      List.Add(ObjectReferenceList[I]);
end;

function TInstantSQLQuery.InternalGetObjectCount: Integer;
begin
  Result := ObjectReferenceCount;
end;

function TInstantSQLQuery.InternalGetObjects(Index: Integer): TObject;
begin
  Result := ObjectReferenceList[Index];
end;

function TInstantSQLQuery.InternalIndexOfObject(AObject: TObject): Integer;
begin
  if AObject is TInstantObject then
    Result := ObjectReferenceList.IndexOf(TInstantObject(AObject))
  else
    Result := -1;
end;

procedure TInstantSQLQuery.InternalInsertObject(Index: Integer;
  AObject: TObject);
begin
  ObjectReferenceList.Insert(Index, AObject as TInstantObject);
end;

procedure TInstantSQLQuery.InternalOpen;
begin
  inherited;
  ReleaseDataSet;
  FDataSet := AcquireDataSet(Statement, ParamsObject);
  if Assigned(FDataSet) then
  try
    FDataSet.FreeNotification(Self);
    if not FDataSet.Active then
      FDataSet.Open;
    InitObjectReferences;
  except
    ReleaseDataSet;
    raise;
  end;
end;

procedure TInstantSQLQuery.InternalReleaseObject(AObject: TObject);
var
  Index: Integer;
begin
  Index := IndexOfObject(AObject);
  if Index <> -1 then
    ObjectReferenceList.RefItems[Index].DestroyInstance;
end;

function TInstantSQLQuery.InternalRemoveObject(AObject: TObject): Integer;
begin
  Result := ObjectReferenceList.Remove(AObject as TInstantObject);
end;

procedure TInstantSQLQuery.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDataSet) then
    FDataSet := nil;
end;

function TInstantSQLQuery.ObjectFetched(Index: Integer): Boolean;
begin
  Result := ObjectReferenceList.RefItems[Index].HasInstance;
end;

procedure TInstantSQLQuery.ReleaseDataSet;
begin
  if Assigned(FDataSet) and Assigned(Connector) and Assigned(Connector.Broker) then
  begin
    (Connector.Broker as TInstantSQLBroker).ReleaseDataSet(FDataSet);
    FDataSet := nil;
  end;
end;

procedure TInstantSQLQuery.SetParams(Value: TParams);
begin
  ParamsObject.Assign(Value);
end;

procedure TInstantSQLQuery.SetStatement(const Value: string);
begin
  FStatement := Value;
end;

{ TInstantConnectionBasedConnectionDef }

constructor TInstantConnectionBasedConnectionDef.Create(
  Collection: TCollection);
begin
  inherited;
  FLoginPrompt := True;
end;

procedure TInstantConnectionBasedConnectionDef.InitConnector(Connector: TInstantConnector);
var
  Connection: TCustomConnection;
begin
  inherited;
  Connection := CreateConnection(Connector);
  try
    (Connector as TInstantConnectionBasedConnector).Connection := Connection;
    (Connector as TInstantConnectionBasedConnector).LoginPrompt := LoginPrompt;
  except
    Connection.Free;
    raise;
  end;
end;

{ TInstantTranslationContext }

function TInstantTranslationContext.AddChildContext(const AContext: TInstantTranslationContext): Integer;
begin
  Result := FChildContexts.Add(AContext);
end;

function TInstantTranslationContext.AddCriteria(
  const Criteria: string): Integer;
begin
  if IndexOfCriteria(Criteria) = -1 then
    Result := CriteriaList.Add(Criteria)
  else
    Result := -1;
end;

procedure TInstantTranslationContext.AddJoin(const FromPath, FromField, ToPath,
  ToField: string);
begin
  AddCriteria(Format('%s = %s', [Qualify(FromPath, FromField),
    Qualify(ToPath, ToField)]));
end;

function TInstantTranslationContext.AddTablePath(
  const TablePath: string): Integer;
begin
  if IndexOfTablePath(TablePath) = -1 then
    Result := TablePathList.Add(TablePath)
  else
    Result := -1;
end;

procedure TInstantTranslationContext.AfterConstruction;
begin
  inherited;
  FChildContexts := TObjectList.Create(True);
end;

procedure TInstantTranslationContext.Clear;
begin
  FreeAndNil(FCriteriaList);
  FreeAndNil(FTablePathList);
end;

procedure TInstantTranslationContext.CollectPaths(AObject: TInstantIQLObject;
  APathList: TList);
begin
  CollectObjects(AObject, TInstantIQLPath, APathList, [TInstantIQLSubquery]);
end;

constructor TInstantTranslationContext.Create(
  const AStatement: TInstantIQLObject; const AQuote: Char;
  const ADelimiters: string; const AIdDataType: TInstantDataType;
  const ARequestedLoadMode: TInstantLoadMode;
  const AParentContext: TInstantTranslationContext = nil);
begin
  inherited Create;
  FParentContext := AParentContext;

  if Assigned(FParentContext) then
    FParentContext.AddChildContext(Self);

  FStatement := AStatement;
  FQuote := AQuote;
  FDelimiters := ADelimiters;
  FIdDataType := AIdDataType;
  FRequestedLoadMode := ARequestedLoadMode;

  Initialize;
end;

function TInstantTranslationContext.CreateChildContext(
  const AStatement: TInstantIQLObject): TInstantTranslationContext;
begin
  // Child contexts (such as subqueries) don't translate queries for
  // burst load modes, for the time being.
  // That's because subqueries now are only used in the EXISTS() function,
  // and for this case there's nothing to be gained (and a performance
  // penalty as well) in constructing a burst load mode enabled subquery.
  // This decision might be revisited in the future if child contexts
  // are used for other things.
  Result := TInstantTranslationContext.Create(AStatement, Quote, Delimiters,
    IdDataType, lmKeysFirst, Self);
end;

destructor TInstantTranslationContext.Destroy;
begin
  FreeAndNil(FTablePathList);
  FreeAndNil(FCriteriaList);
  FreeAndNil(FChildContexts);
  inherited;
end;

function TInstantTranslationContext.FindAttributeMetadata(
  const PathText: string): TInstantAttributeMetadata;
var
  I: Integer;
  AClassMetadata: TInstantClassMetadata;
  List: TStringList;
  AttribName: string;
begin
  List := TStringList.Create;
  try
    AClassMetadata := ObjectClassMetadata;
    Result := nil;
    InstantStrToList(PathText, List, [InstantDot]);
    for I := 0 to Pred(List.Count) do
    begin
      AttribName := List[I];
      Result := AClassMetadata.MemberMap.Find(AttribName);
      if not Assigned(Result) then
        raise EInstantError.CreateFmt(SAttributeNotFound,
          [AttribName, AClassMetadata.Name]);
      if Result.Category = acElement then
        AClassMetadata := Result.ObjectClassMetadata;
    end;
  finally
    List.Free;
  end;
end;

function TInstantTranslationContext.GetChildContext(
  const AIndex: Integer): TInstantTranslationContext;
begin
  Result := TInstantTranslationContext(FChildContexts[AIndex]);
end;


function TInstantTranslationContext.GetChildContextCount: Integer;
begin
  Result := FChildContexts.Count;
end;

function TInstantTranslationContext.GetChildContextIndex: Integer;
begin
  if not HasParentContext then
    Result := -1
  else
    Result := ParentContext.IndexOfChildContext(Self);
end;

function TInstantTranslationContext.GetChildContextLevel: Integer;
begin
  if not HasParentContext then
    Result := -1
  else
    Result := 1 + ParentContext.GetChildContextLevel;
end;

function TInstantTranslationContext.GetClassTablePath: string;
begin
  Result := TablePaths[0];
end;

function TInstantTranslationContext.GetCriteriaCount: Integer;
begin
  Result := CriteriaList.Count;
end;

function TInstantTranslationContext.GetCriteriaList: TStringList;
begin
  if not Assigned(FCriteriaList) then
    FCriteriaList := TStringList.Create;
  Result := FCriteriaList;
end;

function TInstantTranslationContext.GetCriterias(Index: Integer): string;
begin
  Result := CriteriaList.Strings[Index];
end;

function TInstantTranslationContext.GetObjectClassMetadata: TInstantClassMetadata;
begin
{  if not Assigned(FObjectClassMetadata) then
    FObjectClassMetadata := InstantFindClassMetadata(FObjectClassName);}

  Result := FObjectClassMetadata;
end;

function TInstantTranslationContext.GetSubqueryContext(
  const ASubQuery: TInstantIQLSubquery): TInstantTranslationContext;
var
  LChildIndex: Integer;
  LChildContext: TInstantTranslationContext;
begin
  Result := nil;
  for LChildIndex := 0 to FChildContexts.Count - 1 do
  begin
    LChildContext := GetChildContext(LChildIndex);
    if LChildContext.Statement = ASubQuery then
    begin
      Result := LChildContext;
      Exit;
    end
    else
      Result := LChildContext.GetSubqueryContext(ASubQuery);
  end;
end;

function TInstantTranslationContext.GetTableAlias: string;
begin
  Result := TablePathToAlias(TableName);
end;

function TInstantTranslationContext.GetTableName: string;
begin
  Result := ObjectClassMetadata.TableName;
end;

function TInstantTranslationContext.GetTablePathAlias(
  const ATablePath: string): string;
begin
  Result := TablePathToAlias(ATablePath);
end;

function TInstantTranslationContext.GetTablePathAliases(Index: Integer): string;
begin
  if Index < TablePathList.Count then
  begin
    if not HasParentContext then
      Result := Format('t%d', [Succ(Index)])
    else
      Result := Format('l%ds%dt%d', [Succ(ChildContextLevel), Succ(ChildContextIndex), Succ(Index)]);
  end
  else
    Result := '';
end;

function TInstantTranslationContext.GetTablePathCount: Integer;
begin
  Result := TablePathList.Count;
end;

function TInstantTranslationContext.GetTablePathList: TStringList;
begin
  if not Assigned(FTablePathList) then
    FTablePathList := TStringList.Create;
  Result := FTablePathList;
end;

function TInstantTranslationContext.GetTablePaths(Index: Integer): string;
begin
  Result := TablePathList[Index];
end;

function TInstantTranslationContext.HasParentContext: Boolean;
begin
  Result := Assigned(FParentContext);
end;

function TInstantTranslationContext.IndexOfChildContext(
  const AChildContext: TInstantTranslationContext): Integer;
begin
  Result := FChildContexts.IndexOf(AChildContext);
end;

function TInstantTranslationContext.IndexOfCriteria(
  const Criteria: string): Integer;
begin
  Result := CriteriaList.IndexOf(Criteria);
end;

function TInstantTranslationContext.IndexOfTablePath(
  const TablePath: string): Integer;
begin
  Result := TablePathList.IndexOf(TablePath);
end;

procedure TInstantTranslationContext.Initialize;

  procedure InitClassTablePath(List: TList);

    function FindAttributePath: TInstantIQLPath;
    var
      I: Integer;
    begin
      for I := 0 to Pred(List.Count) do
      begin
        Result := List[I];
        if not IsRootAttribute(Result.Text) then
          Exit;
      end;
      Result := nil;
    end;

  var
    LTablePath: string;
    LPath: TInstantIQLPath;
    LClassMeta: TInstantClassMetadata;
  begin
    if ClassRef.Any then
      LTablePath := ObjectClassMetadata.TableName
    else
    begin
      LPath := FindAttributePath;
      if Assigned(LPath) then
        LTablePath := PathToTablePath(LPath.Attributes[0])
      else
        LTablePath := ObjectClassMetadata.TableName;
    end;
    AddTablePath(LTablePath);
    if IsBurstLoadMode(ActualLoadMode) then
    begin
      // Standard mode only adds the main table when needed, and not always.
      // A possible optimization would be to add it only if it does actually
      // have attributes we select. For now let's add it by default as it
      // covers almost all cases.
      AddTablePath(TableName);
      LClassMeta := ObjectClassMetadata.Parent;
      while Assigned(LClassMeta) do
      begin
        if LClassMeta.IsStored then
          AddTablePath(LClassMeta.TableName);
        LClassMeta := LClassMeta.Parent;
      end;
    end;
  end;

  procedure InitCommandCriterias;
  var
    LClassMeta: TInstantClassMetadata;
    LTableName: string;
  begin
    if not ClassRef.Any then
      AddCriteria(Format('%s = %s',
        [Qualify(ClassTablePath, InstantClassFieldName),
        QuoteString(ClassRef.ObjectClassName)]));
    if Specifier.IsPath then
    begin
      if IdDataType in [dtString, dtMemo, dtBlob] then
        AddCriteria(Format('%s <> %s%s',
          [QualifyPath(ConcatPath(Specifier.Text, InstantIdFieldName)),
            Quote, Quote]))
      else
        AddCriteria(Format('%s <> 0',
          [QualifyPath(ConcatPath(Specifier.Text, InstantIdFieldName))]));
    end;
    if IsBurstLoadMode(ActualLoadMode) then
    begin
      LClassMeta := ObjectClassMetadata.Parent;
      while Assigned(LClassMeta) do
      begin
        if LClassMeta.IsStored then
        begin
          LTableName := LClassMeta.TableName;
          if (LTableName <> TableName) and LClassMeta.IsStored then
          begin
            AddJoin(TableName, InstantClassFieldName, LTableName, InstantClassFieldName);
            AddJoin(TableName, InstantIdFieldName, LTableName, InstantIdFieldName);
          end;
        end;
        LClassMeta := LClassMeta.Parent;
      end;
    end;
  end;

var
  I: Integer;
  PathList: TList;
begin
  if (FStatement is TInstantIQLCommand) then
  begin
    ClassRef := TInstantIQLCommand(FStatement).ClassRef;
    Specifier := TInstantIQLCommand(FStatement).Specifier;
  end
  else if (FStatement is TInstantIQLSubquery) then
  begin
    ClassRef := TInstantIQLSubquery(FStatement).ClassRef;
    Specifier := TInstantIQLSubquery(FStatement).Specifier;
  end;

  { TODO : supporting ANY in burst load mode would mean collect
    all descendant classes in the model and left join to all tables,
    which is complicated to do and would probably be inefficient as well.
    A better approach would be to perform N queries, one for each
    concrete class, and combine the resulting sets. This would require
    some big refactoring and is left for the future. For now, we don't
    support burst load mode for ANY statements. }
  if Classref.Any then
    FActualLoadMode := lmKeysFirst
  else
    FActualLoadMode := FRequestedLoadMode;

  PathList := TList.Create;
  try
    CollectPaths(FStatement, PathList);
    InitClassTablePath(PathList);
    for I := 0 to Pred(PathList.Count) do
    begin
      MakeTablePaths(PathList[I]);
      MakeJoins(PathList[I]);
    end;
    InitCommandCriterias;
  finally
    PathList.Free;
  end;
end;

procedure TInstantTranslationContext.MakeJoins(Path: TInstantIQLPath);

  procedure MakePathJoins(Path: TInstantIQLPath);
  var
    I: Integer;
    PathText, FromPath, ToPath, FromField, ToField: string;
  begin
    if Path.AttributeCount > 1 then
    begin
      PathToTarget(Path.SubPath[0], FromPath, FromField);
      for I := 1 to Pred(Path.AttributeCount) do
      begin
        PathText := Path.SubPath[I];
        if not IsRootAttribute(ExtractTarget(PathText)) then
        begin
          PathToTarget(PathText, ToPath, ToField);
          AddJoin(FromPath, FromField + InstantClassFieldName, ToPath,
            InstantClassFieldName);
          AddJoin(FromPath, FromField + InstantIdFieldName, ToPath,
            InstantIdFieldName);
          FromPath := ToPath;
          FromField := ToField;
        end;
      end;
    end;
  end;

  procedure MakeClassJoin(Path: TInstantIQLPath);
  var
    TablePath: string;
  begin
    if Path.HasAttributes then
    begin
      TablePath := PathToTablePath(Path.SubPath[0]);
      if TablePath <> ClassTablePath then
      begin
        AddJoin(ClassTablePath, InstantClassFieldName,
          TablePath, InstantClassFieldName);
        AddJoin(ClassTablePath, InstantIdFieldName,
          TablePath, InstantIdFieldName);
      end;
    end;
  end;

begin
  if not Assigned(Path) then
    Exit;
  MakeClassJoin(Path);
  MakePathJoins(Path);
end;

procedure TInstantTranslationContext.MakeTablePaths(Path: TInstantIQLPath);
var
  I: Integer;
  TablePath: string;
begin
  if not Assigned(Path) or IsRootAttribute(Path.Text) then
    Exit;

  for I := 0 to Pred(Path.AttributeCount) do
  begin
    TablePath := PathToTablePath(Path.SubPath[I]);
    AddTablePath(TablePath);
  end;
end;

function TInstantTranslationContext.PathToTablePath(
  const PathText: string): string;
var
  FieldName: string;
begin
  PathToTarget(PathText, Result, FieldName);
end;

function TInstantTranslationContext.RootAttribToFieldName(const AttribName: string): string;
begin
  if SameText(AttribName, InstantClassFieldName) then
    Result := InstantClassFieldName
  else if SameText(AttribName, InstantIdFieldName) then
    Result := InstantIdFieldName;
end;

function TInstantTranslationContext.PathToTarget(const PathText: string;
  out TablePath, FieldName: string;
  const AClassMetadata: TInstantClassMetadata): TInstantAttributeMetadata;
var
  I: Integer;
  AttribList: TStringList;
  ClassMeta: TInstantClassMetadata;
  AttribName: string;
  Map: TInstantAttributeMap;
begin
  Result := nil;
  if IsRootAttribute(PathText) then
  begin
    TablePath := ClassTablePath;
    FieldName := RootAttribToFieldName(PathText);
  end else
  begin
    if AClassMetadata = nil then
      ClassMeta := ObjectClassMetadata
    else
      ClassMeta := AClassMetadata;
    AttribList := TStringList.Create;
    try
      InstantStrToList(PathText, AttribList, [InstantDot]);
      for I := 0 to Pred(AttribList.Count) do
      begin
        AttribName := AttribList[I];
        if IsRootAttribute(AttribName) then
        begin
          if Assigned(Result) and
            not Result.IsAttributeClass(TInstantReference) then
            raise EInstantError.CreateFmt(SUnableToQueryAttribute,
              [Result.ClassMetadataName, Result.Name]);
          FieldName := FieldName + RootAttribToFieldName(AttribName);
        end else
        begin
          Result := ClassMeta.MemberMap.Find(AttribName);
          if Assigned(Result) then
          begin
            while Assigned(ClassMeta) and not ClassMeta.IsStored do
              ClassMeta := ClassMeta.Parent;
            if Assigned(ClassMeta) then
            begin
              Map := ClassMeta.StorageMaps.FindMap(AttribName);
              if Assigned(Map) then
              begin
                if I > 0 then
                  TablePath := TablePath + InstantDot;
                TablePath := TablePath + Map.Name;
                FieldName := Result.FieldName;
                ClassMeta := Result.ObjectClassMetadata;
              end else
                raise EInstantError.CreateFmt(SAttributeNotQueryable,
                  [Result.ClassName, Result.Name, Result.ClassMetadataName]);
            end else
              raise EInstantError.CreateFmt(SClassNotQueryable,
                [Result.ClassMetadataName]);
          end else
            raise EInstantError.CreateFmt(SAttributeNotFound,
              [AttribName, ClassMeta.Name]);
        end;
      end;
    finally
      AttribList.Free;
    end;
  end;
end;

function TInstantTranslationContext.Qualify(const TablePath,
  FieldName: string): string;
begin
  Result := Format('%s.%s', [TablePathToAlias(TablePath),
    InstantEmbrace(FieldName, Delimiters)]);
end;

function TInstantTranslationContext.QualifyPath(const PathText: string): string;
var
  TablePath, FieldName: string;
begin
  PathToTarget(PathText, TablePath, FieldName);
  Result := Qualify(TablePath, FieldName);
end;

function TInstantTranslationContext.QuoteString(const Str: string): string;
begin
  Result := InstantQuote(Str, Quote);
end;

procedure TInstantTranslationContext.SetClassRef(
  const Value: TInstantIQLClassRef);
begin
  if FClassRef <> Value then
  begin
    FClassRef := Value;
    ObjectClassName := FClassRef.ObjectClassName;


  end;
end;

procedure TInstantTranslationContext.SetObjectClassName(const Value: string);
begin
  if FObjectClassName <> Value then
  begin
    FObjectClassName := Value;
    FObjectClassMetadata := InstantFindClassMetadata(FObjectClassName);

  end;
end;

procedure TInstantTranslationContext.SetSpecifier(
  const Value: TInstantIQLSpecifier);
begin
  FSpecifier := Value;
end;

function TInstantTranslationContext.TablePathToAlias(
  const TablePath: string): string;
var
  LIndex: Integer;
begin
  LIndex := IndexOfTablePath(TablePath);
  if LIndex < 0 then
    raise EInstantError.CreateFmt(STablePathNotFound, [TablePath]);
  Result := TablePathAliases[LIndex];
end;

function TInstantTranslationContext.WriteCriterias(Writer: TInstantIQLWriter;
  IncludeWhere: Boolean): Boolean;
var
  I: Integer;
begin
  Result := CriteriaCount > 0;
  if Result then
  begin
    if IncludeWhere then
      Writer.WriteString(' WHERE ');
    Writer.WriteChar('(');
    for I := 0 to Pred(CriteriaCount) do
    begin
      if I > 0 then
        WriteAnd(Writer);
      Writer.WriteString(Criterias[I]);
    end;
    Writer.WriteChar(')');
  end;
end;

procedure TInstantTranslationContext.WriteTables(Writer: TInstantIQLWriter);
var
  I: Integer;
begin
  for I := 0 to Pred(TablePathCount) do
  begin
    if I > 0 then
      Writer.WriteString(', ');
    Writer.WriteString(Format('%s %s',[InstantEmbrace(
      ExtractTarget(TablePaths[I]), Delimiters), TablePathAliases[I]]));
  end;
end;

{ TInstantDataSetObjectData }

constructor TInstantDataSetObjectData.CreateAndInit(const ADataSet: TDataSet);
begin
  Assert(Assigned(ADataSet));
  Create(nil);
  ADataSet.FreeNotification(Self);
  FDataSet := ADataSet;
  FRecNo := ADataSet.RecNo;
  FIdField := ADataSet.FieldByName(InstantIdFieldName);
end;

function TInstantDataSetObjectData.Locate(const AObjectId: string): Boolean;
begin
  if not Assigned(FDataSet) or not FDataSet.Active then
    Result := False
  else
  begin
    FDataSet.RecNo := FRecNo;
    Result := FIdField.AsString = AObjectId;
  end;
end;

procedure TInstantDataSetObjectData.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDataSet) then
    FDataSet := nil;
end;

end.
