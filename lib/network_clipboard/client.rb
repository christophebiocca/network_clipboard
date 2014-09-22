require_relative 'config'
require_relative 'discovery'
require_relative 'connection'

module NetworkClipboard
  class Client
    def initialize
      @config = Config.new
      @discovery = Discovery.new(@config)
    end

    def loop
      while true
        [:announce,
         :discover,
         :wait,
        ].each do |action|
          send(action)
        end
      end
    end

    def announce
      @discovery.announce
    end

    def discover
      @discovery.get_peer_announcements do |remote_client_id,address|
      end
    end

    def wait
      return IO.select([
        @discovery.receive_socket,
      ], [], [], 5)
    end
  end
end
