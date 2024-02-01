# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Concerns
      module Player
        module BombActions
          def bomb_radius
            @skull_effect == :wimp_syndrome ? 1 : @bomb_radius
          end

          private

          def bomb_control?
            @skull_effect == :diarrhea ? true : @input.bomb?
          end

          def action_control?
            @input.action?
          end

          def kick_bombs(colliding_entity_list)
            return unless @kick

            colliding_entity_list
              .select { |e| e.is_a?(Entities::Bomb) }
              .each { |b| b.direction = @direction }
          end

          def execute_actions!
            return if stunned?

            if bomb_control?
              drop_bomb!
            else
              @bomb_control_released = true
            end
            return unless action_control?

            stop_kicked_bombs!
            punch_bomb!
          end

          def punch_bomb!
            return unless @punch

            center_grid_coord_x, center_grid_coord_y = center_grid_coord.values_at(:x, :y)
            x_grid_target, y_grid_target = increment_position(center_grid_coord_x, center_grid_coord_y)
            @map.entities.each do |e|
              next unless e.is_a?(Entities::Bomb)
              next unless e.grid_collide?(x_grid_target, y_grid_target)

              e.punch!(@direction)
            end
          end

          def stop_kicked_bombs!
            bombs.each do |b|
              b.direction = nil
              b.move_to_center!
            end
          end

          def bomb_capacity
            case @skull_effect
            when :wimp_syndrome
              1
            else
              @bomb_capacity
            end
          end

          def bomb_capacity_reached?
            @skull_effect == :constipation ||
              @map.entities.count { |e| e.is_a?(Entities::Bomb) && e.player == self } >= bomb_capacity
          end

          def bombs
            @map.entities.select do |e|
              e.is_a?(Entities::Bomb) && e.player == self
            end
          end

          def add_bomb_to_map(bomb)
            @map.entities << bomb
          end

          def drop_nex_bomb_in_line!(grid_x, grid_y)
            new_bomb = Entities::Bomb.new(grid_x:, grid_y:, map: @map, player: self)
            colliding_entity_list = new_bomb.colliding_entities.reject { |e| e == self }
            if colliding_entity_list.any?
              return colliding_entity_list.all? { |e| e.is_a?(Entities::Bomb) && e.player == self }
            end

            add_bomb_to_map(new_bomb)
            @sound = :drop_bomb
            true
          end

          def drop_bomb_line!
            @bomb_control_released = false
            grid_x, grid_y = center_grid_coord.fetch_values(:x, :y)
            until bomb_capacity_reached?
              grid_x, grid_y = increment_position(grid_x, grid_y)
              break unless drop_nex_bomb_in_line!(grid_x, grid_y)
            end
          end

          def on_bomb?
            @map.entities.any? do |e|
              e.is_a?(Entities::Bomb) &&
                e.grid_collide?(center_grid_coord[:x], center_grid_coord[:y])
            end
          end

          def drop_bomb!
            return if bomb_capacity_reached?

            if on_bomb?
              drop_bomb_line! if @line_bomb && @bomb_control_released
              return
            end
            add_bomb_to_map(Entities::Bomb.new(grid_x: center_grid_coord[:x], grid_y: center_grid_coord[:y],
                                               map: @map, player: self))
            @bomb_control_released = false
            @sound = :drop_bomb
          end
        end
      end
    end
  end
end
