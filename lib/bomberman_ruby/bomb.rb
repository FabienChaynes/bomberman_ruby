# frozen_string_literal: true

module BombermanRuby
  class Bomb < Entity
    include Blockable
    include Burnable

    BOMB_Z = 5
    BOMB_HYPERACTIVITY_DELAY_MS = 1000
    BOMB_DELAY_MS = 3000
    BOMB_LETHARGY_DELAY_MS = 5000
    SPRITE_REFRESH_RATE = 300
    SPRITES = Gosu::Image.load_tiles(
      "#{__dir__}/../../assets/images/bomb.png",
      Window::SPRITE_SIZE,
      Window::SPRITE_SIZE,
      tileable: true
    ).freeze
    BOMB_SPRITES = SPRITES[0..2]
    FIRE_DIRECTION = {
      left: { x: -1, y: 0 },
      right: { x: 1, y: 0 },
      top: { x: 0, y: -1 },
      bottom: { x: 0, y: 1 },
    }.freeze
    MOVING_SPEED = 2

    HORIZONTAL_PUNCH_MOTION = 16.times.map do |i|
      x = (i + 1) * 3
      y = if i < 6
            (i + 1) * -2
          elsif i > 9
            (-2 * 6) + (2 * (i - 9))
          else
            -2 * 6
          end

      { x:, y: }
    end.freeze
    VERTICAL_PUNCH_MOTION = 16.times.map do |i|
      y = (i + 1) * 3

      { x: 0, y: }
    end.freeze
    HORIZONTAL_BOUNCE_MOTION = [
      { x: 4, y: -8 },
      { x: 8, y: -12 },
      { x: 12, y: -8 },
      { x: 16, y: 0 },
    ].freeze
    VERTICAL_BOUNCE_MOTION = [
      { x: 0, y: 12 },
      { x: 0, y: 10 },
      { x: 0, y: 8 },
      { x: 0, y: 16 },
    ].freeze

    attr_reader :player
    attr_writer :direction

    def initialize(args)
      @player = args.delete(:player)
      super(**args)
      @dropped_at = Gosu.milliseconds
    end

    def update
      move!
      return if Gosu.milliseconds < @dropped_at + bomb_delay

      explode!
    end

    def draw
      BOMB_SPRITES[(Gosu.milliseconds / SPRITE_REFRESH_RATE) % BOMB_SPRITES.size].draw(@x, @y, BOMB_Z)
    end

    def burn!
      explode!
    end

    def colliding_entities(target_x, target_y)
      colliding_players = @map.players.select do |player|
        collide?(player, target_x, target_y)
      end
      colliding_entities_list = super
      colliding_entities_list.delete(self)

      colliding_players + colliding_entities_list
    end

    def punch!(direction)
      return if @direction
      return if @thrown_step

      @thrown_direction = direction
      @thrown_step = 0
      @starting_thrown_position = { x: @x, y: @y }
    end

    private

    def current_motion_step
      case @thrown_direction
      when :left, :right
        @bounce_step ? HORIZONTAL_BOUNCE_MOTION[@bounce_step] : HORIZONTAL_PUNCH_MOTION[@thrown_step]
      else
        @bounce_step ? VERTICAL_BOUNCE_MOTION[@bounce_step] : VERTICAL_PUNCH_MOTION[@thrown_step]
      end
    end

    def wrap_around_map!
      if @x >= Window::WIDTH
        @x = 0
      elsif @x.negative?
        @x = Window::WIDTH - Window::SPRITE_SIZE
      elsif @y > Window::HEIGHT
        @y = 0
      elsif @y.negative?
        @y = Window::HEIGHT
      end
    end

    def end_thrown
      if (colliding_entity_list = colliding_entities(@x, @y)).any?
        colliding_entity_list.each(&:bounced_on)
        @bounce_step = 0
        @starting_thrown_position = { x: @x, y: @y }
      else
        @thrown_direction = @thrown_step = @starting_thrown_position = @bounce_step = nil
      end
    end

    def thrown_move_step
      x_delta, y_delta = current_motion_step.values_at(:x, :y)
      x_delta *= -1 if @thrown_direction == :left
      y_delta *= -1 if @thrown_direction == :up
      @x = @starting_thrown_position[:x] + x_delta
      @y = @starting_thrown_position[:y] + y_delta
      @thrown_step += 1
      @bounce_step += 1 if @bounce_step
    end

    def thrown_move!
      wrap_around_map!
      if current_motion_step
        thrown_move_step
      else
        end_thrown
      end
    end

    def move!
      if @thrown_step
        thrown_move!
        return
      end

      return unless @direction

      move_vertical!
      move_horizontal!
    end

    def move_vertical!
      y_delta = 0
      y_delta -= MOVING_SPEED if @direction == :up
      y_delta += MOVING_SPEED if @direction == :down
      return unless y_delta != 0

      if colliding_entities(@x, @y + y_delta).any?
        @direction = nil
        return
      end
      @y += y_delta
    end

    def move_horizontal!
      x_delta = 0
      x_delta -= MOVING_SPEED if @direction == :left
      x_delta += MOVING_SPEED if @direction == :right
      return unless x_delta != 0

      if colliding_entities(@x + x_delta, @y).any?
        @direction = nil
        return
      end
      @x += x_delta
    end

    def bomb_delay
      case @player.skull_effect
      when :hyperactivity
        BOMB_HYPERACTIVITY_DELAY_MS
      when :lethargy
        BOMB_LETHARGY_DELAY_MS
      else
        BOMB_DELAY_MS
      end
    end

    def explode!
      return if @thrown_direction

      @map.entities.delete(self)
      @map.entities << Fire.new(grid_x: grid_pos[:x], grid_y: grid_pos[:y], map: @map, type: :middle)
      add_radius_fire!(:left)
      add_radius_fire!(:right)
      add_radius_fire!(:top)
      add_radius_fire!(:bottom)
    end

    def add_radius_fire!(direction)
      fire_direction = FIRE_DIRECTION[direction]
      1.upto(@player.bomb_radius) do |current_radius|
        x_delta = current_radius * fire_direction[:x]
        y_delta = current_radius * fire_direction[:y]
        type = current_radius == @player.bomb_radius ? direction : :"middle_#{direction}"
        break unless add_fire!(grid_pos[:x] + x_delta, grid_pos[:y] + y_delta, type)
      end
    end

    def add_fire!(grid_pos_x, grid_pos_y, type)
      blocked = @map.entities.any? { |e| e.is_a?(Blockable) && grid_collide?(e, grid_pos_x, grid_pos_y) }
      burn_entities!(grid_pos_x, grid_pos_y)
      return false if blocked

      if @map.entities.none? { |e| e.is_a?(Fire) && grid_collide?(e, grid_pos_x, grid_pos_y) }
        @map.entities << Fire.new(grid_x: grid_pos_x, grid_y: grid_pos_y, map: @map, type:)
      end
      true
    end

    def burn_entities!(grid_pos_x, grid_pos_y)
      @map.entities.select { |e| e.is_a?(Burnable) && grid_collide?(e, grid_pos_x, grid_pos_y) }.each(&:burn!)
    end
  end
end
