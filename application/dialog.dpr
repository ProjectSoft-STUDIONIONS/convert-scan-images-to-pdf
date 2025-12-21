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
  Формат
  {"dir": "C:\\Temp\\ScanDir", "open": false, "error": 0}

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
  try
    Application.Handle     := Handle;
    Form1                  := TForm1.Create(nil);
    Form1.HandleNeeded;
    EnableWindow(Handle, False);
    if IsPositiveResult(Form1.ShowModal) then
    begin
      jo  := TJsonObject.Create();
      jo.AddPair(TJSONPair.Create('dir', Form1.Edit1.Text));
      jo.AddPair(TJSONPair.Create('open', Form1.CheckBox1.Checked));
      jo.AddPair(TJSONPair.Create('error', 0));
      jsn := jo.ToJSON();
      jo.Free;
      writeLn(jsn);
    end
    else
    begin
      writeLn('{"dir": "", "open": false, "error": 1}');
    end;
  finally
    Form1.Free;
    EnableWindow(Handle, True);
    SetForegroundWindow(Handle);
  end;
end.
