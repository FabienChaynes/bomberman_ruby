# frozen_string_literal: true

module BombermanRuby
  class ClientGame < Game
    attr_reader :socket

    def initialize
      super
      initialize_socket
      @map = Map.new(game: self)
    end

    def update
      send_inputs
      super
    end

    private

    def send_inputs
      @inputs.each do |input|
        inputs_bitfield = input.bitfield
        next if inputs_bitfield == LocalInput::NULL_BYTE

        @socket.send([input.host_input_id, inputs_bitfield].pack("C2"), 0)
      end
    end

    def initialize_socket
      @socket = UDPSocket.new(Socket::AF_INET6)
      @socket.connect(ARGV[0], HostGame::DEFAULT_PORT)
      @inputs.each do |input|
        connect_input(input)
      end
    end

    def connect_input(input)
      @socket.send([0, LocalInput::NULL_BYTE].pack("C2"), 0)
      begin
        msg, = @socket.recvfrom_nonblock(1)
        input.host_input_id = msg.unpack1("C")
      rescue IO::EAGAINWaitReadable
        retry
      end
    end
  end
end
