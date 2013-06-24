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
      end

      def run
        Lita.logger.info("Connecting to IRC.")
        cinch.start
      end

      def shut_down
        Lita.logger.info("Disconnecting from IRC.")
        cinch.quit
      end

      private

      def normalize_config
        Lita.config.adapter.channels = Array(Lita.config.adapter.channels)
        Lita.config.adapter.nick = Lita.config.robot.name
      end

      def configure_cinch
        Lita.logger.debug("Configuring Cinch.")
        cinch.configure do |config|
          config.plugins.plugins = [CinchPlugin]
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
    end

    Lita.register_adapter(:irc, IRC)
  end
end
