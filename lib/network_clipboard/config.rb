require 'yaml'

module NetworkClipboard
  class Config
    DEFAULTS = {
      # http://tools.ietf.org/html/rfc2365
      # Ultimately though, we'd need to reserve a specific address
      # or implemend MADCAP or ZMAAP (Except nothing supports those).
      multicast_ip: '239.255.193.172',
      # Randomly picked by mashing the keyboard.
      port: 53712,
    }

    attr_reader :multicast_ip, :port

    def initialize(filename='~/.networkclipboard.conf')
      filename = File.expand_path(filename)
      begin
        parsed = YAML.load(File.read(filename))
      rescue Errno::ENOENT
        parsed = {}
      end
      config = DEFAULTS.merge(parsed)

      @multicast_ip = config[:multicast_ip]
      @port = config[:port]
    end
  end
end
