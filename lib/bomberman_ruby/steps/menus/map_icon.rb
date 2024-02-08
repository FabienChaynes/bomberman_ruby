# frozen_string_literal: true

module BombermanRuby
  module Steps
    module Menus
      class MapIcon
        ASSETS_PATH = "#{__dir__}/../../../../assets".freeze
        MAP_ICON_WIDTH = 60
        MAP_ICON_HEIGHT = 60
        MAP_ICONS = Gosu::Image.load_tiles(
          "#{ASSETS_PATH}/images/map_icons.png",
          MAP_ICON_WIDTH,
          MAP_ICON_HEIGHT
        ).freeze
        MAP_NAMES = [
          "Standard",
          "Hi Power",
          "Conveyor",
          "Slippage",
          "Landmine",
          "Pipe Bomb",
          "Curvage",
          "Moon Warp",
        ].freeze

        attr_accessor :index

        def initialize(index:)
          @index = index
        end

        def self.deserialize(data)
          new(index: data["index"])
        end

        def draw
          map_icon_x = (Window::WIDTH / 2) - (MAP_ICON_WIDTH / 2)
          map_icon_y = (Window::HEIGHT / 2) - (MAP_ICON_HEIGHT / 2)
          map_name = MAP_NAMES[@index]
          map_name_x = (Window::WIDTH / 2) - (Base::FONT.text_width(map_name) / 2)
          Base::FONT.draw_text(map_name, map_name_x, map_icon_y - Base::FONT_SIZE, 1, 1, 1, Base::FONT_COLOR)
          MAP_ICONS[@index].draw(map_icon_x, map_icon_y, 2)
        end

        def serialize
          {
            class: self.class.to_s,
            index: @index,
          }
        end
      end
    end
  end
end
