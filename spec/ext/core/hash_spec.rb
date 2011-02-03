require File.expand_path('../../../spec_helper', __FILE__)
describe ::Hash do
 
  it "should provide a non-intrusive keep method" do
    hash = {:name => "blambeau", :age => 20}
    hash.keep(:name).should == {:name => "blambeau"}
    hash.keep([:name]).should == {:name => "blambeau"}
    hash.keep(:name, :age).should == hash
    hash.keep([:name, :age]).should == hash
    hash.keep(:name, :age).object_id.should_not == hash.object_id
    hash.keep(:name, :age, :occupation).should == hash
  end

  it "should provide an intrusive keep! method" do
    hash = {:name => "blambeau", :age => 20}
    hash.keep!(:name).should == {:name => "blambeau"}
    hash.keep!([:name]).should == {:name => "blambeau"}
    hash.keep!(:name, :age).should == hash
    hash.keep!([:name, :age]).should == hash
    hash.keep!(:name, :age).object_id.should == hash.object_id
    hash.keep!(:name, :age, :occupation).should == hash
  end
  
  it "should provide a non-intrusive forget method" do
    hash = {:name => "blambeau", :age => 20}
    hash.forget(:name).should == {:age => 20}
    hash.forget([:name]).should == {:age => 20}
    hash.forget(:name, :age).should == {}
    hash.forget([:name, :age]).should == {}
    hash.forget(:name, :age).object_id.should_not == hash.object_id
    hash.forget(:name, :age, :occupation).should == {}
  end

  it "should provide an intrusive forget! method" do
    hash = {:name => "blambeau", :age => 20}
    hash.forget!(:name).should == {:age => 20}
    hash.forget!([:name]).should == {:age => 20}
    hash.forget!(:name, :age).should == {}
    hash.forget!([:name, :age]).should == {}
    hash.forget!(:name, :age).object_id.should == hash.object_id
    hash.forget!(:name, :age, :occupation).should == {}
  end

  it "should provide an helper for building url queries" do
    {}.to_url_query.should == ""
    {:name => "blambeau"}.to_url_query.should == "name=blambeau"
    
    possible = ["name=blambeau&age=12", "age=12&name=blambeau"]
    possible.include?({:name => "blambeau", :age => 12}.to_url_query).should be_true
    
    {:name => "bla&beau"}.to_url_query.should == "name=bla%26beau"
  end
  
  it "should provide a methodize helper" do
    hash = {'hello' => 'world'}
    hash.methodize.hello.should == 'world'
  end

end