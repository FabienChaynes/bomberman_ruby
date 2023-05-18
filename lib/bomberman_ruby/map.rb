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
