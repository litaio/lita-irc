require "securerandom"

module Lita
  module Adapters
    class IRC < Adapter
      class CinchPlugin
        include Cinch::Plugin

        match /.*/
        listen_to :connect, method: :on_connect
        listen_to :invite, method: :on_invite
        listen_to :join, method: :on_room_join
        listen_to :part, method: :on_room_part
        listen_to :quit, method: :on_quit
        listen_to :nick, method: :on_nick_change

        def execute(m)
          body = get_body(m)
          source = get_source(m)
          message = Message.new(robot, body, source)
          message.command! unless source.room
          dispatch(message)
        end

        def on_connect(m)
          robot.trigger(:connected)
        end

        def on_invite(m)
          user = user_by_nick(m.user.nick)
          m.channel.join if robot.auth.user_is_admin?(user)
        end

        def on_room_join(m)
          robot.trigger(
            :user_joined_room,
            user: user_by_nick(m.user.nick),
            room: Lita::Room.create_or_update(m.channel.name, name: m.channel.name),
          )
        end

        def on_room_part(m)
          robot.trigger(
            :user_parted_room,
            user: user_by_nick(m.user.nick),
            room: Lita::Room.create_or_update(m.channel.name, name: m.channel.name),
          )
        end

        def on_quit(m)
          robot.trigger(
            :user_disconnected,
            user: user_by_nick(m.user.nick),
          )
        end

        def on_nick_change(m)
          robot.trigger(
            :user_nick_changed,
            old_user: user_by_nick(m.prefix.gsub(/!.*/, '')),
            user: user_by_nick(m.user.nick),
          )
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

        def get_body(m)
          if m.action?
            m.action_message
          else
            m.message
          end
        end

        def get_source(m)
          user = user_by_nick(m.user.nick)
          channel = m.channel ? m.channel.name : nil
          Source.new(user: user, room: channel)
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
