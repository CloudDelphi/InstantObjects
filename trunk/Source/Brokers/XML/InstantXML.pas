(*
 *   InstantObjects
 *   XML Support
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
 * The Original Code is: Carlo Barazzetta
 *
 * The Initial Developer of the Original Code is: Carlo Barazzetta
 *
 * Contributor(s):
 * Carlo Barazzetta, Adrea Petrelli, Nando Dessena, Marco Cant�,
 * Steven Mitchell
 *
 * ***** END LICENSE BLOCK ***** *)

unit InstantXML;

{$IFDEF LINUX}
{$I '../../InstantDefines.inc'}
{$ELSE}
{$I '..\..\InstantDefines.inc'}
{$ENDIF}

{$IFDEF D6+}
{$WARN SYMBOL_PLATFORM OFF}
{$WARN UNIT_PLATFORM OFF}
{$ENDIF}

interface

uses
  Classes, DB, Contnrs, InstantPersistence, InstantBrokers, InstantCommand,
  InstantMetadata, InstantTypes;

const
  XML_UTF8_HEADER = '<?xml version="1.0" encoding="UTF-8"?>';
  XML_ISO_HEADER = '<?xml version="1.0" encoding="ISO-8859-1"?>';
  XML_EXT = 'xml';
  DOT_XML_EXT = '.' + XML_EXT;
  XML_WILDCARD = '*' + DOT_XML_EXT;
  {$IFNDEF D6+}
  PathDelim = '\';
  {$ENDIF}

