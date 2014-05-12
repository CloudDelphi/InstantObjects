(*
 *   InstantObjects
 *   Embarcadero FireDAC Support
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
 * The Original Code is: InstantObjects FireDAC Support
 *
 * The Initial Developer of the Original Code is: David Taylor
 *
 * Portions created by the Initial Developer are Copyright (C) 2009-2011
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * Carlo Barazzetta
 *
 * ***** END LICENSE BLOCK ***** *)

unit InstantFireDAC;

{$IFDEF LINUX}
{$I '../../InstantDefines.inc'}
{$ELSE}
{$I '..\..\InstantDefines.inc'}
{$ENDIF}

// Supported databases  (only MSSQL and Firebird have been tested as of 8/18/2009)

{$DEFINE SYBASE_SUPPORT}
{$DEFINE MSSQL_SUPPORT}
{$DEFINE IBFB_SUPPORT}
{$DEFINE ORACLE_SUPPORT}
{$DEFINE PGSQL_SUPPORT}
{$DEFINE MYSQL_SUPPORT}
{$DEFINE SQLITE_SUPPORT}

interface

uses
  Classes, Db, InstantPersistence, InstantCommand, InstantDBBuild,
  InstantBrokers, InstantMetadata, InstantTypes, FireDAC.Comp.Client,
  {$IFDEF IBFB_SUPPORT}FireDAC.Phys.IBBase, FireDAC.Phys.FB, FireDAC.Phys.IB,{$ENDIF}
  {$IFDEF MSSQL_SUPPORT}FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLMeta,{$ENDIF}
  {$IFDEF SYBASE_SUPPORT}FireDAC.Phys.ASA, FireDAC.Phys.ASAWrapper,{$ENDIF}
  {$IFDEF ORACLE_SUPPORT}FireDAC.Phys.ORACLE, FireDAC.Phys.ORACLEMeta,{$ENDIF}
  {$IFDEF PGSQL_SUPPORT}FireDAC.Phys.PG, FireDAC.Phys.PGWrapper,{$ENDIF}
  {$IFDEF MYSQL_SUPPORT}FireDAC.Phys.MYSQL, FireDAC.Phys.MYSQLWrapper,{$ENDIF}
  {$IFDEF SQLITE_SUPPORT}FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteWrapper,{$ENDIF}
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Intf, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet
  {$IFDEF D10+}, Variants, DBCommonTypes{$ENDIF};

