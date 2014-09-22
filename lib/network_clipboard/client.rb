require_relative 'config'
require_relative 'discovery'
require_relative 'connection'

module NetworkClipboard
  class Client
    def initialize
      @config = Config.new
    end
  end
end