type
  TXMLFileFormat = (xffUtf8, xffIso);

  TXMLFilesAccessor = class(TCustomConnection)
  private
    FConnected: Boolean;
    FRootFolder: string;
    FXMLFileFormat: TXMLFileFormat;
    procedure CreateStorageDir(const AStorageName: string);
    function GetRootFolder: string;
    procedure SetRootFolder(const AValue: string);
    function SaveToFileXML_UTF8(AObject: TInstantObject;
      const AFileName: string): Boolean;
    function LoadFromFileXML_UTF8(AObject: TInstantObject; const FileName:
      string): boolean;
    function PlainObjectFileName(const StorageName, ClassName, Id: string):
      string;
    function ObjectUpdateCountFromFileName(const AFileName: string): Integer;
  protected
    procedure DoConnect; override;
    procedure DoDisconnect; override;
    function GetConnected: Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    function ReadInstantObject(AObject: TInstantObject; const StorageName,
      AObjectId: string; out AObjectUpdateCount: Integer): Boolean;
    function WriteInstantObject(AObject: TInstantObject;
      const AStorageName: string; out AObjectUpdateCount: Integer): Boolean;
    function DeleteInstantObject(AObject: TInstantObject;
      const AStorageName: string): Boolean;
    function Locate(const AStorageName, AObjectClassName, AObjectId: string): Boolean;
    function CheckConflict(AObject: TInstantObject;
      const AStorageName, AObjectId: string): Boolean;
    procedure LoadFileList(const AFileList: TStringList;
      const AStorageNames: TStrings);
  published
    property RootFolder: string read GetRootFolder write SetRootFolder;
    property XMLFileFormat: TXMLFileFormat read FXMLFileFormat write
      FXMLFileFormat default xffUtf8;
  end;

  TInstantXMLConnectionDef = class(TInstantConnectionBasedConnectionDef)
  private
    FRootFolder: string;
    FXMLFileFormat: TXMLFileFormat;
  protected
    function CreateConnection(AOwner: TComponent): TCustomConnection; override;
  public
    function Edit: Boolean; override;
    class function ConnectionTypeName: string; override;
    class function ConnectorClass: TInstantConnectorClass; override;
  published
    property RootFolder: string read FRootFolder write FRootFolder;
    property XMLFileFormat: TXMLFileFormat read FXMLFileFormat write
      FXMLFileFormat default xffUtf8;
  end;

  TInstantXMLConnector = class(TInstantConnectionBasedConnector)
  private
    function GetConnection: TXMLFilesAccessor;
    procedure SetConnection(const Value: TXMLFilesAccessor);
    procedure CheckConnection;
  protected
    function CreateBroker: TInstantBroker; override;
    function GetDatabaseName: string; override;
    procedure InternalBuildDatabase(Scheme: TInstantScheme); override;
    procedure InternalCommitTransaction; override;
    function InternalCreateQuery: TInstantQuery; override;
    procedure InternalRollbackTransaction; override;
    procedure InternalStartTransaction; override;
  public
    class function ConnectionDefClass: TInstantConnectionDefClass; override;
    constructor Create(AOwner: TComponent); override;
  published
    property Connection: TXMLFilesAccessor read GetConnection write
      SetConnection;
    property UseTransactions default False;
    property LoginPrompt default False;
  end;

  TInstantXMLResolver = class;

  TInstantXMLBroker = class(TInstantCustomRelationalBroker)
  private
    FResolverList: TObjectList;
    function GetResolverCount: Integer;
    function GetResolverList: TObjectList;
    function GetResolvers(Index: Integer): TInstantXMLResolver;
    property ResolverList: TObjectList read GetResolverList;
    function GetConnector: TInstantXMLConnector;
  protected
    function CreateCatalog(const AScheme: TInstantScheme): TInstantCatalog;
      override;
    function CreateResolver(const StorageName: string): TInstantXMLResolver;
    function EnsureResolver(Map: TInstantAttributeMap): TInstantCustomResolver;
      override;
    function FindResolver(const StorageName: string): TInstantXMLResolver;
    property ResolverCount: Integer read GetResolverCount;
    property Resolvers[Index: Integer]: TInstantXMLResolver read GetResolvers;
  public
    destructor Destroy; override;
    function CreateDBBuildCommand(const CommandType:
      TInstantDBBuildCommandType):
      TInstantDBBuildCommand; override;
    property Connector: TInstantXMLConnector read GetConnector;
  end;

  TInstantXMLResolver = class(TInstantCustomResolver)
  private
    FStorageName: string;
    function GetBroker: TInstantXMLBroker;
    function CheckConflict(AObject: TInstantObject; const AObjectId: string;
      ConflictAction: TInstantConflictAction): Boolean;
  protected
    procedure InternalDisposeMap(AObject: TInstantObject; Map:
      TInstantAttributeMap;
      ConflictAction: TInstantConflictAction; Info: PInstantOperationInfo);
        override;
    procedure InternalRetrieveMap(AObject: TInstantObject; const AObjectId:
      string;
      Map: TInstantAttributeMap; ConflictAction: TInstantConflictAction; Info:
        PInstantOperationInfo); override;
    procedure InternalStoreMap(AObject: TInstantObject; Map:
      TInstantAttributeMap;
      ConflictAction: TInstantConflictAction; Info: PInstantOperationInfo);
        override;
    procedure ResetAttributes(AObject: TInstantObject; Map:
      TInstantAttributeMap);
    function Locate(AObject: TObject; const AObjectId: string): Boolean;
      virtual;
    function ReadInstantObject(AObject: TInstantObject; const AObjectId: string;
      out AObjectUpdateCount: Integer): Boolean;
    function WriteInstantObject(AObject: TInstantObject;
      const AObjectId: string; out AObjectUpdateCount: Integer): Boolean;
  public
    constructor Create(ABroker: TInstantCustomRelationalBroker;
      const AStorageName: string);
    property Broker: TInstantXMLBroker read GetBroker;
    property StorageName: string read FStorageName;
  end;

  TInstantXMLTranslator = class(TInstantRelationalTranslator)
  protected
    function TranslateClassRef(ClassRef: TInstantIQLClassRef; Writer:
      TInstantIQLWriter): Boolean; override;
  end;

  TInstantXMLQuery = class(TInstantCustomRelationalQuery)
  private
    FObjectReferenceList: TObjectList;
    FStatement: string;
    FParamsObject: TParams;
    FStorageNames: TStringList;
    FObjectClassNames: TStringList;
    procedure DestroyObjectReferenceList;
    function GetObjectReferenceCount: Integer;
    function GetObjectReferenceList: TObjectList;
    function GetObjectReferences(Index: Integer): TInstantObjectReference;
    // Creates an object reference for each item in AFileList that represents
    // an object of a class included in FObjectClassNames.
    procedure InitObjectReferences(const AFileList: TStrings);
    function GetParamsObject: TParams;
    function GetConnector: TInstantXMLConnector;
    procedure SetStorageNames(const Value: TStringList);
    procedure SetObjectClassNames(const Value: TStringList);
  protected
    class function TranslatorClass: TInstantRelationalTranslatorClass; override;
    function GetActive: Boolean; override;
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
    property ObjectReferenceCount: Integer read GetObjectReferenceCount;
    property ObjectReferenceList: TObjectList read GetObjectReferenceList;
    property ObjectReferences[Index: Integer]: TInstantObjectReference read
      GetObjectReferences;
    property ParamsObject: TParams read GetParamsObject;
  public
    procedure AfterConstruction; override;
    // List of folders from which files should be loaded in InternalOpen.
    property StorageNames: TStringList read FStorageNames write SetStorageNames;
    // Used to filter by class name the files loaded during InternalOpen.
    property ObjectClassNames: TStringList read FObjectClassNames write SetObjectClassNames;
    destructor Destroy; override;
    property Connector: TInstantXMLConnector read GetConnector;
  end;

  // Base class for all XML database build commands.
  TInstantDBBuildXMLCommand = class(TInstantDBBuildCommand)
  private
    function GetConnector: TInstantXMLConnector;
    function GetBroker: TInstantXMLBroker;
  protected
    // Returns The number of statements that compound this script. The
    // predefined implementation returns 1.
    function GetCommandCount: Integer; virtual;
    // Returns the nth command that is part of this script. Valid values
    // are in the range 0 to Pred(GetCommandCount). The default
    // implementation, which should always be called through inherited at the
    // beginning of the overridden version, just returns '', or raises an
    // exception if Index is not in the allowed range.
    function GetCommand(const Index: Integer): string; virtual;
  public
    property Connector: TInstantXMLConnector read GetConnector;
    property Broker: TInstantXMLBroker read GetBroker;
  end;

  TInstantDBBuildXMLAddTableCommand = class(TInstantDBBuildXMLCommand)
  private
    function GetTableMetadata: TInstantTableMetadata;
  protected
    procedure InternalExecute; override;
  public
    property TableMetadata: TInstantTableMetadata read GetTableMetadata;
  end;

  TInstantDBBuildXMLDropTableCommand = class(TInstantDBBuildXMLCommand)
  private
    function GetTableMetadata: TInstantTableMetadata;
  protected
    procedure InternalExecute; override;
  public
    property TableMetadata: TInstantTableMetadata read GetTableMetadata;
  end;

