unit SlackbotHTTPIndy;

interface

type
  TSlackbotHTTPIndy = class
    class function Post(const URL, Msg: string): string;
  end;

implementation

uses
  IdHTTP,
  IdSSLOpenSSL,
  System.Classes;

class function TSlackbotHTTPIndy.Post(const URL, Msg: string): string;
var
  HTTP: TIdHTTP;
  Stream: TStringStream;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  HTTP := nil;
  SSLHandler := nil;
  Stream := nil;
  try
    HTTP := TIdHTTP.Create(nil);
    SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

    Stream := TStringStream.Create;
    Stream.WriteString(Msg);

    HTTP.IOHandler := SSLHandler;
    Result := HTTP.Post(URL, Stream)
  finally
    Stream.Free;
    SSLHandler.Free;
    HTTP.Free;
  end;
end;

end.
