require 'waw'
describe ::Waw::Validation::ArrayValidations do

  it "should be correctly installed" do
    Waw::Validation.array.should == Waw::Validation::ArrayValidations
    Waw::Validation.array[Integer].should_not be_nil
    Waw::Validation.array[Integer].is_a?(Waw::Validation::Validator).should be_true
  end
  
  it "should be autorized in a signature" do
    signature = Waw::Validation.signature {
      validation :id, array[Integer], :bad_array
    }
  end
  
  it "should be correctly block or allow data" do
    signature = Waw::Validation.signature {
      validation :id, array[Integer], :bad_array
    }
    signature.allows?(:id => nil).should be_false
    signature.allows?(:id => 1).should be_false
    signature.allows?(:id => []).should be_true
    signature.allows?(:id => [1, 2]).should be_true
    signature.allows?(:id => ["1", "2"]).should be_true
    signature.allows?(:id => ["1", "hello"]).should be_false
    signature.allows?(:id => ["1", nil]).should be_false
    signature.allows?(:id => ["1", ""]).should be_false

    signature = Waw::Validation.signature {
      validation :id, array[String], :bad_array
    }
    signature.allows?(:id => []).should be_true
  end
  
  it "should get converted sub values" do
    signature = Waw::Validation.signature {
      validation :id, array[Integer], :bad_array
    }
    signature.first_converted(:id => [1]).should == [1]
    signature.first_converted(:id => ["1"]).should == [1]
    signature.first_converted(:id => ["1", "2"]).should == [1, 2]
  end
  
  it "should allow complex validators" do
    signature = Waw::Validation.signature {
      validation :id, array[Integer | missing], :bad_array
    }
    signature.allows?(:id => nil).should be_false
    signature.allows?(:id => ["1", "2"]).should be_true
    signature.allows?(:id => ["1", nil]).should be_true
    signature.allows?(:id => ["1", ""]).should be_true
  end
  
  it "should remove missing values" do
    signature = Waw::Validation.signature {
      validation :id, array[Integer | missing], :bad_array
    }
    signature.first_converted(:id => ["1", nil]).should == [1]
    signature.first_converted(:id => ["1", ""]).should == [1]
    signature.first_converted(:id => ["1", "", nil, "12", "   "]).should == [1, 12]
  end
  
end