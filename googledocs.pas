unit googledocs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3ds, otlog, configuration, utils, dateutils, spreadsheet, httpsend, synautil, ssl_openssl;

type

 TStorageGoogleDocs = class(TThread)
  private
   CacheSS: Tstringlist;
   CacheWS: Tstringlist;
   CacheDocs: string;
   GAuthDocs: string;
   GAuthSpreadSheets: string;
   procedure CreateCache;
   function GetGAuthDocs:boolean;
   function GetGAuthSpreadSheets: boolean;
   function GetSSKey(timestart: string):string;
   function GetWSKey(timestart: string; spreadsheetkey: string):string;
   function AddRow(spreadsheetkey,worksheetkey:string; row: TSRow):boolean;
  public
   LOG: totlog;
   CFG: Totconfig;
   DB: TSqlite3Dataset;
   procedure Execute; override;
   Constructor Create(CreateSuspended: boolean; lLOG: totlog; lCFG: Totconfig; lDB: TSqlite3Dataset);
 end;

implementation

Constructor TStorageGoogleDocs.Create(CreateSuspended : boolean; lLOG: totlog; lCFG: Totconfig; lDB: TSqlite3Dataset);
begin
 LOG := lLOG;
 CFG := lCFG;;
 DB := lDB;
 CacheDocs := '';
 FreeOnTerminate := True;
 inherited Create(CreateSuspended);
end;

procedure TStorageGoogleDocs.CreateCache;
var
 ldb: TSqlite3Dataset;
begin

  lDB := TSqlite3Dataset.Create(DB.Owner);
  lDB.FileName:=DB.FileName;

  CacheSS := TStringList.Create;

  try
   lDB.SQL := 'SELECT * FROM storedata_gdss';
    try
      lDB.Open;
      IF lDB.RecordCount > 0 THEN BEGIN
       lDB.first;
       WHILE (NOT Terminated) AND (NOT lDB.EOF) DO BEGIN
        CacheSS.Add(lDB.FieldByName('name').AsString+'='+lDB.FieldByName('key').AsString);
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

  CacheWS := TStringList.Create;

  try
   lDB.SQL := 'SELECT * FROM storedata_gdws';
    try
      lDB.Open;
      IF lDB.RecordCount > 0 THEN BEGIN
       lDB.first;
       WHILE (NOT Terminated) AND (NOT lDB.EOF) DO BEGIN
        CacheWS.Add(lDB.FieldByName('sskey').AsString+'_'+lDB.FieldByName('name').AsString+'='+lDB.FieldByName('key').AsString);
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

end;

function TStorageGoogleDocs.GetGAuthDocs:boolean;
var
  HTTP: THTTPSend;
  xmldata: string;
  rtmp: boolean;

begin

  rtmp := false;
  Log.Add('GoogleDocs: Trying to get a valid Auth Docs Key');


  HTTP := THTTPSend.Create;
  try
  WriteStrToStream(HTTP.Document, 'accountType=GOOGLE&Email='+CFG.Get('GoogledocsUsername')+'&Passwd='+CFG.Get('GoogleDocsPassword')+'&service=writely&source=openTempus');
  HTTP.MimeType := 'application/x-www-form-urlencoded';

  if HTTP.HTTPMethod('POST', 'https://www.google.com/accounts/ClientLogin') then
    begin
      xmldata := ReadStrFromStream(HTTP.Document,HTTP.Document.Size);
      Log.Add(xmldata);
      IF(Pos('Auth=',xmldata) > 0) THEN BEGIN
          Log.Add('GoogleDocs: Succes obtaining a Valid Auth Key');
          rtmp := true;
        END
        ELSE
          Log.Add('GoogleDocs: Unable to obtain Valid Auth Key');
   end
   ELSE
          Log.Add('GoogleDocs: Unable to obtain Valid Auth Key');
  finally
    HTTP.Free;
  end;
  result := rtmp;
end;

function TStorageGoogleDocs.GetGAuthSpreadSheets: boolean;
var
  HTTP: THTTPSend;
  xmldata: string;
  rtmp: boolean;

begin

  rtmp := false;
  Log.Add('GoogleDocs: Trying to get a valid Auth SpreadSheet Key');

  HTTP := THTTPSend.Create;
  try
  WriteStrToStream(HTTP.Document, 'accountType=GOOGLE&Email='+CFG.Get('GoogledocsUsername')+'&Passwd='+CFG.Get('GoogleDocsPassword')+'&service=wise&source=openTempus');
  HTTP.MimeType := 'application/x-www-form-urlencoded';

  if HTTP.HTTPMethod('POST', 'https://www.google.com/accounts/ClientLogin') then
    begin
      xmldata := ReadStrFromStream(HTTP.Document,HTTP.Document.Size);
      Log.Add(xmldata);
      IF(Pos('Auth=',xmldata) > 0) THEN BEGIN
          Log.Add('GoogleDocs: Succes obtaining a Valid Auth Key');
          rtmp := true;
        END
        ELSE
          Log.Add('GoogleDocs: Unable to obtain Valid SpreadSheet Key');
   end
   ELSE
          Log.Add('GoogleDocs: Unable to obtain Valid SpreadSheet Key');
  finally
    HTTP.Free;
  end;
  result := rtmp;

end;

function TStorageGoogleDocs.GetSSKey(timestart: string):string;
var
  HTTP: THTTPSend;
  xmldata: string;
 filename: string;
 rtmp: string;
 dateparts: tstringlist;
 week: integer;
 gauthavailable: boolean;
