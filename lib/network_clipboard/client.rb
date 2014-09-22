require_relative 'config'
require_relative 'discovery'
require_relative 'connection'

require 'clipboard'
require 'socket'
require 'logger'

module NetworkClipboard
  class Client
    LOGGER = Logger.new(STDOUT)
    LOGGER.level = Logger::WARN

    attr_writer :running

    def self.run
      c = Client.new
      Signal.trap('INT'){c.running = false}
      c.loop
    end

    def initialize
      @config = Config.new
      @discovery = Discovery.new(@config)
      @tcp_server = TCPServer.new(@config.port)
      @connections = {}
      @running = true
    end

    def loop
      while @running
        [:announce,
         :discover,
         :watch_incoming,
         :fetch_clipboard,
         :find_incoming,
         :wait,
        ].each do |action|
          send(action) if @running
        end
      end
    end

    def fetch_clipboard
      update_clipboard(Clipboard.paste)
    end

    def update_clipboard(new_value)
      @new_value,@last_value = new_value,@new_value
      if @new_value != @last_value
        @connections.values.each{|c| send_new_clipboard(c)}
      end
    end

    def send_new_clipboard(connection)
      connection.send(@new_value)
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
        LOGGER.info("New Peer -> #{remote_client_id}")

        aes_connection = AESConnection.new(@config,TCPSocket.new(address,@config.port))

        if aes_connection.remote_client_id != remote_client_id
          LOGGER.error("Client Id #{aes_connection.remote_client_id} doesn't match original value #{remote_client_id}")
          aes_connection.close
          next
        end
          
        if @connections[aes_connection.remote_client_id]
          LOGGER.error("Duplicate connections #{aes_connection} and #{@connections[aes_connection.remote_client_id]}")
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
        LOGGER.info("New Peer <- #{aes_connection.remote_client_id}")

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
