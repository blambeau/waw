require 'waw'

describe ::Waw::Validation::Signature do
  
  # Creates a signature
  def signature(&block)
    ::Waw::Validation.signature(&block)
  end
  
  it "should allow user-friendly DSL" do
    signature {
      validation :mail, mandatory & mail, :bad_email
      validation [:password, :confirm], mandatory & equal, :password_dont_match
    }.should_not be_nil
  end
  
  it "should support missing in disjunction" do
    sigature = signature {
      validation :mail, mail | missing, :bad_mail
    }
    signature.allows?(:mail => "blambeau@hotmail.com").should be_true
    signature.blocks?(:mail => "blambeau@hotmail.com").should be_false
    signature.allows?(:mail => "").should be_true
    signature.allows?(:mail => "   ").should be_true
    signature.allows?(:mail => nil).should be_true
  end
  
end