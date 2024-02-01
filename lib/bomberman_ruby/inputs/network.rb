# frozen_string_literal: true

module BombermanRuby
  module Inputs
    class Network < Base
      FULL_MASK = 0b11111111
      UP_MASK = Local::UP_BIT ^ FULL_MASK
      DOWN_MASK = Local::DOWN_BIT ^ FULL_MASK
      LEFT_MASK = Local::LEFT_BIT ^ FULL_MASK
      RIGHT_MASK = Local::RIGHT_BIT ^ FULL_MASK
      BOMB_MASK = Local::BOMB_BIT ^ FULL_MASK
      ACTION_MASK = Local::ACTION_BIT ^ FULL_MASK

      attr_writer :inputs_bitfield

      def initialize
        super
        @inputs_bitfield = Local::NULL_BYTE
      end

      def self.deserialize(_data)
        new
      end

      def down?
        @inputs_bitfield | DOWN_MASK == FULL_MASK
      end

      def up?
        @inputs_bitfield | UP_MASK == FULL_MASK
      end

      def left?
        @inputs_bitfield | LEFT_MASK == FULL_MASK
      end

      def right?
        @inputs_bitfield | RIGHT_MASK == FULL_MASK
      end

      def bomb?
        @inputs_bitfield | BOMB_MASK == FULL_MASK
      end

      def action?
        @inputs_bitfield | ACTION_MASK == FULL_MASK
      end
    end
  end
end
