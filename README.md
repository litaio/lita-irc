# lita-irc

[![Build Status](https://travis-ci.org/jimmycuadra/lita-irc.png?branch=master)](https://travis-ci.org/jimmycuadra/lita-irc)
[![Code Climate](https://codeclimate.com/github/jimmycuadra/lita-irc.png)](https://codeclimate.com/github/jimmycuadra/lita-irc)
[![Coverage Status](https://coveralls.io/repos/jimmycuadra/lita-irc/badge.png)](https://coveralls.io/r/jimmycuadra/lita-irc)

**lita-irc** is an adapter for [Lita](https://github.com/jimmycuadra/lita) that allows you to use the robot with IRC.

## Installation

Add lita-irc to your Lita instance's Gemfile:

``` ruby
gem "lita-irc"
```

## Configuration

### Required attributes

* `server` (String) - The name of the IRC server Lita should connect to.
* `channels` (Array<String>) - An array of channels Lita should join upon connection.

### Optional attributes

* `user` (String) - The username for Lita's IRC account. Default: `"Lita"`.
* `password` (String) - The password for Lita's IRC account. Default: `nil`.
* `realname` (String) - The "real name" field for Lita's IRC account. Default: `"Lita"`.
* `log_level` (Symbol) - Sets the log level for Cinch's loggers. By default, Cinch's loggers are disabled. Default: `nil`.

### Additional Cinch options

Under the hood, lita-irc uses [Cinch](https://github.com/cinchrb/cinch) for the IRC connection. Cinch has several [configuration options](http://www.rubydoc.info/github/cinchrb/cinch/file/docs/bot_options.md) that you may want to set. To do this, assign a proc/lambda to `config.adapters.irc.cinch`. lita-irc will yield the Cinch configuration object to the proc, so you can configure it as you'd like. Note that for the options listed in the sections above, those values will overwrite anything set in the proc.

**Note**: `config.robot.name` is used as Lita's IRC nickname. The `nick` attribute of the Cinch options is overwritten with this value.

### config.robot.admins

Each IRC user has a unique ID that Lita generates and stores the first time that user is encountered. To populate the `config.robot.admins` attribute, you'll need to use these IDs for each user you want to mark as an administrator. If you're using Lita version 4.1 or greater, you can get a user's ID by sending Lita the command `users find NICKNAME_OF_USER`.

### Example

``` ruby
Lita.configure do |config|
  config.robot.name = "Lita"
  config.robot.adapter = :irc
  config.robot.admins = ["eed844bf-2df0-4091-943a-7ee05ef36f4a"]
  config.adapters.irc.server = "irc.freenode.net"
  config.adapters.irc.channels = ["#litabot"]
  config.adapters.irc.user = "Lita"
  config.adapters.irc.realname = "Lita"
  config.adapters.irc.password = "secret"
  config.adapters.irc.cinch = lambda do |cinch_config|
    cinch_config.max_reconnect_delay = 123
  end
end
```

## Events

The IRC adapter will trigger the `:connected` and `:disconnected` events when the robot has connected and disconnected from IRC, respectively. There is no payload data for either event.

## License

[MIT](http://opensource.org/licenses/MIT)