implementation

uses
  SysUtils, InstantConsts, InstantClasses, TypInfo, InstantXMLCatalog,
  InstantXMLConnectionDefEdit,
{$IFDEF MSWINDOWS}
{$IFNDEF D6+}
  FileCtrl,
{$ENDIF}
  Windows, Controls;
{$ENDIF}
{$IFDEF LINUX}
QControls;
{$ENDIF}

resourcestring
  SCannotCreateDirectory = 'Cannot create directory %s';
  SCommandIndexOutOfBounds = 'Command index out of bounds.';

function GetFileClassName(const FileName: string): string; forward;
function GetFileId(const FileName: string): string; forward;
function GetObjectUpdateCount(const FileName: string): Integer; forward;

{$IFNDEF D6+}
function IncludeTrailingPathDelimiter(const S: string): string;
begin
  Result := IncludeTrailingBackSlash(S);
end;
{$ENDIF}

procedure GlobalLoadFileList(const Path: string; FileList: TStringList);
var
  SearchRec: TSearchRec;
  R: Integer;
  PathWithWildCards: string;
begin
  PathWithWildCards := IncludeTrailingPathDelimiter(Path) + XML_WILDCARD;
  //Find the first file
  R := SysUtils.FindFirst(PathWithWildCards, faAnyFile, SearchRec);
  try
    while R = 0 do // file found!
    begin
      FileList.Append(SearchRec.Name); // Add file to list
      R := SysUtils.FindNext(SearchRec); // Find next file
    end;
  finally
    SysUtils.FindClose(SearchRec);
  end;
end;

function RightPos(const ASubString, AString: string): Integer;
var
  I: Integer;
  SubStringLength: Integer;
begin
  Result := 0;
  SubStringLength := Length(ASubString);
  for I := Length(AString) - Length(ASubString) + 1 downto 1 do
  begin
    if Copy(AString, I, SubStringLength) = ASubString then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function GetFileClassName(const FileName: string): string;
begin
  // File Name: ClassName.Id.UpdateCount.xml
  Result := Copy(FileName, 1, Pos('.', FileName) - 1);
end;

function GetFileId(const FileName: string): string;
var
  P: Integer;
begin
  // File Name: ClassName.Id.UpdateCount.xml
  // Drop ClassName and extension.
  P := Pos('.', FileName);
  Result := Copy(FileName, P + 1, RightPos('.', FileName) - P - 1);
  // Drop UpdateCount.
  Delete(Result, RightPos('.', Result), MaxInt);
end;

function GetObjectUpdateCount(const FileName: string): Integer;
var
  S: string;
  P: Integer;
begin
  // File Name: ClassName.Id.UpdateCount.xml
  // Drop ClassName and extension.
  P := Pos('.', FileName);
  S := Copy(FileName, P + 1, RightPos('.', FileName) - P - 1);
  // Drop Id.
  Delete(S, 1, RightPos('.', S));
  Result := StrToIntDef(S, 0);
end;

{ TInstantXMLConnectionDef }

class function TInstantXMLConnectionDef.ConnectionTypeName: string;
begin
  Result := 'XML';
end;

class function TInstantXMLConnectionDef.ConnectorClass: TInstantConnectorClass;
begin
  Result := TInstantXMLConnector;
end;

function TInstantXMLConnectionDef.CreateConnection(
  AOwner: TComponent): TCustomConnection;
begin
  Result := TXMLFilesAccessor.Create(AOwner);
  TXMLFilesAccessor(Result).RootFolder := RootFolder;
  TXMLFilesAccessor(Result).FXMLFileFormat := XMLFileFormat;
end;

function TInstantXMLConnectionDef.Edit: Boolean;
begin
  with TInstantXMLConnectionDefEditForm.Create(nil) do
  try
    LoadData(Self);
    Result := ShowModal = mrOk;
    if Result then
      SaveData(Self);
  finally
    Free;
  end;
end;

{ TInstantXMLResolver }

function TInstantXMLResolver.CheckConflict(AObject: TInstantObject;
  const AObjectId: string;
  ConflictAction: TInstantConflictAction): Boolean;
begin
  Result := Broker.Connector.Connection.CheckConflict(AObject, FStorageName,
    AObjectId);

  if Result and (ConflictAction = caFail) then
    raise EInstantConflict.CreateFmt(SUpdateConflict,
      [AObject.ClassName, AObjectId]);
end;

