# encoding: utf-8

require 'webmock/rspec'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.order = 'random'
end

require 'coveralls'
require 'simplecov'

if ENV.include?('TRAVIS')
  Coveralls.wear!
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
end

SimpleCov.start do
  add_group 'Source', 'lib'
  add_group 'Unit tests', 'spec/cottus'
  add_group 'Acceptance tests', 'spec/acceptance'
end

require 'cottus'
