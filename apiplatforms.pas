unit apiplatforms;

{$mode objfpc}{$M+}
{$H+}

interface

uses
  Classes, SysUtils, Dialogs, Forms,

{$IFDEF Windows}
Windows, JwaWinUser, JwaTlHelp32, Registry, sqlite3, sqlite3db,
{$endif}
{$IFDEF unix}
sqlite3, sqlite3db,
{$endif}
{$IFDEF Darwin}
{$ifdef ver2_2_0}
  FPCMacOSAll,
{$else}
  MacOSAll,
{$ENDIF}
{$ENDIF}
configuration, utils, md5, otlog, rules;

type

 TAPIDBR = array of TStringList;

 TOTSQL = Class
  private
   CFG: TOTConfig;
  public
   Records: TAPIDBR;
   constructor Create(mCFG: TOTConfig);
   function ExecSQL(query: string): boolean;
   function RecordsSQL(query: string): TAPIDBR;
 end;

 TPlatform = Class
  public
   constructor Create(mCFG: TOTConfig; lLog: TOTLog; mRules: TList); virtual; abstract;
   function WindowProcessPassFilters: boolean; virtual; abstract;
   function SQLExec(query: string): boolean;
   function SQLRecords(query: string): TAPIDBR;
   Log: TOTLog;
   Rules: TList;
  private
   CFG: TOTConfig;
   dbWPId, iteration: integer; {id in db for: window and process register}
   TimeStart: integer;


  protected
   function GetSecondsIdle: integer; virtual; abstract;
   procedure SetNewWindow; virtual; abstract;
   procedure SetNewProcess; virtual; abstract;
   function ChangedWindowProcess:boolean; virtual; abstract;
   procedure FinishCurrentWindowProcess; virtual; abstract;
   procedure UpdateCurrentWindowProcess; virtual; abstract;
   procedure SaveNewWindowProcess; virtual; abstract;
   procedure RunStartUp(enable: boolean); virtual; abstract;
   procedure OpenBrowser(url: string); virtual; abstract;
   function CheckFilters(StrFilters: string; Name: string): boolean;
   procedure SaveTrack(WName,PName: string);
   procedure FinishTrack(WName,PName: string);
   procedure UpdateTrack;
   function PassFilters(WName,PName: string): boolean;
 end;

{$IFDEF Windows}
  TWindowsPlatform = Class(TPlatform)
  private
   CurrentHWND: HWND;
   NewHWND: HWND;
   PID : dword;
   WindowTitle: array[0..255] of char;
   ProcessName: array[0..259] of char;
   RegExprChars: tstringlist;
  public
   constructor Create(mCFG: TOTConfig; lLog: TOTLog; mRules: TList); override;
   function WindowProcessPassFilters: boolean; override;
   function GetSecondsIdle: integer; override;
   procedure SetNewWindow; override;
   procedure SetNewProcess; override;
   function ChangedWindowProcess: boolean; override;
   procedure FinishCurrentWindowProcess; override;
   procedure UpdateCurrentWindowProcess; override;
   procedure SaveNewWindowProcess; override;
   procedure RunStartUp(enable: boolean); override;
   procedure OpenBrowser(url: string); override;
 end;
{$endif}

{$IFDEF unix}
  TUnixPlatform = Class(TPlatform)
  private
   CurrentWId: string;
   NewWId: string;

   CurrentWindowTitle: array[0..255] of char;
   CurrentProcessName: array[0..259] of char;
   NewWindowTitle: array[0..255] of char;
   NewProcessName: array[0..259] of char;

   RegExprChars: tstringlist;
  public
   constructor Create(mCFG: TOTConfig; lLog: TOTLog; mRules: TList); override;
   function WindowProcessPassFilters: boolean; override;
   function GetSecondsIdle: integer; override;
   procedure SetNewWindow; override;
   procedure SetNewProcess; override;
   function ChangedWindowProcess: boolean; override;
   procedure FinishCurrentWindowProcess; override;
   procedure UpdateCurrentWindowProcess; override;
   procedure SaveNewWindowProcess; override;
   procedure RunStartUp(enable: boolean); override;
 end;
{$endif}

function SQLCallback(Sender:pointer; plArgc:longint; argv:PPchar; argcol:PPchar):longint; cdecl;


implementation

 function TPlatform.PassFilters(WName,PName: string): boolean;
