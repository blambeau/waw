module Waw
  module Tools
    class MailAgent
      # Allows creating WLang templates for mails easily
      class Template < Mail
        
        # The wlang dialect
        attr_writer :dialect
        
        # Returns the wlang dialect to use
        def dialect
          return @dialect if @dialect
          case content_type
            when 'text/html'
              'wlang/xhtml'
            when 'text/plain'
              'wlang/active-string'
            else
              Waw.logger.warn("Unable to get wlang dialect from content-type #{content_type}")
              Waw.logger.warn("Using wlang/active-string by default")
          end
        end
        
        # Instantiates this template using a given wlang context.
        # The date of the resulting mail is set to Time.now
        def instantiate(context = {})
          mail, args = self.dup, context.unsymbolize_keys
          mail.subject = mail.subject.wlang(args, dialect)
          mail.body = mail.body.wlang(args, dialect)
          mail.date = Time.now
          mail
        end
        alias :to_mail :instantiate
        
      end
    end # class MailAgent
  end # module Tools
end # module Waw