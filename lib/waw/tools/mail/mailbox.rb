module Waw
  module Tools
    class MailAgent
      # Helper for testing purposes only.
      class Mailbox
        
        # Creates an empty mailbox for a given adress
        def initialize(mail_address)
          @mail_address = mail_address
          @mails = []
        end
        
        # Returns the number of mails in this mailbox
        def size
          @mails.size
        end
        
        # Pushes a mail inside the mailbox, returns an id
        def push(mail)
          @mails << [mail, false]
          @mails.size-1
        end
        alias :<< :push
        
        # Returns the id-th mail in the mailbox. Returns nil
        # if no such mail can be found
        def [](id)
          mail = @mails[id]
          return nil unless mail
          mail[0]
        end
      
        # Checks if a mail is marked as read. Returns nil
        # if no such mail can be found
        def is_read?(id)
          mail = @mails[id]
          return nil unless mail
          mail[1]
        end
        
        # Marks a mail as read and returns it
        def read(id)
          mail = @mails[id]
          return nil unless mail
          mail[1] = true
          mail[0]
        end
        
        # Removes all mails
        def clear
          @mails.clear
        end
        
      end # class Mailbox
    end # class MailAgent
  end # module Tools
end # module Waw 