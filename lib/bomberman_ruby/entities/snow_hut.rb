# frozen_string_literal: true

module BombermanRuby
  module Entities
    class SnowHut < Base
      FRAME_SPRITE = Gosu::Image.new("#{ASSETS_PATH}/images/snow_hut_frame.png").freeze
      FRAME_SPRITE_WIDTH = FRAME_SPRITE.width
      FRAME_SPRITE_HEIGHT = FRAME_SPRITE.height
      CEILING_SPRITE = Gosu::Image.new("#{ASSETS_PATH}/images/snow_hut_ceiling.png", tileable: true).freeze
      CEILING_SPRITE_SIZE = CEILING_SPRITE.width
      SNOW_HUT_Z = 20
      MAX_BLOW_UP_HEIGHT = Window::SPRITE_SIZE * 5
      SERIALIZABLE_VARS = (Base::SERIALIZABLE_VARS + %i[ceiling_y]).freeze

      attr_accessor :ceiling_y

      def initialize(args)
        super(**args)
        @ceiling_y = @y
      end

      def update
        @ceiling_y = @y
        return unless @blow_up_at

        distance = (Gosu.milliseconds - @blow_up_at) / 4
        @ceiling_y -= if distance < MAX_BLOW_UP_HEIGHT
                        distance
                      else
                        MAX_BLOW_UP_HEIGHT - (distance - MAX_BLOW_UP_HEIGHT)
                      end
        @blow_up_at = nil if @ceiling_y >= @y
      end

      def draw
        FRAME_SPRITE.draw(@x - (FRAME_SPRITE_WIDTH / 2) + (Window::SPRITE_SIZE / 2),
                          @y - (FRAME_SPRITE_HEIGHT / 2) + (Window::SPRITE_SIZE / 2) - 2, SNOW_HUT_Z)
        CEILING_SPRITE.draw(@x - (CEILING_SPRITE_SIZE / 2) + (Window::SPRITE_SIZE / 2),
                            @ceiling_y - (CEILING_SPRITE_SIZE / 2), SNOW_HUT_Z)
      end

      def blow_up_ceiling
        @blow_up_at = Gosu.milliseconds
      end
    end
  end
end