var
  AuxResult: boolean;
  TmpResult: boolean;
 begin

  WName := lowercase(trim(WName));
  PName := lowercase(trim(PName));

  IF strtobool(CFG.Get('PositiveFilters')) THEN BEGIN
   AuxResult := FALSE;

   IF Length(CFG.Get('FilterTrackWindows')) > 0 THEN BEGIN
     AuxResult := CheckFilters(CFG.Get('FilterTrackWindows'), WName);
     IF auxresult THEN
      log.add('Positive windows filters result for '+WName+':'+booltostr(auxresult,true));
   END;

   IF Length(CFG.Get('FilterTrackProcesses')) > 0 THEN BEGIN
      TmpResult := CheckFilters(CFG.Get('FilterTrackProcesses'), PName);
      IF TmpResult then
       log.add('Positive process names filters result for '+PName+':'+booltostr(TmpResult,true));
      AuxResult := AuxResult OR TmpResult;
   END

  END ELSE IF strtobool(CFG.Get('NegativeFilters')) THEN BEGIN
  IF Length(CFG.Get('FilterNoTrackWindows')) > 0 THEN BEGIN
     AuxResult := NOT CheckFilters(CFG.Get('FilterNoTrackWindows'), WName);
     IF NOT AuxResult THEN
      log.add('Negative windows filters result for '+WName+':'+booltostr(NOT auxresult,true));
   END;

   IF Length(CFG.Get('FilterNoTrackProcesses')) > 0 THEN BEGIN
      TmpResult := NOT CheckFilters(CFG.Get('FilterNoTrackProcesses'), PName);
      IF NOT TmpResult THEN
         log.add('Negative process names filters result for '+PName+':'+booltostr(NOT TmpResult,true));
      AuxResult := AuxResult AND TmpResult;
   END
  END;

  result := AuxResult;
 end;


 procedure TPlatform.UpdateTrack;
 begin
  {Updates each N seconds - performance issue}
  IF (iteration MOD strtoint(CFG.Get('UpdateFrequency'))) = 0 THEN BEGIN
   iteration := 0;
    self.SQLExec('UPDATE wp_track SET timeend = "'+IntToStr(UnixTime())+'", dtimeend = "'+FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)+'", seconds = '+IntToStr(UnixTime())+' - timestart WHERE id = '+IntToStr(dbWPId));
  END;
  iteration := iteration + 1;
 end;

 procedure TPlatform.FinishTrack(WName,PName: string);
 var
  idt, i: integer;
  rule: TRule;
  StopRule: boolean;

 begin
   IF UnixTime() - TimeStart >= strtoint(CFG.Get('MinTrackingSeconds')) THEN BEGIN

   idt := 0;
   StopRule := false;
   If Rules.Count > 0 THEN
    FOR i := 0 TO Rules.Count - 1 DO BEGIN
      IF NOT StopRule THEN BEGIN
        rule := TRule(Rules.Items[i]);
        idt := rule.Check(WName,PName);
        IF idt <> 0 THEN
           StopRule := TRUE;
      END;
    END;

    self.SQLExec('UPDATE wp_track SET idt = "'+IntToStr(idt)+'", timeend = "'+IntToStr(UnixTime())+'", dtimeend = "'+FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)+'", seconds = '+IntToStr(UnixTime())+' - timestart WHERE id = '+IntToStr(dbWPId));

    Log.add('Current Window Process finished');
   END
   ELSE BEGIN
     self.SQLExec('DELETE FROM wp_track WHERE id = '+IntToStr(dbWPId));
     Log.add('Current Window Process discard: Min tracking seconds: '+CFG.Get('MinTrackingSeconds'));
   END;
 end;

 procedure TPlatform.SaveTrack(WName,PName: string);
 var
  idw, idp, wpid: integer;
  records: TAPIDBR;
  rt: tstringlist;
  logstr: string;

 begin

  Log.Add('Saving ... '+WName+' '+PName);

  IF NOT strtobool(CFG.Get('NoSaveWindows')) THEN BEGIN

    self.SQLExec('INSERT INTO windows (title, md5) VALUES ("'+WName+'", "'+MD5Print(md5.MD5String(WName))+'")');

    { Get the window id in the db }
    records := self.SQLRecords('SELECT id FROM windows WHERE md5 = "'+MD5Print(md5.MD5String(WName))+'"');
    IF Length(records) > 0 THEN BEGIN
     rt := tstringlist(records[0]);
     idw := strtoint(rt.Values['id']);
    END ELSE BEGIN
     idw := 0;
    END;
  END;

  IF NOT strtobool(CFG.Get('NoSaveProcess')) THEN BEGIN

    self.SQLExec('INSERT INTO processes (name, md5) VALUES ("'+PName+'", "'+MD5Print(md5.MD5String(PName))+'")');

    { Get the process id in the db }
    records := self.SQLRecords('SELECT id FROM processes WHERE md5 = "'+MD5Print(md5.MD5String(PName))+'"');
    IF Length(records) > 0 THEN BEGIN
     rt := tstringlist(records[0]);
     idp := strtoint(rt.Values['id']);
    END
    ELSE BEGIN
     idp := 0;
    END;

  END;

  IF (idw > 0) OR (idp > 0) THEN BEGIN

    records := self.SQLRecords('SELECT COUNT(id) as total, MAX(id) as maxvalue FROM wp_track');
    rt := tstringlist(records[0]);

    IF strtoint(rt.Values['total']) = 0 THEN BEGIN
     wpid := 1;
    END
    ELSE BEGIN
     wpid := strtoint(rt.Values['total']) + 1;
    END;

    TimeStart := UnixTime();

    self.SQLExec('INSERT INTO wp_track (id,idw,idp,timestart,timeend, dtimestart, dtimeend, seconds) VALUES ("'+Inttostr(wpid)+'", "'+IntToStr(idw)+'", "'+IntToStr(idp)+'", "'+IntToStr(TimeStart)+'", "0", "'+FormatDateTime('yyyy-mm-dd hh:nn:ss',Now)+'", "0", "0")');

    logstr:='New Window Process started: ';
    IF NOT strtobool(CFG.Get('NoSaveWindows')) THEN
      logstr := logstr+' '+WName;

    IF NOT strtobool(CFG.Get('NoSaveProcess')) THEN
      logstr := logstr+' '+PName;

    Log.Add(logstr);

    dbWPId := wpid;

  END


 end;

 function TPlatform.CheckFilters(StrFilters: string; Name: string):boolean;
 var
  AuxResult, TmpResult: boolean;
  Filters: TStringList;
  currentFilter: string;
  i: integer;
 begin
     Filters := TStringList.Create;
     Split(',',StrFilters,Filters);
     AuxResult := FALSE;
     TmpResult := FALSE;

     IF Filters.Count > 0 THEN BEGIN
       FOR i:= 0 TO Filters.Count -1 DO BEGIN
        currentFilter := '';
        currentFilter := lowercase(Filters.Strings[i]);

        IF Pos('*',currentFilter) > 0 THEN BEGIN

         IF (Pos('*',currentFilter) = 1) AND (LastDelimiter('*',currentFilter) = Length(currentFilter))  THEN
          BEGIN
            IF Pos(StringReplace(currentFilter,'*','',[rfReplaceAll, rfIgnoreCase]),Name) > 0 THEN begin
               log.add('Filter match '+currentfilter+' - '+Name);
               TmpResult := TRUE;
            end
          END
         ELSE IF (Pos('*',currentFilter) = 1) THEN
          BEGIN
            IF Pos(StringReplace(currentFilter,'*','',[rfReplaceAll, rfIgnoreCase]),Name) = (Length(Name) - Length(currentFilter)) + 2 THEN
            begin
               log.add('Filter match '+currentfilter+' - '+Name);
               TmpResult := TRUE;
               end
          END;
         IF (Pos('*',currentFilter) = Length(currentFilter))  THEN
          BEGIN
             IF Pos(StringReplace(currentFilter,'*','',[rfReplaceAll, rfIgnoreCase]),Name) = 1 THEN  begin
               log.add('Filter match '+currentfilter+' - '+Name);
               TmpResult := TRUE;
               end
          END

        END ELSE BEGIN
         IF CompareText(StringReplace(currentFilter,'*','',[rfReplaceAll, rfIgnoreCase]),Name) = 0 THEN begin
          log.add('Filter match '+currentfilter+' - '+Name);
          TmpResult := TRUE;
          end
        END;
       END;
       AuxResult := TmpResult;
     END;
     Filters.Free;
     result := AuxResult;
 end;

 function TPlatform.SQLExec(query: string): boolean;
 var
  msql: TOTSQL;
 begin
   msql := TOTSQL.Create(self.CFG);
   result := msql.ExecSQL(query);
 end;

 function TPlatform.SQLRecords(query: string): TAPIDBR;
 var
  msql: TOTSQL;
 begin
   msql := TOTSQL.Create(self.CFG);
   result := msql.RecordsSQL(query);
 end;

 function SQLCallback(Sender:pointer; plArgc:longint; argv:PPchar; argcol:PPchar):longint; cdecl;
 var
    i: Integer;
    PVal, PName: ^PChar;
    rt: TStringList;
 begin

  with TObject(Sender) as TOTSQL do
  begin

   SetLength(Records, Length(Records) + 1);
   rt := TStringList.Create;
   PVal:=argv;
   PName:=argcol;
   for i:=0 to plArgc-1 do begin
    rt.values[StrPas(PName^)] := StrPas(PVal^);
    inc(PVal);
    inc(PName);
   end;
   Records[Length(Records) - 1] := rt;
   Result:=0;

  end

 end;

