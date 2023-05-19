# frozen_string_literal: true

module BombermanRuby
  class Map
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

    attr_accessor :entities, :players

    def initialize(game:)
      @game = game
      @map_background = MAP_BACKGROUNDS[0]
      @map_path = "#{__dir__}/../../assets/maps/1.txt"
      @entities = []
      @players = []
      @starting_positions = {}
      load!
    end

    def update
      if @game.is_a?(HostGame)
        @players.each(&:update)
        @entities.each(&:update)
        send_map
      else
        read_map
      end
    end

    def draw
      @map_background.draw(0, 0, BACKGROUND_Z)
      @entities.each(&:draw)
      @players.each(&:draw)
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

    def last_socket_msg
      msg = nil
      begin
        loop do
          msg, = @game.socket.recvfrom_nonblock(10_000)
        end
      rescue IO::EAGAINWaitReadable
        # Do nothing
      end
      msg
    end

    def send_map
      @game.client_sockets.each do |_k, s|
        map_entities = (@entities.map(&:serialize) + @players.map(&:serialize)).to_msgpack
        compressed_map_entities = Zlib::Deflate.deflate(map_entities)
        @game.socket.send(compressed_map_entities, 0, s[:ip], s[:port])
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

    def load_items!
      soft_blocks = @entities.select { |e| e.is_a?(SoftBlock) }.shuffle
      8.times { soft_blocks.pop.item = :bomb_up }
      8.times { soft_blocks.pop.item = :fire_up }
      4.times { soft_blocks.pop.item = :speed_up }
      soft_blocks.pop.item = :skull
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
  end
end
