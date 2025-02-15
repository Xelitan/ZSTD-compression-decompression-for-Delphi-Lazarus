# ZSTD-compression-decompression-for-Delphi-Lazarus
ZSTD compression/decompression for Delphi, Lazarus and Free Pascal

## Usage examples 
```
var F,P: TFileStream;
    Size: Integer;
begin
  ZSTD_COMPRESSION := 20; //slow, small file
  ZSTD_COMPRESSION := 1; //fast, big file

  F := TFileStream.Create('test.txt', fmOpenRead);
  P := TFileStream.Create('test.zstd', fmCreate);
  ZSTD(F, P);
  Size := F.Size;
  F.Free;
  P.Free;

  F := TFileStream.Create('test.zstd', fmOpenRead);
  P := TFileStream.Create('test2.txt', fmCreate);
  UnZSTD(F, P, Size);
  F.Free;
  P.Free;
```

## This unit uses ZSTD library:
Zstandard is dual-licensed under BSD OR GPLv2.
https://github.com/facebook/zstd

## Concatenation

Currently this unit compresses data without buffering. So when you compress a file- a whole file is read into RAM, compressed and then saved to disk.
If you want to compress huge files you should divide them into chunks, compress each chunk and then glue chunks together. Concatenation of ZSTD files is a valid ZSTD file.

## Compression
Compression level - anything between 1 (fast, big file) and 20 (slow, small file) is fine. Max is 22 but is very slow. Negative values are also possible but files are just impractically big.
