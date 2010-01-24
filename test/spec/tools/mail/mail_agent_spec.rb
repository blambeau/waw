require 'waw'
require 'waw/tools/mail'

describe ::Waw::Tools::MailAgent do
  
  def agent
    @agent ||= ::Waw::Tools::MailAgent.new
  end
  
  def mail(*args)
    ::Waw::Tools::MailAgent::Mail.new(*args)
  end
  
  it "should allow sending mails easily" do
    agent << mail("Subject", "Message", "sender", "receiver")
    agent.mailbox("receiver").size.should == 1
    mail = agent.mailbox("receiver").read(0)
    mail.subject.should == "Subject"
    mail.body.should == "Message"
  end

  it "should allow sending mails to many receivers" do
    agent << mail("Subject", "Message", "sender", "receiver1", "receiver2")
    agent.mailbox("receiver1").size.should == 1
    agent.mailbox("receiver2").size.should == 1
  end
  
  # it "should really send mails if we force it" do
  #   agent = ::Waw::Tools::MailAgent.new({:host => 'localhost', :port => 7654, :timeout => 1}, true)
  #   agent << mail("Subject", "Message", "sender", "receiver1", "receiver2")
  # end
  
end