# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

# Set the default task to run both specs and linting.
task default: :ci

# --- Testing Tasks ---
desc 'Run RSpec tests'
RSpec::Core::RakeTask.new(:spec)

# --- Linting Tasks ---
desc 'Run RuboCop for static analysis'
RuboCop::RakeTask.new(:rubocop)

# --- Continuous Integration Task ---
desc 'Run all tests and linters'
task ci: %i[spec rubocop]

# --- Development Tasks ---
desc 'Open an IRB console with the gem loaded'
task :console do
  sh 'irb -Ilib -rvalidates_hostname'
end

# Note: The `build`, `install`, and `release` tasks are automatically provided
# by `bundler/gem_tasks`. Run `rake -T` to see all available tasks.
