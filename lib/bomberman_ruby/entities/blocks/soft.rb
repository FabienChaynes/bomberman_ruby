# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Blocks
      class Soft < Base
        include Concerns::Burnable

        BLOCK_Z = 3
        SOFT_BLOCK_SPRITES = Gosu::Image.load_tiles(
          "#{ASSETS_PATH}/images/soft_blocks.png",
          Window::SPRITE_SIZE,
          Window::SPRITE_SIZE
        ).freeze
        MAP_BLOCK_SPRITES = {
          0 => [SOFT_BLOCK_SPRITES[0]],
          1 => [SOFT_BLOCK_SPRITES[0]],
          2 => [
            SOFT_BLOCK_SPRITES[1], SOFT_BLOCK_SPRITES[2], SOFT_BLOCK_SPRITES[3], SOFT_BLOCK_SPRITES[2],
            SOFT_BLOCK_SPRITES[1], SOFT_BLOCK_SPRITES[4], SOFT_BLOCK_SPRITES[5], SOFT_BLOCK_SPRITES[4]
          ],
        }.freeze
        ITEM_MAPPING = {
          bomb_up: Items::BombUp,
          fire_up: Items::FireUp,
          speed_up: Items::SpeedUp,
          skull: Items::Skull,
          kick: Items::Kick,
          punch: Items::Punch,
          line_bomb: Items::LineBomb,
        }.freeze

        attr_writer :item

        def initialize(args)
          super(**args)
          @item = nil
        end

        def draw
          current_sprite.draw(@x, @y, BLOCK_Z)
        end

        def burn!
          super
          return unless ITEM_MAPPING.key?(@item)

          @map.entities << ITEM_MAPPING[@item].new(grid_x: grid_coord[:x], grid_y: grid_coord[:y], map: @map)
        end

        private

        def current_sprite
          self.class.current_animated_sprite(MAP_BLOCK_SPRITES[@map.index])
        end
      end
    end
  end
end
