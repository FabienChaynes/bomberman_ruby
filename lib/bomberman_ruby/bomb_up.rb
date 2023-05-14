# frozen_string_literal: true

module BombermanRuby
  class BombUp < Item
    SPRITE = ITEMS_SPRITES[0]

    def draw
      SPRITE.draw(@x, @y, ITEM_Z)
    end
  end
end
