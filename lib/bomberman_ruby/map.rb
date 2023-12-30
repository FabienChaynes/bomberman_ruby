# frozen_string_literal: true

module BombermanRuby
  class Map < Step
    BACKGROUND_Z = 0
    CHARS_MAPPING = {
      "s" => SoftBlock,
      "x" => HardBlock,
    }.freeze
    MAP_BACKGROUNDS = Gosu::Image.load_tiles("#{__dir__}/../../assets/images/maps.png", 240, 160).freeze
    VERTICAL_MARGIN = 8
    DESERIALIZABLE_CLASSES = [
      "BombermanRuby::Player",
      "BombermanRuby::SoftBlock",
      "BombermanRuby::Bomb",
      "BombermanRuby::Fire",
      "BombermanRuby::BombUp",
      "BombermanRuby::FireUp",
      "BombermanRuby::SpeedUp",
      "BombermanRuby::Skull",
    ].freeze
    CONFIG_ITEM_MAPPING = {
      "bomb_ups" => :bomb_up,
      "fire_ups" => :fire_up,
      "speed_ups" => :speed_up,
      "skulls" => :skull,
    }.freeze
    BATTLE_MODE_SONG = Gosu::Song.new("#{__dir__}/../../assets/sound/battle_mode.mp3").freeze
    END_ROUND_DURATION_MS = 4_000

    attr_accessor :entities, :players

    def initialize(game:)
      super
      @map_background = MAP_BACKGROUNDS[0]
      @map_path = "#{__dir__}/../../assets/maps/1.txt"
      @map_config_path = "#{__dir__}/../../assets/maps/1.yml"
      @entities = []
      @players = []
      @starting_positions = {}
      load! if @game.is_a?(HostGame)
      BATTLE_MODE_SONG.play(true)
    end

    def update
      if @game.is_a?(HostGame)
        @players.each(&:update)
        @players.delete_if(&:deletable?)
        @entities.each(&:update)
        check_end_round
        send_map
      else
        read_map
      end
    end

    def draw
      @map_background.draw(0, 0, BACKGROUND_Z)
      Gosu.translate(0, VERTICAL_MARGIN - Window::SPRITE_SIZE) do
        @entities.each(&:draw)
        @players.each(&:draw)
      end
    end

    private

    def read_map
      return unless (msg = last_socket_msg)

      entities = MessagePack.unpack(Zlib::Inflate.inflate(msg))
      @entities = []
      @players = []
      entities.each do |e|
        @entities << Object.const_get(e["class"]).deserialize(self, e) if DESERIALIZABLE_CLASSES.include?(e["class"])
      end
    end

    def read_socket
      msg, = @game.socket.recvfrom_nonblock(10_000)
      msg.unpack("Ca*")
    end

    def last_socket_msg
      entities = nil
      begin
        loop do
          instruction, data = read_socket
          @game.step = Menu.new(game: @game) if [instruction, data] == [0, "0"]
          entities = data if instruction == 1
        end
      rescue IO::EAGAINWaitReadable
        # Do nothing
      end
      entities
    end

    def send_map
      map_entities = (@entities.map(&:serialize) + @players.map(&:serialize)).to_msgpack
      compressed_map_entities = Zlib::Deflate.deflate(map_entities)
      @game.client_sockets.each do |_k, s|
        @game.socket.send([1, compressed_map_entities].pack("Ca*"), 0, s[:ip], s[:port])
      end
    end

    def load!
      lines = File.read(@map_path).split("\n").map(&:chars)
      lines.each_with_index do |line, y|
        line.each_with_index do |c, x|
          @entities << CHARS_MAPPING[c].new(grid_x: x, grid_y: y, map: self) if CHARS_MAPPING.key?(c)
          @starting_positions[c.to_i] = StartingPosition.new(grid_x: x, grid_y: y) if ("0".."3").include?(c)
        end
      end
      load_items!
      load_players!
    end

    def config
      @config ||= YAML.load(File.read(@map_config_path))
    end

    def delete_extra_soft_blocks!
      shuffled_soft_blocks = @entities.select { |e| e.is_a?(SoftBlock) }.shuffle
      shuffled_soft_blocks.pop(config["soft_blocks"])
      @entities.delete_if { |e| shuffled_soft_blocks.include?(e) }
    end

    def load_items!
      delete_extra_soft_blocks!
      shuffled_soft_blocks = @entities.select { |e| e.is_a?(SoftBlock) }.shuffle
      CONFIG_ITEM_MAPPING.each do |config_key, item|
        config[config_key].times { shuffled_soft_blocks.pop.item = item }
      end
    end

    def load_players!
      @starting_positions.count.times do |i|
        next unless @game.inputs[i]

        @players << Player.new(
          grid_x: @starting_positions[i].grid_x,
          grid_y: @starting_positions[i].grid_y,
          map: self,
          input: @game.inputs[i],
          id: i
        )
      end
    end

    def end_round(winning_player)
      return if @ended_at

      @ended_at = Gosu.milliseconds
      return unless winning_player

      winning_player.winning = true
      winning_player.sound = :winning
    end

    def check_end_round
      alive_players = @players.reject(&:dead?)
      return unless alive_players.count <= 1

      end_round(alive_players.first)
      return if Gosu.milliseconds < @ended_at + END_ROUND_DURATION_MS

      @game.step = Menu.new(game: @game)
      @game.client_sockets.each do |_k, s|
        @game.socket.send([0, "0"].pack("CA"), 0, s[:ip], s[:port])
      end
    end
  end
end
