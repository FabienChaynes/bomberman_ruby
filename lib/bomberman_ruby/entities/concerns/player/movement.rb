# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Concerns
      module Player
        module Movement
          include Concerns::ConveyorMovable

          private

          def speed
            case @skull_effect
            when :lead_feet
              0.5
            when :lightining_feet
              3
            else
              @speed
            end
          end

          def move!
            @moving = false
            conveyor_move!
            return if stunned?

            move_vertical!
            move_horizontal!
          end

          def move_vertical!
            return if (y_delta = moving_delta(up_control?, down_control?)).zero?

            @direction = y_delta.positive? ? :down : :up
            if (colliding_entity_list = colliding_entities(@x, @y + y_delta)).any?
              kick_bombs(colliding_entity_list)
            else
              @y += y_delta
              @moving = true
            end
          end

          def move_horizontal!
            return if (x_delta = moving_delta(left_control?, right_control?)).zero?

            @direction = x_delta.positive? ? :right : :left
            if (colliding_entity_list = colliding_entities(@x + x_delta, @y)).any?
              kick_bombs(colliding_entity_list)
            else
              @x += x_delta
              @moving = true
            end
          end

          def moving_delta(negative_control, positive_control)
            delta = 0
            delta -= speed if negative_control
            delta += speed if positive_control
            delta
          end

          def up_control?
            case @skull_effect
            when :reversal_syndrome
              @input.down?
            else
              @input.up?
            end
          end

          def down_control?
            case @skull_effect
            when :reversal_syndrome
              @input.up?
            else
              @input.down?
            end
          end

          def left_control?
            case @skull_effect
            when :reversal_syndrome
              @input.right?
            else
              @input.left?
            end
          end

          def right_control?
            case @skull_effect
            when :reversal_syndrome
              @input.left?
            else
              @input.right?
            end
          end
        end
      end
    end
  end
end
