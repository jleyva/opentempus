unit storage;


{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dialogs, DOM, XMLRead, XMLWrite, configuration, utils;

type

TStorage = class

  FPath  : String;
  Name   : String;
  Author : String;
  Version: String;
  Bin   : String;
  Params : String;
  Enabled: Boolean;
  Freq: integer;
  FreqExec: Boolean;
  Summary: String;
  DirPath: String;
  CFG: TOTConfig;
  Counter: Integer;

  constructor Create(FilePath: String; mCFG: TOTConfig);
  function CmdLine: string;
  procedure SetEnabled(status: boolean);
end;

implementation


constructor TStorage.Create (FilePath: String; mCFG: TOTConfig);
var
  Node:     TDOMNode;
  Doc:      TXMLDocument;
begin

  self.FPath := FilePath;
  self.Name   := '';
  self.Author := '';
  self.Version:= '';
  self.Bin   := '';
  self.Params := '';
  self.Enabled := false;
  self.Freq := 0;
  self.FreqExec := false;
  self.Summary:= '';
  self.Counter := 0;


  self.CFG := mCFG;
  self.DirPath := ExtractFilePath(FilePath);

  IF FileExists(FilePath) THEN BEGIN
   try
     ReadXMLFile(Doc, FilePath);
     Node := Doc.DocumentElement.FindNode('name');
     self.Name := OTFormatString(Node.TextContent);
     Node := Doc.DocumentElement.FindNode('author');
     self.Author := OTFormatString(Node.TextContent);
     Node := Doc.DocumentElement.FindNode('version');
     self.Version := OTFormatString(Node.TextContent);
     Node := Doc.DocumentElement.FindNode('bin');
     self.Bin := OTFormatString(Node.TextContent);
     Node := Doc.DocumentElement.FindNode('params');
     self.Params := OTFormatString(Node.TextContent);
     Node := Doc.DocumentElement.FindNode('enabled');
     self.Enabled := strtobool(Node.TextContent);
     Node := Doc.DocumentElement.FindNode('freq');
     self.Freq := strtoint(Node.TextContent);
     Node := Doc.DocumentElement.FindNode('freqexec');
     self.FreqExec := strtobool(Node.TextContent);
     Node := Doc.DocumentElement.FindNode('summary');
     self.Summary := OTFormatString(Node.TextContent);
   finally
     Doc.Free;
   end;
  END
end;

function TStorage.CmdLine: string;
var
 cmline: string;

begin

 //Binary script
 {$IFDEF Windows}
 cmline := CFG.PHPBin;
 cmline := cmline+' -c '+CFG.PHPPath;
 {$ENDIF}
 {$IFDEF unix}
 cmline := CFG.PHPBin;
 {$ENDIF}

 self.Params := StringReplace(self.Params, '{dirpath}', self.DirPath, [rfReplaceAll, rfIgnoreCase]);
 self.Params := StringReplace(self.Params, '{dbpath}', CFG.DBPath, [rfReplaceAll, rfIgnoreCase]);

 cmline := cmline+' '+self.Params;

 result := cmline;
end;

procedure TStorage.SetEnabled(status: boolean);
var
  Node:     TDOMNode;
  Doc:      TXMLDocument;
begin
  IF status = NOT self.Enabled THEN
    IF FileExists(self.FPath) THEN BEGIN
     try
      ReadXMLFile(Doc, self.FPath);
      Node := Doc.DocumentElement.FindNode('enabled');
      Node.TextContent:=booltostr(status,true);
      WriteXMLFile(Doc,self.FPath);
     finally
      Doc.Free;
      self.Enabled:=status;
     end;
    END
end;

end.