constructor TInstantXMLResolver.Create(ABroker: TInstantCustomRelationalBroker;
  const AStorageName: string);
begin
  inherited Create(ABroker);
  FStorageName := AStorageName;
end;

function TInstantXMLResolver.GetBroker: TInstantXMLBroker;
begin
  Result := inherited Broker as TInstantXMLBroker;
end;

procedure TInstantXMLResolver.InternalDisposeMap(AObject: TInstantObject;
  Map: TInstantAttributeMap; ConflictAction: TInstantConflictAction;
  Info: PInstantOperationInfo);
var
  TransError: Exception;
  AInfo: TInstantOperationInfo;
  // ObjFileName : string;
begin
  if not Assigned(Info) then
  begin
    Info := @AInfo;
    Info.Conflict := False;
  end;
  if Locate(AObject, AObject.PersistentId) then
  begin
    // Delete object file
    try
      Broker.Connector.Connection.DeleteInstantObject(AObject, FStorageName);
      Info.Success := True;
      Info.Conflict := not Info.Success;
    except
      on EAbort do
        raise;
      on E: Exception do
      begin
        //        TransError := TranslateError(AObject, E);
        TransError := nil;
        if Assigned(TransError) then
          raise TransError
        else
          raise;
      end;
    end;
  end
  else if Map.IsRootMap and (ConflictAction = caFail) then
    raise EInstantConflict.CreateFmt(SDisposeConflict,
      [AObject.ClassName, AObject.PersistentId])
end;

procedure TInstantXMLResolver.InternalRetrieveMap(AObject: TInstantObject;
  const AObjectId: string; Map: TInstantAttributeMap;
  ConflictAction: TInstantConflictAction; Info: PInstantOperationInfo);
var
  AInfo: TInstantOperationInfo;
  LObjectUpdateCount: Integer;
begin
  if not Assigned(Info) then
  begin
    Info := @AInfo;
    Info.Conflict := False;
  end;
  //Read object from file
  Info.Success := Locate(AObject, AObjectId) and
    ReadInstantObject(AObject, AObjectId, LObjectUpdateCount);
  Info.Conflict := not Info.Success;
  if Info.Success then
  begin
    if Map.IsRootMap then
    begin
      Broker.SetObjectUpdateCount(AObject, LObjectUpdateCount);
    end;
  end
  else
    ResetAttributes(AObject, Map);
end;

procedure TInstantXMLResolver.InternalStoreMap(AObject: TInstantObject;
  Map: TInstantAttributeMap; ConflictAction: TInstantConflictAction;
  Info: PInstantOperationInfo);
var
  NewId: string;
  AInfo: TInstantOperationInfo;
  TransError: Exception;
  version: Integer;
begin
  { Avoid any interference with storage when performing store operation }
  NewId := AObject.Id;

  if not Assigned(Info) then
  begin
    Info := @AInfo;
    Info.Conflict := False;
  end;

  if AObject.IsPersistent then
  begin
    if Locate(AObject, AObject.PersistentId) then
    begin
      if Map.IsRootMap then
        Info.Conflict := CheckConflict(AObject, AObject.Id, ConflictAction);
    end;
  end;
  try
    if (ConflictAction = caIgnore) or not Info.Conflict then
    begin
      Info.Success := WriteInstantObject(AObject, NewId, Version);
      Info.Conflict := not Info.Success;
      if Map.IsRootMap then
        Broker.SetObjectUpdateCount(AObject, version);
    end
    else
      Info.Success := True;
  except
    on E: Exception do
    begin
      if E is EAbort then
        raise
      else
      begin
        //        TransError := TranslateError(AObject, E);
        TransError := nil;
        if Assigned(TransError) then
          raise TransError
        else
          raise;
      end;
    end;
  end;
end;

function TInstantXMLResolver.Locate(AObject: TObject; const AObjectId: string):
  Boolean;
begin
  Result := Broker.Connector.Connection.Locate(
    FStorageName, AObject.ClassName, AObjectId);
end;

function TInstantXMLResolver.ReadInstantObject(AObject: TInstantObject;
  const AObjectId: string; out AObjectUpdateCount: Integer): Boolean;
begin
  Result := Broker.Connector.Connection.ReadInstantObject(AObject, FStorageName,
    AObjectId, AObjectUpdateCount);
end;

procedure TInstantXMLResolver.ResetAttributes(AObject: TInstantObject;
  Map: TInstantAttributeMap);
begin

end;

function TInstantXMLResolver.WriteInstantObject(AObject: TInstantObject;
  const AObjectId: string; out AObjectUpdateCount: Integer): Boolean;
begin
  if AObject.Metadata.TableName = FStorageName then
    Result := Broker.Connector.Connection.WriteInstantObject(AObject,
      FStorageName, AObjectUpdateCount)
  else
  begin
    Result := True;
    AObjectUpdateCount := 1;
  end;
end;

{ TInstantXMLConnector }

procedure TInstantXMLConnector.CheckConnection;
begin
  if not assigned(Connection) then
    raise EPropertyError.Create(SUnassignedConnection);
end;

