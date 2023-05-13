# frozen_string_literal: true

require_relative "bomberman_ruby/version"
require_relative "bomberman_ruby/window"

module BombermanRuby
  class Error < StandardError; end
  # Your code goes here...
end

BombermanRuby::Window.new.show
