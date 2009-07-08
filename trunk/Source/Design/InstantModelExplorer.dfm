object InstantModelExplorerForm: TInstantModelExplorerForm
  Left = 385
  Top = 186
  Width = 259
  Height = 433
  VertScrollBar.Range = 20
  Caption = 'InstantObjects Model Explorer'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = 11
  Font.Name = 'MS Sans Serif'
  Font.Pitch = fpVariable
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ModelPanel: TPanel
    Left = 0
    Top = 27
    Width = 251
    Height = 372
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
  end
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 251
    Height = 27
    BorderWidth = 1
    ButtonHeight = 23
    Images = ActionImages
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    object SelectUnitsButton: TToolButton
      Left = 0
      Top = 0
      Action = SelectUnitsAction
    end
    object BuildDatabaseButton: TToolButton
      Left = 23
      Top = 0
      Action = BuildDatabaseAction
    end
    object ToolSep1: TToolButton
      Left = 46
      Top = 0
      Width = 8
      Caption = 'ToolSep1'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object ViewButton: TToolButton
      Left = 54
      Top = 0
      Action = ViewRelationsAction
    end
  end
  object ModelImages: TImageList
    Left = 104
    Top = 40
  end
  object TreeMenu: TPopupMenu
    Images = ActionImages
    OnPopup = TreeMenuPopup
    Left = 8
    Top = 40
    object NewClassItem: TMenuItem
      Action = NewClassAction
    end
    object EditClassItem: TMenuItem
      Action = EditClassAction
    end
    object DeleteClassItem: TMenuItem
      Action = DeleteClassAction
    end
    object ViewSourceItem: TMenuItem
      Action = ViewSourceAction
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object ExpandAllItem: TMenuItem
      Action = ExpandAllAction
    end
    object CollapseAllItem: TMenuItem
      Action = CollapseAllAction
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object RefreshItem: TMenuItem
      Action = RefreshAction
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object ImportModelItem: TMenuItem
      Action = ImportModelAction
    end
    object ExportModelItem: TMenuItem
      Action = ExportModelAction
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object AboutItem: TMenuItem
      Action = AboutAction
    end
  end
  object Actions: TActionList
    Images = ActionImages
    Left = 40
    Top = 40
    object EditClassAction: TAction
      Caption = '&Edit Class'
      Hint = 'Edit Class'
      ImageIndex = 6
      ShortCut = 32781
      OnExecute = EditClassActionExecute
    end
    object RefreshAction: TAction
      Caption = '&Refresh'
      Hint = 'Refresh'
      ImageIndex = 8
      ShortCut = 116
      OnExecute = RefreshActionExecute
    end
    object SelectUnitsAction: TAction
      Caption = 'Select &Units'
      Enabled = False
      Hint = 'Select Units'
      ImageIndex = 0
      OnExecute = SelectUnitsActionExecute
    end
    object BuildDatabaseAction: TAction
      Caption = '&Build InstantObjects Database...'
      Enabled = False
      Hint = 'Build Database'
      ImageIndex = 1
      OnExecute = BuildDatabaseActionExecute
    end
    object ViewInheritanceAction: TAction
      Caption = '&Inheritance'
      Hint = 'View Inheritance'
      ImageIndex = 2
      OnExecute = ViewInheritanceActionExecute
    end
    object ViewRelationsAction: TAction
      Caption = '&Relations'
      Hint = 'View Relations'
      ImageIndex = 3
      OnExecute = ViewRelationsActionExecute
    end
    object NewClassAction: TAction
      Caption = '&New Class...'
      Hint = 'New Class'
      ImageIndex = 4
      ShortCut = 45
      OnExecute = NewClassActionExecute
    end
    object DeleteClassAction: TAction
      Caption = '&Delete Class'
      Hint = 'Delete Class'
      ImageIndex = 9
      ShortCut = 46
      OnExecute = DeleteClassActionExecute
    end
    object ViewSourceAction: TAction
      Caption = 'View &Source'
      Hint = 'View Source'
      ImageIndex = 7
      ShortCut = 13
      OnExecute = ViewSourceActionExecute
    end
    object ExpandAllAction: TAction
      Caption = 'E&xpand All'
      Hint = 'Expand All'
      OnExecute = ExpandAllActionExecute
    end
    object CollapseAllAction: TAction
      Caption = '&Collapse All'
      Hint = 'Collapse All'
      OnExecute = CollapseAllActionExecute
    end
    object ImportModelAction: TAction
      Caption = '&Import Model...'
      Hint = 'Import model'
      ImageIndex = 11
      OnExecute = ImportModelActionExecute
    end
    object ExportModelAction: TAction
      Caption = '&Export Model...'
      Hint = 'Export Model'
      ImageIndex = 10
      OnExecute = ExportModelActionExecute
    end
    object AboutAction: TAction
      Caption = '&About InstantObjects...'
      Hint = 'About InstantObjects'
      OnExecute = AboutActionExecute
    end
  end
  object AttributeImages: TImageList
    Left = 136
    Top = 40
  end
  object ActionImages: TImageList
    Left = 72
    Top = 40
  end
end
