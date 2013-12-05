module Quandl::Babelfish

  #responsible for number cleaning
  class NumberMaid
    @defaults = {
        :decimal_mark => Regexp.escape('.'),
        :ignore_brackets => false, # Brackets ARE negative by default
    }

    @settings = @defaults   #init with defaults

    class << self


      def init(user_settings)
        @settings=@defaults.merge(user_settings)
        @escaped_decimal = Regexp.escape(@settings[:decimal_mark])
      end

      #cleans each number one by one
      def clean(dirty_numbers)
        return nil if dirty_numbers.nil?
        numbers=[]
        Array(dirty_numbers).each do |cell|
          numbers << cell_to_number(cell.to_s)
        end

        (numbers.size == 1) ? numbers[0] : numbers
      end

      def cell_to_number(num)
        return nil if num.nil?
        # Remove annotations
        # if there is something in parenthesis and a number elsewhere, nuke the parenthesis
        temp = num.gsub(/[\(\[\{].*[\)\}\]]/, '')
        num = temp if temp.match(/\d/)

        num.gsub!("est.", '')

        #check for exponents by searching for 'e' 'E' or variations of 'x 10' '*10' and 'X10^'
        is_exp = false
        expmultiplier = 1
        m = /(\s)*(E|e|[X|x|\*](\s)*10(\^)?)(\s)*/.match(num)
        #check if match is made, preceeded by a number/decimal, and succeeded by a digit or a plus/minus sign
        if !m.nil? and m.pre_match =~ /[0-9#{@escaped_decimal}]$/ and m.post_match =~ /^([\-+0-9])/
          is_exp = true
          num = m.pre_match
          expmultiplier = 10 ** /^[0-9\-+]*/.match(m.post_match)[0].to_i
        end
        is_million = (num =~ /million/i)
        is_billion = (num =~ /billion/i)
        is_negative = (num =~ /-[\d]/ or (!@settings[:ignore_brackets] and num =~ /\([\d]/))

        # watch out for two numbers, like a range  eg "27.3 - 33.9"
        # how: if you a see a number followed by a non number char that is not the decimal marker, kill everything to the right of that
        num.gsub!(/(\d) (\d)/, '\1\2')
        if m = num.match(/-?\s*[,\d\.]+/)
          num = m[0]
        end

        # only keep #s and decimal mark
        num.gsub!(/[^0-9#{@escaped_decimal}]/, '')
        num.gsub!(/[^0-9]/, '.')

        return nil if num.nil? || num !~ /[\d]/
        return nil if num.end_with?(".")
        return nil if num.count(".") > 1
        cell = num.nil? ? 0.0 : Float("%.#{14}g" % num)
        cell *= 1e6 if is_million
        cell *= 1e9 if is_billion
        cell *= -1 if is_negative
        cell *= expmultiplier if is_exp
        cell
      end

    end
  end
end