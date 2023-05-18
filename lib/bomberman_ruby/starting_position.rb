# frozen_string_literal: true

module BombermanRuby
  class StartingPosition
    attr_reader :grid_x, :grid_y

    def initialize(grid_x:, grid_y:)
      @grid_x = grid_x
      @grid_y = grid_y
    end
  end
end
