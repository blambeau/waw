require 'waw'
require 'waw/tools/mail'

describe ::Waw::Tools::MailAgent do
  
  def agent
    @agent ||= ::Waw::Tools::MailAgent.new
  end
  
  it("should provide a mail helper, hiding the Mail class") {
    mail = agent.mail("Subject", "Body", "sender", "receiver")
    mail.is_a?(::Waw::Tools::MailAgent::Mail).should be_true
    mail.subject.should == "Subject"
    mail.body.should == "Body"
    mail.from.should == "sender"
    mail.to.should == ["receiver"]
  }
  
  it("should provide a template helper, hiding the Template class") {
    template = agent.template("Subject", "Body", "sender", "receiver")
    template.is_a?(::Waw::Tools::MailAgent::Template).should be_true
    template.subject.should == "Subject"
    template.body.should == "Body"
    template.from.should == "sender"
    template.to.should == ["receiver"]
  }
  
  it("should allow sending mails easily") {
    agent << agent.mail("Subject", "Message", "sender", "receiver")
    agent.mailbox("receiver").size.should == 1
    mail = agent.mailbox("receiver").read(0)
    mail.subject.should == "Subject"
    mail.body.should == "Message"
  }

  it("should allow sending mails to many receivers") {
    agent << agent.mail("Subject", "Message", "sender", "receiver1", "receiver2")
    agent.mailbox("receiver1").size.should == 1
    agent.mailbox("receiver2").size.should == 1
  }
  
  # it("should really send mails if we force it") {
  #   agent = ::Waw::Tools::MailAgent.new({:host => 'localhost', :port => 7654, :timeout => 1}, true)
  #   agent << mail("Subject", "Message", "sender", "receiver1", "receiver2")
  # }
  
  it("should support mail templates") {
    agent.add_template(:waw_info, "Hi ${who}, and welcome in waw", "We've received your request ${id}", "info@waw.org")
    mail = agent.to_mail(:waw_info, {:who => "guy", :id => 123})
    mail.subject.should == "Hi guy, and welcome in waw"
    mail.body.should == "We've received your request 123"
    mail.from.should == "info@waw.org"
  }
  
  it("should provide a great job when working with templates") {
    agent.add_template(:waw_info, "Hi ${who}, and welcome in waw", "We've received your request ${id}", "info@waw.org")
    agent.send_mail(:waw_info, {:who => "guy", :id => 123}, "blambeau@gmail.com")
    mailbox = agent.mailbox("blambeau@gmail.com")
    mailbox.size.should == 1
    mailbox[0].subject.should == "Hi guy, and welcome in waw"
    mailbox[0].body.should == "We've received your request 123"
    mailbox[0].from.should == "info@waw.org"
    mailbox[0].to.should == ["blambeau@gmail.com"]
  }
  
  it("should provide a send_mail with signature 1") {
    agent.send_mail agent.mail("Subject", "Message", "sender", "receiver1", "receiver2")
    mail = agent.mailbox("receiver1")[0]
    mail.subject.should == "Subject"
    mail = agent.mailbox("receiver2")[0]
    mail.subject.should == "Subject"
  }
  
  it("should provide a send_mail with signature 2") {
    agent.add_template(:waw_info, "${subject}", "${body}", "info@waw.org", "receiver1", "receiver2")
    agent.send_mail(:waw_info, {:subject => "hello", :body => "world"})
    mail = agent.mailbox("receiver1")[0]
    mail.subject.should == "hello"
    mail.body.should == "world"
    mail = agent.mailbox("receiver2")[0]
    mail.subject.should == "hello"
    mail.body.should == "world"
  }
  
  it("should provide a send_mail with signature 3") {
    agent.add_template(:waw_info, "${subject}", "${body}", "info@waw.org")
    agent.send_mail(:waw_info, {:subject => "hello", :body => "world"}, "receiver1", "receiver2")
    mail = agent.mailbox("receiver1")[0]
    mail.subject.should == "hello"
    mail.body.should == "world"
    mail = agent.mailbox("receiver2")[0]
    mail.subject.should == "hello"
    mail.body.should == "world"
  }
  
  it("should provide a send_mail with signature 4") {
    agent.add_template(:waw_info, "${subject}", "${body}", "info@waw.org")
    agent.send_mail(:waw_info, {:subject => "hello", :body => "world"}, ["receiver1", "receiver2"])
    mail = agent.mailbox("receiver1")[0]
    mail.subject.should == "hello"
    mail.body.should == "world"
    mail = agent.mailbox("receiver2")[0]
    mail.subject.should == "hello"
    mail.body.should == "world"
  }
  
end