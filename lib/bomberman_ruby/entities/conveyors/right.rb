# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Conveyors
      class Right < Base
        SPRITES = [CONVEYOR_SPRITES[1], CONVEYOR_SPRITES[3], CONVEYOR_SPRITES[5]].freeze

        def x_delta
          @reverse ? speed * -1 : speed
        end

        def priority
          2
        end
      end
    end
  end
end
