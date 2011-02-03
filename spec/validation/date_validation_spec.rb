require File.expand_path('../../spec_helper', __FILE__)
describe "date proposed validation" do

  # Creates a signature
  def date
    @date_validator ||= ::Waw::Validation.signature {
      validation :date, date, :bad_date
    }
  end
  
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
  end

  it "should allow valid dates" do
    date.allows?(:date => "2010/04/25").should be_true
    date.allows?(:date => "25/04/2010").should be_true
  end

  it "should block invalid dates" do
    date.allows?(:date => "2010/33/75").should be_false
    date.allows?(:date => "2010/02/31").should be_false
  end

end