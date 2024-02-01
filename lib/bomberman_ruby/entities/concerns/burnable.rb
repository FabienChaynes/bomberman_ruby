# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Concerns
      module Burnable
        def burn!
          @map.entities.delete(self)
        end
      end
    end
  end
end
