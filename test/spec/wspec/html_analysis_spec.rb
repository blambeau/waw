require 'waw'
require 'waw/wspec'

describe Waw::WSpec::HTMLAnalysis do
  include Waw::WSpec::HTMLAnalysis
  
  def browser_contents
    <<-HTML
      <html>
        <head>
          <title>This is a WSpec rspec test</title>
          <link rel="stylesheet" type="text/css" href="/css/style.css" />
      		<link rel="stylesheet" type="text/css" href="/css/olympiades.css" />
      		<link rel="stylesheet" type="text/css" href="/css/scienceinfuse" />
      		<script type="text/javascript" src="/js/jquery-1.3.2.min.js"></script>
      		<script type="text/javascript" src="/js/waw.js"></script>
      		<script type="text/javascript" src="/js/acmscw.js"></script>
      		<script type="text/javascript" src="/js/acmscw_generated.js"></script>          
        </head>
        <body>
          <div id="menu">
            <a href="/hello" class="current">Hello</a>
            <a href="/world">World</a>
          </div>
          <div id="main">
            <link href="service?key=value"/>
          </div>
        </body>
      </html>
    HTML
  end
  
  it "should correctly decode attributes" do
    decode_attributes_string("").should == {} 
    decode_attributes_string('href="http://www.google.com"').should == {:href => 'http://www.google.com'} 
    decode_attributes_string("href='http://www.google.com'").should == {:href => 'http://www.google.com'} 
    decode_attributes_string('href="http://www.google.com"   src="/images/test.jpg"').should == {
      :href => 'http://www.google.com',
      :src => "/images/test.jpg"
    } 
  end
  
  it "should provide a useful tags helper, returning an array of tags" do
    links = tags('a')
    links.size.should == 2
    links[0].name.should == 'a'
    links[0][:href].should == '/hello'
    links[0][:class].should == 'current'
    links[1].name.should == 'a'
    links[1][:href].should == '/world'
    links[1][:class].should be_nil
  end
  
  it "should allow passing a block to the tags helper method" do
    links = []
    tags('a') {|tag| links << tag}
    links.size.should == 2
    links[0].name.should == 'a'
    links[0][:href].should == '/hello'
    links[0][:class].should == 'current'
    links[1].name.should == 'a'
    links[1][:href].should == '/world'
    links[1][:class].should be_nil
  end
  
  it "should provide a each_tag friendly method" do
    links = []
    each_tag('a') {|tag| links << tag}
    links.size.should == 2
  end
  
  it "should support a tags helper method allowing to express constraints" do
    tags('div').size.should == 2
    tags('div', :id => 'menu').size.should == 1
    tags('div', :id => 'main').size.should == 1
    tags('div', :id => 'none').size.should == 0
  end
  
  it "should support a tags helper method supporting regexp constraints" do
    tags('link', :rel => "stylesheet", :href => /\.css$/).size.should == 2
  end
  
  it "should support a tags helper method allowing complex uris, as href attributes for example" do
    tags = tags('link', :href => "service?key=value")
    tags.size.should == 1
    tags[0][:href].should == 'service?key=value'
  end
  
  it "should support a non plural form for the tags helper method" do
    tag = tag('a')
    (Waw::WSpec::HTMLAnalysis::Tag===tag).should be_true
    tag[:href].should == '/hello'
    tag('nothing').should be_nil
  end
  
  it "should correctly implement has_tag?" do
    has_tag?("title").should be_true
    has_tag?("a").should be_true
    has_tag?("div").should be_true
    has_tag?("div", :id => 'menu').should be_true
    has_tag?("div", :id => 'notmenu').should be_false
    has_tag?("p").should be_false
  end
  
end