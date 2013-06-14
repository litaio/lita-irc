Lita.configure do |config|
  config.adapter.name = :irc
  config.adapter.server = "irc.freenode.net"
  config.adapter.channels = ["#litabot"]
  config.adapter.nick = "LitaBot"
end
