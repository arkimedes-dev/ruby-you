# ruby-you

|  Tests |  Coverage  |
|:-:|:-:|
| [![Tests](https://github.com/arkimedes-dev/ruby-you/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/arkimedes-dev/ruby-you/actions/workflows/main.yml)  |  [![Codecov Coverage](https://codecov.io/github/arkimedes-dev/ruby-you/graph/badge.svg?token=SKTT14JJGV)](https://codecov.io/github/arkimedes-dev/ruby-you) |


A Ruby client for interacting with the You.com API, including the Smart, Research, Search, and News endpoints. This gem provides a simple and consistent interface, along with configurable retry logic, rate-limit handling, debugging options, and comprehensive error handling.

## Features

- **Smart API**: Send queries to `https://chat-api.you.com/smart`.
- **Research API**: Send queries to `https://chat-api.you.com/research`.
- **Search API**: Query `https://api.ydc-index.io/search` for web search results.
- **News API**: Query `https://api.ydc-index.io/news` for news results.

## Requirements

- Ruby 2.6 or higher.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby-you'
```

Then execute

```bash
bundle install
```

Or install it yourself as:

```bash
gem build ruby-you.gemspec
gem install ruby-you-0.1.1.gem
```

## Configuration

The client requires an API key. You can provide this as an environment variable YOU_API_KEY or pass it directly when initializing the client.

You can also configure logging and debugging:

```rb
require 'you'

You.configure do |config|
  config.debug = true                  # enable debug mode for verbose logging
  config.logger = Logger.new($stdout)  # customize the logger, defaults to $stdout with WARN level
end
```

## Usage

```rb
require 'you'

client = You.client(api_key: "YOUR_API_KEY")

# Smart API
response = client.smart(query: "What is the capital of France?", instructions: "Respond in bullet points.")
puts response["answer"]

# Research API
research_result = client.research(query: "Explain quantum computing in simple terms")
puts research_result["answer"]

# Search API
search_result = client.search(query: "Ruby programming", num_web_results: 5, safesearch: "moderate")
puts search_result["hits"]

# News API
news_result = client.news(query: "latest tech news", count: 5, recency: "day")
puts news_result["news"]["results"]
```

## Endpoints and Parameters

### Smart API (POST /smart)

- query (String, required)
- chat_id (String, optional)
- instructions (String, optional)

### Research API (POST /research)

- query (String, required)
- chat_id (String, optional)

### Search API (GET /search)

- query (String, required)
- num_web_results (Integer, optional)
- offset (Integer, optional)
- country (String, optional)
- safesearch (String, optional, defaults to moderate)

### News API (GET /news)

- query (String, required)
- count (Integer, optional)
- offset (Integer, optional)
- country (String, optional)
- search_lang (String, optional)
- ui_lang (String, optional)
- safesearch (String, optional)
- spellcheck (Boolean, optional)
- recency (String, optional: day, week, month, year)

### Error Handling

The client raises custom exceptions for non-200 responses:

- You::BadRequestError (400)
- You::UnauthorizedError (401)
- You::ForbiddenError (403)
- You::NotFoundError (404)
- You::UnprocessableEntityError (422)
- You::RateLimitError (429)
- You::InternalServerError (500)
- You::BadGatewayError (502)
- You::ServiceUnavailableError (503)
- You::GatewayTimeoutError (504)
- You::Error for all other errors.

Rate-limit errors (429) are retried up to max_retries times with an exponential backoff or a Retry-After delay if provided by the server.

### Debugging and Logging

Set `You.configuration.debug = true` to enable detailed logs of requests and responses. These logs include:

- Outgoing request method, URL, and parameters.
- Response status code, headers, and body.

You can customize the logger with You.configuration.logger.

## Testing

This gem uses RSpec and WebMock for testing.

Install the dependencies:

```bash
bundle install
```

Run the tests:

```bash
rspec
```

The test suite covers:

- Successful requests
- Various error responses and the corresponding exceptions
- Rate-limit handling and retry logic
- Debug/logging functionality

## Contributing

- Fork the project
- Create a new feature branch (git checkout -b feature/my-feature)
- Commit your changes (git commit -m 'Add new feature')
- Push to the branch (git push origin feature/my-feature)
- Create a new Pull Request
- Release the gem: `bundle exec rake release`

## License

This project is licensed under the MIT License - see the [LICENSE.txt](https://github.com/arkimedes-dev/ruby-you/blob/main/LICENSE.txt) file for details.
