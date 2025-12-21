unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, System.Generics.Collections,
    System.JSON, System.IOUtils, Vcl.Graphics, FileCtrl, IniFiles,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons,
    System.ImageList,  ShlObj, Vcl.ImgList,
    Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    CheckBox1               : TCheckBox;
    Label1                  : TLabel;
    Edit1                   : TEdit;
    BitBtn1                 : TBitBtn;
    BitBtn2                 : TBitBtn;
    Button1                 : TSpeedButton;
    procedure Form1Create(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    directory : string;
    open      : Boolean;
  end;

var
  Form1       : TForm1;
implementation

{$R *.dfm}

var
  ini         : TIniFile;
  appPath     : string;
  iniFile     : string;
  folder      : TBitmap;
function BrowseCallbackProc(hwnd: HWND; MessageID: UINT; lParam: LPARAM; lpData: LPARAM): Integer; stdcall;
var
    DirName : array[0..MAX_PATH] of Char;
    pIDL    : pItemIDList;
begin
  case  MessageID    of
    BFFM_INITIALIZED: SendMessage(hwnd, BFFM_SETSELECTION, 1, lpData);
    BFFM_SELCHANGED : begin
                         pIDL := Pointer(lParam);
                         if  Assigned(PIDL) then
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
    ulFlags       := BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE or BIF_EDITBOX;
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

procedure TForm1.Form1Create(Sender: TObject);
begin
  (*******************
  ********************)
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  appPath      := ExtractFilePath(Application.ExeName);
  iniFile      := TPath.Combine(appPath, 'dialog.ini');
  ini          := TIniFile.Create(iniFile);
  directory    := ini.ReadString('settings', 'directory', '');
  open         := ini.ReadBool('settings', 'open', false);
  ini.Free;
  Edit1.Text   := directory;
  CheckBox1.Checked := open;
  try
    folder       := TBitmap.Create;
    folder.LoadFromResourceName(HInstance, 'CURRENTFOLDER');
    Button1.Glyph.Assign(folder);
  finally
    folder.Free;
  end;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  ini          := TIniFile.Create(iniFile);
  ini.WriteString('settings', 'directory', directory);
  ini.WriteBool('settings', 'open', open);
  ini.Free;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if SelectFolderDialogExt(Handle, 'Title', directory) then
  begin
    Edit1.Text := directory;
  end
  else
  begin
    directory := '';
    Edit1.Text := directory;
  end;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  open := CheckBox1.Checked;
end;

end.
