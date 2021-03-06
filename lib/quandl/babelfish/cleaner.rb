module Quandl
module Babelfish
    
class Cleaner
  class << self
    def process(dirty_array, date_settings={}, number_settings={})
      return nil,nil if dirty_array.nil?

      #check if first line is header
      header=DateMaid::disinfect(dirty_array.shift) unless DateMaid::analyze_date_format(DateMaid::disinfect(dirty_array[0][0])[0])[0]
      return [], header if dirty_array.empty?
      
      #converts dates first
      dirty_array
      dates = dirty_array.collect{|x| x[0]}
      DateMaid::init(date_settings)
      clean_dates=DateMaid::sweep dates

      clean_array=[]
      #clean numbers later
      NumberMaid::init(number_settings)
      dirty_array.each.with_index do |row, i|
        new_row=[]
        clean_row=NumberMaid::clean(row[1..-1])
        clean_row=[nil] if clean_row.nil?
        (new_row << clean_dates[i]).concat Array(clean_row)    #add clean date and all clean numbers
        clean_array << new_row
      end

      return clean_array, header
    end
  end
end

end
end