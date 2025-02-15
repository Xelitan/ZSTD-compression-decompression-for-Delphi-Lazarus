unit ZstdLib;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Description:	Zstd compressor and decompressor                              //
// Version:	0.1                                                           //
// Date:	15-FEB-2025                                                   //
// License:     MIT                                                           //
// Target:	Win64, Free Pascal, Delphi                                    //
// Copyright:	(c) 2025 Xelitan.com.                                         //
//		All rights reserved.                                          //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Classes, SysUtils, Dialogs;

  var ZSTD_COMPRESSION: Integer = 1;

  const ZSTD_LIB = 'libzstd.dll';

  function ZSTD_compress(dst: PByte; dstCapacity: NativeInt; const src: PByte; srcSize: NativeInt; compressionLevel: Integer): NativeInt; cdecl; external Zstd_LIB;
  function ZSTD_decompress(dst: PByte; dstCapacity: NativeInt; const src: PByte; compressedSize: NativeInt): NativeInt; cdecl; external Zstd_LIB;
  function ZSTD_isError(result: NativeInt): LongBool; cdecl; external Zstd_LIB;
  function ZSTD_compressBound(srcSize: NativeInt): NativeInt; cdecl; external Zstd_LIB;

  //Functions
  function Zstd(Data: PByte; DataLen: Integer; var OutData: TBytes): Boolean; overload;
  function UnZstd(Data: PByte; DataLen: Integer; var OutData: TBytes; OutDataLen: Integer): Boolean; overload;

  function Zstd(InStr, OutStr: TStream): Boolean; overload;
  function UnZstd(InStr, OutStr: TStream; OutDataLen: Integer): Boolean; overload;

  function Zstd(Str: String): String; overload;
  function UnZstd(Str: String; OutDataLen: Integer): String; overload;

implementation

function Zstd(Data: PByte; DataLen: Integer; var OutData: TBytes): Boolean;
var OutLen: Integer;
begin
  OutLen := ZSTD_compressBound(DataLen);
  SetLength(OutData, OutLen);

  OutLen := ZSTD_compress(@OutData[0], OutLen, Data, DataLen, Zstd_COMPRESSION);
  if ZSTD_isError(OutLen) then Exit(False);

  SetLength(OutData, OutLen);

  Result := True;
end;

function UnZstd(Data: PByte; DataLen: Integer; var OutData: TBytes; OutDataLen: Integer): Boolean;
begin
  SetLength(OutData, OutDataLen);

  OutDataLen := ZSTD_decompress(@OutData[0], OutDataLen, Data, DataLen);
  if ZSTD_isError(OutDataLen) then Exit(False);

  SetLength(OutData, OutDataLen);

  Result := True;
end;

function UnZstd(Str: String; OutDataLen: Integer): String;
var Res: Boolean;
    OutLen: Integer;
    OutData: TBytes;
begin
  Res := UnZstd(@Str[1], Length(Str), OutData, OutDataLen);
  if not Res then Exit('');

  OutLen := Length(OutData);
  SetLength(Result, OutLen);
  Move(OutData[0], Result[1], OutLen);
end;

function Zstd(InStr, OutStr: TStream): Boolean;
var Buf: array of Byte;
    Size: Integer;
    OutData: TBytes;
begin
  Result := False;
  try
    Size := InStr.Size - InStr.Position;
    SetLength(Buf, Size);
    InStr.Read(Buf[0], Size);

    if not Zstd(@Buf[0], Size, OutData) then Exit;

    OutStr.Write(OutData[0], Length(OutData));
    Result := True;
  finally
  end;
end;

function UnZstd(InStr, OutStr: TStream; OutDataLen: Integer): Boolean;
var Buf: array of Byte;
    Size: Integer;
    OutData: TBytes;
begin
  Result := False;
  try
    Size := InStr.Size - InStr.Position;
    SetLength(Buf, Size);
    InStr.Read(Buf[0], Size);

    if not UnZstd(@Buf[0], Size, OutData, OutDataLen) then Exit;

    OutStr.Write(OutData[0], Length(OutData));
    Result := True;
  finally
  end;
end;

function Zstd(Str: String): String;
var Res: Boolean;
    OutLen: Integer;
    OutData: TBytes;
begin
  Res := Zstd(@Str[1], Length(Str), OutData);
  if not Res then Exit('');

  OutLen := Length(OutData);
  SetLength(Result, OutLen);
  Move(OutData[0], Result[1], OutLen);
end;

end.
