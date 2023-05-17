# frozen_string_literal: true

module BombermanRuby
  class Input
    def initialize(down:, up:, left:, right:, bomb:)
      @down = down
      @up = up
      @left = left
      @right = right
      @bomb = bomb
    end

    def down?
      @down.any? { |b| Gosu.button_down?(b) }
    end

    def up?
      @up.any? { |b| Gosu.button_down?(b) }
    end

    def left?
      @left.any? { |b| Gosu.button_down?(b) }
    end

    def right?
      @right.any? { |b| Gosu.button_down?(b) }
    end

    def bomb?
      @bomb.any? { |b| Gosu.button_down?(b) }
    end
  end
end
