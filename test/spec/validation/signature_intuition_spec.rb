require 'waw'
describe ::Waw::Validation::Signature do

  # Creates a signature
  def signature(&block)
    ::Waw::Validation.signature(&block)
  end
  
  it "should not be disjunction sensitive on missing" do
    signature = signature {
      validation :mail, mail | missing, :bad_mail
    }
    signature.first_converted(:mail => "blambeau@hotmail.com").should == "blambeau@hotmail.com"
    signature.first_converted().should be_nil

    signature = signature {
      validation :mail, missing | mail, :bad_mail
    }
    signature.first_converted(:mail => "blambeau@hotmail.com").should == "blambeau@hotmail.com"
    signature.first_converted().should be_nil
  end
  
  it "should not be disjunction sensitive on default" do
    signature = signature {
      validation :mail, mail | default("info@hotmail.com"), :bad_mail
    }
    signature.first_converted(:mail => "blambeau@hotmail.com").should == "blambeau@hotmail.com"
    signature.first_converted().should == "info@hotmail.com"

    signature = signature {
      validation :mail, default("info@hotmail.com") | mail, :bad_mail
    }
    signature.first_converted(:mail => "blambeau@hotmail.com").should == "blambeau@hotmail.com"
    signature.first_converted().should == "info@hotmail.com"
  end
  
end