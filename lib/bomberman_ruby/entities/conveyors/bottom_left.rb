# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Conveyors
      class BottomLeft < Base
        SPRITES = [CONVEYOR_SPRITES[0], CONVEYOR_SPRITES[2], CONVEYOR_SPRITES[4]].freeze

        def draw
          current_sprite.draw_rot(@x, @y, CONVEYOR_Z, -90, 1, 0)
        end

        def x_delta
          @reverse ? speed : 0
        end

        def y_delta
          @reverse ? 0 : -1 * speed
        end
      end
    end
  end
end
