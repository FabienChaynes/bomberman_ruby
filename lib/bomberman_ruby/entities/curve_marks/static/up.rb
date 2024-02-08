# frozen_string_literal: true

module BombermanRuby
  module Entities
    module CurveMarks
      module Static
        class Up < Base
          def initialize(**_args)
            super
            @direction = :up
          end
        end
      end
    end
  end
end
