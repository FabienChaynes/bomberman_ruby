# frozen_string_literal: true

require "gosu"
require "msgpack"
require "optparse"
require "socket"
require "yaml"
require "zlib"

require_relative "bomberman_ruby/version"
require_relative "bomberman_ruby/window"
require_relative "bomberman_ruby/game"
require_relative "bomberman_ruby/host_game"
require_relative "bomberman_ruby/client_game"
require_relative "bomberman_ruby/input"
require_relative "bomberman_ruby/local_input"
require_relative "bomberman_ruby/network_input"
require_relative "bomberman_ruby/starting_position"
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
require_relative "bomberman_ruby/step"
require_relative "bomberman_ruby/menu"
require_relative "bomberman_ruby/map"

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
        server_port: HostGame::DEFAULT_PORT,
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
        opts.on("-pPORT", "--server-port PORT", Integer, "Server port (default: #{HostGame::DEFAULT_PORT})") do |port|
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
