require "you/error"
require "uri"
require "faraday"
require "faraday/retry"

module You
  class Client
    SMART_API_BASE_URL = "https://chat-api.you.com".freeze
    SEARCH_API_BASE_URL = "https://api.ydc-index.io".freeze

    attr_accessor :api_key, :max_retries, :initial_wait_time

    def initialize(api_key: nil, max_retries: 3, initial_wait_time: 1)
      @api_key = api_key || ENV["YOU_API_KEY"]

      raise You::Error, "No API key provided. Set YOU_API_KEY env or pass api_key." unless @api_key

      @max_retries = max_retries
      @initial_wait_time = initial_wait_time
    end

    # SMART Endpoint
    def smart(query:, chat_id: nil, instructions: nil)
      post("#{SMART_API_BASE_URL}/smart", {query: query, chat_id: chat_id, instructions: instructions}.compact)
    end

    # RESEARCH Endpoint
    def research(query:, chat_id: nil)
      post("#{SMART_API_BASE_URL}/research", {query: query, chat_id: chat_id}.compact)
    end

    # SEARCH Endpoint (GET)
    def search(query:, **params)
      get("#{SEARCH_API_BASE_URL}/search", {query: query}.merge(params))
    end

    # NEWS Endpoint (GET)
    def news(query:, **params)
      get("#{SEARCH_API_BASE_URL}/news", {query: query}.merge(params))
    end

    private

    def connection(base_url)
      Faraday.new(base_url) do |faraday|
        faraday.request :json
        faraday.response :json

        # If debug mode is on, we add a Faraday logger middleware that outputs to You.configuration.logger
        if You.configuration.debug
          faraday.response :logger, You.configuration.logger, {bodies: true}
        end

        # Retries a request after refreshing the token if we get an UnauthorizedError
        faraday.request :retry, {
          retry_statuses: [429, 500, 502, 503, 504],
          methods: [:get, :post],
          max: max_retries,
          interval_randomness: 0.5,
          interval: initial_wait_time,
          backoff_factor: 2
        } do |retry_opts|
          # If you'd like, you can customize conditions here, e.g.,
          # using the Retry-After header for 429 responses:
          retry_opts.retry_if = lambda do |env, _|
            env.status == 429
          end

          retry_opts.calculate_wait = lambda do |env, _|
            # Check for 'Retry-After' header:
            if (retry_after = env.response_headers["Retry-After"])
              retry_after.to_i
            else
              nil # fall back to default backoff logic
            end
          end
        end

        faraday.adapter Faraday.default_adapter
        faraday.headers["X-API-Key"] = @api_key
      end
    end

    def get_with_retries(url, params = {})
      attempt_with_retries do
      end
    end

    def post_with_retries(url, payload)
      attempt_with_retries do
        post(url, payload)
      end
    end

    def get(url, params = {})
      log_request("GET", url, params)
      resp = connection(base_url(url)).get do |req|
        req.url endpoint_path(url)
        req.params.update(params)
      end
      handle_response(resp)
    end

    def post(url, payload)
      log_request("POST", url, payload)
      resp = connection(base_url(url)).post do |req|
        req.url endpoint_path(url)
        req.body = payload
      end
      handle_response(resp)
    end

    def handle_response(response)
      log_response(response)
      case response.status
      when 200
        response.body
      when 400
        raise You::BadRequestError, "Bad Request: #{response.body}"
      when 401
        raise You::UnauthorizedError, "Unauthorized: #{response.body}"
      when 403
        raise You::ForbiddenError, "Forbidden: #{response.body}"
      when 404
        raise You::NotFoundError, "Not Found: #{response.body}"
      when 422
        raise You::UnprocessableEntityError, "Unprocessable Entity: #{response.body}"
      when 429
        retry_after = response.headers["Retry-After"]
        msg = "Rate Limit Reached: #{response.body}"
        msg << " (Retry-After: #{retry_after})" if retry_after
        raise You::RateLimitError, msg
      when 500
        raise You::InternalServerError, "Internal Server Error: #{response.body}"
      when 502
        raise You::BadGatewayError, "Bad Gateway: #{response.body}"
      when 503
        raise You::ServiceUnavailableError, "Service Unavailable: #{response.body}"
      when 504
        raise You::GatewayTimeoutError, "Gateway Timeout: #{response.body}"
      else
        raise You::Error, "Request failed with status #{response.status}: #{response.body}"
      end
    end

    def base_url(full_url)
      uri = URI(full_url)
      "#{uri.scheme}://#{uri.host}"
    end

    def endpoint_path(full_url)
      uri = URI(full_url)
      uri.path
    end

    def log_request(method, url, params_or_body)
      return unless You.configuration.debug
      You.configuration.logger.info("You API Request: #{method} #{url} with #{params_or_body}")
    end

    def log_response(response)
      return unless You.configuration.debug
      You.configuration.logger.info("You API Response: Status #{response.status}, Headers: #{response.headers}, Body: #{response.body}")
    end
  end
end
