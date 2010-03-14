unit threadprocess;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
 {$IFDEF Windows}
  Windows,
 {$endif}
 otlog, Process;

type

  TShowStatusEvent = procedure(Status: String) of Object;

  TThreadProcess = class(TThread)
  private
   Log: TOTLog;
   Cmdline: string;
   Output: string;
   fStatusText : string;
   showM: boolean;
   procedure ShowStatus;

  public
   constructor Create(CreateSuspended: boolean; mcmdline: string; moutput: string; mLog: TOTLog; mshowM: boolean);
   FOnShowStatus: TShowStatusEvent;
   property OnShowStatus: TShowStatusEvent read FOnShowStatus write FOnShowStatus;
   procedure Execute; override;
  end;


implementation


constructor TThreadProcess.Create(CreateSuspended: boolean; mcmdline: string; moutput: string; mLog: TOTLog; mshowM: boolean);
begin
 self.Cmdline := mcmdline;
 self.Output := moutput;
 self.log := mLog;
 self.showM:= mshowM;

 FreeOnTerminate := True;
 inherited Create(CreateSuspended);
end;

procedure TThreadProcess.ShowStatus;
// this method is executed by the mainthread and can therefore access all GUI elements.
begin
  if Assigned(FOnShowStatus) then
  begin
    FOnShowStatus(fStatusText);
  end;
end;


procedure TThreadProcess.Execute;
var
 Process: TProcess;
 AStringList: TStringList;
begin

     AStringList := TStringList.Create;

     Process := TProcess.Create(nil);
     Process.CommandLine := self.cmdline;
     Process.Options := Process.Options + [poWaitOnExit, poUsePipes];
     Process.ShowWindow := swoHIDE;
     Process.Execute;
     AStringList.LoadFromStream(Process.Output);
     Log.add('Thread Finished'+AStringList.Text);
     fStatusText := AStringList.Text;

     AStringList.Free;
     Process.Free;

     IF (self.showM) AND (fStatusText <> '') THEN
          Synchronize(@Showstatus);

     IF self.Output <> '' THEN BEGIN
     {$IFDEF Windows}
     ShellExecute(self.Handle,nil,PChar(self.Output),'','',SW_SHOWNORMAL);
     {$endif}
     END

end;

end.

