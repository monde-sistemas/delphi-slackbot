unit Slackbot;

interface

uses
  System.SysUtils, SlackbotHTTPIndy;

const
  SLACKBOT_CHANNEL = 'SLACKBOT_CHANNEL';
  SLACKBOT_URL = 'SLACKBOT_URL';

type
  THTTPPostFunc = reference to function(const URL, Msg: string): string;
  TSlackbot = class
  private
    class function ReadConfigFromEnvironment(const VarName: string): string;
    class procedure ValidateURL(const URL: string);
  public
    class var HTTPPostFunc: THTTPPostFunc;
    class procedure Send(const Text: string); overload;
    class procedure Send(const Channel, Text: string); overload;
    class procedure Send(const URL, Channel, Text: string); overload;
  end;

  ESlackbotError = class(Exception);

implementation

uses
  IdURI;

class procedure TSlackbot.Send(const Channel, Text: string);
var
  URL: string;
begin
  URL := ReadConfigFromEnvironment(SLACKBOT_URL);
  Send(URL, Channel, Text);
end;

class function TSlackbot.ReadConfigFromEnvironment(const VarName: string): string;
begin
  Result := GetEnvironmentVariable(VarName);
  if Result.IsEmpty then
    raise ESlackbotError.CreateFmt('%s environment variable not set.', [VarName]);
end;

class procedure TSlackbot.Send(const URL, Channel, Text: string);
var
  URLWithChannel: string;
begin
  ValidateURL(URL);
  URLWithChannel := Format('%s&channel=%s', [URL, TIdURI.ParamsEncode(Channel)]);

  if not Assigned(HTTPPostFunc) then
    HTTPPostFunc := TSlackbotHTTPIndy.Post;

  HTTPPostFunc(URLWithChannel, Text.Replace(#13, ''));
end;

class procedure TSlackbot.Send(const Text: string);
var
  URL, Channel: string;
begin
  URL := ReadConfigFromEnvironment(SLACKBOT_URL);
  Channel := ReadConfigFromEnvironment(SLACKBOT_CHANNEL);

  Send(URL, Channel, Text);
end;

class procedure TSlackbot.ValidateURL(const URL: string);
begin
  if not URL.StartsWith('https') then
    raise ESlackbotError.CreateFmt('Invalid URL: %s. Protocol must be https.', [URL]);

  if not URL.Contains('?token=') then
    raise ESlackbotError.CreateFmt('Invalid URL: %s. Token not found.', [URL]);
end;

end.
