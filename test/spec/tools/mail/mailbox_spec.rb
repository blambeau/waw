require 'waw'
require 'waw/tools/mail'
describe Waw::Tools::MailAgent::Mailbox do
  
  # Returns a mail instance
  def mail(subject)
    mail = Waw::Tools::MailAgent::Mail.new
    mail.subject = subject
    mail
  end
  
  def mailbox(who)
    Waw::Tools::MailAgent::Mailbox.new(who)
  end
  
  it "should allow pushing mails" do
    mailbox = mailbox("blambeau@gmail.com")
    mailbox << mail("This is the first mail")
    mailbox << mail("This is the second mail")
    mailbox.size.should == 2
  end

  it "should allow getting mails" do
    mailbox = mailbox("blambeau@gmail.com")
    mailbox << mail("This is the first mail")
    mailbox << mail("This is the second mail")
    mailbox[0].subject.should == "This is the first mail"
    mailbox[1].subject.should == "This is the second mail"
  end
  
  it "should allow reading mails" do
    mailbox = mailbox("blambeau@gmail.com")
    mailbox << mail("This is the first mail")
    mailbox.is_read?(0).should be_false
    (mail = mailbox.read(0)).should_not be_nil
    mail.subject.should == "This is the first mail"
    mailbox.is_read?(0).should be_true
  end
  
  it "should allow clearing the mailbox" do
    mailbox = mailbox("blambeau@gmail.com")
    mailbox << mail("This is the first mail")
    mailbox << mail("This is the second mail")
    mailbox.size.should == 2
    mailbox.clear
    mailbox.size.should == 0
  end
  
  it "should be robust to unexistant mails" do
    mailbox = mailbox("blambeau@gmail.com")
    mailbox[0].should be_nil
    mailbox[-1].should be_nil
    mailbox.is_read?(0).should be_nil
    mailbox.read(0).should be_nil
  end
  
end