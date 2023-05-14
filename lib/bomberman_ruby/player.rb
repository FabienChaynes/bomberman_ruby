# frozen_string_literal: true

module BombermanRuby
  class Player < Entity
    PLAYER_Z = 10
    SPRITE_WIDTH = 15
    SPRITES = Gosu::Image.load_tiles(
      "#{__dir__}/../../assets/images/player.png",
      SPRITE_WIDTH,
      22
    ).freeze
    WALKING_DOWN_SPRITES = [SPRITES[0], SPRITES[1], SPRITES[0], SPRITES[2]].freeze
    WALKING_LEFT_SPRITES = [SPRITES[6], SPRITES[7], SPRITES[6], SPRITES[8]].freeze
    WALKING_UP_SPRITES = [SPRITES[12], SPRITES[13], SPRITES[12], SPRITES[14]].freeze
    MAX_BOMB_CAPACITY = 5
    MAX_BOMB_RADIUS = 9
    SKULL_EFFECT_DURATION_MS = 10_000
    SKULL_EFFECT_COLORS = [
      Gosu::Color.new(0xff_ffffff),
      Gosu::Color.new(0xff_cccccc),
      Gosu::Color.new(0xff_999999),
      Gosu::Color.new(0xff_666666),
      Gosu::Color.new(0xff_333333),
      Gosu::Color.new(0xff_666666),
      Gosu::Color.new(0xff_999999),
      Gosu::Color.new(0xff_cccccc)
    ].freeze
    ITEM_METHOD_MAPPING = {
      BombermanRuby::BombUp => :increase_bomb_capacity!,
      BombermanRuby::FireUp => :increase_bomb_radius!,
      BombermanRuby::SpeedUp => :increase_speed!,
      BombermanRuby::Skull => :trigger_skull_effect!,
    }.freeze

    attr_reader :skull_effect

    def initialize(args)
      super(**args)
      @direction = :down
      @moving = false
      @bomb_capacity = 1
      @bomb_radius = 1
      @speed = 1
      @skull_effect = nil
      @skull_effect_started_at = nil
    end

    def update
      move!
      check_collisions!
      cancel_skull_effect!
      execute_actions!
    end

    def draw
      scale_x = @direction == :right ? -1 : 1
      draw_x = @direction == :right ? @x + SPRITE_WIDTH : @x
      current_sprite.draw(draw_x, @y, PLAYER_Z, scale_x, 1, sprite_color)
      # debug_hitbox
    end

    def hitbox
      {
        up: 12,
        down: 22,
        left: 1,
        right: 14,
      }
    end

    def bomb_radius
      case @skull_effect
      when :wimp_syndrome
        1
      else
        @bomb_radius
      end
    end

    private

    def speed
      case @skull_effect
      when :lead_feet
        0.5
      when :lightining_feet
        3
      else
        @speed
      end
    end

    def bomb_capacity
      case @skull_effect
      when :wimp_syndrome
        1
      else
        @bomb_capacity
      end
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

    def sprite_color
      if @skull_effect
        SKULL_EFFECT_COLORS[(Gosu.milliseconds / SPRITE_REFRESH_RATE) % SKULL_EFFECT_COLORS.size]
      else
        Gosu::Color.new(0xff_ffffff)
      end
    end

    def move!
      @moving = false

      move_vertical!
      move_horizontal!
    end

    def up_control?
      case @skull_effect
      when :reversal_syndrome
        Gosu.button_down?(Gosu::KB_DOWN)
      else
        Gosu.button_down?(Gosu::KB_UP)
      end
    end

    def down_control?
      case @skull_effect
      when :reversal_syndrome
        Gosu.button_down?(Gosu::KB_UP)
      else
        Gosu.button_down?(Gosu::KB_DOWN)
      end
    end

    def left_control?
      case @skull_effect
      when :reversal_syndrome
        Gosu.button_down?(Gosu::KB_RIGHT)
      else
        Gosu.button_down?(Gosu::KB_LEFT)
      end
    end

    def right_control?
      case @skull_effect
      when :reversal_syndrome
        Gosu.button_down?(Gosu::KB_LEFT)
      else
        Gosu.button_down?(Gosu::KB_RIGHT)
      end
    end

    def bomb_control?
      case @skull_effect
      when :diarrhea
        true
      else
        Gosu.button_down?(Gosu::KB_X)
      end
    end

    def move_vertical!
      y_delta = 0
      y_delta -= speed if up_control?
      y_delta += speed if down_control?
      return unless y_delta != 0 && can_move_to?(@x, @y + y_delta)

      @y += y_delta
      @moving = true
      @direction = y_delta.positive? ? :down : :up
    end

    def move_horizontal!
      x_delta = 0
      x_delta -= speed if left_control?
      x_delta += speed if right_control?
      return unless x_delta != 0 && can_move_to?(@x + x_delta, @y)

      @x += x_delta
      @moving = true
      @direction = x_delta.positive? ? :right : :left
    end

    def can_move_to?(target_x, target_y)
      @map.entities.none? do |entity|
        next unless entity.is_a?(Blockable)
        next if entity.is_a?(Bomb) && collide?(entity, @x, @y)

        collide?(entity, target_x, target_y)
      end
    end

    def check_collisions!
      fire_collisions!
      item_collisions!
    end

    def item_collisions!
      return unless (item = @map.entities.find { |e| e.is_a?(Item) && collide?(e, @x, @y) })

      send(ITEM_METHOD_MAPPING[item.class])
      @map.entities.delete(item)
    end

    def increase_bomb_capacity!
      @bomb_capacity += 1 unless @bomb_capacity >= MAX_BOMB_CAPACITY
    end

    def increase_bomb_radius!
      @bomb_radius += 1 unless @bomb_radius >= MAX_BOMB_RADIUS
    end

    def increase_speed!
      @speed += 0.2
    end

    def trigger_skull_effect!
      @skull_effect = Skull::EFFECTS.sample
      @skull_effect_started_at = Gosu.milliseconds
    end

    def fire_collisions!
      return unless @map.entities.any? { |e| e.is_a?(Fire) && collide?(e, @x, @y) }

      @map.players.delete(self)
    end

    def cancel_skull_effect!
      return unless @skull_effect_started_at && @skull_effect_started_at + SKULL_EFFECT_DURATION_MS < Gosu.milliseconds

      @skull_effect = @skull_effect_started_at = nil
    end

    def execute_actions!
      drop_bomb! if bomb_control?
    end

    def bomb_capacity_reached?
      @skull_effect == :constipation || @map.entities.count { |e| e.is_a?(Bomb) && e.player == self } >= bomb_capacity
    end

    def drop_bomb!
      return if bomb_capacity_reached?
      return if @map.entities.any? do |e|
                  e.is_a?(Bomb) &&
                  grid_collide?(e, center_grid_coord[:x], center_grid_coord[:y])
                end

      @map.entities << Bomb.new(grid_x: center_grid_coord[:x], grid_y: center_grid_coord[:y], map: @map, player: self)
    end
  end
end
