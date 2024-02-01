# frozen_string_literal: true

module BombermanRuby
  module Steps
    module Maps
      class Base < Steps::Base
        BACKGROUND_Z = 0
        MAP_BACKGROUNDS = Gosu::Image.load_tiles(
          "#{ASSETS_PATH}/images/maps.png",
          Window::WIDTH,
          Window::HEIGHT
        ).freeze
        VERTICAL_MARGIN = 8
        BATTLE_MODE_SONG = Gosu::Song.new("#{ASSETS_PATH}/sound/battle_mode.mp3").freeze

        attr_accessor :entities, :players

        def initialize(game:, index:)
          super(game:)
          @map_background = MAP_BACKGROUNDS[index]
          @entities = []
          @players = []
          BATTLE_MODE_SONG.play(true)
        end

        def draw
          @map_background.draw(0, 0, BACKGROUND_Z)
          Gosu.translate(0, VERTICAL_MARGIN - Window::SPRITE_SIZE) do
            @entities.each(&:draw)
            @players.each(&:draw)
          end
        end
      end
    end
  end
end
