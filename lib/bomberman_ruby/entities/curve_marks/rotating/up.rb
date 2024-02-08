# frozen_string_literal: true

module BombermanRuby
  module Entities
    module CurveMarks
      module Rotating
        class Up < Base
          DIRECTIONS = %i[up right down left].freeze

          def initialize(**_args)
            super
            @direction = :up
          end
        end
      end
    end
  end
end
