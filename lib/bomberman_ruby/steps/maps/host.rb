# frozen_string_literal: true

module BombermanRuby
  module Steps
    module Maps
      class Host < Base
        include Steps::Concerns::Hosts::Networkable
        include Steps::Concerns::Maps::FileParsing

        END_ROUND_DURATION_MS = 4_000

        def initialize(game:, index:)
          super
          @map_path = "#{ASSETS_PATH}/maps/#{index}.txt"
          @map_config_path = "#{ASSETS_PATH}/maps/#{index}.yml"
          @starting_positions = {}
          load!
        end

        def update
          @players.each(&:update)
          @players.delete_if(&:deletable?)
          @entities.each(&:update)
          check_end_round
          send_map
        end

        private

        def send_map
          displayable_entities = @entities.reject(&:skip_serialization?)
          send_entities(displayable_entities + @players)
        end

        def check_end_round
          alive_players = @players.reject(&:dead?)
          return unless alive_players.count <= 1

          end_round(alive_players.first)
          return if Gosu.milliseconds < @ended_at + END_ROUND_DURATION_MS

          @game.step = Menus::Host.new(game: @game)
          send_step(Steps::Base::STEP_IDS[:menu])
        end

        def end_round(winning_player)
          return if @ended_at

          @ended_at = Gosu.milliseconds
          return unless winning_player

          winning_player.winning = true
          winning_player.sound = :winning
        end
      end
    end
  end
end
