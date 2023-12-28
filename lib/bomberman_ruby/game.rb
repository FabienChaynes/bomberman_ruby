# frozen_string_literal: true

module BombermanRuby
  class Game
    attr_accessor :step
    attr_reader :inputs

    def initialize(options)
      @options = options
      inputs_config = YAML.load(inputs_config_file)
      @inputs = build_inputs_from_config(inputs_config)
      @step = Menu.new(game: self)
    end

    def update
      @step&.update
    end

    def draw
      @step&.draw
    end

    private

    def build_inputs_from_config(inputs_config)
      used_config(inputs_config).map do |_id, input_config|
        LocalInput.new(
          up: constantize_input_config(input_config, "up"),
          down: constantize_input_config(input_config, "down"),
          left: constantize_input_config(input_config, "left"),
          right: constantize_input_config(input_config, "right"),
          bomb: constantize_input_config(input_config, "bomb"),
          start: constantize_input_config(input_config, "start")
        )
      end
    end

    def constantize_input_config(input_config, input_name)
      input_config[input_name].map { |c| Object.const_get("Gosu::#{c}") }
    end

    def inputs_config_file
      if @options[:config_file] && File.file?(@options[:config_file])
        File.read(@options[:config_file])
      elsif File.file?("config/inputs.yml")
        File.read("config/inputs.yml")
      else
        File.read("config/inputs.yml.example")
      end
    end

    def used_config(inputs_config)
      @options[:player_number] ? inputs_config.take(@options[:player_number]) : inputs_config
    end
  end
end
