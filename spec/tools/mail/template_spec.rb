require File.expand_path('../../../spec_helper', __FILE__)
require 'waw/tools/mail'

describe ::Waw::Tools::MailAgent::Template do
  
  def template(*args)
    ::Waw::Tools::MailAgent::Template.new(*args)
  end
  
  it("should act as a mail for the construction") {
    template = template("${subject}", "${body}", "from")
    template.subject.should == "${subject}"
    template.body.should == "${body}"
    template.from.should == "from"
  }

  it("should detect wlang dialect from content-type") {
    template = template("${subject}", "${body}", "from")
    template.dialect.should == "wlang/active-string"
    template.content_type = "text/html"
    template.dialect.should == "wlang/xhtml"
  }
  
  it("should support easy to_mail instantiation") {
    template = template("Here is the: ${subject}", "Here is the: ${body}", "from", "receiver1", "receiver2")
    mail = template.to_mail(:subject => "The subject", :body => "The body")

    # the template has not changed
    template.subject.should == "Here is the: ${subject}"
    template.body.should == "Here is the: ${body}"
    template.to.should == ["receiver1", "receiver2"]
    
    # the mail should be instantiated
    mail.from.should == "from"
    mail.subject.should == "Here is the: The subject"
    mail.body.should == "Here is the: The body"
    mail.to.should == ["receiver1", "receiver2"]
  }
  
  it("should ensure than to_mail returns something really detached from the template") {
    template = template("Here is the: ${subject}", "Here is the: ${body}", "from", "receiver1", "receiver2")
    mail = template.to_mail(:subject => "The subject", :body => "The body")
    mail.to.clear
    template.to.should == ["receiver1", "receiver2"]
  }
  
end