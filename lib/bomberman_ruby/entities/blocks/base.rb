# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Blocks
      class Base < Entities::Base
        include Concerns::Blockable

        ASSETS_PATH = "#{__dir__}/../../../../assets".freeze
      end
    end
  end
end
