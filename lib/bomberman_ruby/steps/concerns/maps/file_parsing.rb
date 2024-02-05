# frozen_string_literal: true

module BombermanRuby
  module Steps
    module Concerns
      module Maps
        module FileParsing
          CONFIG_ITEM_MAPPING = {
            "bomb_ups" => :bomb_up,
            "fire_ups" => :fire_up,
            "skulls" => :skull,
            "speed_ups" => :speed_up,
            "kicks" => :kick,
            "punches" => :punch,
            "line_bombs" => :line_bomb,
          }.freeze
          CHARS_MAPPING = {
            "x" => [Entities::Blocks::Hard],
            "s" => [Entities::Blocks::Soft],
            ">" => [Entities::Blocks::Soft, Entities::Conveyors::Right],
            "<" => [Entities::Blocks::Soft, Entities::Conveyors::Left],
            "^" => [Entities::Blocks::Soft, Entities::Conveyors::Up],
            "v" => [Entities::Blocks::Soft, Entities::Conveyors::Down],
            "┌" => [Entities::Blocks::Soft, Entities::Conveyors::TopLeft],
            "┐" => [Entities::Blocks::Soft, Entities::Conveyors::TopRight],
            "└" => [Entities::Blocks::Soft, Entities::Conveyors::BottomLeft],
            "┘" => [Entities::Blocks::Soft, Entities::Conveyors::BottomRight],
            "S" => [Entities::Blocks::Soft, Entities::Buttons::SpeedChange],
            "R" => [Entities::Blocks::Soft, Entities::Buttons::RotationChange],
          }.freeze
          STARTING_POSITION_CHARS = ("0"..(Games::Base::MAX_PLAYER_COUNT - 1).to_s)
          PLAYER_CONFIG_KEYS = %i[
            starting_bomb_capacity
            starting_bomb_radius
            starting_kick
            starting_punch
            starting_line_bomb
            starting_speed
          ].freeze

          private

          def load!
            lines = File.read(@map_path).split("\n").map(&:chars)
            lines.each_with_index do |line, y|
              line.each_with_index do |c, x|
                load_coord!(c, x, y)
              end
            end
            load_items!
            load_players!
          end

          def load_coord!(char, x, y)
            if CHARS_MAPPING.key?(char)
              CHARS_MAPPING[char].each do |klass|
                @entities << klass.new(grid_x: x, grid_y: y, map: self)
              end
            end
            @starting_positions[char.to_i] = StartingPosition.new(grid_x: x, grid_y: y) if STARTING_POSITION_CHARS
                                                                                           .include?(char)
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
              config[config_key]&.times { shuffled_soft_blocks.pop.item = item }
            end
          end
        end
      end
    end
  end
end
