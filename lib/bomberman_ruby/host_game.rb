# frozen_string_literal: true

module BombermanRuby
  class HostGame < Game
    DEFAULT_PORT = 64_177

    attr_reader :socket, :client_sockets

    def initialize
      super
      initialize_socket
    end

    def update
      read_socket
      @map = Map.new(game: self) if Gosu.button_down?(Gosu::KB_SPACE)
      super
    end

    private

    def initialize_socket
      @socket = UDPSocket.new(Socket::AF_INET6)
      @socket.bind("::", DEFAULT_PORT)
      @client_sockets = {}
    end

    def read_socket
      @inputs.select { |i| i.is_a?(NetworkInput) }.each { |i| i.inputs_bitfield = LocalInput::NULL_BYTE }
      begin
        loop do
          read_next_msg
        end
      rescue IO::EAGAINWaitReadable
        # Do nothing
      end
    end

    def read_next_msg
      tmp_msg, sending_socket = @socket.recvfrom_nonblock(8)
      input_id, inputs_bitfield = tmp_msg.unpack("C2")
      if input_id.zero?
        add_new_client(sending_socket)
      elsif @client_sockets[input_id]
        @inputs[input_id - 1].inputs_bitfield = inputs_bitfield
      end
    end

    def add_new_client(sending_socket)
      input_id = @inputs.count + 1 # input_id must be > 0
      client_socket = { ip: sending_socket[3], port: sending_socket[1] }
      @client_sockets[input_id] = client_socket
      @socket.send([input_id].pack("C"), 0, client_socket[:ip], client_socket[:port])
      @inputs << NetworkInput.new
    end
  end
end