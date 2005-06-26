(*
 *   InstantObjects
 *   Connection Manager Component
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
 * Contributor(s): Carlo Barazzetta
 *
 * ***** END LICENSE BLOCK ***** *)

unit InstantConnectionManager;

{$I InstantDefines.inc}

{$IFDEF D7+}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CAST OFF}
{$WARN UNSAFE_CODE OFF}
{$ENDIF}

interface

uses
  SysUtils, Classes,
{$IFDEF MSWINDOWS}
  Windows,  
{$ENDIF}
{$IFDEF LINUX}
  QTypes, 
{$ENDIF}
  InstantClasses, InstantPersistence;

type
  TInstantConnectionManagerActionType = (atNew, atEdit, atDelete, atRename,
    atConnect, atDisconnect, atBuild, atOpen);
  TInstantConnectionManagerActionTypes = set of TInstantConnectionManagerActionType;

  TInstantConnectionDefEvent = procedure(Sender: TObject;
    var ConnectionDef: TInstantConnectionDef; var Result: Boolean) of object;
  TInstantConnectorEvent = procedure(Sender: TObject;
    Connector: TInstantConnector) of object;
  TInstantConnectorClassEvent = procedure(Sender: TObject;
    ConnectorClass: TInstantConnectorClass; var Result: Boolean) of object;

  TInstantConnectionManager = class;
  TInstantConnectionManagerExecutor = procedure (ConnectionManager: TInstantConnectionManager);

  TInstantConnectionManager = class(TComponent)
  private
    FCaption: string;
    FFileName: string;
    FFileFormat: TInstantStreamFormat;
    FModel: TInstantModel;
    FOnBuild: TInstantConnectionDefEvent;
    FOnConnect: TInstantConnectionDefEvent;
    FOnDisconnect: TInstantConnectionDefEvent;
    FOnEdit: TInstantConnectionDefEvent;
    FOnIsConnected: TInstantConnectionDefEvent;
    FOnPrepare: TInstantConnectorEvent;
    FOnSupportConnector: TInstantConnectorClassEvent;
    FVisibleActions: TInstantConnectionManagerActionTypes;
    FConnectionDefs: TInstantConnectionDefs;
    function GetConnectionDefs: TInstantConnectionDefs;
    function GetModel: TInstantModel;
    procedure SetFileName(const Value: string);
    procedure SetFileFormat(const Value: TInstantStreamFormat);
    procedure SetModel(Value: TInstantModel);
    procedure SetOnBuild(Value: TInstantConnectionDefEvent);
    procedure SetOnConnect(Value: TInstantConnectionDefEvent);
    procedure SetOnDisconnect(Value: TInstantConnectionDefEvent);
    procedure SetOnEdit(Value: TInstantConnectionDefEvent);
    procedure SetOnIsConnected(Value: TInstantConnectionDefEvent);
    procedure SetOnPrepare(Value: TInstantConnectorEvent);
    procedure SetOnSupportConnector(Value: TInstantConnectorClassEvent);
    procedure SetVisibleActions(Value: TInstantConnectionManagerActionTypes);
    procedure SetCaption(const Value: string);
    function GetDefsFileName: string;
  protected
    property DefsFileName: string read GetDefsFileName;
    // Creates and returns a stream to read the connectiondefs data from.
    // If there is nothing to read, it should return nil.
    // The caller is responsible for freeing the stream after using it.
    // The default implementation just creates a TFileStream that opens
    // DefsFileName for reading. If DefsFileName does not exist, then it returns
    // nil.
    // An overridden implementation might get the data from an encrypted file or
    // a completely different source.
    function CreateConnectionDefsInputStream(): TStream; virtual;
    // Creates and returns a stream to write the connectiondefs data to.
    // If there is nothing to write to, it should return nil.
    // The caller is responsible for freeing the stream after using it.
    // The default implementation just creates a TFileStream that opens
    // DefsFileName for writing. If DefsFileName is not specified, then it
    // returns nil.
    // An overridden implementation might write the data to an encrypted file
    // or a completely different destination.
    function CreateConnectionDefsOutputStream(): TStream; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadConnectionDefs;
    procedure SaveConnectionDefs;
    procedure ConnectByName(const ConnectionDefName: string);
    procedure Execute;
    function IsConnected: Boolean;
    property Model: TInstantModel read GetModel write SetModel;
    property ConnectionDefs: TInstantConnectionDefs read GetConnectionDefs;
  published
    property Caption: string read FCaption write SetCaption;
    property FileName: string read FFileName write SetFileName;
    property FileFormat : TInstantStreamFormat
      read FFileFormat write SetFileFormat default sfBinary;
    property VisibleActions: TInstantConnectionManagerActionTypes
      read FVisibleActions write SetVisibleActions
      default [atNew, atEdit, atDelete, atRename, atConnect, atDisconnect, atBuild, atOpen];
    property OnBuild: TInstantConnectionDefEvent read FOnBuild write SetOnBuild;
    property OnConnect: TInstantConnectionDefEvent read FOnConnect write SetOnConnect;
    property OnDisconnect: TInstantConnectionDefEvent
      read FOnDisconnect write SetOnDisconnect;
    property OnEdit: TInstantConnectionDefEvent read FOnEdit write SetOnEdit;
    property OnIsConnected: TInstantConnectionDefEvent
      read FOnIsConnected write SetOnIsConnected;
    property OnPrepare: TInstantConnectorEvent read FOnPrepare write SetOnPrepare;
    property OnSupportConnector: TInstantConnectorClassEvent
      read FOnSupportConnector write SetOnSupportConnector;
  end;

