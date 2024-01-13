# frozen_string_literal: true

module BombermanRuby
  class Game
    attr_accessor :step
    attr_reader :inputs

    INPUT_LIST = %i[
      up
      down
      left
      right
      bomb
      action
      start
    ].freeze

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
        input_params = INPUT_LIST.each_with_object({}) do |i, acc|
          acc[i] = constantize_input_config(input_config, i.to_s)
        end
        LocalInput.new(**input_params)
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
