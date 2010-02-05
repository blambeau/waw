require 'waw'
describe ::Waw::Session do
  include ::Waw::Fixtures
  before(:each) { load_empty_app   }
  after(:each)  { unload_empty_app }
  
  def session
    @empty_app.session
  end
  
  it "should allows being extended" do
    class ::Waw::Session
      session_var :my_variable, 15
    end
    (session.my_variable = 12).should == 12
    session.my_variable.should == 12
  end
  
  it "should allow resetting variables" do
    class ::Waw::Session
      session_var :my_variable, 15
    end
    session.my_variable = 12
    session.reset(:my_variable)
    session.my_variable.should == 15
  end
  
  it "should allow query variables without parameters" do
    class ::Waw::Session
      session_var(:my_query){ "hello" }
    end
    session.my_query.should == "hello"
  end
  
  it "should allow query variables with parameters" do
    class ::Waw::Session
      session_var(:my_id, 12)
      session_var(:my_query){|session| session.my_id }
    end
    session.my_query.should == 12
  end
  
end