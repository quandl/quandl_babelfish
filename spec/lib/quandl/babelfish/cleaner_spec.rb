require 'spec_helper'

include Quandl::Babelfish
describe Cleaner do

  let(:input){ [] }
  let(:output){ Cleaner.process(input) }
  subject{ output }
  
  context "garbage" do
    let(:input){ [[2456624, 10], [2456625, 20], [2456626, 30]] }
    it{ should be_eq_at_index '[0][0]', Date.new(1970,01,29) }
  end
  
  context "headers with whitespace" do
    let(:input){ [["   Date   ", " C1    ", "C2   ", "    C4"],[1990,1,2,3],[1991,4,5,6]] }
    its(:headers){ should eq ["Date", "C1", "C2", "C4"] }
  end
  
  context "annual" do
    let(:input){ [[1990,1,2,3],[1991,4,5,6]] }
    it{ should be_eq_at_index '[0][0]', Date.new(1990,12,31) }
    it{ should be_eq_at_index '[0][1]', 1 }
    it{ should be_eq_at_index '[1][0]', Date.new(1991,12,31) }
    it{ should be_eq_at_index '[1][3]', 6 }
    its(:headers){ should be_nil }
  end
  
  context "numeric date" do
    let(:input){ [[19900101,'1 [estimate]','2.3 - 4.0','not a number']] }
    it{ should be_eq_at_index '[0][0]', Date.new(1990,01,01) }
    it{ should be_eq_at_index '[0][1]', 1 }
    it{ should be_eq_at_index '[0][2]', 2.3 }
    it{ should be_eq_at_index '[0][3]', nil }
    its(:headers){ should be_nil }
  end
  
  context "data with headers" do
    let(:input){ [['Date',0,0,0],[19900101,'1 [estimate]','2.3 - 4.0','not a number']] }
    it{ should be_eq_at_index '[0][0]', Date.new(1990,01,01) }
    it{ should be_eq_at_index '[0][1]', 1 }
    it{ should be_eq_at_index '[0][2]', 2.3 }
    it{ should be_eq_at_index '[0][3]', nil }
    its(:headers){ should eq ['Date',0,0,0] }
  end

end
