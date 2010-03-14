unit configuration;

{$mode objfpc}{$M+}

interface

uses
  Classes, SysUtils, Forms, StdCtrls, utils
  {$IFDEF unix}
   ,baseunix, unix
  {$endif}
  ;

const

 ModeNormal: integer = 1;
 ModeFiltersDisabled: integer = 2;
 ModeTrackingDisabled: integer = 3;

type

 TAComponents = array of TComponent;

 TOTConfig = Class
 private
  UserPreferences: TStringList;
 public
  FilePath: string;
  IconPath: string;
  LogPath: string;
  ReportsPath: string;
  StoragePath: string;
  DBPath: AnsiString;
  PHPPath: string;
  LangDir: string;
  ReportsHtmlDir: string;
  Mode: Integer;
  constructor Create();
  function FileConfigExists: boolean;
  procedure SetPreference(Component: TComponent);
  function Get(PrefName: string):string;
 end;

implementation

constructor TOTConfig.Create();
var
 wpath: string;
 {$IFDEF unix}
 sharepath,uhpath: string;
 {$endif}
begin
  UserPreferences := TStringList.Create;
  {$IFDEF Windows}
  wpath := ExtractFilePath(Application.EXEName);
  FilePath := wpath + 'preferences.xml';
  LogPath :=  wpath + 'opentempus.log';
  DBPath := wpath + 'opentempus.s3db';

  IconPath := wpath + 'icons';
  ReportsPath := wpath + 'reports';
  StoragePath := wpath + 'storage';
  ReportsHtmlDir:= wpath + 'reportshtml';
  LangDir := wpath + 'languages';

  PHPPath := wpath + 'bin'+DirectorySeparator+'php';
  {$ENDIF}
  {$IFDEF unix}
  sharepath := '/usr/share/opentempus';
  uhpath := GetEnvironmentVariable('HOME')+ DirectorySeparator  + 'opentempus';

  IF NOT DirectoryExists(uhpath) THEN
     CreateDir(uhpath);

  FilePath := uhpath + DirectorySeparator + 'preferences.xml';
  LogPath :=  uhpath + DirectorySeparator + 'opentempus.log';
  DBPath := uhpath + DirectorySeparator + 'opentempus.s3db';
  ReportsHtmlDir:= uhpath + DirectorySeparator + 'reportshtml';

  IF NOT DirectoryExists(ReportsHtmlDir) THEN
     CreateDir(ReportsHtmlDir);

  IF NOT FileExists(DBPath) THEN
     FileCopy(sharepath + DirectorySeparator + 'opentempus.s3db',DBPath);

  IconPath := sharepath + DirectorySeparator + 'icons';
  ReportsPath := sharepath + DirectorySeparator + 'reports';
  StoragePath := sharepath + DirectorySeparator + 'storage';
  LangDir := sharepath + DirectorySeparator + 'languages';

  PHPPath := 'php';
  {$ENDIF}

end;

function TOTConfig.FileConfigExists: boolean;
begin
 result := FileExists(FilePath);
end;


procedure TOTConfig.SetPreference(Component: TComponent);
var
 NewName: string;
begin
   IF Component is TCheckBox THEN BEGIN
    with Component as TCheckBox do begin
      NewName := StringReplace(Name, 'Check', '',[rfReplaceAll, rfIgnoreCase]);
      IF UserPreferences.IndexOfName(NewName) <> -1 THEN
       UserPreferences.Values[NewName] := booltostr(Checked,TRUE)
      ELSE
       UserPreferences.Add(NewName+'='+booltostr(Checked,TRUE));
    end;
   END
   ELSE IF Component is TComboBox THEN BEGIN
    with Component as TComboBox do begin
      NewName := StringReplace(Name, 'Combo', '',[rfReplaceAll, rfIgnoreCase]);
      IF UserPreferences.IndexOfName(NewName) <> -1 THEN
       UserPreferences.Values[NewName] := Text
      ELSE
       UserPreferences.Add(NewName+'='+Text);
    end;
   END
   ELSE IF Component is TEdit THEN BEGIN
    with Component as TEdit do begin
      NewName := StringReplace(Name, 'Edit', '',[rfReplaceAll, rfIgnoreCase]);
      IF UserPreferences.IndexOfName(NewName) <> -1 THEN
       UserPreferences.Values[NewName] := Text
      ELSE
       UserPreferences.Add(NewName+'='+Text);
    end;
   END
end;

function TOTConfig.Get(PrefName: string):string;
begin
  IF UserPreferences.IndexOfName(PrefName) <> -1 THEN begin
   result := UserPreferences.Values[PrefName];
  end
  else begin
   result := '';
  end
end;

end.

