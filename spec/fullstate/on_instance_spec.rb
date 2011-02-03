require File.expand_path('../../spec_helper', __FILE__)
describe ::Waw::FullState::OnInstance do
  include ::Waw::Fixtures
  before(:each) { load_empty_app   }
  after(:each)  { unload_empty_app }
  
  it "should allow session variable creation on classes" do
    class A
      extend Waw::FullState::OnInstance
      session_var :myvar
    end
    A.new.respond_to?(:myvar).should be_true
    A.new.respond_to?(:myvar=).should be_true
  end
  
  it "should allow a default value" do
    class A
      extend Waw::FullState::OnInstance
      session_var :myvar, 12
    end
    A.new.respond_to?(:myvar).should be_true
    A.new.respond_to?(:myvar=).should be_true
  end
  
  it "should allow a default value given by a block" do
    class A
      extend Waw::FullState::OnInstance
      session_var :myvar do 12 end
    end
    A.new.respond_to?(:myvar).should be_true
    A.new.respond_to?(:myvar=).should be_true
  end
  
  it "should respect the default value when the session is empty" do
    class A
      extend Waw::FullState::OnInstance
      session_var :myvar, "hello"
    end
    A.new.myvar.should == "hello"

    class A
      extend Waw::FullState::OnInstance
      session_var :myvar do 12 end
    end
    A.new.myvar.should == 12
  end
  
  it "should allow affecting the session variable" do
    class A
      extend Waw::FullState::OnInstance
      session_var :myvar, "hello"
    end
    a = A.new
    a.myvar = "world"
    @empty_app.session[:myvar].should == "world"
    a.myvar.should == "world"
  end
  
end