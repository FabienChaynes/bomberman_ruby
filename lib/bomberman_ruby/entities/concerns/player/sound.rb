# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Concerns
      module Player
        module Sound
          ASSETS_PATH = "#{__dir__}/../../../../../assets".freeze
          ITEM_SAMPLE = Gosu::Sample.new("#{ASSETS_PATH}/sound/item.wav").freeze
          DROPPED_BOMB_SAMPLE = Gosu::Sample.new("#{ASSETS_PATH}/sound/bomb_dropped.wav").freeze
          ROUND_VICTORY_SAMPLE = Gosu::Sample.new("#{ASSETS_PATH}/sound/round_victory.wav").freeze

          private

          def reset_sound!
            @sound = nil
          end

          def play_sound
            case @sound
            when :drop_bomb
              DROPPED_BOMB_SAMPLE.play
            when :loot_item
              ITEM_SAMPLE.play
            when :winning
              ROUND_VICTORY_SAMPLE.play
            end
          end
        end
      end
    end
  end
end
