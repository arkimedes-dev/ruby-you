require_relative "lib/you/version"

Gem::Specification.new do |spec|
  spec.name = "ruby-you"
  spec.version = You::VERSION
  spec.authors = ["Martin Mochetti"]
  spec.summary = "A Ruby client for the You.com API."
  spec.description = "Provides a simple Ruby interface for interacting with the You.com Smart, Research, Search, and News endpoints."
  spec.homepage = "https://github.com/arkimedes-dev/ruby-you"
  spec.license = "MIT"

  spec.required_ruby_version = Gem::Requirement.new(">= 2.6")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/arkimedes-dev/ruby-you"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ .git .circleci appveyor])
    end
  end

  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{\bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-retry", "~> 2"
end
