$:.unshift File.join(File.dirname(__FILE__),'..','..','lib')

require 'rspec'
require 'confiture'
require 'pp'

RSpec.configure do |config|
  config.mock_with :rspec
  config.treat_symbols_as_metadata_keys_with_true_values = true
end