{$IFDEF Windows}
 {Implementation of TWindowsPlatform}

 constructor TWindowsPlatform.Create(mCFG: TOTConfig; lLog: TOTLog; mRules: TList);
 begin
   self.CFG := mCFG;
   CurrentHWND := 0;
   NewHWND := 0;
   dbWPId := 0;
   iteration := 0;
   Log := lLog;
   self.Rules := mRules;

   RegExprChars := TSTringList.create;
   Split(',','^,$,.,|,(,),[,],+,*,?,{,}',RegExprChars);
 end;

 function TWindowsPlatform.WindowProcessPassFilters: boolean;
 var

  REWindowTitle: array[0..255] of char;
  REProcessName: array[0..259] of char;
  Snap: Integer;
  PData    :TProcessEntry32;
 begin
  GetWindowText(NewHWND, REWindowTitle, 255);

  Snap:=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
  try
    PData.dwSize:=SizeOf(PData);
    if(Process32First(Snap,PData))then
    begin
    repeat
     if PData.th32ProcessID=PID then
     begin
       REProcessName := PData.szExeFile;
       Break;
     end;
    until not(Process32Next(Snap,PData));
    end;
  finally
  Windows.CloseHandle(Snap);
  end;

  result := PassFilters(PStr(REWindowTitle),PStr(REProcessName));
 end;

 function TWindowsPlatform.GetSecondsIdle: integer;
 var
   liInfo: TLastInputInfo;
 begin
   liInfo.cbSize := SizeOf(TLastInputInfo) ;
   GetLastInputInfo(liInfo) ;
   Result := (GetTickCount - liInfo.dwTime) DIV 1000;
 end;

 procedure TWindowsPlatform.SetNewWindow;
 begin
  NewHWND := GetForegroundWindow;
 end;

 procedure TWindowsPlatform.SetNewProcess;
  begin
   windows.GetWindowThreadProcessId(NewHWND,PID);
 end;

 function TWindowsPlatform.ChangedWindowProcess: boolean;
 var
  REWindowTitle: array[0..255] of char;
 begin
  IF NewHWND <> CurrentHWND THEN BEGIN
   result := TRUE;
  END
  ELSE BEGIN
    GetWindowText(NewHWND, REWindowTitle, 255);
    result := REWindowTitle <> WindowTitle;
  END
 end;

 procedure TWindowsPlatform.FinishCurrentWindowProcess;
 begin
  IF CurrentHWND > 0 THEN BEGIN

   FinishTrack(PStr(WindowTitle),PStr(ProcessName));

   CurrentHWND := 0;
   dbWPId := 0;
   TimeStart := 0;
   WindowTitle := '';
   ProcessName := '';
  END
 end;

 procedure TWindowsPlatform.UpdateCurrentWindowProcess;
 begin
  UpdateTrack;
 end;

 procedure TWindowsPlatform.SaveNewWindowProcess;
 var
  Snap: Integer;
  PData    :TProcessEntry32;
 begin
  CurrentHWND := NewHWND;

  GetWindowText(NewHWND, WindowTitle, 255);

  Snap:=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
  try
   PData.dwSize:=SizeOf(PData);
   if(Process32First(Snap,PData))then
   begin
     repeat
       if PData.th32ProcessID=PID then
       begin
         ProcessName := PData.szExeFile;
         Break;
       end;
     until not(Process32Next(Snap,PData));
   end;
   finally
     Windows.CloseHandle(Snap);
  end;

  SaveTrack(Pstr(WindowTitle),PStr(ProcessName));

 end;

 procedure TWindowsPlatform.RunStartUp(enable: boolean);
 var
   Registry: TRegistry;
   Key: string;
   Values: TStringList;
   n: integer;
   RegInfo      : TRegDataInfo;

 begin
  Key:='Software\Microsoft\Windows\CurrentVersion\Run';
  Registry:=TRegistry.Create;

  IF enable THEN BEGIN
   try
    Registry.OpenKey(Key,FALSE);
    Registry.WriteString('opentempus',Application.EXEName);
   finally
    Registry.Free;
   end
  END
  ELSE BEGIN
     try
       if Registry.OpenKey(key,FALSE) then begin

       Values:=TStringList.Create;
       try
         Registry.GetValueNames(Values);
         for n:=0 to Pred(Values.Count) do begin
           If Registry.GetDataInfo( Values[n], RegInfo) then begin
             if (RegInfo.RegData = rdString) then begin
                if Lowercase(Application.ExeName) = LowerCase(Registry.ReadString(Values[n])) then begin
                  Registry.DeleteValue( Values[n] );
                end;
             end;
           end;
         end;
       finally
         Values.Free;
       end;
       end;
     finally
       Registry.Free;
     end;
  END
 end;

 procedure TWindowsPlatform.OpenBrowser(url: string);
 begin
  ShellExecute(application.mainform.Handle,nil,PChar(url),'','',SW_SHOWNORMAL);
 end;

