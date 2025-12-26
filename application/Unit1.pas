unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  System.Generics.Collections, System.JSON, System.IOUtils,
  System.RegularExpressions,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons,
  Vcl.FileCtrl, Vcl.StdCtrls, Vcl.ExtCtrls,
  ShlObj, IniFiles;

type
  TForm1 = class(TForm)
    BitBtn1                 : TBitBtn;
    BitBtn2                 : TBitBtn;
    CheckBox1               : TCheckBox;
    Edit1                   : TEdit;
    Edit2                   : TEdit;
    Edit3                   : TEdit;
    Label1                  : TLabel;
    Label2                  : TLabel;
    Label3                  : TLabel;
    Bevel1: TBevel;
    BitBtn3: TBitBtn;
    procedure Form1Create(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure Edit3Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    author    : string;
    directory : string;
    open      : Boolean;
    title     : string;
  end;

var
  Form1       : TForm1;
implementation

{$R *.dfm}

var
  ini         : TIniFile;
  appPath     : string;
  iniFile     : string;
  titleSelect : string;

function decodeText(s: string):string;
begin
  Result := TRegEx.Replace(s, '((?:#13)?#10)', #13#10);
end;

function encodeText(s: string):string;
begin
  Result := TRegEx.Replace(s, '\r?\n', '#13#10');
end;

function BrowseCallbackProc(hwnd: HWND; MessageID: UINT; lParam: LPARAM; lpData: LPARAM): Integer; stdcall;
var
    DirName : array[0..MAX_PATH] of Char;
    pIDL    : pItemIDList;
begin
  case  MessageID    of
    BFFM_INITIALIZED:
      SendMessage(hwnd, BFFM_SETSELECTION, 1, lpData);
    BFFM_SELCHANGED :
      begin
        pIDL := Pointer(lParam);
        if Assigned(PIDL) then
        begin
          SHGetPathFromIDList(pIDL, DirName);
          if System.SysUtils.DirectoryExists(DirName) then
            SendMessage(hwnd, BFFM_ENABLEOK, 0, 1) //enable the ok button
          else
            SendMessage(hwnd, BFFM_ENABLEOK, 0, 0);
          end
        else
          SendMessage(hwnd, BFFM_ENABLEOK, 0, 0);
      end;
  end;
  Result := 0;
end;

function SelectFolderDialogExt(Handle: Integer; Title: string; var SelectedFolder: string): Boolean;
var
  ItemIDList  : PItemIDList;
  JtemIDList  : PItemIDList;
  DialogInfo  : TBrowseInfo;
  Path        : PWideChar;
begin
  Result := False;
  Path   := StrAlloc(MAX_PATH);
  SHGetSpecialFolderLocation(Handle, CSIDL_DRIVES, JtemIDList);
  with DialogInfo do
  begin
    pidlRoot      := JtemIDList;
    ulFlags       := BIF_RETURNONLYFSDIRS or BIF_USENEWUI;
    hwndOwner     := GetActiveWindow;
    SHGetSpecialFolderLocation(hwndOwner, CSIDL_DRIVES, JtemIDList);
    pszDisplayName:= StrAlloc(MAX_PATH);
    lpszTitle     := PChar(Title);
    lpfn          := @BrowseCallbackProc;
    lParam        := LongInt(PChar(SelectedFolder));
  end;
  ItemIDList := SHBrowseForFolder(DialogInfo);
  if (ItemIDList <> nil) then
    if SHGetPathFromIDList(ItemIDList, Path) then
    begin
      SelectedFolder := Path;
      Result         := True;
    end;
end;

function GetLocaleInformation(Flag: Integer): string;
var
  pcLCA: array [0..20] of Char;
begin
  if GetLocaleInfo(LOCALE_SYSTEM_DEFAULT, Flag, pcLCA, 19) <= 0 then
    pcLCA[0] := #0;
  Result := LowerCase(pcLCA);
end;

function IsStringEmpty(s: Widestring): Boolean;
begin
  Result := Trim(s) = '';
end;

procedure TForm1.Form1Create(Sender: TObject);
begin
  (*******************
  ********************)
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ini          := TIniFile.Create(iniFile);
  ini.WriteString('lang', 'title',              encodeText(Form1.Caption));
  ini.WriteString('lang', 'select.title',       encodeText(titleSelect));
  ini.WriteString('lang', 'label1.caption',     encodeText(Label1.Caption));
  ini.WriteString('lang', 'label2.caption',     encodeText(Label2.Caption));
  ini.WriteString('lang', 'label3.caption',     encodeText(Label3.Caption));
  ini.WriteString('lang', 'button1.hint',       encodeText(BitBtn3.Hint));
  ini.WriteString('lang', 'edit2.hint',         encodeText(Edit2.Hint));
  ini.WriteString('lang', 'edit3.hint',         encodeText(Edit3.Hint));
  ini.WriteString('lang', 'edit2.texthint',     encodeText(Edit2.TextHint));
  ini.WriteString('lang', 'edit3.texthint',     encodeText(Edit3.TextHint));
  ini.WriteString('lang', 'bitbtn1.caption',    encodeText(BitBtn1.Caption));
  ini.WriteString('lang', 'bitbtn2.caption',    encodeText(BitBtn2.Caption));
  ini.Free;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  appPath      := ExtractFilePath(Application.ExeName);
  iniFile      := TPath.Combine(appPath, 'dialog.ini');
  ini          := TIniFile.Create(iniFile);
  author       := Trim(ini.ReadString('settings', 'author', ''));
  title        := Trim(ini.ReadString('settings', 'title', ''));
  directory    := ini.ReadString('settings', 'directory', '');
  open         := ini.ReadBool('settings', 'open', false);

  Form1.Caption  := decodeText(Trim(ini.ReadString('lang', 'title',               'Выбор директории')));

  Label1.Caption  := decodeText(Trim(ini.ReadString('lang', 'label1.caption',     'Директория')));
  Label2.Caption  := decodeText(Trim(ini.ReadString('lang', 'label2.caption',     'Метатег Title')));
  Label3.Caption  := decodeText(Trim(ini.ReadString('lang', 'label3.caption',     'Автор')));
  BitBtn3.Hint    := decodeText(Trim(ini.ReadString('lang', 'button1.hint',       'Выбор директории#13#10с отсканированными изображениями#13#10для преобразования в PDF файл')));
  Edit2.Hint      := decodeText(Trim(ini.ReadString('lang', 'edit2.hint',         'Введите заголовок#13#10Отображается при открытии PDF файла')));
  Edit3.Hint      := decodeText(Trim(ini.ReadString('lang', 'edit3.hint',         'Автор документа')));
  Edit2.TextHint  := decodeText(Trim(ini.ReadString('lang', 'edit2.texthint',     'Введите Заголовок Документа')));
  Edit3.TextHint  := decodeText(Trim(ini.ReadString('lang', 'edit3.texthint',     'Введите Автора Документа')));
  titleSelect     := decodeText(Trim(ini.ReadString('lang', 'select.title',       'Выберите директорию с отсканированными изображениями для преобразования в PDF файл')));
  BitBtn1.Caption := decodeText(Trim(ini.ReadString('lang', 'bitbtn1.caption',    'OK')));
  BitBtn2.Caption := decodeText(Trim(ini.ReadString('lang', 'bitbtn2.caption',    'Отмена')));

  ini.Free;

  if System.SysUtils.DirectoryExists(directory) = False then
  begin
    directory := '';
  end;
  Edit1.Text   := directory;
  CheckBox1.Checked := open;
  Edit2.Text   := title;
  Edit3.Text   := author;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  ini          := TIniFile.Create(iniFile);
  ini.WriteString('settings', 'directory', directory);
  ini.WriteBool('settings', 'open', open);
  ini.WriteString('settings', 'author', author);
  ini.WriteString('settings', 'title', title);
  ini.Free;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  SelectFolderDialogExt(Handle, titleSelect, directory);
  Edit1.Text := directory;
  if (title = '') then
  begin
    if directory.IsEmpty = false then
    begin
      title := Trim(Copy(directory, LastDelimiter('\', directory) + 1, MaxInt));
      Edit2.Text := title;
    end;
  end;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  open := CheckBox1.Checked;
end;

procedure TForm1.Edit2Change(Sender: TObject);
begin
  title := Trim(Edit2.Text);
end;

procedure TForm1.Edit3Change(Sender: TObject);
begin
  author := Trim(Edit3.Text);
end;

end.
