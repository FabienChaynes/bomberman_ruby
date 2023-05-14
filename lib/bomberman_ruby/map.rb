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

    attr_accessor :entities, :players

    def initialize
      @map_background = MAP_BACKGROUNDS[0]
      @map_path = "#{__dir__}/../../assets/maps/1.txt"
      @entities = []
      @players = [Player.new(grid_x: 1, grid_y: 0, map: self)]
      load!
    end

    def update
      @players.each(&:update)
      @entities.each(&:update)
    end

    def draw
      @map_background.draw(0, 0, BACKGROUND_Z)
      @entities.each(&:draw)
      @players.each(&:draw)
    end

    private

    def load!
      lines = File.read(@map_path).split("\n").map(&:chars)
      lines.each_with_index do |line, y|
        line.each_with_index do |c, x|
          @entities << CHARS_MAPPING[c].new(grid_x: x, grid_y: y, map: self) if CHARS_MAPPING.key?(c)
        end
      end
    end
  end
end
