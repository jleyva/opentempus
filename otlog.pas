unit otlog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dialogs, configuration;

type
 TOTLog = class
 private
  LogFile: TextFile;
  LogFilePath: string;
  ShowDateTime: boolean;
  CFG: totconfig;
 public
   constructor Create(lCFG: totconfig; lShowDateTime: boolean);
   procedure add(line: string);
 end;

implementation

 constructor TOTLog.Create(lCFG: totconfig; lShowDateTime: boolean);
 begin
   ShowDateTime := lShowDateTime;
   CFG := lCFG;
   LogFilePath := CFG.LogPath;
   IF NOT FileExists(LogFilePath) THEN BEGIN
      AssignFile(LogFile,LogFilePath);
      Rewrite(LogFile);
      WriteLn(LogFile,'');
      CloseFile(LogFile);
   END
 end;

 procedure TOTLog.add(line: string);
 begin
  IF self.ShowDateTime = TRUE THEN
   line := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)+' - '+line;
  IF (strtobool(CFG.Get('ActivateLoging'))) AND (FileExists(LogFilePath)) THEN BEGIN
   try
    AssignFile(LogFile,LogFilePath);
    Append(LogFile);
    WriteLn(LogFile,line);
   finally
    CloseFile(LogFile);
   end
  END
 end;


end.