class function TInstantXMLConnector.ConnectionDefClass:
  TInstantConnectionDefClass;
begin
  Result := TInstantXMLConnectionDef;
end;

constructor TInstantXMLConnector.Create(AOwner: TComponent);
begin
  inherited;
  LoginPrompt := False;
  UseTransactions := False;
end;

function TInstantXMLConnector.CreateBroker: TInstantBroker;
begin
  Result := TInstantXMLBroker.Create(Self);
end;

function TInstantXMLConnector.GetConnection: TXMLFilesAccessor;
begin
  Result := inherited Connection as TXMLFilesAccessor;
end;

function TInstantXMLConnector.GetDatabaseName: string;
begin
  Result := Connection.RootFolder;
end;

procedure TInstantXMLConnector.InternalBuildDatabase(Scheme: TInstantScheme);
begin
  CheckConnection;
  if not DirectoryExists(Connection.RootFolder) and
      not ForceDirectories(Connection.RootFolder) then
    raise EInOutError.CreateFmt(SCannotCreateDirectory,
      [Connection.RootFolder]);
end;

procedure TInstantXMLConnector.InternalCommitTransaction;
begin
  { TODO: Commit transaction for Connection }
end;

function TInstantXMLConnector.InternalCreateQuery: TInstantQuery;
begin
  Result := TInstantXMLQuery.Create(Self);
end;

procedure TInstantXMLConnector.InternalRollbackTransaction;
begin
  { TODO: Roll back transaction for Connection }
end;

procedure TInstantXMLConnector.InternalStartTransaction;
begin
  { TODO: Start transaction for Connection }
end;

procedure TInstantXMLConnector.SetConnection(
  const Value: TXMLFilesAccessor);
begin
  inherited Connection := Value;
end;

{ TInstantXMLBroker }

function TInstantXMLBroker.CreateResolver(
  const StorageName: string): TInstantXMLResolver;
begin
  Result := TInstantXMLResolver.Create(Self, StorageName);
end;

destructor TInstantXMLBroker.Destroy;
begin
  FResolverList.Free;
  inherited;
end;

function TInstantXMLBroker.CreateCatalog(const AScheme: TInstantScheme):
  TInstantCatalog;
begin
  Result := TInstantXMLCatalog.Create(AScheme, Self);
end;

function TInstantXMLBroker.CreateDBBuildCommand(const CommandType:
  TInstantDBBuildCommandType): TInstantDBBuildCommand;
begin
  if CommandType = ctAddTable then
    Result := TInstantDBBuildXMLAddTableCommand.Create(CommandType, Connector)
  else if CommandType = ctDropTable then
    Result := TInstantDBBuildXMLDropTableCommand.Create(CommandType, Connector)
  else
    Result := inherited CreateDBBuildCommand(CommandType);
end;

function TInstantXMLBroker.EnsureResolver(
  Map: TInstantAttributeMap): TInstantCustomResolver;
var
  StorageName: string;
begin
  StorageName := Map.Name;
  Result := FindResolver(StorageName);
  if not Assigned(Result) then
  begin
    Result := CreateResolver(StorageName);
    ResolverList.Add(Result);
  end;
end;

function TInstantXMLBroker.FindResolver(
  const StorageName: string): TInstantXMLResolver;
var
  I: Integer;
begin
  for I := 0 to Pred(ResolverCount) do
  begin
    Result := Resolvers[I];
    if SameText(StorageName, Result.StorageName) then
      Exit;
  end;
  Result := nil;
end;

function TInstantXMLBroker.GetConnector: TInstantXMLConnector;
begin
  Result := inherited Connector as TInstantXMLConnector;
end;

function TInstantXMLBroker.GetResolverCount: Integer;
begin
  Result := ResolverList.Count;
end;

function TInstantXMLBroker.GetResolverList: TObjectList;
begin
  if not Assigned(FResolverList) then
    FResolverList := TObjectList.Create;
  Result := FResolverList;
end;

function TInstantXMLBroker.GetResolvers(
  Index: Integer): TInstantXMLResolver;
begin
  Result := ResolverList[Index] as TInstantXMLResolver;
end;

{ TInstantXMLQuery }

procedure TInstantXMLQuery.AfterConstruction;
begin
  inherited;
  FStorageNames := TStringList.Create;
  FStorageNames.Sorted := True;
  FStorageNames.Duplicates := dupIgnore;
  FObjectClassNames := TStringList.Create;
  FObjectClassNames.Sorted := True;
  FObjectClassNames.Duplicates := dupIgnore;
end;

destructor TInstantXMLQuery.Destroy;
begin
  DestroyObjectReferenceList;
  FParamsObject.Free;
  FreeAndNil(FStorageNames);
  FreeAndNil(FObjectClassNames);
  inherited;
end;

procedure TInstantXMLQuery.DestroyObjectReferenceList;
begin
  FreeAndNil(FObjectReferenceList);
end;

function TInstantXMLQuery.GetActive: Boolean;
begin
  Result := Assigned(FObjectReferenceList);
end;

