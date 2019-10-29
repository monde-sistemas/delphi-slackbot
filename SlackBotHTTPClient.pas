unit SlackbotHTTPClient;

interface

type
  TSlackbotHTTPClient = class
    class function Post(const URL, Msg: string): string;
  end;

implementation

uses
  System.Net.HTTPClient,
  System.Classes,
  System.SysUtils;

class function TSlackbotHTTPClient.Post(const URL, Msg: string): string;
var
  HTTPClient: THTTPClient;
  Stream: TStringStream;
begin
  HTTPClient := nil;
  Stream := nil;
  try
    HTTPClient := THTTPClient.Create;
    Stream := TStringStream.Create(Msg, TEncoding.UTF8);

    Result := HTTPClient.Post(URL, Stream).ContentAsString(TEncoding.UTF8);
  finally
    Stream.Free;
    HTTPClient.Free;
  end;
end;

end.