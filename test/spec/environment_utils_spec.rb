require "waw"
describe Waw::EnvironmentUtils do
  include Waw::EnvironmentUtils
  
  it "should support non rack assumptions, for testing purposes" do
    session[:name] = 12
    session[:name].should == 12
  end
  
  it "should support session_get and session_set correctly" do
    session_set(:name, 12)
    session_get(:name).should == 12
  end
  
end