begin

 rtmp := '';

 dateparts := tstringlist.create;
 IF CFG.GET('GoogleDocsSpreadsheet') = 'Each Day' THEN BEGIN
  Split(' ',timestart,dateparts);
  filename := dateparts.Strings[0];
 END
 ELSE  IF CFG.GET('GoogleDocsSpreadsheet') = 'Each Week' THEN BEGIN
  Split(' ',timestart,dateparts);
  Split('-',dateparts[0],dateparts);
  week := WeekOfTheYear(EncodeDateTime(StrToInt(dateparts[0]),StrToInt(dateparts[1]),StrToInt(dateparts[2]),0,0,0,0));
  filename := dateparts[0]+'_week_'+inttostr(week);
 END
 ELSE  IF CFG.GET('GoogleDocsSpreadsheet') = 'Each Month' THEN BEGIN
  Split(' ',timestart,dateparts);
  Split('-',dateparts[0],dateparts);
  filename := dateparts[0]+'_month_'+dateparts[1];
 END
 ELSE  IF CFG.GET('GoogleDocsSpreadsheet') = 'Each Year' THEN BEGIN
  Split(' ',timestart,dateparts);
  Split('-',dateparts[0],dateparts);
  filename := dateparts[0];
 END;

 filename := 'opentempus_'+filename;

 // Check cache

 IF CacheWS.IndexOfName(filename) > -1 THEN BEGIN
  rtmp := CacheWS.Values[filename];
 END
 ELSE BEGIN

  IF CacheDocs = '' THEN BEGIN
    HTTP := THTTPSend.Create;
    try
    Log.Add('GoogleDocs: Trying to obtain list of spreadsheets');
    HTTP.Headers.Add('Authorization: GoogleLogin auth='+GAuthSpreadSheets);

    if HTTP.HTTPMethod('GET', 'http://spreadsheets.google.com/feeds/spreadsheets/private/full') then
      begin
        xmldata := ReadStrFromStream(HTTP.Document,HTTP.Document.Size);
        Log.Add(xmldata);
        IF(Pos(filename+'<',xmldata) > 0) THEN BEGIN
            CacheDocs := xmldata;
            Log.Add('GoogleDocs: Succes obtaining a list of spreadsheets');
          END
          ELSE
            Log.Add('GoogleDocs: Unable to obtain list of spreadsheets');
     end
     ELSE
            Log.Add('GoogleDocs: Unable to obtain a list of spreadsheets');
    finally
      HTTP.Free;
    end;
   END;

   // Create a new SpreadSheet and WorkSheet

   // PENDIENTE

     HTTP := THTTPSend.Create;
      try
      WriteStrToStream(HTTP.Document, 'col1,col2,col3');
      HTTP.Headers.Add('Slug: '+filename);
      HTTP.Headers.Add('Authorization: GoogleLogin auth='+GAuthDocs);
      HTTP.MimeType := 'text/csv';

      if HTTP.HTTPMethod('POST', 'http://docs.google.com/feeds/documents/private/full') then
        begin
          xmldata := ReadStrFromStream(HTTP.Document,HTTP.Document.Size);
          Log.Add(xmldata);
          IF(Pos('Auth=',xmldata) > 0) THEN BEGIN
              Log.Add('GoogleDocs: Succes obtaining a Valid Auth Key');
              rtmp := '';
            END
            ELSE
              Log.Add('GoogleDocs: Unable to obtain Valid Auth Key');
       end
       ELSE
              Log.Add('GoogleDocs: Unable to create a WorkSheet');
      finally
        HTTP.Free;
      end;

 END;

  result := rtmp;
end;

function TStorageGoogleDocs.GetWSKey(timestart: string; spreadsheetkey: string):string;
begin
  result := '';
end;

function TStorageGoogleDocs.AddRow(spreadsheetkey,worksheetkey:string; row: TSRow):boolean;
begin
  result := false;
end;

procedure TStorageGoogleDocs.Execute;
var
 rows: array of TSRow;
 i: integeR;
 spreadsheetkey, worksheetkey: string;
 lDB: TSqlite3Dataset;

begin

  lDB := TSqlite3Dataset.Create(DB.Owner);
  lDB.FileName:=DB.FileName;

  Log.Add('Starting GoogleDocs storage');

  i := 0;

  try
  lDB.SQL := 'SELECT idwp, t.seconds, strftime("%Y-%m-%d %H:%M:%S",dtimestart) as ts, strftime("%Y-%m-%d %H:%M:%S",dtimeend) as te, '+'w.title, p.name FROM storedata_wpt wpt, wp_track t, windows w, processes p WHERE wpt.idwp = t.id AND wpt.savegoogledocs = 0 AND t.idw = w.id AND t.idp = p.id';
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

  IF (Length(rows) > 0) AND (GetGAuthSpreadSheets) THEN BEGIN
    i := 0;

    CreateCache;

    WHILE (NOT Terminated) AND (i < Length(rows) - 1) DO BEGIN

        spreadsheetkey := GetSSKey(rows[i].timestart);

        IF spreadsheetkey <> '' THEN BEGIN

          worksheetkey := GetWSKey(rows[i].timestart, spreadsheetkey);

          IF (worksheetkey <> '') AND (addrow(spreadsheetkey,worksheetkey, rows[i])) THEN BEGIN
            try
            lDB.ExecSQL('UPDATE storedata_wpt SET savespreadsheet = 1 WHERE idwp = '+inttostr(rows[i].idwp));
            except
             on E: Exception do
              Log.add('Exception: '+E.ClassName+' '+E.Message);
            end;
           END;
        END;
        Inc(i);
    END;
  END;

  Log.Add('Finished GoogleDocs storage');

end;


end.

