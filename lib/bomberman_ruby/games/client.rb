# frozen_string_literal: true

module BombermanRuby
  module Games
    class Client < Base
      NETWORK_INSTRUCTIONS = {
        input_connection: 0,
        input_data: 1,
      }.freeze

      attr_reader :socket

      def initialize(_)
        super
        @step = Steps::Menus::Client.new(game: self)
        initialize_socket
      end

      def update
        send_inputs
        super
      end

      private

      def send_inputs
        @inputs.each do |input|
          @socket.send([NETWORK_INSTRUCTIONS[:input_data], input.host_input_id, input.bitfield].pack("C3"), 0)
        end
      end

      def initialize_socket
        @socket = UDPSocket.new(Socket::AF_INET6)
        @socket.connect(@options[:server_ip], @options[:server_port])
        @inputs.each do |input|
          connect_input(input)
        end
      end

      def wait_for_input_id
        loop do
          msg, = @socket.recvfrom_nonblock(2)
          instruction, data = msg.unpack("C2")
          break data if instruction == Games::Host::NETWORK_INSTRUCTIONS[:input_connected]
        rescue IO::EAGAINWaitReadable
          retry
        end
      end

      def connect_input(input)
        @socket.send([NETWORK_INSTRUCTIONS[:input_connection]].pack("C"), 0)
        input.host_input_id = wait_for_input_id
      end
    end
  end
end
