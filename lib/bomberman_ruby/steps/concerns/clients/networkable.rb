# frozen_string_literal: true

module BombermanRuby
  module Steps
    module Concerns
      module Clients
        module Networkable
          private

          def read_next_socket_message
            msg, = @game.socket.recvfrom_nonblock(1_000)
            msg.unpack("Ca*")
          end

          def process_next_message
            instruction, data = read_next_socket_message
            if instruction == Games::Host::NETWORK_INSTRUCTIONS[:step]
              step_id, sub_step_id = data.unpack("C2")
              if step_id == Steps::Base::STEP_IDS[:menu]
                @game.step = Menus::Client.new(game: @game)
              elsif step_id == Steps::Base::STEP_IDS[:map]
                @game.step = Steps::Maps::Client.new(game: @game, index: sub_step_id.to_i)
              end
            end
            data if instruction == Games::Host::NETWORK_INSTRUCTIONS[:entities]
          end

          def last_socket_entities_message
            entities = nil
            begin
              loop do
                process_next_message.tap do |data|
                  entities = data if data
                end
              end
            rescue IO::EAGAINWaitReadable
              # Do nothing
            end
            entities
          end

          def read_socket
            return unless (entities_msg = last_socket_entities_message)

            deserialiaze_socket_message(entities_msg)
              .select { |e| self.class::DESERIALIZABLE_CLASSES.include?(e["class"]) }
          end

          def deserialiaze_socket_message(msg)
            MessagePack.unpack(Zlib::Inflate.inflate(msg))
          end
        end
      end
    end
  end
end
