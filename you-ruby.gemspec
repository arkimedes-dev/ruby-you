Gem::Specification.new do |spec|
  spec.name = "ruby-you"
  spec.version = "0.1.0"
  spec.authors = ["Martin Mochetti"]
  spec.summary = "A Ruby client for the You.com API."
  spec.description = "Provides a simple Ruby interface for interacting with the You.com Smart, Research, Search, and News endpoints."
  spec.homepage = "https://github.com/arkimedes-dev/ruby-you"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 2.6"

  spec.files = Dir["{lib}/**/*", "README.md", "LICENSE", "ruby-you.gemspec"]
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-retry", "~> 2"

  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "webmock", "~> 3.17"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/arkimedes-dev/ruby-you"
end
