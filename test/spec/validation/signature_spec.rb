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
  
  it "should have allows? and blocks? with opposite answers" do
    signature = signature {
      validation :age, is >= 18, :bad_age
    }
    signature.allows?().should be_false
    signature.blocks?().should be_true
  end
  
  it "should allow valid data" do
    signature = signature {
      validation :age, is >= 18, :bad_age
    }
    signature.allows?(:age => 18).should be_true
    signature.allows?(:age => 20).should be_true
  end
  
  it "should block invalid data" do
    signature = signature {
      validation :age, is >= 18, :bad_age
    }
    signature.blocks?().should be_true
    signature.blocks?(:age => "").should be_true
    signature.blocks?(:age => "   ").should be_true
    signature.blocks?(:age => nil).should be_true
    signature.blocks?(:age => -10).should be_true
    signature.blocks?(:age => 17).should be_true
    signature.blocks?(:age => 17.99999).should be_true
  end
  
  it "should support missing in disjunction" do
    signature = signature {
      validation :mail, mail | missing, :bad_mail
    }
    signature.allows?(:mail => "blambeau@hotmail.com").should be_true
    signature.blocks?(:mail => "blambeau@hotmail.com").should be_false
    signature.allows?(:mail => "").should be_true
    signature.allows?(:mail => "   ").should be_true
    signature.allows?(:mail => nil).should be_true
  end
  
  it "should allow Boolean to be like a ruby class" do
    signature = signature {
      validation :newsletter, Boolean, :bad_newsletter
    }
    signature.allows?(:newsletter => true).should be_true
    signature.allows?(:newsletter => false).should be_true
    signature.allows?(:newsletter => "true").should be_true
    signature.allows?(:newsletter => "false").should be_true
  end
  
  it "should allow String ruby class as validator" do
    signature = signature {
      validation :name, String, :bad_name
    }
    signature.allows?(:name => "blambeau").should be_true
    signature.allows?(:name => "").should be_true
    signature.blocks?(:name => nil).should be_true
    signature.blocks?().should be_true
  end
  
  it "should allow Integer ruby class as validator" do
    signature = signature {
      validation :age, Integer, :bad_age
    }
    signature.allows?(:age => 12).should be_true
    signature.allows?(:age => "12").should be_true
    signature.blocks?(:age => "hello").should be_true
    signature.blocks?().should be_true
  end
  
  it "should allow Float ruby class as validator" do
    signature = signature {
      validation :temperature, Float, :bad_temperature
    }
    signature.allows?(:temperature => 12).should be_true
    signature.allows?(:temperature => 12.0).should be_true
    signature.allows?(:temperature => "12").should be_true
    signature.allows?(:temperature => "12.0").should be_true
    signature.blocks?(:temperature => "hello").should be_true
    signature.blocks?().should be_true
  end
  
  it "should allow ruby classes as left part of a disjunction" do
    signature = signature {
      validation :age, missing | Integer, :bad_age
    }
    signature.allows?(:age => 12).should be_true
    signature.allows?(:age => "").should be_true
    signature.allows?(:age => nil).should be_true
    signature.blocks?(:age => "hello").should be_true
  end
  
  it "should allow ruby classes as right part of a disjunction" do
    signature = signature {
      validation :age, Integer | missing, :bad_age
    }
    signature.allows?(:age => 12).should be_true
    signature.allows?(:age => "").should be_true
    signature.allows?(:age => nil).should be_true
    signature.blocks?(:age => "hello").should be_true
  end
  
  it "should allow ruby classes as left part of a conjunction" do
    signature = signature {
      validation :age, (is > 10) & Integer, :bad_age
    }
    signature.allows?(:age => 12).should be_true
    signature.allows?(:age => "").should be_false
    signature.allows?(:age => nil).should be_false
    signature.blocks?(:age => 7).should be_true
    signature.blocks?(:age => "hello").should be_true
  end
  
  it "should allow ruby classes as right part of a conjunction" do
    signature = signature {
      validation :age, Integer & (is > 10), :bad_age
    }
    signature.allows?(:age => 12).should be_true
    signature.allows?(:age => "").should be_false
    signature.allows?(:age => nil).should be_false
    signature.blocks?(:age => 7).should be_true
    signature.blocks?(:age => "hello").should be_true
  end
  
end