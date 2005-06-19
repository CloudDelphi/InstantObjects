(*
 *   InstantObjects
 *   TestInstantAttribute
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
 * Steven Mitchell
 *
 * ***** END LICENSE BLOCK ***** *)

unit TestInstantAttribute;

interface

uses fpcunit, InstantPersistence, TestModel, InstantMock;

type

  // Test methods for class TInstantAttribute
  TestTInstantAttribute = class(TTestCase)
  private
    FConn: TInstantMockConnector;
    FInstantAttribute: TInstantString;
    FOwner: TContact;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestChange;
    procedure TestCheckHasMetadata;
    procedure TestDisplayText;
    procedure TestIsDefault;
    procedure TestIsIndexed;
    procedure TestIsMandatory;
    procedure TestIsRequired;
    procedure TestMetadata;
  end;

implementation

uses SysUtils, testregistry, InstantClasses;

procedure TestTInstantAttribute.SetUp;
begin
  FConn := TInstantMockConnector.Create(nil);
  FConn.BrokerClass := TInstantMockBroker;

  if InstantModel.ClassMetadatas.Count > 0 then
    InstantModel.ClassMetadatas.Clear;
  InstantModel.LoadFromResFile(ChangeFileExt(ParamStr(0), '.mdr'));

  FOwner := TContact.Create(FConn);
  FInstantAttribute := FOwner._Name;
end;

procedure TestTInstantAttribute.TearDown;
begin
  FInstantAttribute := nil;
  FreeAndNil(FOwner);
  InstantModel.ClassMetadatas.Clear;
  FreeAndNil(FConn);
end;

procedure TestTInstantAttribute.TestChange;
begin
  AssertFalse(FInstantAttribute.IsChanged);
  FInstantAttribute.Value := 'NewString';
  AssertTrue(FInstantAttribute.IsChanged);
  FInstantAttribute.UnChanged;
  AssertFalse(FInstantAttribute.IsChanged);
  FInstantAttribute.Changed;
  AssertTrue(FInstantAttribute.IsChanged);
end;

procedure TestTInstantAttribute.TestCheckHasMetadata;
begin
  try
    FInstantAttribute.CheckHasMetadata;
  except
    Fail('CheckHasMetadata failed!');
  end;

  FInstantAttribute.Metadata := nil;
  AssertException(EInstantError, FInstantAttribute.CheckHasMetadata);
end;

procedure TestTInstantAttribute.TestDisplayText;
begin
  FInstantAttribute.Value := 'StringValue';
  AssertEquals('StringValue', FInstantAttribute.DisplayText);

  FInstantAttribute.Metadata.EditMask := '!CCCCCC';
  AssertEquals('gValue', FInstantAttribute.DisplayText);

  FInstantAttribute.Value := 'NewString';
  FInstantAttribute.Metadata.EditMask := 'CCCCCC';
  AssertEquals('NewStr', FInstantAttribute.DisplayText);
end;

procedure TestTInstantAttribute.TestIsDefault;
begin
  AssertTrue(FInstantAttribute.IsDefault);

  FInstantAttribute.Value := 'NewString';
  AssertFalse(FInstantAttribute.IsDefault);
end;

procedure TestTInstantAttribute.TestIsIndexed;
begin
  AssertTrue(FInstantAttribute.IsIndexed);

  FInstantAttribute.Metadata.IsIndexed := False;
  AssertFalse(FInstantAttribute.IsIndexed);
end;

procedure TestTInstantAttribute.TestIsMandatory;
begin
  AssertTrue('1', FInstantAttribute.IsMandatory);
  FInstantAttribute.Metadata.IsIndexed := False;
  AssertFalse('2', FInstantAttribute.IsMandatory);

  FInstantAttribute.Metadata.IsRequired := True;
  AssertTrue('3', FInstantAttribute.IsMandatory);
  FInstantAttribute.Metadata.IsRequired := False;
  AssertFalse('4', FInstantAttribute.IsMandatory);
end;

procedure TestTInstantAttribute.TestIsRequired;
begin
  AssertFalse(FInstantAttribute.IsRequired);

  FInstantAttribute.Metadata.IsRequired := True;
  AssertTrue(FInstantAttribute.IsRequired);
end;

procedure TestTInstantAttribute.TestMetadata;
var
  vAttrMetadata: TInstantAttributeMetadata;
begin
  AssertNotNull(FInstantAttribute.Metadata);
  AssertEquals('Name', FInstantAttribute.Metadata.Name);

  vAttrMetadata := FInstantAttribute.Metadata;
  FInstantAttribute.Metadata := nil;
  AssertNull(FInstantAttribute.Metadata);
  FInstantAttribute.Reset;

  FInstantAttribute.Metadata := vAttrMetadata;
  AssertNotNull(FInstantAttribute.Metadata);
  AssertEquals('Name', FInstantAttribute.Metadata.Name);
end;

initialization
  // Register any test cases with the test runner
{$IFNDEF CURR_TESTS}
  RegisterTests([TestTInstantAttribute]);
{$ENDIF}

end.
 