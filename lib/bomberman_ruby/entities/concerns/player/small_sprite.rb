# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Concerns
      module Player
        module SmallSprite
          ASSETS_PATH = "#{__dir__}/../../../../../assets".freeze

          SMALL_SPRITE_COUNT = 9
          SMALL_SPRITE_WIDTH = 13
          SMALL_SPRITE_HEIGHT = 16
          SMALL_SPRITES = Gosu::Image.load_tiles(
            "#{ASSETS_PATH}/images/small_player.png",
            SMALL_SPRITE_WIDTH,
            SMALL_SPRITE_HEIGHT
          ).freeze

          WALKING_DOWN_SMALL_SPRITE_INDEXES = [0, 1].freeze
          WALKING_LEFT_SMALL_SPRITE_INDEXES = [2, 3, 4].freeze
          WALKING_UP_SMALL_SPRITE_INDEXES = [5, 6].freeze
          WINNING_SMALL_SPRITE_INDEXES = [7, 8].freeze

          private

          def small_draw_coords(draw_x, draw_y)
            draw_x += (self.class::SPRITE_WIDTH - SMALL_SPRITE_WIDTH) / 2
            draw_y += (self.class::SPRITE_HEIGHT - SMALL_SPRITE_HEIGHT)
            [draw_x, draw_y]
          end

          def minimize?
            @map.entities.any? { |e| e.is_a?(Pipes::Base) && collide?(e) }
          end

          def fetch_small_player_sprite(sprite_indexes)
            sprite_indexes.map { |i| SMALL_SPRITES[(@id * SMALL_SPRITE_COUNT) + i] }
          end
        end
      end
    end
  end
end
