unit InstantIBFbCatalog;

interface

uses
  InstantPersistence;

type
  // A TInstantCatalog that reads catalog information from an InterBase
  // or Firebird database. Can be used with a SQL broker that accesses
  // InterBase or Firebird databases.
  TInstantIBFbCatalog = class(TInstantSQLBrokerCatalog)
  private
    procedure AddFieldMetadatas(TableMetadata: TInstantTableMetadata);
    procedure AddIndexMetadatas(TableMetadata: TInstantTableMetadata);
    procedure AddTableMetadatas(TableMetadatas: TInstantTableMetadatas);
    function ColumnTypeToDataType(const ColumnType: string;
      const BlobSubType, FieldScale: Integer): TInstantDataType;
    function GetSelectFieldsSQL(const ATableName: string): string;
    function GetSelectIndexesSQL(const ATableName: string): string;
    function GetSelectIndexFieldsSQL(const AIndexName: string): string;
    function GetSelectTablesSQL: string;
  public
    procedure InitTableMetadatas(ATableMetadatas: TInstantTableMetadatas);
      override;
  end;

implementation

uses
  SysUtils, Classes, DB;
  
{ TInstantIBFbCatalog }

procedure TInstantIBFbCatalog.AddIndexMetadatas(
  TableMetadata: TInstantTableMetadata);
var
  Indexes: TDataSet;
  IndexMetadata: TInstantIndexMetadata;

  function GetIndexFields(const IndexName: string): string;
  var
    IndexFieldList: TStrings;
    IndexFields: TDataSet;
  begin
    IndexFieldList := TStringList.Create;
    try
      IndexFields := Broker.AcquireDataSet(GetSelectIndexFieldsSQL(IndexName));
      try
        IndexFields.Open;
        try
          while not IndexFields.Eof do
          begin
            IndexFieldList.Add(Trim(IndexFields.FieldByName('RDB$FIELD_NAME').AsString));
            IndexFields.Next;
          end;
        finally
          IndexFields.Close;
        end;
      finally
        Broker.ReleaseDataSet(IndexFields);
      end;
      IndexFieldList.Delimiter := ';';
      Result := IndexFieldList.DelimitedText;
    finally
      IndexFieldList.Free;
    end;
  end;

begin
  Indexes := Broker.AcquireDataSet(GetSelectIndexesSQL(TableMetadata.Name));
  try
    Indexes.Open;
    try
      while not Indexes.Eof do
      begin
        IndexMetadata := TableMetadata.IndexMetadatas.Add;
        IndexMetadata.Name := Trim(Indexes.FieldByName('RDB$INDEX_NAME').AsString);
        IndexMetadata.Fields := GetIndexFields(IndexMetadata.Name);
        IndexMetadata.Options := [];
        if Pos('RDB$PRIMARY', Indexes.FieldByName('RDB$INDEX_NAME').AsString) = 1 then
          IndexMetadata.Options := IndexMetadata.Options + [ixPrimary, ixUnique]
        else if Indexes.FieldByName('RDB$UNIQUE_FLAG').AsInteger = 1 then
          IndexMetadata.Options := IndexMetadata.Options + [ixUnique];
        { TODO : support other Options? }
        Indexes.Next;
      end;
    finally
      Indexes.Close;
    end;
  finally
    Broker.ReleaseDataSet(Indexes);
  end;
end;

procedure TInstantIBFbCatalog.AddFieldMetadatas(
  TableMetadata: TInstantTableMetadata);
var
  Fields: TDataSet;
  FieldMetadata: TInstantFieldMetadata;
begin
  Fields := Broker.AcquireDataSet(GetSelectFieldsSQL(TableMetadata.Name));
  try
    Fields.Open;
    try
      while not Fields.Eof do
      begin
        FieldMetadata := TableMetadata.FieldMetadatas.Add;
        FieldMetadata.Name := Trim(Fields.FieldByName('RDB$FIELD_NAME').AsString);
        FieldMetadata.DataType := ColumnTypeToDataType(
          Trim(Fields.FieldByName('RDB$TYPE_NAME').AsString),
          Fields.FieldByName('RDB$FIELD_SUB_TYPE').AsInteger,
          Fields.FieldByName('RDB$FIELD_SCALE').AsInteger);
        FieldMetadata.Options := [];
        if Fields.FieldByName('RDB$NULL_FLAG').AsInteger <> 0 then
          FieldMetadata.Options := FieldMetadata.Options + [foRequired];
        if TableMetadata.IndexMetadatas.IsFieldIndexed(FieldMetadata) then
          FieldMetadata.Options := FieldMetadata.Options + [foIndexed];
        { TODO : support ExternalTableName? }
        if FieldMetadata.DataType = dtString then
          FieldMetadata.Size := Fields.FieldByName('RDB$CHARACTER_LENGTH').AsInteger
        else
          FieldMetadata.Size := Fields.FieldByName('RDB$FIELD_LENGTH').AsInteger;
        Fields.Next;
      end;
    finally
      Fields.Close;
    end;
  finally
    Broker.ReleaseDataSet(Fields);
  end;
