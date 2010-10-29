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
        @templates = {}
      end
      
      # Builds a mail instance. This method should always be used preferably
      # to an explicit Mail.new invocation.
      def mail(*args)
        Mail.new(*args)
      end
      
      # Builds a template instance. This method should always be used preferably
      # to an explicit Template.new invocation.
      def template(*args)
        Template.new(*args)
      end
      
      # Adds a mail template under a given name
      def add_template(name, *args)
        if args.size == 1 and Template===args[0]
          @templates[name] = args[0]
        else
          @templates[name] = template(*args)
        end
      end
      
      # Converts a named template to a mail
      def to_mail(template_name, wlang_context)
        raise ArgumentError, "No such template #{template_name}" unless @templates.has_key?(template_name)
        @templates[template_name].to_mail(wlang_context)
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
      
      #
      # Sends an email. If Waw.config.deploy_mode is set to 'production'
      # or 'acceptation', the mail is really sent. Otherwise it is pushed
      # in the receiver mailbox.
      #
      # This method accepts the following invocation signatures:
      #
      #   # sending a real Mail instance (and only one)
      #   agent.send_mail(mail)
      #
      #   # sending from a template for which receivers have been already set
      #   agent.send_mail(:my_template, {:title => "Hello"})
      #
      #   # sending from a template, with explicit receivers as varargs
      #   agent.send_mail(:my_template, {:title => "Hello"}, "receiver@example.com", ..., "receiver_N@example.com")
      #
      #   # sending from a template, with explicit receivers as an array
      #   agent.send_mail(:my_template, {:title => "Hello"}, [...])
      #
      def send_mail(*args)
        # Let try to match the signature
        if args.size == 1 and Mail===args[0]
          # first one
          mail = args[0]
        elsif Symbol===args[0] and Hash===args[1]
          # the others
          mail = to_mail(args.shift, args.shift)
          unless args.empty?
            if args.size == 1 and Array===args[0]
              # third one
              mail.to = args[0]
            else
              # fourth one
              mail.to = args
            end
          else
            # second one
          end
        else
          raise ArgumentError, "Unable to find the send_mail sigature you want with #{args.inspect}"
        end
        
        if do_it_really?
          require 'net/smtp'
          smtp_conn = Net::SMTP.new(@smtp_host, @smtp_port)
          smtp_conn.open_timeout = @smtp_timeout
          smtp_conn.start
          smtp_conn.send_message(mail.dump, mail.from, *mail.to)
          smtp_conn.finish
        else
          #Waw.logger.debug mail.dump
          sent = Mail.parse(mail.dump)
          mail.to.each {|who| mailbox(who) << sent.dup}
          mail.cc.each {|who| mailbox(who) << sent.dup}
          mail.bcc.each {|who| mailbox(who) << sent.dup}
        end
      end
      alias :<< :send_mail
      
    end # class MailAgent
  end # module Tools
end # module Waw