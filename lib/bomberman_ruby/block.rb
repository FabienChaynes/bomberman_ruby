# frozen_string_literal: true

module BombermanRuby
  class Block < Entity
    include Blockable

    def initialize(args)
      super(**args)
      @y += Map::VERTICAL_MARGIN
    end
  end
end
