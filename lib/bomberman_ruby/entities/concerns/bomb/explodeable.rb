# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Concerns
      module Bomb
        module Explodeable
          FIRE_DIRECTION = {
            left: { x: -1, y: 0 },
            right: { x: 1, y: 0 },
            top: { x: 0, y: -1 },
            bottom: { x: 0, y: 1 },
          }.freeze

          private

          def explode!
            return if @thrown_direction

            move_to_center!
            @map.entities.delete(self)
            @map.entities << Fire.new(grid_x: grid_coord[:x], grid_y: grid_coord[:y], map: @map, type: :middle)
            burn_entities!(grid_coord[:x], grid_coord[:y])
            add_fires!
          end

          def add_fires!
            add_radius_fire!(:left)
            add_radius_fire!(:right)
            add_radius_fire!(:top)
            add_radius_fire!(:bottom)
          end

          def bomb_radius
            colliding_snow_hut = @map.entities.find do |e|
              e.is_a?(Entities::SnowHut) && e.grid_collide?(*grid_coord.fetch_values(:x, :y))
            end
            if colliding_snow_hut
              colliding_snow_hut.blow_up_ceiling
              Entities::Player::MAX_BOMB_RADIUS
            else
              @player.bomb_radius
            end
          end

          def add_radius_fire!(direction)
            fire_direction = FIRE_DIRECTION[direction]
            1.upto(bomb_radius) do |current_radius|
              x_delta = current_radius * fire_direction[:x]
              y_delta = current_radius * fire_direction[:y]
              type = current_radius == bomb_radius ? direction : :"middle_#{direction}"
              break unless add_fire!(grid_coord[:x] + x_delta, grid_coord[:y] + y_delta, type)
            end
          end

          def add_fire!(grid_coord_x, grid_coord_y, type)
            blocked = @map.entities.any? do |e|
              e.blocking? && e.grid_collide?(grid_coord_x, grid_coord_y)
            end
            burn_entities!(grid_coord_x, grid_coord_y)
            return false if blocked

            if @map.entities.none? { |e| e.is_a?(Fire) && e.grid_collide?(grid_coord_x, grid_coord_y) }
              @map.entities << Fire.new(grid_x: grid_coord_x, grid_y: grid_coord_y, map: @map, type:)
            end
            true
          end

          def burn_entities!(grid_coord_x, grid_coord_y)
            @map.entities.select do |e|
              e.is_a?(Concerns::Burnable) && e.grid_collide?(grid_coord_x, grid_coord_y)
            end.each(&:burn!)
          end
        end
      end
    end
  end
end
