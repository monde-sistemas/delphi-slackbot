unit Slackbot;

interface

uses
  System.SysUtils,
  SlackbotHTTPIndy;

const
  SLACKBOT_CHANNEL = 'SLACKBOT_CHANNEL';
  SLACKBOT_URL = 'SLACKBOT_URL';

type
  THTTPPostFunc = reference to function(const URL, Msg: string): string;
  TExceptionEvent = reference to procedure(E: Exception);

  TSlackbot = class
  private
    class var FOnException: TExceptionEvent;
    class procedure HandleException;
    class function ReadConfigFromEnvironment(const VarName: string): string;
    class procedure ValidateURL(const URL: string);
  public
    class var HTTPPostFunc: THTTPPostFunc;
    class procedure Send(const Text: string); overload;
    class procedure Send(const Channel, Text: string); overload;
    class procedure Send(const URL, Channel, Text: string); overload;
    class property OnException: TExceptionEvent read FOnException write FOnException;
  end;

  ESlackbotError = class(Exception);

implementation

uses
  IdURI;

class procedure TSlackbot.HandleException;
var
  E: Exception;
begin
  {$IF CompilerVersion >= 32.0 }
  E := AcquireExceptionObject as Exception;
  {$ELSE}
  E := AcquireExceptionObject;
  {$ENDIF}
  if not Assigned(FOnException) then
    raise E;

  try
    try
      FOnException(E);
    except
      // If the exception handler crashes the show must go on
    end;
  finally
    E.Free;
  end;
end;

class procedure TSlackbot.Send(const Channel, Text: string);
var
  URL: string;
begin
  try
    URL := ReadConfigFromEnvironment(SLACKBOT_URL);
    Send(URL, Channel, Text);
  except
    HandleException;
  end;
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
  try
    ValidateURL(URL);
    URLWithChannel := Format('%s&channel=%s', [URL, TIdURI.ParamsEncode(Channel)]);

    if not Assigned(HTTPPostFunc) then
      HTTPPostFunc := TSlackbotHTTPIndy.Post;

    HTTPPostFunc(URLWithChannel, Text.Replace(#13, ''));
  except
    HandleException;
  end;
end;

class procedure TSlackbot.Send(const Text: string);
var
  URL, Channel: string;
begin
  try
    URL := ReadConfigFromEnvironment(SLACKBOT_URL);
    Channel := ReadConfigFromEnvironment(SLACKBOT_CHANNEL);

    Send(URL, Channel, Text);
  except
    HandleException;
  end;
end;

class procedure TSlackbot.ValidateURL(const URL: string);
begin
  if not URL.StartsWith('https') then
    raise ESlackbotError.CreateFmt('Invalid URL: %s. Protocol must be https.', [URL]);

  if not URL.Contains('?token=') then
    raise ESlackbotError.CreateFmt('Invalid URL: %s. Token not found.', [URL]);
end;

end.
