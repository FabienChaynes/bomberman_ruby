# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Pipes
      class Right < Base
        def draw
          VERTICAL_PIPES_SPRITES[1].draw(@x - Window::SPRITE_SIZE, @y - Window::SPRITE_SIZE, PIPE_Z)
        end
      end
    end
  end
end
