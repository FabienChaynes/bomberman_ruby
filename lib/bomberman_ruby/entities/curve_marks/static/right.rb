# frozen_string_literal: true

module BombermanRuby
  module Entities
    module CurveMarks
      module Static
        class Right < Base
          def initialize(**_args)
            super
            @direction = :right
          end
        end
      end
    end
  end
end
