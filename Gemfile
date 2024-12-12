source "https://rubygems.org"

gemspec

gem "rake", "~> 13.2"

group :development, :test do
  gem "byebug", "~> 11.1"
  gem "pry", require: true
  gem "pry-byebug", "~> 3.10", require: true
  gem "pry-rescue", "~> 1.5", require: true
  gem "pry-stack_explorer", "~> 0.6.1", require: true
  gem "dotenv", require: "dotenv/load"
  gem "standard", "~> 1.36"
  gem "timecop"
end

group :test do
  gem "rspec", "~> 3.10"
  gem "webmock", "~> 3.17"
  gem "simplecov"
  gem "simplecov-cobertura"
end

gem "faraday", "~> 2.0"
