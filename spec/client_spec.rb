require "spec_helper"
require "logger"
require "stringio"

RSpec.describe You::Client do
  let(:api_key) { "test_api_key" }
  let(:client) { described_class.new(api_key: api_key) }

  before do
    # Reset configuration before each test
    You.configuration.debug = false
    You.configuration.logger = Logger.new($stdout)
  end

  describe "initialization" do
    context "when api_key is not provided" do
      it "raises an error" do
        # Temporarily unset the YOU_API_KEY environment variable
        original_api_key = ENV.delete("YOU_API_KEY")
        expect { described_class.new(api_key: nil) }.to raise_error(You::Error, /No API key provided/)
        ENV["YOU_API_KEY"] = original_api_key # Restore the environment variable
      end
    end

    context "when api_key is provided" do
      it "does not raise an error" do
        expect { described_class.new(api_key: "key") }.not_to raise_error
      end
    end
  end

  describe ".connection" do
    subject { client.send(:connection, You::Client::SMART_API_BASE_URL) }

    it "sets up the retry middleware" do
      options = subject.builder.handlers.find { |h| h == Faraday::Retry::Middleware }.instance_variable_get(:@args).first
      expect(options).to match(
        retry_statuses: [429, 500, 502, 503, 504],
        methods: [:get, :post],
        max: 3,
        interval_randomness: 0.5,
        interval: 1,
        backoff_factor: 2
      )
    end
  end

  shared_examples "a successful request" do |method_name, endpoint_url|
    it "returns the response body on success" do
      stub_request(request_method, endpoint_url).to_return(
        status: 200,
        body: {"answer" => "Test answer"}.to_json,
        headers: {"Content-Type" => "application/json"}
      )

      response = client.public_send(method_name, query: "test")

      expect(response["answer"]).to eq("Test answer")
    end
  end

  # SMART endpoint tests
  describe "#smart" do
    let(:request_method) { :post }
    let(:endpoint_url) { "https://chat-api.you.com/smart" }

    it_behaves_like "a successful request", :smart, "https://chat-api.you.com/smart"

    it "sends correct parameters" do
      stub = stub_request(:post, endpoint_url).with(
        body: {"query" => "test", "chat_id" => "abc", "instructions" => "Respond in bullet points"}
      ).to_return(status: 200, body: {answer: "ok"}.to_json)

      client.smart(query: "test", chat_id: "abc", instructions: "Respond in bullet points")
      expect(stub).to have_been_requested
    end
  end

  # RESEARCH endpoint tests
  describe "#research" do
    let(:request_method) { :post }
    let(:endpoint_url) { "https://chat-api.you.com/research" }

    it_behaves_like "a successful request", :research, "https://chat-api.you.com/research"

    it "sends correct parameters" do
      stub = stub_request(:post, endpoint_url).with(
        body: {"query" => "test"}
      ).to_return(status: 200, body: {answer: "ok"}.to_json)

      client.research(query: "test")
      expect(stub).to have_been_requested
    end
  end

  # SEARCH endpoint tests
  describe "#search" do
    let(:request_method) { :get }
    let(:endpoint_url) { "https://api.ydc-index.io/search?query=test" }

    it_behaves_like "a successful request", :search, "https://api.ydc-index.io/search?query=test"

    it "sends correct parameters via query string" do
      stub = stub_request(:get, "https://api.ydc-index.io/search")
        .with(query: {"query" => "test", "num_web_results" => "5"})
        .to_return(status: 200, body: {hits: []}.to_json)

      client.search(query: "test", num_web_results: 5)
      expect(stub).to have_been_requested
    end
  end

  # NEWS endpoint tests
  describe "#news" do
    let(:request_method) { :get }
    let(:endpoint_url) { "https://api.ydc-index.io/news?query=test" }

    it_behaves_like "a successful request", :news, "https://api.ydc-index.io/news?query=test"

    it "sends correct parameters via query string" do
      stub = stub_request(:get, "https://api.ydc-index.io/news")
        .with(query: {"query" => "test", "count" => "5"})
        .to_return(status: 200, body: {news: {results: []}}.to_json)

      client.news(query: "test", count: 5)
      expect(stub).to have_been_requested
    end
  end

  # Error handling tests
  describe "error handling" do
    let(:client) { described_class.new(api_key: api_key, max_retries: 1, initial_wait_time: 0.01) }

    [
      [400, You::BadRequestError, "Bad Request"],
      [401, You::UnauthorizedError, "Unauthorized"],
      [403, You::ForbiddenError, "Forbidden"],
      [404, You::NotFoundError, "Not Found"],
      [422, You::UnprocessableEntityError, "Unprocessable Entity"],
      [429, You::RateLimitError, "Rate Limit Reached"],
      [500, You::InternalServerError, "Internal Server Error"],
      [502, You::BadGatewayError, "Bad Gateway"],
      [503, You::ServiceUnavailableError, "Service Unavailable"],
      [504, You::GatewayTimeoutError, "Gateway Timeout"],
      [506, You::Error, "Request failed with status 506: #{{error: "test"}.to_json}"]
    ].each do |status, error_class, message|
      it "raises #{error_class} on HTTP #{status}" do
        stub_request(:post, "https://chat-api.you.com/smart").to_return(status: status, body: {error: "test"}.to_json)

        expect {
          client.smart(query: "test")
        }.to raise_error(error_class, /#{message}/)
      end
    end
  end

  # Debug and logging tests
  describe "debug logging" do
    it "logs requests and responses when debug is enabled" do
      You.configuration.debug = true
      log_output = StringIO.new
      logger = Logger.new(log_output)
      logger.level = Logger::INFO
      You.configuration.logger = logger

      stub_request(:get, "https://api.ydc-index.io/search").with(query: {"query" => "debug-test"})
        .to_return(status: 200, body: {hits: []}.to_json)

      client.search(query: "debug-test")

      logs = log_output.string
      expect(logs).to include("You API Request: GET https://api.ydc-index.io/search") # custom request log
      expect(logs).to include("Status 200") # Faraday logger output
    end
  end
end
