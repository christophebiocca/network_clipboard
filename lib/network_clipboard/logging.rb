require 'logger'

module NetworkClipboard
  LOGGER = Logger.new(STDOUT)
  LOGGER.level = Logger::WARN
end
