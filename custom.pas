unit Custom;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Menus, ExtDlgs,apiplatforms,md5,utils,dateutils;

type

  { TCustom }

  TCustom = class(TForm)
    ButtonSaveTemplate: TButton;
    ButtonSaveTime: TButton;
    ButtonCalendar: TButton;
    CalendarDialog1: TCalendarDialog;
    ComboBoxCustomWindow: TComboBox;
    ComboBoxCustomTask: TComboBox;
    ComboBoxHour: TComboBox;
    ComboBoxMinute: TComboBox;
    EditWindowName: TEdit;
    EditProcessName: TEdit;
    EditDate: TEdit;
    EditMinutes: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;

    {$IFDEF Windows}
    OTAPI: TWindowsPlatform;
    {$endif}
    {$IFDEF unix}
    OTAPI: TUnixPlatform;
    {$endif}

    procedure ButtonCalendarClick(Sender: TObject);
    procedure ButtonSaveTemplateClick(Sender: TObject);
    procedure ButtonSaveTimeClick(Sender: TObject);
    procedure ComboBoxCustomWindowKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ComboBoxCustomWindowSelect(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LoadWindowsTemplates;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  CustomWindowTask: TCustom;

implementation

{ TCustom }


procedure TCustom.LoadWindowsTemplates;
var
 records : TAPIDBR;
 rt: tstringlist;
 i: integer;
begin

  ComboBoxCustomWindow.Clear;
  records := OTAPI.SQLRecords('SELECT * FROM windows_templates ORDER BY title ASC');
  ComboBoxCustomWindow.AddItem('Type or select a window name', TObject(0));
  IF Length(records) > 0 THEN BEGIN
    FOR i:= 0 TO Length(records) - 1 DO BEGIN
     rt := tstringlist(records[i]);
     ComboBoxCustomWindow.AddItem(rt.Values['title'], TObject(strtoint(rt.Values['id'])));
    END;
  END;
  ComboBoxCustomWindow.ItemIndex:=0;

end;

procedure TCustom.ComboBoxCustomWindowKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ButtonSaveTemplate.Enabled := TRUE;
  CustomWindowTask.Caption:=ComboBoxCustomWindow.Text;
end;

procedure TCustom.ButtonSaveTemplateClick(Sender: TObject);
var
 ctext : string;
begin
 ctext := ComboBoxCustomWindow.Text;
 IF ComboBoxCustomWindow.Items.IndexOf(ctext) < 0 THEN BEGIN
  IF OTAPI.SQLExec('INSERT INTO windows_templates (title) VALUES ("'+ctext+'")') THEN
          showmessage('Window title template created successfully.');;
  LoadWindowsTemplates;
  ComboBoxCustomWindow.ItemIndex := ComboBoxCustomWindow.Items.IndexOf(ctext);
 END
end;

procedure TCustom.ButtonSaveTimeClick(Sender: TObject);
 var
  WindowTitle, ProcessName, sql: string;
  idw,idp,dbWPId, seconds: integer;
  minutes: real;
  records: TAPIDBR;
  rt: tstringlist;
  StartDate, Enddate: TDateTime;
  myYear, myMonth, myDay : Word;

begin

  WindowTitle := Trim(EditWindowName.Text);
  ProcessName := Trim(EditProcessName.Text);
  EditMinutes.Text := Trim(EditMinutes.Text);

  try
     minutes := strtofloat(EditMinutes.Text)
  except
     minutes := 0;
  end;

  IF minutes > 0 THEN BEGIN

    seconds := Round(minutes * 60);

     OTAPI.SQLExec('INSERT INTO windows (title, md5) VALUES ("'+WindowTitle+'", "'+MD5Print(md5.MD5String(WindowTitle))+'")');

     OTAPI.SQLExec('INSERT INTO processes (name, md5) VALUES ("'+ProcessName+'", "'+MD5Print(md5.MD5String(ProcessName))+'")');

    { Get the window id in the db }
    records := OTAPI.SQLRecords('SELECT id FROM windows WHERE md5 = "'+MD5Print(md5.MD5String(WindowTitle))+'"');
    IF Length(records) > 0 THEN BEGIN
     rt := tstringlist(records[0]);
     idw := strtoint(rt.Values['id']);
    END ELSE BEGIN
     idw := 0;
    END;

    { Get the process id in the db }
    records := OTAPI.SQLRecords('SELECT id FROM processes WHERE md5 = "'+MD5Print(md5.MD5String(ProcessName))+'"');
    IF Length(records) > 0 THEN BEGIN
     rt := tstringlist(records[0]);
     idp := strtoint(rt.Values['id']);
    END
    ELSE BEGIN
     idp := 0;
    END;

    records := OTAPI.SQLRecords('SELECT COUNT(id) as total, MAX(id) as maxvalue FROM wp_track');
    rt := tstringlist(records[0]);

    IF strtoint(rt.Values['total']) = 0 THEN BEGIN
     dbWPId := 1;
    END
    ELSE BEGIN
     dbWPId := strtoint(rt.Values['total']) + 1;
    END;

    StartDate := StrToDate(EditDate.Text);
    DecodeDate(StartDate, myYear, myMonth, myDay);
    StartDate := EncodeDateTime(myYear, myMonth, myDay, strtoint(ComboBoxHour.Text), strtoint(ComboBoxMinute.Text), 0, 0);
    EndDate := IncSecond(StartDate,seconds);

    sql := 'INSERT INTO wp_track (id,idw,idp,timestart,timeend, dtimestart, dtimeend, seconds, idt) VALUES ("'+Inttostr(dbWPId)+'", "'+IntToStr(idw)+'", "'+IntToStr(idp)+'", "'+inttostr(DateTimetounix(StartDate))+'", "'+inttostr(DateTimetounix(EndDate))+'", "'+FormatDateTime('yyyy-mm-dd hh:nn:ss',StartDate)+'", "'+FormatDateTime('yyyy-mm-dd hh:nn:ss',EndDate)+'", "'+inttostr(seconds)+'", "'+inttostr(Integer(ComboBoxCustomTask.Items.Objects[ComboBoxCustomTask.ItemIndex]))+'")';
    IF OTAPI.SQLExec(sql) THEN
       showmessage('Time track created successfully.');
  END
  ELSE
      showmessage('Plese, write a correct number of minutes');
end;

procedure TCustom.ButtonCalendarClick(Sender: TObject);
begin
  if CalendarDialog1.Execute then
     EditDate.Text:=DateTimeToStr(CalendarDialog1.Date);
end;

procedure TCustom.ComboBoxCustomWindowSelect(Sender: TObject);
begin
 ButtonSaveTemplate.Enabled := FALSE;
 CustomWindowTask.Caption:=ComboBoxCustomWindow.Text;
end;

procedure TCustom.FormShow(Sender: TObject);
var
 records : TAPIDBR;
 rt: tstringlist;
 i: integer;
begin

 LoadWindowsTemplates;

 EditDate.Text := DateToStr(Date);

  ComboBoxCustomTask.Clear;
  records := OTAPI.SQLRecords('SELECT t.id,c.name as category, t.name as task FROM task t, category c WHERE t.idc = c.id ORDER BY c.name,t.name');
  ComboBoxCustomTask.AddItem('Select a task', TObject(0));
  IF Length(records) > 0 THEN BEGIN
    FOR i:= 0 TO Length(records) - 1 DO BEGIN
     rt := tstringlist(records[i]);
     ComboBoxCustomTask.AddItem(rt.Values['category']+': '+rt.Values['task'], TObject(strtoint(rt.Values['id'])));
    END;
  END;
  ComboBoxCustomTask.ItemIndex:=0;

end;

initialization
  {$I custom.lrs}

end.

