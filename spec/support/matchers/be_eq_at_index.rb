RSpec::Matchers.define :be_eq_at_index do |index, expected|
  match do |actual|
    # value should eq expectation
    actual_value_with_index(actual, index) == expected
  end

  failure_message_for_should do |actual|
    "expected that #{actual_value_with_index(actual, index)} would eq #{expected}"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual_value_with_index(actual, index)} would eq #{expected}"
  end

  description do
    "be eq to #{expected} for array at index #{index}"
  end
  
  def actual_value_with_index(actual, index)
    # split string index into keys
    indexes = index.to_s.split(']').collect{|v| v.gsub('[','') }
    # convert indexes to integers if this is an array
    indexes = indexes.collect(&:to_i) if actual.is_a?(Array)
    # apply indexes to value
    value = actual
    indexes.each do |i|
      value = value.send(:[], i)
    end
    value
  end
  
end