{$endif}


{Implementation of TUnixPlatform}

{$IFDEF unix}
 constructor TUnixPlatform.Create(mCFG: TOTConfig; lLog: TOTLog; mRules: TList);
 begin
  self.CFG := mCFG;

  CurrentWId := '';
  NewWId := '';
  CurrentWindowTitle := '';
  CurrentProcessName := '';
  NewWindowTitle := '';
  NewProcessName := '';

  iteration := 0;
  Log := lLog;
  self.Rules := mRules;

  RegExprChars := TSTringList.create;
  Split(',','^,$,.,|,(,),[,],+,*,?,{,}',RegExprChars);
 end;

 function TUnixPlatform.WindowProcessPassFilters: boolean;
 begin
  result := PassFilters(NewWindowTitle,NewProcessName);
 end;

 function TUnixPlatform.GetSecondsIdle: integer;
 begin
  result := 0;
 end;

 procedure TUnixPlatform.SetNewWindow;
 begin
  NewWId := '';
  NewWindowTitle := '';
  NewProcessName := '';
  //Call to script sh


 end;

 procedure TUnixPlatform.SetNewProcess;
 begin
  NewProcessName := NewProcessName;
 end;

 function TUnixPlatform.ChangedWindowProcess: boolean;
 begin
  IF NewWId <> CurrentWId THEN BEGIN
   result := TRUE;
  END
  ELSE BEGIN
    result := NewWindowTitle <> CurrentWindowTitle;
  END
 end;

 procedure TUnixPlatform.FinishCurrentWindowProcess;
 begin
  IF CurrentWId <> '' THEN BEGIN

   FinishTrack(CurrentWindowTitle,CurrentProcessName);

   CurrentWId := '';
   dbWPId := 0;
   TimeStart := 0;
   CurrentWindowTitle := '';
   CurrentProcessName := '';
  END
 end;

 procedure TUnixPlatform.UpdateCurrentWindowProcess;
 begin
  UpdateTrack;
 end;

 procedure TUnixPlatform.SaveNewWindowProcess;
 begin
  CurrentWId := NewWId;
  CurrentWindowTitle := NewWindowTitle;
  CurrentProcessName := NewProcessName;

  SaveTrack(CurrentWindowTitle,CurrentProcessName);

 end;

 procedure TUnixPlatform.RunStartUp(enable: boolean);
 begin

 end;

