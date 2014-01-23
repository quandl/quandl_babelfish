require 'spec_helper'
include Quandl::Babelfish
describe Helper do

  before(:each) do
    @square_table = [
        [1,2,3],
        [4,5,6],
        [7,8,9]
    ]
  end

  it 'should square an already square table' do
    Helper::make_square(@square_table).should == @square_table
  end

  it 'should square an empty table' do
    Helper::make_square([]).should == []
  end

  it 'should square a single cell table' do
    Helper::make_square([[1]]).should == [[1]]
  end

  it 'should square a single row table' do
    Helper::make_square([[1,2,3]]).should == [[1,2,3]]
  end

  it 'should square a nil row table' do
    Helper::make_square([[], [1,2,3]]).should == [[nil,nil,nil], [1,2,3]]
  end

  it 'should square a nil row table at end too' do
    Helper::make_square([[1,2,3], []]).should == [[1,2,3], [nil,nil,nil]]
  end

  it 'should square a variable row table' do
    Helper::make_square([[1], [1,2,3], [1,2]]).should == [[1,nil,nil], [1,2,3], [1,2,nil]]
  end

  it 'should square messy table' do
    Helper::make_square([[1],[],[1,2,3],[1],[1],[1,2,3,4,5,6]]).should == [[1,nil,nil,nil,nil,nil], [nil,nil,nil,nil,nil,nil], [1,2,3,nil,nil,nil], [1,nil,nil,nil,nil,nil], [1,nil,nil,nil,nil,nil], [1,2,3,4,5,6]]
  end

end