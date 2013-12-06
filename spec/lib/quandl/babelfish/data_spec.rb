require 'spec_helper'

describe Quandl::Babelfish::Data do
  let(:data_args){ [] }
  subject{ Quandl::Babelfish::Data.new(*data_args) }
  
  its(:to_a){ should eq [] }
  its(:headers){ should eq [] }
    
  context "given Array" do
    let(:data_args){ [ [[1,2,3],[4,3,5]] ] }
    its(:to_a){ should eq [[1,2,3],[4,3,5]] }
    its(:headers){ should eq [] }
  end
  
  context "given Array with :headers" do
    let(:data_args){ [ [[1,2,3],[4,3,5]], { headers: ['Date', 'C1', 'C2'] } ] }
    its(:to_a){ should eq [[1,2,3],[4,3,5]] }
    its(:headers){ should eq ['Date', 'C1', 'C2'] }
  end
  
  context "given junk headers: Float" do
    let(:data_args){ [ 2, { headers: 1.2 } ] }
    its(:to_a){ should eq [nil,nil] }
    its(:headers){ should eq [] }
  end
  context "given junk headers: String" do
    let(:data_args){ [ 2, { headers: '1.2' } ] }
    its(:to_a){ should eq [nil,nil] }
    its(:headers){ should eq [] }
  end
    
end