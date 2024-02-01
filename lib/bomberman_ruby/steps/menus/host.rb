# frozen_string_literal: true

module BombermanRuby
  module Steps
    module Menus
      class Host < Base
        include Steps::Concerns::Hosts::Networkable

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
        MAP_COUNT = 2
        MAP_CHANGE_DELAY = 250
        MAP_STEP_ID = 1

        def update
          @inputs = @game.inputs
          if @inputs[0]&.start?
            launch_map
          else
            update_map_selection
            send_inputs
          end
        end

        def draw
          super
          draw_map_selection
          FONT.draw_text("Press start to launch the game", 0, Window::HEIGHT - FONT_SIZE, INPUT_Z, 1, 1, FONT_COLOR)
        end

        private

        def draw_map_selection
          map_icon_x = (Window::WIDTH / 2) - (MAP_ICON_WIDTH / 2)
          map_icon_y = (Window::HEIGHT / 2) - (MAP_ICON_HEIGHT / 2)
          map_name = MAP_NAMES[@current_map_index]
          map_name_x = (Window::WIDTH / 2) - (FONT.text_width(map_name) / 2)
          FONT.draw_text(map_name, map_name_x, map_icon_y - FONT_SIZE, 1, 1, 1, FONT_COLOR)
          MAP_ICONS[@current_map_index].draw(map_icon_x, map_icon_y, 2)
        end

        def update_map_selection
          return unless !@map_changed_at || @map_changed_at + MAP_CHANGE_DELAY < Gosu.milliseconds
          return unless @inputs[0]&.right? || @inputs[0]&.left?

          @map_changed_at = Gosu.milliseconds
          update_current_map_index
        end

        def update_current_map_index
          @current_map_index += 1 if @inputs[0]&.right?
          @current_map_index -= 1 if @inputs[0]&.left?
          @current_map_index = MAP_COUNT - 1 if @current_map_index.negative?
          @current_map_index = 0 if @current_map_index >= MAP_COUNT
        end

        def launch_map
          @game.step = Maps::Host.new(game: @game, index: @current_map_index)
          send_step(Steps::Base::STEP_IDS[:map], @current_map_index)
        end

        def send_inputs
          send_entities(@inputs)
        end
      end
    end
  end
end
