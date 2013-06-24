# lita-irc

[![Build Status](https://travis-ci.org/jimmycuadra/lita-irc.png)](https://travis-ci.org/jimmycuadra/lita-irc)
[![Code Climate](https://codeclimate.com/github/jimmycuadra/lita-irc.png)](https://codeclimate.com/github/jimmycuadra/lita-irc)
[![Coverage Status](https://coveralls.io/repos/jimmycuadra/lita-irc/badge.png)](https://coveralls.io/r/jimmycuadra/lita-irc)

**lita-irc** is an adapter for [Lita](https://github.com/jimmycuadra/lita) that allows you to use the robot with IRC.

## Installation

Add lita-irc to your Lita instance's Gemfile:

``` ruby
gem "lita-irc"
```

## Configuration

All attributes set on `config.adapter` will be passed on to the underlying [Cinch](https://github.com/cinchrb/cinch) robot. The documentation for [Cinch's options](http://rubydoc.info/github/cinchrb/cinch/file/docs/bot_options.md) detail all of them.

The attributes listed below are either fundamental to making the bot work, or have defaults provided by Lita that take precedence over Cinch's defaults.

### Required attributes

* `server` (String) - The name of the IRC server Lita should connect to. Default: `nil`.
* `channels` (Array<String>) - An array of channels Lita should join upon connection. Default: `nil`.

### Optional attributes

* `user` (String) - The username for Lita's IRC account. Default: `"Lita"".
* `password` (String) - The password for Lita's IRC account. Default: `nil`.
* `realname` (String) - The "real name" field for Lita's IRC account. Default: `"Lita"`.

**Note**: `config.robot.name` is used as Lita's IRC nickname. `config.adapter.nick` is ignored.

### Example

``` ruby
Lita.configure do |config|
  config.robot.name = "Lita"
  config.robot.adapter = :irc
  config.adapter.server = "irc.freenode.net"
  config.adapter.channels = ["#litabot"]
  config.adapter.user = "Lita"
  config.adapter.realname = "Lita"
  config.adapter.password = "secret"
end
```

## License

[MIT](http://opensource.org/licenses/MIT)