type
  TInstantFireDACConnectionDef = class(TInstantRelationalConnectionDef)
  private
    FCatalog            : string;
    FDatabase           : string;
    FHostName           : string;
    FLoginPrompt        : boolean;
    FPassword           : string;
    FPort               : integer;
    FProperties         : string;
    FProtocol           : string;
    FUseDelimitedIdents : boolean;
    FUserName           : string;
  protected
    procedure InitConnector(Connector: TInstantConnector); override;
  public
    function Edit: Boolean; override;
    class function ConnectionTypeName: string; override;
    class function ConnectorClass: TInstantConnectorClass; override;
  published
    property Catalog: string read FCatalog write FCatalog;
    property Database: string read FDatabase write FDatabase;
    property HostName: string read FHostName write FHostName;
    property LoginPrompt: boolean read FLoginPrompt write FLoginPrompt;
    property Password: string read FPassword write FPassword;
    property Port: Integer read FPort write FPort;
    property Properties: string read FProperties write FProperties;
    property Protocol: string read FProtocol write FProtocol;
    property UseDelimitedIdents: boolean read FUseDelimitedIdents write FUseDelimitedIdents;
    property UserName: string read FUserName write FUserName;
  end;

  TInstantFireDACBroker = class;

  TInstantFireDACConnector = class(TInstantRelationalConnector)
  private
    FConnection         : TFDConnection;
    FLoginPrompt        : Boolean;
    FOnLogin            : TLoginEvent;
    FUseDelimitedIdents : Boolean;
    procedure DoAfterConnectionChange;
    procedure DoBeforeConnectionChange;
    function GetBroker: TInstantFireDACBroker;
    function GetConnection: TFDConnection;
    function GetLoginPrompt: Boolean;
    procedure SetConnection(Value: TFDConnection);
    procedure SetLoginPrompt(const Value: Boolean);
    procedure SetUseDelimitedIdents(const Value: Boolean);
  protected
    procedure AfterConnectionChange; virtual;
    procedure BeforeConnectionChange; virtual;
    procedure AssignLoginOptions; virtual;
    procedure CheckConnection;
    function CreateBroker: TInstantBroker; override;
    procedure DoLogin(AConnection: TFDCustomConnection;
      const AConnectionDef: IFDStanConnectionDef); virtual;
    function GetConnected: Boolean; override;
    function GetDatabaseExists: Boolean; override;
    procedure InternalBuildDatabase(Scheme: TInstantScheme); override;
    procedure InternalCommitTransaction; override;
    procedure InternalConnect; override;
    procedure InternalCreateDatabase; override;
    procedure InternalDisconnect; override;
    procedure InternalRollbackTransaction; override;
    procedure InternalStartTransaction; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function ParamByName(const AName: string): string;
  public
    constructor Create(AOwner: TComponent); override;
    class function ConnectionDefClass: TInstantConnectionDefClass; override;
    function HasConnection: Boolean;
    property Broker: TInstantFireDACBroker read GetBroker;
  published
    property Connection: TFDConnection read GetConnection write SetConnection;
    property LoginPrompt: Boolean read GetLoginPrompt write SetLoginPrompt default False;
    property OnLogin: TLoginEvent read FOnLogin write FOnLogin;
    property UseDelimitedIdents: Boolean read FUseDelimitedIdents write SetUseDelimitedIdents default False;
  end;

  TInstantFireDACBroker = class(TInstantSQLBroker)
  private
    function GetConnector: TInstantFireDACConnector;
  protected
    procedure AssignDataSetParams(DataSet: TDataSet; AParams: TParams); override;
    procedure AssignParam(SourceParam: TParam; TargetParam: TFDParam); virtual;
    function CreateCatalog(const AScheme: TInstantScheme): TInstantCatalog; override;
    function CreateResolver(Map: TInstantAttributeMap): TInstantSQLResolver; override;
    function GetDatabaseName: string; override;
    function GetDBMSName: string; override;
    function GetSQLDelimiters: string; override;
    function GetSQLQuote: Char; override;
    procedure InternalCreateDatabase; virtual;
    function InternalCreateQuery: TInstantQuery; override;
    function InternalDataTypeToColumnType(DataType: TInstantDataType): string; virtual; abstract;
    function InternalDBNotExistsErrorCode: Integer; virtual;
    function UseBooleanFields: Boolean; virtual; abstract;
  public
    procedure CreateDatabase;
    function CreateDataSet(const AStatement: string; AParams: TParams = nil): TDataSet; override;
    function CreateDBBuildCommand(const CommandType: TInstantDBBuildCommandType): TInstantDBBuildCommand; override;
    function DataTypeToColumnType(DataType: TInstantDataType; Size: Integer): string; override;
    function Execute(const AStatement: string; AParams: TParams = nil): Integer; override;
    function DBNotExistsErrorCode: Integer;
    property Connector: TInstantFireDACConnector read GetConnector;
  end;

  //
  // Resolver that interprets an integer column value as a boolean
  //
  TInstantFireDACResolver = class(TInstantSQLResolver)
  protected
    function ReadBooleanField(DataSet: TDataSet; const FieldName: string): Boolean; override;
  end;

  //
  // Translator that translates a boolean value to a '0' or '1'
  //
  TInstantFireDACTranslator = class(TInstantRelationalTranslator)
  protected
    function TranslateConstant(Constant: TInstantIQLConstant; Writer: TInstantIQLWriter): Boolean; override;
  end;

  TInstantFireDACQuery = class(TInstantSQLQuery)
  protected
    class function TranslatorClass: TInstantRelationalTranslatorClass; override;
  end;

  { Sybase broker }

  {$IFDEF SYBASE_SUPPORT}
  TInstantFireDACSybaseBroker = class(TInstantFireDACBroker)
  protected
    function InternalDataTypeToColumnType(DataType: TInstantDataType): string; override;
    function UseBooleanFields: Boolean; override;
  end;
  {$ENDIF}

  { MS SQL Server broker }

  {$IFDEF MSSQL_SUPPORT}
  TInstantFireDACMSSQLBroker = class(TInstantFireDACBroker)
  protected
    function InternalDataTypeToColumnType(DataType: TInstantDataType): string; override;
    function UseBooleanFields: Boolean; override;
  end;

  TInstantFireDACMSSQL2005Broker = class(TInstantFireDACMSSQLBroker)
  protected
    function InternalDataTypeToColumnType(DataType: TInstantDataType): string; override;
  end;
  {$ENDIF}

  { Interbase and Firebird brokers }

  {$IFDEF IBFB_SUPPORT}
  TInstantFireDACIbFbBroker = class(TInstantFireDACBroker)
  protected
    procedure InternalCreateDatabase; override;
    function InternalDataTypeToColumnType(DataType: TInstantDataType): string; override;
    function InternalDBNotExistsErrorCode: Integer; override;
    function UseBooleanFields: Boolean; override;
  end;
  {$ENDIF}

  { Oracle broker }

  {$IFDEF ORACLE_SUPPORT}
  TInstantFireDACOracleBroker = class(TInstantFireDACBroker)
  protected
    function InternalDataTypeToColumnType(DataType: TInstantDataType): string; override;
    function UseBooleanFields: Boolean; override;
  end;
  {$ENDIF}

  { PostgreSQL broker }

  {$IFDEF PGSQL_SUPPORT}
  TInstantFireDACPgSQLBroker = class(TInstantFireDACBroker)
  protected
    function InternalDataTypeToColumnType(DataType: TInstantDataType): string; override;
    function UseBooleanFields: Boolean; override;
  end;
  {$ENDIF}

  { MySQL broker }

  {$IFDEF MYSQL_SUPPORT}
  TInstantMySQLGenerator = class(TInstantSQLGenerator)
  protected
    function InternalGenerateDropIndexSQL(Metadata: TInstantIndexMetadata): string; override;
  end;

  TInstantFireDACMySQLBroker = class(TInstantFireDACBroker)
  protected
    function InternalDataTypeToColumnType(DataType: TInstantDataType): string;
      override;
    function InternalDBNotExistsErrorCode: Integer; override;
    function UseBooleanFields: Boolean; override;
  public
    class function GeneratorClass: TInstantSQLGeneratorClass; override;
  end;
  {$ENDIF}

  { SQLite broker }

  {$IFDEF SQLITE_SUPPORT}

  //SQLite doesn�t support ALTER TABLE. Spport for ADD COLUMN, ALTER COLUMN and
  //DROP COLUMN, is emulated with a couple of CREATE TEMP TABLE, INSERT INTO,
  //DROP TABLE, CREATE TABLE, INSERT INTO and finally DROP TABLE
  TInstantDBBuildSQLiteAlterTableSQLCommand = class(TInstantDBBuildSQLCommand)
  private
    FTmpTableMD       : TInstantTableMetadata;
    FOldTableMetadata : TInstantTableMetadata;
    FNewTableMetadata : TInstantTableMetadata;
    FScheme           : TInstantScheme;
  protected
    procedure Rollback; virtual;
    function GetDescription: string; override;
    function GetSQLStatement(const Index: Integer): string; override;
    function GetSQLStatementCount: Integer; override;
    function GetNewTableMetadata: TInstantTableMetadata;
    function GetOldTableMetadata: TInstantTableMetadata;
    procedure InternalExecute; override;
  public
    destructor Destroy; override;
    property OldTableMetadata: TInstantTableMetadata read GetOldTableMetadata;
    property NewTableMetadata: TInstantTableMetadata read GetNewTableMetadata;
  end;

  TInstantSQLiteGenerator = class(TInstantSQLGenerator)
  protected
    function InternalGenerateInsertFromSelectSQL(const SourceMetadata, TargetMetadata: TInstantTableMetadata): string; virtual;
    function InternalGenerateCreateTempTableSQL(Metadata: TInstantTableMetadata): string; virtual;
  public
    function GenerateCreateTempTableSQL(Metadata: TInstantTableMetadata): string;
    function GenerateInsertFromSelectSQL(const SourceMetadata, TargetMetadata: TInstantTableMetadata): string;
  end;

  TInstantFireDACSQLiteBroker = class(TInstantFireDACBroker)
  protected
    function InternalDataTypeToColumnType(DataType: TInstantDataType): string; override;
    function UseBooleanFields: Boolean; override;
  public
    class function GeneratorClass: TInstantSQLGeneratorClass; override;
    function CreateDBBuildCommand(const CommandType: TInstantDBBuildCommandType): TInstantDBBuildCommand; override;
  end;
  {$ENDIF}

