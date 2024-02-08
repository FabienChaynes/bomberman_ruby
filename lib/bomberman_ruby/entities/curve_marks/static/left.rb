# frozen_string_literal: true

module BombermanRuby
  module Entities
    module CurveMarks
      module Static
        class Left < Base
          def initialize(**_args)
            super
            @direction = :left
          end
        end
      end
    end
  end
end
