# frozen_string_literal: true

module BombermanRuby
  class Item < Entity
    include Burnable

    ITEM_Z = 1
    ITEMS_SPRITES = Gosu::Image.load_tiles(
      "#{__dir__}/../../assets/images/items.png",
      Window::SPRITE_SIZE,
      Window::SPRITE_SIZE
    ).freeze
  end
end
