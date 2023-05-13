# frozen_string_literal: true

module BombermanRuby
  class SoftBlock
    BLOCK_Z = 1
    SOFT_BLOCK_SPRITES = Gosu::Image.load_tiles(
      "#{__dir__}/../../assets/images/soft_block.png",
      Window::SPRITE_SIZE,
      Window::SPRITE_SIZE
    ).freeze

    attr_accessor :x, :y

    def initialize(grid_x:, grid_y:, map:)
      @x = grid_x * Window::SPRITE_SIZE
      @y = grid_y * Window::SPRITE_SIZE + Map::VERTICAL_MARGIN
      @map = map
    end

    def draw
      SOFT_BLOCK_SPRITES[0].draw(@x, @y, BLOCK_Z)
    end
  end
end
