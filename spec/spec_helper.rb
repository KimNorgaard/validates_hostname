# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'rspec/core'
require 'bundler/setup'
require 'active_model'
require 'rspec/collection_matchers'
require 'validates_hostname'

I18n.load_path += Dir[File.expand_path('../config/locales/*.yaml', __dir__)]

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Run specs in random order to surface order dependencies.
  config.order = :random

  # Allows you to focus on a single test by adding `, :focus`
  config.filter_run_when_matching :focus
end
