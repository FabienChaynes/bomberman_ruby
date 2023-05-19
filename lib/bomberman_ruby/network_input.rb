# frozen_string_literal: true

module BombermanRuby
  class NetworkInput < Input
    FULL_MASK = 0b11111111
    UP_MASK = LocalInput::UP_BIT ^ FULL_MASK
    DOWN_MASK = LocalInput::DOWN_BIT ^ FULL_MASK
    LEFT_MASK = LocalInput::LEFT_BIT ^ FULL_MASK
    RIGHT_MASK = LocalInput::RIGHT_BIT ^ FULL_MASK
    BOMB_MASK = LocalInput::BOMB_BIT ^ FULL_MASK

    attr_writer :inputs_bitfield

    def initialize
      super
      @inputs_bitfield = LocalInput::NULL_BYTE
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
  end
end
