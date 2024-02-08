# frozen_string_literal: true

module BombermanRuby
  module Steps
    module Menus
      class Host < Base
        include Steps::Concerns::Hosts::Networkable
        MAP_COUNT = 6
        MAP_CHANGE_DELAY = 250
        MAP_STEP_ID = 1

        def initialize(args)
          map_index = args.delete(:map_index) || 0
          super(**args)
          @map_icon.index = map_index
        end

        def update
          @inputs = @game.inputs
          if @inputs.any?(&:action?)
            launch_map
          else
            update_map_selection
            send_entities(@inputs + [@map_icon])
          end
        end

        private

        def update_map_selection
          return unless !@map_changed_at || @map_changed_at + MAP_CHANGE_DELAY < Gosu.milliseconds
          return unless @inputs.any? { |i| i.right? || i.left? }

          @map_changed_at = Gosu.milliseconds
          update_current_map_index
        end

        def update_current_map_index
          @map_icon.index += 1 if @inputs.any?(&:right?)
          @map_icon.index -= 1 if @inputs.any?(&:left?)
          @map_icon.index = MAP_COUNT - 1 if @map_icon.index.negative?
          @map_icon.index = 0 if @map_icon.index >= MAP_COUNT
        end

        def launch_map
          @game.step = Maps::Host.new(game: @game, index: @map_icon.index)
          send_step(Steps::Base::STEP_IDS[:map], @map_icon.index)
        end
      end
    end
  end
end
