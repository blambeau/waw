require File.expand_path('../../spec_helper', __FILE__)
module Waw::Validation
  validator :my_validator, validator{|s| s=="I'm my_validator"}
end
class SomeDSL
  include Waw::Validation
end
describe ::Waw::Validation do
  
  it "should respond to installed validators" do
    Waw::Validation.should respond_to(:my_validator)
  end
  
  it "should allow other classes/modules (like DSLs) to include it and to get validators for free (issue #260)" do
    SomeDSL.new.should respond_to(:my_validator)
    SomeDSL.new.my_validator.convert_and_validate(nil).should == [false, [nil]]
  end
  
  it "should support being reopened later" do
    module Waw::Validation
      validator :second_validator_test, validator{|arg| Integer===arg}
    end
    SomeDSL.new.should respond_to(:second_validator_test)
    SomeDSL.new.second_validator_test.convert_and_validate(12).should == [true, [12]]
  end
  
end
