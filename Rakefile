require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "standard/rake"
require "dotenv/tasks"

RSpec::Core::RakeTask.new(:spec)

task default: %i[dotenv spec standard]
