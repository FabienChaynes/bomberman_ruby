# frozen_string_literal: true

module BombermanRuby
  module Entities
    class Player < Base
      include Concerns::Player::Sprite
      include Concerns::Player::Bonus
      include Concerns::Player::Movement
      include Concerns::Player::BombActions
      include Concerns::Player::Collisions
      include Concerns::Player::Sound

      STUNNED_DURATION_MS = 1_000
      DEATH_DURATION_MS = SPRITE_REFRESH_RATE * DEATH_SPRITE_COUNT

      SERIALIZABLE_VARS = (Base::SERIALIZABLE_VARS + %i[id direction moving skull_effect sound winning dead_at
                                                        current_death_sprite stunned_at]).freeze
      SERIALIZABLE_VARS_SYMBOLS = (Base::SERIALIZABLE_VARS_SYMBOLS + %i[direction sound]).freeze

      attr_accessor :skull_effect
      attr_writer :direction, :moving, :sound, :winning, :dead_at, :current_death_sprite, :stunned_at

      def initialize(args) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        @input = args.delete(:input)
        @id = args.delete(:id)
        @bomb_capacity = args.delete(:starting_bomb_capacity) || 1
        @bomb_radius = args.delete(:starting_bomb_radius) || 2
        @speed = args.delete(:starting_speed) || 1
        @kick = args.delete(:starting_kick) || false
        @punch = args.delete(:starting_punch) || false
        @line_bomb = args.delete(:starting_line_bomb) || false
        super(**args)
        @y = (args[:grid_y] * Window::SPRITE_SIZE) - (hitbox[:down] - Window::SPRITE_SIZE)
        @direction = :down
        @moving = @winning = @bomb_control_released = false
        @current_death_sprite = 0
      end

      def update
        reset_sound!
        set_death_sprite if dead?
        return if @winning || dead?

        move!
        check_collisions!
        cancel_skull_effect!
        cancel_stun!
        execute_actions!
      end

      def draw
        scale_x = @direction == :right && !dead? ? -1 : 1
        draw_x, draw_y = draw_coords
        current_sprite.draw(draw_x, draw_y, PLAYER_Z, scale_x, 1, sprite_color)
        play_sound
        # debug_hitbox
      end

      def bounced_on
        @stunned_at = Gosu.milliseconds
      end

      def hitbox
        {
          up: 14,
          down: 24,
          left: 2,
          right: 15,
        }
      end

      def dead?
        !!@dead_at
      end

      def deletable?
        @dead_at && Gosu.milliseconds > @dead_at + DEATH_DURATION_MS
      end

      private

      def draw_coords
        draw_x = @x
        draw_y = @y
        if dead?
          draw_x -= (DEATH_SPRITE_WIDTH - SPRITE_WIDTH) / 2
          draw_y -= (DEATH_SPRITE_HEIGHT - SPRITE_HEIGHT) / 2
        elsif @direction == :right
          draw_x += SPRITE_WIDTH
        end
        [draw_x, draw_y]
      end

      def cancel_stun!
        return unless @stunned_at && @stunned_at + STUNNED_DURATION_MS < Gosu.milliseconds

        @stunned_at = nil
      end

      def stunned?
        !!@stunned_at
      end
    end
  end
end
