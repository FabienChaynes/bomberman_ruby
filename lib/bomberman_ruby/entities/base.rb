# frozen_string_literal: true

module BombermanRuby
  module Entities
    class Base
      include Concerns::Debuggable
      include Concerns::Serializable

      ASSETS_PATH = "#{__dir__}/../../../assets".freeze

      SPRITE_REFRESH_RATE = 200

      attr_accessor :x, :y

      class << self
        def coord_to_grid_coord(x, y)
          {
            x: x.to_i / Window::SPRITE_SIZE,
            y: y.to_i / Window::SPRITE_SIZE,
          }
        end

        def grid_coord_to_coord(x, y)
          {
            x: x.to_i * Window::SPRITE_SIZE,
            y: y.to_i * Window::SPRITE_SIZE,
          }
        end

        def current_animated_sprite(sprites, refresh_rate = self::SPRITE_REFRESH_RATE)
          sprites[(Gosu.milliseconds / refresh_rate) % sprites.size]
        end
      end

      def initialize(grid_x:, grid_y:, map:)
        @x = grid_x * Window::SPRITE_SIZE
        @y = grid_y * Window::SPRITE_SIZE
        @map = map
      end

      def update; end

      def draw; end

      def bounced_on; end

      def hitbox
        {
          up: 0,
          down: Window::SPRITE_SIZE,
          left: 0,
          right: Window::SPRITE_SIZE,
        }
      end

      def grid_coord
        self.class.coord_to_grid_coord(@x, @y)
      end

      def move_to_center!
        coords = self.class.grid_coord_to_coord(*center_grid_coord.fetch_values(:x, :y))
        @x = coords[:x]
        @y = coords[:y]
      end

      def x_hitbox_range(x: @x)
        (x + hitbox[:left])...(x + hitbox[:right])
      end

      def y_hitbox_range(y: @y)
        (y + hitbox[:up])...(y + hitbox[:down])
      end

      def grid_collide?(target_grid_x, target_grid_y)
        grid_coord[:x] == target_grid_x && grid_coord[:y] == target_grid_y
      end

      def blocking?
        false
      end

      private

      def collide?(other_entity, target_x = @x, target_y = @y)
        x_hitbox_range(x: target_x).overlap?(other_entity.x_hitbox_range) &&
          y_hitbox_range(y: target_y).overlap?(other_entity.y_hitbox_range)
      end

      def colliding_entities(target_x = @x, target_y = @y)
        @map.entities.select do |entity|
          next unless entity.blocking?
          next if entity == self

          collide?(entity, target_x, target_y)
        end
      end

      def center
        {
          x: ((@x + hitbox[:left]) + (@x + hitbox[:right])) / 2.0,
          y: ((@y + hitbox[:up]) + (@y + hitbox[:down])) / 2.0,
        }
      end

      def center_grid_coord
        self.class.coord_to_grid_coord(center[:x], center[:y])
      end

      def increment_position(x, y)
        y -= 1 if @direction == :up
        y += 1 if @direction == :down
        x -= 1 if @direction == :left
        x += 1 if @direction == :right
        [x, y]
      end
    end
  end
end