procedure RegisterConnectionManagerExecutor(ConnectionManagerExecutor: TInstantConnectionManagerExecutor);

implementation

uses
  InstantConsts;

var
  _ConnectionManagerExecutor: TInstantConnectionManagerExecutor;

procedure RegisterConnectionManagerExecutor(ConnectionManagerExecutor: TInstantConnectionManagerExecutor);
begin
  _ConnectionManagerExecutor := ConnectionManagerExecutor;
end;

{ TInstantConnectionManager }

constructor TInstantConnectionManager.Create(AOwner: TComponent);
begin
  inherited;
  FVisibleActions := [atNew, atEdit, atDelete, atRename, atConnect,
    atDisconnect, atBuild, atOpen];
  FFileFormat := sfBinary;
end;

function TInstantConnectionManager.GetModel: TInstantModel;
begin
  Result := FModel;
  if not Assigned(FModel) then
    Result := InstantModel;
end;

procedure TInstantConnectionManager.SetFileName(const Value: string);
begin
  if Value <> FFileName then
  begin
    if SameText(ExtractFileExt(Value), '.xml') then
      FFileFormat := sfXML
    else
      FFileFormat := sfBinary;
    FFileName := Value;
    LoadConnectionDefs;
  end;
end;

procedure TInstantConnectionManager.SetFileFormat(
  const Value: TInstantStreamFormat);
begin
  FFileFormat := Value;
end;

procedure TInstantConnectionManager.SetModel(Value: TInstantModel);
begin
  FModel := Value;
end;

procedure TInstantConnectionManager.SetOnBuild(
  Value: TInstantConnectionDefEvent);
begin
  FOnBuild := Value;
end;

procedure TInstantConnectionManager.SetOnConnect(
  Value: TInstantConnectionDefEvent);
begin
  FOnConnect := Value;
end;

procedure TInstantConnectionManager.SetOnDisconnect(
  Value: TInstantConnectionDefEvent);
begin
  FOnDisconnect := Value;
end;

procedure TInstantConnectionManager.SetOnEdit(
  Value: TInstantConnectionDefEvent);
begin
  FOnEdit := Value;
end;

procedure TInstantConnectionManager.SetOnIsConnected(
  Value: TInstantConnectionDefEvent);
begin
  FOnIsConnected := Value;
end;

procedure TInstantConnectionManager.SetOnPrepare(
  Value: TInstantConnectorEvent);
