# frozen_string_literal: true

module BombermanRuby
  module Entities
    module CurveMarks
      module Static
        class Down < Base
          def initialize(**_args)
            super
            @direction = :down
          end
        end
      end
    end
  end
end
