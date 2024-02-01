# frozen_string_literal: true

module BombermanRuby
  module Steps
    class Base
      ASSETS_PATH = "#{__dir__}/../../../assets".freeze
      STEP_IDS = {
        menu: 0,
        map: 1,
      }.freeze

      def initialize(game:)
        @game = game
      end
    end
  end
end
