# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Blocks
      class Soft < Base
        include Concerns::Burnable

        BLOCK_Z = 1
        SOFT_BLOCK_SPRITES = Gosu::Image.load_tiles(
          "#{ASSETS_PATH}/images/soft_block.png",
          Window::SPRITE_SIZE,
          Window::SPRITE_SIZE
        ).freeze
        ITEM_MAPPING = {
          bomb_up: Items::BombUp,
          fire_up: Items::FireUp,
          speed_up: Items::SpeedUp,
          skull: Items::Skull,
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

          @map.entities << ITEM_MAPPING[@item].new(grid_x: grid_coord[:x], grid_y: grid_coord[:y], map: @map)
        end
      end
    end
  end
end
