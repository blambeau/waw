require 'waw'

describe "::Waw::StaticController::WawAccess.matching_file" do
  
  def folder
    File.dirname(__FILE__)
  end
  
  def join(folder, path)
    File.join(folder, path)
  end
  
  def wawaccess
    ::Waw::StaticController::WawAccess.new(nil, folder)
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
  
  it 'should correctly resolve file names' do
    wawaccess.matching_file('waw_access_spec.rb').should == join(folder, 'waw_access_spec.rb')
    File.exists?(wawaccess.matching_file('waw_access_spec.rb')).should be_true
  end
  
  it 'should correctly resolve file names with spaces' do
    file = wawaccess.matching_file('issue 360.txt')
    file.should == join(folder, 'issue 360.txt')
    File.exists?(file).should be_true
  end
  
end

describe ::Waw::StaticController::WawAccess do
  
  def parse(text = "")
    wa = ::Waw::StaticController::WawAccess.new(nil, File.dirname(__FILE__))
    wa.dsl_merge(text)
    wa
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
  
  it "should propose all ::Waw::Validation as basic matchers" do
    wa = parse <<-EOF
      wawaccess do
        match(file)      { :file }
        match(directory) { :directory }
        match(true)      { :is404 }
      end
    EOF
    wa.do_path_serve('waw_access_spec.rb').should == :file
    wa.do_path_serve('').should == :directory
    wa.do_path_serve('nothing/at/all').should == :is404
  end
  
  it "should not provide block conflict between validators and matching rules" do
    wa = parse <<-EOF
      wawaccess do
        match file do
          :file
        end
      end
    EOF
    wa.do_path_serve('waw_access_spec.rb').should == :file
  end
  
  it "should support files with spaces (on file, see #360)" do
    wa = parse <<-EOF
      wawaccess do
        match file do
          static
        end
      end
    EOF
    code, headers, body = wa.do_path_serve('issue 360.txt')
    code.should == 200 
  end
  
  it "should support files with %20 spaces (on file, see #360)" do
    wa = parse <<-EOF
      wawaccess do
        match file do
          static
        end
      end
    EOF
    code, headers, body = wa.do_path_serve('issue%20360.txt')
    code.should == 200 
  end
   
end