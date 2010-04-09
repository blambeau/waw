module Waw
  module Tools
    class MailAgent
      # A helper to respect the mail protocol
      class Mail
        
        # Source address
        attr_accessor :from
        
        # Target addresses 
        attr_accessor :to
        
        # Target carbon copy addresses 
        attr_accessor :cc
        
        # Target b carbon copy addresses 
        attr_accessor :bcc
        
        # Mail subject
        attr_accessor :subject
        
        # Mail date
        attr_accessor :date
        
        # MIME version
        attr_accessor :mime_version
        
        # Content-type
        attr_accessor :content_type
        
        # Content-type
        attr_accessor :charset
        
        # Mail body
        attr_accessor :body
        
        # Creates an empty mail
        def initialize(subject = nil, body = nil, from = nil, *to)
          @from = from
          @to = to.empty? ? [] : to
          @cc, @bcc = [], []
          @subject = subject
          @date = Time.now
          @mime_version = "1.0"
          @content_type = "text/plain"
          @charset = "UTF-8"
          @body = body
        end
        
        # Class methods
        class << self
          
          # Decodes a mail from a given string
          def decode(str)
            mail = Mail.new
            lines = str.split("\n")
            until false 
              case line = lines.shift.strip
                when /^From: (.*)$/
                  mail.from = $1
                when /^To: (.*)$/
                  mail.to = $1.split(',').collect{|s| s.strip}
                when /^Cc: (.*)$/
                  mail.cc = $1.split(',').collect{|s| s.strip}
                when /^Bcc: (.*)$/
                  mail.bcc = $1.split(',').collect{|s| s.strip}
                when /^Subject: (.*)$/
                  mail.subject = $1
                when /^Date: (.*)$/
                  mail.date = Time.rfc2822($1)
                when /^MIME-Version: (.*)$/
                  mail.mime_version = $1
                when /^Content-type: (.*); charset=(.*)$/
                  mail.content_type = $1
                  mail.charset = $2
                when /^$/
                  break
              end
            end
            mail.body = lines.join("\n")
            mail
          end
        
          alias :parse :decode
        end

        # Returns a valid mail string instantiation
        def to_s
          str = <<-MAIL_END
            From: #{from}
            To: #{to.nil? ? '' : to.join(", ")}
            Cc: #{cc.nil? ? '' : cc.join(", ")}
            Bcc: #{bcc.nil? ? '' : bcc.join(", ")}
            Subject: #{subject}
            Date: #{date.rfc2822}
            MIME-Version: #{mime_version}
            Content-type: #{content_type}; charset=#{charset}

            #{body}
          MAIL_END
          str.gsub(/^[ \t]*/, '')
        end
        alias :encode :to_s
        alias :dump :to_s
        
        # Makes a deep copy of this mail. Changing the list of receivers
        # in particular does not affect the original mail
        def dup
          mail = super
          mail.to = to.nil? ? nil : to.dup
          mail.cc = cc.nil? ? nil : cc.dup
          mail.bcc = bcc.nil? ? nil : bcc.dup
          mail
        end
        
      end # class Mail
    end # class MailAgent
  end # module Tools
end # module Waw 