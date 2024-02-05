# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Conveyors
      class BottomRight < Base
        SPRITES = [CONVEYOR_SPRITES[0], CONVEYOR_SPRITES[2], CONVEYOR_SPRITES[4]].freeze

        def draw
          current_sprite.draw_rot(@x, @y, CONVEYOR_Z, 180, 1, 1)
        end

        def x_delta
          @reverse ? 0 : -1 * speed
        end

        def y_delta
          @reverse ? -1 * speed : 0
        end
      end
    end
  end
end
