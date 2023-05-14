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
    ITEM_MAPPING = {
      bomb_up: BombUp,
      fire_up: FireUp,
      speed_up: SpeedUp,
      skull: Skull,
    }.freeze

    attr_writer :item

    def initialize(args)
      super(**args)
      @item = nil
    end

    def draw
      SOFT_BLOCK_SPRITES[0].draw(@x, @y, BLOCK_Z)
    end

    def burn!
      super
      return unless ITEM_MAPPING.key?(@item)

      @map.entities << ITEM_MAPPING[@item].new(grid_x: grid_pos[:x], grid_y: grid_pos[:y], map: @map)
    end
  end
end
