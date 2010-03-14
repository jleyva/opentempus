unit slimtimer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, Forms, configuration,  httpsend, synacode, synautil, sqlite3ds, DOM, XMLRead, otlog;

type

  TTimeEntry = record
   idwp: integer;
   idw: integer;
   seconds: integer;
   timestart: string;
   windowtitle: string;
   processname: string;
  end;

  TSlimTimer = class(TThread)
  private
   CFG: TOTConfig;
   DB: TSqlite3Dataset;
   cacheIdw: TStringList;
   cacheST: TStringList;
   cachecalled: boolean;
   AccessToken: string;
   UserID: string;
   Log: TOTLog;

   procedure CreateCache;
   procedure GetAccessTokenUserId;
   function CreateTask(Name:string): integer;
   function CreateTimeEntry(TaskId,StartTime,Duration,Tags: String):boolean;
  public
   constructor Create(CreateSuspended: boolean; mCFG: TOTConfig; mDB: TSqlite3Dataset; mLog: TOTLog);
   procedure Execute; override;
  end;

implementation

const

 MAXTask: integer = 30;

constructor TSlimTimer.Create(CreateSuspended: boolean; mCFG: TOTConfig; mDB: TSqlite3Dataset; mLog: TOTLog);
begin
 self.CFG := mCFG;
 self.DB := mDB;
 self.log := mLog;
 cacheIdw := TStringList.create;
 cacheST := TStringList.create;
 cachecalled := false;
 AccessToken := '';
  FreeOnTerminate := True;
 inherited Create(CreateSuspended);
end;

procedure TSlimTimer.CreateCache;
begin
 cachecalled := true;

 try
   DB.SQL := 'SELECT idw,idslimtimer FROM storedata_stcache';
    try
    DB.Open;
    IF DB.RecordCount > 0 THEN BEGIN
     cacheIdw.Capacity := DB.RecordCount + 100;
     cacheST.Capacity := cacheIdw.Capacity;
     DB.First;
     WHILE NOT DB.EOF DO BEGIN
      cacheIdw.Add(DB.FieldByName('idw').asString);
      cacheST.Add(DB.FieldByName('idslimtimer').asString);
      DB.next;
     END;
    END;
    finally
    DB.close;
    end;
  except
   on E: Exception do
    Log.add('Exception: '+E.ClassName+' '+E.Message);
  end;
end;

procedure TSlimTimer.GetAccessTokenUserId;
var
  HTTP: THTTPSend;
  xmldata: string;
  S : TStringStream;
  XML : TXMLDocument;
  Passnode: TDOMNode;

begin

  Log.Add('SlimTimer: Trying to get a valid Acces Token and User Id');

  HTTP := THTTPSend.Create;
  try
  WriteStrToStream(HTTP.Document, 'api_key='+CFG.Get('SlimTimerAPIKey')+'&user[password]='+CFG.Get('SlimTimerPassword')+'&user[email]='+cfg.Get('SlimTimerUsername'));
  HTTP.MimeType := 'application/x-www-form-urlencoded';
  http.headers.Add('Accept: application/xml');

  if HTTP.HTTPMethod('POST', 'http://slimtimer.com/users/token') then
    begin
      xmldata := ReadStrFromStream(HTTP.Document,HTTP.Document.Size);
      IF(Pos('access-token',xmldata) > 0) THEN BEGIN
        try
          S:= TStringStream.Create(xmldata);
          //Log.add(xmldata);
          Try
            S.Position:=0;
            XML:=Nil;
            ReadXMLFile(XML,S);
            PassNode := XML.DocumentElement.FindNode('access-token');
            AccessToken := PassNode.TextContent;
            PassNode := XML.DocumentElement.FindNode('user-id');
            UserID := PassNode.TextContent;
          Finally
            S.Free;
            Log.Add('SlimTimer: Success Valid Access token and User id');
          end;
        except
         on E: Exception do
          Log.add('Exception: '+E.ClassName+' '+E.Message);
        end;
        END
        ELSE
          Log.Add('SlimTimer: Unable to obtain Valid Access token and User id');
   end;
  finally
    HTTP.Free;
  end;
end;

function TSlimTimer.CreateTask(Name: string): integer;
var
  HTTP: THTTPSend;
  xmldata: string;
  S : TStringStream;
  XML : TXMLDocument;
  Passnode: TDOMNode;
  rtmp: integer;
begin

  rtmp := 0;
  IF AccessToken  = '' THEN
   GetAccessTokenUserId;

  IF (AccessToken  <> '') AND (UserID <> '') THEN BEGIN
   Log.Add('SlimTimer: Trying to create a new task');
   try
   HTTP := THTTPSend.Create;
   try
     WriteStrToStream(HTTP.Document, 'api_key='+CFG.Get('SlimTimerAPIKey')+'&access_token='+AccessToken+'&task[name]='+EncodeURLElement(Name));
     HTTP.MimeType := 'application/x-www-form-urlencoded';
     http.headers.Add('Accept: application/xml');
       if HTTP.HTTPMethod('POST', 'http://slimtimer.com/users/'+UserID+'/tasks') then
         begin
          xmldata := ReadStrFromStream(HTTP.Document,HTTP.Document.size);
          IF(Pos('<task>',xmldata) > 0) AND (Pos('</id>',xmldata) > 0) THEN BEGIN
          S:= TStringStream.Create(xmldata);
          //Log.add(xmldata);
          Try
            S.Position:=0;
            XML:=Nil;
            ReadXMLFile(XML,S);
            PassNode := XML.DocumentElement.FindNode('id');
            rtmp := strtoint(PassNode.TextContent);
          Finally
            S.Free;
            Log.Add('SlimTimer: New Task Created');
          end;
          end;
         end;
      finally
       HTTP.Free;
      end;
    except
     on E: Exception do
      Log.add('Exception: '+E.ClassName+' '+E.Message);
    end;
  END;

  result := rtmp;
