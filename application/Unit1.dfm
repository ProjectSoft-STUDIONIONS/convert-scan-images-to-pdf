object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #1042#1099#1073#1086#1088' '#1076#1080#1088#1077#1082#1090#1086#1088#1080#1080
  ClientHeight = 111
  ClientWidth = 455
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Padding.Left = 5
  Padding.Top = 5
  Padding.Right = 10
  Padding.Bottom = 5
  Position = poMainFormCenter
  OnCreate = Form1Create
  OnShow = FormShow
  TextHeight = 15
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 433
    Height = 15
    Margins.Left = 10
    Margins.Top = 10
    Margins.Right = 10
    AutoSize = False
    Caption = #1044#1080#1088#1077#1082#1090#1086#1088#1080#1103
  end
  object Button1: TSpeedButton
    Left = 424
    Top = 29
    Width = 23
    Height = 22
    Cursor = crHandPoint
    OnClick = Button1Click
  end
  object BitBtn1: TBitBtn
    Left = 285
    Top = 81
    Width = 75
    Height = 25
    Cursor = crHandPoint
    Caption = 'OK'
    Default = True
    ModalResult = 1
    NumGlyphs = 2
    TabOrder = 0
    OnClick = BitBtn1Click
  end
  object BitBtn2: TBitBtn
    Left = 366
    Top = 81
    Width = 83
    Height = 25
    Cursor = crHandPoint
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 1
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 58
    Width = 433
    Height = 17
    Caption = #1054#1090#1082#1088#1099#1090#1100' '#1076#1080#1088#1077#1082#1090#1086#1088#1080#1102' '#1087#1086' '#1086#1082#1086#1085#1095#1072#1085#1080#1102' '#1087#1088#1086#1094#1077#1089#1089#1072
    TabOrder = 2
    OnClick = CheckBox1Click
  end
  object Edit1: TEdit
    Left = 8
    Top = 28
    Width = 410
    Height = 23
    ReadOnly = True
    TabOrder = 3
  end
end
