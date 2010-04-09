require 'waw'
require 'waw/tools/mail'
describe ::Waw::Tools::MailAgent::Mail do
  
  it "should correctly support encode/decode for testing purposes at least" do
    mail = ::Waw::Tools::MailAgent::Mail.new
    mail.from = "blambeau@gmail.com"
    mail.to = ["blambeau@chefbe.net", "llambeau@chefbe.net"]
    mail.cc = ["cc@chefbe.net"]
    mail.bcc = ["bcc@chefbe.net"]
    mail.subject = "This is a test mail"
    mail.body = "Hello people"
    
    mail = ::Waw::Tools::MailAgent::Mail.decode(mail.encode)
    mail.from.should == "blambeau@gmail.com"
    mail.to.should == ["blambeau@chefbe.net", "llambeau@chefbe.net"]
    mail.cc.should == ["cc@chefbe.net"]
    mail.bcc.should == ["bcc@chefbe.net"]
    mail.subject.should == "This is a test mail"
    mail.content_type.should == "text/plain"
    mail.charset.should == "UTF-8"
    mail.body.should == "Hello people"
  end
  
  it "should support encode/decode on long bodies" do
    mail = ::Waw::Tools::MailAgent::Mail.new
    body = <<-EOF
<p>This is a complex framework</p>

<p>But definitely fine!</p>
EOF
    mail.body = body
    mail.content_type = 'text/html'

    mail.content_type.should == "text/html"
    mail.charset.should == "UTF-8"
    mail.body.should == body
  end
  
  it "should provide a short form for initialize" do
    mail = ::Waw::Tools::MailAgent::Mail.new("The subject", "The message", "me", "you")
    mail.subject.should == "The subject"
    mail.body.should == "The message"
    mail.from.should == "me"
    mail.to.should == ["you"]
  end
  
  it "should support multiple receivers in the short form for initialize" do
    mail = ::Waw::Tools::MailAgent::Mail.new("The subject", "The message", "me", "you", "us")
    mail.subject.should == "The subject"
    mail.body.should == "The message"
    mail.from.should == "me"
    mail.to.should == ["you", "us"]
  end
  
end