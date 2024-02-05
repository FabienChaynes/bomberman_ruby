# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Conveyors
      class TopLeft < Base
        SPRITES = [CONVEYOR_SPRITES[0], CONVEYOR_SPRITES[2], CONVEYOR_SPRITES[4]].freeze

        def x_delta
          @reverse ? 0 : speed
        end

        def y_delta
          @reverse ? speed : 0
        end
      end
    end
  end
end
