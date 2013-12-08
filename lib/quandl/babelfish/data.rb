module Quandl
module Babelfish

class Data < Quandl::Data
  
  def initialize(*args)
    super(*args)
    # clean data on initialize
    self.data_array
  end
  
  
  protected
  
  def clean(data)
    # skip cleaning if already clean
    return data if data.kind_of?(Array) && cleaned?
    # Quandl::Data is already clean, but to avoid errors extract internal array
    return data.data_array if data.kind_of?(Quandl::Data)
    # Return empty array if given empty string, nil, etc.
    return [] if data.blank?
    # Hash needs conversion to array
    data = Quandl::Data::Format.hash_to_array( data )
    # String needs conversion to array
    data = Quandl::Data::Format.csv_to_array( data )
    # Babelfish cleaner
    data, self.headers = Quandl::Babelfish.clean(data)
    # mark data as clean
    cleaned!
    # return data
    data
  end
  
end

end
end