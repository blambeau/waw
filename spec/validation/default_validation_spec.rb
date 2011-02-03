require File.expand_path('../../spec_helper', __FILE__)
describe ::Waw::Validation::DefaultValidator do
  
  def default(*args, &block)
    ::Waw::Validation::DefaultValidator.new(*args, &block)
  end
  
  it "should be correct about missing values when calling validate" do
    default(8).validate(1).should == false
    default(8).validate(1, nil).should == false
    default(8).validate(nil).should == true
    default(8).validate("").should == true
    default(8).validate("  ").should == true
    default(8).validate("", nil).should == true
  end
  
  it "should be correct about missing values when calling convert_and_validate" do
    default(8).convert_and_validate(1).should == [false, [1]]
    default(8).convert_and_validate(nil).should == [true, [8]]
    default(8).convert_and_validate(nil, nil).should == [true, [8, 8]]
  end
  
  it "should support passing a block (feature #305)" do
    default{8}.convert_and_validate(1).should == [false, [1]]
    default{8}.convert_and_validate(nil).should == [true, [8]]
    default{8}.convert_and_validate(nil, nil).should == [true, [8, 8]]
  end
  
  it "should also work when used in signature (feature #{306})" do
    signature = ::Waw::Validation.signature {
      validation :time, String | default{Time.now}, :time
    }
    signature.allows?(:time => nil).should == true
    Time.should === signature.first_converted(:time => nil)
  end
  
end