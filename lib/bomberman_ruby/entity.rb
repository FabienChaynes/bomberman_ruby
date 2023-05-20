# frozen_string_literal: true

module BombermanRuby
  class Entity
    SPRITE_REFRESH_RATE = 200

    attr_accessor :x, :y

    def self.coord_to_grid_coord(x, y)
      {
        x: x.to_i / Window::SPRITE_SIZE,
        y: y.to_i / Window::SPRITE_SIZE,
      }
    end

    def initialize(grid_x:, grid_y:, map:)
      @x = grid_x * Window::SPRITE_SIZE
      @y = grid_y * Window::SPRITE_SIZE
      @map = map
    end

    def update; end

    def draw; end

    def hitbox
      {
        up: 0,
        down: Window::SPRITE_SIZE,
        left: 0,
        right: Window::SPRITE_SIZE,
      }
    end

    def grid_pos
      self.class.coord_to_grid_coord(@x, @y)
    end

    def serialize
      {
        class: self.class.to_s,
        x: @x,
        y: @y,
      }
    end

    def self.deserialize(map, data)
      entity = new(grid_x: 0, grid_y: 0, map:)
      entity.x = data["x"]
      entity.y = data["y"]
      entity
    end

    private

    def grid_collide?(other_entity, target_grid_x, target_grid_y)
      other_entity.grid_pos[:x] == target_grid_x && other_entity.grid_pos[:y] == target_grid_y
    end

    def collide?(other_entity, target_x, target_y) # rubocop:disable Metrics/AbcSize
      return false if target_x + hitbox[:right] <= other_entity.x + other_entity.hitbox[:left]
      return false if target_x + hitbox[:left] >= other_entity.x + other_entity.hitbox[:right]
      return false if target_y + hitbox[:down] <= other_entity.y + other_entity.hitbox[:up]
      return false if target_y + hitbox[:up] >= other_entity.y + other_entity.hitbox[:down]

      true
    end

    def center
      {
        x: ((@x + hitbox[:left]) + (@x + hitbox[:right])) / 2.0,
        y: ((@y + hitbox[:up]) + (@y + hitbox[:down])) / 2.0,
      }
    end

    def center_grid_coord
      Entity.coord_to_grid_coord(center[:x], center[:y])
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
