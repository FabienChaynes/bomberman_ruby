# frozen_string_literal: true

module BombermanRuby
  module Entities
    class Hole < Base
      include Concerns::Blockable
      include Concerns::Triggerable

      SPRITES = Gosu::Image.load_tiles(
        "#{ASSETS_PATH}/images/hole.png",
        Window::SPRITE_SIZE,
        Window::SPRITE_SIZE,
        tileable: true
      ).freeze
      HOLE_Z = 2
      SERIALIZABLE_VARS = (Base::SERIALIZABLE_VARS + %i[index]).freeze

      attr_writer :index

      def initialize(args)
        super(**args)
        @triggerable = true
        @triggered = false
        @index = nil
      end

      def update
        check_trigger!
      end

      def draw
        SPRITES[@index].draw(@x, @y, HOLE_Z) if @index
      end

      def blocking?
        @index == 1
      end

      private

      def trigger!
        @index = @index.nil? ? 0 : 1
      end
    end
  end
end
