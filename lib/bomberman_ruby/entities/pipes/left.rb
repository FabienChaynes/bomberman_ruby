# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Pipes
      class Left < Base
        def draw
          VERTICAL_PIPES_SPRITES[0].draw(@x, @y - Window::SPRITE_SIZE, PIPE_Z)
        end
      end
    end
  end
end
