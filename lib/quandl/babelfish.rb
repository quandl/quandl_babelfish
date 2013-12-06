require "quandl/babelfish/version"

require "quandl/babelfish/cleaner"
require "quandl/babelfish/date_maid"
require "quandl/babelfish/number_maid"

require 'quandl/error/guess_date_format'
require 'quandl/error/invalid_date'
require 'quandl/error/unknown_date_format'

module Quandl::Babelfish
  class << self
    def clean(data, date_settings={}, number_settings={})
      Cleaner::process data, date_settings, number_settings

    end
  end
end