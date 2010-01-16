require 'waw'
describe "missing validation" do

  # Creates a signature
  def missing(&block)
    if block
      ::Waw::Validation.signature(&block)
    else
      @missing_validator ||= ::Waw::Validation.signature {
        validation :mail, missing, :bad_mail
      }
    end
  end
  
  it "should allow missing values" do
    missing.allows?(:mail => nil).should be_true
    missing.allows?(:mail => "").should be_true
    missing.allows?(:mail => "   ").should be_true
  end
  
  it "should block non missing values" do
    missing.blocks?(:mail => "blambeau@gmail.com").should be_true
  end
  
  it "should be robust to strange values" do
    missing.blocks?(:mail => 1234567).should be_true
    missing.blocks?(:mail => self).should be_true
    missing.blocks?(:mail => Object.new).should be_true
    missing.blocks?(:mail => Class).should be_true
  end
  
  it "should correctly convert missings to nil" do
    missing.first_converted(:mail => "").should be_nil
    missing.first_converted(:mail => nil).should be_nil
    missing.first_converted(:mail => "    ").should be_nil
  end

  it "should never change non missings" do
    missing.first_converted(:mail => "bla").should == "bla"
    missing.first_converted(:mail => 12).should == 12
  end
  
end