function TInstantXMLQuery.GetConnector: TInstantXMLConnector;
begin
  Result := inherited Connector as TInstantXMLConnector;
end;

function TInstantXMLQuery.GetObjectReferenceCount: Integer;
begin
  Result := ObjectReferenceList.Count;
end;

function TInstantXMLQuery.GetObjectReferenceList: TObjectList;
begin
  if not Assigned(FObjectReferenceList) then
    FObjectReferenceList := TObjectList.Create;
  Result := FObjectReferenceList;
end;

function TInstantXMLQuery.GetObjectReferences(
  Index: Integer): TInstantObjectReference;
begin
  Result := ObjectReferenceList[Index] as TInstantObjectReference;
end;

function TInstantXMLQuery.GetParams: TParams;
begin
  Result := ParamsObject;
end;

function TInstantXMLQuery.GetParamsObject: TParams;
begin
  if not Assigned(FParamsObject) then
    FParamsObject := TParams.Create;
  Result := FParamsObject;
end;

function TInstantXMLQuery.GetStatement: string;
begin
  Result := FStatement;
end;

procedure TInstantXMLQuery.InitObjectReferences(const AFileList: TStrings);
var
  I: Integer;

  procedure AddObjectReference(const AFileName: string);
  var
    vClassName, vObjectId: string;
    vObjectReference: TInstantObjectReference;
    vIndex: Integer;
  begin
    vClassName := GetFileClassName(AFileName);
    if FObjectClassNames.Find(vClassName, vIndex) then
    begin
      vObjectId := GetFileId(AFileName);
      vObjectReference := TInstantObjectReference.Create(nil, True);
      try
        vObjectReference.ReferenceObject(vClassName, vObjectId);
        ObjectReferenceList.Add(vObjectReference);
      except
        ObjectReferenceList.Remove(vObjectReference);
        vObjectReference.Free;
        raise;
      end;
    end;
  end;

begin
  for I := 0 to AFileList.Count - 1 do
    AddObjectReference(AFileList[I]);
end;

function TInstantXMLQuery.InternalAddObject(AObject: TObject): Integer;
var
  ObjectRef: TInstantObjectReference;
begin
  ObjectRef := TInstantObjectReference.Create(AObject as TInstantObject, True);
  try
    Result := ObjectReferenceList.Add(ObjectRef);
  except
    ObjectRef.Free;
    raise
  end;
end;

procedure TInstantXMLQuery.InternalClose;
begin
  DestroyObjectReferenceList;
  inherited;
end;

procedure TInstantXMLQuery.InternalGetInstantObjectRefs(List:
    TInstantObjectReferenceList);
var
  I: Integer;
begin
  for I := 0 to Pred(ObjectReferenceCount) do
    if ObjectFetched(I) and (Objects[I] is TInstantObject) then
      List.Add(TInstantObject(Objects[I]));
end;

function TInstantXMLQuery.InternalGetObjectCount: Integer;
begin
  Result := ObjectReferenceCount;
end;

function TInstantXMLQuery.InternalGetObjects(Index: Integer): TObject;
begin
  Result := ObjectReferences[Index].Dereference(Connector);
end;

function TInstantXMLQuery.InternalIndexOfObject(AObject: TObject): Integer;
begin
  if AObject is TInstantObject then
    for Result := 0 to Pred(ObjectReferenceCount) do
      if ObjectReferences[Result].Equals(TInstantObject(AObject)) then
        Exit;
  Result := -1;
end;

procedure TInstantXMLQuery.InternalInsertObject(Index: Integer;
  AObject: TObject);
var
  ObjectRef: TInstantObjectReference;
begin
  ObjectRef := TInstantObjectReference.Create(AObject as TInstantObject, True);
  try
    ObjectReferenceList.Insert(Index, ObjectRef);
  except
    ObjectRef.Free;
    raise
  end;
end;

procedure TInstantXMLQuery.InternalOpen;
var
  vFileList: TStringList;
begin
  inherited;
  vFileList := TStringList.Create;
  try
    Connector.Connection.Open;
    Connector.Connection.LoadFileList(vFileList, FStorageNames);
    InitObjectReferences(vFileList);
  finally
    vFileList.Free;
  end;
end;

procedure TInstantXMLQuery.InternalReleaseObject(AObject: TObject);
var
  Index: Integer;
begin
  Index := IndexOfObject(AObject);
  if Index <> -1 then
    ObjectReferences[Index].DestroyInstance;
end;

function TInstantXMLQuery.InternalRemoveObject(AObject: TObject): Integer;
begin
  Result := IndexOfObject(AObject);
  if Result <> -1 then
    ObjectReferenceList.Delete(Result);
end;

function TInstantXMLQuery.ObjectFetched(Index: Integer): Boolean;
begin
  Result := ObjectReferences[Index].HasInstance;
end;

procedure TInstantXMLQuery.SetObjectClassNames(const Value: TStringList);
begin
  FObjectClassNames.Assign(Value);
end;

procedure TInstantXMLQuery.SetParams(Value: TParams);
begin
  inherited;
  ParamsObject.Assign(Value);
end;

