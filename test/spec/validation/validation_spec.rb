require 'waw'

module Waw::Validation
  validator :my_validator, validator{|s| "I'm my_validator"}
end
module SomeDSL
  include Waw::Validation
end
describe ::Waw::Validation do
  
  it "should respond to installed validators" do
    Waw::Validation.should respond_to(:my_validator)
  end
  
  it "should allow other classes/modules (like DSLs) to include it and to get validators for free (issue #260)" do
    SomeDSL.should respond_to(:my_validator)
  end
  
end
