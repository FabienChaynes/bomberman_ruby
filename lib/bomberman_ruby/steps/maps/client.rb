# frozen_string_literal: true

module BombermanRuby
  module Steps
    module Maps
      class Client < Base
        include Steps::Concerns::Clients::Networkable

        BASE_SERIALIZABLE_CLASSES = "BombermanRuby::Entities::"
        DESERIALIZABLE_CLASSES = [
          "Bomb",
          "Blocks::Soft",
          "Buttons::RotationChange",
          "Buttons::SpeedChange",
          "Conveyors::BottomLeft",
          "Conveyors::BottomRight",
          "Conveyors::Down",
          "Conveyors::Left",
          "Conveyors::Right",
          "Conveyors::TopLeft",
          "Conveyors::TopRight",
          "Conveyors::Up",
          "CurveMarks::Rotating::Down",
          "CurveMarks::Rotating::Up",
          "Fire",
          "Hole",
          "Items::BombUp",
          "Items::FireUp",
          "Items::FullFire",
          "Items::Skull",
          "Items::SpeedUp",
          "Items::Kick",
          "Items::Punch",
          "Items::LineBomb",
          "Pipes::Base",
          "Pipes::Down",
          "Pipes::Left",
          "Pipes::Middle",
          "Pipes::Right",
          "Pipes::Up",
          "Player",
          "SnowHut",
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
