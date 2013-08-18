# encoding: utf-8

require 'simplecov'
SimpleCov.start

require 'webmock/rspec'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.order = 'random'
end

require 'cottus'
