unit rules;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dialogs;

type

TRule = class

  Window   : String;
  Process : String;
  Logic : String;
  IdTask: Integer;

  constructor Create(cWindow: String; cProcess   : String; cLogic: String;  cIdTask : Integer);
  function Check(WindoTitle: string;  ProcessName: string): integer;
end;

implementation


constructor TRule.Create ( cWindow: String; cProcess : String; cLogic: String; cIdTask : Integer);
begin
 self.Window := cWindow;
 self.Process := cProcess;
 self.Logic := cLogic;
 self.IdTask := cIdTask;

end;

function TRule.Check(WindoTitle: string;  ProcessName: string): integer;
var
 idt: integer;
begin
 idt := 0;

  IF (Pos(lowercase(self.Window),lowercase(WindoTitle)) > 0) OR (Pos(lowercase(self.Process),lowercase(ProcessName)) > 0) THEN BEGIN
      IF (self.Logic = 'OR') OR ((self.Logic = 'AND') AND (Pos(lowercase(self.Window),lowercase(WindoTitle)) > 0) AND (Pos(lowercase(self.Process),lowercase(ProcessName)) > 0)) THEN BEGIN
         idt := self.IdTask;
      END
  END;

 result := idt;
end;

end.

