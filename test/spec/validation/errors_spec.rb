require "waw"
describe Waw::Validation::Error do

  it "should be raisable easily" do
    begin
      raise Waw::Validation::Error, [:bad_user, :bad_age]
      false.should be_true
    rescue Waw::Validation::Error => ex
      ex.failed.should == [:bad_user, :bad_age]
      ex.message.should_not be_nil
      ex.message.is_a?(String).should be_true
    end
  end
  
  it "should allow catching subclasses with Error" do
    begin
      raise Waw::Validation::KO, [:bad_user, :bad_age]
      false.should be_true
    rescue Waw::Validation::Error => ex
      ex.failed.should == [:bad_user, :bad_age]
      ex.message.should_not be_nil
      ex.message.is_a?(String).should be_true
    end
  end

  it "should allow catching exact subclasses" do
    begin
      raise Waw::Validation::KO, [:bad_user, :bad_age]
      false.should be_true
    rescue Waw::Validation::KO => ex
      ex.failed.should == [:bad_user, :bad_age]
      ex.message.should_not be_nil
      ex.message.is_a?(String).should be_true
    end
  end

end