# frozen_string_literal: true

module BombermanRuby
  module Steps
    module Maps
      class Host < Base
        include Steps::Concerns::Hosts::Networkable

        CONFIG_ITEM_MAPPING = {
          "bomb_ups" => :bomb_up,
          "fire_ups" => :fire_up,
          "skulls" => :skull,
          "speed_ups" => :speed_up,
        }.freeze
        CHARS_MAPPING = {
          "s" => Entities::Blocks::Soft,
          "x" => Entities::Blocks::Hard,
        }.freeze
        STARTING_POSITION_CHARS = ("0"..(Games::Base::MAX_PLAYER_COUNT - 1).to_s)
        END_ROUND_DURATION_MS = 4_000
        PLAYER_CONFIG_KEYS = %i[
          starting_bomb_capacity
          starting_bomb_radius
          starting_kick
          starting_punch
          starting_line_bomb
          starting_speed
        ].freeze

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

        def load!
          lines = File.read(@map_path).split("\n").map(&:chars)
          lines.each_with_index do |line, y|
            line.each_with_index do |c, x|
              @entities << CHARS_MAPPING[c].new(grid_x: x, grid_y: y, map: self) if CHARS_MAPPING.key?(c)
              @starting_positions[c.to_i] = StartingPosition.new(grid_x: x, grid_y: y) if STARTING_POSITION_CHARS
                                                                                          .include?(c)
            end
          end
          load_items!
          load_players!
        end

        def load_items!
          delete_extra_soft_blocks!
          set_blocks_items!
        end

        def load_players!
          [@starting_positions.count, @game.inputs.count].min.times do |i|
            @players << instanciate_player(i)
          end
        end

        def instanciate_player(id)
          Entities::Player.new(
            grid_x: @starting_positions[id].grid_x,
            grid_y: @starting_positions[id].grid_y,
            map: self,
            input: @game.inputs[id],
            id:,
            **config.transform_keys(&:to_sym).slice(*PLAYER_CONFIG_KEYS)
          )
        end

        def config
          @config ||= YAML.load_file(@map_config_path)
        end

        def delete_extra_soft_blocks!
          shuffled_soft_blocks = @entities.select { |e| e.is_a?(Entities::Blocks::Soft) }.shuffle
          shuffled_soft_blocks.pop(config["soft_blocks"])
          @entities.delete_if { |e| shuffled_soft_blocks.include?(e) }
        end

        def set_blocks_items!
          shuffled_soft_blocks = @entities.select { |e| e.is_a?(Entities::Blocks::Soft) }.shuffle
          CONFIG_ITEM_MAPPING.each do |config_key, item|
            config[config_key].times { shuffled_soft_blocks.pop.item = item }
          end
        end

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
