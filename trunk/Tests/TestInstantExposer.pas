﻿(*
 *   InstantObjects Test Suite
 *   TestMockBroker
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
 * The Original Code is: InstantObjects Test Suite/TestMockBroker
 *
 * The Initial Developer of the Original Code is: Uberto Barbini
 *
 * Portions created by the Initial Developer are Copyright (C) 2005
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * Nando Dessena
 *
 * ***** END LICENSE BLOCK ***** *)

unit TestInstantExposer;

interface

uses
  fpcunit, testregistry, InstantXML, InstantPresentation;

type
  TTestExposer = class(TTestCase)
  private
  protected
    FConn: TInstantXMLConnector;
    FAcc: TXMLFilesAccessor;
    FExp: TInstantExposer;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestStoreAndRetrieveContact;
    procedure TestStoreAndRetrieveContactPhones;
//    procedure TestOrderBy;
    procedure FieldSetValue;
  end;

implementation

uses
  SysUtils, ShellAPI, InstantPersistence, TestModel, DB;

{ TTestXMLBroker }

procedure TTestExposer.SetUp;
begin
  FAcc := TXMLFilesAccessor.Create(nil);
  FAcc.RootFolder := ExtractFilePath(ParamStr(0)) + 'XMLDB';
  ForceDirectories(FAcc.RootFolder);
  FConn := TInstantXMLConnector.Create(nil);
  FConn.Connection := FAcc;
  FConn.IsDefault := True;
  FConn.UseUnicode := TestModel.TestUseUnicode;
  FExp := TInstantExposer.Create(nil);

  if InstantModel.ClassMetadatas.Count > 0 then
    InstantModel.ClassMetadatas.Clear;
  InstantModel.LoadFromResFile(ChangeFileExt(ParamStr(0), '.mdr'));
end;

