require File.expand_path('../../spec_helper', __FILE__)
describe ::Waw::ActionController do
  include ::Waw::Fixtures
  before(:each) { load_action_app   }
  after(:each)  { unload_action_app }
  
  it "should find its url" do
    controller = Waw::Fixtures::ActionControllerTest
    controller.url.should == "/services"
    controller.instance.url.should == "/services"
    controller.say_hello.url.should == "/services/say_hello"
  end
  
end