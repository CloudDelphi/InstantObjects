inherited InstantClassEditorForm: TInstantClassEditorForm
  Left = 319
  Top = 196
  Width = 397
  Height = 325
  Caption = 'Class Editor'
  OldCreateOrder = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited EditPanel: TPanel
    Width = 389
    Height = 260
    object PageControl: TPageControl
      Left = 4
      Top = 4
      Width = 381
      Height = 252
      ActivePage = ClassSheet
      Align = alClient
      TabOrder = 0
      object ClassSheet: TTabSheet
        Caption = 'Class'
        OnResize = ClassSheetResize
        object ClassNameLabel: TLabel
          Left = 16
          Top = 16
          Width = 56
          Height = 13
          Caption = 'Class &Name'
          FocusControl = ClassNameEdit
        end
        object BaseClassLabel: TLabel
          Left = 16
          Top = 64
          Width = 52
          Height = 13
          Caption = '&Base Class'
          FocusControl = BaseClassEdit
        end
        object UnitLabel: TLabel
          Left = 16
          Top = 112
          Width = 19
          Height = 13
          Caption = '&Unit'
          FocusControl = UnitEdit
        end
        object StorageLabel: TLabel
          Left = 152
          Top = 160
          Width = 68
          Height = 13
          Caption = '&Storage Name'
          FocusControl = StorageEdit
        end
        object PersistenceLabel: TLabel
          Left = 16
          Top = 160
          Width = 55
          Height = 13
          Caption = '&Persistence'
          FocusControl = PersistenceComboBox
        end
        object ClassNameEdit: TDBEdit
          Left = 16
          Top = 32
          Width = 353
          Height = 21
          DataField = 'Name'
          DataSource = SubjectSource
          TabOrder = 0
          OnChange = ClassNameEditChange
        end
        object BaseClassEdit: TDBComboBox
          Left = 16
          Top = 80
          Width = 353
          Height = 21
          DataField = 'BaseClassName'
          DataSource = SubjectSource
          ItemHeight = 13
          Sorted = True
          TabOrder = 1
        end
        object UnitEdit: TDBComboBox
          Left = 16
          Top = 128
          Width = 353
          Height = 21
          Style = csDropDownList
          DataField = 'UnitName'
          DataSource = SubjectSource
          ItemHeight = 13
          TabOrder = 2
        end
        object StorageEdit: TDBEdit
          Left = 152
          Top = 176
          Width = 217
          Height = 21
          DataField = 'StorageName'
          DataSource = SubjectSource
          TabOrder = 4
        end
        object PersistenceComboBox: TDBComboBox
          Left = 16
          Top = 176
          Width = 121
          Height = 21
          Style = csDropDownList
          DataField = 'Persistence'
          DataSource = SubjectSource
          ItemHeight = 13
          TabOrder = 3
          OnChange = PersistenceComboBoxChange
        end
      end
      object AttributeSheet: TTabSheet
        BorderWidth = 4
        Caption = 'Attributes'
        ImageIndex = 1
        object AttributesSplitter: TSplitter
          Left = 0
          Top = 111
          Width = 365
          Height = 3
          Cursor = crVSplit
          Align = alBottom
        end
        object InheritedAttributesPanel: TPanel
          Left = 0
          Top = 114
          Width = 365
          Height = 109
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 1
          object InheritedAttributesLabel: TLabel
            Left = 0
            Top = 0
            Width = 365
            Height = 16
            Align = alTop
            AutoSize = False
            Caption = 'Inherited'
          end
          object InheritedAttributesView: TListView
            Left = 0
            Top = 16
            Width = 365
            Height = 93
            Align = alClient
            Columns = <
              item
                AutoSize = True
                Caption = 'Name'
              end
              item
                AutoSize = True
                Caption = 'Type'
              end>
            ReadOnly = True
            TabOrder = 0
            ViewStyle = vsReport
            OnEdited = IntroducedAttributesViewEdited
          end
        end
        object IntroducedAttributesPanel: TPanel
          Left = 0
          Top = 0
          Width = 365
          Height = 104
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 0
          object IntroducedAttributesLabel: TLabel
            Left = 0
            Top = 0
            Width = 365
            Height = 16
            Align = alTop
            AutoSize = False
            Caption = 'Introduced'
          end
          object IntroducedAttributesView: TListView
            Left = 0
            Top = 16
            Width = 365
            Height = 95
            Align = alClient
            Columns = <
              item
                AutoSize = True
                Caption = 'Name'
              end
              item
                AutoSize = True
                Caption = 'Type'
              end>
            ReadOnly = True
            PopupMenu = AttributesMenu
            TabOrder = 0
            ViewStyle = vsReport
            OnDblClick = IntroducedAttributesViewDblClick
            OnEdited = IntroducedAttributesViewEdited
          end
        end
      end
    end
  end
  inherited BottomPanel: TPanel
    Top = 260
    Width = 389
    inherited ButtonPanel: TPanel
      Left = 229
    end
  end
  inherited SubjectExposer: TInstantExposer
    AfterPostField = SubjectExposerAfterPostField
    OnTranslate = SubjectExposerTranslate
    Top = 268
  end
  inherited SubjectSource: TDataSource
    Top = 268
  end
  object AttributeImages: TImageList
    Left = 68
    Top = 268
  end
  object StateImages: TImageList
    Left = 100
    Top = 268
  end
  object AttributesMenu: TPopupMenu
    Images = ActionImages
    OnPopup = AttributesMenuPopup
    Left = 164
    Top = 268
    object AttributeNewItem: TMenuItem
      Action = AttributeNewAction
      ShortCut = 45
    end
    object AttributeDeleteItem: TMenuItem
      Action = AttributeDeleteAction
      ShortCut = 46
    end
    object AttributeEditItem: TMenuItem
      Action = AttributeEditAction
      ShortCut = 32781
    end
  end
  object Actions: TActionList
    Images = ActionImages
    Left = 196
    Top = 268
    object AttributeNewAction: TAction
      Caption = '&New'
      Hint = 'New Attribute'
      ImageIndex = 0
      OnExecute = AttributeNewActionExecute
    end
    object AttributeDeleteAction: TAction
      Caption = '&Delete'
      Hint = 'Delete'
      ImageIndex = 1
      OnExecute = AttributeDeleteActionExecute
    end
    object AttributeEditAction: TAction
      Caption = '&Edit'
      Hint = 'Edit'
      ImageIndex = 2
      OnExecute = AttributeEditActionExecute
    end
  end
  object ActionImages: TImageList
    Left = 132
    Top = 268
  end
end
