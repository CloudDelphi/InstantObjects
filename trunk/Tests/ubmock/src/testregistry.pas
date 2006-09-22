{
    $Id: testregistry.pas,v 1.1 2005/02/11 22:11:57 decko Exp $
{
    $Id: testregistry.pp,v 1.3 2005/04/11 18:10:55 michael Exp $
    This file is part of the Free Component Library (FCL)
    Copyright (c) 2004 by Dean Zobec, Michael Van Canneyt

    Port to Free Pascal of the JUnit framework.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
unit testregistry;

interface

uses
  fpcunit, testdecorator;
  
type

  TTestDecoratorClass = class of TTestDecorator;


procedure RegisterTest(ATestClass: TTestCaseClass); overload;

procedure RegisterTests(ATests: Array of TTestCaseClass);

procedure RegisterTestDecorator(ADecoratorClass: TTestDecoratorClass; ATestClass: TTestCaseClass);

function NumberOfRegisteredTests: longint;

function GetTestRegistry: TTestSuite;

implementation

var
  FTestRegistry: TTestSuite;

function GetTestRegistry: TTestSuite;
begin
  if not Assigned(FTestRegistry) then
    FTestRegistry := TTestSuite.Create;
  Result := FTestRegistry;
end;

procedure RegisterTest(ATestClass: TTestCaseClass);
begin
  GetTestRegistry.AddTestSuiteFromClass(ATestClass);
end;

procedure RegisterTestDecorator(ADecoratorClass: TTestDecoratorClass; ATestClass: TTestCaseClass);
begin
  GetTestRegistry.AddTest(ADecoratorClass.Create(TTestSuite.Create(ATestClass)));
end;

procedure RegisterTests(ATests: Array of TTestCaseClass);
var
  i: integer;
begin
  for i := Low(ATests) to High(ATests) do
    if Assigned(ATests[i]) then
    begin
      RegisterTest(ATests[i]);
    end;
end;


function NumberOfRegisteredTests: longint;
begin
  Result := GetTestRegistry.CountTestCases;
end;

initialization
  FTestRegistry := nil;
finalization
  FTestRegistry.Free;
end.

