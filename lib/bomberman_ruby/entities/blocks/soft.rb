# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Blocks
      class Soft < Base
        include Concerns::Burnable

        BLOCK_Z = 5
        SOFT_BLOCK_SPRITES = Gosu::Image.load_tiles(
          "#{ASSETS_PATH}/images/soft_blocks.png",
          Window::SPRITE_SIZE,
          Window::SPRITE_SIZE
        ).freeze
        BURNING_SOFT_BLOCK_SPRITES = Gosu::Image.load_tiles(
          "#{ASSETS_PATH}/images/burning_soft_blocks.png",
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
          3 => [SOFT_BLOCK_SPRITES[6]],
        }.freeze
        MAP_BURNING_SOFT_BLOCK_SPRITES = {
          0 => [BURNING_SOFT_BLOCK_SPRITES[0], BURNING_SOFT_BLOCK_SPRITES[1], BURNING_SOFT_BLOCK_SPRITES[2],
                BURNING_SOFT_BLOCK_SPRITES[3], BURNING_SOFT_BLOCK_SPRITES[4]],
          1 => [BURNING_SOFT_BLOCK_SPRITES[0]],
          2 => [BURNING_SOFT_BLOCK_SPRITES[5], BURNING_SOFT_BLOCK_SPRITES[6], BURNING_SOFT_BLOCK_SPRITES[7],
                BURNING_SOFT_BLOCK_SPRITES[8], BURNING_SOFT_BLOCK_SPRITES[9]],
          3 => [BURNING_SOFT_BLOCK_SPRITES[10], BURNING_SOFT_BLOCK_SPRITES[11], BURNING_SOFT_BLOCK_SPRITES[12],
                BURNING_SOFT_BLOCK_SPRITES[13], BURNING_SOFT_BLOCK_SPRITES[14]],
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

        SERIALIZABLE_VARS = (Base::SERIALIZABLE_VARS + %i[burning_index]).freeze

        attr_writer :item

        def initialize(args)
          super(**args)
          @item = nil
        end

        def draw
          current_sprite.draw(@x, @y, BLOCK_Z)
        end

        private

        def final_burn!
          return unless ITEM_MAPPING.key?(@item)

          @map.entities << ITEM_MAPPING[@item].new(grid_x: grid_coord[:x], grid_y: grid_coord[:y], map: @map)
        end

        def burning_sprites
          MAP_BURNING_SOFT_BLOCK_SPRITES[@map.index]
        end

        def current_sprite
          if @burning_index
            burning_sprites[@burning_index]
          else
            self.class.current_animated_sprite(MAP_BLOCK_SPRITES[@map.index])
          end
        end
      end
    end
  end
end
