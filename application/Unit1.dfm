object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #1042#1099#1073#1086#1088' '#1076#1080#1088#1077#1082#1090#1086#1088#1080#1080
  ClientHeight = 228
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
  ShowHint = True
  OnClose = FormClose
  OnCreate = Form1Create
  OnShow = FormShow
  TextHeight = 15
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 441
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
    Hint = 
      #1042#1099#1073#1086#1088' '#1076#1080#1088#1077#1082#1090#1086#1088#1080#1080' '#13#10#1089' '#1086#1090#1089#1082#1072#1085#1080#1088#1086#1074#1072#1085#1085#1099#1084#1080' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1103#1084#1080' '#13#10#1076#1083#1103' '#1087#1088#1077#1086#1073#1088 +
      #1072#1079#1086#1074#1072#1085#1080#1103' '#1074' PDF '#1092#1072#1081#1083
    ParentShowHint = False
    ShowHint = True
    OnClick = Button1Click
  end
  object Label2: TLabel
    Left = 8
    Top = 57
    Width = 69
    Height = 15
    Caption = #1052#1077#1090#1072#1090#1077#1075' Title'
  end
  object Label3: TLabel
    Left = 8
    Top = 107
    Width = 33
    Height = 15
    Caption = #1040#1074#1090#1086#1088
  end
  object Bevel1: TBevel
    Left = 8
    Top = 183
    Width = 441
    Height = 4
    Shape = bsTopLine
    Style = bsRaised
  end
  object BitBtn1: TBitBtn
    Left = 285
    Top = 193
    Width = 75
    Height = 25
    Cursor = crHandPoint
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 0
    OnClick = BitBtn1Click
  end
  object BitBtn2: TBitBtn
    Left = 366
    Top = 193
    Width = 83
    Height = 25
    Cursor = crHandPoint
    Caption = #1054#1090#1084#1077#1085#1072
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 1
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 157
    Width = 433
    Height = 17
    Hint = #1054#1090#1082#1088#1099#1090#1100' '#1076#1080#1088#1077#1082#1090#1086#1088#1080#1102' '#1087#1086' '#1086#1082#1086#1085#1095#1072#1085#1080#1102' '#1087#1088#1086#1094#1077#1089#1089#1072
    Caption = #1054#1090#1082#1088#1099#1090#1100' '#1076#1080#1088#1077#1082#1090#1086#1088#1080#1102' '#1087#1086' '#1086#1082#1086#1085#1095#1072#1085#1080#1102' '#1087#1088#1086#1094#1077#1089#1089#1072
    TabOrder = 2
    OnClick = CheckBox1Click
  end
  object Edit1: TEdit
    Left = 8
    Top = 29
    Width = 410
    Height = 23
    ReadOnly = True
    TabOrder = 3
  end
  object Edit2: TEdit
    Left = 8
    Top = 78
    Width = 441
    Height = 23
    Hint = #1042#1074#1077#1076#1080#1090#1077' '#1079#1072#1075#1086#1083#1086#1074#1086#1082#13#10#1054#1090#1086#1073#1088#1072#1078#1072#1077#1090#1089#1103' '#1087#1088#1080' '#1086#1090#1082#1088#1099#1090#1080#1080' PDF '#1092#1072#1081#1083#1072
    TabOrder = 4
    OnChange = Edit2Change
  end
  object Edit3: TEdit
    Left = 8
    Top = 128
    Width = 441
    Height = 23
    Hint = #1040#1074#1090#1086#1088' '#1076#1086#1082#1091#1084#1077#1085#1090#1072
    TabOrder = 5
    OnChange = Edit3Change
  end
end
