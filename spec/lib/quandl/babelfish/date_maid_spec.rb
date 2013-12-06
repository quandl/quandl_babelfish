require 'spec_helper'

include Quandl::Babelfish
describe NumberMaid do

  it 'should return an exception because month and day are ambiguous YYYY' do
    dates = ['01/01/2011','1/2/2011','2/3/2011','11/1/2011']
    lambda {DateMaid::sweep(dates)}.should raise_error(Quandl::Errors::GuessDateFormat)
  end

  it 'should return an exception because month and day are ambiguous YY' do
    dates = ['01/01/11','1/2/11','1/3/11','11/1/11']
    lambda {DateMaid::sweep(dates)}.should raise_error(Quandl::Errors::GuessDateFormat)
  end

  it 'should remove unwanted characters from dates (eg. &nbsp;)' do
    a=194.chr+160.chr
    dates = ["2005#{a}","#{a}2006",'2007','2008']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2005,12,31)
    dates[1].should == Date.new(2006,12,31)
    dates[2].should == Date.new(2007,12,31)
    dates[3].should == Date.new(2008,12,31)
  end

  it 'should transform a parseable date into valid data (US) YYYY year' do
    dates = ['01/10/2011','1/11/2011','1/12/2011','1/13/2011']

    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,10)
    dates[1].should  == Date.new(2011,1,11)
    dates[2].should  == Date.new(2011,1,12)
    dates[3].should  == Date.new(2011,1,13)
  end

  it 'should calculate dates from UNIX timestamps (to UTC)' do
    dates = [1279324800,1279411200,1279497600,1279584000]

    dates  = DateMaid::sweep(dates)
    dates[0].should  == Date.new(2010,7,17)
    dates[1].should  == Date.new(2010,7,18)
    dates[2].should  == Date.new(2010,7,19)
    dates[3].should  == Date.new(2010,7,20)
  end

  it 'should transform a parseable date into valid data (US) YY year' do
    dates = ['01/10/11','1/11/11','1/12/11','1/13/11,4']
    dates  = DateMaid::sweep(dates)
    dates[0].should  == Date.new(2011,1,10)
    dates[1].should  == Date.new(2011,1,11)
    dates[2].should  == Date.new(2011,1,12)
    dates[3].should  == Date.new(2011,1,13)
  end

  it 'should throw error when 1 of the dates is invalid' do
    # It ain't a leap year
    dates = ['2/29/2011','01/01/2011','1/2/2011','1/3/2011','12/1/2011']
    lambda {DateMaid::sweep(dates)}.should raise_error(Quandl::Errors::InvalidDate)
  end

  it 'should strip invalid parseable dates (US)' do
    dates = ['01/01/2011','1/2/2011','1/3/2011','12/17/2011']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,1)
    dates[1].should == Date.new(2011,1,2)
    dates[2].should == Date.new(2011,1,3)
    dates[3].should == Date.new(2011,12,17)
  end

  it 'should transform a parseable date into valid data (ISO)' do
    dates = ['2011-01-01','2011-01-02','2011-01-03','2011-02-04']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,1)
    dates[1].should == Date.new(2011,1,2)
    dates[2].should == Date.new(2011,1,3)
    dates[3].should == Date.new(2011,2,4)
  end

  it 'should parse ISO dates' do
    # It ain't a leap year
    dates = ['2011-01-01','2011-01-02','2011-01-03','2011-02-04']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,1)
    dates[1].should == Date.new(2011,1,2)
    dates[2].should == Date.new(2011,1,3)
    dates[3].should == Date.new(2011,2,4)
  end

  it 'should handle JP dates YYYY/MM/DD' do
    dates = ['2011/01/01','2011/01/2','2011/1/03','2011/2/4']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,1)
    dates[1].should == Date.new(2011,1,2)
    dates[2].should == Date.new(2011,1,3)
    dates[3].should == Date.new(2011,2,4)
  end

  it 'should handle manually formatted dates (EU)' do
    dates = ['01/01/2011','2/1/2011','3/1/2011','1/12/2011']
    DateMaid::init(:format => '%d/%m/%Y')
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,1)
    dates[1].should == Date.new(2011,1,2)
    dates[2].should == Date.new(2011,1,3)
    dates[3].should == Date.new(2011,12,1)
    DateMaid::init({})
  end

  it 'should handle manually formatted dates (EU, strip)' do
    dates = ['01/01/2011','2/1/2011','3/1/2011','1/12/2011']
    DateMaid::init(:format => '%d/%m/%Y')
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,1)
    dates[1].should == Date.new(2011,1,2)
    dates[2].should == Date.new(2011,1,3)
    dates[3].should == Date.new(2011,12,1)
    DateMaid::init({})
  end

  it 'should transform a year into an end of year date' do
    dates = ['2011','2010','2009','2008','2007','2006']

    DateMaid::init({:frequency => 'annual'})
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,12,31)
    dates[1].should == Date.new(2010,12,31)
    dates[2].should == Date.new(2009,12,31)
    dates[3].should == Date.new(2008,12,31)
    DateMaid::init({})
  end

  it 'should transform a year into an end of year date with gaps' do
    dates = ['2011','2010','2009','2008','2007','2006']
    DateMaid::init({:frequency => 'annual'})
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,12,31)
    dates[1].should == Date.new(2010,12,31)
    dates[2].should == Date.new(2009,12,31)
    dates[3].should == Date.new(2008,12,31)
    DateMaid::init({})
  end

  it 'should transform a YYYY.0 into an end of year date' do
    dates = ['2011.0','2010.0','2009.0','2008.0','2007.0','2006.0']
    DateMaid::init({:frequency => 'annual'})
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,12,31)
    dates[1].should == Date.new(2010,12,31)
    dates[2].should == Date.new(2009,12,31)
    dates[3].should == Date.new(2008,12,31)
    DateMaid::init({})
  end

  it 'should transform a YYYY.1 into an end of month date' do
    dates = ['2011.1','2010.2','2009.3','2008.10','2007.11','2006.12']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,01,31)
    dates[1].should == Date.new(2010,02,28)
    dates[2].should == Date.new(2009,03,31)
    dates[3].should == Date.new(2008,10,31)
    dates[4].should == Date.new(2007,11,30)
    dates[5].should == Date.new(2006,12,31)
  end


  it 'should transform yyyy-mm to end of month' do
    dates = ['2011-01','2011-02','2011-03','2011-04']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,31)
    dates[1].should == Date.new(2011,2,28)
    dates[2].should == Date.new(2011,3,31)
    dates[3].should == Date.new(2011,4,30)
  end

  it 'should transform yyyy/mm to end of month' do
    dates = ['2011/01','2011/02','2011/03','2011/04,4']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,31)
    dates[1].should == Date.new(2011,2,28)
    dates[2].should == Date.new(2011,3,31)
    dates[3].should == Date.new(2011,4,30)
  end

  it 'should transform yyyyMmm to end of month' do
    dates = ['2011M01','2011M02','2011M03','2011M04']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,31)
    dates[1].should == Date.new(2011,2,28)
    dates[2].should == Date.new(2011,3,31)
    dates[3].should == Date.new(2011,4,30)
  end

  it 'should transform yyyyWww to the first Friday of the week of the year' do
    dates = ['1998W52','1998W53','1999W01']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(1998,12,25)
    dates[1].should == Date.new(1999,1,1)
    dates[2].should == Date.new(1999,1,8)
  end

  it 'should fail on invalid YYYY-MM formats' do
    dates = ['2011-13','2011-AA','2011-01','2011-02','2011-03','2011-04']
    lambda {DateMaid::sweep(dates)}.should raise_error(Quandl::Errors::InvalidDate)
  end

  it 'should parse YYYY-MM formats' do
    dates = ['2011-01','2011-02','2011-03','2011-04']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,31)
    dates[1].should == Date.new(2011,2,28)
    dates[2].should == Date.new(2011,3,31)
    dates[3].should == Date.new(2011,4,30)
  end

  it 'should transform mm-yyyy to end of month' do
    dates = ['01-2011','02-2011','3-2011','4-2011']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,31)
    dates[1].should == Date.new(2011,2,28)
    dates[2].should == Date.new(2011,3,31)
    dates[3].should == Date.new(2011,4,30)
  end

  it 'should transform mm/yyyy to end of month' do
    dates = ['01/2011','02/2011','3/2011','4/2011']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,31)
    dates[1].should == Date.new(2011,2,28)
    dates[2].should == Date.new(2011,3,31)
    dates[3].should == Date.new(2011,4,30)
  end

  it 'should transform yyyymm (no delimiter) to end of month' do
    dates = ['201101','201102','201103','201104']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,31)
    dates[1].should == Date.new(2011,2,28)
    dates[2].should == Date.new(2011,3,31)
    dates[3].should == Date.new(2011,4,30)
  end

  it 'should transform yyyymm (no delimiter) to end of month' do
    # Only 5 digits
    dates = ['201101','201102','201103','201104']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,31)
    dates[1].should == Date.new(2011,2,28)
    dates[2].should == Date.new(2011,3,31)
    dates[3].should == Date.new(2011,4,30)
  end

  it 'should transform YYYY-MMM to end of month' do
    dates = ['2011-jan','2011-feb','2011-mar','2011-apr']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,31)
    dates[1].should == Date.new(2011,2,28)
    dates[2].should == Date.new(2011,3,31)
    dates[3].should == Date.new(2011,4,30)
  end

  it 'should transform YYYY MMM to end of month' do
    dates = ['2011 jan','2011 feb','2011 mar','2011 apr']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,31)
    dates[1].should == Date.new(2011,2,28)
    dates[2].should == Date.new(2011,3,31)
    dates[3].should == Date.new(2011,4,30)
  end

  it 'should transform YYYY MMM to end of month (CAPS)' do
    dates = ['2011 JAN','2011 FEB','2011 MAR','2011 APR']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,31)
    dates[1].should == Date.new(2011,2,28)
    dates[2].should == Date.new(2011,3,31)
    dates[3].should == Date.new(2011,4,30)
  end

  it 'should transform YYYY MMM to end of month (Camel)' do
    dates = ['2011 Jan','2011 Feb','2011 Mar','2011 Apr,4']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,31)
    dates[1].should == Date.new(2011,2,28)
    dates[2].should == Date.new(2011,3,31)
    dates[3].should == Date.new(2011,4,30)
  end

  it 'should transform MMM-YYYY to end of month' do
    dates = ['jan-2011','feb-2011','mar-2011','apr-2011,4']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,31)
    dates[1].should == Date.new(2011,2,28)
    dates[2].should == Date.new(2011,3,31)
    dates[3].should == Date.new(2011,4,30)
  end

  it 'should transform MMM-YYYY to end of month (strip)' do
    dates = ['jan-2011','feb-2011','mar-2011','apr-2011']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,31)
    dates[1].should == Date.new(2011,2,28)
    dates[2].should == Date.new(2011,3,31)
    dates[3].should == Date.new(2011,4,30)
  end

  it 'should transform MMMYYYY to end of month (No delimiter)' do
    dates = ['jan2011','feb2011','mar2011','apr2011']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,31)
    dates[1].should == Date.new(2011,2,28)
    dates[2].should == Date.new(2011,3,31)
    dates[3].should == Date.new(2011,4,30)
  end

  it 'should transform MMMYYYY to end of month (No delimiter, strip)' do
    dates = ['jan2011','feb2011','mar2011','apr2011']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,31)
    dates[1].should == Date.new(2011,2,28)
    dates[2].should == Date.new(2011,3,31)
    dates[3].should == Date.new(2011,4,30)
  end


  it 'should transform YYYYMMM to end of month (No delimiter) even if one date is partially valid' do
    dates = ['2011JAN','2011FEB','2011MAR','2011APR,4']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,31)
    dates[1].should == Date.new(2011,2,28)
    dates[2].should == Date.new(2011,3,31)
    dates[3].should == Date.new(2011,4,30)
  end

  it 'should transform YYYYMMM to end of month (No delimiter)' do
    dates = ['2011JAN','2011FEB','2011MAR','2011APR,4']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,31)
    dates[1].should == Date.new(2011,2,28)
    dates[2].should == Date.new(2011,3,31)
    dates[3].should == Date.new(2011,4,30)
  end

  it 'should transform YYYY-MMM-DD to date' do
    dates = ['2011-jan-01','2011-feb-01','2011-mar-3','2011-apr-4']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,1)
    dates[1].should == Date.new(2011,2,1)
    dates[2].should == Date.new(2011,3,3)
    dates[3].should == Date.new(2011,4,4)
  end

  it 'should transform YYYY-MMM-DD to date (strip)' do
    dates = ['2011-jan-01','2011-feb-01','2011-mar-3','2011-apr-4']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,1)
    dates[1].should == Date.new(2011,2,1)
    dates[2].should == Date.new(2011,3,3)
    dates[3].should == Date.new(2011,4,4)
  end


  it 'should transform DD-MMM-YYYY to date' do
    dates = ['01-jan-2011','01-feb-2011','3-mar-2011','4-apr-2011']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,1)
    dates[1].should == Date.new(2011,2,1)
    dates[2].should == Date.new(2011,3,3)
    dates[3].should == Date.new(2011,4,4)
  end

  it 'should transform DD-MMM-YYYY to date (strip)' do
    dates = ['01-jan-2011','01-feb-2011','3-mar-2011','4-apr-2011']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,1)
    dates[1].should == Date.new(2011,2,1)
    dates[2].should == Date.new(2011,3,3)
    dates[3].should == Date.new(2011,4,4)
  end

  it 'should transform YYYYMMMDD to date (no delimiters)' do
    dates = ['2011jan01','2011feb01','2011mar3','2011apr4']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,1)
    dates[1].should == Date.new(2011,2,1)
    dates[2].should == Date.new(2011,3,3)
    dates[3].should == Date.new(2011,4,4)
  end

  it 'should transform YYYYMMMDD to date (no delimiters, strip)' do
    dates = ['2011jan01','2011feb01','2011mar3','2011apr4']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,1)
    dates[1].should == Date.new(2011,2,1)
    dates[2].should == Date.new(2011,3,3)
    dates[3].should == Date.new(2011,4,4)
  end

  it 'should transform DD-MMM-YYYY to date (no delimiters)' do
    dates = ['01jan2011','01feb2011','3mar2011','4apr2011']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,1)
    dates[1].should == Date.new(2011,2,1)
    dates[2].should == Date.new(2011,3,3)
    dates[3].should == Date.new(2011,4,4)
  end

  it 'should transform DD-MMM-YYYY to date (no delimiters, strip)' do
    dates = ['01jan2011','01feb2011','3mar2011','4apr2011']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,1,1)
    dates[1].should == Date.new(2011,2,1)
    dates[2].should == Date.new(2011,3,3)
    dates[3].should == Date.new(2011,4,4)
  end

  it 'should transform yyyy-Qq to end of quarter' do
    dates = ['2011-Q1','2011-Q2','2011-Q3','2011-Q4']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,3,31)
    dates[1].should == Date.new(2011,6,30)
    dates[2].should == Date.new(2011,9,30)
    dates[3].should == Date.new(2011,12,31)
  end

  it 'should transform yyyy-Qq to end of quarter (strip)' do
    dates = ['2011-Q1','2011-Q2','2011-Q3','2011-Q4']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,3,31)
    dates[1].should == Date.new(2011,6,30)
    dates[2].should == Date.new(2011,9,30)
    dates[3].should == Date.new(2011,12,31)
  end

  it 'should transform yyyyQq to end of quarter (no delimiter)' do
    dates = ['2011q1','2011Q2','2011q3','2011Q4,4']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2011,3,31)
    dates[1].should == Date.new(2011,6,30)
    dates[2].should == Date.new(2011,9,30)
    dates[3].should == Date.new(2011,12,31)
  end

  it 'should handle white space at front and back of dates' do
    dates = ['  2012q2   ']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2012,6,30)
  end

  it 'should handle white space at front and back of dates (2)' do
    dates = ['  2012   ']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2012,12,31)
  end

  it 'should know 1871.10 is October' do
    dates = ['1871.10']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(1871,10,31)
  end

  it 'should handle 1990' do
    dates = ['1990']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(1990,12,31)
  end

  it 'should handle 1990 - 1995' do
    dates = ['1990 - 1995']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(1990,12,31)
  end

  it 'should transform YYYYMMDD to date' do
    dates = ['20010101','20110518','19701111','19770208','19900531']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2001,1,1)
    dates[1].should == Date.new(2011,5,18)
    dates[2].should == Date.new(1970,11,11)
    dates[3].should == Date.new(1977,2,8)
    dates[4].should == Date.new(1990,5,31)
  end

  it 'should transform Jan 30, 1955' do
    dates = ['Jan 30, 1955']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(1955,1,30)
  end

  it 'should transform Jan-68' do
    dates = ['Dec-68','Jan-69']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(1968,12,31)
    dates[1].should == Date.new(1969,1,31)
  end


  it 'should transform Jul-01' do
    dates = ['Jul-01','Aug-01']
    dates  = DateMaid::sweep(dates)
    dates[1].should == Date.new(2001,8,31)
    dates[0].should == Date.new(2001,7,31)
  end

  it 'should transform Dec-31-12' do
    dates = ['Dec-31-12']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2012,12,31)
  end

  it 'should format YYYY/MM/DD' do
    dates = ['20010101','20110518','19701111','19770208','19900531']
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2001,1,1)
    dates[1].should == Date.new(2011,5,18)
    dates[2].should == Date.new(1970,11,11)
    dates[3].should == Date.new(1977,2,8)
    dates[4].should == Date.new(1990,5,31)
  end

  it 'should strip days of the week' do
    pending "Not implemented yet"
    dates = ["Tuesday, April 30, 2013","Mon april 29, 2012"]
    dates  = DateMaid::sweep(dates)
    dates[0].should == Date.new(2013,04,30)
    dates[1].should == Date.new(2012,04,29)
  end


end