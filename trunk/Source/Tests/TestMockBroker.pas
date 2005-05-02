unit TestMockBroker;

interface

uses
  Classes, SysUtils, InstantPersistence, fpcunit, testregistry, InstantMock,
  Model;

type
  TTestMockBroker = class(TTestCase)
  private
  protected
    FConn: TInstantMockConnector;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestModelMdx;
    procedure TestGetBroker;
    procedure TestBuildDatabase;
    procedure TestStoreAndRetrieveAddress;
  end;

  TTestMockRelationalBroker = class(TTestCase)
  private
  protected
    FConn: TInstantMockConnector;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestGetBroker;
    procedure TestStoreAndRetrieveContact;
    procedure TestParts;
  end;

implementation

{ TTestMockBroker }

procedure TTestMockBroker.TestModelMdx;
begin
  InstantModel.LoadFromFile(ChangeFileExt(ParamStr(0),'.mdx'));
  AssertNotNull(InstantModel.ClassMetadatas.Find('TContact'));
end;

procedure TTestMockBroker.TestGetBroker;
var
  brok: TInstantMockBroker;
begin
  brok := (Fconn.Broker as TInstantMockBroker);
  AssertNotNull(brok);
  AssertEquals(brok.ClassType, TInstantMockBroker);
  brok.MockManager.StartSetUp;
  brok.MockManager.EndSetUp;
  Fconn.BuildDatabase(InstantModel);
  brok.MockManager.Verify;
end;

procedure TTestMockBroker.TestBuildDatabase;
var
  brok: TInstantMockBroker;
begin
  InstantModel.LoadFromFile(ChangeFileExt(ParamStr(0),'.mdx'));

  brok := Fconn.Broker as TInstantMockBroker;
  brok.MockManager.StartSetUp;
  brok.MockManager.EndSetUp;
  Fconn.BuildDatabase(InstantModel);
  brok.MockManager.Verify;
end;

procedure TTestMockBroker.TestStoreAndRetrieveAddress;
var
  a: TAddress;
  old_id: string;
  brok: TInstantMockBroker;
begin
  InstantModel.LoadFromFile(ChangeFileExt(ParamStr(0),'.mdx'));

  Fconn.IsDefault := True;
  Fconn.StartTransaction;
  brok := Fconn.Broker as TInstantMockBroker;
  brok.MockManager.StartSetUp;
  a := TAddress.Create;
  try
    a.City := 'Milan';
    a.Store();
    old_id := a.id;
  finally
    FreeAndNil(a);
  end;
  AssertNull(a);
  brok.MockManager.EndSetUp;
  brok.MockManager.AddExpectation('InternalStoreObject ' + old_id);
  brok.MockManager.Verify;
  Fconn.CommitTransaction;
  brok.MockManager.StartSetUp;
  a := TAddress.Retrieve(old_id);
  try
    AssertEquals(old_id, a.Id);
  finally
    FreeAndNil(a);
  end;
  brok.MockManager.EndSetUp;
  brok.MockManager.AddExpectation('InternalRetrieveObject ' + old_id);
  brok.MockManager.Verify;
end;

procedure TTestMockBroker.SetUp;
begin
  inherited;
  FConn := TInstantMockConnector.Create(nil);
  FConn.BrokerClass := TInstantMockBroker;
end;

procedure TTestMockBroker.TearDown;
begin
  FConn.Free;
  inherited;
end;

{ TTestMockRelationalBroker }

procedure TTestMockRelationalBroker.SetUp;
begin
  inherited;
  FConn := TInstantMockConnector.Create(nil);
  FConn.BrokerClass := TInstantMockCRBroker;
end;

procedure TTestMockRelationalBroker.TearDown;
begin
  inherited;
  FConn.Free;
end;

procedure TTestMockRelationalBroker.TestGetBroker;
var
  brok: TInstantMockCRBroker;
begin
  brok := (Fconn.Broker as TInstantMockCRBroker);
  AssertNotNull(brok);
  AssertEquals(brok.ClassType, TInstantMockCRBroker);
  brok.MockManager.StartSetUp;
  brok.MockManager.EndSetUp;
  Fconn.BuildDatabase(InstantModel);
  brok.MockManager.Verify;
end;

procedure TTestMockRelationalBroker.TestParts;
var
  c: TContact;
  t: TPhone;
begin
  InstantModel.LoadFromFile(ChangeFileExt(ParamStr(0),'.mdx'));
  Fconn.IsDefault := True;
  c := TContact.Create;
  try
    AssertNotNull(c._Phones);
    AssertEquals(0, c.PhoneCount);
    t := TPhone.Create;
    t.Name := 'Home';
    t.Number := '012 12345678';
    c.AddPhone(t);
    AssertEquals(1, c.PhoneCount);
  finally
    c.Free;
  end;
end;

procedure TTestMockRelationalBroker.TestStoreAndRetrieveContact;
var
  c: TContact;
  old_id: string;
  brok: TInstantMockCRBroker;
  t: TPhone;
begin
  InstantModel.LoadFromFile(ChangeFileExt(ParamStr(0),'.mdx'));

  Fconn.IsDefault := True;
  brok := Fconn.Broker as TInstantMockCRBroker;
  brok.MockManager.StartSetUp;

  c := TContact.Create;
  try
    c.Name := 'Mike';
    c.Address.City := 'Milan';
    t := TPhone.Create;
    t.Name := 'Home';
    t.Number := '012 12345678';
    c.AddPhone(t);
    AssertEquals(1, c.PhoneCount);

    t := TPhone.Create;
    t.Name := 'Office';
    t.Number := '012 23456781';
    c.AddPhone(t);
    AssertEquals(2, c.PhoneCount);
    c.Store();
    old_id := c.id;
  finally
    FreeAndNil(c);
  end;
  AssertNull(c);
  brok.MockManager.EndSetUp;
  brok.MockManager.AddExpectation('InternalStoreObject caFail ' + old_id);
  brok.MockManager.Verify;
  brok.MockManager.StartSetUp;
  brok.MockManager.AddExpectation('InternalRetrieveObject caFail ' + old_id);
  brok.MockManager.EndSetUp;
  c := TContact.Retrieve(old_id);
  try
    AssertEquals(old_id, c.Id);
    AssertNotNull(c.Address);
    AssertEquals(0, c.PhoneCount); //mock brocker cannot collect part and parts
  finally
    FreeAndNil(c);
  end;
  brok.MockManager.Verify;
end;

initialization
  RegisterTests([TTestMockBroker, TTestMockRelationalBroker]);

end.
