require 'yaml'

module NetworkClipboard
  class Config
    DEFAULTS = {
    }

    def initialize(filename='~/.networkclipboard.conf')
      filename = File.expand_path(filename)
      begin
        parsed = YAML.load(File.read(filename))
      rescue Errno::ENOENT
        parsed = {}
      end
      config = DEFAULTS.merge(parsed)
    end
  end
end
