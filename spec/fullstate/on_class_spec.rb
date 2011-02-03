require File.expand_path('../../spec_helper', __FILE__)
describe ::Waw::FullState::OnClass do
  include ::Waw::Fixtures
  before(:each) { load_empty_app   }
  after(:each)  { unload_empty_app }
  
  it "should allow session variables on classes" do
    class A
      extend Waw::FullState::OnClass
      session_var :myvar
    end
    A.respond_to?(:myvar).should be_true
    A.respond_to?(:myvar=).should be_true
  end
  
  it "should allow a default value" do
    class A
      extend Waw::FullState::OnClass
      session_var :myvar, 12
    end
    A.respond_to?(:myvar).should be_true
    A.respond_to?(:myvar=).should be_true
  end
  
  it "should allow a default value given by a block" do
    class A
      extend Waw::FullState::OnClass
      session_var :myvar do 12 end
    end
    A.respond_to?(:myvar).should be_true
    A.respond_to?(:myvar=).should be_true
  end

  it "should respect the default value when the session is empty" do
    class A
      extend Waw::FullState::OnClass
      session_var :myvar, "hello"
    end
    A.myvar.should == "hello"
  
    class B
      extend Waw::FullState::OnClass
      session_var :myvar do 12 end
    end
    B.myvar.should == 12
  end
   
  it "should allow affecting the session variable" do
    class A
      extend Waw::FullState::OnClass
      session_var :myvar, "hello"
    end
    a = A
    a.myvar = "world"
    @empty_app.session[:myvar].should == "world"
    a.myvar.should == "world"
  end

end