# frozen_string_literal: true

module BombermanRuby
  class Player < Entity
    PLAYER_Z = 10

    SPRITE_COUNT = 12
    SPRITE_WIDTH = 17
    SPRITE_HEIGHT = 24
    SPRITES = Gosu::Image.load_tiles(
      "#{__dir__}/../../assets/images/player.png",
      SPRITE_WIDTH,
      SPRITE_HEIGHT
    ).freeze

    DEATH_SPRITE_COUNT = 4
    DEATH_SPRITE_WIDTH = 23
    DEATH_SPRITE_HEIGHT = 20
    DEATH_SPRITES = Gosu::Image.load_tiles(
      "#{__dir__}/../../assets/images/dead_player.png",
      DEATH_SPRITE_WIDTH,
      DEATH_SPRITE_HEIGHT
    ).freeze

    WALKING_DOWN_SPRITE_INDEXES = [0, 1, 0, 2].freeze
    WALKING_LEFT_SPRITE_INDEXES = [3, 4, 3, 5].freeze
    WALKING_UP_SPRITE_INDEXES = [6, 7, 6, 8].freeze
    WINNING_SPRITE_INDEXES = [0, 9].freeze
    DEATH_SPRITE_INDEXES = [0, 1, 2, 3].freeze
    STUNNED_SPRITE_INDEXES = [10, 11].freeze

    MAX_BOMB_CAPACITY = 5
    MAX_BOMB_RADIUS = 9
    SKULL_EFFECT_DURATION_MS = 10_000
    STUNNED_DURATION_MS = 1_000
    SKULL_EFFECT_COLORS = [
      Gosu::Color.new(0xff_ffffff),
      Gosu::Color.new(0xff_cccccc),
      Gosu::Color.new(0xff_999999),
      Gosu::Color.new(0xff_666666),
      Gosu::Color.new(0xff_333333),
      Gosu::Color.new(0xff_666666),
      Gosu::Color.new(0xff_999999),
      Gosu::Color.new(0xff_cccccc),
    ].freeze
    ITEM_METHOD_MAPPING = {
      BombermanRuby::BombUp => :increase_bomb_capacity!,
      BombermanRuby::FireUp => :increase_bomb_radius!,
      BombermanRuby::SpeedUp => :increase_speed!,
      BombermanRuby::Skull => :trigger_skull_effect!,
    }.freeze
    ITEM_SAMPLE = Gosu::Sample.new("#{__dir__}/../../assets/sound/item.wav").freeze
    DROPPED_BOMB_SAMPLE = Gosu::Sample.new("#{__dir__}/../../assets/sound/bomb_dropped.wav").freeze
    ROUND_VICTORY_SAMPLE = Gosu::Sample.new("#{__dir__}/../../assets/sound/round_victory.wav").freeze
    DEATH_DURATION_MS = SPRITE_REFRESH_RATE * DEATH_SPRITE_COUNT

    attr_accessor :skull_effect
    attr_writer :direction, :moving, :sound, :winning, :dead_at, :current_death_sprite, :stunned_at

    def initialize(args) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      @input = args.delete(:input)
      @id = args.delete(:id)
      @bomb_capacity = args.delete(:starting_bomb_capacity) || 1
      @bomb_radius = args.delete(:starting_bomb_radius) || 1
      @speed = args.delete(:starting_speed) || 1
      @kick = args.delete(:starting_kick) || false
      @line_bomb = args.delete(:starting_line_bomb) || false
      super(**args)
      @y = (args[:grid_y] * Window::SPRITE_SIZE) - (hitbox[:down] - Window::SPRITE_SIZE)
      @direction = :down
      @moving = @winning = @bomb_control_released = false
      @current_death_sprite = 0
    end

    def serialize # rubocop:disable Metrics/MethodLength
      super.merge({
                    id: @id,
                    direction: @direction,
                    moving: @moving,
                    skull_effect: @skull_effect,
                    sound: @sound,
                    winning: @winning,
                    dead_at: @dead_at,
                    current_death_sprite: @current_death_sprite,
                    stunned_at: @stunned_at,
                  })
    end

    def self.deserialize(map, data) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      entity = new(grid_x: 0, grid_y: 0, map:, id: data["id"])
      entity.x = data["x"]
      entity.y = data["y"]
      entity.moving = data["moving"]
      entity.winning = data["winning"]
      entity.skull_effect = data["skull_effect"]
      entity.dead_at = data["dead_at"]
      entity.stunned_at = data["stunned_at"]
      entity.current_death_sprite = data["current_death_sprite"]
      entity.sound = data["sound"]&.to_sym
      entity.direction = data["direction"].to_sym
      entity
    end

    def update
      reset_sound!
      set_death_sprite if dead?
      return if @winning || dead?

      move!
      check_collisions!
      cancel_skull_effect!
      cancel_stun!
      execute_actions!
    end

    def draw # rubocop:disable Metrics/MethodLength
      scale_x = 1
      draw_x = @x
      draw_y = @y
      if dead?
        draw_x -= (DEATH_SPRITE_WIDTH - SPRITE_WIDTH) / 2
        draw_y -= (DEATH_SPRITE_HEIGHT - SPRITE_HEIGHT) / 2
      elsif @direction == :right
        scale_x = -1
        draw_x += SPRITE_WIDTH
      end
      current_sprite.draw(draw_x, draw_y, PLAYER_Z, scale_x, 1, sprite_color)
      play_sound
      # debug_hitbox
    end

    def bounced_on
      @stunned_at = Gosu.milliseconds
    end

    def hitbox
      {
        up: 14,
        down: 24,
        left: 2,
        right: 15,
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

    def dead?
      !!@dead_at
    end

    def deletable?
      @dead_at && Gosu.milliseconds > @dead_at + DEATH_DURATION_MS
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

    def walking_down_sprites
      @walking_down_sprites ||= WALKING_DOWN_SPRITE_INDEXES.map { |i| SPRITES[(@id * SPRITE_COUNT) + i] }
    end

    def walking_up_sprites
      @walking_up_sprites ||= WALKING_UP_SPRITE_INDEXES.map { |i| SPRITES[(@id * SPRITE_COUNT) + i] }
    end

    def walking_left_sprites
      @walking_left_sprites ||= WALKING_LEFT_SPRITE_INDEXES.map { |i| SPRITES[(@id * SPRITE_COUNT) + i] }
    end

    def winning_sprites
      @winning_sprites ||= WINNING_SPRITE_INDEXES.map { |i| SPRITES[(@id * SPRITE_COUNT) + i] }
    end

    def death_sprites
      @death_sprites ||= DEATH_SPRITE_INDEXES.map { |i| DEATH_SPRITES[(@id * DEATH_SPRITE_COUNT) + i] }
    end

    def stunned_sprites
      @stunned_sprites ||= STUNNED_SPRITE_INDEXES.map { |i| SPRITES[(@id * SPRITE_COUNT) + i] }
    end

    def current_death_sprite
      death_sprites[@current_death_sprite]
    end

    def current_stunned_sprite
      stunned_sprites[(Gosu.milliseconds / SPRITE_REFRESH_RATE) % stunned_sprites.size]
    end

    def walking_sprites
      case @direction
      when :down
        walking_down_sprites
      when :up
        walking_up_sprites
      when :left, :right
        walking_left_sprites
      end
    end

    def current_sprite
      return current_death_sprite if dead?
      return current_stunned_sprite if stunned?

      sprites = @winning ? winning_sprites : walking_sprites
      if @moving || @winning
        sprites[(Gosu.milliseconds / SPRITE_REFRESH_RATE) % sprites.size]
      else
        sprites.first
      end
    end

    def set_death_sprite
      @current_death_sprite = ((Gosu.milliseconds - @dead_at) / SPRITE_REFRESH_RATE).clamp(0, death_sprites.size - 1)
    end

    def sprite_color
      if @skull_effect
        SKULL_EFFECT_COLORS[(Gosu.milliseconds / SPRITE_REFRESH_RATE) % SKULL_EFFECT_COLORS.size]
      else
        Gosu::Color.new(0xff_ffffff)
      end
    end

    def cancel_stun!
      return unless @stunned_at && @stunned_at + STUNNED_DURATION_MS < Gosu.milliseconds

      @stunned_at = nil
    end

    def stunned?
      !!@stunned_at
    end

    def move!
      @moving = false
      return if stunned?

      move_vertical!
      move_horizontal!
    end

    def up_control?
      case @skull_effect
      when :reversal_syndrome
        @input.down?
      else
        @input.up?
      end
    end

    def down_control?
      case @skull_effect
      when :reversal_syndrome
        @input.up?
      else
        @input.down?
      end
    end

    def left_control?
      case @skull_effect
      when :reversal_syndrome
        @input.right?
      else
        @input.left?
      end
    end

    def right_control?
      case @skull_effect
      when :reversal_syndrome
        @input.left?
      else
        @input.right?
      end
    end

    def bomb_control?
      case @skull_effect
      when :diarrhea
        true
      else
        @input.bomb?
      end
    end

    def action_control?
      @input.action?
    end

    def kick_bombs(colliding_entity_list)
      return unless @kick

      colliding_entity_list
        .select { |e| e.is_a?(Bomb) }
        .each { |b| b.direction = @direction }
    end

    def move_vertical! # rubocop:disable Metrics/MethodLength
      y_delta = 0
      y_delta -= speed if up_control?
      y_delta += speed if down_control?
      return unless y_delta != 0

      @direction = y_delta.positive? ? :down : :up
      if (colliding_entity_list = colliding_entities(@x, @y + y_delta)).any?
        kick_bombs(colliding_entity_list)
      else
        @y += y_delta
        @moving = true
      end
    end

    def colliding_entities(_target_x, _target_y)
      super.reject do |e|
        e.is_a?(Bomb) && collide?(e, @x, @y)
      end
    end

    def move_horizontal! # rubocop:disable Metrics/MethodLength
      x_delta = 0
      x_delta -= speed if left_control?
      x_delta += speed if right_control?
      return unless x_delta != 0

      @direction = x_delta.positive? ? :right : :left
      if (colliding_entity_list = colliding_entities(@x + x_delta, @y)).any?
        kick_bombs(colliding_entity_list)
      else
        @x += x_delta
        @moving = true
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
      @sound = :loot_item
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

      @dead_at = Gosu.milliseconds
    end

    def cancel_skull_effect!
      return unless @skull_effect_started_at && @skull_effect_started_at + SKULL_EFFECT_DURATION_MS < Gosu.milliseconds

      @skull_effect = @skull_effect_started_at = nil
    end

    def execute_actions!
      if bomb_control?
        drop_bomb!
      else
        @bomb_control_released = true
      end
      return unless action_control?

      stop_kicked_bombs!
      punch_bomb!
    end

    def punch_bomb! # rubocop:disable Metrics/CyclomaticComplexity
      x_grid_target, y_grid_target = center_grid_coord.values_at(:x, :y)
      x_grid_target -= 1 if @direction == :left
      x_grid_target += 1 if @direction == :right
      y_grid_target -= 1 if @direction == :up
      y_grid_target += 1 if @direction == :down
      @map.entities.each do |e|
        next unless e.is_a?(Bomb)
        next unless grid_collide?(e, x_grid_target, y_grid_target)

        e.punch!(@direction)
      end
    end

    def stop_kicked_bombs!
      bombs.each do |b|
        b.direction = nil
        b.move_to_center!
      end
    end

    def bomb_capacity_reached?
      @skull_effect == :constipation || @map.entities.count { |e| e.is_a?(Bomb) && e.player == self } >= bomb_capacity
    end

    def increment_position(x, y)
      y -= 1 if @direction == :up
      y += 1 if @direction == :down
      x -= 1 if @direction == :left
      x += 1 if @direction == :right
      [x, y]
    end

    def bombs
      @map.entities.select do |e|
        e.is_a?(Bomb) && e.player == self
      end
    end

    def add_bomb_to_map(bomb)
      @map.entities << bomb
    end

    def drop_nex_bomb_in_line!(grid_x, grid_y)
      new_bomb = Bomb.new(grid_x:, grid_y:, map: @map, player: self)
      coords = Entity.grid_coord_to_coord(grid_x, grid_y)
      colliding_entity_list = new_bomb.colliding_entities(coords[:x], coords[:y])
      if colliding_entity_list.reject { |e| e == self }.any?
        return colliding_entity_list.all? { |e| e.is_a?(Bomb) && e.player == self }
      end

      add_bomb_to_map(new_bomb)
      true
    end

    def drop_bomb_line!
      grid_x, grid_y = center_grid_coord.fetch_values(:x, :y)
      until bomb_capacity_reached?
        grid_x, grid_y = increment_position(grid_x, grid_y)
        break unless drop_nex_bomb_in_line!(grid_x, grid_y)
      end
      @sound = :drop_bomb
    end

    def on_bomb?
      @map.entities.any? do |e|
        e.is_a?(Bomb) &&
          grid_collide?(e, center_grid_coord[:x], center_grid_coord[:y])
      end
    end

    def drop_bomb!
      return if bomb_capacity_reached?

      if on_bomb?
        return unless @bomb_control_released

        @bomb_control_released = false
        drop_bomb_line! if @line_bomb
        return
      end
      add_bomb_to_map(Bomb.new(grid_x: center_grid_coord[:x], grid_y: center_grid_coord[:y], map: @map, player: self))
      @bomb_control_released = false
      @sound = :drop_bomb
    end

    def reset_sound!
      @sound = nil
    end

    def play_sound
      case @sound
      when :drop_bomb
        DROPPED_BOMB_SAMPLE.play
      when :loot_item
        ITEM_SAMPLE.play
      when :winning
        ROUND_VICTORY_SAMPLE.play
      end
    end
  end
end
