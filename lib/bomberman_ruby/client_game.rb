# frozen_string_literal: true

module BombermanRuby
  class ClientGame < Game
    attr_reader :socket

    def initialize(_)
      super
      initialize_socket
    end

    def update
      send_inputs
      super
    end

    private

    def send_inputs
      @inputs.each do |input|
        @socket.send([input.host_input_id, input.bitfield].pack("C2"), 0)
      end
    end

    def initialize_socket
      @socket = UDPSocket.new(Socket::AF_INET6)
      @socket.connect(@options[:server_ip], @options[:server_port])
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
