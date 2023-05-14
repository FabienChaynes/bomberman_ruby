# frozen_string_literal: true

module BombermanRuby
  class SoftBlock < Entity
    BLOCK_Z = 1
    SOFT_BLOCK_SPRITES = Gosu::Image.load_tiles(
      "#{__dir__}/../../assets/images/soft_block.png",
      Window::SPRITE_SIZE,
      Window::SPRITE_SIZE
    ).freeze

    def initialize(args)
      super(**args)
      @y += Map::VERTICAL_MARGIN
    end

    def draw
      SOFT_BLOCK_SPRITES[0].draw(@x, @y, BLOCK_Z)
    end
  end
end
