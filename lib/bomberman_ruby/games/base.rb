# frozen_string_literal: true

module BombermanRuby
  module Games
    class Base
      attr_accessor :step
      attr_reader :inputs

      BUTTON_LIST = %i[
        up
        down
        left
        right
        bomb
        action
        start
      ].freeze
      CONFIG_DIR = "#{__dir__}/../../../config".freeze
      MAX_PLAYER_COUNT = 4

      def initialize(options)
        @options = options
        inputs_config = YAML.load(inputs_config_file)
        @inputs = build_inputs_from_config(inputs_config)
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
          input_params = BUTTON_LIST.each_with_object({}) do |b, acc|
            acc[b] = constantize_input_config(input_config, b.to_s)
          end
          Inputs::Local.new(**input_params)
        end
      end

      def constantize_input_config(input_config, input_name)
        input_config[input_name].map { |c| Object.const_get("Gosu::#{c}") }
      end

      def inputs_config_file
        if @options[:config_file] && File.file?(@options[:config_file])
          File.read(@options[:config_file])
        elsif File.file?("#{CONFIG_DIR}/inputs.yml")
          File.read("#{CONFIG_DIR}/inputs.yml")
        else
          File.read("#{CONFIG_DIR}/inputs.yml.example")
        end
      end

      def used_config(inputs_config)
        @options[:player_number] ? inputs_config.take(@options[:player_number]) : inputs_config
      end
    end
  end
end
