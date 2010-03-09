describe "Our understanding of ruby" do
  
  def sandbox_file_with_spaces
    File.join(File.dirname(__FILE__), 'issue 360.txt')
  end

  def sandbox_file_with_spaces_2
    File.join(File.dirname(__FILE__), 'ext', 'issue 360.txt')
  end
  
  before(:all) do
    File.open(sandbox_file_with_spaces, 'w'){|io| io << "hello world!"}
    File.open(sandbox_file_with_spaces_2, 'w'){|io| io << "hello world!"}
    File.read(sandbox_file_with_spaces).should == "hello world!"
    File.read(sandbox_file_with_spaces_2).should == "hello world!"
  end
  
  after(:all) do
    FileUtils.rm sandbox_file_with_spaces
    FileUtils.rm sandbox_file_with_spaces_2
  end

  it "should be correct about File.exists? in presence of spaces" do
    File.exists?(__FILE__).should be_true
    File.exists?("something that does not exists").should be_false
    File.exists?(sandbox_file_with_spaces).should be_true
    File.exists?(sandbox_file_with_spaces_2).should be_true
  end
  
end