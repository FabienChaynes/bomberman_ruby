# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Concerns
      module Player
        module Bonus
          ITEM_METHOD_MAPPING = {
            Items::BombUp => :increase_bomb_capacity!,
            Items::FireUp => :increase_bomb_radius!,
            Items::SpeedUp => :increase_speed!,
            Items::Skull => :trigger_skull_effect!,
            Items::Kick => :enable_kick!,
            Items::Punch => :enable_punch!,
            Items::LineBomb => :enable_line_bomb!,
          }.freeze
          MAX_BOMB_CAPACITY = 5
          MAX_BOMB_RADIUS = 9
          SKULL_EFFECT_DURATION_MS = 10_000

          private

          def item_collisions!
            return unless (item = @map.entities.find { |e| e.is_a?(Items::Base) && collide?(e) })

            send(ITEM_METHOD_MAPPING[item.class])
            @map.entities.delete(item)
            @sound = :loot_item
          end

          def increase_bomb_capacity!
            @bomb_capacity += 1 unless @bomb_capacity >= MAX_BOMB_CAPACITY
          end

          def increase_bomb_radius!
            @bomb_radius += 1 unless @bomb_radius >= MAX_BOMB_RADIUS
          end

          def increase_speed!
            @speed += 0.2
          end

          def trigger_skull_effect!
            @skull_effect = Items::Skull::EFFECTS.sample
            @skull_effect_started_at = Gosu.milliseconds
          end

          def cancel_skull_effect!
            unless @skull_effect_started_at && @skull_effect_started_at + SKULL_EFFECT_DURATION_MS < Gosu.milliseconds
              return
            end

            @skull_effect = @skull_effect_started_at = nil
          end

          def enable_kick!
            @kick = true
          end

          def enable_punch!
            @punch = true
          end

          def enable_line_bomb!
            @line_bomb = true
          end
        end
      end
    end
  end
end
