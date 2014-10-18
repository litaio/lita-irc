require "cinch"

require "lita"
require "lita/adapters/irc/cinch_plugin"

module Lita
  module Adapters
    class IRC < Adapter
      CONTROLLED_CONFIG_KEYS = %i(channels server user realname)
      MANUALLY_ASSIGNED_KEYS = %i(channels nick)
      EXTRA_CINCH_OPTIONS = Cinch::Configuration::Bot::KnownOptions - CONTROLLED_CONFIG_KEYS

      # Required attributes
      config :channels, type: [Array, String], required: true
      config :server, type: String, required: true

      # Optional attributes
      config :user, type: String, default: "Lita"
      config :realname, type: String, default: "Lita"
      config :log_level, type: Symbol

      EXTRA_CINCH_OPTIONS.each { |option| config option }

      attr_reader :cinch

      def initialize(robot)
        super

        @cinch = Cinch::Bot.new
        configure_cinch
        configure_logging
        register_plugin
      end

      def run
        Lita.logger.info("Connecting to IRC.")
        cinch.start
      end

      def join(room_id)
        cinch.join(room_id)
      end

      def part(room_id)
        cinch.part(room_id)
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

      def channels
        Array(robot.config.adapters.irc.channels)
      end

      def configure_cinch
        Lita.logger.debug("Configuring Cinch.")
        cinch.configure do |cinch_config|
          cinch_config.channels = channels
          cinch_config.nick = robot.config.robot.name

          Cinch::Configuration::Bot::KnownOptions.each do |key|
            next if MANUALLY_ASSIGNED_KEYS.include?(key)
            value = config.public_send(key)
            cinch_config.public_send("#{key}=", value) unless value.nil?
          end
        end
      end

      def configure_logging
        if config.log_level
          cinch.loggers.level = config.log_level
        else
          cinch.loggers.clear
        end
      end

      def register_plugin
        cinch.configure do |cinch_config|
          cinch_config.plugins.prefix = nil
          cinch_config.plugins.plugins = [CinchPlugin]
          cinch_config.plugins.options[CinchPlugin] = { robot: robot }
        end
      end
    end

    Lita.register_adapter(:irc, IRC)
  end
end