end;

function TSlimTimer.CreateTimeEntry(TaskId,StartTime,Duration,Tags: String):boolean;
var
  HTTP: THTTPSend;
  xmldata: string;
  rtmp: boolean;

begin

  rtmp := FALSE;
  IF AccessToken  = '' THEN
   GetAccessTokenUserId;

  IF (AccessToken  <> '') AND (UserID <> '') THEN BEGIN
   Log.Add('SlimTimer: Trying to create a new time entry');
   try
    HTTP := THTTPSend.Create;
     try
       log.add('api_key='+CFG.Get('SlimTimerAPIKey')+'&access_token='+AccessToken+'&time-entry[task_id]='+EncodeURLElement(TaskId)+'&time-entry[start_time]='+EncodeURLElement(StartTime)+'&time-entry[duration_in_seconds]='+EncodeURLElement(Duration)+'&time-entry[tags]='+EncodeURLElement(Tags));
       WriteStrToStream(HTTP.Document, 'api_key='+CFG.Get('SlimTimerAPIKey')+'&access_token='+AccessToken+'&time-entry[task_id]='+EncodeURLElement(TaskId)+'&time-entry[start_time]='+EncodeURLElement(StartTime)+'&time-entry[duration_in_seconds]='+EncodeURLElement(Duration)+'&time-entry[tags]='+EncodeURLElement(Tags));
       HTTP.MimeType := 'application/x-www-form-urlencoded';
       http.headers.Add('Accept: application/xml');
         if HTTP.HTTPMethod('POST', 'http://slimtimer.com/users/'+UserID+'/time_entries') then
           begin
            xmldata := ReadStrFromStream(HTTP.Document,HTTP.Document.size);
            Log.add(xmldata);
            IF(Pos('<time-entry>',xmldata) > 0) AND (Pos('</id>',xmldata) > 0) THEN BEGIN
              rtmp := TRUE;
              Log.Add('SlimTimer: New Time Entry Created');
            end;
           end;
      finally
       HTTP.Free;
      end;
    except
     on E: Exception do
      Log.add('Exception: '+E.ClassName+' '+E.Message);
    end;
  END;

  result := rtmp;
end;

procedure TSlimTimer.Execute;
var
 i,tid, NewTask, currentSTTask, counTask: integer;
 tasks: array of TTimeEntry;

begin

     counTask := 0;

     SetLength(tasks,MAXTask);
     Log.Add('Starting Slim Timer Task and Time Entries Commit');

     IF NOT cachecalled THEN
        self.CreateCache;

      try
      DB.SQL := 'SELECT t.id, t.idw, t.seconds, strftime("%Y-%m-%d %H:%M:%S",dtimestart) as ts, w.title, p.name FROM storedata_wpt wpt, wp_track t, windows w, processes p WHERE wpt.idwp = t.id AND wpt.saveslimtimer = 0 AND t.idw = w.id AND t.idp = p.id LIMIT '+inttostr(MAXTask);
        try
        DB.Open;
        IF DB.RecordCount > 0 THEN BEGIN
         DB.first;
         WHILE NOT DB.EOF DO BEGIN
          tasks[counTask].idwp := DB.FieldByName('id').AsInteger;
          tasks[counTask].idw := DB.FieldByName('idw').AsInteger;
          tasks[counTask].seconds := DB.FieldByName('seconds').AsInteger;
          tasks[counTask].timestart := DB.FieldByName('ts').AsString;
          tasks[counTask].windowtitle := DB.FieldByName('title').AsString;
          tasks[counTask].processname := DB.FieldByName('name').AsString;
          Inc(counTask);
          DB.Next;
         END;
        END;
        finally
        DB.close;
        end;
      except
       on E: Exception do
        Log.add('Exception: '+E.ClassName+' '+E.Message);
      end;

      Log.Add(' SlimTimer: '+inttostr(counTask)+' new time entries found.');

      FOR i:= 0 TO counTask - 1 DO BEGIN
        currentSTTask := 0;
        // Check if task exists
        tid := tasks[i].idw;
        IF cacheIdw.IndexOf(inttostr(tid)) = -1 THEN BEGIN
          NewTask := CreateTask(tasks[i].windowtitle);
          IF NewTask > 0 THEN
          begin
             currentSTTask := NewTask;
             try
              DB.ExecSQL('INSERT INTO storedata_stcache(idw,idslimtimer) VALUES ("'+inttostr(tid)+'","'+inttostr(NewTask)+'")');
             except
              on E: Exception do
               Log.add('Exception: '+E.ClassName+' '+E.Message);
              end;
             cacheIdw.Add(inttostr(tid));
             cacheST.Add(inttostr(NewTask));
          end;
        END
        ELSE BEGIN
          currentSTTask := strtoint(cacheST.Strings[cacheIdw.IndexOf(inttostr(tid))]);
        END;

        IF currentSTTASk > 0 THEN BEGIN
           IF CreateTimeEntry(inttostr(currentSTTask),tasks[i].timestart,inttostr(tasks[i].seconds),tasks[i].processname) THEN BEGIN
             try
              DB.ExecSQL('UPDATE storedata_wpt SET saveslimtimer = 1 WHERE idwp = '+inttostr(tasks[i].idwp));
             except
             on E: Exception do
              Log.add('Exception: '+E.ClassName+' '+E.Message);
             end;
           END;
         END;
      END;

end;

end.

