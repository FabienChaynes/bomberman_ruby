# frozen_string_literal: true

module BombermanRuby
  module Entities
    class Fire < Base
      include Concerns::Burnable

      EXPLOSION_DURATION_MS = 500

      EXPLODING_SAMPLE = Gosu::Sample.new("#{ASSETS_PATH}/sound/bomb.wav").freeze
      SPRITES = Gosu::Image.load_tiles(
        "#{ASSETS_PATH}/images/flames.png",
        Window::SPRITE_SIZE,
        Window::SPRITE_SIZE,
        tileable: true
      ).freeze
      CENTER_SPRITES = [SPRITES[8], SPRITES[9], SPRITES[10], SPRITES[11], SPRITES[10], SPRITES[9], SPRITES[8]].freeze
      MIDDLE_SPRITES = [SPRITES[4], SPRITES[5], SPRITES[6], SPRITES[7], SPRITES[6], SPRITES[5], SPRITES[4]].freeze
      EXTREMITY_SPRITES = [SPRITES[0], SPRITES[1], SPRITES[2], SPRITES[3], SPRITES[2], SPRITES[1], SPRITES[0]].freeze
      FIRE_SPRITES_MAPPING = {
        center: CENTER_SPRITES,
        middle_left: MIDDLE_SPRITES,
        middle_right: MIDDLE_SPRITES,
        middle_top: MIDDLE_SPRITES,
        middle_bottom: MIDDLE_SPRITES,
        left: EXTREMITY_SPRITES,
        right: EXTREMITY_SPRITES,
        top: EXTREMITY_SPRITES,
        bottom: EXTREMITY_SPRITES,
      }.freeze

      SERIALIZABLE_VARS = (Base::SERIALIZABLE_VARS + %i[burning_index]).freeze
      SERIALIZABLE_VARS_SYMBOLS = (Base::SERIALIZABLE_VARS_SYMBOLS + %i[type sound]).freeze

      attr_writer :type, :sound

      def initialize(args)
        @type = args.delete(:type)
        super(**args)
        @sound = :initial if @type == :center
        burn!
      end

      def update
        @sound = @sound == :initial ? :exploding : nil
        burn_colliding_bombs
        super
      end

      def draw
        sprite.draw_rot(@x, @y, Bomb::BOMB_Z, draw_angle, draw_center_x, draw_center_y)
        play_sound
      end

      private

      def burning_sprites
        CENTER_SPRITES
      end

      def draw_angle
        case @type
        when :middle_right, :right
          90
        when :middle_left, :left
          -90
        when :middle_bottom, :bottom
          180
        else
          0
        end
      end

      def draw_center_x
        case @type
        when :middle_left, :left, :middle_bottom, :bottom
          1
        else
          0
        end
      end

      def draw_center_y
        case @type
        when :middle_right, :right, :middle_bottom, :bottom
          1
        else
          0
        end
      end

      def burn_colliding_bombs
        colliding_entities
          .select { |e| e.is_a?(Bomb) }
          .each(&:burn!)
      end

      def sprite
        FIRE_SPRITES_MAPPING[@type][@burning_index]
      end

      def play_sound
        case @sound
        when :exploding
          EXPLODING_SAMPLE.play
        end
      end
    end
  end
end
