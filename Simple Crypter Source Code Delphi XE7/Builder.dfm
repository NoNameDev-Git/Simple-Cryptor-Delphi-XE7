object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Cryptor'
  ClientHeight = 198
  ClientWidth = 324
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Times New Roman'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 14
  object sSpeedButton1: TsSpeedButton
    Left = 40
    Top = 132
    Width = 249
    Height = 25
    Caption = 'Build'
    OnClick = sSpeedButton1Click
  end
  object sSpeedButton2: TsSpeedButton
    Left = 40
    Top = 76
    Width = 249
    Height = 22
    Caption = 'Generate Key'
    OnClick = sSpeedButton2Click
  end
  object sEdit1: TsEdit
    Left = 40
    Top = 48
    Width = 249
    Height = 22
    TabStop = False
    Enabled = False
    TabOrder = 0
    BoundLabel.Active = True
    BoundLabel.ParentFont = False
    BoundLabel.Caption = 'Key'
  end
  object sSpinEdit1: TsSpinEdit
    Left = 40
    Top = 104
    Width = 57
    Height = 22
    TabStop = False
    TabOrder = 1
    Text = '10'
    BoundLabel.Active = True
    BoundLabel.ParentFont = False
    BoundLabel.Caption = 'Sec'
    MaxValue = 10000
    MinValue = 1
    Value = 10
  end
  object sFilenameEdit1: TsFilenameEdit
    Left = 40
    Top = 21
    Width = 249
    Height = 21
    TabStop = False
    AutoSize = False
    MaxLength = 255
    TabOrder = 2
    Text = ''
    CheckOnExit = True
    BoundLabel.Active = True
    BoundLabel.ParentFont = False
    BoundLabel.Caption = 'File'
    GlyphMode.Grayed = False
    GlyphMode.Blend = 0
  end
  object sStatusBar1: TsStatusBar
    Left = 0
    Top = 179
    Width = 324
    Height = 19
    Panels = <>
  end
  object sCheckBox1: TsCheckBox
    Left = 120
    Top = 106
    Width = 75
    Height = 18
    TabStop = False
    Caption = 'Add Bytes'
    TabOrder = 4
    OnClick = sCheckBox1Click
    ImgChecked = 0
    ImgUnchecked = 0
    ShowFocus = False
  end
  object sSpinEdit2: TsSpinEdit
    Left = 193
    Top = 104
    Width = 96
    Height = 22
    TabStop = False
    Enabled = False
    TabOrder = 5
    Text = '1000000'
    BoundLabel.ParentFont = False
    MaxValue = 9000000000000000
    MinValue = 1
    Value = 1000000
  end
  object sSaveDialog1: TsSaveDialog
    DefaultExt = '.exe'
    FileName = 'cryptfile'
    Filter = '.exe|*.exe'
    Left = 288
    Top = 136
  end
end
