unit SlackbotTests;

interface

uses
  Classes,
  DUnitX.TestFramework,
  Slackbot;

type
  {$M+}
  [TestFixture]
  TSlackbotTests = class
  private
    FPostedURL: string;
    FPostedText: string;
    procedure DeleteEnvironmentVariables;
    function PostOK(const URL, Msg: string): string;
    procedure SetEnvironmentVariables;
  public
    [Setup]
    procedure SetUp;
  published
    procedure Send_ValidURLAndChannel_ChannelEncodedAndAppendedToURL;
    procedure Send_TextWithWindowsLineBreaks_CRRemoveFromMessage;
    procedure Send_URLWithoutHTTPS_ESlackbotError;
    procedure Send_URLWithoutToken_ESlackbotError;
    procedure Send_URLAndChannelConfigInEnvironmentVars_URLAndChannelReadFromEnvironment;
    procedure Send_URLConfigInEnvironmentVars_URLReadFromEnvironment;
    procedure Send_OnExceptionAssignedAndExceptionRaised_OnExceptionCalledWithException;
    procedure Send_OnExceptionAssignedAndVariablesNotSet_OnExceptionCalledWithException;
  end;

implementation

uses
  Winapi.Windows,
  System.SysUtils;

const
  ValidChannel = '#my_channel';
  ValidURL = 'https://my.slack.com/services/hooks/slackbot?token=my_token';

procedure TSlackbotTests.DeleteEnvironmentVariables;
begin
  SetEnvironmentVariable(PChar(SLACKBOT_URL), nil);
  SetEnvironmentVariable(PChar(SLACKBOT_CHANNEL), nil);
end;

function TSlackbotTests.PostOK(const URL, Msg: string): string;
begin
  FPostedURL := URL;
  FPostedText := Msg;
  Result := 'ok';
end;

procedure TSlackbotTests.Send_URLAndChannelConfigInEnvironmentVars_URLAndChannelReadFromEnvironment;
begin
  try
    SetEnvironmentVariables;

    TSlackbot.Send('text');

    Assert.AreEqual(ValidURL + '&channel=%23my_channel', FPostedURL);
  finally
    DeleteEnvironmentVariables;
  end;
end;

procedure TSlackbotTests.Send_URLConfigInEnvironmentVars_URLReadFromEnvironment;
begin
  try
    SetEnvironmentVariables;

    TSlackbot.Send('#another_channel', 'text');

    Assert.AreEqual(ValidURL + '&channel=%23another_channel', FPostedURL);
  finally
    DeleteEnvironmentVariables;
  end;
end;

procedure TSlackbotTests.Send_OnExceptionAssignedAndExceptionRaised_OnExceptionCalledWithException;
var
  RaisedException: Exception;
begin
  TSlackbot.OnException :=
    procedure(E: Exception)
    begin
      RaisedException := E;
    end;

  TSlackbot.Send('invalid_url_will_raise_Exception', '', '');

  Assert.IsNotNull(RaisedException, 'OnException event was not called');
end;

procedure TSlackbotTests.Send_OnExceptionAssignedAndVariablesNotSet_OnExceptionCalledWithException;
var
  RaisedException: Exception;
begin
  DeleteEnvironmentVariables;

  TSlackbot.OnException :=
    procedure(E: Exception)
    begin
      RaisedException := E;
    end;

  TSlackbot.Send('boom');

  Assert.IsNotNull(RaisedException, 'OnException event was not called');
end;

procedure TSlackbotTests.Send_TextWithWindowsLineBreaks_CRRemoveFromMessage;
begin
  TSlackbot.Send(ValidURL, ValidChannel, 'Line 1' + sLineBreak + 'Line 2');

  Assert.AreEqual('Line 1' + #10 + 'Line 2', FPostedText);
end;

procedure TSlackbotTests.Send_URLWithoutHTTPS_ESlackbotError;
begin
  Assert.WillRaise(
    procedure
    begin
      TSlackbot.Send('invalid_url', '', '');
    end, ESlackbotError);
end;

procedure TSlackbotTests.Send_URLWithoutToken_ESlackbotError;
begin
  Assert.WillRaise(
    procedure
    begin
      TSlackbot.Send('https://my.slack.com/services/hooks/slackbot', '', '');
    end, ESlackbotError);
end;

procedure TSlackbotTests.Send_ValidURLAndChannel_ChannelEncodedAndAppendedToURL;
begin
  TSlackbot.Send(ValidURL, '#my_channel', 'Msg');

  Assert.AreEqual(ValidURL + '&channel=%23my_channel', FPostedURL);
end;

procedure TSlackbotTests.SetEnvironmentVariables;
begin
  SetEnvironmentVariable(PChar(SLACKBOT_URL), PChar(ValidURL));
  SetEnvironmentVariable(PChar(SLACKBOT_CHANNEL), PChar(ValidChannel));
end;

procedure TSlackbotTests.SetUp;
begin
  FPostedURL := '';
  FPostedText := '';
  TSlackbot.HTTPPostFunc := PostOK;
  TSlackbot.OnException := nil;
end;

initialization
  TDUnitX.RegisterTestFixture(TSlackbotTests);

end.
