require 'socket'
require 'ipaddr'
require 'digest'

module NetworkClipboard
  class Discovery
    attr_reader :receive_socket

    def initialize(config)
      @config = config

      @receive_socket = UDPSocket.new()
      @receive_socket.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, multicast_addr.hton + bind_addr.hton)
      @receive_socket.bind(bind_addr.to_s,port)

      @send_socket = UDPSocket.new()
      @send_socket.setsockopt(:IPPROTO_IP, :IP_MULTICAST_TTL, 1)
      @send_socket.connect(multicast_addr.to_s,port)

      @authenticated_client_id = [
        @config.client_id,
        Digest::HMAC.digest(@config.secret,@config.client_id,Digest::SHA256),
      ].pack("H32A32")
    end

    def port
      @port ||= @config.port
    end

    def bind_addr
      @bind_addr ||= IPAddr.new('0.0.0.0')
    end

    def multicast_addr
      @multicast_addr ||= IPAddr.new(@config.multicast_ip)
    end

    def announce
      @send_socket.send(@authenticated_client_id,0)
    end

    def get_peer_announcements
      return enum_for(__method__) if !block_given?
      begin
        while true
          msg,ip = @receive_socket.recvfrom_nonblock(65536)
          other_client_id,other_digest = msg.unpack('H32A32')

          next if other_client_id == @config.client_id

          # We could do a constant time string compare, but an attacker can
          # just listen to announces and rebroadcast them as his own anyway.
          # This is just to skip other honest clients with different secrets
          # on the network, to avoid wasting time on a handshake.
          next unless other_digest == Digest::HMAC.digest(@config.secret,other_client_id,Digest::SHA256)

          yield [other_client_id,ip[2]]
        end
      rescue IO::WaitReadable
      end
    end
  end
end
