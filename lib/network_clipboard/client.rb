require_relative 'config'
require_relative 'discovery'
require_relative 'connection'

require 'clipboard'
require 'socket'
require 'logger'

module NetworkClipboard
  LOGGER = Logger.new(STDOUT)
  LOGGER.level = Logger::WARN

  class ConnectionWrapper
    def initialize(client,connection)
      @client = client
      @connection = connection
      @read_thread = Thread.new{read_loop}
      @write_thread = Thread.new{write_loop}
      @running = true
      @value = nil
    end

    def read_loop
      while @running
        begin
          new_value = @connection.receive()
        rescue DisconnectedError
          if @running
            LOGGER.error("Client #{@connection.remote_client_id} went away")
            @running = false
          end
          break
        end
        next if @value == new_value
        LOGGER.info("Received new clipboard value from #{@connection.remote_client_id}")
        Clipboard.copy(@value = new_value)
      end
      @connection.close_read
      LOGGER.debug("Read loop completed")
    end

    def write_loop
      while @running
        new_value = Clipboard.paste
        (sleep(2); next) if new_value.nil? or new_value.empty? or @value == new_value
        LOGGER.info("Sending clipboard value to #{@connection.remote_client_id}")
        @connection.send(@value = new_value)
      end
      @connection.close_write
      LOGGER.debug("Write loop completed")
    end
    
    def join
      @read_thread.join
      @write_thread.join
    end

    def stop
      @running = false
    end
  end

  class Client

    def self.run
      c = Client.new
      Signal.trap('INT'){c.stop}
      c.loop
    end

    def initialize
      @config = Config.new
      @discovery = Discovery.new(@config)

      @tcp_server = TCPServer.new(@config.port)

      @connections = {}
      @connections_mutex = Mutex.new

      @running = true
    end

    def loop
      Thread.abort_on_exception = true
      @announce_thread = Thread.new{announce_loop}
      @discover_thread = Thread.new{discover_loop}
      @incoming_loop = Thread.new{incoming_loop}

      @announce_thread.join

      @connections.values.each do |connection|
        connection.join
      end
    end

    def announce_loop
      while @running
        LOGGER.debug("Announcing")
        @discovery.announce
        LOGGER.debug("Announced")
        sleep(15)
      end
    end

    def discover_loop
      while @running
        LOGGER.debug("Discovering")
        remote_client_id,address = @discovery.get_peer_announcement
        LOGGER.debug("Found #{remote_client_id} on #{address}")

        @connections_mutex.synchronize do
          next if @connections[remote_client_id]

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

          LOGGER.info("New Peer -> #{remote_client_id}")
          @connections[aes_connection.remote_client_id] = ConnectionWrapper.new(self,aes_connection)
        end
      end
    end

    def incoming_loop
      while @running
        incoming = @tcp_server.accept
        aes_connection = AESConnection.new(@config,incoming)

        LOGGER.debug("Incoming #{aes_connection.remote_client_id} from #{incoming.peeraddr(false)[-1]}")

        @connections_mutex.synchronize do
          if @connections[aes_connection.remote_client_id]
            LOGGER.info("Connection already established to #{aes_connection.remote_client_id}, dropping.")
            aes_connection.close
            next
          end

          LOGGER.info("New Peer <- #{aes_connection.remote_client_id}")

          @connections[aes_connection.remote_client_id] = ConnectionWrapper.new(self,aes_connection)
        end
      end
    end

    def run_connection(connection)
      begin
        while @running
          Clipboard.copy(connection.receive())
        end
      ensure
        connection.close

        @connections_mutex.synchronize do
          @connections.delete(connection.remote_client_id)
        end
      end
    end

    def stop
      @running = false
      @connections.values.each(&:stop)
    end
  end
end
