require 'waw'
require 'fileutils'
describe ::Waw::Validation::FileValidator do
  
  def file
    ::Waw::Validation::FileValidator.new
  end
  
  def sandbox_file_with_spaces
    File.join(File.dirname(__FILE__), 'issue 360.txt')
  end
  
  before(:all) do
    File.open(sandbox_file_with_spaces, 'w'){|io| io << "hello world!"}
    File.read(sandbox_file_with_spaces).should == "hello world!"
  end
  
  after(:all) do
    FileUtils.rm sandbox_file_with_spaces
  end

  it "should recognize real files" do
    (file === __FILE__).should be_true
  end
  
  it "should support file names containing spaces (see #360)" do
    (file === sandbox_file_with_spaces).should be_true
  end
  
  it "should not decode html paths itself (see #360)" do
    (file === sandbox_file_with_spaces.gsub(/\s/,"%20")).should be_false
  end
    
end