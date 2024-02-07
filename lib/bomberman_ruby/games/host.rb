# frozen_string_literal: true

module BombermanRuby
  module Games
    class Host < Base
      DEFAULT_PORT = 64_177
      NETWORK_INSTRUCTIONS = {
        input_connected: 0,
        step: 1,
        entities: 2,
      }.freeze

      attr_reader :socket, :client_sockets
      attr_writer :step

      def initialize(_)
        super
        @step = Steps::Menus::Host.new(game: self)
        initialize_socket
      end

      def update
        read_socket
        super
      end

      private

      def initialize_socket
        @client_sockets = Set.new
        return if @options[:local_only]

        @socket = UDPSocket.new(Socket::AF_INET6)
        @socket.bind("::", @options[:server_port])
      end

      def read_socket
        return unless @socket

        loop do
          process_next_msg
        end
      rescue IO::EAGAINWaitReadable
        # Do nothing
      end

      def process_next_msg
        msg, sending_socket = @socket.recvfrom_nonblock(3)
        instruction, input_id, inputs_bitfield = msg.unpack("C3")
        if instruction == Games::Client::NETWORK_INSTRUCTIONS[:input_connection]
          add_new_client(sending_socket)
        elsif instruction == Games::Client::NETWORK_INSTRUCTIONS[:input_data] &&
              @inputs[input_id].is_a?(Inputs::Network)
          @inputs[input_id].inputs_bitfield = inputs_bitfield
        end
      end

      def add_new_client(sending_socket)
        input_id = @inputs.count
        client_socket = { ip: sending_socket[3], port: sending_socket[1] }
        @client_sockets << client_socket
        @socket.send([NETWORK_INSTRUCTIONS[:input_connected], input_id].pack("C2"), 0,
                     client_socket[:ip], client_socket[:port])
        @inputs << Inputs::Network.new
      end
    end
  end
end
