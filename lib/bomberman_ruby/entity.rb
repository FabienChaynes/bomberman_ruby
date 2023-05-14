# frozen_string_literal: true

module BombermanRuby
  class Entity
    attr_accessor :x, :y

    def initialize(grid_x:, grid_y:, map:)
      @x = grid_x * Window::SPRITE_SIZE
      @y = grid_y * Window::SPRITE_SIZE
      @map = map
    end
  end
end
