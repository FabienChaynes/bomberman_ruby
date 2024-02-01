# frozen_string_literal: true

module BombermanRuby
  module Steps
    module Concerns
      module Hosts
        module Networkable
          private

          def send_entities(entities)
            return unless @game.client_sockets.any?

            serialized_entities = serialiaze_socket_message(entities.map(&:serialize))
            @game.client_sockets.each do |s|
              @game.socket.send([Games::Host::NETWORK_INSTRUCTIONS[:entities], serialized_entities].pack("Ca*"), 0,
                                s[:ip], s[:port])
            end
          end

          def send_step(step_id, sub_step_id = 0)
            @game.client_sockets.each do |s|
              @game.socket.send([Games::Host::NETWORK_INSTRUCTIONS[:step], step_id, sub_step_id].pack("C3"), 0,
                                s[:ip], s[:port])
            end
          end

          def serialiaze_socket_message(msg)
            Zlib::Deflate.deflate(msg.to_msgpack)
          end
        end
      end
    end
  end
end
