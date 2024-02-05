# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Conveyors
      class Left < Base
        SPRITES = [CONVEYOR_SPRITES[5], CONVEYOR_SPRITES[3], CONVEYOR_SPRITES[1]].freeze

        def x_delta
          @reverse ? speed : speed * -1
        end

        def priority
          2
        end
      end
    end
  end
end
