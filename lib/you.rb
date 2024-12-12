require "you/version"
require "you/configuration"
require "you/client"

module You
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    # A convenience method to access a default client directly
    def client
      @client ||= You::Client.new
    end
  end
end
