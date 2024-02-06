# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Concerns
      module Triggerable
        private

        def check_trigger!
          unless @triggerable
            @triggerable = !colliding_players?
            return
          end
          return unless colliding_players?

          trigger!
          @triggered = !@triggered
          @triggerable = false
        end

        def trigger!; end

        def colliding_players?
          @map.players.any? do |player|
            collide?(player)
          end
        end
      end
    end
  end
end
