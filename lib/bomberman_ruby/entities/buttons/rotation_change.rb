# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Buttons
      class RotationChange < Base
        private

        def current_sprite
          @triggered ? SPRITES[3] : SPRITES[2]
        end

        def trigger!
          @map.entities.each do |entity|
            next unless entity.is_a?(Conveyors::Base)

            entity.reverse = !entity.reverse
          end
        end
      end
    end
  end
end
