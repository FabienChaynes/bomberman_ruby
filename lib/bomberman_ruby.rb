# frozen_string_literal: true

require "gosu"
require "yaml"

require_relative "bomberman_ruby/version"
require_relative "bomberman_ruby/window"
require_relative "bomberman_ruby/game"
require_relative "bomberman_ruby/input"
require_relative "bomberman_ruby/entity"
require_relative "bomberman_ruby/blockable"
require_relative "bomberman_ruby/burnable"
require_relative "bomberman_ruby/block"
require_relative "bomberman_ruby/hard_block"
require_relative "bomberman_ruby/bomb"
require_relative "bomberman_ruby/fire"
require_relative "bomberman_ruby/item"
require_relative "bomberman_ruby/bomb_up"
require_relative "bomberman_ruby/fire_up"
require_relative "bomberman_ruby/speed_up"
require_relative "bomberman_ruby/skull"
require_relative "bomberman_ruby/player"
require_relative "bomberman_ruby/soft_block"
require_relative "bomberman_ruby/map"

module BombermanRuby
  class Error < StandardError; end

  def self.start
    BombermanRuby::Window.new.show
  end
end
