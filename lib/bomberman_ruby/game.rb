# frozen_string_literal: true

module BombermanRuby
  class Game
    attr_reader :inputs

    def initialize
      inputs_config_file = if File.file?("config/inputs.yml")
                             File.read("config/inputs.yml")
                           else
                             File.read("config/inputs.yml.example")
                           end
      inputs_config = YAML.load(inputs_config_file)
      @inputs = build_inputs_from_config(inputs_config)
      @map = Map.new(game: self)
    end

    def update
      @map.update
    end

    def draw
      @map.draw
    end

    private

    def build_inputs_from_config(inputs_config)
      inputs_config.map do |_id, input_config|
        Input.new(
          up: constantize_input_config(input_config, "up"),
          down: constantize_input_config(input_config, "down"),
          left: constantize_input_config(input_config, "left"),
          right: constantize_input_config(input_config, "right"),
          bomb: constantize_input_config(input_config, "bomb")
        )
      end
    end

    def constantize_input_config(input_config, input_name)
      input_config[input_name].map { |c| Object.const_get("Gosu::#{c}") }
    end
  end
end
