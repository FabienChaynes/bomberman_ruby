# frozen_string_literal: true

module BombermanRuby
  class Input
    # Should be inherited by real inputs classes
    def serialize
      {
        class: self.class.to_s,
      }
    end
  end
end
