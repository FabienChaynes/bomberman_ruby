# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Pipes
      class Base < Entities::Base
        HORIZONTAL_PIPES_SPRITES = Gosu::Image.load_tiles(
          "#{ASSETS_PATH}/images/horizontal_pipes.png",
          Window::SPRITE_SIZE * 3,
          Window::SPRITE_SIZE * 2
        ).freeze
        VERTICAL_PIPES_SPRITES = Gosu::Image.load_tiles(
          "#{ASSETS_PATH}/images/vertical_pipes.png",
          Window::SPRITE_SIZE * 2,
          Window::SPRITE_SIZE * 3
        ).freeze
        MIDDLE_PIPE_SPRITE = Gosu::Image.new(
          "#{ASSETS_PATH}/images/middle_pipe.png"
        ).freeze
        PIPE_Z = 20
      end
    end
  end
end
