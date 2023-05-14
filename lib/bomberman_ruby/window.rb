# frozen_string_literal: true

require "gosu"

module BombermanRuby
  class Window < Gosu::Window
    WIDTH = 240
    HEIGHT = 160
    SPRITE_SIZE = 16
    SCALING_FACTOR = 3

    def initialize
      super(WIDTH * SCALING_FACTOR, HEIGHT * SCALING_FACTOR)
      @map = Map.new
    end

    def update
      @map.update
    end

    def draw
      Gosu.scale(SCALING_FACTOR, SCALING_FACTOR) do
        @map.draw
      end
    end
  end
end
