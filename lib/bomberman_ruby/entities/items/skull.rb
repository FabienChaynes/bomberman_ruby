# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Items
      class Skull < Base
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
      end
    end
  end
end