end;

procedure TInstantIBFbCatalog.AddTableMetadatas(
  TableMetadatas: TInstantTableMetadatas);
var
  Tables: TDataSet;
  TableMetadata: TInstantTableMetadata;
begin
  Tables := Broker.AcquireDataSet(GetSelectTablesSQL());
  try
    Tables.Open;
    try
      while not Tables.Eof do
      begin
        TableMetadata := TableMetadatas.Add;
        TableMetadata.Name := Trim(Tables.FieldByName('RDB$RELATION_NAME').AsString);
        // Call AddIndexMetadatas first, so that AddFieldMetadatas can see what
        // indexes are defined to correctly set the foIndexed option.
        AddIndexMetadatas(TableMetadata);
        AddFieldMetadatas(TableMetadata);
        Tables.Next;
      end;
    finally
      Tables.Close;
    end;
  finally
    Broker.ReleaseDataSet(Tables);
  end;
end;

function TInstantIBFbCatalog.ColumnTypeToDataType(const ColumnType: string;
  const BlobSubType, FieldScale: Integer): TInstantDataType;
begin
  { TODO : How to use FieldScale? }
  if SameText(ColumnType, 'TEXT') or SameText(ColumnType, 'VARYING') then
    Result := dtString
  else if SameText(ColumnType, 'SHORT') or SameText(ColumnType, 'LONG') then
    Result := dtInteger
  else if SameText(ColumnType, 'FLOAT') or SameText(ColumnType, 'DOUBLE') then
    Result := dtFloat
  else if SameText(ColumnType, 'TIMESTAMP') or SameText(ColumnType, 'DATE')
      or SameText(ColumnType, 'TIME')then
    Result := dtDateTime
  else if SameText(ColumnType, 'BLOB') then
  begin
    if BlobSubType = 1 then
      Result := dtMemo
    else
      Result := dtBlob;
  end
  else
    raise Exception.CreateFmt('ColumnType %s not supported.', [ColumnType]);
end;

function TInstantIBFbCatalog.GetSelectFieldsSQL(
  const ATableName: string): string;
begin
  Result :=
    'select ' +
    '  RF.RDB$FIELD_NAME, RF.RDB$NULL_FLAG, ' +
    '  T.RDB$TYPE_NAME, F.RDB$FIELD_SUB_TYPE, F.RDB$FIELD_LENGTH, ' +
    '  F.RDB$FIELD_SCALE, F.RDB$CHARACTER_LENGTH ' +
    'from ' +
    '  RDB$RELATION_FIELDS RF ' +
    'join ' +
    '  RDB$FIELDS F ' +
    'on ' +
    '  RF.RDB$FIELD_SOURCE = F.RDB$FIELD_NAME ' +
    'join ' +
    '  RDB$TYPES T ' +
    'on ' +
    '  F.RDB$FIELD_TYPE = T.RDB$TYPE ' +
    '  and T.RDB$FIELD_NAME = ''RDB$FIELD_TYPE'' ' +
    'where ' +
    '  RF.RDB$RELATION_NAME = ''' + ATableName + ''' ' +
    'order by ' +
    '  RF.RDB$FIELD_POSITION';
end;

function TInstantIBFbCatalog.GetSelectIndexesSQL(
  const ATableName: string): string;
begin
  Result :=
    'select ' +
    '  RDB$INDEX_NAME, RDB$UNIQUE_FLAG ' +
    'from ' +
    '  RDB$INDICES ' +
    'where ' +
    '  RDB$RELATION_NAME = ''' + ATableName + ''' ' +
    'order by ' +
    '  RDB$INDEX_NAME';
end;

function TInstantIBFbCatalog.GetSelectIndexFieldsSQL(
  const AIndexName: string): string;
begin
  Result :=
    'select ' +
    '  RDB$FIELD_NAME ' +
    'from ' +
    '  RDB$INDEX_SEGMENTS ' +
    'where ' +
    '  RDB$INDEX_NAME = ''' + AIndexName + ''' ' +
    'order by ' +
    '  RDB$FIELD_POSITION';
end;

function TInstantIBFbCatalog.GetSelectTablesSQL: string;
begin
  Result :=
    'select ' +
    '  RDB$RELATION_NAME ' +
    'from ' +
    '  RDB$RELATIONS ' +
    'where ' +
    '  RDB$SYSTEM_FLAG = 0 ' +
    '  and RDB$VIEW_BLR is null ' +
    'order by ' +
    '  RDB$RELATION_NAME';
end;

procedure TInstantIBFbCatalog.InitTableMetadatas(
  ATableMetadatas: TInstantTableMetadatas);
begin
  ATableMetadatas.Clear;
  AddTableMetadatas(ATableMetadatas);
end;

end.
