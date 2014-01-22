module Quandl
module Babelfish

class Chronometer
  class << self

    #return frequency and warning message if present
    def process(table)
      # guesses date frequency in a table
      return nil if table.nil? || table.size==0
      return 'daily' if table.size==1      #not enough , need more points
      freqs = []
      fmt = "%Y-%m"
      fmt = "%Y" if table[0][0].to_s !~ /-/
      fmt = "%Y-%m-%d" if table[0][0].to_s =~ /^.*-.*-.*$/

      table.each_index do |r|
        break if r==6  #first 6 record is enough to analyze
        if table[r+1].nil?
          break
        else
          diff = (Date.strptime(table[r+1][0].to_s, fmt) -
              Date.strptime(table[r][0].to_s, fmt)).to_i.abs
          if diff < 4
            freqs << 'daily'
          elsif diff < 10
            freqs << 'weekly'
          elsif diff < 60
            freqs << 'monthly'
          elsif diff < 200
            freqs << 'quarterly'
          else
            freqs << 'annual'
          end
        end
      end
      return freqs.sort_by { |e| freqs.count(e) }.reverse.first#, nil
    end
    
  end
end

end
end