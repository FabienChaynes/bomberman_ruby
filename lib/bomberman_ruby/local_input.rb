# frozen_string_literal: true

module BombermanRuby
  class LocalInput < Input
    NULL_BYTE = 0b00000000
    UP_BIT = 0b10000000
    DOWN_BIT = 0b01000000
    LEFT_BIT = 0b00100000
    RIGHT_BIT = 0b00010000
    BOMB_BIT = 0b00001000

    attr_accessor :host_input_id

    def initialize(down:, up:, left:, right:, bomb:, start:) # rubocop:disable Metrics/ParameterLists:
      super()
      @down_buttons = down
      @up_buttons = up
      @left_buttons = left
      @right_buttons = right
      @bomb_buttons = bomb
      @start_buttons = start
      @host_input_id = nil
    end

    def self.deserialize(_data)
      new(down: nil, up: nil, left: nil, right: nil, bomb: nil, start: nil)
    end

    def bitfield
      inputs_bitfield = NULL_BYTE
      inputs_bitfield |= UP_BIT if up?
      inputs_bitfield |= DOWN_BIT if down?
      inputs_bitfield |= LEFT_BIT if left?
      inputs_bitfield |= RIGHT_BIT if right?
      inputs_bitfield |= BOMB_BIT if bomb?
      inputs_bitfield
    end

    def down?
      @down_buttons.any? { |b| Gosu.button_down?(b) }
    end

    def up?
      @up_buttons.any? { |b| Gosu.button_down?(b) }
    end

    def left?
      @left_buttons.any? { |b| Gosu.button_down?(b) }
    end

    def right?
      @right_buttons.any? { |b| Gosu.button_down?(b) }
    end

    def bomb?
      @bomb_buttons.any? { |b| Gosu.button_down?(b) }
    end

    def start?
      @start_buttons.any? { |b| Gosu.button_down?(b) }
    end
  end
end
