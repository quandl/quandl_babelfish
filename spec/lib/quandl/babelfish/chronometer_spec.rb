require 'spec_helper'

include Quandl::Babelfish
describe Chronometer do

  it 'should calculate frequency = daily' do
    table = [['2012-01-01','1','2'],['2012-01-02','3','4'],['2012-01-03','5','6']]
    frequency = Chronometer.process(table)
    frequency.should == 'daily'
  end

  it 'should calculate frequency = monthly' do
    table = [['2012-01-01','1','2'],['2012-02-01','3','4'],['2012-04-01','5','6'],
             ['2012-04-01','1','2'],['2012-05-01','3','4'],['2012-06-01','5','6']]
    frequency = Chronometer.process(table)
    frequency.should == 'monthly'
  end

  it 'should calculate frequency = quarterly' do
    table = [['2012-01-01','1','2'],['2012-04-01','3','4'],['2012-07-01','5','6'],
             ['2012-10-01','1','2'],['2013-01-01','3','4'],['2012-04-01','5','6']]
    frequency = Chronometer.process(table)
    frequency.should == 'quarterly'
  end

  it 'should calculate frequency = quarterly' do
    table = [['2012-01-01','1','2'],['2012-07-01','3','4'],['2013-01-01','5','6'],
             ['2013-07-01','1','2']]
    frequency = Chronometer.process(table)
    frequency.should == 'quarterly'
  end

  it 'should calculate frequency = annual' do
    table = [['2008-01-01','1','2'],['2008-12-01','3','4'],['2010-01-01','5','6'],
             ['2011-01-01','1','2'],['2013-01-01','5','6']]
    frequency = Chronometer.process(table)
    frequency.should == 'annual'
  end

  it 'should calculate frequency = daily if only one row' do
    table = [['2010-01-01','1','2']]
    frequency = Chronometer.process(table)
    frequency.should == 'daily'
  end

  it 'should calculate frequency = nil if nil table passed' do
    frequency = Chronometer.process(nil)
    frequency.should == nil
  end

end