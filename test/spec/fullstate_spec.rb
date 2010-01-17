require "waw"
describe ::Waw::FullState do
  
  it "should allow session variable creation on classes" do
    class A
      extend Waw::FullState::OnInstance
      session_var :name
    end
    A.new.respond_to?(:name).should be_true
    A.new.respond_to?(:name=).should be_true
  end
  
  it "should allow a default value" do
    class A
      extend Waw::FullState::OnInstance
      session_var :name, 12
    end
    A.new.respond_to?(:name).should be_true
    A.new.respond_to?(:name=).should be_true
  end
  
  it "should allow a default value given by a block" do
    class A
      extend Waw::FullState::OnInstance
      session_var :name do 12 end
    end
    A.new.respond_to?(:name).should be_true
    A.new.respond_to?(:name=).should be_true
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
    Waw.session[:myvar].should == "world"
    a.myvar.should == "world"
  end
  
end