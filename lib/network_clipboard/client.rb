require_relative 'config'
require_relative 'discovery'
require_relative 'connection'

require 'clipboard'
require 'socket'

module NetworkClipboard
  class Client
    def initialize
      @config = Config.new
      @discovery = Discovery.new(@config)
      @tcp_server = TCPServer.new(@config.port)
      @connections = {}
    end

    def loop
      while true
        [:announce,
         :discover,
         :watch_incoming,
         :find_incoming,
         :wait,
        ].each do |action|
          send(action)
        end
      end
    end

    def watch_incoming
      @connections.values.each{|c| receive_clipboard(c)}
    end

    def receive_clipboard(connection)
      inbound = connection.receive(false)
      Clipboard.copy(inbound) if inbound
    end

    def announce
      @discovery.announce
    end

    def discover
      @discovery.get_peer_announcements do |remote_client_id,address|
        next if @connections[remote_client_id] or remote_client_id < @config.client_id

        aes_connection = AESConnection.new(@config,TCPSocket.new(address,@config.port))

        if aes_connection.remote_client_id != remote_client_id
          aes_connection.close
          next
        end
          
        if @connections[aes_connection.remote_client_id]
          aes_connection.close
          next
        end

        @connections[aes_connection.remote_client_id] = aes_connection
      end
    end

    def find_incoming
      while true
        begin
          incoming = @tcp_server.accept_nonblock
        rescue IO::WaitReadable
          return
        end
        aes_connection = AESConnection.new(@config,incoming)

        if @connections[aes_connection.remote_client_id]
          aes_connection.close
          next
        end

        @connections[aes_connection.remote_client_id] = aes_connection
      end
    end

    def wait
      return IO.select([
        @discovery.receive_socket,
        @tcp_server,
      ] + @connections.values.collect(&:socket), [], [], 5)
    end
  end
end
