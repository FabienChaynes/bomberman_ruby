# frozen_string_literal: true

module BombermanRuby
  class Player < Entity
    PLAYER_Z = 10
    SPRITE_REFRESH_RATE = 200
    SPRITE_WIDTH = 15
    SPRITES = Gosu::Image.load_tiles(
      "#{__dir__}/../../assets/images/player.png",
      SPRITE_WIDTH,
      22
    ).freeze
    WALKING_DOWN_SPRITES = [SPRITES[0], SPRITES[1], SPRITES[0], SPRITES[2]].freeze
    WALKING_LEFT_SPRITES = [SPRITES[6], SPRITES[7], SPRITES[6], SPRITES[8]].freeze
    WALKING_UP_SPRITES = [SPRITES[12], SPRITES[13], SPRITES[12], SPRITES[14]].freeze

    def initialize(args)
      super(**args)
      @direction = :down
      @moving = false
    end

    def update
      move!
    end

    def draw
      scale_x = @direction == :right ? -1 : 1
      draw_x = @direction == :right ? @x + SPRITE_WIDTH : @x
      current_sprite.draw(draw_x, @y, PLAYER_Z, scale_x)
      debug_hitbox
    end

    def hitbox
      {
        up: 12,
        down: 22,
        left: 1,
        right: 14,
      }
    end

    private

    def speed
      1
    end

    def current_sprite
      sprites = case @direction
                when :down
                  WALKING_DOWN_SPRITES
                when :up
                  WALKING_UP_SPRITES
                when :left, :right
                  WALKING_LEFT_SPRITES
                end
      @moving ? sprites[(Gosu.milliseconds / SPRITE_REFRESH_RATE) % sprites.size] : sprites.first
    end

    def move!
      @moving = false

      move_vertical!
      move_horizontal!
    end

    def move_vertical!
      y_delta = 0
      y_delta -= speed if Gosu.button_down?(Gosu::KB_UP)
      y_delta += speed if Gosu.button_down?(Gosu::KB_DOWN)
      return unless y_delta != 0 && can_move_to?(@x, @y + y_delta)

      @y += y_delta
      @moving = true
      @direction = y_delta.positive? ? :down : :up
    end

    def move_horizontal!
      x_delta = 0
      x_delta -= speed if Gosu.button_down?(Gosu::KB_LEFT)
      x_delta += speed if Gosu.button_down?(Gosu::KB_RIGHT)
      return unless x_delta != 0 && can_move_to?(@x + x_delta, @y)

      @x += x_delta
      @moving = true
      @direction = x_delta.positive? ? :right : :left
    end

    def can_move_to?(target_x, target_y)
      @map.entities.none? do |entity|
        next unless entity.is_a?(Blockable)

        collide?(entity, target_x, target_y)
      end
    end
  end
end
