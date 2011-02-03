require File.expand_path('../../spec_helper', __FILE__)
describe "mail proposed validation" do

  # Creates a signature
  def mail
    @mail_validator ||= ::Waw::Validation.signature {
      validation :mail, mail, :bad_mail
    }
  end
  
  it "should block missing values" do
    mail.blocks?(:mail => nil).should be_true
    mail.blocks?(:mail => "").should be_true
    mail.blocks?(:mail => "   ").should be_true
  end

  it "should be robust to strange values" do
    mail.blocks?(:mail => nil).should be_true
    mail.blocks?(:mail => 12).should be_true
    mail.blocks?(:mail => self).should be_true
    mail.blocks?(:mail => Class).should be_true
    mail.blocks?(:mail => self).should be_true
  end

  it "should allow valid mails" do
    mail.allows?(:mail => "blambeau@gmail.com").should be_true
    mail.allows?(:mail => "blambeau@acm-sc.be").should be_true
  end

  it "should support mails with dots" do
    mail.allows?(:mail => "bernard.lambeau@gmail.com").should be_true
  end

  it "should support mails with numbers" do
    mail.allows?(:mail => "bernard007@gmail.com").should be_true
  end

  it "should support trailing spaces" do
    mail.allows?(:mail => "blambeau@gmail.com   ").should be_true
    mail.allows?(:mail => "   blambeau@acm-sc.be").should be_true
    mail.allows?(:mail => "   blambeau@acm-sc.be    ").should be_true
  end
  
  it "should not support spaces inside the mail" do
    mail.blocks?(:mail => "blamb gmail.com").should be_true
    mail.blocks?(:mail => "blambeau@gmail.com  and something here").should be_true
    mail.blocks?(:mail => "something here blambeau@gmail.com").should be_true
    mail.blocks?(:mail => "something here blambeau@gmail.com and also here").should be_true
  end
  
end