procedure AssignFireDACProtocols(Strings: TStrings);

implementation

uses
  SysUtils, {$IFDEF D7+}Types,{$ENDIF} Controls, {$IFDEF D5}DBLogDlg,{$ENDIF}
  InstantConsts, InstantClasses, InstantFireDACConnectionDefEdit,
  InstantFireDACCatalog, InstantUtils,
  FireDAC.Stan.Consts;

resourcestring
  SInvalidDatabasePageSize = 'Invalid database PageSize value: "%s"';

{$IFDEF SQLITE_SUPPORT}
const
  STmpTableSuffix = '_IOTmp_';
{$ENDIF}

{$IFDEF MSSQL_SUPPORT}
  S_FD_MSSQL2005Id = S_FD_MSSQLId + ' 2005';
{$ENDIF}

procedure AssignFireDACProtocols(Strings: TStrings);
begin
  if assigned(Strings) then
    begin
      Strings.Clear;

      {$IFDEF SYBASE_SUPPORT}
      Strings.Add(S_FD_ASAId);
      {$ENDIF}

      {$IFDEF MSSQL_SUPPORT}
      Strings.Add(S_FD_MSSQLId);
      Strings.Add(S_FD_MSSQL2005Id);
      {$ENDIF}

      {$IFDEF IBFB_SUPPORT}
      Strings.Add(S_FD_FBId);
      Strings.Add(S_FD_IBId);
      {$ENDIF}

      {$IFDEF ORACLE_SUPPORT}
      Strings.Add(S_FD_OraId);
      {$ENDIF}

      {$IFDEF PGSQL_SUPPORT}
      Strings.Add(S_FD_PGId);
      {$ENDIF}

      {$IFDEF MYSQL_SUPPORT}
      Strings.Add(S_FD_MySQLId);
      {$ENDIF}

      {$IFDEF SQLITE_SUPPORT}
      Strings.Add(S_FD_SQLiteId);
      {$ENDIF}
    end;
end;


{ Local routines }

{$IFDEF D5}
function LoginDialogProcCompatibility(const ADatabaseName: string;
 var AUserName, APassword: string): Boolean;
begin
  Result := LoginDialogEx(ADatabaseName, AUserName, APassword, False);
end;
{$ENDIF}

{ TInstantFireDACConnectionDef }

class function TInstantFireDACConnectionDef.ConnectionTypeName: string;
begin
  Result := 'FireDAC';
end;

class function TInstantFireDACConnectionDef.ConnectorClass: TInstantConnectorClass;
begin
  Result := TInstantFireDACConnector;
end;

function TInstantFireDACConnectionDef.Edit: Boolean;
var
  EditForm : TInstantFireDACConnectionDefEditForm;
begin
  EditForm := TInstantFireDACConnectionDefEditForm.Create(nil);
  try
    EditForm.LoadData(Self);
    Result := (EditForm.ShowModal = mrOk);
    if (Result) then
      EditForm.SaveData(Self);
  finally
    EditForm.Free;
  end;
end;

procedure TInstantFireDACConnectionDef.InitConnector(Connector: TInstantConnector);
var
  Connection  : TFDConnection;
  FDConnector : TInstantFireDACConnector;
begin
  inherited;
  Connection := TFDConnection.Create(Connector);
  try
    FDConnector := (Connector as TInstantFireDACConnector);
    FDConnector.Connection := Connection;
    FDConnector.LoginPrompt := LoginPrompt;
    FDConnector.UseDelimitedIdents := UseDelimitedIdents;

    // Use FireDAC MSSQL driver name for MSSQL 2005 protocol
    if (SameText(Protocol, S_FD_MSSQL2005Id)) then
      Connection.DriverName := S_FD_MSSQLId else
      Connection.DriverName := Protocol;

    Connection.TxOptions.AutoCommit := false;
    Connection.TxOptions.Isolation := xiReadCommitted;
    Connection.Params.Values['User_Name'] := UserName;
    Connection.Params.Values['Password'] := Password;
    Connection.Params.Values['Database'] := Database;
    Connection.Params.Values['MetaDefCatalog'] := Catalog;

    if (trim(HostName) = '') then
      HostName := '127.0.0.1';

    if (Port <= 0) then
      Connection.Params.Values['Server'] := HostName else
      Connection.Params.Values['Server'] := HostName + ', ' + IntToStr(Port)
  except
    Connection.Free;
    raise;
  end;
end;

{ TInstantFireDACConnector }

procedure TInstantFireDACConnector.AfterConnectionChange;
begin
  if (HasConnection) then
    begin
      FConnection.Close;
      FConnection.TxOptions.AutoCommit := true;
      FConnection.TxOptions.Isolation := xiReadCommitted;
      FConnection.OnLogin := DoLogin;
    end;
end;

procedure TInstantFireDACConnector.AssignLoginOptions;
begin
  if (HasConnection) then
    FConnection.LoginPrompt := FLoginPrompt;
end;

procedure TInstantFireDACConnector.BeforeConnectionChange;
begin
end;

