# frozen_string_literal: true

module BombermanRuby
  module Burnable
    def burn!
      @map.entities.delete(self)
    end
  end
end
