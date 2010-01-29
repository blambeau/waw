module Waw
  module Commands
    class StartCommand < Command
      
      def banner
        <<-EOF
          Usage: [waw-]start [options]
        EOF
      end
      
      # Start command is always safe
      def check_command_policy
        true
      end
      
      # Runs the sub-class defined command
      def __run(requester_file, arguments)
        Waw.autoload(requester_file)
        t = Thread.new(Waw.kernel) do |app|
          begin
            server = Rack::Handler::Mongrel
          rescue LoadError => e
            server = Rack::Handler::WEBrick
          end
          options = {:Port => Waw.config.web_port, :Host => "0.0.0.0", :AccessLog => []}
          server.run app, options
        end
        info "Your web application has been started successfully"
        info "Have a look at #{Waw.config.web_base}"
        info "Enjoy waw!"
        t.join
      end

    end # class StartCommand
  end # module Commans
end # module Waw