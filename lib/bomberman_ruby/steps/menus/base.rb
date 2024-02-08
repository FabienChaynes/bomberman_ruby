# frozen_string_literal: true

module BombermanRuby
  module Steps
    module Menus
      class Base < Steps::Base
        ASSETS_PATH = "#{__dir__}/../../../../assets".freeze
        BACKGROUND = Gosu::Image.new("#{ASSETS_PATH}/images/menu_background.png")
        BACKGROUND_Z = 0
        INPUT_Z = 1
        INPUT_SPRITE_MARGIN = 5
        FONT_SIZE = 10
        FONT = Gosu::Font.new(FONT_SIZE)
        FONT_COLOR = 0xff_000000
        MENU_SONG = Gosu::Song.new("#{ASSETS_PATH}/sound/menu.mp3").freeze

        def initialize(game:)
          super
          @inputs = []
          @map_icon = MapIcon.new(index: 0)
          MENU_SONG.play(true)
        end

        def draw
          BACKGROUND.draw(0, 0, BACKGROUND_Z)
          @inputs[0..(Games::Base::MAX_PLAYER_COUNT - 1)].each_with_index do |input, i|
            sprite_index = input.is_a?(Inputs::Network) ? local_input_sprite : network_input_sprite
            sprite_offset = Entities::Player::SPRITE_COUNT * i
            Entities::Player::SPRITES[sprite_index + sprite_offset]
              .draw(i * (Entities::Player::SPRITE_WIDTH + INPUT_SPRITE_MARGIN), INPUT_Z)
          end
          @map_icon.draw
          FONT.draw_text("Press action to launch the game", 0, Window::HEIGHT - FONT_SIZE, INPUT_Z, 1, 1, FONT_COLOR)
        end

        private

        def local_input_sprite
          Entities::Player::WINNING_SPRITE_INDEXES.last
        end

        def network_input_sprite
          Entities::Player::WALKING_DOWN_SPRITE_INDEXES.first
        end
      end
    end
  end
end
