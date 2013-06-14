require "lita"
require "cinch"

module Lita
  module Adapters
    class IRC < Adapter
      require_configs :server, :channels

      def run
        lita_robot = robot

        @bot = Cinch::Bot.new do
          configure do |config|
            config.nick = "Lita"
            config.user = "Lita"
            config.realname = "Lita"

            Lita.config.adapter.each do |key, value|
              next if key == :name

              if config.class::KnownOptions.include?(key)
                config.send("#{key}=", value)
              end
            end
          end

          on :message, /.+/ do |m|
            user_name = m.user.nick
            channel_name = m.channel.name if m.channel?

            source = Source.new(user_name, channel_name)
            message = Message.new(lita_robot, m.message, source)
            message.command! unless channel_name

            lita_robot.receive(message)
          end
        end

        @bot.start
      end

      def send_messages(source, strings)
        target = if source.room
          Cinch::Channel.new(source.room, @bot)
        else
          Cinch::User.new(source.user, @bot)
        end

        strings.each { |string| target.msg(string) }
      end
    end

    Lita.register_adapter(:irc, IRC)
  end
end
