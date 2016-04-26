program Tests;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  DUnitXTestRunner in 'DUnitXTestRunner.pas',
  SlackbotTests in 'SlackbotTests.pas',
  Slackbot in '..\Slackbot.pas',
  SlackbotHTTPIndy in '..\SlackbotHTTPIndy.pas';

begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  TDunitXTestRunner.RunTests;
end.
