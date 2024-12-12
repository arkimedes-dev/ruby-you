if ENV["COVERAGE_DIR"]
  require "simplecov"
  SimpleCov.coverage_dir(ENV["COVERAGE_DIR"])
  if ENV["CI"]
    require "simplecov-cobertura"
    SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
  end
  SimpleCov.start
end

require "rspec"
require "webmock/rspec"
require "pry"
require "you"
require "dotenv"

# Load environment variables from .env.test
Dotenv.load(".env.test")

Bundler.require(:default, :development, :test)

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end
end
