# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Conveyors
      class Base < Entities::Base
        CONVEYOR_SPRITES = Gosu::Image.load_tiles(
          "#{ASSETS_PATH}/images/conveyor.png",
          Window::SPRITE_SIZE,
          Window::SPRITE_SIZE
        ).freeze
        CONVEYOR_Z = 2
        SERIALIZABLE_VARS = (Base::SERIALIZABLE_VARS + %i[reverse fast]).freeze

        attr_accessor :reverse, :fast

        def initialize(**_args)
          super
          @reverse = false
          @fast = false
        end

        def draw
          current_sprite.draw(@x, @y, CONVEYOR_Z)
        end

        def x_delta
          0
        end

        def y_delta
          0
        end

        def speed
          fast ? 0.8 : 0.5
        end

        def priority
          1
        end

        private

        def current_sprite
          sprites = @reverse ? self.class::SPRITES.reverse : self.class::SPRITES
          refresh_rate = @fast ? SPRITE_REFRESH_RATE / 2 : SPRITE_REFRESH_RATE
          self.class.current_animated_sprite(sprites, refresh_rate)
        end
      end
    end
  end
end
