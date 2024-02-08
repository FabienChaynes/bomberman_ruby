# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Concerns
      module Player
        module Sprite
          include SmallSprite
          PLAYER_Z = 10
          SPRITE_COUNT = 12
          SPRITE_WIDTH = 17
          SPRITE_HEIGHT = 24
          SPRITES = Gosu::Image.load_tiles(
            "#{ASSETS_PATH}/images/player.png",
            SPRITE_WIDTH,
            SPRITE_HEIGHT
          ).freeze

          DEATH_SPRITE_WIDTH = 23
          DEATH_SPRITE_HEIGHT = 20
          DEATH_SPRITES = Gosu::Image.load_tiles(
            "#{ASSETS_PATH}/images/dead_player.png",
            DEATH_SPRITE_WIDTH,
            DEATH_SPRITE_HEIGHT
          ).freeze

          WALKING_DOWN_SPRITE_INDEXES = [0, 1, 0, 2].freeze
          WALKING_LEFT_SPRITE_INDEXES = [3, 4, 3, 5].freeze
          WALKING_UP_SPRITE_INDEXES = [6, 7, 6, 8].freeze
          WINNING_SPRITE_INDEXES = [0, 9].freeze
          DEATH_SPRITE_INDEXES = [0, 1, 2, 3].freeze
          STUNNED_SPRITE_INDEXES = [10, 11].freeze
          DEATH_SPRITE_COUNT = DEATH_SPRITE_INDEXES.count

          SKULL_EFFECT_COLORS = [
            Gosu::Color.new(0xff_ffffff), Gosu::Color.new(0xff_cccccc), Gosu::Color.new(0xff_999999),
            Gosu::Color.new(0xff_666666), Gosu::Color.new(0xff_333333), Gosu::Color.new(0xff_666666),
            Gosu::Color.new(0xff_999999), Gosu::Color.new(0xff_cccccc)
          ].freeze

          private

          def draw_coords(sprite)
            draw_x = @x
            draw_y = @y
            draw_x, draw_y = small_draw_coords(draw_x, draw_y) if minimize?
            if dead?
              draw_x -= (DEATH_SPRITE_WIDTH - SPRITE_WIDTH) / 2
              draw_y -= (DEATH_SPRITE_HEIGHT - SPRITE_HEIGHT) / 2
            elsif @direction == :right
              draw_x += sprite.width
            end
            [draw_x, draw_y]
          end

          def current_sprite
            return current_death_sprite if dead?
            return current_stunned_sprite if stunned?

            sprites = @winning ? winning_sprites : walking_sprites
            if @moving || @winning
              self.class.current_animated_sprite(sprites)
            else
              sprites.first
            end
          end

          def walking_sprites
            case @direction
            when :down
              walking_down_sprites
            when :up
              walking_up_sprites
            when :left, :right
              walking_left_sprites
            end
          end

          def fetch_player_sprite(sprite_indexes)
            sprite_indexes.map { |i| SPRITES[(@id * SPRITE_COUNT) + i] }
          end

          %i[walking_down walking_up walking_left winning].each do |sprites_name|
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              # def walking_down_sprites
              #   if minimize?
              #     @small_walking_down_sprites ||= fetch_small_player_sprite(WALKING_DOWN_SMALL_SPRITE_INDEXES)
              #   else
              #     @walking_down_sprites ||= fetch_player_sprite(WALKING_DOWN_SPRITE_INDEXES)
              #   end
              # end

              def #{sprites_name}_sprites
                if minimize?
                  @small_#{sprites_name}_sprites ||= fetch_small_player_sprite(#{sprites_name.upcase}_SMALL_SPRITE_INDEXES)
                else
                  @#{sprites_name}_sprites ||= fetch_player_sprite(#{sprites_name.upcase}_SPRITE_INDEXES)
                end
              end
            RUBY
          end

          def stunned_sprites
            @stunned_sprites ||= fetch_player_sprite(STUNNED_SPRITE_INDEXES)
          end

          def death_sprites
            @death_sprites ||= DEATH_SPRITE_INDEXES.map { |i| DEATH_SPRITES[(@id * DEATH_SPRITE_COUNT) + i] }
          end

          def current_death_sprite
            death_sprites[@current_death_sprite]
          end

          def current_stunned_sprite
            self.class.current_animated_sprite(stunned_sprites)
          end

          def sprite_color
            if @skull_effect
              self.class.current_animated_sprite(SKULL_EFFECT_COLORS)
            else
              Gosu::Color.new(0xff_ffffff)
            end
          end

          def set_death_sprite
            @current_death_sprite = ((Gosu.milliseconds - @dead_at) / self.class::SPRITE_REFRESH_RATE)
                                    .clamp(0, death_sprites.size - 1)
          end
        end
      end
    end
  end
end
