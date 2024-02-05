# frozen_string_literal: true

require "gosu"
require "msgpack"
require "optparse"
require "socket"
require "yaml"
require "zlib"

require_relative "bomberman_ruby/version"
require_relative "bomberman_ruby/window"
require_relative "bomberman_ruby/games/base"
require_relative "bomberman_ruby/games/host"
require_relative "bomberman_ruby/games/client"
require_relative "bomberman_ruby/inputs/base"
require_relative "bomberman_ruby/inputs/local"
require_relative "bomberman_ruby/inputs/network"
require_relative "bomberman_ruby/starting_position"
require_relative "bomberman_ruby/entities/concerns/debuggable"
require_relative "bomberman_ruby/entities/concerns/serializable"
require_relative "bomberman_ruby/entities/base"
require_relative "bomberman_ruby/entities/concerns/blockable"
require_relative "bomberman_ruby/entities/concerns/burnable"
require_relative "bomberman_ruby/entities/concerns/conveyor_movable"
require_relative "bomberman_ruby/entities/concerns/bomb/throwable"
require_relative "bomberman_ruby/entities/concerns/bomb/explodeable"
require_relative "bomberman_ruby/entities/concerns/bomb/kickable"
require_relative "bomberman_ruby/entities/blocks/base"
require_relative "bomberman_ruby/entities/blocks/hard"
require_relative "bomberman_ruby/entities/bomb"
require_relative "bomberman_ruby/entities/fire"
require_relative "bomberman_ruby/entities/items/base"
require_relative "bomberman_ruby/entities/items/bomb_up"
require_relative "bomberman_ruby/entities/items/fire_up"
require_relative "bomberman_ruby/entities/items/speed_up"
require_relative "bomberman_ruby/entities/items/skull"
require_relative "bomberman_ruby/entities/items/kick"
require_relative "bomberman_ruby/entities/items/punch"
require_relative "bomberman_ruby/entities/items/line_bomb"
require_relative "bomberman_ruby/entities/concerns/player/collisions"
require_relative "bomberman_ruby/entities/concerns/player/sound"
require_relative "bomberman_ruby/entities/concerns/player/sprite"
require_relative "bomberman_ruby/entities/concerns/player/bonus"
require_relative "bomberman_ruby/entities/concerns/player/movement"
require_relative "bomberman_ruby/entities/concerns/player/bomb_actions"
require_relative "bomberman_ruby/entities/player"
require_relative "bomberman_ruby/entities/blocks/soft"
require_relative "bomberman_ruby/entities/buttons/base"
require_relative "bomberman_ruby/entities/buttons/speed_change"
require_relative "bomberman_ruby/entities/buttons/rotation_change"
require_relative "bomberman_ruby/entities/conveyors/base"
require_relative "bomberman_ruby/entities/conveyors/right"
require_relative "bomberman_ruby/entities/conveyors/left"
require_relative "bomberman_ruby/entities/conveyors/up"
require_relative "bomberman_ruby/entities/conveyors/down"
require_relative "bomberman_ruby/entities/conveyors/bottom_right"
require_relative "bomberman_ruby/entities/conveyors/bottom_left"
require_relative "bomberman_ruby/entities/conveyors/top_left"
require_relative "bomberman_ruby/entities/conveyors/top_right"
require_relative "bomberman_ruby/steps/concerns/hosts/networkable"
require_relative "bomberman_ruby/steps/concerns/clients/networkable"
require_relative "bomberman_ruby/steps/base"
require_relative "bomberman_ruby/steps/menus/base"
require_relative "bomberman_ruby/steps/menus/host"
require_relative "bomberman_ruby/steps/menus/client"
require_relative "bomberman_ruby/steps/concerns/maps/file_parsing"
require_relative "bomberman_ruby/steps/maps/base"
require_relative "bomberman_ruby/steps/maps/host"
require_relative "bomberman_ruby/steps/maps/client"

module BombermanRuby
  class Error < StandardError; end

  class << self
    def start
      options = parse_options
      BombermanRuby::Window.new(options).show
    end

    private

    def parse_options # rubocop:disable Metrics/MethodLength
      options = {
        server_port: Games::Host::DEFAULT_PORT,
      }
      OptionParser.new do |opts|
        opts.banner = "Usage: bomberman [options]"

        opts.on(
          "-sIP",
          "--server-ip IP",
          String,
          "Server IP to connect to. If not provided, the game will be hosted on this machine."
        ) do |s|
          options[:server_ip] = s
        end
        opts.on("-pPORT", "--server-port PORT", Integer,
                "Server port (default: #{Games::Host::DEFAULT_PORT})") do |port|
          options[:server_port] = port
        end
        opts.on(
          "-cPATH",
          "--config-file PATH",
          String,
          'Config file path (default: "config/inputs.yml" then "config/inputs.yml.example")'
        ) do |c|
          options[:config_file] = c
        end
        opts.on("-nCOUNT", "--player-number COUNT", Integer, "Number of local players") do |n|
          options[:player_number] = n
        end
      end.parse!

      options
    end
  end
end
