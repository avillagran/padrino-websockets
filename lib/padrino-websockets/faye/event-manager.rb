module Padrino
  module WebSockets
    module Faye
      class EventManager < BaseEventManager
        def initialize(channel, user, ws, event_context, &block)
          @channel = channel
          logger.info "initialize channel: #{channel} user: #{user}"
          ws.on :open do |event|
            self.on_open event #&method(:on_open)
          end
          ws.on :message do |event|
            self.on_message event.data, @ws
          end
          ws.on :close do |event|
            self.on_shutdown event # method(:on_shutdown)
          end

          super channel, user, ws, event_context, &block
        end

        ##
        # Manage the WebSocket's connection being closed.
        #
        def on_shutdown(event)
          @pinger.cancel if @pinger
          super
        end

        ##
        # Write a message to the WebSocket.
        #
        def self.write(message, ws)
          ws.send ::Oj.dump(message)
        end

        ##
        # Send message on channel to user
        #
        def send_message(message)
           Padrino::WebSockets::Faye::EventManager.send_message(@channel,@user,message)
        end

        protected
          ##
          # Maintain the connection if ping frames are supported
          #
          def on_open(event)
            super event

            @ws.ping('pong')
          end
      end
    end
  end
end
