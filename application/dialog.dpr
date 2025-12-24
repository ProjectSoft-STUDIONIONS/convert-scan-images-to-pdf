program dialog;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  Vcl.Forms, Vcl.dialogs, System.SysUtils, Vcl.Controls,
  System.JSON, Windows, System.UITypes,
  Unit1 in 'Unit1.pas' {Form1};
(***************************

  Пограмма возвращает строку JSON
  dir             Полный путь до директории с изображениями
  open            Открыть директорию после окончания
  title           Заголовок документа
  author          Автор документа
  Формат
  {"dir": "C:\\Temp\\ScanDir", "open": false, "title": "Заголовок", "author": "Автор", "error": 0}

  Индекс ошибок "error"
  0 - Ошибок нет
  1 - Программу завершил пользователь.

***************************)
var
  Handle         : THandle;
  jo             : TJsonObject;
  jsn            : string;
begin
  SetConsoleOutputCP(CP_UTF8);
  Handle         := GetForegroundWindow;
  jo  := TJsonObject.Create();
  try
    Application.Handle     := Handle;
    Form1                  := TForm1.Create(nil);
    Form1.HandleNeeded;
    EnableWindow(Handle, False);
    if IsPositiveResult(Form1.ShowModal) then
    begin
      jo.AddPair(TJSONPair.Create('dir',      Form1.Edit1.Text));
      jo.AddPair(TJSONPair.Create('open',     Form1.CheckBox1.Checked));
      jo.AddPair(TJSONPair.Create('title',    Trim(Form1.Edit2.Text)));
      jo.AddPair(TJSONPair.Create('author',   Trim(Form1.Edit3.Text)));
      jo.AddPair(TJSONPair.Create('error',    0));
    end
    else
    begin
      jo.AddPair(TJSONPair.Create('dir',      ''));
      jo.AddPair(TJSONPair.Create('open',     false));
      jo.AddPair(TJSONPair.Create('title',    ''));
      jo.AddPair(TJSONPair.Create('author',   ''));
      jo.AddPair(TJSONPair.Create('error',    1));
    end;
  finally
    jsn := jo.ToJSON();
    writeLn(jsn);
    jo.Free;
    Form1.Free;
    EnableWindow(Handle, True);
    SetForegroundWindow(Handle);
  end;
end.
