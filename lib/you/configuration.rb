require "logger"

module You
  class Configuration
    attr_accessor :logger, :debug

    def initialize
      @logger = Logger.new($stdout)
      @logger.level = Logger::WARN
      @debug = false
    end
  end
end