procedure TTestExposer.TearDown;

  function DelTree(DirName: string): Boolean;
  var
    SHFileOpStruct : TSHFileOpStruct;
  begin
    try
      Fillchar(SHFileOpStruct,Sizeof(SHFileOpStruct),0) ;
      with SHFileOpStruct do begin
        Wnd := 0;
        pFrom := PChar(ExcludeTrailingPathDelimiter(DirName) + #0);
        wFunc := FO_DELETE;
        fFlags := FOF_ALLOWUNDO;
        fFlags := fFlags or FOF_NOCONFIRMATION;
        fFlags := fFlags or FOF_SILENT;
       end;
       Result := (SHFileOperation(SHFileOpStruct) = 0) ;
    except
      Result := False;
    end;
  end;

begin
  inherited;
  InstantModel.ClassMetadatas.Clear;
  FreeAndNil(FExp);
  FreeAndNil(FConn);
//  DelTree(FAcc.RootFolder);
  FreeAndNil(FAcc);
end;

procedure TTestExposer.TestStoreAndRetrieveContact;
const
  DEF_NAME = 'AName';
  DEF_NAME_UNICODE = '网站导航';
  DEF_CITY = 'Milan (€)';
  ADDRESS_STREET = 'Street';
  ADDRESS_STREET_UNICODE = '链接';
var
  c: TContact;
  old_id: string;
  t: TPhone;
  DataSetField: TDataSetField;
  Field: TField;
begin
  FExp.ObjectClass := TContact;
  c := TContact.Create;
  try
    FExp.Subject := c;
    FExp.Edit;
    Field := FExp.FieldByName('Name');
    if not FConn.UseUnicode then
    begin
      Field.Value := DEF_NAME;
      AssertEquals(DEF_NAME, c.Name);
    end
    else
    begin
      Field.Value := DEF_NAME_UNICODE;
      AssertEquals(DEF_NAME_UNICODE, c.Name);
    end;
    Field := FExp.FieldByName('Address.City');
    Field.Value := DEF_CITY;
    AssertEquals(DEF_CITY, c.Address.City);
    Field := FExp.FieldByName('Address.Street');
    if not FConn.UseUnicode then
    begin
      Field.Value := ADDRESS_STREET;
      AssertEquals(ADDRESS_STREET, c.Address.Street);
    end
    else
    begin
      Field.Value := ADDRESS_STREET_UNICODE;
      AssertEquals(ADDRESS_STREET_UNICODE, c.Address.Street);
    end;
    FExp.Post;
    if not FConn.UseUnicode then
    begin
      AssertEquals(DEF_NAME, c.Name);
      AssertEquals(DEF_CITY, c.Address.City);
      AssertEquals(ADDRESS_STREET, c.Address.Street);
    end
    else
    begin
      AssertEquals(DEF_NAME_UNICODE, c.Name);
      AssertEquals(DEF_CITY, c.Address.City);
      AssertEquals(ADDRESS_STREET_UNICODE, c.Address.Street);
    end;
    old_id := c.id;
  finally
    FreeAndNil(c);
  end;
  AssertNull(c);
  c := TContact.Retrieve(old_id);
  try
    AssertNotNull('Object not retrieved', c);
    AssertEquals(old_id, c.Id);
    if not FConn.UseUnicode then
    begin
      AssertEquals(DEF_NAME, c.Name);
      AssertEquals(DEF_CITY, c.Address.City);
      AssertEquals(ADDRESS_STREET, c.Address.Street);
    end
    else
    begin
      AssertEquals(DEF_NAME_UNICODE, c.Name);
      AssertEquals(DEF_CITY, c.Address.City);
      AssertEquals(ADDRESS_STREET_UNICODE, c.Address.Street);
    end;
    AssertNotNull(c.Address);
  finally
    FreeAndNil(c);
  end;
end;

procedure TTestExposer.FieldSetValue;
const
  DEF_NAME = 'AName';
  DEF_NAME_UNICODE = '链接';
var
  Field: TField;
  c: TContact;
begin
  FExp.ObjectClass := TContact;
  c := TContact.Create;
  try
    FExp.Subject := c;
    FExp.Edit;
    Field := FExp.FieldByName('Name');
    if not FConn.UseUnicode then
    begin
      Field.Value := DEF_NAME;
      AssertEquals(DEF_NAME, Field.Value);
    end
    else
    begin
      Field.Value := DEF_NAME_UNICODE;
      AssertEquals(DEF_NAME_UNICODE, Field.Value);
    end;
  finally
    FreeAndNil(c);
  end;
end;

procedure TTestExposer.TestStoreAndRetrieveContactPhones;
const
  DEF_NAME = 'AName';
  DEF_NAME_UNICODE = '链接';
  DEF_HOME = 'Home';
  DEF_OFFICE = 'Office';
  DEF_NUM_HOME  = '012 12345678';
  DEF_NUM_OFFICE = '012-234-56781';
var
  c: TContact;
  old_id: string;
  t: TPhone;
  DataSetField: TDataSetField;
  Field: TField;
begin
  FExp.ObjectClass := TContact;
  c := TContact.Create;
  try
    FExp.Subject := c;
    FExp.Edit;
    Field := FExp.FieldByName('Name');
    if not FConn.UseUnicode then
    begin
      Field.Value := DEF_NAME;
      AssertEquals(DEF_NAME, c.Name);
    end
    else
    begin
      Field.Value := DEF_NAME_UNICODE;
      AssertEquals(DEF_NAME_UNICODE, c.Name);
    end;
    Field := FExp.FieldByName('Address.City');
    DataSetField := FExp.FieldByName('Phones') as TDataSetField;
    DataSetField.NestedDataSet.Append;
    DataSetField.NestedDataSet.FieldByName('Name').Value := DEF_HOME;
    DataSetField.NestedDataSet.FieldByName('Number').Value := DEF_NUM_HOME;
    DataSetField.NestedDataSet.Post;
    AssertEquals(1, c.PhoneCount);
    DataSetField.NestedDataSet.Append;
    DataSetField.NestedDataSet.FieldByName('Name').Value := DEF_OFFICE;
    DataSetField.NestedDataSet.FieldByName('Number').Value := DEF_NUM_OFFICE;
    DataSetField.NestedDataSet.Post;
    AssertEquals(2, c.PhoneCount);
    FExp.Post;
    AssertEquals(2, c.PhoneCount);
//  AssertEquals(DEF_HOME, c.Phones[0].Name);
//  AssertEquals(DEF_NUM_HOME, c.Phones[0].Number);
//  AssertEquals(DEF_OFFICE, c.Phones[1].Name);
//  AssertEquals(DEF_NUM_OFFICE, c.Phones[1].Number);
    old_id := c.id;
  finally
    FreeAndNil(c);
  end;
  AssertNull(c);
  c := TContact.Retrieve(old_id);
  try
    AssertNotNull('Object not retrieved', c);
    AssertEquals(old_id, c.Id);
    if not FConn.UseUnicode then
      AssertEquals(DEF_NAME, c.Name)
    else
      AssertEquals(DEF_NAME_UNICODE, c.Name);
    AssertNotNull(c.Address);
    AssertEquals(2, c.PhoneCount);
//    AssertEquals(DEF_HOME, c.Phones[0].Name);
//    AssertEquals(DEF_NUM_HOME, c.Phones[0].Number);
//    AssertEquals(DEF_OFFICE, c.Phones[1].Name);
//    AssertEquals(DEF_NUM_OFFICE, c.Phones[1].Number);
  finally
    FreeAndNil(c);
  end;
end;

initialization
{$IFNDEF CURR_TESTS}
  RegisterTests([TTestExposer]);
{$ENDIF}
end.

