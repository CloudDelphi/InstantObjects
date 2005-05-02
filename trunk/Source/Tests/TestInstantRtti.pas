unit TestInstantRtti;

interface

uses
  Classes, SysUtils,
  InstantRtti,
  fpcunit,
  MaskUtils,
  testregistry;

type

  { TTestInstantRtti }

  TTestInstantRtti = class(TTestCase)
  published
    procedure TestHexToBin;
    procedure TestInheritsFrom;
    procedure TestMaskUtils;
    procedure TestInstantProperties;
    procedure TestInstantSetProperty;
  end;

  { TGuineaPig }

  TGuineaPig = class;
  TGuineaPigClass = class of TGuineaPig;
  
  TGuineaPig = class(TPersistent)
  private
    FAge: integer;
    FIsMale: Boolean;
    FName: string;
    FWeight: double;
    procedure SetAge(const Value: integer);
    procedure SetIsMale(const AValue: Boolean);
    procedure SetName(const Value: string);
    procedure SetWeight(const Value: double);
  public
    constructor Create;
  published
    property Age: integer read FAge write SetAge;
    property Weight: double read FWeight write SetWeight;
    property PigName: string read FName write SetName;
    property IsMale: Boolean read FIsMale write SetIsMale;
  end;

implementation

uses
  Variants;

{ TTestInstantRtti }

procedure TTestInstantRtti.TestHexToBin;
var
  s, hs: array [0..4] of char;
begin
  s := '  ';
  hs := '    ';
  BinToHex(PChar(@s), PChar(@hs), 2);
  AssertEquals('2020', hs);
  s := '2020';
  hs := 'aa';
  HexToBin(PChar(@s), PChar(@hs), 2);
  AssertEquals('  ', hs);
end;

procedure TTestInstantRtti.TestInheritsFrom;
var
  c: TGuineaPig;
  cc: TGuineaPigClass;
  
  procedure CheckClass(AClass: TGuineaPigClass);
  begin
    AssertTrue(AClass.InheritsFrom(TGuineaPig));
  end;
  
begin
  AssertTrue(TGuineaPig.InheritsFrom(TPersistent));
  AssertFalse(TGuineaPig.InheritsFrom(TTestInstantRtti));
  AssertTrue(TGuineaPig.InheritsFrom(TGuineaPig));
  c := TGuineaPig.Create;
  try
    AssertTrue(c.InheritsFrom(TPersistent));
    AssertFalse(c.InheritsFrom(TTestInstantRtti));
    AssertTrue(c.InheritsFrom(TGuineaPig));
    
    cc := TGuineaPig;
    AssertTrue(cc.InheritsFrom(TPersistent));
    AssertFalse(cc.InheritsFrom(TTestInstantRtti));
    AssertTrue(cc.InheritsFrom(TGuineaPig));

    AssertTrue(c.InheritsFrom(cc));
    AssertTrue(c.ClassType.InheritsFrom(cc));
    AssertTrue(cc.InheritsFrom(cc));

    CheckClass(TGuineaPigClass(c.ClassType));
  finally
    c.Free;
  end;
end;

procedure TTestInstantRtti.TestInstantProperties;
var
  p: TInstantProperties;
  c: TGuineaPig;
  i, t: integer;
begin
  c := TGuineaPig.Create;
  p := TInstantProperties.Create(c);
  try
    AssertEquals(4, p.Count);
    t := -1;
    for i := 0 to p.Count - 1 do
      if p.Names[i] = 'PigName' then
        t := i;
    AssertTrue('t >= 0', t >= 0);
    AssertEquals(c.PigName, VarToStr(p.Values[t]));
  finally
    c.Free;
    p.Free;
  end;
end;

procedure TTestInstantRtti.TestInstantSetProperty;
var
  c: TGuineaPig;
begin
  c := TGuineaPig.Create;
  try
    InstantSetProperty(c, 'PigName', 'croton');
    AssertEquals('croton', c.PigName);
    InstantSetProperty(c, 'IsMale', True);
    AssertEquals(True, c.IsMale);
    InstantSetProperty(c, 'Age', 15);
    AssertEquals(15, c.Age);
    InstantSetProperty(c, 'Weight', 15.758);
    AssertEquals(15.758, c.Weight);
  finally
    c.Free;
  end;
end;

procedure TTestInstantRtti.TestMaskUtils;
var
  ds, ts : string;
begin
  ds := DateSeparator;
  ts := TimeSeparator;

  AssertEquals('123', FormatMaskText('###','1234'));
  AssertEquals('(123)_   -    ', FormatMaskText('(000)_000-0000;0;*','123'));
  AssertEquals('(123)_456-    ', FormatMaskText('(000)_000-0000;0;*','123456'));
  AssertEquals('(123)_456-789 ', FormatMaskText('(000)_000-0000;0;*','123456789'));
  AssertEquals('(123)_456-7890', FormatMaskText('(000)_000-0000;0;*','1234567890'));
  AssertEquals('t_   ', FormatMaskText('t_###','ab'));
  AssertEquals('t_   ', FormatMaskText('t_###','abcd'));
  AssertEquals('t_abc', FormatMaskText('t_LLL;0;*','abc'));

  AssertEquals('(012)345-6789',FormatMaskText('!\(999\)000-0000;0;','0123456789'));
  AssertEquals('(02  ) 1234 5678.1234',FormatMaskText('!\(9999\) 0000 0000\.9999;0;','02  123456781234'));
  AssertEquals('TRM.DNC.55P27.B242.Z',FormatMaskText('>LLL\.LLL\.00L00\.L000\.L;0;','TRMDNC55P27B242Z'));
  AssertEquals('00100',FormatMaskText('00000;0;','00100'));
  AssertEquals('13'+ds+'02'+ds+'95',FormatMaskText('!99/99/00;0;','130295'));
  AssertEquals('13'+ds+'02'+ds+'1995',FormatMaskText('!99/99/\1\900;0;','130295'));
  AssertEquals('13 Gen 1995',FormatMaskText('!99 >L<LL \1\900;0;','13Gen95'));
  AssertEquals('21'+ts+'05'+TimeSeparator+'15',FormatMaskText('!90:00:00;0;','210515'));
  AssertEquals('13'+ts+'45',FormatMaskText('!90:00;0;','1345'));
end;

{ TGuineaPig }

constructor TGuineaPig.Create;
begin
  Age := 2;
  Weight := 1.75;
  PigName := 'miss piggy';
  IsMale := False;
end;

procedure TGuineaPig.SetAge(const Value: integer);
begin
  FAge := Value;
end;

procedure TGuineaPig.SetIsMale(const AValue: Boolean);
begin
  if FIsMale=AValue then exit;
  FIsMale:=AValue;
end;

procedure TGuineaPig.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TGuineaPig.SetWeight(const Value: double);
begin
  FWeight := Value;
end;

initialization
  RegisterTests([TTestInstantRtti]);

end.
