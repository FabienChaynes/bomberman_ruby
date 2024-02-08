# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Items
      class Base < Entities::Base
        include Concerns::Burnable

        ITEM_Z = 4
        COLOR_Z = 3
        BURNING_Z = 15
        ITEMS_SPRITES = Gosu::Image.load_tiles(
          "#{ASSETS_PATH}/images/items.png",
          Window::SPRITE_SIZE,
          Window::SPRITE_SIZE
        ).freeze
        BURNING_ITEM_SPRITES = Gosu::Image.load_tiles(
          "#{ASSETS_PATH}/images/burning_item.png",
          Window::SPRITE_SIZE,
          Window::SPRITE_SIZE * 2
        ).freeze
        BORDER_COLORS = [
          Gosu::Color.new(0xfff5f609),
          Gosu::Color.new(0xff7af305),
          Gosu::Color.new(0xff04ea0e),
          Gosu::Color.new(0xff04ea8b),
          Gosu::Color.new(0xff02f2ea),
          Gosu::Color.new(0xff0182ee),
          Gosu::Color.new(0xff010aee),
          Gosu::Color.new(0xff6d1eda),
          Gosu::Color.new(0xffd902d9),
          Gosu::Color.new(0xffe92a95),
          Gosu::Color.new(0xffe92a2f),
          Gosu::Color.new(0xffe9902f),
        ].freeze

        SERIALIZABLE_VARS = (Base::SERIALIZABLE_VARS + %i[burning_index]).freeze

        def draw
          if @burning_index
            burning_sprites[@burning_index].draw(@x, @y - Window::SPRITE_SIZE, BURNING_Z)
          else
            current_color = self.class.current_animated_sprite(BORDER_COLORS)
            Gosu.draw_rect(@x, @y, Window::SPRITE_SIZE, Window::SPRITE_SIZE, current_color, COLOR_Z)
            self.class::SPRITE.draw(@x, @y, ITEM_Z)
          end
        end

        private

        def burning_sprites
          self.class::BURNING_ITEM_SPRITES
        end
      end
    end
  end
end
