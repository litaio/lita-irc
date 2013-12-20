require "cinch"

require "lita"
require "lita/adapters/irc/cinch_plugin"

module Lita
  module Adapters
    class IRC < Adapter
      require_configs :server, :channels

      attr_reader :cinch

      def initialize(robot)
        super

        @cinch = Cinch::Bot.new
        normalize_config
        configure_cinch
        configure_logging
        register_plugin
      end

      def run
        Lita.logger.info("Connecting to IRC.")
        cinch.start
      end

      def send_messages(target, strings)
        if target.private_message?
          user = Cinch::User.new(target.user.name, cinch)
          strings.each { |s| user.msg(s) }
        else
          channel = Cinch::Channel.new(target.room, cinch)
          strings.each { |s| channel.msg(s) }
        end
      end

      def set_topic(target, topic)
        room = target.room
        channel = Cinch::Channel.new(target.room, cinch)
        Lita.logger.debug("Setting topic for channel #{room}: #{topic}")
        channel.topic = topic
      end

      def shut_down
        Lita.logger.info("Disconnecting from IRC.")
        cinch.quit
        robot.trigger(:disconnected)
      end

      private

      def normalize_config
        Lita.config.adapter.channels = Array(Lita.config.adapter.channels)
        Lita.config.adapter.nick = Lita.config.robot.name
      end

      def configure_cinch
        Lita.logger.debug("Configuring Cinch.")
        cinch.configure do |config|
          Lita.config.adapter.each do |key, value|
            if config.class::KnownOptions.include?(key)
              config.send("#{key}=", value)
            end
          end
        end
      end

      def configure_logging
        if Lita.config.adapter.log_level
          cinch.loggers.level = Lita.config.adapter.log_level
        else
          cinch.loggers.clear
        end
      end

      def register_plugin
        cinch.configure do |config|
          config.plugins.prefix = nil
          config.plugins.plugins = [CinchPlugin]
          config.plugins.options[CinchPlugin] = { robot: robot }
        end
      end
    end

    Lita.register_adapter(:irc, IRC)
  end
end
