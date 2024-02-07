# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Pipes
      class Middle < Base
        def draw
          MIDDLE_PIPE_SPRITE.draw(@x - Window::SPRITE_SIZE, @y - Window::SPRITE_SIZE, PIPE_Z)
        end
      end
    end
  end
end
