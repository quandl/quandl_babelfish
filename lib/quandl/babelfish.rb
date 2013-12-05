require "quandl/babelfish/version"

require "quandl/babelfish/cleaner"
require "quandl/babelfish/date_maid"
require "quandl/babelfish/number_maid"
require 'quandl/babelfish/errors'

module Quandl::Babelfish
  class << self
    def clean(data, date_settings={}, number_settings={})
      Cleaner::process data, date_settings, number_settings

    end
  end
end