require "cinch"

require "lita"
require "lita/adapters/irc/cinch_plugin"

module Lita
  module Adapters
    class IRC < Adapter
      # Required attributes
      config :channels, type: [Array, String], required: true
      config :server, type: String, required: true

      # Optional attributes
      config :user, type: String, default: "Lita"
      config :password, type: String
      config :realname, type: String, default: "Lita"
      config :log_level, type: Symbol
      config :cinch do
        validate do |value|
          "must be a callable object" unless value.respond_to?(:call)
        end
      end

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
          send_messages_to_user(target, strings)
        else
          send_messages_to_channel(target, strings)
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
          config.cinch.call(cinch_config) if config.cinch

          cinch_config.channels = channels
          cinch_config.server = config.server
          cinch_config.nick = robot.config.robot.name

          cinch_config.user = config.user if config.user
          cinch_config.password = config.password if config.password
          cinch_config.realname = config.realname if config.realname
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
          cinch_config.plugins.plugins ||= []
          cinch_config.plugins.plugins += [CinchPlugin]
          cinch_config.plugins.options[CinchPlugin] = { robot: robot }
        end
      end

      def send_message_to_target(target, string)
        string_without_action = string.gsub(/^\/me\s+/i, "")

        if string == string_without_action
          target.send(string)
        else
          target.action(string_without_action)
        end
      end

      def send_messages_to_channel(target, strings)
        channel = Cinch::Channel.new(target.room, cinch)
        strings.each { |string| send_message_to_target(channel, string) }
      end

      def send_messages_to_user(target, strings)
        user = Cinch::User.new(target.user.name, cinch)
        strings.each { |string| send_message_to_target(user, string) }
      end
    end

    Lita.register_adapter(:irc, IRC)
  end
end
