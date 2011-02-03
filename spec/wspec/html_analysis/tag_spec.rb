require File.expand_path('../../../spec_helper', __FILE__)
require 'waw/wspec'

describe Waw::WSpec::HTMLAnalysis::Tag do
  
  def tag(name, attributes = {})
    Waw::WSpec::HTMLAnalysis::Tag.new(nil, name, attributes)
  end
  
  it "should give access to its name" do
    tag('a').name.should == 'a'
    tag('div').name.should == 'div'
  end
  
  it "should give access to its attributes" do
    tag = tag('a', :id => "link", :class => "current")
    tag.attributes.should == {:id => "link", :class => "current"}
    tag[:id].should == "link"
    tag[:class].should == "current"
  end
  
  it "should provide a helper for matching an attribute specification" do
    tag = tag('a', :id => "link", :class => "current")
    tag.matches?(:id => 'link').should be_true
    tag.matches?(:id => 'link', :class => "current").should be_true
    tag.matches?(:id => 'link', :class => "current", :noone => "something").should be_false
    tag.matches?(:id => 'nolink').should be_false
    tag.matches?(:id => 'link', :class => "notthegoodone").should be_false
    tag.matches?(:noone => 'something').should be_false
  end
  
  it 'should allow expression regular expressions in the matching helper' do
    tag = tag('a', :id => "link", :class => "current")
    tag.matches?(:id => /^([a-z]+)$/).should be_true
    tag.matches?(:id => /^([0-9]+)$/).should be_false
  end
  
end