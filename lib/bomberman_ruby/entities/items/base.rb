# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Items
      class Base < Entities::Base
        include Concerns::Burnable

        ITEM_Z = 1
        ASSETS_PATH = "#{__dir__}/../../../../assets".freeze
        ITEMS_SPRITES = Gosu::Image.load_tiles(
          "#{ASSETS_PATH}/images/items.png",
          Window::SPRITE_SIZE,
          Window::SPRITE_SIZE
        ).freeze

        def draw
          self.class::SPRITE.draw(@x, @y, ITEM_Z)
        end
      end
    end
  end
end
