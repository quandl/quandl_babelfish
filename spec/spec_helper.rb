$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

require 'pry'
require "rspec"
require 'quandl/babelfish'

# require support
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.mock_with :rspec
end