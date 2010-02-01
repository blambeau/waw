require 'waw'
describe ::Waw::ResourceCollection do
  
  it "should support creating resources simply" do
    resources = ::Waw::ResourceCollection.parse_resources <<-EOF
      name   'hello'
      who    12
    EOF
    resources.name.should == 'hello'
    resources.who.should == 12
  end
  
  it "should support default values" do
    resources = ::Waw::ResourceCollection.parse_resources <<-EOF
    EOF
    resources.name('hello').should == 'hello'
  end
  
  it "should support passing blocks" do
    resources = ::Waw::ResourceCollection.parse_resources <<-EOF
      what  {|r| 12 }
    EOF
    resources.what.should == 12
  end
  
  it "should support installing Proc as resources" do
    resources = ::Waw::ResourceCollection.parse_resources <<-EOF
      what  Kernel.lambda { 12 }
    EOF
    Proc.should === resources.what
    resources.what.call.should == 12
  end
  
  it "should support self referencing" do
    resources = ::Waw::ResourceCollection.parse_resources <<-EOF
      who     'hello'
      who2    who
    EOF
    resources.who2.should == 'hello'
  end

  it "should support self referencing with blocks" do
    resources = ::Waw::ResourceCollection.parse_resources <<-EOF
      who     {'hello'}
      who2    who
    EOF
    resources.who2.should == 'hello'
  end

end