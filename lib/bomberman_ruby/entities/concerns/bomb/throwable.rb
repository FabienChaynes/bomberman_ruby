# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Concerns
      module Bomb
        module Throwable
          HORIZONTAL_PUNCH_MOTION = Array.new(16) do |i|
            x = (i + 1) * 3
            y = if i < 6
                  (i + 1) * -2
                elsif i <= 9
                  -2 * 6
                else
                  (-2 * 6) + (2 * (i - 9))
                end

            { x:, y: }
          end.freeze
          VERTICAL_PUNCH_MOTION = Array.new(16) do |i|
            y = (i + 1) * 3

            { x: 0, y: }
          end.freeze
          HORIZONTAL_BOUNCE_MOTION = [
            { x: 4, y: -8 },
            { x: 8, y: -12 },
            { x: 12, y: -8 },
            { x: 16, y: 0 },
          ].freeze
          VERTICAL_BOUNCE_MOTION = [
            { x: 0, y: 12 },
            { x: 0, y: 10 },
            { x: 0, y: 8 },
            { x: 0, y: 16 },
          ].freeze

          private

          def current_motion_step
            case @thrown_direction
            when :left, :right
              @bounce_step ? HORIZONTAL_BOUNCE_MOTION[@bounce_step] : HORIZONTAL_PUNCH_MOTION[@thrown_step]
            when :up, :down
              @bounce_step ? VERTICAL_BOUNCE_MOTION[@bounce_step] : VERTICAL_PUNCH_MOTION[@thrown_step]
            end
          end

          def wrap_around_map!
            if @x >= Window::WIDTH
              @x = 0
            elsif @x.negative?
              @x = Window::WIDTH - Window::SPRITE_SIZE
            elsif @y > Window::HEIGHT
              @y = 0
            elsif @y.negative?
              @y = Window::HEIGHT
            end
          end

          def end_thrown
            if (colliding_entity_list = colliding_entities).any?
              colliding_entity_list.each(&:bounced_on)
              @bounce_step = 0
              @starting_thrown_position = { x: @x, y: @y }
            else
              @thrown_direction = @thrown_step = @starting_thrown_position = @bounce_step = nil
            end
          end

          def thrown_move_step
            x_delta, y_delta = current_motion_step.values_at(:x, :y)
            x_delta *= -1 if @thrown_direction == :left
            y_delta *= -1 if @thrown_direction == :up
            @x = @starting_thrown_position[:x] + x_delta
            @y = @starting_thrown_position[:y] + y_delta
            @thrown_step += 1
            @bounce_step += 1 if @bounce_step
          end

          def thrown_move!
            wrap_around_map!
            if current_motion_step
              thrown_move_step
            else
              end_thrown
            end
          end
        end
      end
    end
  end
end
