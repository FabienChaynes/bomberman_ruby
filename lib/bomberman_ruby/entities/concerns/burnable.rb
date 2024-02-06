# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Concerns
      module Burnable
        attr_writer :burning_index

        def update
          return unless @burned_at

          delay = Gosu.milliseconds - @burned_at
          if delay >= Fire::EXPLOSION_DURATION_MS
            @map.entities.delete(self)
            final_burn!
            return
          end
          new_burning_index = (delay / (Fire::EXPLOSION_DURATION_MS / burning_sprites.size)).to_i
          @burning_index = new_burning_index if new_burning_index < burning_sprites.size
        end

        def burn!
          @burning_index = 0
          @burned_at = Gosu.milliseconds
        end

        private

        def final_burn!; end
      end
    end
  end
end
