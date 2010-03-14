unit report;

{$mode objfpc}{$H+}


interface

uses
  Classes, SysUtils, dialogs, configuration, DOM, XMLRead, dateutils, utils;

type

TReport = class

  Name   : String;
  Author : String;
  Version: String;
  Bin   : String;
  Params : String;
  Output: String;
  Summary: String;
  DirPath: String;
  CFG: TOTConfig;

  constructor Create(FilePath: string; mCFG: TOTConfig);
  function CmdLine(StartDate, EndDate: string):string;
end;

implementation


constructor TReport.Create(FilePath: string; mCFG: TOTConfig);
var
  Node:     TDOMNode;
  Doc:      TXMLDocument;
begin

  self.Name   := '';
  self.Author := '';
  self.Version:= '';
  self.Bin   := '';
  self.Params := '';
  self.Output:= '';
  self.Summary:= '';

  self.CFG := mCFG;

  self.DirPath := ExtractFilePath(FilePath);

  IF FileExists(FilePath) THEN BEGIN
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
   Node := Doc.DocumentElement.FindNode('output');
   self.Output := OTFormatString(Node.TextContent);
   Node := Doc.DocumentElement.FindNode('summary');
   self.Summary := OTFormatString(Node.TextContent);
   Doc.Free;
  END

end;

function TReport.CmdLine(StartDate, EndDate: string): string;
var
 cmline, mparams: string;
 starttime, endtime: integer;
begin

 //Binary script
 {$IFDEF Windows}
 cmline := CFG.PHPBin;
 cmline := cmline+' -c '+CFG.PHPPath;
 {$ENDIF}
 {$IFDEF unix}
 cmline := CFG.PHPBin;
 {$ENDIF}

 starttime := 0;
 endtime := 0;

 IF StartDate <> '' THEN
  starttime := DateTimeToUnix(StrToDate(StartDate));
 IF EndDate <> '' THEN BEGIN
  endtime := DateTimeToUnix(StrToDate(EndDate));
  endtime := endtime + 86399;
 END;

 mparams := self.Params;

 mparams := StringReplace(mparams, '{dirpath}', self.DirPath, [rfReplaceAll, rfIgnoreCase]);
 mparams := StringReplace(mparams, '{dbpath}', CFG.DBPath, [rfReplaceAll, rfIgnoreCase]);
 mparams := StringReplace(mparams, '{reporthtmldir}', CFG.ReportsHtmlDir, [rfReplaceAll, rfIgnoreCase]);
 mparams := StringReplace(mparams, '{startdate}', StartDate, [rfReplaceAll, rfIgnoreCase]);
 mparams := StringReplace(mparams, '{enddate}', EndDate, [rfReplaceAll, rfIgnoreCase]);
 mparams := StringReplace(mparams, '{starttime}', IntToStr(starttime), [rfReplaceAll, rfIgnoreCase]);
 mparams := StringReplace(mparams, '{endtime}', IntToStr(endtime), [rfReplaceAll, rfIgnoreCase]);
 cmline := cmline+' '+mparams;

 result := cmline;
end;

end.
