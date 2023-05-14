# frozen_string_literal: true

module BombermanRuby
  class SoftBlock < Block
    include Burnable

    BLOCK_Z = 1
    SOFT_BLOCK_SPRITES = Gosu::Image.load_tiles(
      "#{__dir__}/../../assets/images/soft_block.png",
      Window::SPRITE_SIZE,
      Window::SPRITE_SIZE
    ).freeze

    def draw
      SOFT_BLOCK_SPRITES[0].draw(@x, @y, BLOCK_Z)
    end
  end
end
