# frozen_string_literal: true

module BombermanRuby
  class Window < Gosu::Window
    WIDTH = 240
    HEIGHT = 160
    SPRITE_SIZE = 16
    INITIAL_SCALING_FACTOR = 3

    def initialize(options)
      super((WIDTH * INITIAL_SCALING_FACTOR).round, (HEIGHT * INITIAL_SCALING_FACTOR).round)
      @game = options[:server_host] ? Games::Client.new(options) : Games::Host.new(options)
    end

    def update
      self.resizable = true
      @game.update
    end

    def draw
      Gosu.scale(scaling_factor, scaling_factor) do
        @game.draw
      end
    end

    def needs_cursor?
      false
    end

    private

    def scaling_factor
      width_scaling_factor = width / WIDTH.to_f
      height_scaling_factor = height / HEIGHT.to_f
      [width_scaling_factor, height_scaling_factor].min
    end
  end
end
