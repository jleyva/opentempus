unit spreadsheet;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3ds, otlog, configuration, utils, dateutils;

type

  TSRow = record
   idwp: integer;
   windowtitle: string;
   processname: string;
   seconds: integer;
   timestart: string;
   timeend: string;
  end;

 TStorageSpreadSheet = class(TThread)
  private
  function addrow(filepath: string; row: tsrow):boolean;
  function getfilepath(timestart: string):string;
  public
  LOG: totlog;
  CFG: Totconfig;
  DB: TSqlite3Dataset;
  procedure Execute; override;
  Constructor Create(CreateSuspended: boolean; lLOG: totlog; lCFG: Totconfig; lDB: TSqlite3Dataset);
 end;

implementation

Constructor TStorageSpreadSheet.Create(CreateSuspended : boolean; lLOG: totlog; lCFG: Totconfig; lDB: TSqlite3Dataset);
begin
 LOG := lLOG;
 CFG := lCFG;;
 DB := lDB;
 FreeOnTerminate := True;
 inherited Create(CreateSuspended);
end;

function TStorageSpreadSheet.getfilepath(timestart: string): string;
var
 filename,extension: string;
 dateparts: tstringlist;
 week: integer;
begin
 dateparts := tstringlist.create;
 IF CFG.GET('SpreadsheetPeriod') = 'Each Day' THEN BEGIN
  Split(' ',timestart,dateparts);
  filename := dateparts.Strings[0];
 END
 ELSE  IF CFG.GET('SpreadsheetPeriod') = 'Each Week' THEN BEGIN
  Split(' ',timestart,dateparts);
  Split('-',dateparts[0],dateparts);
  week := WeekOfTheYear(EncodeDateTime(StrToInt(dateparts[0]),StrToInt(dateparts[1]),StrToInt(dateparts[2]),0,0,0,0));
  filename := dateparts[0]+'_week_'+inttostr(week);
 END
 ELSE  IF CFG.GET('SpreadsheetPeriod') = 'Each Month' THEN BEGIN
  Split(' ',timestart,dateparts);
  Split('-',dateparts[0],dateparts);
  filename := dateparts[0]+'_month_'+dateparts[1];
 END
 ELSE  IF CFG.GET('SpreadsheetPeriod') = 'Each Year' THEN BEGIN
  Split(' ',timestart,dateparts);
  Split('-',dateparts[0],dateparts);
  filename := dateparts[0];
 END;

 result := CFG.GET('SpreadsheetDirPath')+DirectorySeparator+'opentempus_'+filename+'.'+LowerCase(CFG.GET('SpreadsheetFormat'));
end;

function TStorageSpreadSheet.addrow(filepath: string; row: tsrow):boolean;
var
  F: TFileStream;
  //F: TextFile;
  nrow: string;
  Separator: string;
  NewLine: string;
begin
  try
    try
    //AssignFile(F,filepath);
    IF NOT FileExists(filepath) THEN BEGIN
     F := TFileStream.Create(filepath, fmCreate);
     //Rewrite(F);
    END
    ELSE BEGIN
     F := TFileStream.Create(filepath, fmOpenWrite);
     F.Position := F.Size;
     //Append(F);
    END;

    IF LowerCase(CFG.GET('SpreadsheetFormat')) = 'csv' THEN BEGIN
     Separator := ';';
     NewLine := CHR(13);
     StringReplace(row.windowtitle,';',',',[rfReplaceAll, rfIgnoreCase]);
     StringReplace(row.processname,';',',',[rfReplaceAll, rfIgnoreCase]);
     StringReplace(row.windowtitle,'"','""',[rfReplaceAll, rfIgnoreCase]);
     StringReplace(row.processname,'"','""',[rfReplaceAll, rfIgnoreCase]);
     nrow := '"'+row.windowtitle+'"'+Separator+'"'+row.processname+'"'+Separator+inttostr(row.seconds)+Separator+row.timestart+Separator+row.timeend+NewLine;
    END
    ELSE BEGIN
     Separator := CHR(9);
     NewLine := LineEnding;
     nrow := row.windowtitle+Separator+row.processname+Separator+inttostr(row.seconds)+Separator+row.timestart+Separator+row.timeend+NewLine;
    END;
    //WriteLn(F,nrow);
    F.Write(Pchar(nrow)^,Length(nrow));
    finally
     F.Free;
     //CloseFile(F);
    end;
  except
   on E: Exception do
    Log.add('Exception: FilePath '+filepath+' '+E.ClassName+' '+E.Message);
  end;
  result := TRUE;
end;

procedure TStorageSpreadSheet.Execute;
var
 rows: array of TSRow;
 i: integeR;
 sqlquery: string;
 lDB: TSqlite3Dataset;
 filepath: string;
begin

  lDB := TSqlite3Dataset.Create(DB.Owner);
  lDB.FileName:=DB.FileName;

  Log.Add('Starting Spreadsheet storage');
  i := 0;

  try
  lDB.SQL := 'SELECT idwp, t.seconds, strftime("%Y-%m-%d %H:%M:%S",dtimestart) as ts, strftime("%Y-%m-%d %H:%M:%S",dtimeend) as te, '+'w.title, p.name FROM storedata_wpt wpt, wp_track t, windows w, processes p WHERE wpt.idwp = t.id AND wpt.savespreadsheet = 0 AND t.idw = w.id AND t.idp = p.id';
    try
      lDB.Open;
      IF lDB.RecordCount > 0 THEN BEGIN
       SetLength(rows, lDB.RecordCount);
       lDB.first;
       WHILE (NOT Terminated) AND (NOT lDB.EOF) DO BEGIN
        rows[i].idwp := lDB.FieldByName('idwp').AsInteger;
        rows[i].seconds := lDB.FieldByName('seconds').AsInteger;
        rows[i].timestart := lDB.FieldByName('ts').AsString;
        rows[i].timeend := lDB.FieldByName('te').AsString;
        rows[i].windowtitle := lDB.FieldByName('title').AsString;
        rows[i].processname := lDB.FieldByName('name').AsString;
        Inc(i);
        lDB.Next;
       END;
      END;
    finally
    lDB.close;
    end;
  except
   on E: Exception do
    Log.add('Exception: '+E.ClassName+' '+E.Message);
  end;

  Log.Add('Upgrading Spreadsheet '+inttostr(Length(rows)));

  IF Length(rows) > 0 THEN BEGIN
    i := 0;
    WHILE (NOT Terminated) AND (i < Length(rows) - 1) DO BEGIN
        filepath := getfilepath(rows[i].timestart);
        IF addrow(filepath, rows[i]) THEN BEGIN
          try
          lDB.ExecSQL('UPDATE storedata_wpt SET savespreadsheet = 1 WHERE idwp = '+inttostr(rows[i].idwp));
          except
           on E: Exception do
            Log.add('Exception: FilePath '+filepath+' '+E.ClassName+' '+E.Message);
          end;
         END;
        Inc(i);
    END;
  END;

  Log.Add('Finished Spreadsheet storage');

end;

end.

