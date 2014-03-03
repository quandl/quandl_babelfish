require 'spec_helper'

include Quandl::Babelfish
describe Cleaner do

  let(:input){ [] }
  let(:output){ Cleaner.process(input) }
  let(:data){ output[0] }
  let(:headers){ output[1] }
  subject{ data }
  
  context "given nil" do
    let(:input){ [[2012, nil], [2011, 20], [2010, 30]] }
    it{ should eq [[Date.new(2012,12,31), nil], [Date.new(2011,12,31), 20.0], [Date.new(2010,12,31), 30.0]] }
  end

  context "given nil" do
    let(:input){ [[2002,'#N.A.'], [2011, 20]]}
    it{ should eq [[Date.new(2002,12,31), nil], [Date.new(2011,12,31), 20.0]] }
  end
  
  context "mismatch row count" do
    let(:input){ [[2012], [2011, 20], [2010, 30, 25]] }
    it{ should eq [[Date.new(2012,12,31)], [Date.new(2011,12,31), 20], [Date.new(2010,12,31), 30, 25]] }
  end
  
  context "garbage" do
    let(:input){ [[2456624, 10], [2456625, 20], [2456626, 30]] }
    it{ should be_eq_at_index '[0][0]', Date.new(1970,01,29) }
  end
  
  context "headers with whitespace" do
    let(:input){ [["   Date   ", " C1    ", "C2   ", "    C4"],[1990,1,2,3],[1991,4,5,6]] }
    it{ headers.should eq ["Date", "C1", "C2", "C4"] }
  end
  
  context "annual" do
    let(:input){ [[1990,1,2,3],[1991,4,5,6]] }
    it{ should be_eq_at_index '[0][0]', Date.new(1990,12,31) }
    it{ should be_eq_at_index '[0][1]', 1 }
    it{ should be_eq_at_index '[1][0]', Date.new(1991,12,31) }
    it{ should be_eq_at_index '[1][3]', 6 }
    it{ headers.should be_nil }
  end
  
  context "numeric date" do
    let(:input){ [[19900101,'1 [estimate]','2.3 - 4.0','not a number']] }
    it{ should be_eq_at_index '[0][0]', Date.new(1990,01,01) }
    it{ should be_eq_at_index '[0][1]', 1 }
    it{ should be_eq_at_index '[0][2]', 2.3 }
    it{ should be_eq_at_index '[0][3]', nil }
    it{ headers.should be_nil }
  end
  
  context "data with headers" do
    let(:input){ [['Date',0,0,0],[19900101,'1 [estimate]','2.3 - 4.0','not a number']] }
    it{ should be_eq_at_index '[0][0]', Date.new(1990,01,01) }
    it{ should be_eq_at_index '[0][1]', 1 }
    it{ should be_eq_at_index '[0][2]', 2.3 }
    it{ should be_eq_at_index '[0][3]', nil }
    it{ headers.should eq ['Date','0','0','0'] }
  end

  context "data with nil" do
    let(:input){ [["Date", "Col1"], ["2002", nil], ["2003", "5"]] }
    it{ should be_eq_at_index '[0][0]', Date.new(2002,12,31) }
    it{ data[0].length.should == 2}
    it{ should be_eq_at_index '[0][1]', nil }
    it{ should be_eq_at_index '[1][0]', Date.new(2003,12,31)  }
    it{ should be_eq_at_index '[1][1]', 5 }
    it{ headers.should eq ['Date','Col1'] }
  end

  context "data with middle nil" do
    let(:input){ [["Date", "Col1", "Col2"], ["2002", nil, '1'], ["2003", "5", '6']] }
    it{ should be_eq_at_index '[0][0]', Date.new(2002,12,31) }
    it{ should be_eq_at_index '[0][1]', nil }
    it{ should be_eq_at_index '[0][2]', 1}
    it{ should be_eq_at_index '[1][0]', Date.new(2003,12,31)  }
    it{ should be_eq_at_index '[1][1]', 5 }
    it{ should be_eq_at_index '[1][2]', 6 }
    it{ headers.should eq ['Date','Col1', 'Col2'] }
  end

end
