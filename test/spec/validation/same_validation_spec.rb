require 'waw'
describe "same proposed validation" do

  # Creates a signature
  def mail
    @same_validator ||= ::Waw::Validation.signature {
      validation [:pass, :confirm], mandatory & same, :bad_mail
    }
  end
  
  it "should block invalid combinations" do
    mail.blocks?(:pass => nil).should be_true
    mail.blocks?(:confirm => "").should be_true
    mail.blocks?(:pass => "", :confirm => "").should be_true
    mail.blocks?(:pass => nil, :confirm => "blambeau").should be_true
    mail.blocks?(:pass => "blambeau", :confirm => "").should be_true
  end

  it "should not block valid combinations" do
    mail.blocks?(:pass => "blambeau", :confirm => "blambeau").should be_false
  end

  
end