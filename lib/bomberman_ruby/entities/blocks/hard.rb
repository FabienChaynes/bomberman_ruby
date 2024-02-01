# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Blocks
      class Hard < Base
        def skip_serialization?
          true
        end
      end
    end
  end
end
