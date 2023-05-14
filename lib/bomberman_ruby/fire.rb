# frozen_string_literal: true

module BombermanRuby
  class Fire < Entity
    EXPLOSION_DURATION_MS = 500
    FIRE_SPRITES = Bomb::SPRITES[3..10]
    FIRE_SPRITES_MAPPING = {
      middle: FIRE_SPRITES[2],
      middle_left: FIRE_SPRITES[1],
      middle_right: FIRE_SPRITES[3],
      middle_top: FIRE_SPRITES[6],
      middle_bottom: FIRE_SPRITES[6],
      left: FIRE_SPRITES[0],
      right: FIRE_SPRITES[4],
      top: FIRE_SPRITES[5],
      bottom: FIRE_SPRITES[7],
    }.freeze

    def initialize(args)
      @type = args.delete(:type)
      super(**args)
      @y += Map::VERTICAL_MARGIN
      @exploded_at = Gosu.milliseconds
    end

    def update
      return if Gosu.milliseconds < @exploded_at + EXPLOSION_DURATION_MS

      @map.entities.delete(self)
    end

    def draw
      sprite.draw(@x, @y, Bomb::BOMB_Z)
    end

    private

    def sprite
      FIRE_SPRITES_MAPPING[@type]
    end
  end
end
