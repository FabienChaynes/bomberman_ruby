# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Conveyors
      class Down < Base
        SPRITES = [CONVEYOR_SPRITES[1], CONVEYOR_SPRITES[3], CONVEYOR_SPRITES[5]].freeze

        def draw
          current_sprite.draw_rot(@x, @y, CONVEYOR_Z, 90, 0, 1)
        end

        def y_delta
          @reverse ? speed * -1 : speed
        end

        def priority
          2
        end
      end
    end
  end
end
