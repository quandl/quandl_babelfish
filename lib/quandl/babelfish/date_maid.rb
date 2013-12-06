module Quandl::Babelfish

  #responsible for number formatting
  class DateMaid
    @defaults = {
        :format => nil
    }

    @settings = @defaults   #init with defaults

    class << self

      def init(user_settings)
        @settings=@defaults.merge(user_settings)
      end

      #looks at all the dates and formats them to unambiguous ISO 8601 format  (yyyy-mm-dd)
      def sweep(all_dates)
        return nil if all_dates.nil?

        all_dates = disinfect all_dates

        if @settings[:format].nil?
          #find good example and extract all info from it and apply it to each of the dates in the set
          good_sample = find_good_date(all_dates)

          raise Error::GuessDateFormat.new("Unable to find date format for provide dates") if good_sample.nil?

          date_format, frequency = analyze_date_format(good_sample)


        else
          date_format = @settings[:format]
        end

        iso_dates=[]
        all_dates.each do |fuzzy_date|
          temp_date = convert(fuzzy_date, date_format) rescue raise(Error::InvalidDate,fuzzy_date)
          iso_dates  << frequency_transform(temp_date, frequency)
        end

        iso_dates
      end

      def analyze_date_format(example)
        return nil if example.nil?

        # Regular formats and Custom formats (where Date.parse and Date.strptime
        # fear to tread)
        if re = example.match(/^(\d{1,2})\D(\d{1,2})\D\d{4}/) # eg "07/03/2012"
          if re[1].to_i > 12
            return '%d-%m-%Y', nil
          else
            return '%m-%d-%Y', nil
          end
        end
        if re = example.match(/^(\d{1,2})\D(\d{1,2})\D\d{2}/) # eg "07/03/12"
          if re[1].to_i > 12
            return '%d-%m-%y', nil
          else
            return '%m-%d-%y', nil
          end
        end
        # order these guys from most specific to most general
        return "%Y", "annual" if example =~ /^\d{4}[\s]?-[\s]?\d{4}$/
        return '%Y%m%d', 'daily' if example =~ /^\d{8}$/ && example[4..5].to_i < 13 && example[6..7].to_i < 32 # precisely 8 digits - yyyymmdd
        return 'epoch', 'daily' if example =~ /^\d{7}.*$/ # 7 or more digits - epoch
        return '%Y', 'annual' if example =~ /^\d{4}$/ # 4 digits
        return '%Y', 'annual' if example =~ /^\d{4}\.0$/ # 4 digits with a dot 0 for excel
        return ':year_quarter', 'quarterly' if example =~ /^\d{4}[Qq]\d$/ # 4 digits, Q, digit (here because the next pattern would override it)
        return '%YM%m', 'monthly' if example =~ /^\d{4}M\d{1,2}$/ # 2007M08
        return '%GW%V', 'weekly' if example =~ /^\d{4}W\d{1,2}$/ # 2012W01
        return '%Y-%m', 'monthly' if example =~ /^\d{4}\D\d{1,2}$/ # 4 digits, separator, 1-2 digits
        return '%m-%Y', 'monthly' if example =~ /^\d{1,2}\D\d{4}$/ # 1-2 digits, separator, 4 digits
        return '%Y%m', 'monthly' if example =~ /^\d{6}$/ # 6 digits
        return '%Y-%b', 'monthly' if example =~ /^\d{4}\D\w{3}$/ # 4 digits, separator, 3 letters
        return '%b-%Y', 'monthly' if example =~ /^\w{3}\D\d{4}$/ # 3 letters, separator, 4 digits
        return '%b-%y', 'monthly' if example =~ /^\w{3}\D\d{2}$/ # 3 letters, separator, 2 digits
        return '%Y%b', 'monthly' if example =~ /^\d{4}\w{3}$/ # 4 digits, 3 letters
        return '%b%Y', 'monthly' if example =~ /^\w{3}\d{4}$/ # 3 letters, 4 digits
        return '%Y-%b-%d', 'daily' if example =~ /^\d{4}\D\w{3}\D\d{1,2}$/ # 4 digits, separator, 3 letters, separator, 1-2 digits
        return '%Y-%m-%d', 'daily' if example =~ /^\d{4}\D\d{1,2}\D\d{1,2}$/ # 4 digits, separator, 1-2 digits, separator, 1-2 digits
        return '%d-%b-%Y', 'daily' if example =~ /^\d{1,2}\D\w{3}\D\d{4}$/ # 1-2 digits, separator, 3 letters, separator, 4 digits
        return '%Y%b%d', 'daily' if example =~ /^\d{4}\w{3}\d{1,2}$/ # 4 digits, 3 letters, 1-2 digits
        return '%d%b%Y', 'daily' if example =~ /^\d{1,2}\w{3}\d{4}$/ # 1-2 digits, 3 letters, 4 digits
        return '%d-%b-%y', 'daily' if example =~ /^\d{1,2}\D\w{3}\D\d{2}$/ # 1-2 digits, 3 letters, 2 digits
        return '%b-%d-%Y', 'daily' if example =~ /^\w{3}\D\d{1,2}\D{1,2}\d{4}$/ # 3 letters, separator, 1-2 digits, separator(s), 4 digits

        #our custom formats
        return ':year_quarter', 'quarterly' if example =~ /^\d{4}\D[Qq]\d$/ # 4 digits, separator, Q, digit
        return ':excel-1900', 'daily' if example =~ /^\d{5}$/ # 5 digits
        return ':excel-1900', 'daily' if example =~ /^\d{5}\.0$/ # 5 digits dot zero excel

        # No, try default date parse
        # raise PostProcessorException, "Unable to guess date format for #{example}"
        [nil, nil]
      end

      def disinfect(dates)
        [*dates].collect do |date|
          date.to_s.encode!('UTF-8', 'UTF-8', :invalid => :replace)
          date.to_s.gsub!(/[^\x01-\x7f]/,'')
          date.to_s.strip.gsub(/\s\s+/, ' ')
        end
      end
      private


      #converts date to specified format
      def convert(fuzzy_date, date_format)
        if date_format.nil?
          # Assuming a US date format with 3 parameters (i.e. MM?DD?YYYY)
          tokens = fuzzy_date.split(/\D/)
          if tokens[0].length > 2 || fuzzy_date =~ /\w{2}/
            # Its ISO
            return DateTime.parse(fuzzy_date.to_s).to_date
          else
            # Guessing US
            return Date.new(tokens[2].to_i, tokens[0].to_i, tokens[1].to_i)
          end
        else
          case date_format
          when ':year_quarter'
            return year_quarter_formatter(fuzzy_date)
          when ':excel-1900'
            return excel_1900_formatter(fuzzy_date)
          else #regular ruby formatter
            return regular_formatter(fuzzy_date, date_format)
          end

        end
      end


      def year_quarter_formatter(fuzzy_date)
        raw_date = fuzzy_date
        tokens = raw_date.gsub(/[qQ]/, '-').gsub(/[a-zA-Z]/, '').split(/[^0-9]/)
        tokens.delete_if {|x| x.nil? || x.empty?} # In case there are more than one delimiter because we replaced the Q
        Date.new(tokens[0].to_i, tokens[1].to_i * 3, 1)
      end

      def excel_1900_formatter(fuzzy_date)
        # handle Lotus 123 bug has 1900 as a leap year
        Date.civil(1899, 12, 31) + fuzzy_date.to_i - 1 if fuzzy_date.to_i > 0
      end

      def regular_formatter(fuzzy_date, date_format)
        # We have a date format - oh so pretty, but...
        date_string = fuzzy_date
        # normalize delimiters to hyphens so we do not have to make a format for each one.
        # delimiters can be letters when its all numbers and delimiters only when there are letters. Sigh.
        # only if no format where provided
        date_string = date_string.gsub(/[^\d\w]+/, '-') if @settings[:format].nil?

        #epoch date string
        if date_format == 'epoch'
          news = Time.at(date_string.to_i).utc.to_s.match(/\d\d\d\d-\d\d-\d\d/)
          formatted_date = DateTime.strptime(news.to_s, '%Y-%m-%d').to_date
        else
          if date_string.to_s =~ /^(\w{3})\D(\d{2})$/
            century = $2.to_i < 25 ? '20' : '19'
            date_string = "#{$1} #{century}#{$2}"
            formatted_date = DateTime.strptime(date_string.to_s, '%b %Y').to_date
          else
            formatted_date = DateTime.strptime(date_string.to_s, date_format).to_date
          end
        end
        formatted_date+=4 if date_format == '%GW%V'  #strptime makes dates on Mondays. We want Fridays.
        formatted_date
      end



      #find good example of date to use as template for format
      def find_good_date(all_dates)
        good_sample=nil
        all_dates.each do |fuzzy_date|
          if  usable_cell(fuzzy_date)
            good_sample = fuzzy_date
            break
          end
        end
        good_sample
      end

      def usable_cell(cell)
        return false if cell.nil? || cell.to_s.empty?
        return false if cell.to_s.size > 20 # even annotated date can't be bigger than 20

        return true if cell.to_s =~ /^\w{3}\D[456789]\d$/
        # date is not usable as an example if it is ambiguous as to day and month
        # 03/04/2012, for example, is ambiguous.  03/17/2012 is NOT ambiguous
        if re = cell.to_s.match(/^(\d{1,2})\D(\d{1,2})\D\d{2,4}/)  # e.g. 03/04/2012
          if re[1].to_i <= 12 and re[2].to_i <= 12
            return false
          else
            return true
          end
        end

        if re = cell.to_s.match(/^(\d{1,2})\D\w{3}\D(\d{2})/) # 07-jun-07
          if re[1].to_i <= 12 and re[2].to_i <= 12
            return false
          else
            return true
          end
        end

        return true if cell.to_s =~ /\d{4}/ # It has a 4 digit year somewhere

        return true if cell.to_s =~ /^\w{3}\D\d{2}/ # %b-%y(d)..also not ambiguous

        false # Thank you, come again
      end

      # Bump date to the end of the respective periods
      def frequency_transform(date, frequency)
        case frequency
          when 'annual'
            date = Date.new(date.year,12,31)
          when 'quarterly'
            month = 3*((date.month-1)/3 + 1) # equals 3,6,9 or 12
            date = Date.new(date.year, month, 1).next_month-1
          when 'monthly'
            date = Date.new(date.year, date.month,1).next_month-1
          else
            # Do nothing for daily or weekly
        end

        date
      end


    end
  end
end
