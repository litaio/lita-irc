require "securerandom"

module Lita
  module Adapters
    class IRC < Adapter
      class CinchPlugin
        include Cinch::Plugin

        match /.*/

        def execute(m)
          body = m.action? ? m.action_message : m.message
          user = user_by_nick(m.user.nick)
          channel = m.channel ? m.channel.name : nil
          source = Source.new(user, channel)
          message = Message.new(robot, body, source)
          message.command! unless channel
          dispatch(message)
        end

        private

        def dispatch(message)
          channel_text = " in #{message.source.room}" if message.source.room
          Lita.logger.debug(<<-MSG.chomp
Dispatching message to Lita from #{message.source.user.name}#{channel_text}.
MSG
          )
          robot.receive(message)
        end

        def robot
          config[:robot]
        end

        def user_by_nick(nick)
          Lita.logger.debug("Looking up user with nick: #{nick}.")
          User.find_by_name(nick) || User.create(SecureRandom.uuid, name: nick)
        end
      end
    end
  end
end
