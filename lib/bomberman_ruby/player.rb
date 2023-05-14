# frozen_string_literal: true

module BombermanRuby
  class Player < Entity
    PLAYER_Z = 10
    SPRITE_REFRESH_RATE = 200
    SPRITES = Gosu::Image.load_tiles(
      "#{__dir__}/../../assets/images/player.png",
      15,
      22
    ).freeze
    WALKING_DOWN_SPRITES = [SPRITES[0], SPRITES[1], SPRITES[0], SPRITES[2]].freeze
    WALKING_LEFT_SPRITES = [SPRITES[6], SPRITES[7], SPRITES[6], SPRITES[8]].freeze
    WALKING_UP_SPRITES = [SPRITES[12], SPRITES[13], SPRITES[12], SPRITES[14]].freeze

    def draw
      WALKING_DOWN_SPRITES[(Gosu.milliseconds / SPRITE_REFRESH_RATE) % WALKING_DOWN_SPRITES.size].draw(@x, @y, PLAYER_Z)
    end
  end
end
