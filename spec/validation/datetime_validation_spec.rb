require File.expand_path('../../spec_helper', __FILE__)
describe "datetime proposed validation" do

  describe "with default options" do
    
    let(:date){ 
      @date_validator ||= ::Waw::Validation.signature {
        validation [:date, :time], datetime, :bad_date
      }
    }
    
    it "should block missing values" do
      date.blocks?(:date => nil).should be_true
      date.blocks?(:date => "").should be_true
      date.blocks?(:date => "   ").should be_true
    end

    it "should be robust to strange values" do
      date.blocks?(:date => nil).should be_true
      date.blocks?(:date => 12).should be_true
      date.blocks?(:date => self).should be_true
      date.blocks?(:date => Class).should be_true
      date.blocks?(:date => self).should be_true
      date.blocks?(:date => "hello", :time => "12:16").should be_true
    end

    it "should allow valid date/time pairs" do
      date.allows?({:date => "2010/04/25", :time => "12:15"}).should be_true
      date.allows?({:date => "2010/04/25", :time => "00:00"}).should be_true
    end
  
    it 'should correctly convert date/time pairs' do
      result, converted = date.apply({:date => "2010/04/25", :time => "12:15"})
      converted.should == {:date => Date.parse("2010/04/25"), :time => Time.parse("2010/04/25 12:15")}
    end
  
    it "should block invalid dates" do
      date.blocks?(:date => "65/12/2010", :time => "12:16").should be_true
      date.blocks?(:date => "2010/10/12", :time => "28:16").should be_true
    end
  
  end

  describe "when a specific date format has been set" do
    
    let(:date){ 
      @date_validator ||= ::Waw::Validation.signature {
        validation [:date, :time], datetime(:date_format => "%d/%m/%y"), :bad_date
      }
    }
    
    it "should block non-conforming dates" do
      date.blocks?(:date => "2010/12/1", :time => "12:16").should be_true
    end
    
    it "should allow conforming dates" do
      date.allows?(:date => "2/12/10", :time => "12:16").should be_true
    end
    
    it 'should correctly convert date/time pairs' do
      result, converted = date.apply({:date => "25/04/10", :time => "11:00"})
      converted.should == {:date => Date.parse("2010/04/25"), :time => Time.parse("2010/04/25 11:00")}
    end

  end
    
  describe "when a default time should be provided" do
    
    let(:date){ 
      @date_validator ||= ::Waw::Validation.signature {
        validation :time, regexp(/^\d{2}:\d{2}$/) | default('12:15'), :bad_time
        validation [:date, :time], datetime, :bad_date
      }
    }

    it 'should correctly convert date/time pairs' do
      result, converted = date.apply({:date => "2010/04/25", :time => "11:00"})
      converted.should == {:date => Date.parse("2010/04/25"), :time => Time.parse("2010/04/25 11:00")}
    end

    it 'should correctly convert when time is missing' do
      result, converted = date.apply({:date => "2010/04/25"})
      converted.should == {:date => Date.parse("2010/04/25"), :time => Time.parse("2010/04/25 12:15")}
    end

    it "should block invalid date/time pairs" do
      date.blocks?(:date => "65/12/2010", :time => "12:16").should be_true
      date.blocks?(:date => "2010/10/12", :time => "28:16").should be_true
    end
    
  end
  
end