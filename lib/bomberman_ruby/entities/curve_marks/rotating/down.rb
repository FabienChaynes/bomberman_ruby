# frozen_string_literal: true

module BombermanRuby
  module Entities
    module CurveMarks
      module Rotating
        class Down < Base
          DIRECTIONS = %i[down left up right].freeze

          def initialize(**_args)
            super
            @direction = :down
          end
        end
      end
    end
  end
end
