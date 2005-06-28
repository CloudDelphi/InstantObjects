(*
 *   InstantObjects Test Suite
 *   TestInstantIndexMetadata
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
 * The Original Code is: InstantObjects Test Suite/TestInstantIndexMetadata
 *
 * The Initial Developer of the Original Code is: Steven Mitchell
 *
 * Portions created by the Initial Developer are Copyright (C) 2005
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * 
 *
 * ***** END LICENSE BLOCK ***** *)

unit TestInstantIndexMetadata;

interface

uses fpcunit, InstantPersistence;

type

  // Test methods for class TInstantIndexMetadata
  TestTInstantIndexMetadata = class(TTestCase)
  private
    FCollection: TInstantIndexMetadatas;
    FInstantIndexMetadata: TInstantIndexMetadata;
    FOwner: TInstantTableMetadata;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCollection;
    procedure TestFields;
    procedure TestOptions;
    procedure TestTableMetadata;
  end;

  // Test methods for class TInstantIndexMetadatas
  TestTInstantIndexMetadatas = class(TTestCase)
  private
    FInstantIndexMetadatas: TInstantIndexMetadatas;
    FOwner: TInstantTableMetadata;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAddIndexMetadata;
    procedure TestAdd;
    procedure TestOwner;
  end;

implementation

uses SysUtils, Db, testregistry;

procedure TestTInstantIndexMetadata.SetUp;
begin
  FOwner := TInstantTableMetadata.Create(nil);
  FCollection := TInstantIndexMetadatas.Create(FOwner);
  FInstantIndexMetadata := TInstantIndexMetadata.Create(FCollection);
  FInstantIndexMetadata.Fields := 'IndexFields';
  FInstantIndexMetadata.Options := [ixPrimary, ixUnique];
end;

procedure TestTInstantIndexMetadata.TearDown;
begin
  FInstantIndexMetadata.Free;
  FInstantIndexMetadata := nil;
  FreeAndNil(FCollection);
  FreeAndNil(FOwner);
end;

procedure TestTInstantIndexMetadata.TestCollection;
begin
  AssertNotNull(FInstantIndexMetadata.Collection);
  AssertSame(FCollection, FInstantIndexMetadata.Collection);
end;

procedure TestTInstantIndexMetadata.TestFields;
begin
  AssertEquals('IndexFields', FInstantIndexMetadata.Fields);
end;

procedure TestTInstantIndexMetadata.TestOptions;
begin
  AssertTrue([ixPrimary, ixUnique] = FInstantIndexMetadata.Options);
end;

procedure TestTInstantIndexMetadata.TestTableMetadata;
begin
  AssertNotNull(FInstantIndexMetadata.TableMetadata);
  AssertSame(FOwner, FInstantIndexMetadata.TableMetadata);
end;

procedure TestTInstantIndexMetadatas.SetUp;
begin
  FOwner := TInstantTableMetadata.Create(nil);
  FInstantIndexMetadatas := TInstantIndexMetadatas.Create(FOwner);
end;

procedure TestTInstantIndexMetadatas.TearDown;
begin
  FInstantIndexMetadatas.Free;
  FInstantIndexMetadatas := nil;
  FreeAndNil(FOwner);
end;

procedure TestTInstantIndexMetadatas.TestAdd;
var
  vReturnValue: TInstantIndexMetadata;
begin
  vReturnValue := FInstantIndexMetadatas.Add;
  AssertNotNull(vReturnValue);
  AssertEquals(1, FInstantIndexMetadatas.Count);
  AssertNotNull('Items[0]', FInstantIndexMetadatas.Items[0]);
  FInstantIndexMetadatas.Remove(vReturnValue);
  AssertEquals(0, FInstantIndexMetadatas.Count);
end;

procedure TestTInstantIndexMetadatas.TestAddIndexMetadata;
var
  vOptions: TIndexOptions;
  vFields: string;
  vName: string;
  vReturnValue: TInstantIndexMetadata;
begin
  vName := 'PrimaryID';
  vFields := 'IndexFields';
  vOptions := [ixPrimary, ixUnique];
  FInstantIndexMetadatas.AddIndexMetadata(vName, vFields, vOptions);
  vReturnValue := TInstantIndexMetadata(FInstantIndexMetadatas.Find(vName));
  AssertNotNull('IndexMetadata not found!', vReturnValue);
  AssertEquals(vFields, vReturnValue.Fields);
  AssertTrue('Options value', vOptions = vReturnValue.Options);
end;

procedure TestTInstantIndexMetadatas.TestOwner;
var
  vReturnValue: TInstantTableMetadata;
begin
  vReturnValue := FInstantIndexMetadatas.Owner;
  AssertNotNull(vReturnValue);
  AssertSame(FOwner, vReturnValue);
end;

initialization
  // Register any test cases with the test runner
{$IFNDEF CURR_TESTS}
  RegisterTests([TestTInstantIndexMetadata,
                 TestTInstantIndexMetadatas]);
{$ENDIF}

end.
