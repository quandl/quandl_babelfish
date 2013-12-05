require 'spec_helper'

include Quandl::Babelfish
describe Cleaner do

  it 'should return clean table #1' do
    input=[[1990,1,2,3],[1991,4,5,6]]
    output=Cleaner::process input
    output[0][0].should ==Date.new(1990,12,31)
    output[0][1].should ==1
    output[1][0].should ==Date.new(1991,12,31)
    output[1][3].should ==6
  end

  it 'should return clean table #2' do
    input=[[19900101,'1 [estimate]','2.3 - 4.0','not a number']]
    output=Cleaner::process input
    output[0][0].should ==Date.new(1990,01,01)
    output[0][1].should ==1
    output[0][2].should ==2.3
    output[0][3].should ==nil
  end

end
