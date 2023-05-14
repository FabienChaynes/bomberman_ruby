# frozen_string_literal: true

module BombermanRuby
  class Skull < Item
    SPRITE = ITEMS_SPRITES[3]
    EFFECTS = %i[
      constipation
      diarrhea
      hyperactivity
      lead_feet
      lethargy
      lightining_feet
      reversal_syndrome
      wimp_syndrome
    ].freeze

    def draw
      SPRITE.draw(@x, @y, ITEM_Z)
    end
  end
end
