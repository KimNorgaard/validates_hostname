require 'active_record'
require "rails/all"
require 'rspec/rails'
require 'rspec/collection_matchers'

require 'validates_hostname'
require 'test_model'

RSpec.configure do |config|
  config.mock_with :rspec
  config.expect_with :rspec do |c|
    c.syntax = :should
  end
end
