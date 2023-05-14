# frozen_string_literal: true

require "gosu"

module BombermanRuby
  class Window < Gosu::Window
    WIDTH = 240
    HEIGHT = 160
    SPRITE_SIZE = 16

    def initialize
      super(WIDTH, HEIGHT)
      @map = Map.new
    end

    def update
      @map.update
    end

    def draw
      @map.draw
    end
  end
end
