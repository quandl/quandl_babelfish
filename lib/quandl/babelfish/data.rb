module Quandl
module Babelfish

class Data < Array
  
  def initialize(*args, &block)
    # do we have options?
    options = args.pop if args && args.last.is_a?(Hash)
    # set headers if given
    @headers = options[:headers] if options && options.has_key?(:headers) && options[:headers].is_a?(Array)
    # onwards and upwards
    super(*args, &block)
  end
  
  def headers
    @headers ||= []
  end
  
end

end
end