procedure TInstantFireDACConnector.CheckConnection;
begin
  if not assigned(FConnection) then
    raise EInstantError.Create(SUnassignedConnection);
end;

class function TInstantFireDACConnector.ConnectionDefClass: TInstantConnectionDefClass;
begin
  Result := TInstantFireDACConnectionDef;
end;

constructor TInstantFireDACConnector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLoginPrompt := False;
  FUseDelimitedIdents := False;
end;

function TInstantFireDACConnector.CreateBroker: TInstantBroker;
begin
  CheckConnection;
  Result := nil;

  {$IFDEF SYBASE_SUPPORT}
  if SameText(FConnection.DriverName, S_FD_ASAId) then
    Result := TInstantFireDACSybaseBroker.Create(Self);
  {$ENDIF}

  {$IFDEF MSSQL_SUPPORT}
  if SameText(FConnection.DriverName, S_FD_MSSQLId) then
    Result := TInstantFireDACMSSQLBroker.Create(Self);

  if SameText(FConnection.DriverName, S_FD_MSSQL2005Id) then
    Result := TInstantFireDACMSSQL2005Broker.Create(Self);
  {$ENDIF}

  {$IFDEF IBFB_SUPPORT}
  if SameText(FConnection.DriverName, S_FD_IBId) or SameText(FConnection.DriverName, S_FD_FBId) then
    Result := TInstantFireDACIbFbBroker.Create(Self);
  {$ENDIF}

  {$IFDEF ORACLE_SUPPORT}
  if SameText(FConnection.DriverName, S_FD_OraId) then
    Result := TInstantFireDACOracleBroker.Create(Self);
  {$ENDIF}

  {$IFDEF PGSQL_SUPPORT}
  if SameText(FConnection.DriverName, S_FD_PGId) then
    Result := TInstantFireDACPgSQLBroker.Create(Self);
  {$ENDIF}

  {$IFDEF MYSQL_SUPPORT}
  if SameText(FConnection.DriverName, S_FD_MySQLId) then
    Result := TInstantFireDACMySQLBroker.Create(Self);
  {$ENDIF}

  {$IFDEF SQLITE_SUPPORT}
  if SameText(FConnection.DriverName, S_FD_SQLiteId) then
    Result := TInstantFireDACSQLiteBroker.Create(Self);
  {$ENDIF}

  if (Result = nil) then
    raise EInstantError.CreateFmt(SProtocolNotSupported,
     [FConnection.DriverName]);
end;

procedure TInstantFireDACConnector.DoLogin(AConnection: TFDCustomConnection;
  const AConnectionDef: IFDStanConnectionDef);
begin
  if (assigned(FOnLogin)) then
    FOnLogin(AConnection, AConnection.Params.Values['User_Name'],
             AConnection.Params.Values['Password']);
end;

procedure TInstantFireDACConnector.DoAfterConnectionChange;
begin
  if (HasConnection) then
    FConnection.FreeNotification(Self);
  AfterConnectionChange;
end;

procedure TInstantFireDACConnector.DoBeforeConnectionChange;
begin
  try
    BeforeConnectionChange;
  finally
    if HasConnection then
      FConnection.RemoveFreeNotification(Self);
  end;
end;

function TInstantFireDACConnector.GetBroker: TInstantFireDACBroker;
begin
  Result := inherited Broker as TInstantFireDACBroker;
end;

function TInstantFireDACConnector.GetConnected: Boolean;
begin
  if (HasConnection) then
    Result := Connection.Connected else
    Result := inherited GetConnected;
end;

function TInstantFireDACConnector.GetConnection: TFDConnection;
begin
  if not (csDesigning in ComponentState) then
    CheckConnection;
  Result := FConnection;
end;

function TInstantFireDACConnector.GetDatabaseExists: Boolean;
begin
  AssignLoginOptions;
  try
    Connection.Open;
    Result := True;
    Connection.Close;
  except
// TODO Fixup database detection logic for FireDAC - Exception approach may not work well
//    on E : EZSQLException do
//      if (E.ErrorCode = Broker.DBNotExistsErrorCode) then
//        Result := False
//      else
//        raise;
    Result := False
  end;
end;

function TInstantFireDACConnector.GetLoginPrompt: Boolean;
begin
  if (HasConnection) then
    FLoginPrompt := FConnection.LoginPrompt;
  Result := FLoginPrompt;
end;

function TInstantFireDACConnector.HasConnection: Boolean;
begin
  Result := assigned(FConnection);
end;

procedure TInstantFireDACConnector.InternalBuildDatabase(
  Scheme: TInstantScheme);
begin
  StartTransaction;
  try
    inherited InternalBuildDatabase(Scheme);
    CommitTransaction;
  except
    RollbackTransaction;
    raise;
  end;
end;

procedure TInstantFireDACConnector.InternalCommitTransaction;
begin
  CheckConnection;
  if (FConnection.InTransaction) then
    FConnection.Commit;
end;

procedure TInstantFireDACConnector.InternalConnect;
begin
  CheckConnection;
  FConnection.Open;
end;

procedure TInstantFireDACConnector.InternalCreateDatabase;
begin
  if (Connection.Connected) then
    raise EInstantError.Create(SDatabaseOpen);
  Broker.CreateDatabase;
end;

procedure TInstantFireDACConnector.InternalDisconnect;
begin
  if (HasConnection) then
    FConnection.Close;
end;

procedure TInstantFireDACConnector.InternalRollbackTransaction;
begin
  CheckConnection;
  if (FConnection.InTransaction) then
    FConnection.Rollback;
end;

procedure TInstantFireDACConnector.InternalStartTransaction;
begin
  CheckConnection;
  if (not FConnection.InTransaction) then
    FConnection.StartTransaction;
end;

procedure TInstantFireDACConnector.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (AComponent = FConnection) and (Operation = opRemove) then
    FConnection := nil;
end;

function TInstantFireDACConnector.ParamByName(const AName: string): string;
begin
  Result := Connection.Params.Values[AName];
