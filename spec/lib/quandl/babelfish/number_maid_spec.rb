require 'spec_helper'

include Quandl::Babelfish
describe NumberMaid do

  it "should handle '1.432,32' i.e. 1432.32 in Canadian format" do
    NumberMaid::init(:decimal_mark => ',')
    NumberMaid::clean('1.432,32').should == 1432.32
    NumberMaid::init({})   #reset settings
  end

  it "should remove spaces that act as 000 separators" do
    NumberMaid::clean('12 345').should == 12345
  end

  it "should accept commas that act as 000 separators" do
    NumberMaid::clean('12,345').should == 12345
  end

  it "should handle scientific notation" do
    NumberMaid::clean('2.1e2').should == 210
    NumberMaid::clean('2.1 E 2').should == 210
    NumberMaid::clean('2.1 E+2').should == 210
    NumberMaid::clean('210 E -2').should == 2.1
    NumberMaid::clean('2.1 e +2').should == 210
    NumberMaid::clean('2.1*10^2').should == 210
    NumberMaid::clean('2.1 X102').should == 210
    NumberMaid::clean('sci not: -2.1 * 10 2 Ghz').should == -210
  end

  it "should mulitiply number if cell contains million or billion" do
    NumberMaid::clean('35 million').should == 35000000
    NumberMaid::clean('42 billion').should == 42000000000
  end

  it "should handle a plain integer" do
    NumberMaid::clean('1').should == 1
  end

  it "should handle a plain negative integer" do
    NumberMaid::clean('-1').should == -1
    NumberMaid::clean('(1)').should == -1
  end

  it "should handle a plain float" do
    NumberMaid::clean('1.1').should == 1.1
  end

  it "should handle a plain negative float" do
    NumberMaid::clean('-1.1').should == -1.1
    NumberMaid::clean('(1.1)').should == -1.1
  end

  it "should ignore extraneous characters" do
    NumberMaid::clean('a1.1a').should == 1.1
    NumberMaid::clean('And the answer is 1.1').should == 1.1
    NumberMaid::clean('1.1 for the win').should == 1.1
    NumberMaid::clean('1.1%').should == 1.1
    NumberMaid::clean('-1.1%').should == -1.1
    NumberMaid::clean('(1.1%)').should == -1.1
    NumberMaid::clean('[1.1%]').should == 1.1
    NumberMaid::clean('/1.1%/').should == 1.1
    NumberMaid::clean('{1.1%}').should == 1.1
    NumberMaid::clean('1.1Ghz').should == 1.1
    NumberMaid::clean('(1.1Ghz)').should == -1.1
  end

  it 'should get nothing' do
    NumberMaid::clean('').should be_nil
    NumberMaid::clean('super').should be_nil
    NumberMaid::clean('This is great. And then she said...').should be_nil
    NumberMaid::clean(' ').should be_nil
    NumberMaid::clean('.').should be_nil
    NumberMaid::clean('*').should be_nil
    NumberMaid::clean('(not a number dude)').should be_nil
    NumberMaid::clean('(O.OO)').should be_nil
    NumberMaid::clean('#!!@#$%.^&*())').should be_nil # The cartoon swear test
  end

  it "should handle this stupid one:  '(A1) 249.34' " do
    NumberMaid::clean('(A1) 234.3').should == 234.3
    NumberMaid::clean('234.3{3}').should == 234.3
    NumberMaid::clean('234.3[yes]').should == 234.3
    NumberMaid::clean('(234.3)').should == -234.3
    NumberMaid::clean('est. 32.8').should == 32.8
    NumberMaid::clean('(a6) 9,008').should == 9008
  end

  it "should handle: '32.4/66.2'" do
    NumberMaid::clean('32.4/18.8').should == 32.4
    NumberMaid::clean('32.4 / 18.8').should == 32.4
    NumberMaid::clean('32.4 to 18.8').should == 32.4
    NumberMaid::clean('273.1/281.7').should == 273.1
    NumberMaid::clean('1,013/1,026').should == 1013
    NumberMaid::clean('1,013/1,026').should == 1013
    NumberMaid::clean('~14,508/14,512').should == 14508
  end

  it "should convert many numbers" do
    numbers = [2011,'2012*[123]',2013,2014]

    numbers = NumberMaid::clean(numbers)
    numbers.length.should == 4
    numbers[0].should == 2011
    numbers[1].should == 2012
    numbers[2].should == 2013
    numbers[3].should == 2014
  end

  it "should leave nil's for invalid cells" do
    numbers = [2011,2012,'abcdef',2014]
    numbers = NumberMaid::clean(numbers)
    numbers.length.should == 4
    numbers[0].should == 2011
    numbers[1].should == 2012
    numbers[2].should be_nil
    numbers[3].should == 2014

  end

  it "should handle crazy long decimals" do
    numbers = NumberMaid::clean('0.12345678901234567890')
    numbers.should == 0.12345678901235
  end

  it "should handle pound in front" do
    NumberMaid::clean('#N/A').should be_nil
  end


end
