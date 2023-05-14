# frozen_string_literal: true

module BombermanRuby
  class FireUp < Item
    SPRITE = ITEMS_SPRITES[1]

    def draw
      SPRITE.draw(@x, @y, ITEM_Z)
    end
  end
end
