{

Some useful procedures and functions

}
unit utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dateutils, fileutil;


function UnixTime(): int64;
function OTFormatString(str: string):string;
procedure Split (const Delimiter: Char;Input: string; const Strings: TStrings);
function FileCopy(source,dest: String): Boolean;


implementation

function UnixTime(): int64;
begin
  Result := DateTimetounix(Now);

end;

function OTFormatString(str: string):string;
begin
 IF NeedRTLAnsi THEN BEGIN
  str := UTF8Encode(widestring(str));
 END;
 result := str;
end;

procedure Split (const Delimiter: Char; Input: string; const Strings: TStrings) ;
begin
   Assert(Assigned(Strings)) ;
   Strings.Clear;
   Strings.Delimiter := Delimiter;
   Strings.DelimitedText := Input;
end;

function FileCopy(source,dest: String): Boolean;
var
 fSrc,fDst,len: Integer;
 ct,units,size: Longint;
 buffer: packed array [0..2047] of Byte;
begin
 ct:=0;
 Result := False; { Assume that it WONT work }
 if source <> dest then begin
   fSrc := FileOpen(source,fmOpenRead);
   if fSrc >= 0 then begin
     size := FileSeek(fSrc,0,2);
     units:=size div 2048;
     FileSeek(fSrc,0,0);
     fDst := FileCreate(dest);
     if fDst >= 0 then begin
       while size > 0 do begin
         len := FileRead(fSrc,buffer,sizeof(buffer));
         FileWrite(fDst,buffer,len);
         size := size - len;
         if units > 0 then
         ct:=ct+1;
       end;
       FileSetDate(fDst,FileGetDate(fSrc));
       FileClose(fDst);
       FileSetAttr(dest,FileGetAttr(source));
       Result := True;
     end;
     FileClose(fSrc);
   end;
 end;
end;

end.

