# frozen_string_literal: true

module BombermanRuby
  module Entities
    class Bomb < Base
      include Concerns::Blockable
      include Concerns::Burnable
      include Concerns::Bomb::Throwable
      include Concerns::Bomb::Explodeable
      include Concerns::Bomb::Kickable

      BOMB_DELAY_MS = 3000
      BOMB_HYPERACTIVITY_DELAY_MS = 1000
      BOMB_LETHARGY_DELAY_MS = 5000

      BOMB_Z = 5
      SPRITE_REFRESH_RATE = 300
      SPRITES = Gosu::Image.load_tiles(
        "#{ASSETS_PATH}/images/bomb.png",
        Window::SPRITE_SIZE,
        Window::SPRITE_SIZE,
        tileable: true
      ).freeze
      BOMB_SPRITES = SPRITES[0..2]

      attr_reader :player
      attr_writer :direction

      def initialize(args)
        @player = args.delete(:player)
        super(**args)
        @dropped_at = Gosu.milliseconds
      end

      def update
        move!
        return if Gosu.milliseconds < @dropped_at + bomb_delay

        explode!
      end

      def draw
        self.class.current_animated_sprite(BOMB_SPRITES).draw(@x, @y, BOMB_Z)
      end

      def burn!
        explode!
      end

      def colliding_entities(target_x = @x, target_y = @y)
        colliding_players = @map.players.select do |player|
          collide?(player, target_x, target_y)
        end
        colliding_entities_list = super

        colliding_players + colliding_entities_list
      end

      def punch!(direction)
        return if @direction
        return if @thrown_step

        @thrown_direction = direction
        @thrown_step = 0
        @starting_thrown_position = { x: @x, y: @y }
      end

      private

      def move!
        if @thrown_step
          thrown_move!
          return
        end
        kicked_move! if @direction
      end

      def bomb_delay
        case @player.skull_effect
        when :hyperactivity
          BOMB_HYPERACTIVITY_DELAY_MS
        when :lethargy
          BOMB_LETHARGY_DELAY_MS
        else
          BOMB_DELAY_MS
        end
      end
    end
  end
end
