# frozen_string_literal: true

module BombermanRuby
  class Entity
    attr_accessor :x, :y

    def initialize(grid_x:, grid_y:, map:)
      @x = grid_x * Window::SPRITE_SIZE
      @y = grid_y * Window::SPRITE_SIZE
      @map = map
    end

    def draw; end

    def hitbox
      {
        up: 0,
        down: Window::SPRITE_SIZE,
        left: 0,
        right: Window::SPRITE_SIZE,
      }
    end

    private

    def collide?(other_entity, target_x, target_y) # rubocop:disable Metrics/AbcSize
      return true if target_y + hitbox[:up] < Map::VERTICAL_MARGIN
      return false if target_x + hitbox[:right] <= other_entity.x + other_entity.hitbox[:left]
      return false if target_x + hitbox[:left] >= other_entity.x + other_entity.hitbox[:right]
      return false if target_y + hitbox[:down] <= other_entity.y + other_entity.hitbox[:up]
      return false if target_y + hitbox[:up] >= other_entity.y + other_entity.hitbox[:down]

      true
    end

    def debug_hitbox # rubocop:disable Metrics/AbcSize
      Gosu.draw_rect(
        @x + hitbox[:left],
        @y + hitbox[:up], hitbox[:right] - hitbox[:left],
        hitbox[:down] - hitbox[:up],
        Gosu::Color.new(0x77, 0xff, 0, 0),
        10_000
      )
    end
  end
end
