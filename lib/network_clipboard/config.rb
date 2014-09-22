require 'yaml'
require 'securerandom'

module NetworkClipboard
  class Config
    DEFAULTS = {
      # http://tools.ietf.org/html/rfc2365
      # Ultimately though, we'd need to reserve a specific address
      # or implemend MADCAP or ZMAAP (Except nothing supports those).
      multicast_ip: '239.255.193.172',
      # Randomly picked by mashing the keyboard.
      port: 53712,
      # This file needs to be shared to enable clipboard transfer.
      secret_file: '~/.networkclipboard.secret',
    }

    attr_reader :multicast_ip, :port, :secret, :client_id

    def initialize(filename='~/.networkclipboard.conf')
      filename = File.expand_path(filename)
      begin
        parsed = YAML.load(File.read(filename))
      rescue Errno::ENOENT
        parsed = {}
      end
      config = DEFAULTS.merge(parsed)

      secret_filename = File.expand_path(config[:secret_file])
      begin
        @secret = [File.read(secret_filename)].pack('H*')
      rescue Errno::ENOENT
        @secret = SecureRandom.random_bytes(32)
        File.open(secret_filename,'w',0400){|f|f.write(secret.unpack('H*')[0])}
      end

      @multicast_ip = config[:multicast_ip]
      @port = config[:port]
      @client_id = SecureRandom.uuid.gsub('-','')
    end
  end
end
