module Quandl::Errors
  class UnknownDateFormat < StandardError;
  end

  class GuessDateFormat < StandardError;
  end

  class InvalidDate < StandardError;
  end

end