{$endif}


 constructor TOTSQL.Create(mCFG: TOTConfig);
 begin
  self.CFG := mCFG;
 end;

 function TOTSQL.ExecSQL(query: string): boolean;
 var
 rcc,rcq       : Integer;
 sdb       : PPsqlite3;
 pzErrMsg : PChar;
 rtmp: boolean;
// SL: TSQLite;

 begin
   rcc := sqlite3_open(PChar(CFG.DBPath), @sdb);
   rtmp := TRUE;
   try
    if rcc = SQLITE_OK then begin
     rcq := sqlite3_exec(sdb, PChar(query), nil, nil, @pzErrMsg);
     if rcq <> SQLITE_OK then begin
       //Log.Add(pzErrMsg+' '+query);
       rtmp := FALSE
      end
    end
    else begin
     rtmp:= false;
     //Log.Add(pzErrMsg+' '+query);
    end
   finally
    sqlite3_close(sdb);
   end;
   result := rtmp;

 end;

function TOTSQL.RecordsSQL(query: string): TAPIDBR;
 var
 rc      : Integer;
 sdb       : PPsqlite3;
 pzErrMsg : PChar;

 begin
    rc := sqlite3_open(PChar(CFG.DBPath), @sdb);
    try
    if rc = SQLITE_OK then begin
     SetLength(Records,0);
     rc := sqlite3_exec(sdb, PChar(query), @SQLCallback, Self, @pzErrMsg);
     if rc <> SQLITE_OK then begin
       //Log.Add(pzErrMsg+' '+query);
      end
    end
    else begin
     //Log.Add(pzErrMsg+' '+query);
    end
   finally
    sqlite3_close(sdb);
   end;

   result := Records;

end;

end.

