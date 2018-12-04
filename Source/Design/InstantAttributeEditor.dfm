inherited InstantAttributeEditorForm: TInstantAttributeEditorForm
  Left = 78
  Top = 485
  Caption = 'Attribute Editor'
  ClientHeight = 371
  ClientWidth = 241
  ParentFont = True
  OldCreateOrder = True
  OnCreate = FormCreate
  ExplicitWidth = 257
  ExplicitHeight = 410
  PixelsPerInch = 96
  TextHeight = 13
  inherited EditPanel: TPanel
    Width = 241
    Height = 340
    ExplicitWidth = 241
    ExplicitHeight = 340
    object PageControl: TPageControl
      Left = 4
      Top = 4
      Width = 233
      Height = 332
      ActivePage = DefinitionSheet
      Align = alClient
      TabOrder = 0
      object DefinitionSheet: TTabSheet
        Caption = 'Definition'
        object NameLabel: TLabel
          Left = 8
          Top = 8
          Width = 27
          Height = 13
          Caption = '&Name'
          FocusControl = NameEdit
        end
        object TypeLabel: TLabel
          Left = 8
          Top = 48
          Width = 24
          Height = 13
          Caption = '&Type'
          FocusControl = TypeEdit
        end
        object ObjectClassLabel: TLabel
          Left = 8
          Top = 88
          Width = 60
          Height = 13
          Caption = 'Object &Class'
          FocusControl = ObjectClassEdit
        end
        object StorageNameLabel: TLabel
          Left = 8
          Top = 176
          Width = 68
          Height = 13
          Caption = '&Storage Name'
          FocusControl = StorageNameEdit
        end
        object SizeLabel: TLabel
          Left = 160
          Top = 48
          Width = 19
          Height = 13
          Caption = 'Si&ze'
          FocusControl = SizeEdit
        end
        object ExternalStorageNameLabel: TLabel
          Left = 8
          Top = 262
          Width = 111
          Height = 13
          Caption = '&External Storage Name'
          FocusControl = ExternalStorageNameEdit
        end
        object StorageKindLabel: TLabel
          Left = 8
          Top = 216
          Width = 61
          Height = 13
          Caption = 'Storage &Kind'
          FocusControl = StorageKindEdit
        end
        object EnumeratedTypeLabel: TLabel
          Left = 7
          Top = 132
          Width = 83
          Height = 13
          Caption = '&Enumerated type'
          FocusControl = EnumeratedTypeEdit
        end
        object NameEdit: TDBEdit
          Left = 7
          Top = 24
          Width = 210
          Height = 21
          DataField = 'Name'
          DataSource = SubjectSource
          TabOrder = 0
          OnChange = NameEditChange
          OnKeyPress = NameEditKeyPress
        end
        object TypeEdit: TDBComboBox
          Left = 7
          Top = 64
          Width = 137
          Height = 21
          Style = csDropDownList
          DataField = 'AttributeType'
          DataSource = SubjectSource
          Sorted = True
          TabOrder = 1
          OnClick = TypeEditClick
        end
        object ObjectClassEdit: TDBComboBox
          Left = 7
          Top = 104
          Width = 210
          Height = 21
          DataField = 'Metadata.ObjectClassName'
          DataSource = SubjectSource
          Sorted = True
          TabOrder = 2
          OnChange = ObjectClassEditChange
          OnEnter = ObjectClassEditEnter
        end
        object StorageNameEdit: TDBEdit
          Left = 7
          Top = 192
          Width = 210
          Height = 21
          DataField = 'StorageName'
          DataSource = SubjectSource
          TabOrder = 4
          OnChange = StorageNameEditChange
        end
        object SizeEdit: TDBEdit
          Left = 160
          Top = 64
          Width = 57
          Height = 21
          DataField = 'Metadata.Size'
          DataSource = SubjectSource
          TabOrder = 3
        end
        object ExternalStorageNameEdit: TDBEdit
          Left = 7
          Top = 279
          Width = 210
          Height = 21
          DataField = 'ExternalStorageName'
          DataSource = SubjectSource
          TabOrder = 6
          OnChange = ExternalStorageNameEditChange
        end
        object StorageKindEdit: TDBComboBox
          Left = 7
          Top = 232
          Width = 210
          Height = 21
          Style = csDropDownList
          DataField = 'StorageKind'
          DataSource = SubjectSource
          Sorted = True
          TabOrder = 5
          OnChange = StorageKindEditChange
        end
        object AutoExternalStorageNameCheckBox: TCheckBox
          Left = 172
          Top = 260
          Width = 45
          Height = 17
          Alignment = taLeftJustify
          Caption = 'Auto'
          TabOrder = 7
          OnClick = AutoExternalStorageNameCheckBoxClick
        end
        object EnumeratedTypeEdit: TDBComboBox
          Left = 7
          Top = 149
          Width = 210
          Height = 21
          DataField = 'Metadata.EnumName'
          DataSource = SubjectSource
          TabOrder = 8
          OnChange = EnumeratedTypeEditChange
          OnEnter = EnumeratedTypeEditEnter
        end
      end
      object AccessSheet: TTabSheet
        Caption = 'Access'
        ImageIndex = 2
        object VisibilityLabel: TLabel
          Left = 8
          Top = 8
          Width = 37
          Height = 13
          Caption = '&Visibility'
          FocusControl = VisibilityEdit
        end
        object SingularNameLabel: TLabel
          Left = 120
          Top = 8
          Width = 68
          Height = 13
          Caption = '&Singular Name'
          FocusControl = SingularNameEdit
        end
        object IndexNameLabel: TLabel
          Left = 8
          Top = 181
          Width = 58
          Height = 13
          Caption = 'Index Name'
          FocusControl = IndexNameEdit
        end
        object VisibilityEdit: TDBComboBox
          Left = 8
          Top = 24
          Width = 97
          Height = 21
          Style = csDropDownList
          DataField = 'Visibility'
          DataSource = SubjectSource
          TabOrder = 0
        end
        object MethodsGroupBox: TGroupBox
          Left = 120
          Top = 56
          Width = 97
          Height = 121
          Caption = 'Methods'
          TabOrder = 3
          object MethodAddCheckBox: TCheckBox
            Left = 8
            Top = 16
            Width = 73
            Height = 17
            Caption = '&Add'
            TabOrder = 0
          end
          object MethodRemoveCheckBox: TCheckBox
            Left = 8
            Top = 32
            Width = 73
            Height = 17
            Caption = 'Re&move'
            TabOrder = 1
          end
          object MethodInsertCheckBox: TCheckBox
            Left = 8
            Top = 48
            Width = 73
            Height = 17
            Caption = '&Insert'
            TabOrder = 2
          end
          object MethodDeleteCheckBox: TCheckBox
            Left = 8
            Top = 64
            Width = 73
            Height = 17
            Caption = 'D&elete'
            TabOrder = 3
          end
          object MethodIndexOfCheckBox: TCheckBox
            Left = 8
            Top = 80
            Width = 73
            Height = 17
            Caption = 'Index&Of'
            TabOrder = 4
          end
          object MethodClearCheckBox: TCheckBox
            Left = 8
            Top = 96
            Width = 73
            Height = 17
            Caption = '&Clear'
            TabOrder = 5
          end
        end
        object SingularNameEdit: TDBEdit
          Left = 120
          Top = 24
          Width = 97
          Height = 21
          DataField = 'SingularName'
          DataSource = SubjectSource
          TabOrder = 1
        end
        object OptionsGroupBox: TGroupBox
          Left = 8
          Top = 56
          Width = 97
          Height = 121
          Caption = 'Options'
          TabOrder = 2
          object OptionReadOnlyCheckBox: TCheckBox
            Left = 8
            Top = 64
            Width = 73
            Height = 17
            Caption = '&Read only'
            TabOrder = 2
          end
          object OptionDefaultCheckBox: TCheckBox
            Left = 8
            Top = 80
            Width = 73
            Height = 17
            Caption = '&Default'
            TabOrder = 3
          end
          object OptionIndexedCheckBox: TCheckBox
            Left = 8
            Top = 16
            Width = 73
            Height = 17
            Caption = 'Inde&xed'
            TabOrder = 0
            OnClick = OptionIndexedCheckBoxClick
          end
          object OptionRequiredCheckBox: TCheckBox
            Left = 8
            Top = 48
            Width = 73
            Height = 17
            Caption = 'Req&uired'
            TabOrder = 5
          end
          object OptionUniqueCheckBox: TCheckBox
            Left = 8
            Top = 32
            Width = 73
            Height = 17
            Caption = 'Uni&que'
            TabOrder = 1
          end
          object OptionUseNullCheckBox: TCheckBox
            Left = 8
            Top = 96
            Width = 73
            Height = 17
            Caption = 'Use &Null'
            TabOrder = 4
          end
        end
        object IndexNameEdit: TDBEdit
          Left = 7
          Top = 197
          Width = 210
          Height = 21
          DataField = 'IndexName'
          DataSource = SubjectSource
          TabOrder = 4
        end
      end
      object PresentationSheet: TTabSheet
        Caption = 'Presentation'
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object EdtMaskLabel: TLabel
          Left = 8
          Top = 8
          Width = 45
          Height = 13
          Caption = 'Edit &Mask'
          FocusControl = EditMaskEdit
        end
        object DisplayWidthLabel: TLabel
          Left = 8
          Top = 88
          Width = 65
          Height = 13
          Caption = 'Display &Width'
          FocusControl = DisplayWidthEdit
        end
        object DisplayLabelLabel: TLabel
          Left = 8
          Top = 128
          Width = 62
          Height = 13
          Caption = 'Display &Label'
          FocusControl = DisplayLabelEdit
        end
        object ValidCharsLabel: TLabel
          Left = 8
          Top = 48
          Width = 78
          Height = 13
          Caption = '&Valid Characters'
          FocusControl = ValidCharsEdit
        end
        object DefaultValueLabel: TLabel
          Left = 8
          Top = 168
          Width = 64
          Height = 13
          Caption = '&Default Value'
          FocusControl = DefaultValueEdit
        end
        object EditMaskEdit: TDBEdit
          Left = 8
          Top = 24
          Width = 209
          Height = 21
          DataField = 'Metadata.EditMask'
          DataSource = SubjectSource
          TabOrder = 0
        end
        object DisplayWidthEdit: TDBEdit
          Left = 8
          Top = 104
          Width = 65
          Height = 21
          DataField = 'Metadata.DisplayWidth'
          DataSource = SubjectSource
          TabOrder = 2
        end
        object DisplayLabelEdit: TDBEdit
          Left = 8
          Top = 144
          Width = 209
          Height = 21
          DataField = 'Metadata.DisplayLabel'
          DataSource = SubjectSource
          TabOrder = 3
        end
        object ValidCharsEdit: TDBEdit
          Left = 8
          Top = 64
          Width = 209
          Height = 21
          DataField = 'Metadata.ValidCharsString'
          DataSource = SubjectSource
          TabOrder = 1
        end
        object DefaultValueEdit: TDBEdit
          Left = 8
          Top = 184
          Width = 209
          Height = 21
          DataField = 'Metadata.DefaultValue'
          DataSource = SubjectSource
          TabOrder = 4
        end
      end
    end
  end
  inherited BottomPanel: TPanel
    Top = 340
    Width = 241
    ExplicitTop = 340
    ExplicitWidth = 241
    inherited ButtonPanel: TPanel
      Left = 81
      ExplicitLeft = 81
      inherited OkButton: TButton
        Left = 1
        Top = 2
        ExplicitLeft = 1
        ExplicitTop = 2
      end
      inherited CancelButton: TButton
        Left = 81
        Top = 2
        ExplicitLeft = 81
        ExplicitTop = 2
      end
    end
  end
  inherited SubjectExposer: TInstantExposer
    OnInitField = SubjectExposerInitField
    OnTranslate = SubjectExposerTranslate
    Left = 14
    Top = 284
  end
  inherited SubjectSource: TDataSource
    Left = 54
    Top = 284
  end
end
