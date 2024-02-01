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
          end
        end
      end
    end
  end
end
