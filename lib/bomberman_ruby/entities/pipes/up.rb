# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Pipes
      class Up < Base
        def draw
          HORIZONTAL_PIPES_SPRITES[0].draw(@x - Window::SPRITE_SIZE, @y, PIPE_Z)
        end
      end
    end
  end
end
