require 'spec_helper'

include Quandl
describe Babelfish do

  it 'should run gem' do
    input=[[1990,1,2,3],[1991,4,5,6]]
    output = Babelfish::clean input
    output[0][0].should ==Date.new(1990,12,31)
    output[0][1].should ==1
    output[1][0].should ==Date.new(1991,12,31)
    output[1][3].should ==6
  end

end
