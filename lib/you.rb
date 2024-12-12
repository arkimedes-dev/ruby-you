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

    # A convenience method to access the client directly
    def client(api_key: nil, max_retries: 3, initial_wait_time: 1)
      @client ||= You::Client.new(
        api_key: api_key,
        max_retries: max_retries,
        initial_wait_time: initial_wait_time
      )
    end
  end
end
