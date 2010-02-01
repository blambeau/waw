require 'waw'
describe ::Waw::StaticController::WawAccess do
  
  def parse(text = "")
    wa = ::Waw::StaticController::WawAccess.new(nil, File.dirname(__FILE__))
    wa.dsl_merge(text)
    wa
  end
  
  it "should propose all ::Waw::Validation as basic matchers" do
    wa = parse <<-EOF
      wawaccess do
        match(file)      { :file }
        match(directory) { :directory }
        match(true)      { :is404 }
      end
    EOF
    wa.apply_rules('waw_access_spec.rb').should == :file
    wa.apply_rules('').should == :directory
    wa.apply_rules('nothing/at/all').should == :is404
  end
  
  it "should not provide block conflict between validators and matching rules" do
    wa = parse <<-EOF
      wawaccess do
        match file do
          :file
        end
      end
    EOF
    wa.apply_rules('waw_access_spec.rb').should == :file
  end

end