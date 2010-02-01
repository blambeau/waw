module Waw
  module Commands
    class ProfileCommand < Command
      
      def banner
        <<-EOF
          Usage: [waw-]profile [options]
        EOF
      end
      
      # Start command is always safe
      def check_command_policy
        true
      end
      
      # Runs the sub-class defined command
      def __run(requester_file, arguments)
        thread = ::Waw::Commands::StartCommand.new.waw_start(requester_file)
        thread.join
      rescue Interrupt => ex
        info "waw-profile stopping now... ciao!"
      end

    end # module ProfileCommand
  end # module Commands
end # module Waw