end;

procedure TInstantFireDACConnector.SetConnection(Value: TFDConnection);
begin
  if (Value <> FConnection) then
    begin
      Disconnect;
      DoBeforeConnectionChange;
      FConnection := Value;
      AssignLoginOptions;
      DoAfterConnectionChange;
    end;
end;

procedure TInstantFireDACConnector.SetLoginPrompt(const Value: Boolean);
begin
  FLoginPrompt := Value;
  AssignLoginOptions;
end;

procedure TInstantFireDACConnector.SetUseDelimitedIdents(const Value: Boolean);
begin
  FUseDelimitedIdents := Value;
end;

{ TInstantFireDACBroker }

procedure TInstantFireDACBroker.AssignDataSetParams(DataSet: TDataSet; AParams: TParams);
var
  SourceParam : TParam;
  TargetParam : TFDParam;
  i           : Integer;
  Params      : TFDParams;
begin
  // Don't call inherited
  Params := (DataSet as TFDQuery).Params;
  for i := 0 to Pred(AParams.Count) do
    begin
      SourceParam := AParams[i];
      TargetParam := Params.FindParam(SourceParam.Name);
      if assigned(TargetParam) then
        AssignParam(SourceParam, TargetParam);
    end;
end;

procedure TInstantFireDACBroker.AssignParam(SourceParam: TParam; TargetParam: TFDParam);

{$IFDEF D12+}
function ConvertBlobData(const Bytes: TBytes): RawByteString;
  begin
    SetLength(Result, Length(Bytes));
    if length(Result) > 0 then
      Move(Bytes[0], Result[1], Length(Bytes))
  end;
{$ENDIF}

begin
  case SourceParam.DataType of
    ftBoolean:
      if UseBooleanFields then
        TargetParam.Assign(SourceParam) else
        TargetParam.AsInteger := ord(SourceParam.AsBoolean);
    ftBlob:
    {$IFDEF D12+}
      TargetParam.AsBlob := ConvertBlobData(SourceParam.AsBlob);
    {$ELSE}
      TargetParam.AsBlob := SourceParam.AsBlob;
    {$ENDIF}
    else
      TargetParam.Assign(SourceParam);
  end;
  
  if (SourceParam.IsNull) then
    begin
      TargetParam.Clear;
      TargetParam.Bound := true;
    end;
end;

function TInstantFireDACBroker.CreateCatalog(const AScheme: TInstantScheme): TInstantCatalog;
begin
  Result := TInstantFireDACCatalog.Create(AScheme,Self);
end;

procedure TInstantFireDACBroker.CreateDatabase;
begin
  InternalCreateDatabase;
end;

function TInstantFireDACBroker.CreateDataSet(const AStatement: string;
  AParams: TParams): TDataSet;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := Connector.Connection;
    Query.SQL.Text := AStatement;
    if assigned(AParams) then
      AssignDatasetParams(Query, AParams);
    Result := Query;
  except
    Query.Free;
    raise;
  end;
end;

function TInstantFireDACBroker.CreateDBBuildCommand(
  const CommandType: TInstantDBBuildCommandType): TInstantDBBuildCommand;
begin
  if CommandType = ctAddTable then
    Result := TInstantDBBuildAddTableSQLCommand.Create(CommandType, Connector)
  else if CommandType = ctDropTable then
    Result := TInstantDBBuildDropTableSQLCommand.Create(CommandType, Connector)
  else if CommandType = ctAddField then
    Result := TInstantDBBuildAddFieldSQLCommand.Create(CommandType, Connector)
  else if CommandType = ctAlterField then
    Result := TInstantDBBuildAlterFieldSQLCommand.Create(CommandType, Connector)
  else if CommandType = ctDropField then
    Result := TInstantDBBuildDropFieldSQLCommand.Create(CommandType, Connector)
  else if CommandType = ctAddIndex then
    Result := TInstantDBBuildAddIndexSQLCommand.Create(CommandType, Connector)
  else if CommandType = ctAlterIndex then
    Result := TInstantDBBuildAlterIndexSQLCommand.Create(CommandType, Connector)
  else if CommandType = ctDropIndex then
    Result := TInstantDBBuildDropIndexSQLCommand.Create(CommandType, Connector)
  else
    Result := inherited CreateDBBuildCommand(CommandType);
end;

function TInstantFireDACBroker.CreateResolver(Map: TInstantAttributeMap): TInstantSQLResolver;
begin
  if UseBooleanFields then
    Result := TInstantSQLResolver.Create(Self, Map) else
    Result := TInstantFireDACResolver.Create(Self, Map);
end;

function TInstantFireDACBroker.DataTypeToColumnType(DataType: TInstantDataType;
  Size: Integer): string;
begin
  Result := InternalDataTypeToColumnType(DataType);
  if (DataType = dtString) and (Size > 0) then
    Result := Result + InstantEmbrace(IntToStr(Size), '()');
end;

function TInstantFireDACBroker.DBNotExistsErrorCode: Integer;
begin
  Result := InternalDBNotExistsErrorCode;
end;

function TInstantFireDACBroker.Execute(const AStatement: string;
  AParams: TParams): Integer;
var
  DataSet: TFDQuery;
begin
  DataSet := AcquireDataSet(AStatement,AParams) as TFDQuery;
  try
    DataSet.ExecSQL;
    Result := DataSet.RowsAffected;
  finally
    ReleaseDataSet(DataSet);
  end;
end;

function TInstantFireDACBroker.GetConnector: TInstantFireDACConnector;
begin
  Result := inherited Connector as TInstantFireDACConnector;
end;

function TInstantFireDACBroker.GetDatabaseName: string;
begin
  Result := Connector.ParamByName('Database');
end;

function TInstantFireDACBroker.GetDBMSName: string;
begin
  Result := Connector.Connection.DriverName;
end;

function TInstantFireDACBroker.GetSQLDelimiters: string;
var
  LeftCh : char;
  RightCh : char;
