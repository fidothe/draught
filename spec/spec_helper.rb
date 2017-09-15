require 'bundler/setup'
require 'simplecov'
SimpleCov.start

require 'draught'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RSpec::Matchers.define :approximate do |expected|
  match do |actual|
    actual.approximates?(expected, @delta)
  end

  chain :within do |delta|
    @delta = delta
  end

  diffable
end
