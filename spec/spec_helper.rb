require 'bundler/setup'
require 'simplecov'
require 'pp'
SimpleCov.start

require 'draught'
require 'svg_fixture_helper'

module Helpers
  def deg_to_rad(degrees)
    degrees * (Math::PI/180)
  end
end


RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include(Helpers)

  config.extend SVGFixtureHelper::Helpers, :svg_fixture
end

RSpec::Matchers.define :be_boolean do
  match do |actual|
    case actual
    when TrueClass, FalseClass
      true
    else
      false
    end
  end
end

RSpec::Matchers.define :approximate do |expected|
  match do |actual|
    if @delta.nil?
      if @tolerance.nil?
        raise NotImplementedError unless expected.respond_to?(:within_tolerance?)
        actual == expected
      else
        if [actual, expected].all? { |x| x.respond_to?(:within_tolerance?) }
          actual.within_tolerance?(@tolerance, expected)
        else
          @tolerance.within?(actual, expected)
        end
      end
    else
      actual.approximates?(expected, @delta)
    end
  end

  chain :tolerance do |tolerance|
    @tolerance = tolerance
  end

  chain :within do |delta|
    @delta = delta
  end

  failure_message do |actual|
    "expected that #{actual} would be within #{@delta} of #{expected}"
  end

  diffable
end

RSpec::Matchers.define :pp_as do |expected|
  match do |actual|
    out = ""
    PP.pp(actual, out)
    @actual = out
    out == expected
  end

  failure_message do |actual|
    "expected that the correct pp output (#{expected.inspect}) would be generated"
  end

  diffable
end
