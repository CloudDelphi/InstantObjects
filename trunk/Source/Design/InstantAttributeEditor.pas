(*
 *   InstantObjects
 *   Attribute Editor
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
 * Carlo Barazzetta, Adrea Petrelli, Nando Dessena, Steven Mitchell
 *
 * ***** END LICENSE BLOCK ***** *)

unit InstantAttributeEditor;

interface

{$I ..\Core\InstantDefines.inc}

uses
  SysUtils, Classes,
  InstantEdit, DB, InstantCode, TypInfo,
{$IFDEF MSWINDOWS}
  Windows, Messages, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, DBCtrls, Mask, ComCtrls, ImgList,
{$ENDIF}
{$IFDEF LINUX}
  QImgList, QStdCtrls, QDBCtrls, QMask, QControls, QComCtrls, QExtCtrls,
{$ENDIF}
  InstantPresentation;

type
  TInstantStringsEvent = procedure(Sender: TObject; Items: TStrings) of object;

  TInstantAttributeEditorForm = class(TInstantEditForm)
    AccessSheet: TTabSheet;
    DefinitionSheet: TTabSheet;
    DisplayWidthEdit: TDBEdit;
    DisplayWidthLabel: TLabel;
    EditMaskEdit: TDBEdit;
    EdtMaskLabel: TLabel;
    MethodAddCheckBox: TCheckBox;
    MethodClearCheckBox: TCheckBox;
    MethodDeleteCheckBox: TCheckBox;
    MethodIndexOfCheckBox: TCheckBox;
    MethodInsertCheckBox: TCheckBox;
    MethodRemoveCheckBox: TCheckBox;
    MethodsGroupBox: TGroupBox;
    NameEdit: TDBEdit;
    NameLabel: TLabel;
    ObjectClassEdit: TDBComboBox;
    ObjectClassLabel: TLabel;
    OptionDefaultCheckBox: TCheckBox;
    OptionIndexedCheckBox: TCheckBox;
    OptionReadOnlyCheckBox: TCheckBox;
    OptionRequiredCheckBox: TCheckBox;
    OptionsGroupBox: TGroupBox;
    PageControl: TPageControl;
    PresentationSheet: TTabSheet;
    SingularNameEdit: TDBEdit;
    SingularNameLabel: TLabel;
    SizeEdit: TDBEdit;
    SizeLabel: TLabel;
    StorageNameEdit: TDBEdit;
    StorageNameLabel: TLabel;
    TypeEdit: TDBComboBox;
    TypeImages: TImageList;
    TypeLabel: TLabel;
    ValidCharsEdit: TDBEdit;
    ValidCharsLabel: TLabel;
    VisibilityEdit: TDBComboBox;
    VisibilityLabel: TLabel;
    DefaultValueLabel: TLabel;
    DefaultValueEdit: TDBEdit;
    ExternalStorageNameEdit: TDBEdit;
    ExternalStorageNameLabel: TLabel;
    StorageKindEdit: TDBComboBox;
    StorageKindLabel: TLabel;
    AutoExternalStorageNameCheckBox: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure NameEditChange(Sender: TObject);
    procedure NumericFieldGetText(Sender: TField; var Text: string;
      Display: Boolean);
    procedure ObjectClassEditChange(Sender: TObject);
    procedure ObjectClassEditEnter(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure SubjectExposerInitField(Sender: TObject; Field: TField);
    procedure SubjectExposerTranslate(Sender: TObject; Field: TField;
      var Value: Variant; Write: Boolean);
    procedure TypeEditClick(Sender: TObject);
    procedure StorageKindEditChange(Sender: TObject);
    procedure ExternalStorageNameEditChange(Sender: TObject);
    procedure StorageNameEditChange(Sender: TObject);
    procedure AutoExternalStorageNameCheckBoxClick(Sender: TObject);
  private
    FBaseClassStorageName: string;
    FLimited: Boolean;
    FModel: TInstantCodeModel;
    FOnLoadClasses: TInstantStringsEvent;
    function GetSubject: TInstantCodeAttribute;
    procedure SetSubject(const Value: TInstantCodeAttribute);
    procedure SetLimited(Value: Boolean);
    procedure SetModel(const Value: TInstantCodeModel);
  protected
    procedure LoadClasses;
    procedure LoadData; override;
    procedure LoadEnums(TypeInfo: PTypeInfo; Items: TStrings;
      Values: Pointer);
    procedure LoadTypes;
    procedure LoadVisibilities;
    procedure LoadStorageKind;
    procedure PopulateClasses;
    procedure SaveData; override;
    procedure SubjectChanged; override;
    procedure UpdateControls;
    procedure ComputeExternalStorageName;
  public
    property BaseClassStorageName: string read FBaseClassStorageName write
      FBaseClassStorageName;
    property Limited: Boolean read FLimited write SetLimited;
    property Model: TInstantCodeModel read FModel write SetModel;
    property OnLoadClasses: TInstantStringsEvent read FOnLoadClasses
      write FOnLoadClasses;
    property Subject: TInstantCodeAttribute read GetSubject write SetSubject;
  end;

implementation

uses
  InstantRtti, InstantPersistence, InstantDesignUtils, InstantImageUtils,
  InstantClasses;

{$R *.dfm}

{ TInstantAttributeEditorForm }

procedure TInstantAttributeEditorForm.FormCreate(Sender: TObject);
begin
  LoadMultipleImages(TypeImages, 'IO_ATTRIBUTEEDITORIMAGES', HInstance);
  PageControl.ActivePage := DefinitionSheet;
  ActiveControl := NameEdit;
end;

function TInstantAttributeEditorForm.GetSubject: TInstantCodeAttribute;
begin
  Result := inherited Subject as TInstantCodeAttribute;
end;

procedure TInstantAttributeEditorForm.LoadClasses;
var
  I: Integer;
begin
  ObjectClassEdit.Items.BeginUpdate;
  try
    ObjectClassEdit.Items.Clear;
    if Assigned(FOnLoadClasses) then
      FOnLoadClasses(Self, ObjectClassEdit.Items)
    else
      if Assigned(FModel) then
        for I := 0 to Pred(FModel.ClassCount) do
          ObjectClassEdit.Items.Add(FModel.Classes[I].Name);
    if Assigned(ObjectClassEdit.Field) then
      ObjectClassEdit.ItemIndex :=
        ObjectClassEdit.Items.IndexOf(ObjectClassEdit.Field.AsString);
  finally
    ObjectClassEdit.Items.EndUpdate;
  end;
end;

procedure TInstantAttributeEditorForm.LoadData;

  procedure LoadOptions;
  begin
    OptionIndexedCheckBox.Checked := Subject.IsIndexed;
    OptionRequiredCheckBox.Checked := Subject.IsRequired;
    OptionReadOnlyCheckBox.Checked := Subject.ReadOnly;
    OptionDefaultCheckBox.Checked := Subject.IsDefault;
  end;

  procedure LoadMethods;
  begin
    MethodAddCheckBox.Checked := Subject.IncludeAddMethod;
    MethodRemoveCheckBox.Checked := Subject.IncludeRemoveMethod;
    MethodInsertCheckBox.Checked := Subject.IncludeInsertMethod;
    MethodDeleteCheckBox.Checked := Subject.IncludeDeleteMethod;
    MethodIndexOfCheckBox.Checked := Subject.IncludeIndexOfMethod;
    MethodClearCheckBox.Checked := Subject.IncludeClearMethod;
  end;

begin
  inherited;
  LoadOptions;
  LoadMethods;
end;

procedure TInstantAttributeEditorForm.LoadEnums(TypeInfo: PTypeInfo;
  Items: TStrings; Values: Pointer);
type
  PByteSet = ^TByteSet;
  TByteSet = set of Byte;
var
  Names: TStringList;
  ByteSet: PByteSet;
  S: string;
  I: Integer;
begin
  ByteSet := Values;
  Names := TStringList.Create;
  try
    InstantGetEnumNames(TypeInfo, Names);
    Items.BeginUpdate;
    try
      Items.Clear;
      for I := 0 to Pred(Names.Count) do
      begin
        if not Assigned(ByteSet) or not (I in ByteSet^) then
        begin
          S := Names[I];
          Items.Add(Copy(S, 3, Length(S)));
        end;
      end;
    finally
      Items.EndUpdate;
    end;
  finally
    Names.Free;
  end;
end;

procedure TInstantAttributeEditorForm.LoadStorageKind;
begin
  StorageKindEdit.ItemIndex :=
    SubjectExposer.GetFieldStrings(StorageKindEdit.Field, StorageKindEdit.Items);
end;

procedure TInstantAttributeEditorForm.LoadTypes;
var
  I: Integer;
begin
  TypeEdit.ItemIndex := SubjectExposer.GetFieldStrings(TypeEdit.Field,
    TypeEdit.Items);
  I := TypeEdit.Items.IndexOf('Unknown');
  if I <> -1 then
    TypeEdit.Items.Delete(I);
end;

procedure TInstantAttributeEditorForm.LoadVisibilities;
var
  I: Integer;
begin
  SubjectExposer.GetFieldStrings(VisibilityEdit.Field, VisibilityEdit.Items);
  I := VisibilityEdit.Items.IndexOf('Default');
  if I <> -1 then
    VisibilityEdit.Items.Delete(I);
  if Assigned(Subject) and Subject.IsContainer then
  begin
    I := VisibilityEdit.Items.IndexOf('Published');
    if I <> -1 then
      VisibilityEdit.Items.Delete(I);
  end;
  if Assigned(VisibilityEdit.Field) then
    VisibilityEdit.ItemIndex :=
      VisibilityEdit.Items.IndexOf(VisibilityEdit.Field.AsString);
end;

procedure TInstantAttributeEditorForm.NameEditChange(Sender: TObject);
begin
  SubjectExposer.AssignFieldValue(NameEdit.Field, NameEdit.Text);
  UpdateControls;
  ComputeExternalStorageName;
end;

procedure TInstantAttributeEditorForm.NumericFieldGetText(Sender: TField;
  var Text: string; Display: Boolean);
begin
  if Sender.AsInteger = 0 then
    Text := ''
  else
    Text := IntToStr(Sender.AsInteger);
end;

procedure TInstantAttributeEditorForm.ObjectClassEditChange(Sender: TObject);
begin
  SubjectExposer.AssignFieldValue(ObjectClassEdit.Field, ObjectClassEdit.Text);
  UpdateControls;
end;

procedure TInstantAttributeEditorForm.ObjectClassEditEnter(
  Sender: TObject);
begin
  PopulateClasses;
end;

procedure TInstantAttributeEditorForm.OkButtonClick(Sender: TObject);
var
  Attribute: TInstantCodeAttribute;
  I: Integer;
begin
  if Assigned(Subject.Owner) then
    for I := 0 to Pred(Subject.Owner.AttributeCount) do
    begin
      Attribute := Subject.Owner.Attributes[I];
      if (Attribute <> Subject) and SameText(Attribute.Name, Subject.Name) then
      begin
        ModalResult := mrNone;
        raise Exception.Create('Name already used');
      end;
    end;

  if not Assigned(FModel) then
    // Do not do SubjectExposer.PostChanges when called from 
    // ModelMaker, otherwise Container Methods settings for a
    // new attribute are cleared.
    SaveData
  else
    inherited;
end;

procedure TInstantAttributeEditorForm.PopulateClasses;
begin
  if ObjectClassEdit.Items.Count = 0 then
    LoadClasses;
end;

procedure TInstantAttributeEditorForm.SaveData;

  procedure SaveOptions;
  begin
    Subject.IsIndexed := OptionIndexedCheckBox.Checked;
    Subject.IsRequired := OptionRequiredCheckBox.Checked;
    Subject.ReadOnly := OptionReadOnlyCheckBox.Checked;
    Subject.IsDefault := OptionDefaultCheckBox.Checked;
  end;

  procedure SaveMethods;
  begin
    Subject.IncludeAddMethod := MethodAddCheckBox.Checked;
    Subject.IncludeRemoveMethod := MethodRemoveCheckBox.Checked;
    Subject.IncludeInsertMethod := MethodInsertCheckBox.Checked;
    Subject.IncludeDeleteMethod := MethodDeleteCheckBox.Checked;
    Subject.IncludeIndexOfMethod := MethodIndexOfCheckBox.Checked;
    Subject.IncludeClearMethod := MethodClearCheckBox.Checked;
  end;

begin
  inherited;
  SaveOptions;
  SaveMethods;
end;

procedure TInstantAttributeEditorForm.SetLimited(Value: Boolean);
begin
  if Value <> FLimited then
  begin
    FLimited := Value;
    UpdateControls;
  end;
end;

procedure TInstantAttributeEditorForm.SetModel(const Value: TInstantCodeModel);
begin
  if FModel <> Value then
  begin
    FModel := Value;
    LoadClasses;
  end;
end;

procedure TInstantAttributeEditorForm.SetSubject(
  const Value: TInstantCodeAttribute);
begin
  inherited Subject := Value;
end;

procedure TInstantAttributeEditorForm.SubjectChanged;
begin
  inherited;
  LoadTypes;
  LoadVisibilities;
  LoadStorageKind;
  UpdateControls;
  ComputeExternalStorageName;
end;

procedure TInstantAttributeEditorForm.SubjectExposerInitField(
  Sender: TObject; Field: TField);
begin
  if (Field.FieldName = 'Metadata.Size') or
    (Field.FieldName = 'Metadata.DisplayWidth') then
    Field.OnGetText := NumericFieldGetText;
end;

procedure TInstantAttributeEditorForm.SubjectExposerTranslate(
  Sender: TObject; Field: TField; var Value: Variant; Write: Boolean);

  procedure TranslateEnum(const Prefix: string);
  var
    Name: string;
  begin
    if Write then
      Value := Prefix + Value
    else
    begin
      Name := Value;
      Delete(Name, 1, Length(Prefix));
      Value := Name;
    end;
  end;

begin
  if Field.FieldName = 'AttributeType' then
    TranslateEnum('at')
  else
    if Field.FieldName = 'Visibility' then
      TranslateEnum('vi')
    else
      if Field.FieldName = 'StorageKind' then
        TranslateEnum('sk');
end;

procedure TInstantAttributeEditorForm.TypeEditClick(Sender: TObject);
begin
  SubjectExposer.AssignFieldValue(TypeEdit.Field, TypeEdit.Text);
  // Controls need to be enabled first to
  // reliably load combo dropdown lists in MM OFExpt
  UpdateControls;
  LoadVisibilities;
  LoadStorageKind;
  ComputeExternalStorageName;
end;

procedure TInstantAttributeEditorForm.UpdateControls;

  procedure DisableSubControls(Parent: TWinControl; Disable: Boolean);
  var
    I: Integer;
  begin
    for I := 0 to Pred(Parent.ControlCount) do
    begin
      Parent.Controls[I].Enabled := not Disable;
      if Parent.Controls[I] is TWinControl then
        DisableSubControls(TWinControl(Parent.Controls[I]), Disable);
    end;
  end;

  procedure EnableCtrl(Control: TControl; Enable: Boolean);
  begin
    EnableControl(Control, Enable, SubjectSource);
  end;

var
  HasName, HasClass, IsComplex, IsContainer, CanBeExternal, IsExternal,
    IsMaskable, IsString, IsValid: Boolean;
begin
  CanBeExternal := Subject.AttributeType in [atPart, atParts, atReferences];
  if not CanBeExternal then
    Subject.StorageKind := skEmbedded;
  if Subject.AttributeType = atPart then
    Subject.ExternalStorageName := '';

  HasName := NameEdit.Text <> '';
  HasClass := ObjectClassEdit.Text <> '';
  IsComplex := Subject.IsComplex;
  IsMaskable := Subject.AttributeType in [atString, atMemo, atFloat, atCurrency,
    atInteger];
  IsContainer := Subject.IsContainer;

  IsExternal := Subject.StorageKind = skExternal;
  IsString := Subject.AttributeType in [atString, atMemo];
  IsValid := HasName and (not IsComplex or HasClass);

  DisableSubControls(DefinitionSheet, Limited);
  DisableSubControls(AccessSheet, Limited);
  if not Limited then
  begin
    EnableCtrl(ObjectClassLabel, IsComplex);
    EnableCtrl(ObjectClassEdit, IsComplex);
    EnableCtrl(SingularNameLabel, IsContainer);
    EnableCtrl(SingularNameEdit, IsContainer);
    EnableCtrl(OptionDefaultCheckBox, IsContainer);
    EnableCtrl(MethodsGroupBox, IsContainer);
    EnableCtrl(MethodAddCheckBox, IsContainer);
    EnableCtrl(MethodClearCheckBox, IsContainer);
    EnableCtrl(MethodDeleteCheckBox, IsContainer);
    EnableCtrl(MethodIndexOfCheckBox, IsContainer);
    EnableCtrl(MethodInsertCheckBox, IsContainer);
    EnableCtrl(MethodRemoveCheckBox, IsContainer);

    EnableCtrl(StorageKindEdit, CanBeExternal);
    EnableCtrl(StorageKindLabel, CanBeExternal);
  end;
  EnableCtrl(StorageNameLabel, not IsExternal or (Subject.AttributeType =
    atPart));
  EnableCtrl(StorageNameEdit, not IsExternal or (Subject.AttributeType =
    atPart));

  EnableCtrl(ExternalStorageNameLabel, IsExternal
    and not (Subject.AttributeType = atPart));
  EnableCtrl(ExternalStorageNameEdit, IsExternal
    and not (Subject.AttributeType = atPart));
  EnableCtrl(AutoExternalStorageNameCheckBox,
    ExternalStorageNameEdit.Enabled);

  EnableCtrl(SizeLabel, IsString);
  EnableCtrl(SizeEdit, IsString);
  EnableCtrl(OptionsGroupBox, True);
  EnableCtrl(OptionIndexedCheckBox, True);
  EnableCtrl(OptionRequiredCheckBox, True);
  EnableCtrl(OkButton, IsValid);
  PresentationSheet.TabVisible := IsMaskable;
end;

procedure TInstantAttributeEditorForm.StorageKindEditChange(Sender: TObject);
begin
  if StorageKindEdit.Text <> '' then
    SubjectExposer.AssignFieldValue(StorageKindEdit.Field,
      StorageKindEdit.Text);
  UpdateControls;
  ComputeExternalStorageName;
end;

procedure TInstantAttributeEditorForm.ExternalStorageNameEditChange(Sender:
  TObject);
begin
  if ExternalStorageNameEdit.Text <> '' then
    SubjectExposer.AssignFieldValue(ExternalStorageNameEdit.Field,
      ExternalStorageNameEdit.Text);
  UpdateControls;
end;

procedure
  TInstantAttributeEditorForm.AutoExternalStorageNameCheckBoxClick(Sender:
  TObject);
begin
  if AutoExternalStorageNameCheckBox.Checked then
    ComputeExternalStorageName;
end;

procedure TInstantAttributeEditorForm.StorageNameEditChange(
  Sender: TObject);
begin
  UpdateControls;
end;

procedure TInstantAttributeEditorForm.ComputeExternalStorageName;

  function GetStorageName: string;
  begin
    if StorageNameEdit.Text <> '' then
      Result := StorageNameEdit.Text
    else
      Result := NameEdit.Text;
  end;

begin
  if ExternalStorageNameEdit.Enabled then
  begin
    if (Subject.ExternalStorageName <> '') and
      not AutoExternalStorageNameCheckBox.Checked then
      ExternalStorageNameEdit.Text := Subject.ExternalStorageName
    else
      if (ExternalStorageNameEdit.Text = '') or
        AutoExternalStorageNameCheckBox.Checked then
        ExternalStorageNameEdit.Text :=
          Format('%s_%s', [BaseClassStorageName, GetStorageName()]);
  end
  else
    ExternalStorageNameEdit.Text := '';

end;

end.


