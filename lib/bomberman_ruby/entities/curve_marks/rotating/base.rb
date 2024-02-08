# frozen_string_literal: true

module BombermanRuby
  module Entities
    module CurveMarks
      module Rotating
        class Base < CurveMarks::Base
          SPRITE = Gosu::Image.new(
            "#{ASSETS_PATH}/images/rotating_curve_mark.png"
          ).freeze
          ROTATING_CURVE_MARK_Z = 1
          CHANGE_DELAY = 2000

          ANGLE = {
            down: 0,
            left: 90,
            up: 180,
            right: -90,
          }.freeze

          SERIALIZABLE_VARS_SYMBOLS = (Base::SERIALIZABLE_VARS_SYMBOLS + %i[direction]).freeze

          attr_writer :direction

          def initialize(**_args)
            super
            @direction = self.class::DIRECTIONS.first
            @start = Gosu.milliseconds
          end

          def update
            direction_index = ((Gosu.milliseconds - @start) / CHANGE_DELAY) % self.class::DIRECTIONS.size
            @direction = self.class::DIRECTIONS[direction_index]
          end

          def draw
            SPRITE.draw_rot(@x, @y + 1, ROTATING_CURVE_MARK_Z, angle, center_x, center_y)
          end

          private

          def angle
            ANGLE[@direction]
          end

          def center_x
            case @direction
            when :down, :left
              0
            when :up, :right
              1
            end
          end

          def center_y
            case @direction
            when :down, :right
              0
            when :left, :up
              1
            end
          end
        end
      end
    end
  end
end
