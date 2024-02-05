# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Concerns
      module ConveyorMovable
        private

        def conveyor_move!
          return unless (conveyor = current_colliding_conveyor)

          on_conveyor(conveyor)
          return if colliding_entities(@x + conveyor.x_delta, @y + conveyor.y_delta).any?

          @x += conveyor.x_delta
          @y += conveyor.y_delta
        end

        def on_conveyor(_conveyor); end

        def current_colliding_conveyor
          @map.entities.select do |entity|
            entity.is_a?(Conveyors::Base) && collide?(entity)
          end.max_by(&:priority)
        end
      end
    end
  end
end
