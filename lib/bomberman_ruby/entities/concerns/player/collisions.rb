# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Concerns
      module Player
        module Collisions
          private

          def colliding_entities(_target_x, _target_y)
            super.reject do |e|
              e.is_a?(Entities::Bomb) && collide?(e)
            end
          end

          def check_collisions!
            fire_collisions!
            item_collisions!
          end

          def fire_collisions!
            return unless @map.entities.any? { |e| e.is_a?(Fire) && collide?(e) }

            @dead_at = Gosu.milliseconds
          end
        end
      end
    end
  end
end
