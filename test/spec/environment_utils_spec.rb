require "waw"
describe Waw::EnvironmentUtils do
  include Waw::EnvironmentUtils
  
  it "should support non rack assumptions, for testing purposes" do
    session[:name] = 12
    session[:name].should == 12
  end
  
  it "should support session.get and session.set correctly" do
    session.set(:name, 12)
    session.get(:name).should == 12
  end
  
end