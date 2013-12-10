module Quandl
module Error
  class Standard < StandardError
    
    attr_accessor :details
    
    def line
      detail :line
    end
    def context
      detail :context
    end
    def problem
      detail :problem
    end
    
    def detail(key)
      details.send(key) if details.respond_to?(key)
    end
    
    def initialize(opts=nil)
      @details = OpenStruct.new( opts ) if opts && opts.is_a?(Hash)
    end
    
  end
end
end