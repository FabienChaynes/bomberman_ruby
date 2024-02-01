# frozen_string_literal: true

module BombermanRuby
  module Steps
    module Menus
      class Client < Base
        include Steps::Concerns::Clients::Networkable

        DESERIALIZABLE_CLASSES = [
          "BombermanRuby::Inputs::Local",
          "BombermanRuby::Inputs::Network",
        ].freeze

        def update
          update_menu_state
        end

        def draw
          super
          FONT.draw_text("Waiting for the host to start the game",
                         0, Window::HEIGHT - FONT_SIZE, INPUT_Z, 1, 1, FONT_COLOR)
        end

        private

        def update_menu_state
          return unless (inputs = read_socket)

          @inputs = []
          inputs.each do |e|
            @inputs << Object.const_get(e["class"]).deserialize(e)
          end
        end
      end
    end
  end
end
