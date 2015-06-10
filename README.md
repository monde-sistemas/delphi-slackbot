# delphi-slackbot
Delphi library to send messages on slack using slackbot.

## Enabling Slackbot integrations on Slack

Before using this library to post messages to [Slack](https://slack.com/), you must enable the Slackbot integration for your team and get your URL. Please, read the [Slack documentation](https://api.slack.com/slackbot) to learn how to do it.

## Using

You can either use `TSlackbot` reading the URL and channel from the environment or passing directly to the method.

### Examples

Read the URL and Channel from the `SLACKBOT_URL` and `SLACKBOT_CHANNEL` environment variables, respectively:
```Delphi
TSlackbot.Send('My message');
```
Only read the URL from the environment:
```Delphi
TSlackbot.Send('#my_channel', 'My message');
```
Use the URL and channel provided in the method params:
```Delphi
URL := 'https://example.slack.com/services/hooks/slackbot?token=example_token';
TSlackbot.Send(URL, '#my_channel', 'My message');
```

### OpenSSL

The default implementation uses [Indy](http://www.indyproject.org/index.en.aspx) and [OpenSSL](https://www.openssl.org/) for posting the message, so you must have the `libeay32.dll` and `ssleay32.dll` on your application path.

## Executing the tests

You need DUnitX do run the tests.

  * Clone the [DUnitX](https://github.com/VSoftTechnologies/DUnitX/) repository locally
  * Define a `DUNITX` environment variable, pointing to the DUnitX clone directory.

## Contributing

If you got something that's worth including into the project please [submit a Pull Request](https://github.com/monde-sistemas/delphi-slackbot/pulls) or [open an issue](https://github.com/monde-sistemas/delphi-slackbot/issues) for further discussion.

## License

This software is open source, licensed under the The MIT License (MIT). See [LICENSE](https://github.com/monde-sistemas/delphi-slackbot/blob/master/LICENSE) for details.
