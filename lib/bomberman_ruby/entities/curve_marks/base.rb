# frozen_string_literal: true

module BombermanRuby
  module Entities
    module CurveMarks
      class Base < Entities::Base
        def enable(bomb)
          bomb.direction = @direction
        end
      end
    end
  end
end
