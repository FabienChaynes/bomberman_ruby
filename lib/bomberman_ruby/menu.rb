# frozen_string_literal: true

module BombermanRuby
  class Menu < Step
    BACKGROUND = Gosu::Image.new("#{__dir__}/../../assets/images/menu_background.png")
    MAP_ICON_WIDTH = 60
    MAP_ICON_HEIGHT = 60
    MAP_ICONS = Gosu::Image.load_tiles(
      "#{__dir__}/../../assets/images/map_icons.png",
      MAP_ICON_WIDTH,
      MAP_ICON_HEIGHT
    ).freeze
    MAP_NAMES = [
      "Standard",
      "Hi Power",
      "Conveyor",
      "Slippage",
      "Landmine",
      "Pipe Bomb",
      "Curvage",
      "Moon Warp",
    ].freeze
    MAP_COUNT = 2
    MAP_CHANGE_DELAY = 250
    FONT_SIZE = 10
    FONT = Gosu::Font.new(FONT_SIZE)
    DESERIALIZABLE_CLASSES = [
      "BombermanRuby::LocalInput",
      "BombermanRuby::NetworkInput",
    ].freeze
    MENU_SONG = Gosu::Song.new("#{__dir__}/../../assets/sound/menu.mp3").freeze

    def initialize(game:)
      super
      @inputs = []
      @current_map_index = 0
      MENU_SONG.play(true)
    end

    def update # rubocop:disable Metrics/MethodLength
      if @game.is_a?(HostGame)
        @inputs = @game.inputs
        if @inputs[0]&.start?
          launch_map
        else
          update_map_selection
          send_inputs
        end
      else
        update_menu_state
      end
    end

    def draw
      BACKGROUND.draw(0, 0, 0)
      @inputs[0..3].each_with_index do |input, i|
        sprite_index = input.is_a?(NetworkInput) ? 9 : 0
        Player::SPRITES[sprite_index + (Player::SPRITE_COUNT * i)].draw(i * (Player::SPRITE_WIDTH + 5), 1)
      end
      text = @game.is_a?(HostGame) ? "Press start to launch the game" : "Waiting for the host to start the game"
      draw_map_selection if @game.is_a?(HostGame)
      FONT.draw_text(text, 0, Window::HEIGHT - FONT_SIZE, 1, 1, 1, 0xff_000000)
    end

    private

    def draw_map_selection
      map_icon_x = (Window::WIDTH / 2) - (MAP_ICON_WIDTH / 2)
      map_icon_y = (Window::HEIGHT / 2) - (MAP_ICON_HEIGHT / 2)
      map_name = MAP_NAMES[@current_map_index]
      map_name_x = (Window::WIDTH / 2) - (FONT.text_width(map_name) / 2)
      FONT.draw_text(map_name, map_name_x, map_icon_y - FONT_SIZE, 1, 1, 1, 0xff_000000)
      MAP_ICONS[@current_map_index].draw(map_icon_x, map_icon_y, 2)
    end

    def update_map_selection # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      return unless !@map_changed_at || @map_changed_at + MAP_CHANGE_DELAY < Gosu.milliseconds
      return unless @inputs[0]&.right? || @inputs[0]&.left?

      @map_changed_at = Gosu.milliseconds
      @current_map_index += 1 if @inputs[0]&.right?
      @current_map_index -= 1 if @inputs[0]&.left?
      @current_map_index = MAP_COUNT - 1 if @current_map_index.negative?
      @current_map_index = 0 if @current_map_index >= MAP_COUNT
    end

    def launch_map
      @game.step = Map.new(game: @game, index: @current_map_index)
      @game.client_sockets.each do |_k, s|
        @game.socket.send([0, @current_map_index.to_s].pack("CA"), 0, s[:ip], s[:port])
      end
    end

    def update_menu_state
      instruction, data = read_socket
      return unless instruction == 1

      @inputs = []
      inputs = MessagePack.unpack(Zlib::Inflate.inflate(data))
      inputs.each do |e|
        @inputs << Object.const_get(e["class"]).deserialize(e) if DESERIALIZABLE_CLASSES.include?(e["class"])
      end
    end

    def send_inputs
      inputs = @inputs.map(&:serialize).to_msgpack
      compressed_inputs = Zlib::Deflate.deflate(inputs)
      @game.client_sockets.each do |_k, s|
        @game.socket.send([1, compressed_inputs].pack("Ca*"), 0, s[:ip], s[:port])
      end
    end

    def read_socket
      instruction = data = nil
      begin
        loop do
          msg, = @game.socket.recvfrom_nonblock(10_000)
          instruction, data = msg.unpack("Ca*")
          @game.step = Map.new(game: @game, index: data.to_i) if instruction.zero?
        end
      rescue IO::EAGAINWaitReadable
        # Do nothing
      end
      return [instruction, data] if !data&.empty? && @game.step.is_a?(Menu)
    end
  end
end
