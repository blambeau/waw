require "waw"
describe Waw::FullState::Variable do
  include ::Waw::Fixtures
  before(:each) { load_empty_app   }
  after(:each)  { unload_empty_app }
  
  # Creates a variable instance
  def variable(name, default_value = nil, &block)
    Waw::FullState::Variable.new(name, default_value, &block)
  rescue => ex
    raise ex
  end
  
  it "should accept respect assignation" do
    var = variable(:name)
    (var.value = 12).should == 12
    var.value.should == 12
    var.value += 1
    var.value.should == 13
  end
  
  it "should respect default values" do
    var = variable(:name, 12)
    var.value.should == 12
    var.value += 1
    var.value.should == 13
  end
  
  it "should respect block default values" do
    var = variable(:name){ "hello world" }
    var.value.should == "hello world"
    var.value = 1
    var.value.should == 1
  end
  
  it "should allow reset with a default value" do
    var = variable(:name, 12)
    var.value = 2
    var.reset
    var.value.should == 12
  end
  
  it "should allow reset with a block as default" do
    var = variable(:name){ "hello world" }
    var.value = 2
    var.reset
    var.value.should == "hello world"
  end
  
  it "should detect bad usages" do
    # don't know why it does not work
    #variable(:name, 12){ 13 }.should raise_exception(ArgumentError)
  end

end