# frozen_string_literal: true

module BombermanRuby
  class Menu < Step
    BACKGROUND = Gosu::Image.new("#{__dir__}/../../assets/images/menu_background.png")
    FONT_SIZE = 10
    FONT = Gosu::Font.new(FONT_SIZE)
    DESERIALIZABLE_CLASSES = [
      "BombermanRuby::LocalInput",
      "BombermanRuby::NetworkInput",
    ].freeze

    def initialize(game:)
      super
      @inputs = []
    end

    def update
      if @game.is_a?(HostGame)
        @inputs = @game.inputs
        if @inputs[0]&.start?
          launch_map
        else
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
      FONT.draw_text(text, 0, Window::HEIGHT - FONT_SIZE, 1, 1, 1, 0xff_000000)
    end

    private

    def launch_map
      @game.step = Map.new(game: @game)
      @game.client_sockets.each do |_k, s|
        @game.socket.send([0, "1"].pack("CA"), 0, s[:ip], s[:port])
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
          @game.step = Map.new(game: @game) if [instruction, data] == [0, "1"]
        end
      rescue IO::EAGAINWaitReadable
        # Do nothing
      end
      return [instruction, data] if !data&.empty? && @game.step.is_a?(Menu)
    end
  end
end
