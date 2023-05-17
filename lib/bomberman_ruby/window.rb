# frozen_string_literal: true

module BombermanRuby
  class Window < Gosu::Window
    WIDTH = 240
    HEIGHT = 160
    SPRITE_SIZE = 16
    SCALING_FACTOR = 3

    def initialize
      super((WIDTH * SCALING_FACTOR).round, (HEIGHT * SCALING_FACTOR).round)
      @game = Game.new
    end

    def update
      @game.update
    end

    def draw
      Gosu.scale(SCALING_FACTOR, SCALING_FACTOR) do
        @game.draw
      end
    end
  end
end