procedure TInstantXMLQuery.SetStatement(const Value: string);
begin
  inherited;
  FStatement := Value;
end;

procedure TInstantXMLQuery.SetStorageNames(const Value: TStringList);
begin
  FStorageNames.Assign(Value);
end;

class function TInstantXMLQuery.TranslatorClass:
  TInstantRelationalTranslatorClass;
begin
  Result := TInstantXMLTranslator;
end;

{ TXMLFilesAccessor }

function TXMLFilesAccessor.GetRootFolder: string;
begin
  Result := IncludeTrailingPathDelimiter(FRootFolder);
end;

procedure TXMLFilesAccessor.SetRootFolder(const AValue: string);
begin
  if FRootFolder <> AValue then
  begin
    FRootFolder := AValue;
  end;
end;

function TXMLFilesAccessor.SaveToFileXML_UTF8(AObject: TInstantObject;
  const AFileName: string): Boolean;
var
  strstream: TStringStream;
  fileStream: TFileStream;
  DataStr: string;
begin
  strstream := TStringStream.Create('');
  try
    InstantWriteObject(strStream, sfXML, AObject);
{$IFDEF D6+}
    if FXMLFileFormat = xffUtf8 then
      DataStr := AnsiToUtf8(XML_UTF8_HEADER + strStream.DataString)
    else
      DataStr := XML_ISO_HEADER + strStream.DataString;
{$ELSE}
    DataStr := strStream.DataString;
{$ENDIF}
  finally
    strStream.Free;
  end;
  fileStream := TFileStream.Create(AFileName, fmCreate);
  try
    Result := fileStream.Write(DataStr[1], Length(DataStr)) <> 0;
  finally
    fileStream.Free;
  end;
end;

function RemoveXmlDeclaration(const xmlString: string): string;
var
  nPos: Integer;
begin
  nPos := Pos('<?xml', xmlString);
  if nPos > 0 then
    Result := Copy(xmlString, Pos('?>', xmlString) + 2, maxint)
  else
    Result := xmlString;
end;

function TXMLFilesAccessor.LoadFromFileXML_UTF8(AObject: TInstantObject;
  const FileName: string): boolean;
var
  fileStream: TFileStream;
  strUtf8: string;
  strstream: TStringStream;
begin
  fileStream := TFileStream.Create(FileName, fmOpenRead);
  try
    SetLength(strUtf8, fileStream.Size);
    Result := fileStream.Read(strUtf8[1], fileStream.Size) <> 0;
    // skip XML HEADER (until the parser is "dumb")
    strUtf8 := RemoveXmlDeclaration(strUtf8);
  finally
    fileStream.Free;
  end;

{$IFDEF D6+}
  if FXMLFileFormat = xffUtf8 then
    strUtf8 := Utf8ToAnsi(strUtf8);
{$ENDIF}

  strstream := TStringStream.Create(strUtf8);
  try
    InstantReadObject(strstream, sfXML, AObject);
  finally
    strstream.Free;
  end;
end;

function TXMLFilesAccessor.ReadInstantObject(AObject: TInstantObject;
  const StorageName, AObjectId: string; out AObjectUpdateCount: Integer): Boolean;
var
  LFileName: string;
begin
  LFileName := PlainObjectFileName(StorageName, AObject.ClassName, AObjectId);
  Result := LoadFromFileXML_UTF8(AObject, LFileName);
  AObjectUpdateCount := ObjectUpdateCountFromFileName(LFileName);
end;

function TXMLFilesAccessor.WriteInstantObject(AObject: TInstantObject;
  const AStorageName: string; out AObjectUpdateCount: Integer): Boolean;
var
  LFileName: string;
begin
  CreateStorageDir(AStorageName);
  LFileName := PlainObjectFileName(AStorageName, AObject.ClassName, AObject.Id);
  Result := SavetoFileXML_UTF8(AObject, LFileName);
  AObjectUpdateCount := ObjectUpdateCountFromFileName(LFileName);
end;

function TXMLFilesAccessor.Locate(const AStorageName, AObjectClassName,
  AObjectId: string): Boolean;
var
  filename: string;
begin
  filename := PlainObjectFileName(AStorageName, AObjectClassName, AObjectId);
  Result := FileExists(filename);
end;

procedure TXMLFilesAccessor.CreateStorageDir(const AStorageName: string);
begin
  if not DirectoryExists(RootFolder + AStorageName) then
    MkDir(RootFolder + AStorageName);
end;

function TXMLFilesAccessor.ObjectUpdateCountFromFileName(
  const AFileName: string): Integer;
begin
  Result := GetObjectUpdateCount(ExtractFileName(AFileName));
end;

function TXMLFilesAccessor.DeleteInstantObject(AObject: TInstantObject;
  const AStorageName: string): Boolean;
begin
  Result := SysUtils.DeleteFile(PlainObjectFileName(AStorageName,
    AObject.ClassName, AObject.Id));
end;

constructor TXMLFilesAccessor.Create(AOwner: TComponent);
begin
  inherited;
  FXMLFileFormat := xffUtf8;
end;

