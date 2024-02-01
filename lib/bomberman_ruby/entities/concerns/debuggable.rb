# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Concerns
      module Debuggable
        private

        def debug_hitbox # rubocop:disable Metrics/AbcSize
          Gosu.draw_rect(
            @x + hitbox[:left],
            @y + hitbox[:up],
            hitbox[:right] - hitbox[:left],
            hitbox[:down] - hitbox[:up],
            Gosu::Color.new(0x77, 0xff, 0, 0),
            10_000
          )
        end
      end
    end
  end
end
