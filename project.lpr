program opentempusc;

{$mode objfpc}{$H+}

{$IFDEF Windows}
{$R project.rc}
{$ENDIF}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads, cmem
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { you can add units after this }, opentempus,  utils, apiplatforms,
  configuration, otlog, rules, report, storage, threadprocess, Custom;

begin
  Application.Title:='opentempus';
  Application.Initialize;
  Application.ShowMainForm := False;
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TCustom, CustomWindowTask);
  Application.Run;
end.

