(*
 *   InstantObjects
 *   Basic Edit Form
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
 * Carlo Barazzetta, Adrea Petrelli, Nando Dessena
 *
 * ***** END LICENSE BLOCK ***** *)

unit InstantEdit;

{$I ..\Core\InstantDefines.inc}

interface

uses
  SysUtils, Classes, DB,
{$IFDEF MSWINDOWS}
  Windows, Messages, Graphics, StdCtrls, ExtCtrls, Controls, Forms, Dialogs,
{$ENDIF}
{$IFDEF LINUX}
  QForms, QStdCtrls, QControls, QExtCtrls,
{$ENDIF}
  InstantPresentation;
type
  TInstantEditForm = class(TForm)
    SubjectExposer: TInstantExposer;
    SubjectSource: TDataSource;
    EditPanel: TPanel;
    BottomPanel: TPanel;
    ButtonPanel: TPanel;
    OkButton: TButton;
    CancelButton: TButton;
    procedure CancelButtonClick(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    function GetSubject: TObject;
    procedure SetSubject(const Value: TObject);
  protected
    procedure LoadData; virtual;
    procedure SaveData; virtual;
    procedure SubjectChanged; virtual;
  public
    property Subject: TObject read GetSubject write SetSubject;
  end;

implementation

{$R *.dfm}

{ TInstantEditForm }

procedure TInstantEditForm.CancelButtonClick(Sender: TObject);
begin
  try
    SubjectExposer.Revert;
  except
    ModalResult := mrNone;
    raise;
  end;
end;

function TInstantEditForm.GetSubject: TObject;
begin
  Result := SubjectExposer.Subject;
end;

procedure TInstantEditForm.LoadData;
begin
end;

procedure TInstantEditForm.OkButtonClick(Sender: TObject);
begin
  try
    SaveData;
    SubjectExposer.PostChanges;
  except
    ModalResult := mrNone;
    raise;
  end;
end;

procedure TInstantEditForm.SaveData;
begin
end;

procedure TInstantEditForm.SetSubject(const Value: TObject);
begin
  if Value <> Subject then
  begin
    SubjectExposer.Subject := Value;
    SubjectExposer.Remember;
    SubjectChanged;
  end;
end;

procedure TInstantEditForm.SubjectChanged;
begin
  LoadData;
end;

procedure TInstantEditForm.FormCreate(Sender: TObject);
begin
{$IFDEF MSWINDOWS}
  BorderStyle := bsDialog;
{$ENDIF}
{$IFDEF LINUX}
  BorderStyle := fbsDialog;
{$ENDIF}
end;

end.
