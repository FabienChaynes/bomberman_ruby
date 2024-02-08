# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Concerns
      module Bomb
        module Kickable
          MOVING_SPEED = 2

          private

          def kicked_move!
            move_vertical!
            move_horizontal!
          end

          def move_vertical!
            return unless %i[up down].include?(@direction)

            y_delta = 0
            y_delta -= MOVING_SPEED if @direction == :up
            y_delta += MOVING_SPEED if @direction == :down
            if colliding_entities(@x, @y + y_delta).any?
              @direction = nil
              return
            end
            @y += y_delta
            enable_curve_mark!
          end

          def move_horizontal!
            return unless %i[left right].include?(@direction)

            x_delta = 0
            x_delta -= MOVING_SPEED if @direction == :left
            x_delta += MOVING_SPEED if @direction == :right
            if colliding_entities(@x + x_delta, @y).any?
              @direction = nil
              return
            end
            @x += x_delta
            enable_curve_mark!
          end

          def enable_curve_mark!
            @map.entities.find do |entity|
              next unless entity.is_a?(CurveMarks::Base)

              entity.x == @x && entity.y == @y
            end&.enable(self)
          end
        end
      end
    end
  end
end