begin
  if not Connector.UseDelimitedIdents then
    Result := ''
  else
  begin
    with Connector.Connection do
    begin
      LeftCh  := ConnectionMetaDataIntf.NameQuoteChar[ncDefault, nsLeft];
      RightCh := ConnectionMetaDataIntf.NameQuoteChar[ncDefault, nsRight];
    end;

    if (LeftCh = #0) or (RightCh = #0) or (LeftCh = ' ') or (RightCh = ' ') then
      Result := '' else
      Result := LeftCh + RightCh;
  end;
end;

function TInstantFireDACBroker.GetSQLQuote: Char;
begin
  Result := '''';
end;

procedure TInstantFireDACBroker.InternalCreateDatabase;
begin
  raise EInstantError.CreateFmt(SDatabaseCreationNotSupported, [GetDBMSName]);
end;

function TInstantFireDACBroker.InternalCreateQuery: TInstantQuery;
begin
  if UseBooleanFields then
    Result := TInstantSQLQuery.Create(Connector) else
    Result := TInstantFireDACQuery.Create(Connector);
end;

function TInstantFireDACBroker.InternalDBNotExistsErrorCode: Integer;
begin
  Result := 0;
end;

{ TInstantFireDACResolver }

function TInstantFireDACResolver.ReadBooleanField(DataSet: TDataSet;
  const FieldName: string): Boolean;
begin
  Result := (DataSet.FieldByName(FieldName).AsInteger <> 0);
end;

{ TInstantFireDACTranslator }

function TInstantFireDACTranslator.TranslateConstant(
  Constant: TInstantIQLConstant; Writer: TInstantIQLWriter): Boolean;
begin
  if SameText(Constant.Value, InstantTrueString) then
  begin
    Writer.WriteChar('1');
    Result := True;
  end
  else if SameText(Constant.Value, InstantFalseString) then
  begin
    Writer.WriteChar('0');
    Result := True;
  end
  else
    Result := inherited TranslateConstant(Constant, Writer);
end;

{ TInstantFireDACQuery }

class function TInstantFireDACQuery.TranslatorClass: TInstantRelationalTranslatorClass;
begin
  Result := TInstantFireDACTranslator;
end;

{ TInstantFireDACSybaseBroker }

{$IFDEF SYBASE_SUPPORT}
function TInstantFireDACSybaseBroker.InternalDataTypeToColumnType(
  DataType: TInstantDataType): string;
const
  Types: array[TInstantDataType] of string = (
    'INTEGER',
    'DOUBLE PRECISION',
    'MONEY',
    'TINYINT',
    'VARCHAR',
    'TEXT',
    'DATETIME',
    'IMAGE',
    'DATETIME',
    'DATETIME',
    'INTEGER');
begin
  Result := Types[DataType];
end;

function TInstantFireDACSybaseBroker.UseBooleanFields: Boolean;
begin
  Result := False;
end;
{$ENDIF}

{ TInstantFireDACMSSQLBroker }

{$IFDEF MSSQL_SUPPORT}
function TInstantFireDACMSSQLBroker.InternalDataTypeToColumnType(
  DataType: TInstantDataType): string;
const
  Types: array[TInstantDataType] of string = (
    'INTEGER',
    'FLOAT',
    'MONEY',
    'BIT',
    'VARCHAR',
    'TEXT',
    'DATETIME',
    'IMAGE',
    'DATETIME',
    'DATETIME',
    'INTEGER');
begin
  Result := Types[DataType];
end;

function TInstantFireDACMSSQLBroker.UseBooleanFields: Boolean;
begin
  Result := True;
end;

function TInstantFireDACMSSQL2005Broker.InternalDataTypeToColumnType(
  DataType: TInstantDataType): string;
const
  Types: array[TInstantDataType] of string = (
    'INTEGER',
    'FLOAT',
    'MONEY',
    'BIT',
    'VARCHAR',
    'VARBINARY(MAX)',
    'DATETIME',
    'VARCHAR(MAX)',
    'DATETIME',
    'DATETIME',
    'INTEGER');
begin
  Result := Types[DataType];
end;
{$ENDIF}

{ TInstantFireDACIbFbBroker }

{$IFDEF IBFB_SUPPORT}
procedure TInstantFireDACIbFbBroker.InternalCreateDatabase;
var
  OldProperties : string;
  CharacterSet  : string;
  PageSizeStr   : string;
  PageSize      : integer;
const
  DEFAULT_DB_PAGESIZE = 8192;
begin
  // do not call inherited
  with Connector do
    begin
      OldProperties := Connection.Params.Text;

      try
        CharacterSet := trim(Connection.Params.Values['CharacterSet']);
        PageSizeStr := trim(Connection.Params.Values['PageSize']);

        if (CharacterSet = '') then
          CharacterSet := 'UTF8';

        if (PageSizeStr <> '') then
          begin
            PageSize := StrToIntDef(PageSizeStr,-1);
            if (PageSize <> 1024) and // Deprecated for FB 2.1+
               (PageSize <> 2048) and // Deprecated for FB 2.1+
               (PageSize <> 4096) and
               (PageSize <> 8192) and
               (PageSize <> 16384) then // Available FB 2.0 and later
              raise EInstantError.CreateFmt(SInvalidDatabasePageSize, [PageSizeStr]);
          end else
          begin
            PageSize := DEFAULT_DB_PAGESIZE;
          end;

        Connection.Params.Values['CharacterSet'] := CharacterSet;
        Connection.Params.Values['CreateDatabase'] := 'Yes';
        Connection.Params.Values['SQLDialect'] := '3';
        Connection.Params.Values['PageSize'] := IntToStr(PageSize);
        Connect;
        Disconnect;
      finally
        Connection.Params.Text := OldProperties;
      end;
    end;
end;

function TInstantFireDACIbFbBroker.InternalDataTypeToColumnType(DataType: TInstantDataType): string;
const
  Types: array[TInstantDataType] of string = (
    'INTEGER',
    'DOUBLE PRECISION',
    'DECIMAL(14,4)',
    'SMALLINT',
    'VARCHAR',
    'BLOB SUB_TYPE 1',
    'TIMESTAMP',
    'BLOB',
    'TIMESTAMP',
    'TIMESTAMP',
    'INTEGER');
begin
  Result := Types[DataType];
end;

function TInstantFireDACIbFbBroker.InternalDBNotExistsErrorCode: Integer;
begin
  Result := -902;
end;

function TInstantFireDACIbFbBroker.UseBooleanFields: Boolean;
begin
  Result := False;
end;
{$ENDIF}

{ TInstantFireDACOracleBroker }

{$IFDEF ORACLE_SUPPORT}
function TInstantFireDACOracleBroker.InternalDataTypeToColumnType(
  DataType: TInstantDataType): string;
const
  Types: array[TInstantDataType] of string = (
    'NUMBER(10)',
    'FLOAT',
    'NUMBER(14,4)',
    'NUMBER(1)',
    'VARCHAR2',
    'CLOB',
    'DATE',
    'BLOB',
    'DATE',
    'DATE',
    'INTEGER');
begin
  Result := Types[DataType];
end;

function TInstantFireDACOracleBroker.UseBooleanFields: Boolean;
begin
  Result := False;
end;
{$ENDIF}

{ TInstantFireDACPgSQLBroker }

{$IFDEF PGSQL_SUPPORT}
function TInstantFireDACPgSQLBroker.InternalDataTypeToColumnType(DataType: TInstantDataType): string;
const
  Types: array[TInstantDataType] of string = (
    'INTEGER',
    'FLOAT8',
    'DECIMAL(14,4)',
    'BOOLEAN',
    'VARCHAR',
    'TEXT',
    'TIMESTAMP',
    'BYTEA',
    'TIMESTAMP',
    'TIMESTAMP',
    'INTEGER');
begin
  Result := Types[DataType];
end;

function TInstantFireDACPgSQLBroker.UseBooleanFields: Boolean;
begin
  Result := True;
end;
{$ENDIF}

{$IFDEF MYSQL_SUPPORT}

{ TInstantMySQLGenerator }

function TInstantMySQLGenerator.InternalGenerateDropIndexSQL(Metadata: TInstantIndexMetadata): string;
begin
  Result := Format('ALTER TABLE %s DROP INDEX %s',
   [Metadata.TableMetadata.Name, Metadata.Name]);
end;

{ TInstantFireDACMySQLBroker }

class function TInstantFireDACMySQLBroker.GeneratorClass: TInstantSQLGeneratorClass;
begin
  Result := TInstantMySQLGenerator;
end;

function TInstantFireDACMySQLBroker.InternalDataTypeToColumnType(DataType: TInstantDataType): string;
const
  Types: array[TInstantDataType] of string = (
    'INTEGER',
    'FLOAT',
    'DECIMAL(14,4)',
    'BOOL',
    'VARCHAR',
    'TEXT',
    'DATETIME',
    'BLOB',
    'DATE',
    'TIME',
    'INTEGER');
begin
  Result := Types[DataType];
end;

function TInstantFireDACMySQLBroker.InternalDBNotExistsErrorCode: Integer;
begin
  Result := 1049;
end;

function TInstantFireDACMySQLBroker.UseBooleanFields: Boolean;
begin
  Result := False;
end;
{$ENDIF}

{$IFDEF SQLITE_SUPPORT}

{ TInstantDBBuildAlterTableSQLCommand }

destructor TInstantDBBuildSQLiteAlterTableSQLCommand.Destroy;
begin
  FNewTableMetadata.Free;
  FTmpTableMD.Free;
  FScheme.Free;
  inherited;
end;

function TInstantDBBuildSQLiteAlterTableSQLCommand.GetDescription: string;
begin
  with Broker.Generator do
    case CommandType of
      ctAddField:
        Result := GenerateAddFieldSQL(NewMetadata as TInstantFieldMetadata);
      ctAlterField:
        Result := GenerateAlterFieldSQL(OldMetadata as TInstantFieldMetadata,
          NewMetadata as TInstantFieldMetadata);
      ctDropField:
        Result := GenerateDropFieldSQL(OldMetadata as TInstantFieldMetadata);
    end;
    Result := Result + ' - emulated with multi-statement SQL.';
end;

function TInstantDBBuildSQLiteAlterTableSQLCommand.GetNewTableMetadata: TInstantTableMetadata;
begin
  if not Assigned(FNewTableMetadata) then
  begin
    FNewTableMetadata := TInstantTableMetadata.Create(OldTableMetadata.Collection);
    FNewTableMetadata.Assign(OldTableMetadata);
    case CommandType of
      ctAddField:
        FNewTableMetadata.FieldMetadatas.Add.Assign(NewMetadata);
      ctAlterField:
      begin
        with FNewTableMetadata.FieldMetadatas do
          Remove(Find(OldMetadata.Name));
        FNewTableMetadata.FieldMetadatas.Add.Assign(NewMetadata);
      end;
      ctDropField:
        with FNewTableMetadata.FieldMetadatas do
          Remove(Find(OldMetadata.Name));
    end;
  end;
  Result := FNewTableMetadata;
end;

function TInstantDBBuildSQLiteAlterTableSQLCommand.GetOldTableMetadata: TInstantTableMetadata;
var
  FieldMetadata : TInstantFieldMetadata;
begin
  if not Assigned(FOldTableMetadata) then
  begin
    //Force to read the table from database
    FScheme := Broker.ReadDatabaseScheme(nil);

    FieldMetadata := nil;
    case CommandType of
      ctDropField, ctAlterField:
        FieldMetadata := TInstantFieldMetadata(OldMetadata);
      ctAddField:
        FieldMetadata := TInstantFieldMetadata(NewMetadata);
    end;

    { TODO : This only works for case-insensitive object names! }
    FOldTableMetadata :=
      FScheme.FindTableMetadata(AnsiUpperCase(FieldMetadata.TableMetadata.Name));
  end;
  Result := FOldTableMetadata;
end;

function TInstantDBBuildSQLiteAlterTableSQLCommand.GetSQLStatement(const Index: Integer): string;

  function CreateTmpTableMetadata(TableMetadata: TInstantTableMetadata):
      TInstantTableMetadata;
  begin
    Result := TInstantTableMetadata.Create(TableMetadata.Collection);
    Result.Assign(TableMetadata);
    Result.Name := TableMetadata.Name + STmpTableSuffix;
  end;

begin
  Result := inherited GetSQLStatement(Index);

  if not Assigned(FTmpTableMD) then
    FTmpTableMD := CreateTmpTableMetadata(OldTableMetadata);

  with TInstantSQLiteGenerator(Broker.Generator) do
    case Index of
      0: Result := GenerateCreateTempTableSQL(FTmpTableMD);
      1: Result := GenerateInsertFromSelectSQL(OldTableMetadata, FTmpTableMD);
      2: Result := GenerateDropTableSQL(OldTableMetadata);
      3: Result := GenerateCreateTableSQL(NewTableMetadata);
      4: Result := GenerateInsertFromSelectSQL(FTmpTableMD, NewTableMetadata);
      5: Result := GenerateDropTableSQL(FTmpTableMD);
    end;
end;

function TInstantDBBuildSQLiteAlterTableSQLCommand.GetSQLStatementCount: Integer;
begin
  Result := 6;
end;

procedure TInstantDBBuildSQLiteAlterTableSQLCommand.InternalExecute;
var
  iStatement: Integer;
  InTransaction: Boolean;
begin
  InTransaction := false;
  try
    for iStatement := 0 to Pred(GetSQLStatementCount) do
    begin
      Broker.Execute(GetSQLStatement(iStatement));
      InTransaction := (iStatement > 2) and (iStatement < 5);
    end;
  except
    if InTransaction then Rollback;
    raise;
  end;
end;

procedure TInstantDBBuildSQLiteAlterTableSQLCommand.Rollback;
begin
  { TODO : Some DBMS supports data definition within transactions,
    If FireDAC knows that then the follow code is unnecessary! }
  with Broker, TInstantSQLiteGenerator(Broker.Generator) do
  begin
    try
      Execute(GenerateDropTableSQL(NewTableMetadata));
    except
      //Safe if NewTable doesn�t exist
    end;
    Execute(GenerateCreateTableSQL(OldTableMetadata));
    Execute(GenerateInsertFromSelectSQL(FTmpTableMD, OldTableMetadata));
    Execute(GenerateDropTableSQL(FTmpTableMD));
  end;
end;

{ TInstantSQLiteGenerator }

function TInstantSQLiteGenerator.GenerateCreateTempTableSQL(
  Metadata: TInstantTableMetadata): string;
begin
  Result := InternalGenerateCreateTempTableSQL(Metadata);
end;

function TInstantSQLiteGenerator.GenerateInsertFromSelectSQL(
  const SourceMetadata, TargetMetadata: TInstantTableMetadata): string;
begin
  Result := InternalGenerateInsertFromSelectSQL(SourceMetadata, TargetMetadata);
end;

function TInstantSQLiteGenerator.InternalGenerateCreateTempTableSQL(
  Metadata: TInstantTableMetadata): string;
begin
  Result := InternalGenerateCreateTableSQL(Metadata);
  Insert('TEMP ', Result, Pos('TABLE', Result));
end;

function TInstantSQLiteGenerator.InternalGenerateInsertFromSelectSQL(
  const SourceMetadata, TargetMetadata: TInstantTableMetadata): string;
var
  i: Integer;
  TargetField : TInstantFieldMetadata;
  FieldList : string;
begin
  for i := 0 to Pred(TargetMetadata.FieldMetadatas.Count) do
  begin
    TargetField := TargetMetadata.FieldMetadatas[i];
    { TODO : This only works for case-insensitive object names! }
    if SourceMetadata.FieldMetadatas.IndexOf(AnsiUpperCase(TargetField.Name)) > -1 then
      FieldList := FieldList + EmbraceField(TargetField.Name) + ', ';
  end;
  Delete(FieldList, Length(FieldList) - 1, 2);
  Result := Format('INSERT INTO %s(%s) SELECT %s FROM %s',
    [TargetMetadata.Name, FieldList, FieldList, SourceMetadata.Name]);
end;

{ TInstantFireDACSQLiteBroker }

function TInstantFireDACSQLiteBroker.CreateDBBuildCommand(
  const CommandType: TInstantDBBuildCommandType): TInstantDBBuildCommand;
begin
  case CommandType of
    ctAddField, ctAlterField, ctDropField:
      Result := TInstantDBBuildSQLiteAlterTableSQLCommand.Create(CommandType, Connector)
    else
      Result := inherited CreateDBBuildCommand(CommandType);
  end;
end;

class function TInstantFireDACSQLiteBroker.GeneratorClass:
  TInstantSQLGeneratorClass;
begin
  Result := TInstantSQLiteGenerator;
end;

function TInstantFireDACSQLiteBroker.InternalDataTypeToColumnType(
  DataType: TInstantDataType): string;
const
  Types: array[TInstantDataType] of string = (
    'INTEGER',
    'FLOAT',
    'NUMERIC(14,4)',
    'BOOLEAN',
    'VARCHAR',
    'TEXT',
    'TIMESTAMP',
    'BLOB',
    'TIMESTAMP',
    'TIMESTAMP',
    'INTEGER');
begin
  Result := Types[DataType];
end;

function TInstantFireDACSQLiteBroker.UseBooleanFields: Boolean;
begin
  Result := True;
end;
{$ENDIF}

initialization
  RegisterClass(TInstantFireDACConnectionDef);
  TInstantFireDACConnector.RegisterClass;
  {$IFDEF D5}
  if (not assigned(LoginDialogProc)) then
    LoginDialogProc := LoginDialogProcCompatibility;
  {$ENDIF}

finalization
  TInstantFireDACConnector.UnregisterClass;

end.