begin
  FOnPrepare := Value;
end;

procedure TInstantConnectionManager.SetOnSupportConnector(
  Value: TInstantConnectorClassEvent);
begin
  FOnSupportConnector := Value;
end;

procedure TInstantConnectionManager.SetVisibleActions(
  Value: TInstantConnectionManagerActionTypes);
begin
  FVisibleActions := Value;
end;

procedure TInstantConnectionManager.ConnectByName(const ConnectionDefName: string);
var
  Result: Boolean;
  ConnectionDef : TInstantConnectionDef;
begin
  LoadConnectionDefs;
  ConnectionDef := ConnectionDefs.Find(ConnectionDefName) as TInstantConnectionDef;
  if Assigned(ConnectionDef) then
    OnConnect(Self, ConnectionDef, Result)
  else
    raise EInstantError.CreateFmt(SConnectionDefError, [ConnectionDefName, FileName]);
end;

destructor TInstantConnectionManager.Destroy;
begin
  FConnectionDefs.Free;
  inherited;
end;

function TInstantConnectionManager.GetConnectionDefs: TInstantConnectionDefs;
begin
  if not Assigned(FConnectionDefs) then
    FConnectionDefs := TInstantConnectionDefs.Create;
  Result := FConnectionDefs;
end;

procedure TInstantConnectionManager.LoadConnectionDefs;
var
  InputStream: TStream;
begin
  try
    InputStream := CreateConnectionDefsInputStream();
    try
      if Assigned(InputStream) then
        InstantReadObject(InputStream, FileFormat, ConnectionDefs);
    finally
      InputStream.Free;
    end;
  except
    on E: Exception do
      raise EInstantError.CreateFmt(SErrorLoadingConnectionDefs,
        [DefsFileName, E.Message]);
  end;
end;

procedure TInstantConnectionManager.SaveConnectionDefs;
var
  OutputStream: TStream;
begin
  OutputStream := CreateConnectionDefsOutputStream();
  try
    if Assigned(OutputStream) then
      InstantWriteObject(OutputStream, FileFormat, ConnectionDefs);
  finally
    OutputStream.Free;
  end;
end;

function TInstantConnectionManager.GetDefsFileName: string;
var
  Path: string;
begin
  if FileName <> '' then
  begin
    Path := ExtractFilePath(FileName);
    if Path = '' then
      Result := ExtractFilePath(ParamStr(0)) + FileName
    else
      Result := FileName;
  end
  else
    Result := '';
end;

procedure TInstantConnectionManager.Execute;
begin
  if Assigned(_ConnectionManagerExecutor) then
    _ConnectionManagerExecutor(Self)
  else
    // WARNING:
    // If you want to use the default ConnectionManagerForm (as in previous versions of IO)
    // simply add InstantConnectionManagerForm in an uses section of your application.
    raise EInstantError.Create(SConnectionManagerExecutorNotAssigned);
end;

procedure TInstantConnectionManager.SetCaption(const Value: string);
begin
  FCaption := Value;
end;

function TInstantConnectionManager.IsConnected: Boolean;
var
  i: Integer;
  ConnectionDef: TInstantConnectionDef;
begin
  Result := False;
  if not Assigned(OnIsConnected) then
    Exit;
  for i := 0 to Pred(ConnectionDefs.Count) do
  begin
    ConnectionDef := ConnectionDefs.Items[i];
    OnIsConnected(Self, ConnectionDef, Result);
    if Result then
      Break;
  end;
end;

function TInstantConnectionManager.CreateConnectionDefsInputStream: TStream;
begin
  if FileExists(DefsFileName) then
    Result := TFileStream.Create(DefsFileName, fmOpenRead)
  else
    Result := nil;
end;

function TInstantConnectionManager.CreateConnectionDefsOutputStream: TStream;
begin
  if DefsFileName <> '' then
    Result := TFileStream.Create(DefsFileName, fmCreate)
  else
    Result := nil;
end;

end.
