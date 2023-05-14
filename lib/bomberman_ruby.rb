# frozen_string_literal: true

require_relative "bomberman_ruby/version"
require_relative "bomberman_ruby/window"
require_relative "bomberman_ruby/entity"
require_relative "bomberman_ruby/blockable"
require_relative "bomberman_ruby/burnable"
require_relative "bomberman_ruby/block"
require_relative "bomberman_ruby/hard_block"
require_relative "bomberman_ruby/soft_block"
require_relative "bomberman_ruby/player"
require_relative "bomberman_ruby/bomb"
require_relative "bomberman_ruby/fire"
require_relative "bomberman_ruby/map"

module BombermanRuby
  class Error < StandardError; end
  # Your code goes here...
end

BombermanRuby::Window.new.show
