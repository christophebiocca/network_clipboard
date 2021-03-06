# lib/network_clipboard/discovery.rb
#
# Copyright 2014 Christophe Biocca
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require_relative 'authentication'

require 'socket'
require 'ipaddr'

module NetworkClipboard
  class Discovery
    attr_reader :receive_socket

    def initialize(config,authentication)
      @config = config
      @authentication = authentication

      @receive_socket = UDPSocket.new()
      @receive_socket.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, multicast_addr.hton + bind_addr.hton)
      @receive_socket.bind(bind_addr.to_s,port)

      @send_socket = UDPSocket.new()
      @send_socket.setsockopt(:IPPROTO_IP, :IP_MULTICAST_TTL, 1)
      @send_socket.connect(multicast_addr.to_s,port)

      @authenticated_client_id = [
        @config.client_id,
        @authentication.sign(@config.client_id),
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

    def get_peer_announcement
      while true
        msg,ip = @receive_socket.recvfrom(65536)
        other_client_id,other_digest = msg.unpack('H32A32')

        # Retry if we got our own announcement.
        next if other_client_id == @config.client_id

        # We could do a constant time string compare, but an attacker can
        # just listen to announces and rebroadcast them as his own anyway.
        # This is just to skip other honest clients with different secrets
        # on the network, to avoid wasting time on a failed handshake.
        next unless @authentication.verify(other_client_id,other_digest)

        return [other_client_id,ip[2]]
      end
    end
  end
end
