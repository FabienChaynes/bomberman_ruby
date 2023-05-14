# frozen_string_literal: true

module BombermanRuby
  class SpeedUp < Item
    SPRITE = ITEMS_SPRITES[2]

    def draw
      SPRITE.draw(@x, @y, ITEM_Z)
    end
  end
end