function TXMLFilesAccessor.PlainObjectFileName(const StorageName,
  ClassName, Id: string): string;
begin
  Result := RootFolder + StorageName + PathDelim + ClassName + '.' + Id + '.1' +
    DOT_XML_EXT;
end;

function TXMLFilesAccessor.CheckConflict(AObject: TInstantObject;
  const AStorageName, AObjectId: string): Boolean;
begin
  Result := False; // don't care about updatecount
end;

procedure TXMLFilesAccessor.LoadFileList(const AFileList: TStringList;
  const AStorageNames: TStrings);
var
  I: Integer;
begin
  AFileList.Clear;
  for I := 0 to AStorageNames.Count - 1 do
    GlobalLoadFileList(RootFolder + AStorageNames[I], AFileList);
end;

procedure TXMLFilesAccessor.DoConnect;
begin
  if DirectoryExists(RootFolder) then
    FConnected := True;
end;

procedure TXMLFilesAccessor.DoDisconnect;
begin
  FConnected := False;
end;

function TXMLFilesAccessor.GetConnected: Boolean;
begin
  Result := FConnected;
end;

{ TInstantXMLTranslator }

function TInstantXMLTranslator.TranslateClassRef(
  ClassRef: TInstantIQLClassRef; Writer: TInstantIQLWriter): Boolean;
var
  vInheritedClasses: TList;
  I: Integer;
begin
  Result := inherited TranslateClassRef(ClassRef, Writer);
  if TablePathCount > 0 then
  begin
    (Query as TInstantXMLQuery).StorageNames.Text := TablePaths[0];
    (Query as TInstantXMLQuery).ObjectClassNames.Text := ClassRef.ObjectClassName;
    if ClassRef.Any then
    begin
      // Need to add all inherited classes as well.
      vInheritedClasses := TList.Create;
      try
        InstantGetClasses(vInheritedClasses, InstantFindClass(ClassRef.ObjectClassName));
        for I := 0 to vInheritedClasses.Count - 1 do
        begin
          (Query as TInstantXMLQuery).StorageNames.Add(
             TInstantObjectClass(vInheritedClasses[I]).Metadata.TableName);
          (Query as TInstantXMLQuery).ObjectClassNames.Add(
             TInstantObjectClass(vInheritedClasses[I]).ClassName);
        end;
      finally
        FreeAndNil(vInheritedClasses);
      end;
    end;
  end
  else
  begin
    (Query as TInstantXMLQuery).StorageNames.Clear;
    (Query as TInstantXMLQuery).ObjectClassNames.Clear;
  end;
end;

{ TInstantDBBuildXMLCommand }

function TInstantDBBuildXMLCommand.GetBroker: TInstantXMLBroker;
begin
  Result := Connector.Broker as TInstantXMLBroker;
end;

function TInstantDBBuildXMLCommand.GetCommand(const Index: Integer): string;
begin
  if (Index < 0) or (Index >= GetCommandCount) then
    raise EInstantDBBuildError.CreateFmt(SCommandIndexOutOfBounds,
      [Index]);
  Result := '';
end;

function TInstantDBBuildXMLCommand.GetCommandCount: Integer;
begin
  Result := 1;
end;

function TInstantDBBuildXMLCommand.GetConnector: TInstantXMLConnector;
begin
  Result := inherited Connector as TInstantXMLConnector;
end;

function TInstantDBBuildXMLAddTableCommand.GetTableMetadata:
  TInstantTableMetadata;
begin
  Result := NewMetadata as TInstantTableMetadata;
end;

procedure TInstantDBBuildXMLAddTableCommand.InternalExecute;
var
  vDatabaseName: string;
begin
  Connector.CheckConnection;
  vDatabaseName := Connector.DatabaseName;

  if not DirectoryExists(vDatabaseName) and
      not ForceDirectories(vDatabaseName) then
    raise EInOutError.CreateFmt(SCannotCreateDirectory, [vDatabaseName]);

  // No need to create the class-specific folders, which will be created
  // when instances are written.
end;

function TInstantDBBuildXMLDropTableCommand.GetTableMetadata:
  TInstantTableMetadata;
begin
  Result := OldMetadata as TInstantTableMetadata;
end;

procedure TInstantDBBuildXMLDropTableCommand.InternalExecute;
var
  vTableName: string;
  sr: TSearchRec;
  vDatabaseName: string;
begin
  Connector.CheckConnection;
  vDatabaseName := Connector.DatabaseName;

  // Delete subFolder for the "storage name"
  vTableName := vDatabaseName + TableMetadata.Name;
  if DirectoryExists(vTableName) then
  begin
    if FindFirst(vTableName + '\*.*', faAnyFile, sr) = 0 then
    begin
      repeat
        SysUtils.DeleteFile(vTableName + '\' + sr.Name);
      until FindNext(sr) <> 0;
      SysUtils.FindClose(sr);
    end;
    RemoveDir(vTableName);
  end;
end;

initialization
  Classes.RegisterClass(TInstantXMLConnectionDef);
  TInstantXMLConnector.RegisterClass;

finalization
  TInstantXMLConnector.UnregisterClass;

end.

