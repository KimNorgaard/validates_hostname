# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'net/http'
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

# --- TLD Update Task ---
namespace :tlds do
  desc 'Update the TLD list from IANA'
  task :update do
    uri = URI('http://data.iana.org/TLD/tlds-alpha-by-domain.txt')
    puts "Fetching latest TLDs from #{uri}..."

    begin
      response = Net::HTTP.get(uri)

      File.open('data/tlds.txt', 'w') do |f|
        f.write(response)
      end

      puts 'Successfully updated data/tlds.txt.'
    rescue StandardError => e
      warn "An error occurred during TLD update: #{e.message}"
      exit 1
    end
  end
end
