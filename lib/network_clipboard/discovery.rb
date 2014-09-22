require 'socket'
require 'ipaddr'

module NetworkClipboard
  class Discovery
    def initialize(config)
      @config = config

      @receive_socket = UDPSocket.new()
      @receive_socket.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, multicast_addr.hton + bind_addr.hton)
      @receive_socket.bind(bind_addr.to_s,port)

      @send_socket = UDPSocket.new()
      @send_socket.setsockopt(:IPPROTO_IP, :IP_MULTICAST_TTL, 1)
      @send_socket.connect(multicast_addr.to_s,port)
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
  end
end
