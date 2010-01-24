module Waw
  module Tools
    # Provides a tool to send mails simply
    class MailAgent
      
      # Creates a default mail agent
      def initialize(opts = {}, force_real = false)
        @force_real = force_real
        if do_it_really?
          @smtp_host = opts[:host]
          @smtp_port = opts[:port]
          @smtp_timeout = opts[:timeout]
          raise ArgumentError, "Opts should include :host, :port and :timeout parameters\n#{opts.inspect} received"\
            if @smtp_host.nil? or @smtp_port.nil? or @smtp_timeout.nil?
        end
      end
      
      # Send mails, really?
      def do_it_really?
        @force_real or (Waw.config and ['production', 'acceptation'].include?(Waw.config.deploy_mode))
      end
      
      # Returns installed mailboxes
      def mailboxes
        @mailboxes ||= Hash.new{|h, k| h[k] = Mailbox.new(k)}
      end
      
      # Returns the mailbox of a given receiver, creating
      # a new one if it cannot be found
      def mailbox(receiver)
        mailboxes[receiver]
      end
      
      # Sends an email. If Waw.config.deploy_mode is set to 'production'
      # or 'acceptation', the mail is really sent. Otherwise it is pushed
      # in the receiver mailbox.
      def send_mail(mail)
        if do_it_really?
          require 'net/smtp'
          smtp_conn = Net::SMTP.new(@smtp_host, @smtp_port)
          smtp_conn.open_timeout = @smtp_timeout
          smtp_conn.start
          smtp_conn.send_message(mail.body, mail.from, *mail.to)
          smtp_conn.finish
        else
          mail.to.each {|who| mailbox(who) << mail.dup}
        end
      end
      alias :<< :send_mail
      
    end # class MailAgent
  end # module Tools
end # module Waw