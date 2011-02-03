require File.expand_path('../spec_helper', __FILE__)
describe Waw do
  
  it "should have a version number" do
    Waw.const_defined?(:VERSION).should be_true
  end
  
end
