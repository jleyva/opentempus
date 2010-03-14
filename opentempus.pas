unit opentempus;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Menus, ComCtrls, configuration, apiplatforms,
  PopupNotifier, otlog, XMLPropStorage, ExtDlgs, rules, report, CheckLst, threadprocess, storage, utils, custom, Translations, gettext, dateutils;

const

   SecondsDay: integer = 86400;

type

  { TMain }

  TMain = class(TForm)
    ApplicationProperties1: TApplicationProperties;
    ButtonApplyRule: TButton;
    ButtonStorageRun: TButton;
    ButtonEditRule: TButton;
    ButtonRunReport: TButton;
    ButtonCalendar1: TButton;
    Button3: TButton;
    ButtonDeleteRule: TButton;
    ButtonOrderRulesDown: TButton;
    ButtonAddCategory: TButton;
    ButtonOrderRulesUp: TButton;
    ButtonSaveRule: TButton;
    ButtonEditCategory: TButton;
    ButtonDeleteCategory: TButton;
    ButtonDeleteTask: TButton;
    Button8: TButton;
    ButtonAddTask: TButton;
    ButtonSave: TButton;
    ButtonCancel: TButton;
    CalendarDialog1: TCalendarDialog;
    CheckMonday: TCheckBox;
    CheckTuesday: TCheckBox;
    CheckWednesday: TCheckBox;
    CheckThursday: TCheckBox;
    CheckFriday: TCheckBox;
    CheckSaturday: TCheckBox;
    CheckSunday: TCheckBox;
    ComboTrackSHour: TComboBox;
    ComboTrackSMinute: TComboBox;
    ComboTrackEHour: TComboBox;
    ComboTrackEMinute: TComboBox;
    ComboNewRuleProcess: TComboBox;
    ComboBoxApplyRuleTime: TComboBox;
    GroupBox11: TGroupBox;
    Image1: TImage;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    ListBoxStorage: TCheckListBox;
    CheckPositiveFilters: TCheckBox;
    CheckNegativeFilters: TCheckBox;
    CheckRunStartup: TCheckBox;
    CheckNoSaveWindows: TCheckBox;
    CheckNoSaveProcess: TCheckBox;
    CheckActivateLoging: TCheckBox;
    ComboNewRuleLogic: TComboBox;
    ComboTaskCategory: TComboBox;
    ComboMinTrackingSeconds: TComboBox;
    ComboIdleStatus: TComboBox;
    ComboUpdateFrequency: TComboBox;
    ComboTrackingInterval: TComboBox;
    ComboNotifyIdle: TComboBox;
    EditDate2: TEdit;
    EditDate1: TEdit;
    EditNewRuleWindow: TEdit;
    EditNewRuleName: TEdit;
    EditNewCategory: TEdit;
    EditTaskName: TEdit;
    EditFilterTrackWindows: TEdit;
    EditFilterTrackProcesses: TEdit;
    EditFilterNoTrackWindows: TEdit;
    EditFilterNoTrackProcesses: TEdit;
    GroupBox1: TGroupBox;
    GroupBox10: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    GroupBox9: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label3: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label37: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ListBoxReports: TListBox;
    ListBoxRules: TListBox;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    PageControl1: TPageControl;
    PageControl3: TPageControl;
    PageControl4: TPageControl;
    PopupMenu1: TPopupMenu;
    PopupNotifier1: TPopupNotifier;
    StaticTextReports: TStaticText;
    StaticTextStorage: TStaticText;
    TabSheet1: TTabSheet;
    TabSheet10: TTabSheet;
    TabSheet11: TTabSheet;
    TabSheet12: TTabSheet;
    TabSheet13: TTabSheet;
    TabSheet14: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    TabSheet9: TTabSheet;
    Timer1: TTimer;
    TrayIcon1: TTrayIcon;
    TreeTasksRules: TTreeView;
    TreeCatTask: TTreeView;
    TreeTasks: TTreeView;
    XMLPropStorage1: TXMLPropStorage;

    procedure ApplicationProperties1Minimize(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ButtonApplyRuleClick(Sender: TObject);
    procedure ButtonEditCategoryClick(Sender: TObject);
    procedure ButtonCalendar1Click(Sender: TObject);
    procedure ButtonDeleteCategoryClick(Sender: TObject);
    procedure ButtonDeleteRuleClick(Sender: TObject);
    procedure ButtonDeleteTaskClick(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure ButtonAddCategoryClick(Sender: TObject);
    procedure ButtonEditRuleClick(Sender: TObject);
    procedure ButtonOrderRulesDownClick(Sender: TObject);
    procedure ButtonOrderRulesUpClick(Sender: TObject);
    procedure ButtonRunReportClick(Sender: TObject);
    procedure ButtonSaveRuleClick(Sender: TObject);
    procedure ButtonAddTaskClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure ButtonStorageRunClick(Sender: TObject);
    procedure ButtonTaskAddCategoryClick(Sender: TObject);
    procedure CheckNegativeFiltersChange(Sender: TObject);
    procedure CheckNoSaveProcessChange(Sender: TObject);
    procedure CheckNoSaveWindowsChange(Sender: TObject);
    procedure CheckPositiveFiltersChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Label12Click(Sender: TObject);
    procedure ListBoxReportsClick(Sender: TObject);
    procedure ListBoxStorageClick(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure PageControl3Change(Sender: TObject);
    procedure TabSheet10Show(Sender: TObject);
    procedure TabSheet11Show(Sender: TObject);
    procedure TabSheet12Show(Sender: TObject);
    procedure TabSheet13Show(Sender: TObject);
    procedure TabSheet6Show(Sender: TObject);
    procedure TabSheet7Show(Sender: TObject);
    procedure TabSheet9Show(Sender: TObject);


    procedure Timer1Timer(Sender: TObject);
    procedure SavePreferences;
    procedure SetPreferences;
    procedure LoadRules;
    procedure LoadListRules;
    procedure LoadTaskTree;
    procedure LoadComboTaskCategory;
    procedure TrayIcon1Click(Sender: TObject);
    procedure XMLPropStorage1SavingProperties(Sender: TObject);
    procedure LoadStoragePlugins;
    procedure ShowCustomForm;
    procedure LoadLanguage;
    procedure SetMode(Mode: integer);

  private
    { private declarations }
    CFG: TOTConfig;
    UserIsIdle: boolean;
    {$IFDEF Windows}
    OTAPI: TWindowsPlatform;
    {$endif}
    {$IFDEF unix}
    OTAPI: TUnixPlatform;
    {$endif}

    CountTimerSeconds: integer;

    Log: TOTLog;
    Rules: TList;
    LetClose: boolean;
    StoragePlugins: TList;
    ReportsPlugins: Tlist;

    EditingTask: integer;
    EditingCategory: integer;
    EditingRule: integer;
   ModeChangedByUser: boolean;

    procedure ShowStatus(Status: string);

  public
    { public declarations }
  end;

var
  Main: TMain;
  Lang, FallbackLang: string;

resourcestring

  rsRunAtStartup = 'Run at startup';
  rsActivateLogg = 'Activate Logging';
  rsMainPreferen = 'Main Preferencs';
  rsGeneral = 'General';
  rsTracking = 'Tracking';
  rsTrackingUpda = 'Tracking update frequency (seconds)';
  rsTrackingIntervalSeco = 'Tracking interval (seconds)';
  rsDoNotSaveTrackingsLe = 'Do not save trackings less than (seconds):';
  rsMinutesForIdleStatus = 'Minutes for idle status';
  rsAmountOfSecondsBetwe = 'Amount of seconds between notification and going '
    +'idle';
  rsPreferences = 'Preferences';
  rsIdle = 'Idle';
  rsSave = 'Save';
  rsCancel = 'Cancel';
  rsPrivacyAndFilters = 'Privacy and Filters';
  rsPrivacy = 'Privacy';
  rsDoNotSaveProcessName = 'Do not save process names';
  rsDoNotSaveWindowsTitl = 'Do not save windows titles/captions';
  rsFilters = 'Filters';
  rsOnlyTrackWindowsWhos = 'Only track windows whose title contains:';
  rsOnlyTrackProcessesWh = 'Only track processes whose name contains:';
  rsDoNotTrackWindowsWho = 'Do not track windows whose title contains:';
  rsDoNotTrackProcessesW = 'Do not track processes whose name contains:';
  rsTasks = 'Tasks';
  rsNewTask = 'New Task';
  rsCategory = 'Category';
  rsTask = 'Task';
  rsAdd = 'Add';
  rsManageTasks = 'Manage Tasks';
  rsDelete = 'Delete';
  rsEdit = 'Edit';
  rsCategories = 'Categories';
  rsNewCategory = 'New Category';
  rsManageCategories = 'Manage Categories';
  rsRules = 'Rules';
  rsNewRule = 'New Rule';
  rsRuleName = 'Rule Name:';
  rsWindowTitleContains = 'Window Title contains:';
  rsProcessNameContains = 'Process name contains:';
  rsLinkTo = 'Link to:';
  rsManageRules = 'Manage Rules';
  rsApplyThisRuleTo = 'Apply this rule to:';
  rsUp = 'Up';
  rsDown = 'Down';
  rsApply = 'Apply';
  rsReports = 'Reports';
  rsEndDate = 'End Date:';
  rsStartDate = 'Start Date:';
  rsReportInfo = 'Report info:';
  rsRunReport = 'Run Report';
  rsPlugins = 'Plugins';
  rsPluginsForDataStorag = 'Plugins for data storage, data import, backup and '
    +'manteinance';
  rsPluginInfo = 'Plugin Info:';
  rsRunNow = 'Run Now';
  rsUsePositiveFilters = 'Use Positive Filters ';
  rsUseNegativeFilters = 'Use Negative Filters ';

  rsUpdate = 'Update';
  rsOpenTempusIdleStatus = 'openTempus Idle status';
  rsYouAreGoingIdle = 'You are going to be Idle in ';
  rsYouAreGoingIdleSecs = ' seconds \n your current task will be finished in openTempus';
  rsPleaseSelectTask = 'Please, select a Task';
  rsPleaseSelectTaskCat = 'Please, select a Task not a category';
  rsRulesSaved = 'Rule saved successfully';
  rsRuleUpdated = 'Rule updated successfully';
  rsPleaseWriteTask = 'Please, write a task name';
  rsPleaseSelectCategory = 'Please, select a category';
  rsRuleApplied = 'Rule applied to ';
  rsTimeEntries = ' time entries';
  rsAreYouSureWant = 'Are you sure you want to delete this category?\n Tasks will be move to Miscellaneous category';
  rsAreYouSureDelTask = 'Are you sure you want to delete this task?';
  rsThisPluginIsEnabled = 'This plugin is enabled and is executed every ';
  rsThisPluginIsEnabledSecs = ' seconds. Are you sure you want run it now?';
  rsAll = 'All';
  rsLast = 'Last';
  rsYear = 'Year';
  rsToday = 'Today';
  rsDays = 'days';
  rsMonths = 'months';
  rsName = 'Name';
  rsAuthor = 'Author';
  rsVersion = 'Version';
  rsSummary = 'Summary';
  rsFrequency = 'Frequency';

  rsSecs = 'secs';
  rsThisPluginDoesNot = 'This plugin does not run as a scheluded process. It must be run using the "Run now" button.';
  rsNormal = 'Normal';
  rsTrackingDisabled = 'Tracking Disabled';
  rsFiltersDisabled = 'Filters Disabled';
  rsMode = 'Mode';
  rsExit = 'Exit';
  rsCustomWindowTask = 'Custom Window/Task';
  rsAbout = 'About';
  rsHelpOnline = 'Help online';
  rsLanguage = 'Language';
  rsDoNotTrackBetween = 'Do not track between:';
  rsDoNotTrackTheseDays = 'Do not track these days:';
  rsMon = 'Mon';
  rsTue = 'Tue';
  rsWed = 'Wed';
  rsThu = 'Thu';
  rsFri = 'Fri';
  rsSat = 'Sat';
  rsSun = 'Sun';

implementation

{$IFDEF Windows}
uses Windows;
{$endif}
{$IFDEF Darwin}
uses
{$ifdef ver2_2_0}
  FPCMacOSAll;
{$else}
  MacOSAll;
{$ENDIF}
{$ENDIF}

const
  OTVersion: Real = 0.95;

{ TMain }

procedure TMain.FormCreate(Sender: TObject);
begin

  CFG := TOTConfig.Create;
  XMLPropStorage1.FileName := CFG.FilePath;

  Log := TOTLog.Create(CFG,TRUE);

  {$IFDEF Windows}
  OTAPI:= TWindowsPlatform.Create(CFG, Log, Rules);
  {$endif}
  {$IFDEF unix}
  OTAPI:= TUnixPlatform.Create(CFG, Log, Rules);
  {$endif}

  IF FileExists(XMLPropStorage1.FileName) THEN BEGIN
    XMLPropStorage1.Restore;
  END
  ELSE BEGIN
   CFG.Mode := ModeNormal;
  END;

  SetPreferences;

  LoadLanguage;

  LoadRules;
  LoadStoragePlugins;
  ReportsPlugins := TList.Create;

  LetClose := FALSE;

  UserIsIdle := FALSE;
  TrayIcon1.Visible := True;
  Timer1.Interval := 1000;
  CountTimerSeconds:=0;
  EditingTask := 0;
  EditingRule := 0;
  EditingCategory := 0;
  ModeChangedByUser := False;

  EditDate1.Text := DateToStr(Date);
  EditDate2.Text := DateToStr(Date);
  Timer1.Enabled := TRUE;

  PageControl1.ActivePageIndex := 0;

  Log.add('Starting Lazarus');


end;

procedure TMain.LoadLanguage;
var
  PODirectory: String;
begin

  PODirectory := CFG.LangDir;

  IF (Lang = '') AND (FallbackLang = '') THEN
     GetLanguageIDs(Lang, FallbackLang);

  Translations.TranslateUnitResourceStrings('opentempus', PODirectory + DirectorySeparator + 'opentempus.%s.po', Lang, FallbackLang);

  Caption := rsPreferences;
  CheckRunStartup.Caption := rsRunAtStartup;
  CheckActivateLoging.Caption := rsActivateLogg;
  TabSheet1.Caption := rsMainPreferen;
  GroupBox1.Caption := rsGeneral;
  GroupBox2.Caption := rsTracking;
  Label7.Caption := rsTrackingUpda;
  Label6.Caption := rsTrackingIntervalSeco;
  Label9.Caption := rsDoNotSaveTrackingsLe;
  Label1.Caption := rsMinutesForIdleStatus;
  Label8.Caption := rsAmountOfSecondsBetwe;
  GroupBox3.Caption := rsIdle;
  ButtonSave.Caption := rsSave;
  ButtonCancel.Caption := rsCancel;
  TabSheet2.Caption := rsPrivacyAndFilters;
  GroupBox4.Caption := rsPrivacy;
  CheckNoSaveProcess.Caption := rsDoNotSaveProcessName;
  CheckNoSaveWindows.Caption := rsDoNotSaveWindowsTitl;
  GroupBox5.Caption := rsFilters;
  Label2.Caption := rsOnlyTrackWindowsWhos;
  Label3.Caption := rsOnlyTrackProcessesWh;
  Label4.Caption := rsDoNotTrackWindowsWho;
  Label5.Caption := rsDoNotTrackProcessesW;
  TabSheet6.Caption := rsTasks;
  TabSheet9.Caption := rsTasks;
  GroupBox6.Caption := rsNewTask;
  Label26.Caption := rsCategory;
  Label27.Caption := rsTask;
  ButtonAddTask.Caption := rsAdd;
  GroupBox7.Caption := rsManageTasks;
  ButtonDeleteTask.Caption := rsDelete;
  Button8.Caption := rsEdit;
  TabSheet10.Caption := rsCategories;
  GroupBox8.Caption := rsNewCategory;
  ButtonAddCategory.Caption := rsAdd;
  GroupBox9.Caption := rsManageCategories;
  ButtonEditCategory.Caption := rsEdit;
  ButtonDeleteCategory.Caption := rsDelete;
  TabSheet13.Caption := rsRules;
  TabSheet11.Caption := rsNewRule;
  Label28.Caption := rsRuleName;
  Label29.Caption := rsWindowTitleContains;
  Label30.Caption := rsProcessNameContains;
  Label31.Caption := rsLinkTo;
  ButtonSaveRule.Caption := rsAdd;
  TabSheet12.Caption := rsManageRules;
  Label11.Caption := rsApplyThisRuleTo;
  ButtonOrderRulesUp.Caption := rsUp;
  ButtonOrderRulesDown.Caption := rsDown;
  ButtonDeleteRule.Caption := rsDelete;
  ButtonEditRule.Caption := rsEdit;
  ButtonApplyRule.Caption := rsApply;
  TabSheet7.Caption := rsReports;
  GroupBox11.Caption := rsReports;
  Label35.Caption := rsEndDate;
  Label34.Caption := rsStartDate;
  Label10.Caption := rsReportInfo;
  ButtonRunReport.Caption := rsRunReport;
  TabSheet14.Caption := rsPlugins;
  GroupBox10.Caption := rsPluginsForDataStorag;
  Label37.Caption := rsPluginInfo;
  ButtonStorageRun.Caption := rsRunNow;
  CheckPositiveFilters.Caption := rsUsePositiveFilters;
  CheckNegativeFilters.Caption := rsUseNegativeFilters;
  MenuItem1.Caption := rsPreferences;
  MenuItem8.Caption := rsReports;
  MenuItem7.Caption := rsCustomWindowTask;
  MenuItem2.Caption := rsMode;
  MenuItem6.Caption := rsExit;
  MenuItem9.Caption := rsAbout;
  Label12.Caption := rsHelpOnline;
  MenuItem10.Caption:= rsLanguage;

  Label14.Caption := rsDoNotTrackBetween;
  Label13.Caption := rsDoNotTrackTheseDays;
  CheckMonday.Caption := rsMon;
  CheckTuesday.Caption := rsTue;
  CheckWednesday.Caption := rsWed;
  CheckThursday.Caption := rsThu;
  CheckFriday.Caption := rsFri;
  CheckSaturday.Caption := rsSat;
  CheckSunday.Caption := rsSun;

end;

procedure TMain.SetPreferences;
var
 i: integer;
begin
  IF FileExists(XMLPropStorage1.FileName) THEN BEGIN
   CFG.Mode := strtoint(XMLPropStorage1.StoredValue['Mode']);
   Lang := XMLPropStorage1.StoredValue['Lang'];
   FallbackLang := Lang;
  END;

  IF CFG.Mode = ModeNormal THEN
   TrayIcon1.Icon.LoadFromFile(CFG.IconPath+DirectorySeparator+'opentempus.ico')
  ELSE IF CFG.Mode = ModeTrackingDisabled THEN
   TrayIcon1.Icon.LoadFromFile(CFG.IconPath+DirectorySeparator+'opentempustdisabled.ico')
  ELSE IF CFG.Mode = ModeFiltersDisabled THEN
   TrayIcon1.Icon.LoadFromFile(CFG.IconPath+DirectorySeparator+'opentempusfdisabled.ico');

  for i:= 0 to main.ComponentCount -1 do
   CFG.SetPreference(Main.Components[i]);
end;

procedure TMain.SavePreferences;
begin
 XMLPropStorage1.StoredValue['Mode'] := inttostr(CFG.Mode);
 XMLPropStorage1.StoredValue['Lang'] := Lang;
 XMLPropStorage1.Save;
 SetPreferences;
end;


procedure TMain.ShowCustomForm;
begin
     CustomWindowTask.OTAPI := OTAPI;
     CustomWindowTask.Show;
end;

{This is not working fine on Lazarus, this is the reason for the spaghetti code
 See http://www.mail-archive.com/lazarus@lazarus.freepascal.org/msg03056.html for more info
}
procedure TMain.ApplicationProperties1Minimize(Sender: TObject);
  {$IFDEF Windows}
var

   OwnerWnd : HWnd;
  {$endif}
begin
  {$IFDEF Windows}
  OwnerWnd:=GetWindow(Handle,GW_OWNER);
  ShowWindow(OwnerWnd,SW_HIDE);
  {$endif}
  Main.Visible := False;
  Main.Hide;
  Application.ShowMainForm := False;
  Application.ProcessMessages;
end;


procedure TMain.Button3Click(Sender: TObject);
begin
  if CalendarDialog1.Execute then
  EditDate2.Text:=DateTimeToStr(CalendarDialog1.Date);
end;

procedure TMain.ButtonApplyRuleClick(Sender: TObject);
var
 i,j,days,seconds,idct,idt,corder,cont: integer;
 records: TAPIDBR;
 rt: tstringlist;
 sqlcondition, sql: string;
 StopRule: boolean;
 rule: trule;

begin

 corder := ListBoxRules.ItemIndex;
 records := OTAPI.SQLRecords('SELECT * FROM rules WHERE id = "'+inttostr(integer(ListBoxRules.Items.Objects[corder]))+'"');
 rt := tstringlist(records[0]);
 idct := strtoint(rt.values['idt']);

 days := integer(ComboBoxApplyRuleTime.Items.Objects[ComboBoxApplyRuleTime.ItemIndex]);
 seconds := UnixTime() - (days * SecondsDay);
 sqlcondition := '';

 IF days <> 0 THEN
  sqlcondition := ' AND timestart > '+inttostr(seconds);
 sql := 'SELECT wp.id,w.title as wtitle, p.name as pname FROM `wp_track` wp LEFT JOIN `windows` w ON wp.idw = w.id LEFT JOIN `processes` p ON wp.idp = p.id WHERE idt <> '+inttostr(idct)+' '+sqlcondition;
 records := OTAPI.SQLRecords(sql);

 IF Length(records) > 0 THEN
   cont := 0;
   Log.Add('Checking rule to '+inttostr(Length(records))+' records');
   FOR i:= 0 TO Length(records) - 1 DO BEGIN
    rt := tstringlist(records[i]);
    idt := 0;
    StopRule := false;
    If Rules.Count > 0 THEN
     FOR j := 0 TO Rules.Count - 1 DO BEGIN
       IF (NOT StopRule) AND (j < corder + 1) THEN BEGIN
         rule := TRule(Rules.Items[j]);
         idt := rule.Check(rt.Values['wtitle'],rt.Values['pname']);
         //Log.Add('Checked'+rt.Values['wtitle']+' '+rule.Window);
         IF idt <> 0 THEN
            StopRule := TRUE;
       END;
     END;

    IF (idt > 0) AND (idt = idct) THEN BEGIN
       OTAPI.SQLExec('UPDATE wp_track SET idt = '+inttostr(idct)+' WHERE id = '+rt.Values['id']);
       Log.Add('Rule Applied to '+rt.Values['pname']+' '+rt.Values['wtitle']);
       Inc(cont);
    END;
   END;
   showmessage(rsRuleApplied+inttostr(cont)+rsTimeEntries);
end;

procedure TMain.ButtonEditCategoryClick(Sender: TObject);
begin
  EditingCategory := Integer(TreeCatTask.Selected.Data);
  ButtonAddCategory.Caption:=rsUpdate;
  EditNewCategory.Text:= TreeCatTask.selected.Text;
end;

procedure TMain.ButtonCalendar1Click(Sender: TObject);
begin
  if CalendarDialog1.Execute then
  EditDate1.Text:=DateTimeToStr(CalendarDialog1.Date);
end;

procedure TMain.ButtonDeleteCategoryClick(Sender: TObject);
var
 idc: integer;
 buttonSelected : Integer;
begin
  idc := Integer(TreeCatTask.Selected.Data);
  IF idc > 1 THEN BEGIN
   buttonSelected := MessageDlg(rsAreYouSureWant,mtError, mbOKCancel, 0);
   if buttonSelected = mrOK  then BEGIN
    OTAPI.SQLExec('UPDATE task SET idc = "1" WHERE idc = "'+IntToStr(idc)+'"');
    OTAPI.SQLExec('DELETE FROM category WHERE id = "'+IntToStr(idc)+'"');
    LoadTaskTree
   END
  END
end;

procedure TMain.ButtonDeleteRuleClick(Sender: TObject);
var
 i: integer;
 sql: string;
begin

 If ListBoxRules.SelCount > 0 THEN BEGIN
   i := ListBoxRules.ItemIndex;
   OTAPI.SQLExec('DELETE FROM rules WHERE id = "'+IntToStr(integer(ListBoxRules.Items.Objects[i]))+'"');
   sql := 'UPDATE rules SET `order` = `order` - 1 WHERE `order` > '+IntToStr(i + 1);
   OTAPI.SQLExec(sql);
  END;

  LoadListRules;
end;

procedure TMain.ButtonDeleteTaskClick(Sender: TObject);
var
 idt: integer;
 buttonSelected : Integer;
begin
  idt := Integer(TreeTasks.Selected.Data);
  IF idt > 0 THEN BEGIN
   buttonSelected := MessageDlg(rsAreYouSureDelTask,mtError, mbOKCancel, 0);
   if buttonSelected = mrOK  then BEGIN
    OTAPI.SQLExec('DELETE FROM task WHERE id = "'+IntToStr(idt)+'"');
    LoadTaskTree
   END
  END
end;


procedure TMain.ButtonOrderRulesUpClick(Sender: TObject);
var
 i, sel: integer;
begin
   sel := 0;
   If ListBoxRules.SelCount > 0 THEN BEGIN
     i := ListBoxRules.ItemIndex;
     IF i > 0 THEN BEGIN
      OTAPI.SQLExec('UPDATE rules SET `order` = "'+IntToStr(i + 1)+'" WHERE `order` = "'+IntToStr(i)+'"');
      OTAPI.SQLExec('UPDATE rules SET `order` = "'+IntToStr(i)+'" WHERE id = "'+IntToStr(integer(ListBoxRules.Items.Objects[i]))+'"');
      sel := i - 1;
     END
   END;

  LoadListRules;
  ListBoxRules.Selected[sel] := TRUE;
end;

procedure TMain.ButtonRunReportClick(Sender: TObject);
var
 cmline: string;
 MThread: TThreadProcess;
begin

 IF ListBoxReports.SelCount > 0 THEN
   BEGIN
     with TObject(ReportsPlugins.Items[ListBoxReports.ItemIndex]) as TReport do begin
      cmline := CmdLine(EditDate1.Text,EditDate2.Text);
      Log.Add('Start Report thread: '+Name+' cmdline:'+cmline);
      MThread := TThreadProcess.Create(False, cmline, CFG.ReportsHtmlDir+DirectorySeparator+Output, log, TRUE);
      MThread.OnShowStatus := @ShowStatus;
     end
   END;
end;


procedure TMain.XMLPropStorage1SavingProperties(Sender: TObject);
begin

end;



procedure TMain.ButtonCancelClick(Sender: TObject);
var
 i: integer;
begin
  // Force the main form to restore the original preferences
  XMLPropStorage1.Restore;
   FOR i:=0 TO ListBoxStorage.Count - 1 DO BEGIN
     WITH TObject(StoragePlugins.Items[i]) AS TStorage DO BEGIN
          ListBoxStorage.Checked[i] := Enabled;
     END;
   END;
  Main.Hide;
end;

procedure TMain.ButtonSaveClick(Sender: TObject);
var
 RunStartup: boolean;
 i: integer;
begin

  RunStartup := strtobool(CFG.Get('RunStartup'));
  // Save to the xml
  SavePreferences;
  // Load de CFG object with the new preferences
  SetPreferences;

  IF (NOT RunStartup) AND (strtobool(CFG.Get('RunStartup'))) THEN
     OTAPI.RunStartUp(TRUE);

  IF (RunStartup) AND (NOT strtobool(CFG.Get('RunStartup'))) THEN
     OTAPI.RunStartUp(FALSE);

   FOR i:=0 TO ListBoxStorage.Count - 1 DO BEGIN
     WITH TObject(StoragePlugins.Items[i]) AS TStorage DO BEGIN
          IF ListBoxStorage.Checked[i] THEN
             SetEnabled(TRUE)
          ELSE
              SetEnabled(FALSE);
     END;
   END;

  Main.hide;
  Log.add('Configuration saved');

end;

procedure TMain.ShowStatus(Status: string);
begin
  showmessage(Status);
end;


procedure TMain.ButtonStorageRunClick(Sender: TObject);
var
 ConfirmRun: boolean;
 buttonSelected: integer;
 MThread: TThreadProcess;

begin
  ConfirmRun:=FALSE;
  IF ListBoxStorage.SelCount > 0 THEN BEGIN
     with TObject(StoragePlugins.Items[ListBoxStorage.ItemIndex]) as TStorage DO BEGIN
      IF (FreqExec) AND (Enabled) THEN BEGIN
         buttonSelected := MessageDlg(rsThisPluginIsEnabled+inttostr(Freq)+rsThisPluginIsEnabledSecs,mtError, mbOKCancel, 0);
         IF buttonSelected = mrOK  THEN
            ConfirmRun := TRUE
         ELSE
            ConfirmRun := FALSE;
      END
      ELSE
          ConfirmRun := TRUE;

      IF ConfirmRun THEN BEGIN
        Counter := 0;
        Log.Add('Start Storage thread: '+Name+' cmdline:'+cmdline);
        MThread := TThreadProcess.Create(FALSE,cmdline,'',Log, TRUE);
        MThread.OnShowStatus := @ShowStatus;
      END
     END;
  END;
end;

procedure TMain.Button8Click(Sender: TObject);
begin
 EditingTask:= Integer(TreeTasks.Selected.Data);
 IF EditingTask > 0 THEN BEGIN
  EditTaskName.Text:= TreeTasks.selected.Text;
  ComboTaskCategory.Text:= TreeTasks.selected.Parent.Text;
  ButtonAddTask.Caption:=rsUpdate;
 END
end;

procedure TMain.ButtonTaskAddCategoryClick(Sender: TObject);
begin
  TabSheet10.Show;
end;

procedure TMain.CheckNegativeFiltersChange(Sender: TObject);
begin
  IF CheckNegativeFilters.Checked = TRUE THEN BEGIN
    CheckPositiveFilters.Checked := FALSE;

    EditFilterTrackProcesses.Enabled := FALSE;
    EditFilterTrackProcesses.Color := clInactiveBorder;
    EditFilterTrackWindows.Enabled := FALSE;
    EditFilterTrackWindows.Color := clInactiveBorder;

    EditFilterNoTrackProcesses.Enabled := TRUE;
    EditFilterNoTrackProcesses.color := clWindow;
    EditFilterNoTrackWindows.Enabled := TRUE;
    EditFilterNoTrackWindows.color := clWindow;
  END
  ELSE BEGIN
    EditFilterNoTrackProcesses.Enabled := FALSE;
    EditFilterNoTrackProcesses.color := clInactiveBorder;
    EditFilterNoTrackWindows.Enabled := FALSE;
    EditFilterNoTrackWindows.color := clInactiveBorder;
  END;
end;

procedure TMain.CheckNoSaveProcessChange(Sender: TObject);
begin
  IF CheckNoSaveProcess.Checked = TRUE THEN
   CheckNoSaveWindows.Checked := FALSE;
end;

procedure TMain.CheckNoSaveWindowsChange(Sender: TObject);
begin
  IF CheckNoSaveWindows.Checked = TRUE THEN
   CheckNoSaveProcess.Checked := FALSE;
end;

procedure TMain.CheckPositiveFiltersChange(Sender: TObject);
begin
  IF CheckPositiveFilters.Checked = TRUE THEN BEGIN
    CheckNegativeFilters.Checked := FALSE;

    EditFilterTrackProcesses.Enabled := TRUE;
    EditFilterTrackProcesses.color := clWindow;
    EditFilterTrackWindows.Enabled := TRUE;
    EditFilterTrackWindows.color := clWindow;

    EditFilterNoTrackProcesses.Enabled := FALSE;
    EditFilterNoTrackProcesses.Color := clInactiveBorder;
    EditFilterNoTrackWindows.Enabled := FALSE;
    EditFilterNoTrackWindows.Color := clInactiveBorder;
  END
  ELSE BEGIN
    EditFilterTrackProcesses.Enabled := FALSE;
    EditFilterTrackProcesses.color := clInactiveBorder;
    EditFilterTrackWindows.Enabled := FALSE;
    EditFilterTrackWindows.color := clInactiveBorder;
  END;
end;



procedure TMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
 XMLPropStorage1.Restore;
 Self.hide;
 IF LetClose THEN
  CanClose := TRUE
 ELSE
  CanClose := FALSE;
end;

procedure TMain.FormDestroy(Sender: TObject);
begin
  OTAPI.FinishCurrentWindowProcess;
  Log.add('Lazarus Closed');
end;

procedure TMain.Label12Click(Sender: TObject);
begin
 OTAPI.OpenBrowser('http://opentempus.org/help/');
end;



procedure TMain.ListBoxReportsClick(Sender: TObject);

var
 Report: TReport;

begin

IF ListBoxReports.Items.Count > 0 THEN BEGIN
   Report := TReport(ReportsPlugins.Items[ListBoxReports.ItemIndex]);
   StaticTextReports.Caption:= rsName+': '+Report.Name+chr(13);
   StaticTextReports.Caption:= StaticTextReports.Caption+rsAuthor+': '+Report.Author+chr(13);
   StaticTextReports.Caption:= StaticTextReports.Caption+rsVersion+': '+Report.Version+chr(13);
   StaticTextReports.Caption:= StaticTextReports.Caption+rsSummary+': '+Report.Summary+chr(13);
  END
end;

procedure TMain.ListBoxStorageClick(Sender: TObject);
var
 SP: TStorage;
begin
 SP := TStorage(StoragePlugins.Items[ListBoxStorage.ItemIndex]);
 StaticTextStorage.Caption:= rsName+': '+SP.Name+chr(13);
 StaticTextStorage.Caption:= StaticTextStorage.Caption+rsAuthor+': '+SP.Author+chr(13);
 StaticTextStorage.Caption:= StaticTextStorage.Caption+rsVersion+': '+SP.Version+chr(13);
 IF NOT SP.FreqExec THEN
    StaticTextStorage.Caption:= StaticTextStorage.Caption+rsFrequency+': '+rsThisPluginDoesNot+chr(13)
 ELSE
    StaticTextStorage.Caption:= StaticTextStorage.Caption+rsFrequency+' ('+rsSecs+'): '+inttostr(SP.Freq)+chr(13);

 StaticTextStorage.Caption:= StaticTextStorage.Caption+rsSummary+': '+SP.Summary+chr(13);
end;

procedure TMain.MenuItem11Click(Sender: TObject);
begin
  Lang := 'en';
  FallbackLang := 'en';
  LoadLanguage;
  SavePreferences;
end;

procedure TMain.MenuItem12Click(Sender: TObject);
begin
  Lang := 'es';
  FallbackLang := 'es_ES';
  LoadLanguage;
  SavePreferences;
end;


procedure TMain.MenuItem1Click(Sender: TObject);
begin
  //Main.Left := (Screen.Width DIV 2) - (Main.Width DIV 2);
  //Main.Top := (Screen.Height DIV 2) - (Main.Height DIV 2);
  PageControl1.TabIndex:=0;
  Main.Show;
end;

procedure TMain.SetMode(Mode: integer);
begin

 IF Mode = ModeNormal THEN BEGIN
  CFG.Mode := ModeNormal;
  MenuItem3.Caption:= '• '+rsNormal;
  MenuItem4.Caption:= '  '+rsTrackingDisabled;
  MenuItem5.Caption:= '  '+rsFiltersDisabled;
  TrayIcon1.Icon.LoadFromFile(CFG.IconPath+DirectorySeparator+'opentempus.ico');
  SavePreferences;
  Log.add('Mode Normal Activated');
 END
 ELSE  IF Mode = ModeTrackingDisabled THEN BEGIN
  CFG.Mode := ModeTrackingDisabled;
  MenuItem3.Caption:= '  '+rsNormal;
  MenuItem4.Caption:= '• '+rsTrackingDisabled;
  MenuItem5.Caption:= '  '+rsFiltersDisabled;
  TrayIcon1.Icon.LoadFromFile(CFG.IconPath+DirectorySeparator+'opentempustdisabled.ico');
  OTAPI.FinishCurrentWindowProcess;
  SavePreferences;
  Log.add('Mode Tracking Disabled activated');
 END
 ELSE  IF Mode = ModeFiltersDisabled THEN BEGIN
  CFG.Mode := ModeFiltersDisabled;
  MenuItem3.Caption:= '  '+rsNormal;
  MenuItem4.Caption:= '  '+rsTrackingDisabled;
  MenuItem5.Caption:= '• '+rsFiltersDisabled;
  TrayIcon1.Icon.LoadFromFile(CFG.IconPath+DirectorySeparator+'opentempusfdisabled.ico');
  {This should be improved, not stop the current process, some better solution missing}
  OTAPI.FinishCurrentWindowProcess;
  SavePreferences;
  Log.add('Mode Filters Disabled activated');
 END
end;

procedure TMain.MenuItem3Click(Sender: TObject);
begin
 SetMode(ModeNormal);
 ModeChangedByUser := True;
end;

procedure TMain.MenuItem4Click(Sender: TObject);
begin
 SetMode(ModeTrackingDisabled);
 ModeChangedByUser := True;
end;

procedure TMain.MenuItem5Click(Sender: TObject);
begin
 SetMode(ModeFiltersDisabled);
 ModeChangedByUser := True;
end;

procedure TMain.MenuItem6Click(Sender: TObject);
begin
  LetClose := TRUE;
  Self.Close;
end;

procedure TMain.MenuItem7Click(Sender: TObject);
begin
     ShowCustomForm;
end;

procedure TMain.MenuItem8Click(Sender: TObject);
begin
  Main.Show;
  PageControl1.TabIndex:=3;
end;

procedure TMain.MenuItem9Click(Sender: TObject);
begin
  OTAPI.OpenBrowser('http://opentempus.org');
end;

procedure TMain.PageControl1Change(Sender: TObject);
begin

end;

procedure TMain.PageControl3Change(Sender: TObject);
begin

end;

procedure TMain.TabSheet10Show(Sender: TObject);
begin
  EditingCategory:=0;
  ButtonAddCategory.Caption:=rsAdd;
end;

procedure TMain.TabSheet11Show(Sender: TObject);
var
 records : TAPIDBR;
 rt: tstringlist;
 i: integer;
begin

  ComboNewRuleProcess.Clear;
  records := OTAPI.SQLRecords('SELECT name FROM processes ORDER BY name ASC');
  ComboNewRuleProcess.Items[0] := '';
  IF Length(records) > 0 THEN BEGIN
    FOR i:= 0 TO Length(records) - 1 DO BEGIN
     rt := tstringlist(records[i]);
     ComboNewRuleProcess.items.Add(rt.Values['name']);
    END;
  END;
  ComboNewRuleProcess.ItemIndex:=0;

end;


procedure TMain.LoadListRules;
var
 i: integer;
 records: TAPIDBR;
 rt: tstringlist;

begin

 ListBoxRules.Items.Clear;

 records := OTAPI.SQLRecords('SELECT * FROM rules ORDER BY `order`');
 IF Length(records) > 0 THEN BEGIN
   FOR i:= 0 TO Length(records) - 1 DO BEGIN
    rt := tstringlist(records[i]);
    ListBoxRules.Items.AddObject(IntToStr(i + 1)+' - '+rt.Values['name']+' ('+rt.Values['window']+' '+rt.Values['logic']+' '+rt.Values['process']+')',tobject(strtoint(rt.Values['id'])));
   END
  END;
  LoadRules;
end;

procedure TMain.TabSheet12Show(Sender: TObject);
begin
 LoadListRules;
 IF ComboBoxApplyRuleTime.items.Count = 0 THEN BEGIN;
   ComboBoxApplyRuleTime.Items.AddObject(rsToday,TObject(1));
   ComboBoxApplyRuleTime.Items.AddObject(rsLast+' 7 '+rsDays,TObject(7));
   ComboBoxApplyRuleTime.Items.AddObject(rsLast+' 15 '+rsDays,TObject(15));
   ComboBoxApplyRuleTime.Items.AddObject(rsLast+' 30 '+rsDays,TObject(30));
   ComboBoxApplyRuleTime.Items.AddObject(rsLast+' 3 '+rsMonths,TObject(90));
   ComboBoxApplyRuleTime.Items.AddObject(rsLast+' 6 '+rsMonths,TObject(180));
   ComboBoxApplyRuleTime.Items.AddObject(rsLast+' '+rsYear,TObject(360));
   ComboBoxApplyRuleTime.Items.AddObject(rsAll,TObject(0));
   ComboBoxApplyRuleTime.ItemIndex:=0;
 END
end;

procedure TMain.TabSheet13Show(Sender: TObject);
begin
  PageControl4.ActivePageIndex:=0;
  EditingRule:=0;
  ButtonSaveRule.Caption:=rsAdd;
end;


procedure TMain.LoadStoragePlugins;
var
 searchResult : TSearchRec;
 StoragePlugin: Tstorage;
 CPath,Cfile: string;

begin

 StoragePlugins := TList.Create;
 ListBoxStorage.Items.Clear;

 IF DirectoryExists(CFG.StoragePath) THEN BEGIN
  if FindFirst(CFG.StoragePath+DirectorySeparator+'*', faDirectory, searchResult) = 0 then
  begin
    repeat
      if (searchResult.attr and faDirectory) = faDirectory
      then BEGIN
        IF (searchResult.Name <> '.') AND (searchResult.Name <> '..') THEN BEGIN
          CPath := CFG.StoragePath+DirectorySeparator+searchResult.Name+DirectorySeparator;
          CFile := 'config.xml';
          IF FileExists(CPath+lowercase('config.'+Lang+'.xml')) THEN
             CFile := lowercase('config.'+Lang+'.xml')
          ELSE IF FileExists(CPath+lowercase('config.'+FallbackLang+'.xml')) THEN
             CFile := lowercase('config.'+FallbackLang+'.xml');
          StoragePlugin := TStorage.Create(CPath+CFile, CFG);
          StoragePlugins.Add(StoragePlugin);
          ListBoxStorage.Items.Add(StoragePlugin.Name);
          IF StoragePlugin.Enabled THEN
             ListBoxStorage.Checked[ListBoxStorage.Count - 1] := TRUE;
        END
      END

    until FindNext(searchResult) <> 0;

    FindCloseUTF8(searchResult);
  end;
 END

end;

procedure TMain.LoadRules;
var
 records: TAPIDBR;
 rt: tstringlist;
 i: integer;

begin
 Rules := TList.Create;

 records := OTAPI.SQLRecords('SELECT * FROM rules ORDER BY `order`');
 IF Length(records) > 0 THEN BEGIN
  FOR i:= 0 TO Length(records) - 1 DO BEGIN
  rt := tstringlist(records[i]);
  Rules.Add(TRule.Create(rt.Values['window'],rt.Values['process'],rt.Values['logic'],strtoint(rt.Values['idt'])));
  END
 END;

 OTAPI.Rules := Rules;
end;

procedure TMain.TabSheet6Show(Sender: TObject);
begin
 LoadTaskTree;
 PageControl3.ActivePageIndex:=0;
end;

procedure TMain.TabSheet7Show(Sender: TObject);
var
 searchResult : TSearchRec;
 Report: TReport;
 CPath,CFile: string;

begin

 IF ReportsPlugins.Count = 0 THEN BEGIN

   ListBoxReports.Items.Clear;

   IF DirectoryExists(CFG.ReportsPath) THEN BEGIN
    if FindFirst(CFG.ReportsPath+DirectorySeparator+'*', faDirectory, searchResult) = 0 then
    begin
      repeat
        if (searchResult.attr and faDirectory) = faDirectory
        then BEGIN
          IF (searchResult.Name <> '.') AND (searchResult.Name <> '..') THEN BEGIN
            CPath := CFG.ReportsPath+DirectorySeparator+searchResult.Name+DirectorySeparator;
            CFile := 'config.xml';
            IF FileExists(CPath+lowercase('config.'+Lang+'.xml')) THEN
               CFile := lowercase('config.'+Lang+'.xml')
            ELSE IF FileExists(CPath+lowercase('config.'+FallbackLang+'.xml')) THEN
               CFile := lowercase('config.'+FallbackLang+'.xml');
            Report := TReport.Create(CPath+CFile, CFG);
            ReportsPlugins.Add(Report);
            ListBoxReports.Items.Add(Report.Name);
          END
        END

      until FindNext(searchResult) <> 0;

      FindCloseUTF8(searchResult);
    end;
   END
 END
end;

procedure TMain.TabSheet9Show(Sender: TObject);
begin
 EditingTask := 0;
 ButtonAddTask.Caption:= rsAdd;
end;

procedure TMain.LoadComboTaskCategory;
var
 records : TAPIDBR;
 rt: tstringlist;
 i: integer;
begin

  ComboTaskCategory.Clear;
  records := OTAPI.SQLRecords('SELECT * FROM category ORDER BY name ASC');
  IF Length(records) > 0 THEN BEGIN
    FOR i:= 0 TO Length(records) - 1 DO BEGIN
     rt := tstringlist(records[i]);
     ComboTaskCategory.AddItem(rt.Values['name'], TObject(strtoint(rt.Values['id'])));
    END;
    ComboTaskCategory.ItemIndex:=0;
  END;
end;

procedure TMain.TrayIcon1Click(Sender: TObject);
begin
     ShowCustomForm;
end;


procedure TMain.ButtonAddTaskClick(Sender: TObject);
var
 idc: integer;
 sql: string;

begin

  EditTaskName.Text := Trim(EditTaskName.Text);
  idc := Integer(ComboTaskCategory.Items.Objects[ComboTaskCategory.Items.IndexOf(ComboTaskCategory.Text)]);

  IF idc <= 0 THEN BEGIN
   showmessage(rsPleaseSelectCategory)
  END
  ELSE IF EditTaskName.Text = '' THEN BEGIN
   showmessage(rsPleaseWriteTask)
  END
  ELSE BEGIN
   IF EditingTask > 0 THEN BEGIN
    sql := 'UPDATE task SET idc = '+Inttostr(idc)+', name = "'+EditTaskName.Text+'" WHERE id = '+IntToStr(EditingTask);
    EditingTask := 0;
    ButtonAddTask.Caption:= rsAdd;
   END
   ELSE BEGIN
    sql := 'INSERT INTO task (idc,name) VALUES ("'+Inttostr(idc)+'", "'+EditTaskName.Text+'")';
   END;

   IF OTAPI.SQLExec(sql) THEN BEGIN
    LoadTaskTree;
    ComboTaskCategory.ItemIndex:=0;
    EditTaskName.Text:='';
   END
  END
end;


procedure TMain.ButtonSaveRuleClick(Sender: TObject);
var
 idt, maxorder: integer;
 rt: tstringlist;
 records: TAPIDBR;
 sql: string;

begin
   // TODO Calendar - CalendarDialog1.Execute;

  EditNewRuleName.Text := Trim(EditNewRuleName.Text);
  EditNewRuleWindow.Text := Trim(EditNewRuleWindow.Text);
  ComboNewRuleProcess.Text := Trim(ComboNewRuleProcess.Text);
  sql := '';

  IF TreeTasksRules.Selected <> NIL THEN BEGIN
    idt := Integer(TreeTasksRules.Selected.Data);
    IF idt <> 0 THEN BEGIN
      IF EditingRule <> 0 THEN BEGIN
        sql := 'UPDATE rules SET name ="'+EditNewRuleName.Text+'", ';
        sql := sql +' window = "'+EditNewRuleWindow.Text+'", ';
        sql := sql + 'process = "'+ComboNewRuleProcess.Text+'", logic = "'+ComboNewRuleLogic.Text+'", idt = "'+inttostr(idt)+'" WHERE id = '+inttostr(EditingRule);
        EditingRule:=0;
        ButtonSaveRule.Caption:='Save';
        showmessage(rsRuleUpdated);
      END
      ELSE BEGIN
        IF (EditNewRuleName.Text <> '') AND ((EditNewRuleWindow.Text  <> '') OR (ComboNewRuleProcess.Text <> '')) THEN BEGIN
          records := OTAPI.SQLRecords('SELECT COUNT(id) as total, MAX(`order`) as maxorder FROM rules');
          rt := tstringlist(records[0]);
          IF(strtoint(rt.Values['total']) = 0) THEN BEGIN
           maxorder := 1;
          END
          ELSE BEGIN
           maxorder := strtoint(rt.Values['maxorder']) + 1;
          END;
          sql := 'INSERT INTO rules (name, window, process, logic, idt, `order`) VALUES ("'+EditNewRuleName.Text+'","'+EditNewRuleWindow.Text+'","'+ComboNewRuleProcess.Text+'", "'+ComboNewRuleLogic.Text+'", "'+inttostr(idt)+'", "'+inttostr(maxorder)+'")';
        END
      END;
      IF (sql <> '') AND (OTAPI.SQLExec(sql)) THEN BEGIN
       LoadRules;
       EditNewRuleName.Text:='';
       EditNewRuleWindow.Text:='';
       ComboNewRuleProcess.Text:='';
       showmessage(rsRulesSaved);
      END
     END

    ELSE
        showmessage(rsPleaseSelectTaskCat);
  END
  ELSE
       showmessage(rsPleaseSelectTask);
end;

procedure TMain.ButtonAddCategoryClick(Sender: TObject);
var
 sql: string;

begin

 EditNewCategory.Text := Trim(EditNewCategory.Text);

 IF EditingCategory > 0 THEN BEGIN
  sql := 'UPDATE category SET  name = "'+EditNewCategory.Text+'" WHERE id = '+IntToStr(EditingCategory);
  EditingCategory:=0;
  ButtonAddCategory.Caption:= rsAdd;
 END
 ELSE BEGIN
  IF EditNewCategory.Text <> '' THEN
    sql := 'INSERT INTO category (name) VALUES ("'+EditNewCategory.Text+'")';
 END;

 //OTAPI.SQLExec(sql);
 IF OTAPI.SQLExec(sql) THEN BEGIN
  LoadTaskTree;
  EditNewCategory.Text:='';
 END
end;

procedure TMain.ButtonEditRuleClick(Sender: TObject);
var
 rt: tstringlist;
 records: TAPIDBR;
begin


 If ListBoxRules.SelCount > 0 THEN BEGIN
  EditingRule := integer(ListBoxRules.Items.Objects[ListBoxRules.ItemIndex]);
  records := OTAPI.SQLRecords('SELECT * FROM rules WHERE id = "'+inttostr(EditingRule)+'"');

  rt := records[0];
  PageControl4.TabIndex:=0;
  EditNewRuleName.Text:=rt.values['name'];
  EditNewRuleWindow.Text:=rt.values['window'];
  ComboNewRuleProcess.Text:=rt.values['process'];
  ComboNewRuleLogic.Text:=rt.values['logic'];
  TreeTasksRules.selected := TreeTasksRules.Items.FindNodeWithData(tobject(strtoint(rt.values['idt'])));
  ButtonSaveRule.Caption:=rsUpdate;

 END
end;

procedure TMain.ButtonOrderRulesDownClick(Sender: TObject);
  var
 i, sel: integer;
 sql: string;
begin

 IF ListBoxRules.SelCount > 0 THEN BEGIN
  i := ListBoxRules.ItemIndex;
  IF i < ListBoxRules.Count - 1 THEN BEGIN
    sql := 'UPDATE rules SET `order` = "'+IntToStr(i + 1)+'" WHERE `order` = "'+IntToStr(i + 2)+'"';
    OTAPI.SQLExec(sql);

    sql := 'UPDATE rules SET `order` = "'+IntToStr(i + 2)+'" WHERE id = "'+IntToStr(integer(ListBoxRules.Items.Objects[i]))+'"';
    OTAPI.SQLExec(sql);
    sel := i + 1;
    LoadListRules;
    ListBoxRules.selected[sel] := TRUE;
  END
 END
end;

procedure TMain.LoadTaskTree;
var
 node:ttreenode;
 i,j,cat : integer;
 records: TAPIDBR;
 rt: tstringlist;
begin

 LoadComboTaskCategory;

 TreeTasks.Items.Clear;
 TreeTasksRules.Items.Clear;
 TreeCatTask.Items.Clear;

 cat := 0;
 FOR i := 0 TO combotaskcategory.Items.count -1 do begin

     TreeTasks.Items.Add(nil,ComboTaskCategory.items[i]);
     TreeTasksRules.Items.Add(nil,ComboTaskCategory.items[i]);

     node := TreeCatTask.Items.Add(nil,ComboTaskCategory.items[i]);
     node.data := pointer(Integer(ComboTaskCategory.Items.Objects[i]));

     cat := TreeTasks.Items.count - 1;

     records := OTAPI.SQLRecords('SELECT * FROM task WHERE idc = "'+IntToStr(Integer(ComboTaskCategory.Items.Objects[i]))+'" ORDER BY name ASC');
     IF Length(records) > 0 THEN BEGIN
       FOR j:= 0 TO Length(records) - 1 DO BEGIN
        rt := tstringlist(records[j]);
        node := TreeTasks.Items.AddChild(TreeTasks.Items[cat],rt.Values['name']);
        node.data := pointer(strtoint(rt.Values['id']));
        node := TreeTasksRules.Items.AddChild(TreeTasksRules.Items[cat],rt.Values['name']);
        node.data := pointer(strtoint(rt.Values['id']));
       END
     END
 end;
end;

procedure TMain.Timer1Timer(Sender: TObject);
var
 IdleTimeLeft: integer;
 AuxSIdle, i: integer;
 DayOfW: integer;
 UTrackS, UTrackE: integer;
 ChangeForcedByTime: boolean;

begin

 Inc(CountTimerSeconds);
 DayOfW := DayOfTheWeek(Date);

 FOR i:=0 TO StoragePlugins.Count - 1 DO BEGIN
     with TObject(StoragePlugins.Items[i]) as TStorage DO BEGIN
          IF (FreqExec) AND (Enabled) THEN BEGIN
             Inc(Counter);
             IF Counter >= Freq THEN BEGIN
                Counter := 0;
                Log.Add('Start Storage thread: '+Name+' cmdline:'+cmdline);
                TThreadProcess.Create(FALSE,cmdline,'',log,FALSE);
             END;
          END;
     END;
 END;

 ChangeForcedByTime := FALSE;
 UTrackS := DateTimetounix(Date) + strtoint(CFG.Get('TrackSHour')) * 3600 + strtoint(CFG.Get('TrackSMinute')) * 60;
 UTrackE := DateTimetounix(Date) + strtoint(CFG.Get('TrackEHour')) * 3600 + strtoint(CFG.Get('TrackEMinute')) * 60;

 IF(DateTimetounix(Date) <> UTrackS) OR ((DateTimetounix(Date) <> UTrackE)) THEN BEGIN

  IF UTrackS <= UTrackE THEN BEGIN
   IF (DateTimetounix(Now) >= UTrackS) AND (DateTimetounix(Now) <= UTrackE) THEN
    ChangeForcedByTime := TRUE;
  END
  ELSE IF UTrackS > UTrackE THEN BEGIN
   IF DateTimetounix(Now) >= UTrackS THEN
    ChangeForcedByTime := TRUE;
   IF DateTimetounix(Now) <= UTrackE THEN
    ChangeForcedByTime := TRUE;
  END;

  IF ChangeForcedByTime THEN BEGIN
   SetMode(ModeTrackingDisabled);
   ModeChangedByUser := False;
  END
{  ELSE IF (NOT ModeChangedByUser) AND (CFG.Mode = ModeTrackingDisabled) THEN BEGIN
   SetMode(ModeNormal);
   ModeChangedByUser := False;
  END;    }

 END;

 IF ((DayOfW = 1) AND (strtobool(CFG.Get('Monday')))) OR  ((DayOfW = 2) AND (strtobool(CFG.Get('Tuesday'))))  OR  ((DayOfW = 3) AND (strtobool(CFG.Get('Wednesday'))))  OR  ((DayOfW = 4) AND (strtobool(CFG.Get('Thursday'))))  OR  ((DayOfW = 5) AND (strtobool(CFG.Get('Friday'))))  OR  ((DayOfW = 6) AND (strtobool(CFG.Get('Saturday'))))  OR  ((DayOfW = 7) AND (strtobool(CFG.Get('Sunday')))) THEN BEGIN
  IF (CFG.Mode <> ModeTrackingDisabled) THEN BEGIN
   SetMode(ModeTrackingDisabled);
   ModeChangedByUser := False;
  END
 END
 ELSE IF (NOT ChangeForcedByTime) AND (NOT ModeChangedByUser) AND (CFG.Mode = ModeTrackingDisabled) THEN BEGIN
   SetMode(ModeNormal);
  ModeChangedByUser := False;
 END;

 IF CFG.Mode = ModeTrackingDisabled THEN
  CountTimerSeconds := 0;

 IF CountTimerSeconds >= strtoint(CFG.Get('TrackingInterval')) THEN BEGIN

   CountTimerSeconds := 0;

   IF (strtoint(CFG.Get('IdleStatus')) > 0) AND (CFG.Mode <> ModeTrackingDisabled) AND (strtoint(CFG.Get('NotifyIdle')) > 0) AND (PopupNotifier1.visible = FALSE) THEN BEGIN
    AuxSIdle := OTAPI.GetSecondsIdle;
    IF (AuxSIdle + strtoint(CFG.Get('NotifyIdle'))) > strtoint(CFG.Get('IdleStatus')) * 60 THEN BEGIN
      IdleTimeLeft := (strtoint(CFG.Get('IdleStatus')) * 60) - AuxSIdle;
      PopupNotifier1.Title:= rsOpenTempusIdleStatus;
      PopupNotifier1.Text:= wraptext(rsYouAreGoingIdle+IntToStr(IdletimeLeft)+rsYouAreGoingIdleSecs,40);
      PopupNotifier1.ShowAtPos(Screen.Width - 100, Screen.Height - 50);

    END;
   END;

   IF (CFG.Mode <> ModeTrackingDisabled) AND (NOT UserIsIdle) THEN
   BEGIN
     IF (strtoint(CFG.Get('IdleStatus')) > 0) AND (OTAPI.GetSecondsIdle > strtoint(CFG.Get('IdleStatus')) * 60) THEN
     BEGIN
      OTAPI.FinishCurrentWindowProcess;
      UserIsIdle := TRUE;
      Log.add('User is idle');
     END
     ELSE BEGIN

      OTAPI.SetNewWindow;
      OTAPI.SetNewProcess;

      IF OTAPI.ChangedWindowProcess THEN
      BEGIN
       OTAPI.FinishCurrentWindowProcess;
       IF (CFG.Mode = ModeFiltersDisabled) OR (OTAPI.WindowProcessPassFilters) THEN
        OTAPI.SaveNewWindowProcess;
      END
      ELSE BEGIN
       OTAPI.UpdateCurrentWindowProcess;
      END;
     END;
   END;

   { Check Idle Status }
   IF (UserIsIdle) AND (CFG.Mode <> ModeTrackingDisabled) THEN
   BEGIN
    OTAPI.FinishCurrentWindowProcess;
    UserIsIdle := (strtoint(CFG.Get('IdleStatus')) > 0) AND (OTAPI.GetSecondsIdle > strtoint(CFG.Get('IdleStatus')) * 60);
   END;

 END;

end;


initialization
  {$I opentempus.lrs}

end.

