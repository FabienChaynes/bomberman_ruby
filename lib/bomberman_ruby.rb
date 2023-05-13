# frozen_string_literal: true

require_relative "bomberman_ruby/version"
require_relative "bomberman_ruby/window"
require_relative "bomberman_ruby/soft_block"
require_relative "bomberman_ruby/map"

module BombermanRuby
  class Error < StandardError; end
  # Your code goes here...
end

BombermanRuby::Window.new.show
