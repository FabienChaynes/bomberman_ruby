# frozen_string_literal: true

module BombermanRuby
  module Inputs
    class Base
      def serialize
        {
          class: self.class.to_s,
        }
      end
    end
  end
end
