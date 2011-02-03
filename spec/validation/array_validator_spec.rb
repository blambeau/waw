require File.expand_path('../../spec_helper', __FILE__)
describe ::Waw::Validation::ArrayValidations::ArrayValidator do
  
  def arrayval(subvalidator)
    ::Waw::Validation::ArrayValidations::ArrayValidator.new(subvalidator)
  end
  
  it "should correctly validate non empty arrays" do
    arrayval(String).validate(["hop", "hello"]).should be_true
    arrayval(String).validate(["world"]).should be_true
  end
  
  it "should correctly validate empty arrays" do
    arrayval(String).validate([]).should be_true
  end
  
end