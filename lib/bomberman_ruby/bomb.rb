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
      Window::SPRITE_SIZE
    ).freeze
    BOMB_SPRITES = SPRITES[0..2]
    FIRE_DIRECTION = {
      left: { x: -1, y: 0 },
      right: { x: 1, y: 0 },
      top: { x: 0, y: -1 },
      bottom: { x: 0, y: 1 },
    }.freeze

    attr_reader :player

    def initialize(args)
      @player = args.delete(:player)
      super(**args)
      @dropped_at = Gosu.milliseconds
    end

    def update
      return if Gosu.milliseconds < @dropped_at + bomb_delay

      explode!
    end

    def draw
      BOMB_SPRITES[(Gosu.milliseconds / SPRITE_REFRESH_RATE) % BOMB_SPRITES.size].draw(@x, @y, BOMB_Z)
    end

    def burn!
      explode!
    end

    private

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
