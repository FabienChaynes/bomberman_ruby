# frozen_string_literal: true

module BombermanRuby
  module Steps
    module Maps
      class Client < Base
        include Steps::Concerns::Clients::Networkable

        BASE_SERIALIZABLE_CLASSES = "BombermanRuby::Entities::"
        DESERIALIZABLE_CLASSES = [
          "Conveyors::BottomLeft",
          "Conveyors::BottomRight",
          "Conveyors::Down",
          "Conveyors::Left",
          "Conveyors::Right",
          "Conveyors::TopLeft",
          "Conveyors::TopRight",
          "Conveyors::Up",
          "Bomb",
          "Blocks::Soft",
          "Buttons::RotationChange",
          "Buttons::SpeedChange",
          "Fire",
          "Items::BombUp",
          "Items::FireUp",
          "Items::Skull",
          "Items::SpeedUp",
          "Items::Kick",
          "Items::Punch",
          "Items::LineBomb",
          "Player",
        ].freeze

        def update
          read_map
        end

        private

        def read_map
          return unless (entities = read_socket)

          @entities = []
          entities.each do |e|
            @entities << Object.const_get("#{BASE_SERIALIZABLE_CLASSES}#{e["class"]}").deserialize(self, e)
          end
        end
      end
    end
  end
end
