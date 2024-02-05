# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Buttons
      class Base < Entities::Base
        ASSETS_PATH = "#{__dir__}/../../../../assets".freeze
        SPRITES = Gosu::Image.load_tiles(
          "#{ASSETS_PATH}/images/buttons.png",
          Window::SPRITE_SIZE,
          Window::SPRITE_SIZE
        ).freeze
        BUTTON_Z = 1
        SERIALIZABLE_VARS = (Base::SERIALIZABLE_VARS + %i[triggered])

        def initialize(**_args)
          super
          @triggerable = true
          @triggered = false
        end

        def update
          unless @triggerable
            @triggerable = !colliding_players?
            return
          end
          return unless colliding_players?

          trigger!
          @triggered = !@triggered
          @triggerable = false
        end

        def draw
          current_sprite.draw(@x, @y, BUTTON_Z)
        end

        private

        def colliding_players?
          @map.players.any? do |player|
            collide?(player)
          end
        end
      end
    end
  end
end
