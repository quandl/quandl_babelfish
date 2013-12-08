require 'spec_helper'

describe Quandl::Babelfish::Data do
  
  let(:csv) { "Date, Column 1, Column 2, C3, C4, C5, C6, C7\n 2012-03-07,,69.75,69.75,69.75,0.0,0.0,0.0\n2012-03-06,69.75,69.75,69.75,69.75,0.0,0.0,0.0\n2012-03-05,69.75,69.75,69.75,69.75,0.0,0.0,0.0\n2012-03-04,69.75,69.75,69.75,69.75,0.0,0.0,0.0\n2012-02-29,,69.75,69.75,69.75,0.0,0.0,0.0\n2012-02-28,69.75,69.75,69.75,69.75,0.0,0.0,0.0\n" }
  
  let(:data){ Quandl::Babelfish::Data.new(csv) }
  subject{ data }
  
  let(:expected_data){ [['2012-03-07',nil,69.75,69.75,69.75,0.0,0.0,0.0],['2012-03-06',69.75,69.75,69.75,69.75,0.0,0.0,0.0],['2012-03-05',69.75,69.75,69.75,69.75,0.0,0.0,0.0],['2012-03-04',69.75,69.75,69.75,69.75,0.0,0.0,0.0],['2012-02-29',nil,69.75,69.75,69.75,0.0,0.0,0.0],['2012-02-28',69.75,69.75,69.75,69.75,0.0,0.0,0.0]] }
  let(:expected_headers){ ['Date', 'Column 1', 'Column 2', 'C3', 'C4', 'C5', 'C6', 'C7'] }
  
  its(:headers){ should eq expected_headers }  
  its('clone.headers'){ should eq expected_headers }
  its('to_jd.headers'){ should eq expected_headers }
  
  its(:to_date_str){ should eq expected_data }
  
end