# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Blocks
      class Base < Entities::Base
        include Concerns::Blockable
      end
    end
  end
end
