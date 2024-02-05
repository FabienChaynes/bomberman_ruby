# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Buttons
      class SpeedChange < Base
        private

        def current_sprite
          @triggered ? SPRITES[1] : SPRITES[0]
        end

        def trigger!
          @map.entities.each do |entity|
            next unless entity.is_a?(Conveyors::Base)

            entity.fast = !entity.fast
          end
        end
      end
    end
  end
end
